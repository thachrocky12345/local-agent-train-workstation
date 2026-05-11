# Data Flow

Last Updated: 2026-05-09

This flowchart shows how data enters QVAC, gets validated and processed, and is returned to the caller. Inputs come from three surfaces: direct SDK calls, CLI invocation, and the OpenAI-compatible HTTP server (also in `packages/cli`). Validation is performed primarily by Zod schemas co-located with the code paths. Model artifacts are fetched by `dl-*` loaders (filesystem cache or P2P via Hyperdrive). Inference happens in native addons, and results stream back as token chunks or buffered artifacts.

```mermaid
flowchart TD
    subgraph Inputs
        A1[SDK call<br/>App → @qvac/sdk]
        A2[CLI command]
        A3[HTTP request<br/>OpenAI-compatible server]
    end

    A1 --> V[Validate args<br/>Zod schemas]
    A2 --> V
    A3 --> V

    V -->|invalid| ERR[Error path<br/>see error-flow.md]
    V -->|valid| RES[Resolve model source]

    RES --> DLF{Source?}
    DLF -->|filesystem| LOC[dl-filesystem]
    DLF -->|hyperdrive| P2P[dl-hyperdrive]
    DLF -->|huggingface| HF[Fetch via HF_TOKEN]

    LOC --> CACHE[(Local model cache)]
    P2P --> CACHE
    HF --> CACHE

    CACHE --> LOAD[Load into native addon<br/>llm-llamacpp / ocr-onnx / ...]
    LOAD --> RUN[Run inference]

    RUN --> OUT{Output mode?}
    OUT -->|stream| STREAM[Token / chunk stream]
    OUT -->|buffered| BUF[Result object]

    STREAM --> CLIENT[Return to caller]
    BUF --> CLIENT
```
