# Golden Look v4 Architecture

Golden Look v4의 현재 Production 아키텍처입니다.

```text
[ Browser / Mobile Web ]
          |
          | HTTPS
          v
[ GoldenLook-Frontend / Vercel ]
          |
          | Supabase Auth (Email/Password)
          | - browser client uses publishable/anon key only
          | - access token issued to browser
          |
          | Authorization: Bearer <access token>
          v
[ GoldenLook-Backend / Vercel ]
          |
          |-- Auth validation
          |     `supabase.auth.getUser(token)`
          |
          |-- Case API
          |     CRUD / generate / publish / flyer / cleanup
          |
          |-- Supabase PostgreSQL
          |     cases
          |     ai_generation_usage
          |     storage_deletion_failures
          |
          |-- Supabase Private Storage
          |     original image
          |     generated image
          |     5-minute signed URL
          |
          |-- Gemini Image API
          |     body_visible
          |     face_only
          |
          `-- Flyer Renderer
                public 1080x1350 PNG

[ GoldenLook-Integration ]
          |
          |-- Product / API / appearance contracts
          |-- 20-color palette
          |-- Architecture documentation
          |-- E2E / QA evidence
          |-- Deployment baseline
          `-- Release source of truth
```

## Frontend

Repository: `Minimin0/GoldenLook-Frontend`

역할:

- 모바일 중심 사용자 UI
- Supabase Email/Password 로그인·회원가입
- 사진 업로드 및 `photoMode` 직접 선택
- 인상착의 / 신체정보 입력
- AI 생성·재생성 UX
- 실종 정보 입력 및 publish
- `/my` 전단 관리
- `/c/[shareId]` 공개 전단 표시·공유

Frontend에는 `SUPABASE_SERVICE_ROLE_KEY`나 `GEMINI_API_KEY` 같은 server secret을 두지 않습니다.

## Backend

Repository: `Minimin0/GoldenLook-Backend`

역할:

- Supabase access token 검증
- owner-only Case CRUD
- private image storage 및 signed URL
- 생성 reservation / attempt identity / concurrency control
- 일일 AI 생성 제한 및 재생성 횟수 관리
- AI adapter 호출
- publish / flyer PNG / public metadata
- cleanup cron 및 storage deletion retry
- CORS allowlist

Backend는 service role과 Gemini key를 server-side 환경변수로만 사용합니다.

## AI

AI 코드는 별도 저장소가 아니라 Backend의 `lib/server/ai/`에 있습니다.

```text
POST /api/cases/[id]/generate
  -> generation reservation
  -> original private image download
  -> imageAdapter.generate(...)
  -> Gemini image model
  -> image sanitize / JPEG normalization
  -> unique generated storage path upload
  -> generation finalize
  -> old generated object cleanup
  -> signed URL response
```

현재 필수 경로에는 Gemini text parsing, Modal, SegFormer, LAB recolor가 없습니다.

## Supabase

Production에서 사용하는 범위:

- Auth: Email/Password
- PostgreSQL: case / generation lifecycle / cleanup state
- Storage: `case-images` private bucket
- RLS 및 direct privilege 제한
- service-role-only generation/publish RPC

원본 사진과 AI 생성 이미지는 public bucket으로 노출하지 않습니다. 공개 대상은 발행된 전단 PNG와 최소 public metadata뿐입니다.

## Deployment

- Frontend: Vercel
- Backend: Vercel
- Database/Auth/Storage: Supabase Seoul (`ap-northeast-2`)
- AI Provider: Gemini

세부 URL, SHA, deployment ID는 [`deployment.md`](deployment.md)를 기준으로 합니다.
