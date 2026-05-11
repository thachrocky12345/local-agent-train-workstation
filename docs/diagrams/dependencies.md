# Package Dependencies

Last Updated: 2026-05-09

This diagram groups the major external dependencies used across `qvac/packages/*` by category, and shows which package category consumes which group. The `qvac-rnd-fabric-llm-bitnet/` repo has no `requirements.txt` at present — its scripts import standard libraries plus `huggingface_hub` ad-hoc. The `/init` skill will refresh this when a real dependency manifest appears or when `package.json` files change.

```mermaid
graph LR
    subgraph QvacPackages [qvac/packages]
        SDK[sdk]
        CLI[cli]
        Inference[infer-* / *-cpp / *-onnx]
        DL[dl-*]
        REG[registry-server]
    end

    subgraph Runtime [Native runtime]
        BARE[bare]
        BAREMAKE[bare-make]
        VCPKG[vcpkg]
        CLANG[clang-22]
    end

    subgraph EnginesNative [Inference engines]
        LLAMA[llama.cpp]
        ONNX[onnxruntime]
        WHISPER[whisper.cpp]
        NMT[nmt.cpp]
        DIFFC[diffusion.cpp]
    end

    subgraph DataInfra [Data / P2P]
        HYPER[hyperdrive]
        FS[node:fs / bare-fs]
    end

    subgraph Validation [Validation & types]
        ZOD[zod]
        TS[typescript]
    end

    subgraph CrossCut [Cross-cutting]
        BRITTLE[brittle]
        STD[standard]
        ESLINT[eslint]
        PRETTIER[prettier]
        BUN[bun]
    end

    SDK --> ZOD
    SDK --> TS
    SDK --> Inference
    SDK --> DL

    Inference --> BARE
    Inference --> BAREMAKE
    Inference --> VCPKG
    Inference --> CLANG
    Inference --> EnginesNative

    DL --> HYPER
    DL --> FS

    CLI --> SDK
    REG --> HYPER

    QvacPackages -.test.-> BRITTLE
    QvacPackages -.lint.-> STD
    SDK -.lint.-> ESLINT
    SDK -.format.-> PRETTIER
    SDK -.build.-> BUN
```
