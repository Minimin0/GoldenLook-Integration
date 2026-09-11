# Golden Look Integration

## 🔗 Golden Look 저장소 바로가기

| 저장소 | 역할 |
|---|---|
| [🎨 GoldenLook-Frontend](https://github.com/Minimin0/GoldenLook-Frontend) | 사용자 화면, 모바일 UX, 사진 업로드, 결과 확인 및 공유 |
| [⚙️ GoldenLook-Backend](https://github.com/Minimin0/GoldenLook-Backend) | API, Supabase, Gemini, 전단 생성, SegFormer + LAB 이미지 처리 |
| [🔗 GoldenLook-Integration](https://github.com/Minimin0/GoldenLook-Integration) | 공통 계약, E2E 검증, 배포 기록, 평가 및 Production 관리 |

> 현재 저장소: **GoldenLook-Integration**
>
> Golden Look 전체 시스템의 계약, E2E 검증, 배포 및 Release Evidence를 관리합니다.

Golden Look의 Frontend와 Backend를 연결하고, 공통 Contract, E2E 검증, 배포 상태, 평가 결과 및 Production Release를 관리하는 Repository입니다.

## 프로젝트 개요

Integration Repository는 실제 Runtime을 구현하지 않습니다. 대신 Golden Look 전체 시스템의 계약, 검증 절차, 배포 기록, 평가 Evidence, Production Version Tracking을 관리합니다.

## Integration Repository 역할

- Frontend ↔ Backend Contract 관리
- Architecture 문서화
- E2E 시나리오 관리
- Deployment Evidence 정리
- Evaluation Report 관리
- Production Release 추적

## 전체 시스템 구조

```text
GoldenLook-Frontend
        │
        │ HTTPS API
        ▼
GoldenLook-Backend
        │
        ├── Gemini API
        ├── Supabase
        ├── Flyer Renderer
        └── Modal AI
             ├── SegFormer
             └── LAB Recolor

GoldenLook-Integration
   Contract / E2E / Deployment / Evidence
```

Integration은 Runtime 요청 경로가 아니라 개발·검증·릴리스 관리 Repository입니다.

## 📦 서비스 Repository

### Frontend

[GoldenLook-Frontend](https://github.com/Minimin0/GoldenLook-Frontend)

사용자 화면과 모바일 웹 UX를 담당합니다.

### Backend

[GoldenLook-Backend](https://github.com/Minimin0/GoldenLook-Backend)

API, 데이터, Gemini 및 이미지 AI 파이프라인을 담당합니다.

## 공통 Contract

`contracts/colors.json`은 20개 color id의 공통 계약입니다. Frontend와 Backend의 color contract와 동일해야 합니다.

## E2E 시나리오

- Normal Flow: 사진 → 자연어 → Gemini parse → 보호자 확인 → AI recolor → 전단 → 공개 URL → 공유
- Gemini Failure: Gemini 실패 → appearance 전부 unknown → 수동 입력 → 이후 정상 진행
- Modal Failure: Modal/Recolor 실패 → original image fallback → 전단 생성 → publish 성공
- Unknown Flow: appearance 전부 unknown → 원본 기반 전단 생성 → publish

## 배포 관리

Frontend Production URL, Backend Production URL, Modal Endpoint Status는 검증된 값만 기록합니다. 아직 정해지지 않은 값은 `TBD`로 유지합니다.

## Production Version Tracking

Release마다 Frontend HEAD SHA, Backend HEAD SHA, Integration Version, 테스트 결과, Secret Scan 결과, Contract Verification 결과를 기록합니다.

## 평가 Evidence

`evidence/` 아래에 screenshots, parse-tests, recolor-tests 결과를 보관합니다. 실제 개인정보나 민감한 사진은 저장하지 않습니다.

## 브랜치 전략

`main`은 Production-ready 상태만 유지합니다. 기본 개발은 `develop`에서 시작하며, 작업 브랜치는 `feat/*`, `fix/*`, `docs/*`, `chore/*` 형식을 사용합니다.

## 현재 상태

- Frontend Repository: TBD
- Frontend Production URL: TBD
- Frontend HEAD SHA: TBD
- Backend Repository: TBD
- Backend Production URL: TBD
- Backend HEAD SHA: TBD
- Modal Endpoint Status: TBD
- Integration Version: TBD
- Frontend Tests: TBD
- Backend Tests: TBD
- AI Pipeline Tests: TBD
- E2E Tests: TBD
- Secret Scan: TBD
- Contract Verification: TBD
- Production Release: TBD
