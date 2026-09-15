# Golden Look Integration

Golden Look 전체의 **제품 계약, 파트별 구현 현황, E2E, 배포 정보, QA evidence**를 관리하는 통합 source-of-truth 저장소입니다.

현재 Golden Look v4는 Frontend·Backend·AI가 Production 환경에서 연결된 상태이며, 핵심 Production E2E를 통과했습니다. 팀 단위 최종 QA는 계속 진행합니다.

## Production

| 구분 | 주소 / 기준 |
|---|---|
| Frontend | https://goldenlook-frontend.vercel.app |
| Backend | https://goldenlook-backend.vercel.app |
| Frontend main | `0e8a51b2b3489dcb1584e2599959d222be992819` |
| Backend main | `6264d0341054256b3ae92c46a0530c29fb8fedf7` |
| Supabase | Seoul (`ap-northeast-2`) / Production 연결 완료 |
| Release 상태 | Code Freeze 승인, 팀 QA 진행 중 |

상세 배포 기준과 검증 결과는 [`docs/deployment.md`](docs/deployment.md)를 확인합니다.

## 저장소 구성

| 저장소 | 역할 |
|---|---|
| [GoldenLook-Frontend](https://github.com/Minimin0/GoldenLook-Frontend) | 사용자 화면, Auth UI, 사진·인상착의 입력, AI 결과 확인, 전단 발행·공유·관리 |
| [GoldenLook-Backend](https://github.com/Minimin0/GoldenLook-Backend) | Auth 검증, Case API, Supabase DB/Storage, AI orchestration, 전단 PNG, cleanup |
| **GoldenLook-Integration** | 제품 계약, 파트별 통합 문서, E2E, 배포·QA·Release evidence |

AI 구현은 별도 네 번째 저장소가 아니라 `GoldenLook-Backend/lib/server/ai/` 안에 있으며, AI 담당자가 해당 경계를 소유합니다.

## Golden Look v4

보호자가 실종자의 기존 사진과 실종 당시 정보를 입력하면, AI가 **실종 당일 예상 모습을 재현**하고 모바일 전단으로 발행·공유하는 서비스입니다.

사용자가 사진 유형을 직접 선택합니다.

- `body_visible`: 몸이 나온 사진을 기반으로 얼굴·배경·포즈를 최대한 유지하면서 옷의 색/형태를 반영
- `face_only`: 얼굴 사진을 identity reference로 사용해 나이·키·성별·체형·옷 정보를 반영한 실사형 전신 예상 모습 생성

생성 결과에는 `AI로 재현한 예상 모습`을 표시합니다.

## 현재 사용자 흐름

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

## 파트별 구현 현황

| 파트 | 현재 상태 | 핵심 범위 |
|---|---|---|
| Frontend | Production 배포 / QA 진행 | `/`, `/login`, `/create`, `/my`, `/c/[shareId]`, 4단계 작성 위저드, 모바일 UI |
| Backend | Production 배포 / E2E PASS | Supabase Auth 검증, owner-only CRUD, private storage, signed URL, generate/publish/flyer/cleanup |
| AI | Production 연동 / 실제 Gemini 호출 PASS | `body_visible`, `face_only`, timeout/retry, JPEG 후처리, synthetic 평가 도구 |
| Integration | Source of truth | v4 계약, 색상 계약, API/아키텍처/배포/E2E 문서 |

전체 구현 요약은 [`docs/FINAL_IMPLEMENTATION_SUMMARY.md`](docs/FINAL_IMPLEMENTATION_SUMMARY.md)에 정리합니다.

## 문서 인덱스

### 최종 구현 / 운영

- [`docs/FINAL_IMPLEMENTATION_SUMMARY.md`](docs/FINAL_IMPLEMENTATION_SUMMARY.md) — Frontend·Backend·AI·Integration 전체 구현 현황
- [`docs/architecture.md`](docs/architecture.md) — 현재 Production 아키텍처
- [`docs/ai-pipeline.md`](docs/ai-pipeline.md) — v4 AI 파이프라인
- [`docs/api-contract.md`](docs/api-contract.md) — 앱-facing API 계약
- [`docs/deployment.md`](docs/deployment.md) — Production 배포 기준과 검증 현황
- [`docs/privacy.md`](docs/privacy.md) — 개인정보/보관 원칙

### 제품 계약 / 개발 기준

- [`docs/FINAL_PRODUCT_PLAN_v4.md`](docs/FINAL_PRODUCT_PLAN_v4.md)
- [`docs/DEVELOPMENT_EXECUTION_PLAN_v4.md`](docs/DEVELOPMENT_EXECUTION_PLAN_v4.md)
- [`docs/TEAM_CHANGE_SUMMARY_v4.md`](docs/TEAM_CHANGE_SUMMARY_v4.md)
- [`docs/V3_TO_V4_CHANGELOG.md`](docs/V3_TO_V4_CHANGELOG.md)
- [`docs/BACKEND_V4_HANDOFF.md`](docs/BACKEND_V4_HANDOFF.md)
- [`contracts/colors.json`](contracts/colors.json) — 20색 팔레트 계약

## 검증 기준

현재 Release baseline에서 확인된 항목:

- Frontend lint / test / typecheck / build PASS
- Backend lint / test / typecheck / build PASS
- Supabase Email/Password Auth PASS
- owner-only Case CRUD 및 사용자 간 접근 차단 PASS
- private Storage 및 signed URL PASS
- 실제 Gemini `body_visible` / `face_only` 생성 PASS
- 전단 publish 및 1080×1350 PNG PASS
- 공개 metadata 최소 필드 계약 PASS
- 삭제 후 public flyer/meta 404 PASS
- secret/raw storage path browser 노출 없음

팀 QA에서 발견된 문제는 Code Freeze 원칙에 따라 **재현 → 담당 파트 확인 → blocker 판정 → 최소 수정 PR** 순서로 처리합니다.

## MVP에서 하지 않는 것

- Gemini 자연어 parsing
- 112/182 신고 기능
- 자체 제보 기능
- Kakao/Google 로그인
- 경찰/공공기관 시스템 연동

## 개발 원칙

AI 내부 구현은 AI 담당자가 자유롭게 개선할 수 있습니다. 단, API/DTO/env/DB/Storage/Frontend 입력과 같이 다른 파트에 영향을 주는 계약 변경은 반드시 통합 문서에 반영합니다.

Frontend/Backend 구현 문서와 충돌하는 경우 이 저장소의 v4 제품 계약을 우선 기준으로 확인합니다.
