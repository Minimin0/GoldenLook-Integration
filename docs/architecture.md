# Architecture

```text
GoldenLook-Frontend
        |
        | HTTPS API
        v
GoldenLook-Backend
        |
        |-- Gemini API: natural language to appearance
        |-- Supabase: PostgreSQL and private storage
        |-- Flyer Renderer
        `-- Modal AI: Python 3.12, SegFormer, LAB deterministic recolor

GoldenLook-Integration
        |
        |-- Shared Contracts
        |-- Architecture Documentation
        |-- E2E
        |-- Verification
        |-- Evaluation
        `-- Production Release Evidence
```

AI code lives in `GoldenLook-Backend/ai/`; no fourth AI repository exists.
