# Architecture Overview

Last Updated: 2026-05-09

This diagram shows the top-level components of the `qvac-workstation`. The two subrepos are independent: `qvac/` is the active monorepo (TypeScript SDK over native C++ inference addons), and `qvac-rnd-fabric-llm-bitnet/` is a research-artifacts repo whose source code lives in an external project. External integrations (model registry, P2P transport via Hyperdrive, ONNX/llama.cpp engines) are shown as separate nodes.

```mermaid
graph TD
    subgraph Workstation [qvac-workstation]
        direction TB

        subgraph QvacRepo [qvac/ — main monorepo]
            direction TB
            CLI[packages/cli<br/>OpenAI-compatible HTTP server]
            SDK[packages/sdk<br/>unified TypeScript SDK]
            RAG[packages/rag]
            REG[packages/registry-server]

            subgraph Inference [Inference addons]
                LLM[llm-llamacpp]
                EMB[embed-llamacpp]
                OCR[ocr-onnx]
                TTS[tts-onnx]
                STT1[transcription-whispercpp]
                STT2[transcription-parakeet]
                TR[translation-nmtcpp]
                DIFF[diffusion-cpp]
                LDET[langdetect-text]
            end

            subgraph DataLoaders [Data loaders]
                DLB[dl-base]
                DLF[dl-filesystem]
                DLH[dl-hyperdrive]
            end

            subgraph CrossCutting [Cross-cutting]
                ERR[error]
                LOG[logging]
                DIAG[diagnostics]
            end
        end

        subgraph ResearchRepo [qvac-rnd-fabric-llm-bitnet/]
            direction TB
            EvalScripts[evaluations/scripts<br/>Python tools]
            Datasets[evaluations/<br/>JSONL datasets]
            Reports[evaluations/reports]
        end
    end

    subgraph External [External engines & infra]
        LLAMA[(llama.cpp / GGML)]
        ONNX[(ONNX Runtime)]
        WHISPER[(whisper.cpp)]
        HYPER[(Hyperdrive P2P)]
        HF[(HuggingFace registry)]
        FABRIC[(qvac-fabric-llm.cpp<br/>external repo)]
    end

    CLI --> SDK
    SDK --> Inference
    SDK --> RAG
    SDK --> DataLoaders
    SDK --> CrossCutting
    SDK --> REG

    LLM --> LLAMA
    EMB --> LLAMA
    OCR --> ONNX
    TTS --> ONNX
    STT1 --> WHISPER
    DLH --> HYPER
    REG --> HF

    EvalScripts --> Datasets
    EvalScripts --> Reports
    EvalScripts -.uses results from.-> FABRIC
```
