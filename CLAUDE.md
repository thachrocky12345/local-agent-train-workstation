# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 🔁 Init Behavior (ALWAYS FOLLOW)

Whenever `/init` is run:

1. Read `.claude/skills/init/SKILL.md` and follow it completely.
2. Read `.claude/skills/diagrams/SKILL.md` and follow it completely.
3. Update `CLAUDE.md` — refresh `Project Structure`, `Tech Stack`, `Key Modules`, `Known Dependencies`.
4. Update `docs/architecture.md` — `Last Updated` timestamp, new layers, new dependencies.
5. Check and process `docs/decisions/.pending_adr_review` (create / deprecate / supersede ADRs as the diff demands; skip dev-only and minor-version-bump deps).
6. Update `docs/decisions/index.md`.
7. Generate or update ALL diagrams in `docs/diagrams/`.
8. Generate or update ALL flows in `docs/flows/`.
9. Update `docs/diagrams/index.md` and `docs/flows/index.md`.
10. Confirm with: `✅ Init sync complete — updated: [files], diagrams: [list], flows: [list]`

DO NOT skip any step even if nothing seems changed. Always regenerate diagrams.

## Known Dependencies

<!-- Claude auto-updates this section on every /init — do not edit manually -->

Last synced: 2026-05-09

There is no `requirements.txt`, `pyproject.toml`, or root `package.json` at the workstation level. Dependencies are tracked per subrepo:

- **`qvac/`** — every `qvac/packages/*/package.json` is snapshotted by the post-init hook into `docs/decisions/.last_deps_snapshot`. Major framework / inference / data-loader / native-runtime additions trigger ADRs.
- **`qvac-rnd-fabric-llm-bitnet/`** — Python eval scripts use ad-hoc imports (no requirements file present). If a `requirements.txt` or `pyproject.toml` is added, the hook will pick it up automatically.

Run `make init` then `/init` to refresh this section.

## Project Overview

`qvac-workstation` is a multi-repo workspace for QVAC-related work. It hosts the main **QVAC monorepo** (a cross-platform, local-first, P2P AI ecosystem with a TypeScript SDK over native C++ inference addons) alongside a **BitNet research-artifacts repo** (datasets, evaluation scripts, and reports for LoRA fine-tuning of BitNet b1.58 models on edge GPUs). The two subrepos are fully independent at the build and tooling layer.

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Workstation tooling | Bash hooks, Make, Mermaid diagrams |
| qvac/ SDK | TypeScript, bun, Zod, ESLint, Prettier |
| qvac/ runtimes | Node.js, Bare runtime, Expo |
| qvac/ native addons | C++, CMake, vcpkg, clang-22, bare-make, GoogleTest, clang-tidy |
| qvac/ JS lint | standard (standardjs) |
| qvac/ integration test | brittle |
| Research repo | Python 3 (standalone scripts), JSONL datasets |
| External engines used | llama.cpp / GGML, ONNX Runtime, whisper.cpp, Parakeet, NMT.cpp |

## Project Structure

```
qvac-workstation/
├── CLAUDE.md                       # This file (workstation-level guidance)
├── Makefile                        # `make init` runs the post-init hook
├── .claude/
│   ├── settings.json               # Hooks + skills wiring
│   ├── hooks/
│   │   └── post_init.sh            # Snapshot deps, regenerate structure tree
│   └── skills/
│       ├── init/SKILL.md           # /init orchestration
│       ├── diagrams/SKILL.md       # All diagram + flow generation rules
│       ├── code-review/            # (placeholder)
│       └── refactor/               # (placeholder)
├── docs/
│   ├── architecture.md             # System-level architecture overview
│   ├── structure.md                # [generated] file-tree snapshot
│   ├── decisions/                  # ADRs + index + template
│   │   ├── _template.md
│   │   ├── index.md
│   │   ├── .last_deps_snapshot     # [generated] dependency baseline
│   │   └── .pending_adr_review     # [generated when deps drift]
│   ├── diagrams/                   # Mermaid diagrams + index
│   ├── flows/                      # Mermaid sequence/flow diagrams + index
│   └── runbooks/                   # Operational runbooks (empty)
├── tools/
│   ├── scripts/                    # Workstation-level helper scripts
│   └── prompts/                    # Reusable prompt templates
├── qvac/                           # Main QVAC monorepo (own CLAUDE.md)
└── qvac-rnd-fabric-llm-bitnet/     # Research artifacts (docs + datasets)
```

## Key Modules

These are the main units of code/work. Per-subrepo detail lives in each subrepo.

