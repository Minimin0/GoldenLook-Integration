# GoldenLook-Integration Agents

## 역할
Golden Look 전체 시스템의 contract, architecture, E2E, deployment evidence, evaluation, production release tracking을 담당합니다.

## 수정 가능한 영역
`contracts/`, `docs/`, `e2e/`, `evidence/`, `scripts/`, `reports/`를 수정합니다. App runtime behavior는 이 Repository에서 구현하지 않습니다.

## 수정 금지 계약
팀장 승인 없이 변경하지 않습니다: appearance shape, `known` / `none` / `unknown` 의미, 20 color ids, API 6개 경로, 원본 사진 병기, 얼굴/몸/포즈 생성 금지, Gemini 사용자 확인, AI failure fallback, private storage 원칙.

## Secret 관리
Secret, 실제 `.env*`, private photo, service-role key, API key를 커밋하지 않습니다. Public Repository에 올라가는 내용은 모두 공개 가능해야 합니다.

## 브랜치 전략
`main`은 Production-ready 상태만 유지합니다. 기본 작업은 `develop`에서 시작하며, 브랜치는 `feat/*`, `fix/*`, `docs/*`, `chore/*` 형식을 사용합니다.

## PR 원칙
Contract를 변경하는 PR은 downstream Frontend/Backend 영향을 설명해야 합니다. Evidence PR은 검증한 Frontend/Backend SHA를 명시합니다.

## 테스트 원칙
Contract 변경 전후로 `scripts/contract-check.sh`를 실행합니다.

## 아키텍처 원칙
팀장 승인 없이 Spring Boot, Firebase, auth, voice, Kubernetes, 4번째 AI Repository를 추가하지 않습니다.
