# AI Pipeline (v4)

Owner: AI 담당 (양승호). Code: `GoldenLook-Backend/lib/server/ai/`. Source of truth for policy: `docs/FINAL_PRODUCT_PLAN_v4.md` §5–6.

## Flow

`POST /api/cases/[id]/generate` → `imageAdapter.generate(input)` → Gemini image model (`GEMINI_IMAGE_MODEL`, default `gemini-3.1-flash-image`, 1K output) → JPEG, longest side ≤ 1536px → private Storage.

The app-facing adapter contract (`lib/server/ai/types.ts`) is unchanged: structured `photoMode` / appearance / body inputs in, one image out, or a thrown failure that the route maps to `AI_TEMPORARY_ERROR` (503).

## Modes

- `body_visible`: edits the original photo. Output keeps the original aspect ratio. Face, identity, background, pose and lighting are preserved. A known garment **type** reshapes that garment (e.g. padded jacket → short-sleeve T-shirt); a known **color only** recolors it and keeps its shape.
- `face_only`: uses the face photo as identity reference and generates a natural standing full-body image (3:4, 2K) reflecting age, height, gender and body type, keeping the reference facial expression. A missing top/bottom type falls back to plain, neutral, logo-free clothing.

## Input rules

- Only `known` garments are applied. `unknown` is never stated as fact; `none` is applied as absent.
- Korean garment types and palette color IDs are translated to English for the model (color name + hex from `contracts/colors.json`).
- `items` are flyer text only and are not sent to the image model.
- Prompts contain no name, contact, place or other flyer PII. The model is told not to render any text.
- The `AI로 재현한 예상 모습` label is rendered by the app/flyer, not by the model.
- Sunglasses and face masks in the photo are always kept; the model must never invent the facial features they hide (team decision 2026-09-14).
- If a `body_visible` photo shows several people, only the most central, prominent person is edited. The app does not ask who the missing person is, so group photos with the person at the edge can edit the wrong person; guardians are expected to upload a photo of the missing person alone.

## Reliability

- 75s timeout per provider attempt, at most 2 attempts.
- Retried: HTTP 429/5xx, network errors, timeouts, responses without an image.
- Not retried: safety blocks (`IMAGE_SAFETY`, `PROHIBITED_CONTENT`, …), other 4xx, missing API key.
- Logs contain only `kind`, `status`, `attempt`, `model` — never images, prompts or user input.

## Cost

Gemini 3.1 Flash Image (no free tier): `body_visible` uses 1K output, about $0.067 per image and ~10s; `face_only` uses 2K output, about $0.101 per image and ~17s, because the face is small in a full-body frame and 2K keeps it sharper. One successful case uses 1–4 images (first result + up to 3 regenerations); a retried attempt can add one more.

## Evaluation

`npm run ai:eval` in Backend (requires `GEMINI_API_KEY` in `.env.local`). It creates synthetic, fictional source people once, runs 5 `body_visible` + 5 `face_only` cases, and writes an HTML report to `.ai-eval/runs/<time>/` (git-ignored). Real people's photos are never used.

Criteria: face similarity, background preservation, input reflection (color/type), photorealism, no invented details for unknown items, latency.

## Removed from v3

SegFormer, LAB recolor, Modal, and Gemini text parsing are no longer in the required path. They may be reintroduced only as optional AI-internal tools.
