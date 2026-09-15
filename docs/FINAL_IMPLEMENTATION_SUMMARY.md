# Golden Look Final Implementation Summary

Golden Look v4의 Frontend, Backend, AI, Integration 및 Production 배포 상태를 한 문서에서 확인할 수 있도록 정리한 통합 구현 현황입니다.

정리 기준: 2026-09-15

## 1. Product Baseline

Golden Look은 보호자가 제공한 사진과 실종 당시 정보를 바탕으로 **AI가 실종 당일 예상 모습을 재현하고 모바일 전단으로 발행·공유하는 서비스**입니다.

핵심 사용자 흐름:

```text
랜딩
→ 이메일 회원가입 / 로그인
→ 사진 업로드
→ 사진 모드 선택
→ 인상착의 선택
→ AI 예상 모습 생성
→ 보호자 확인 / 재생성
→ 실종 정보 입력
→ 전단 발행
→ 공개 URL 공유
→ 내 전단 관리 / 삭제
```

사진 모드는 사용자가 직접 선택합니다.

- `body_visible`: 몸이 보이는 원본 사진을 기반으로 image edit
- `face_only`: 얼굴 사진을 identity reference로 사용해 실사형 전신 예상 모습 생성

생성 결과는 `AI로 재현한 예상 모습`으로 명확히 표시합니다.

---

## 2. Frontend

Repository: https://github.com/Minimin0/GoldenLook-Frontend

Production: https://goldenlook-frontend.vercel.app

Main SHA: `0e8a51b2b3489dcb1584e2599959d222be992819`

### 역할

Frontend는 실제 사용자가 만나는 전체 Web UX를 담당합니다.

- 랜딩 및 서비스 설명
- Email/Password 회원가입·로그인
- 사진 업로드
- `body_visible` / `face_only` 선택
- 인상착의 및 신체정보 입력
- AI 생성 / 재생성
- 실종 정보 입력
- 전단 발행
- 공개 전단 공유
- 내 전단 목록 / 삭제

### 주요 화면

| Route | Auth | 역할 |
|---|---|---|
| `/` | 불필요 | 랜딩 / 서비스 설명 |
| `/demo` | 불필요 | synthetic 30초 체험 |
| `/login` | - | Email/Password 로그인·회원가입 |
| `/create` | 필요 | 4단계 전단 작성 위저드 |
| `/my` | 필요 | 내 전단 관리 |
| `/c/[shareId]` | 불필요 | 공개 전단 |

### 4단계 Create Flow

1. 사진 업로드 및 `photoMode` 선택
2. 인상착의 입력
3. AI 예상 모습 생성 / 재생성
4. 실종 정보 입력 및 publish

### Frontend 보안 원칙

Frontend에는 다음 secret을 두지 않습니다.

- Supabase service role key
- Gemini API key
- Backend server secret

브라우저에서는 Supabase publishable/anon key와 로그인 후 발급받은 access token만 사용합니다.

### 검증

- lint: PASS
- tests: 4 files / 45 tests PASS
- typecheck: PASS
- build: PASS
- Production landing/login/create/my smoke: PASS
- browser bundle secret leak: PASS

---

## 3. Backend

Repository: https://github.com/Minimin0/GoldenLook-Backend

Production: https://goldenlook-backend.vercel.app

Main SHA: `6264d0341054256b3ae92c46a0530c29fb8fedf7`

### 역할

Backend는 Auth 검증, 데이터 ownership, private image storage, AI orchestration, 전단 발행과 cleanup을 담당합니다.

### 주요 기능

- Supabase Bearer token 검증
- owner-only Case CRUD
- cross-user 접근 차단
- private `case-images` Storage
- 5분 signed URL 발급
- EXIF 제거 및 이미지 sanitize
- AI generation reservation / attempt identity
- generation concurrency protection
- 일일 생성 제한
- 첫 생성 + 최대 3회 성공 재생성
- generated image lifecycle 관리
- publish validation
- public flyer PNG
- public flyer metadata 최소 노출
- cleanup cron
- storage deletion failure retry queue
- CORS allowlist

### API

```text
GET    /api/cases
POST   /api/cases
GET    /api/cases/[id]
PATCH  /api/cases/[id]
DELETE /api/cases/[id]
POST   /api/cases/[id]/generate
POST   /api/cases/[id]/publish
GET    /api/flyer/[shareId]
GET    /api/flyer/[shareId]/meta
GET    /api/cron/cleanup
POST   /api/cron/cleanup
```

Private route는 `Authorization: Bearer <Supabase access token>`을 사용합니다.

### Supabase 구조

주요 table:

- `public.cases`
- `public.ai_generation_usage`
- `public.storage_deletion_failures`

주요 server-only RPC:

- `begin_case_generation(...)`
- `finish_case_generation(...)`
- `abort_case_generation(...)`
- `publish_case(...)`

원본/생성 이미지 경로는 API DTO에 raw path로 반환하지 않습니다.

### 검증

- lint: PASS
- tests: 10 files / 54 tests PASS
- typecheck: PASS
- build: PASS
- Auth + CRUD Production E2E: PASS
- owner isolation: PASS
- private Storage: PASS
- signed URL: PASS
- CORS: PASS
- publish / flyer / cleanup: PASS

---

## 4. AI

AI 구현 위치:

```text
GoldenLook-Backend/lib/server/ai/
```

AI 파트는 별도의 네 번째 Repository를 사용하지 않습니다.

### Provider / Model

현재 기본 Provider는 Gemini이며 기본 모델은:

```text
gemini-3.1-flash-image
```

