# Request Flow

Last Updated: 2026-05-09

The diagram traces a typical SDK call (`completion`) from an end-user app through the QVAC SDK, into the appropriate inference package, down to the native addon (a Bare runtime `.bare` prebuild built from the C++ engine, e.g. llama.cpp), and back as a streamed token sequence. The CLI path is identical except a request first hits the OpenAI-compatible HTTP server in `packages/cli`.

```mermaid
sequenceDiagram
    autonumber
    participant App as User app
    participant CLI as packages/cli<br/>(optional)
    participant SDK as packages/sdk
    participant DL as packages/dl-* loader
    participant Infer as packages/llm-llamacpp
    participant Native as Bare addon (.bare prebuild)
    participant Engine as llama.cpp

    App->>SDK: loadModel({ modelSrc, modelType: "llm" })
    SDK->>DL: resolve modelSrc (filesystem | hyperdrive | hf)
    DL-->>SDK: local file path
    SDK->>Infer: bind model
    Infer->>Native: load via Bare bindings
    Native->>Engine: model load
    Engine-->>Native: model handle
    Native-->>Infer: modelId
    Infer-->>SDK: modelId
    SDK-->>App: modelId

    App->>SDK: completion({ modelId, history, stream: true })
    Note over App,SDK: CLI path: App → CLI → SDK<br/>over OpenAI-compatible HTTP
    SDK->>Infer: tokenize + sample
    Infer->>Native: forward()
    Native->>Engine: decode tokens
    loop streaming
        Engine-->>Native: token
        Native-->>Infer: token
        Infer-->>SDK: token
        SDK-->>App: tokenStream chunk
    end

    App->>SDK: unloadModel({ modelId })
    SDK->>Infer: free
    Infer->>Native: dispose
    Native->>Engine: release
```
