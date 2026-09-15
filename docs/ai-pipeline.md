# AI Pipeline (v4)

AI 구현 위치: `GoldenLook-Backend/lib/server/ai/`

AI 파트는 provider/model/prompt/pipeline 내부를 독립적으로 개선할 수 있으며, 앱-facing API/DTO/env/DB/Storage 계약에 영향을 주는 변경만 통합 대상으로 봅니다.

## Flow

```text
POST /api/cases/[id]/generate
  -> Backend generation reservation
  -> original private image download
  -> imageAdapter.generate(input)
  -> Gemini image model
  -> image sanitize / JPEG normalization
  -> unique generated path upload
  -> generation finalize
  -> previous generated object cleanup
  -> signed URL response
```

현재 기본 모델은 `GEMINI_IMAGE_MODEL=gemini-3.1-flash-image`이며, 출력 설정은 모드에 따라 다릅니다.

- `body_visible`: 1K generation, 원본 비율 유지
- `face_only`: 2K generation, 3:4 전신 중심

최종 이미지는 Backend에서 정리해 JPEG로 저장하며 longest side는 1536px 이하로 맞춥니다.

## App-facing contract

AI adapter 입력은 구조화된 정보입니다.

- `photoMode`
- appearance
- body profile
- age
- height
- original image bytes / MIME

AI는 앱에 직접 DTO를 노출하지 않습니다. Backend route가 AI 성공/실패를 Case generation lifecycle과 앱-facing 응답으로 변환합니다.

## Modes

### `body_visible`

원본 사진을 기반으로 하는 image edit 경로입니다.

- 얼굴 / identity를 최대한 유지
- 원본 배경 / 포즈 / 조명 / 구도를 최대한 유지
- 알려진 옷 종류와 색을 반영
- 여러 명이 나온 경우 가장 중심적이고 두드러진 인물 1명만 대상으로 처리
- 선글라스·마스크처럼 원본에서 얼굴을 가린 요소는 유지하고 가려진 특징을 임의로 생성하지 않음

### `face_only`

얼굴 사진을 identity reference로 사용해 실사형 전신 예상 모습을 생성합니다.

입력에 다음 정보가 필요합니다.

- 나이
- 키
- 성별
- 체형
- 상의/하의 등 알려진 옷 정보

출력은 자연스러운 standing full-body 3:4 구도를 목표로 하며, 얼굴이 전신 안에서 너무 작아지는 문제를 줄이기 위해 2K output을 사용합니다.

## Input rules

- `known` 정보만 사실처럼 반영
- `unknown`은 추정해서 사실로 만들지 않음
- `none`은 해당 항목이 없다는 의미
- 20색 palette ID를 영어 색상명 + HEX로 변환해 prompt에 사용
- 이름, 연락처, 실종 장소 등 flyer PII는 AI prompt에 전달하지 않음
- AI 모델이 텍스트를 렌더링하도록 요구하지 않음
- `AI로 재현한 예상 모습` 라벨은 Frontend/Backend flyer가 결정적으로 표시

## Reliability

- provider attempt timeout: 75초
- 최대 2회 시도
- 재시도 대상: 429, 5xx, network error, timeout, 이미지가 없는 응답
- 안전 차단 및 일반 4xx는 무조건 재시도하지 않음
- generate route `maxDuration`: 180초
- provider 로그에 이미지 bytes, prompt, 개인정보를 남기지 않음

## Regeneration

- 첫 성공 생성: 1회
- 추가 성공 재생성: 최대 3회
- 총 최대 성공 결과: 4개
- Backend가 `regenerationCount` / `regenerationsRemaining` 관리
- 새 결과는 항상 새 private storage path에 저장
- 이전 generated object는 성공적인 교체 이후 삭제 대상

## Evaluation

Backend에서 다음 명령으로 synthetic 평가를 수행할 수 있습니다.

```bash
npm run ai:eval
```

기본 평가 세트:

- `body_visible` 5건
- `face_only` 5건

어려운 사진 세트는 `AI_EVAL_SET=hard`로 실행합니다.

평가 항목:

- face similarity
- background / pose preservation
- 옷 색·종류 반영
- body profile 반영
- photorealism
- unknown 정보 임의 생성 여부
- latency

평가는 synthetic / fictional person 이미지만 사용하며 결과 리포트는 `.ai-eval/` 아래에 생성되고 Git에는 커밋하지 않습니다.

## Production verification

최종 Production E2E에서 확인된 항목:

- `body_visible` 실제 Gemini generation PASS
- `face_only` 실제 Gemini generation PASS
- generated JPEG / signed URL PASS
- regeneration app contract PASS
- publish / flyer flow PASS

## Removed from v3 required path

다음 기술은 현재 Golden Look v4의 필수 runtime path에 없습니다.

- Gemini text parsing
- SegFormer clothing segmentation
- LAB deterministic recolor
- Modal AI service

필요 시 향후 AI-internal 도구로 다시 검토할 수 있지만 현재 제품 계약에는 포함하지 않습니다.
