# Production Deployment

Golden Look v4의 현재 Production 배포 기준입니다.

마지막 정리 기준: 2026-09-15

## Release Baseline

| 영역 | Repository / Service | Production 기준 |
|---|---|---|
| Frontend | `Minimin0/GoldenLook-Frontend` | `0e8a51b2b3489dcb1584e2599959d222be992819` |
| Backend | `Minimin0/GoldenLook-Backend` | `6264d0341054256b3ae92c46a0530c29fb8fedf7` |
| Integration | `Minimin0/GoldenLook-Integration` | v4 source of truth / release docs |
| Database/Auth/Storage | Supabase | Seoul `ap-northeast-2` |
| AI | Gemini | `gemini-3.1-flash-image` |

## Production URLs

### Frontend

- URL: https://goldenlook-frontend.vercel.app
- Vercel project: `goldenlook-frontend`
- deployment: `dpl_BEC8RueQ9EpxtauXEf5uBwXaJzdn`
- deployment status: READY
- main SHA: `0e8a51b2b3489dcb1584e2599959d222be992819`

### Backend

- URL: https://goldenlook-backend.vercel.app
- Vercel project: `goldenlook-backend`
- deployment: `dpl_Bkr4PHf5s9yyCQfM7W9WCGeMENa7`
- deployment status: READY
- main SHA: `6264d0341054256b3ae92c46a0530c29fb8fedf7`
- AI PR #5 included: YES

### Supabase

- project ref: `ppdurqupxsabawmqyutj`
- region: Seoul (`ap-northeast-2`)
- Auth: Email/Password
- Email confirmation: enabled
- Database: PostgreSQL
- Storage: private `case-images` bucket

## Runtime Topology

```text
Browser
  |
  |-- Supabase Auth (Email/Password)
  |
  v
Frontend / Vercel
  |
  | Authorization: Bearer <Supabase access token>
  v
Backend / Vercel
  |
  |-- Supabase PostgreSQL
  |-- Supabase Private Storage
  |-- Gemini Image API
  `-- Flyer PNG renderer
```

## Required Environment Names

값 자체는 저장소에 기록하지 않습니다.

### Frontend

```text
NEXT_PUBLIC_API_BASE_URL
NEXT_PUBLIC_SUPABASE_URL
NEXT_PUBLIC_SUPABASE_ANON_KEY
NEXT_PUBLIC_BASE_URL
```

Optional:

```text
NEXT_PUBLIC_KAKAO_JS_KEY
```

### Backend

```text
SUPABASE_URL
SUPABASE_SERVICE_ROLE_KEY
GEMINI_API_KEY
GEMINI_IMAGE_MODEL
CORS_ALLOWED_ORIGINS
AI_GENERATION_DAILY_LIMIT
NEXT_PUBLIC_BASE_URL
CRON_SECRET
```

`SUPABASE_SERVICE_ROLE_KEY`, `GEMINI_API_KEY`, `CRON_SECRET`은 server-side secret으로만 관리합니다.

## Production Verification

### Frontend

- lint: PASS
- test: PASS — 4 files / 45 tests
- typecheck: PASS
- build: PASS
- landing: PASS
- login: PASS
- anonymous `/create` redirect: PASS
- authenticated `/create`: PASS
- `/my`: PASS
- public flyer view: PASS

### Backend

- lint: PASS
- test: PASS — 10 files / 54 tests
- typecheck: PASS
- build: PASS
- Auth validation: PASS
- owner-only Case CRUD: PASS
- cross-user access block: PASS
- private Storage: PASS
- signed URL: PASS
- CORS exact frontend origin: PASS
- raw storage path API leak: PASS

### AI / E2E

- actual Gemini provider call: PASS
- `body_visible`: PASS
- `face_only`: PASS
- regeneration app contract: PASS
- publish: PASS
- public flyer PNG: PASS
- flyer size: 1080×1350 PASS
- `AI로 재현한 예상 모습` label: PASS
- public metadata minimal fields: PASS
- delete cleanup: PASS
- flyer/meta after delete: 404 PASS

## Release Status

- Code Freeze: APPROVED
- Core Production E2E: PASS
- Team QA: IN PROGRESS
- New features during QA: prohibited
- Allowed changes: reproducible blocker/security/privacy/deploy defects only, through minimal PR

## Known Operational Note — Auth Email

Supabase 기본 SMTP는 개발/테스트 용도로 rate limit이 강합니다. 여러 팀원이 짧은 시간에 회원가입 confirmation email을 반복 요청하면 `email rate limit`에 걸릴 수 있습니다.

현재 QA에서는 이미 확인된 계정 또는 Supabase에서 confirm된 QA 계정을 사용할 수 있습니다.

공개 심사 기간에 다수 사용자의 직접 회원가입을 받을 경우에는 custom SMTP 연결을 권장합니다. 이메일 인증 자체는 비활성화하지 않습니다.

## Deployment Change Rule

Production 배포가 변경되면 이 문서에서 최소 다음 항목을 갱신합니다.

1. Frontend / Backend main SHA
2. Vercel deployment ID
3. READY 여부
4. Production smoke 결과
5. 계약 변경 여부
6. AI model/env 변경 여부

secret 값은 어떤 경우에도 이 저장소에 기록하지 않습니다.
