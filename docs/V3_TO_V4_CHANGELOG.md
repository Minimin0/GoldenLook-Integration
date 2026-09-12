# Golden Look v3 -> v4 변경로그

- Gemini 자연어 parse 제거
- 4카테고리 자연어 입력 제거, 20색 직접 선택 중심으로 변경
- `photoMode(body_visible/face_only)` 추가
- body_visible에서 옷 색 + 옷 형태 생성형 편집 허용
- face_only에서 몸 생성 허용
- face_only body profile: 나이/키/성별/체형
- 얼굴-only 옷 종류는 선택, 미입력 시 neutral basic outfit
- 결과 라벨 `AI로 재현한 예상 모습`
- 공개 전단은 생성 결과 중심
- 자연스럽게 서 있는 자세
- 재생성 최대 3회
- 배경 최대한 유지
- SegFormer/LAB/Modal을 필수 구조에서 제거
- baseline AI를 Gemini Image API로 변경
- AI 담당자 내부 구현 권한 대폭 확대
- AI provider/model/prompt/pipeline은 비동결
- API/DTO/env/DB/Frontend 영향 변화만 보고/통합 조정
