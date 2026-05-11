# Architecture

Last Updated: 2026-05-09

## Overview

`qvac-workstation` is a multi-repo workspace containing two independent projects:

1. **`qvac/`** — the QVAC monorepo: an open-source, cross-platform ecosystem for building local-first, peer-to-peer AI applications. Cross-runtime support for Node.js, Bare runtime, and Expo. Native C++ inference addons (llama.cpp, ONNX Runtime, whisper.cpp, etc.) plus a unified TypeScript SDK.
2. **`qvac-rnd-fabric-llm-bitnet/`** — a research-artifacts repository for BitNet b1.58 LoRA fine-tuning on heterogeneous edge GPUs. Documentation, datasets, evaluation scripts, and reports only — the actual source code lives in the external `qvac-fabric-llm.cpp` repo.

The two subrepos are independent at the build, dependency, and tooling level. There are no workstation-level build/test/lint commands.

## Tech Stack

**Workstation root**
- Bash hook (`.claude/hooks/post_init.sh`) for dependency snapshotting and structure regeneration.
- Make for one-shot orchestration (`make init`).

**`qvac/` subrepo**
- TypeScript / JavaScript (SDK and most packages)
- C++ (native addons via Bare runtime + bare-make + vcpkg + clang-22)
- Build: `bare-make` for native, `bun` for the SDK
- Test: `brittle` (integration), GoogleTest (C++), bun test
- Lint: `standard` (JS), `clang-tidy` (C++), `eslint` + `prettier` (SDK)

**`qvac-rnd-fabric-llm-bitnet/` subrepo**
- Python 3 (standalone evaluation scripts; no shared package layout)
- JSONL datasets, Markdown reports
- No build, test, or lint configuration at repo level

## System Layers

```
┌──────────────────────────────────────────────────────────────────┐
│ Application layer                                                │
│   • End-user apps consuming @qvac/sdk                            │
│   • CLI (packages/cli) exposing OpenAI-compatible HTTP server    │
└──────────────────────────────────────────────────────────────────┘
┌──────────────────────────────────────────────────────────────────┐
│ SDK layer (packages/sdk)                                         │
│   • Type-safe unified entry point                                │
│   • Composition over classes; Zod schemas co-located             │
└──────────────────────────────────────────────────────────────────┘
┌──────────────────────────────────────────────────────────────────┐
│ Inference layer (packages/infer-base + packages/*-cpp / *-onnx)  │
│   • llm-llamacpp, embed-llamacpp, ocr-onnx, tts-onnx,            │
│   • transcription-whispercpp, transcription-parakeet,            │
│   • translation-nmtcpp, langdetect-text, diffusion-cpp           │
└──────────────────────────────────────────────────────────────────┘
┌──────────────────────────────────────────────────────────────────┐
│ Data loading layer (packages/dl-*)                               │
│   • dl-base, dl-filesystem, dl-hyperdrive (P2P model fetching)   │
└──────────────────────────────────────────────────────────────────┘
┌──────────────────────────────────────────────────────────────────┐
│ Cross-cutting (packages/error, packages/logging,                 │
│ packages/diagnostics)                                            │
└──────────────────────────────────────────────────────────────────┘
┌──────────────────────────────────────────────────────────────────┐
│ Registry (packages/registry-server)                              │
│   • Distributed model registry; vcpkg ports for model assets     │
└──────────────────────────────────────────────────────────────────┘
```

## Key Modules

| Module | Subrepo | Role |
|--------|---------|------|
| `packages/sdk` | qvac | Unified TypeScript SDK; main entry point |
| `packages/cli` | qvac | CLI + OpenAI-compatible HTTP server |
| `packages/llm-llamacpp` | qvac | LLM inference via llama.cpp |
| `packages/embed-llamacpp` | qvac | Embeddings via llama.cpp |
| `packages/ocr-onnx` | qvac | OCR via ONNX Runtime; canonical agent config source (`.agent/`) |
| `packages/tts-onnx` | qvac | Text-to-speech via ONNX Runtime |
| `packages/transcription-whispercpp` | qvac | Speech-to-text via whisper.cpp |
| `packages/transcription-parakeet` | qvac | Speech-to-text via Parakeet |
| `packages/translation-nmtcpp` | qvac | Translation via NMT.cpp |
| `packages/diffusion-cpp` | qvac | Image generation |
| `packages/rag` | qvac | Retrieval-augmented generation |
| `packages/dl-filesystem`, `dl-hyperdrive`, `dl-base` | qvac | Model data loaders (local + P2P) |
| `packages/registry-server` | qvac | Distributed model registry |
| `packages/error`, `packages/logging`, `packages/diagnostics` | qvac | Cross-cutting concerns |
| `evaluations/scripts/` | research | Standalone Python tools for biomed and email-style eval |
| `evaluations/biomedqa_data/`, `email_style_transfer/` | research | JSONL datasets |
| `evaluations/reports/` | research | Markdown experimental reports |

## Recent Decisions

ADRs are tracked in [`docs/decisions/`](decisions/index.md). None recorded yet — see [`docs/decisions/index.md`](decisions/index.md).

## Diagrams

See [`docs/diagrams/`](diagrams/index.md):
- [architecture.md](diagrams/architecture.md) — system component overview
- [dependencies.md](diagrams/dependencies.md) — package dependency graph
- [data-model.md](diagrams/data-model.md) — entity relationships (placeholder where N/A)
- [deployment.md](diagrams/deployment.md) — deployment & infrastructure

## Flows

See [`docs/flows/`](flows/index.md):
- [request-flow.md](flows/request-flow.md) — SDK call lifecycle
- [auth-flow.md](flows/auth-flow.md) — token / auth (placeholder; QVAC is local-first)
- [data-flow.md](flows/data-flow.md) — data processing pipeline
- [error-flow.md](flows/error-flow.md) — error propagation

## Open Questions

- Should the workstation root track ADRs that span both subrepos, or only ones affecting workstation tooling? (Currently: workstation tooling only; subrepo decisions belong in their own histories.)
- Is the Python eval-script set in the research repo stable enough to ADR, or treat as ad-hoc tooling?
- Should `dl-hyperdrive` (P2P) be diagrammed as an external dependency on Hypercore/Holepunch infrastructure?