| Module | Subrepo | Purpose |
|--------|---------|---------|
| `packages/sdk` | qvac | Type-safe unified SDK (main entry point) |
| `packages/cli` | qvac | CLI + OpenAI-compatible HTTP server |
| `packages/llm-llamacpp` | qvac | LLM inference (llama.cpp) |
| `packages/embed-llamacpp` | qvac | Embeddings (llama.cpp) |
| `packages/ocr-onnx` | qvac | OCR (ONNX Runtime). Hosts canonical agent config (`.agent/`). |
| `packages/tts-onnx` | qvac | Text-to-speech (ONNX Runtime) |
| `packages/transcription-whispercpp`, `transcription-parakeet` | qvac | Speech-to-text |
| `packages/translation-nmtcpp` | qvac | Translation |
| `packages/diffusion-cpp` | qvac | Image generation |
| `packages/rag` | qvac | Retrieval-augmented generation |
| `packages/dl-base`, `dl-filesystem`, `dl-hyperdrive` | qvac | Model data loaders (local + P2P via Hyperdrive) |
| `packages/registry-server` | qvac | Distributed model registry |
| `packages/error`, `logging`, `diagnostics` | qvac | Cross-cutting concerns |
| `evaluations/scripts/` | research | Standalone Python eval tools |
| `evaluations/biomedqa_data/`, `email_style_transfer/` | research | JSONL datasets |
| `evaluations/reports/` | research | Markdown reports + JSON results |

## Conventions

- **Diagrams**: Mermaid inside markdown fences, with a plain-English explanation above each diagram and a `Last Updated` timestamp at file top.
- **ADRs**: numbered sequentially (`docs/decisions/NNNN-title.md`), use `_template.md`, status one of Proposed / Accepted / Deprecated / Superseded. Index updated automatically on `/init`.
- **Workstation hooks**: bash, POSIX-friendly, idempotent; never run `npm`/`bun`/`bare-make`/`pip` from the hook.
- **Code conventions** for the `qvac/` subrepo (TypeScript rules, commit prefixes, PR title format, C++ rules, **strict bash command rules**, never-skip-tests rule) are defined in `qvac/CLAUDE.md` — defer to it. Do not duplicate or override those rules here.
- **Code conventions** for the research repo: standalone Python scripts; no enforced formatter, type checker, or test framework at repo level.

---

## Workstation Layout

This directory is a multi-repo workstation, not a single project. It contains two independent git repositories with different purposes, build systems, and conventions:

```
qvac-workstation/
├── qvac/                          # Main QVAC monorepo (active development)
└── qvac-rnd-fabric-llm-bitnet/    # Research artifacts repo (docs/datasets only)
```

When working on a task, first determine which subrepo it concerns and operate inside that subrepo. The two repos are unrelated at the build/dependency level — never assume tooling from one applies to the other. There are no workstation-level build, test, or lint commands (only the doc-sync `make init`).

## qvac/ — Main Monorepo

**This subrepo has its own `CLAUDE.md` at `qvac/CLAUDE.md`. Read it before doing any work in `qvac/`.** It is the authoritative source for build/test/lint commands, bash command rules, commit conventions, agent setup, and code conventions. Do not duplicate that content here.

Key facts to know up front:
- Cross-platform local-first/P2P AI monorepo (Node.js, Bare runtime, Expo).
- Packages live in `qvac/packages/` (~30 packages).
- Two distinct build toolchains coexist:
  - Native C++ addons → `bare-make` + vcpkg + clang-22.
  - SDK (`packages/qvac-sdk`) → `bun`.
- Agent config in `qvac/.claude/` and `qvac/.cursor/` is **generated** by the `/setup` skill from the canonical source at `qvac/packages/ocr-onnx/.agent/`. Edit the canonical source, not the generated copies.
- Strict bash command rules apply inside `qvac/` (no heredocs, no `$()` command substitution, no `&&`/`||`/`;` chaining, no pipes/redirects). Violating them blocks the automated pipeline. See `qvac/CLAUDE.md` for the full list.
- NEVER delete, disable, skip, or weaken existing tests — fix the code or the test, or stop and report.

## qvac-rnd-fabric-llm-bitnet/ — Research Repo

A documentation/artifacts repository for BitNet b1.58 LoRA fine-tuning research. **No application source code lives here** — the actual implementation is in the external `qvac-fabric-llm.cpp` repo (https://github.com/tetherto/qvac-fabric-llm.cpp), which builds on llama.cpp/GGML.

Contents:
- `docs/BENCHMARKS.md` — performance metrics across platforms (Vulkan/Metal, mobile/desktop GPUs).
- `evaluations/biomedqa_data/`, `evaluations/email_style_transfer/` — JSONL training/validation/test datasets.
- `evaluations/scripts/` — standalone Python evaluation tools (`build_biomed_dataset.py`, `compare_base_vs_adapters.py`, `monitor_training.py`, `quick_compare.py`, `test_biomed_prompts.py`). Run individually with `python <script>.py`. There is no shared package layout, no test suite, and no lint config in this repo.
- `evaluations/reports/` — markdown experimental reports and JSON results.
- `releases/` — links to GitHub Releases of the companion source repo.

The biomedical artifacts are research-only and explicitly **not** for clinical use (per the repo's README disclaimer).

## Working Across Repos

- Never run a command from the workstation root expecting it to act on both repos. Each has its own `.git`, dependencies, and tooling.
- The strict bash rules in `qvac/CLAUDE.md` apply to work inside `qvac/`. They are not formally enforced in the research repo, but following them is a safe default.
- The research repo's results were produced using the external `qvac-fabric-llm.cpp` codebase, which is conceptually related to (but separate from) `qvac/packages/llm-llamacpp`. Don't conflate them.
