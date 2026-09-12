# Golden Look v4 API Contract

Private routes use `Authorization: Bearer <Supabase access token>`. Non-owned case IDs return `404`. Browser origins must be listed in Backend `CORS_ALLOWED_ORIGINS`.

| Method | Path | Auth | Role |
|---|---|---|---|
| GET | `/api/cases` | user | My Flyers list, newest first, max 50 |
| POST | `/api/cases` | user | create case and upload photo |
| GET/PATCH/DELETE | `/api/cases/[id]` | owner | read, update, delete |
| POST | `/api/cases/[id]/generate` | owner | generate or regenerate image |
| POST | `/api/cases/[id]/publish` | owner | idempotent publish |
| GET | `/api/flyer/[shareId]` | public | flyer PNG |

The Backend also exposes authenticated cron cleanup at `/api/cron/cleanup`; it is not an app-facing route.

`photoMode` is `body_visible|face_only`. Appearance status is `known|none|unknown`; known garments require a 20-color contract ID. Face-only generation requires age (1-120), height (40-230 cm), gender, and body type.

Generation states are `PENDING`, `GENERATING`, `GENERATED`, and `TEMPORARY_ERROR`. The first success plus three successful regenerations are allowed. Internal attempt UUIDs prevent stale requests from finishing or aborting newer requests. Clients handle `GENERATION_LIMIT`, `DAILY_GENERATION_LIMIT`, `GENERATION_IN_PROGRESS`, and `CASE_PUBLISHED` distinctly.

Private image URLs expire after five minutes. Public output never includes case UUID, user ID, storage path, generation attempt ID, manage token, or internal report data.
