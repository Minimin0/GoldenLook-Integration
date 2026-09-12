# GOLDEN LOOK - FINAL 개발 실행계획서 v4.0

> 기준일: 2026-09-12  
> 상위 기준: `FINAL_PRODUCT_PLAN_v4.md`

## 0. 실행 원칙

1. Gemini 자연어 parsing 작업은 중단한다.
2. SegFormer/Modal recolor는 제출 필수 경로에서 제거한다.
3. 이미지 AI는 adapter 경계만 맞추고 AI 담당자에게 구현 자율권을 준다.
4. Frontend/Backend는 AI provider 세부 구현을 몰라도 mock contract로 병렬 개발한다.
5. 통합 경계를 깨는 AI 변경은 금지하지 않지만 main merge 전에 보고한다.

---

# 1. 아키텍처

```text
Frontend
  ↓
Backend
  ├─ Auth / Ownership
  ├─ Case / Storage
  ├─ Image AI Adapter  <--- AI 담당자 자유 영역
  │    └─ Baseline: Gemini Image API
  ├─ Publish / Flyer
  └─ Cleanup
```

## AI 팀 자유 영역

권장 경로 예:

```text
lib/server/image-ai/
  index.ts
  provider.ts
  prompts.ts
  types.ts
  validation.ts
```

Python/별도 서비스가 필요하면 AI 담당자가 추가해도 된다. 단, app-facing adapter가 유지되면 된다.

---

# 2. 역할별 P0

## Frontend

- 로그인/회원가입
- 사진 유형 체크박스
- 사진 업로드
- 20색 palette
- 상의/하의/모자/신발/소지품 입력
- face_only 추가정보 UI
- generate loading/result
- 재생성 최대 3회
- 기본정보/publish
- 공개 전단/share
- 내 전단/delete

## Backend

- Supabase Auth session
- ownership
- cases schema
- private Storage
- create/get/patch/delete
- Image AI adapter 호출
- generate attempt 관리
- publish/shareId
- flyer
- cleanup

## AI 담당

- Gemini 이미지 생성/편집 POC
- body_visible prompt
- face_only prompt
- identity/background preservation 실험
- 결과 품질 비교
- adapter 구현/개선
- timeout/retry/error mapping
- 비용 측정
- AI change report

## Integration

- v4 contract source of truth
- E2E
- authz 공격 테스트
- 생성 결과 evidence
- release SHA 기록

---

# 3. 개발 순서

## Gate 1 - Contract/Auth

- v4 docs 반영
- `photo_mode`/appearance/body_profile schema
- Auth/ownership
- mock `/generate`

통과: A 계정 case를 B 계정이 못 읽음.

## Gate 2 - Input UX

- 사진 유형 체크
- 업로드
- palette
- 옷 정보
- face_only 추가 정보

통과: 두 모드 request DTO가 정확히 생성됨.

## Gate 3 - AI POC

AI 담당자는 구현 방식 제한 없이 결과를 만든다.

테스트:

- body_visible 5건 이상
- face_only 5건 이상
- 패딩→반팔
- 색 변경
- 얼굴 유사성
- 배경 유지

통과: 팀이 데모 가능한 결과 품질을 확인.

## Gate 4 - Generate Integration

`POST /api/cases/[id]/generate`

- owner check
- attempt limit
- AI adapter
- image save
- status/error

통과: 배포 환경에서 두 모드 성공.

## Gate 5 - Publish

- 보호자 확인
- 기본정보
- 연락처 공개 확인
- flyer/public/share

통과: 모바일 공유 가능.

## Gate 6 - Manage/Delete

- 내 전단
- delete
- Storage/DB cleanup
- 공개 URL 404

## Gate 7 - E2E/Submission

- iPhone Safari
- Android Chrome
- synthetic demo
- secret scan
- authz test
- cost/latency 기록

---

# 4. AI Change Governance

AI 담당자는 다음을 자유롭게 바꾼다.

- provider/model/prompt
- 언어/SDK
- 폴더/서비스 구조
- 후처리/validation
- retry/timeout/cache
- generation pipeline

단, 다음은 보고한다.

```text
[AI CHANGE REPORT]
날짜:
변경:
이유:
외부 API/DTO 영향:
환경변수 영향:
Frontend 영향:
DB/Storage 영향:
비용/속도 영향:
검증 결과:
```

**통합 경계에 영향이 없으면 승인 대기 없이 merge 가능한 작은 PR로 진행한다.**

경계에 영향이 있으면 feature branch 실험은 자유지만 main merge 전에 팀에 공유한다.

---

# 5. 주요 테스트

- 비로그인 private API 401
- 타인 case 404/403
- face_only body generation
- body_visible clothing edit
- 옷 종류 미입력 neutral outfit
- unknown 정보 prompt에서 확정 금지
- 재생성 버튼 3회 제한
- provider timeout 재시도
- AI safety rejection 처리
- publish 전 연락처 공개 동의
- delete 후 Storage/DB/public 404
- PII/secret 로그 없음

---

# 6. 완료 조건

- 두 모드 E2E
- Gemini parsing 코드가 제출 핵심 흐름에 없음
- SegFormer/Modal이 필수 의존성이 아님
- AI 팀이 provider를 바꿔도 adapter만 맞으면 Frontend 변경 불필요
- v4 README/AGENTS/CLAUDE가 세 저장소에서 동일한 방향을 설명
- Integration이 source of truth
