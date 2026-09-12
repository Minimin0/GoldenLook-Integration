# GoldenLook-Integration Agents - v4.0

## 역할
전체 시스템의 source of truth, contract, architecture, E2E, 배포 evidence, 평가, release tracking을 담당합니다.

## v4 제품 기준

- Gemini 자연어 parsing 없음
- 20색 직접 선택
- `body_visible`: 옷 색/형태 편집
- `face_only`: 얼굴 기반 예상 몸 생성
- baseline: Gemini Image API
- 결과 라벨: `AI로 재현한 예상 모습`
- 재생성 최대 3회

## AI 자유도 원칙

Integration은 AI 담당자의 내부 구현을 제한하지 않습니다.

동결하지 않는 것:
- provider/model
- prompt
- SDK/언어
- AI 폴더/서비스 구조
- generation/edit pipeline
- 후처리

동결하는 것은 **통합 경계와 제품 안전 규칙뿐**입니다.

AI 담당자가 외부 API/DTO/env/DB/Frontend 입력을 바꾸는 경우 변경 내용을 기록하고 downstream impact를 확인합니다. 실험 자체를 막지 않습니다.

## Source of Truth

- `docs/FINAL_PRODUCT_PLAN_v4.md`
- `docs/DEVELOPMENT_EXECUTION_PLAN_v4.md`
- `docs/TEAM_CHANGE_SUMMARY_v4.md`
- `docs/V3_TO_V4_CHANGELOG.md`

## 보안
Secret, 실제 `.env*`, 실제 개인정보, private image를 커밋하지 않습니다.

## PR
Contract 변경 PR은 Frontend/Backend 영향과 migration 여부를 명시합니다. Evidence PR은 검증한 Frontend/Backend SHA를 기록합니다.