실제 Production model name은 Backend의 `GEMINI_IMAGE_MODEL`로 주입합니다.

### `body_visible`

원본 인물 사진을 기반으로 하는 image edit 모드입니다.

목표:

- identity 유지
- 얼굴 유지
- 배경 / 포즈 / 조명 최대한 유지
- known clothing color/type 반영
- group photo에서는 중심 인물 1명만 편집
- 선글라스·마스크 등 가려진 얼굴 특징을 임의로 생성하지 않음

### `face_only`

얼굴 사진을 identity reference로 사용해 실사형 full-body 이미지를 생성합니다.

반영 정보:

- age
- height
- gender
- body type
- clothing

현재 3:4 full-body output을 목표로 2K generation을 사용합니다.

### 안정성

- provider attempt timeout: 75초
- 최대 2회 시도
- 429/5xx/network/timeout/no-image response 재시도
- safety block 및 일반 4xx는 재시도하지 않음
- generate route maxDuration: 180초
- 결과 JPEG normalization / longest side 1536px 이하

### AI Evaluation

Backend의 `npm run ai:eval`로 synthetic 평가를 수행할 수 있습니다.

평가 범위:

- face similarity
- background / pose preservation
- clothing 반영
- body profile 반영
- photorealism
- unknown 정보 임의 생성 여부
- latency

### Production 검증

- actual Gemini provider call: PASS
- `body_visible`: PASS
- `face_only`: PASS
- regeneration app contract: PASS
- signed generated image: PASS

---

## 5. Integration

Repository: https://github.com/Minimin0/GoldenLook-Integration

Integration Repository는 실행 앱이 아니라 **전체 프로젝트 계약과 release source of truth**입니다.

관리 범위:

- final product plan
- development execution plan
- frontend/backend/AI 통합 구조
- API contract
- appearance contract
- 20색 palette contract
- E2E flow
- privacy policy
- deployment baseline
- QA / release evidence

주요 문서:

- `docs/FINAL_PRODUCT_PLAN_v4.md`
- `docs/DEVELOPMENT_EXECUTION_PLAN_v4.md`
- `docs/TEAM_CHANGE_SUMMARY_v4.md`
- `docs/architecture.md`
- `docs/ai-pipeline.md`
- `docs/api-contract.md`
- `docs/deployment.md`
- `contracts/colors.json`

---

## 6. Production Deployment

| Part | Production |
|---|---|
| Frontend | https://goldenlook-frontend.vercel.app |
| Backend | https://goldenlook-backend.vercel.app |
| Frontend Vercel deployment | `dpl_BEC8RueQ9EpxtauXEf5uBwXaJzdn` |
| Backend Vercel deployment | `dpl_Bkr4PHf5s9yyCQfM7W9WCGeMENa7` |
| Supabase region | Seoul `ap-northeast-2` |
| Supabase project ref | `ppdurqupxsabawmqyutj` |

Backend Production SHA와 GitHub main SHA는 `6264d0341054256b3ae92c46a0530c29fb8fedf7`로 일치합니다.

상세한 환경변수 이름과 검증 결과는 `docs/deployment.md`를 기준으로 합니다.

---

## 7. Production E2E / QA

현재까지 핵심 Production E2E에서 확인된 항목:

- Email/Password Auth PASS
- Case CRUD PASS
- cross-user 접근 차단 PASS
- private Storage PASS
- signed URL PASS
- `body_visible` Gemini generation PASS
- `face_only` Gemini generation PASS
- regeneration contract PASS
- publish PASS
- flyer PNG 1080×1350 PASS
- `AI로 재현한 예상 모습` label PASS
- public meta: `contact`, `missingAt`, `name`, `place` only PASS
- `/create` PASS
- `/my` PASS
- public `/c/[shareId]` PASS
- case delete PASS
- delete 후 flyer/meta 404 PASS
- final Storage residue 없음 확인
- deletion failure queue 없음 확인

### 현재 QA 상태

Core Production E2E와 Code Freeze 검증은 완료됐고, 현재는 팀원별 최종 QA를 진행합니다.

Code Freeze 이후 수정 허용 범위:

- 주요 사용자 흐름 blocker
- security defect
- privacy leak
- build/deploy failure
- 명백한 데이터 유실 가능성

개선 목적의 신규 기능이나 광범위 refactor는 진행하지 않습니다.

---

## 8. Privacy / Safety

- original image: private
- generated image: private
- public flyer만 외부 공유
- raw storage path API 노출 금지
- user id / case 내부 UUID public flyer 노출 금지
- 이름/연락처/실종 장소를 AI prompt에 전달하지 않음
- 공개 연락처는 보호자 명시적 동의 필요
- 실제 테스트는 synthetic image 사용
- 최대 48시간 내 cleanup 정책

---

## 9. MVP Exclusions

현재 MVP에 포함하지 않는 범위:

- Gemini text parsing
- 자유 텍스트 기반 옷차림 분석
- 112/182 신고 기능
- 자체 제보 기능
- Kakao/Google 로그인
- 경찰/공공기관 시스템 직접 연동
- Modal/SegFormer/LAB mandatory pipeline

---

## 10. Current Release State

```text
Frontend           Production READY
Backend            Production READY
Supabase           Connected
Gemini             Production call PASS
Production E2E     PASS
Security/Privacy   PASS
Documentation      v4 aligned
Code Freeze        APPROVED
Team QA            IN PROGRESS
```

QA에서 blocker가 발견되지 않는 한 현재 Production baseline을 제출 기준으로 유지합니다.
