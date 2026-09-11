# GoldenLook-Integration

## Project Overview
Golden Look is a three-repository MVP for Wanted AI Championship 2026. A guardian uploads one original photo and describes the missing person's clothing. Gemini helps structure the description, the guardian confirms it, Modal AI recolors only known supported clothing regions, and the flyer always includes the original photo.

## Repository Responsibility
This repository owns shared contracts, architecture documentation, E2E scenarios, verification scripts, evaluation notes, deployment evidence, and production release tracking. It does not implement the web app or backend runtime.

## Architecture
`GoldenLook-Frontend` calls `GoldenLook-Backend` over HTTPS. Backend integrates Gemini, Supabase private storage/PostgreSQL, flyer rendering, and Modal AI under `GoldenLook-Backend/ai/`. Integration documents and verifies the system. Integration contracts may become the source of truth over time.

## Tech Stack
- Markdown documentation
- POSIX shell verification scripts
- JSON shared contracts

## Directory Structure
- `contracts/`: shared contracts, including the 20 fixed color ids
- `docs/`: architecture, API, appearance, AI, privacy, and deployment docs
- `e2e/`: normal, Gemini fallback, Modal fallback, and unknown-flow scenarios
- `evidence/`: screenshots, parse tests, and recolor tests
- `scripts/`: health and contract checks
- `reports/`: release and evaluation reports

## Local Setup
```bash
chmod +x scripts/*.sh
scripts/contract-check.sh
```

## Environment Variables
No runtime environment variables are required in this repository today. Do not commit real `.env*` files.

## Branch Strategy
`main` is production-ready. `develop` is the base for active work. Use `feat/*`, `fix/*`, `docs/*`, and `chore/*` branches.

## Development Workflow
Update contracts and docs here first when they affect both app repositories. Keep evidence tied to exact frontend/backend SHAs once production URLs exist.

## Security Rules
No secrets, no private personal data, no private photos, and no invented release values. Use `TBD` until a value is verified.

## Current Status
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
