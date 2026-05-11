# Error Flow

Last Updated: 2026-05-09

The flow shows how errors propagate from their origin (native addon, validation layer, network) up through the QVAC error wrappers (`packages/error` / `QvacErrorBase`) and out to the caller. Per the conventions in `qvac/CLAUDE.md`, all errors must use structured error classes and preserve the original `cause`. Logging is centralized in `packages/logging`.

```mermaid
flowchart TD
    subgraph Sources
        S1[Native addon failure<br/>e.g. CUDA OOM, bad GGUF]
        S2[Validation error<br/>Zod schema reject]
        S3[Network / loader error<br/>dl-* loaders]
        S4[Model registry error]
    end

    S1 --> WRAP
    S2 --> WRAP
    S3 --> WRAP
    S4 --> WRAP

    WRAP[Wrap in QvacErrorBase subclass<br/>preserve cause chain]

    WRAP --> LOG[Log via packages/logging<br/>level=error, structured fields]

    LOG --> SURF{Caller surface}

    SURF -->|SDK promise| REJ[Reject promise<br/>typed error class]
    SURF -->|stream| EVT[Emit 'error' event<br/>on tokenStream]
    SURF -->|CLI| EXIT[Print to stderr<br/>non-zero exit code]
    SURF -->|HTTP server| RESP[OpenAI-compatible<br/>error JSON + status code]

    REJ --> APP[Application code<br/>try/catch or .catch]
    EVT --> APP
    EXIT --> SHELL[Shell / CI]
    RESP --> CLIENT[HTTP client]
```

## Notes

- Strict rule from `qvac/CLAUDE.md`: never swallow errors, always preserve `cause`.
- Test failures from `brittle` integration tests must never be skipped or weakened — fix the code or the test.
- Native-addon failures sometimes manifest as process crashes when not properly bridged; check that prebuilds match the host triplet.
