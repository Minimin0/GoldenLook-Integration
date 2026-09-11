# GoldenLook-Integration Agents

## Role
System contract, architecture, E2E, deployment evidence, evaluation, and production release tracking for Golden Look.

## Editable Areas
Edit `contracts/`, `docs/`, `e2e/`, `evidence/`, `scripts/`, and `reports/`. Do not implement app runtime behavior here.

## Fixed Contracts
Do not change without team lead approval: appearance shape, `known` / `none` / `unknown` meanings, the 20 color ids, six API paths, original-photo pairing, no face/body/pose generation, Gemini user confirmation, AI failure fallback, and private storage principle.

## Secrets
Never commit secrets, real `.env*`, private photos, service-role keys, or API keys. Public repository contents must be safe to publish.

## Branch Strategy
`main` is production-ready only. Work from `develop`; feature branches use `feat/*`, `fix/*`, `docs/*`, or `chore/*`.

## PR Principles
Any PR changing contracts must explain downstream frontend/backend impact. Evidence PRs should identify the tested frontend/backend SHAs.

## Tests
Run `scripts/contract-check.sh` before merging contract changes.

## Architecture
Do not add Spring Boot, Firebase, auth, voice, Kubernetes, or a fourth AI repository unless the team lead approves an architecture change.
