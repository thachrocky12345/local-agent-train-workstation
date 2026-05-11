# Deployment

Last Updated: 2026-05-09

No `docker-compose.yml`, `Dockerfile`, or `k8s/` is present at the workstation root. QVAC's distribution model is **native prebuilds**, not containers: each native addon under `qvac/packages/*-cpp` and `*-onnx` produces `.bare` prebuilds (via `bare-make install`) that are bundled and shipped through GitHub Packages (dev) or npm (release). The research repo distributes binaries via GitHub Releases of the external `qvac-fabric-llm.cpp` repo.

The diagram below sketches the *publication* topology. Update this file if/when containerization is added.

```mermaid
graph LR
    subgraph Dev [Development]
        DEV[Local dev<br/>bare-make build & install]
        CI[GitHub Actions<br/>.github/workflows/*]
    end

    subgraph DistChannels [Distribution channels]
        GHPKG[GitHub Packages<br/>dev builds from main]
        NPM[npm<br/>@qvac/* releases]
        GHREL[GitHub Releases<br/>qvac-fabric-llm.cpp binaries]
    end

    subgraph Consumers [Consumers]
        APP[End-user apps<br/>Node / Bare / Expo]
        CLI[QVAC CLI<br/>OpenAI-compatible HTTP]
        EDGE[Mobile / edge devices<br/>Android / iOS / desktop]
    end

    DEV --> CI
    CI -- "branch: main" --> GHPKG
    CI -- "branch: release-*" --> NPM
    CI -- "BitNet binaries" --> GHREL

    GHPKG --> APP
    NPM --> APP
    NPM --> CLI
    GHREL --> EDGE
```

## Notes

- Multi-platform prebuild workflows (`prebuilds-*.yml`) handle native bindings per OS / arch.
- Path-scoped CI: only affected packages build/publish on a given commit.
- Expensive integration tests are gated behind a `verify` PR label.
