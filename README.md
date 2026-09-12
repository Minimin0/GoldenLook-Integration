# Golden Look Integration

Golden Look 전체의 **v4 제품 계약, E2E, 배포·평가 evidence**를 관리하는 source-of-truth 저장소입니다.

## 저장소

| 저장소 | 역할 |
|---|---|
| [GoldenLook-Frontend](https://github.com/Minimin0/GoldenLook-Frontend) | 모바일 UX |
| [GoldenLook-Backend](https://github.com/Minimin0/GoldenLook-Backend) | Auth/API/Storage/Image AI |
| **GoldenLook-Integration** | Contract/E2E/Release/Evidence |

## v4 한 줄 설명

보호자가 사진 유형과 실종 당시 옷 정보를 직접 선택하면, **몸이 나온 사진은 옷의 색과 형태를 편집하고 얼굴만 나온 사진은 예상 몸을 생성**해 `AI로 재현한 예상 모습` 전단을 만드는 서비스입니다.

## v4 핵심 문서

- [`docs/FINAL_PRODUCT_PLAN_v4.md`](docs/FINAL_PRODUCT_PLAN_v4.md)
- [`docs/DEVELOPMENT_EXECUTION_PLAN_v4.md`](docs/DEVELOPMENT_EXECUTION_PLAN_v4.md)
- [`docs/TEAM_CHANGE_SUMMARY_v4.md`](docs/TEAM_CHANGE_SUMMARY_v4.md)
- [`docs/V3_TO_V4_CHANGELOG.md`](docs/V3_TO_V4_CHANGELOG.md)

## AI 개발 원칙

AI 내부 구현은 최소 제약입니다. AI 담당자는 provider/model/prompt/pipeline을 자유롭게 수정할 수 있습니다. 다른 파트와 맞물리는 API/DTO/env/DB/Frontend 입력을 바꿀 때만 변경 내용을 보고하고 통합합니다.

## MVP에서 하지 않는 것

- Gemini text parsing
- 112/182
- 자체 제보
- Kakao/Google login

## 운영 원칙

Frontend/Backend의 문서와 구현이 충돌하면 Integration v4 contract를 기준으로 확인합니다. 구현 과정에서 더 나은 AI 방식이 발견되면, **AI 내부는 자유롭게 개선하고 contract 영향만 기록**합니다.
