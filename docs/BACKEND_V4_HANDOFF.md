# Backend v4 Handoff

## Frontend

- Configure `NEXT_PUBLIC_API_BASE_URL` to the Backend deployment origin and send the Supabase access token as `Authorization: Bearer <token>`.
- Use `GET /api/cases` for My Flyers. It returns `{ cases }`, newest first, capped at 50.
- Create with multipart `photo`, `photoMode`, and optional `data` JSON. PATCH accepts JSON or multipart `photo` plus `data`.
- Treat signed `originalUrl` and `generatedUrl` as five-minute values; refresh GET/list when expired.
- Render `label` (`AI로 재현한 예상 모습`) beside every generated result. The public `/c/[shareId]` page can display or share `/api/flyer/[shareId]` directly; no public JSON case endpoint exists in v4.
- Disable regeneration when `regenerationsRemaining` is zero. Distinguish daily quota from case regeneration exhaustion using `DAILY_GENERATION_LIMIT` versus `GENERATION_LIMIT`.
- After publish, PATCH/generate return `CASE_PUBLISHED`; delete remains available. Public pages must be `noindex`.
- Remove the current Frontend-only `appearance.glasses` field before sending requests; it is not part of the frozen v4 garment contract.

## Backend Environment

`SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY`, `CORS_ALLOWED_ORIGINS`, `GEMINI_API_KEY`, `GEMINI_IMAGE_MODEL`, `AI_GENERATION_DAILY_LIMIT`, `NEXT_PUBLIC_BASE_URL`, `CRON_SECRET`.

Production frontend origins must be listed exactly in `CORS_ALLOWED_ORIGINS`. Production fails closed if it is missing.

## AI Team

Provider, model, prompt, SDK, pipeline, preprocessing, postprocessing, retry, timeout, and cost tuning remain AI-team-owned. Preserve the structured `photoMode`/appearance/body inputs, image result, temporary-error distinction, PII/secret rules, and Backend attempt lifecycle. Report changes to API DTOs, environment variables, DB/Storage, Frontend inputs, or cost structure before merge.

## Retention

The daily Vercel cron uses a 24-hour cutoff, producing an expected 24-48 hour deletion range. Storage deletion must succeed before the case row is deleted; failed stale-file deletion is retried from the deletion queue.
