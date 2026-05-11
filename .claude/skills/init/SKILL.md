# Skill: init

**Trigger:** `/init`

This skill governs every `/init` invocation in the qvac-workstation. Follow it completely and in order — never skip steps even if nothing appears changed.

## Workspace Awareness

This workstation is multi-repo. Two independent git repositories live side by side:

- `qvac/` — main monorepo (JS/TS/C++ via Bare runtime + bun + bare-make + vcpkg). **Has its own `qvac/CLAUDE.md` with stricter rules — never override it.**
- `qvac-rnd-fabric-llm-bitnet/` — research artifacts (docs + JSONL datasets + standalone Python eval scripts). No build system at the repo level.

When scanning, walk both subrepos and treat them as independent units.

**Default exclusions:** `.git`, `node_modules`, `__pycache__`, `venv`, `.venv`, `*.pyc`, `build`, `dist`, `prebuilds`, `.bare`, `.next`, `.turbo`, `coverage`, `.cache`.

## Execution Steps (run in this exact order)

### 1. Scan project structure
- Walk both subrepos.
- Detect packages: `qvac/packages/*/package.json`, `qvac/packages/*/bare.json`, root `package.json` files.
- Detect Python: `qvac-rnd-fabric-llm-bitnet/evaluations/scripts/*.py` and any `requirements.txt`/`pyproject.toml`.
- Detect native build: `CMakeLists.txt`, `vcpkg.json`, `linux-clang.cmake`, `prebuilds/`.
- Detect infra: `Dockerfile`, `docker-compose.yml`, `k8s/`, `.github/workflows/`.

### 2. Update `CLAUDE.md` (workstation root)
Refresh ONLY these sections; preserve everything else verbatim:
- `## Tech Stack`
- `## Project Structure`
- `## Key Modules`
- `## Known Dependencies` (set `Last synced:` to today's date)

### 3. Update `docs/architecture.md`
- Refresh `Last Updated:` line.
- Refresh `## System Layers` and `## Key Modules`.
- Append newly detected dependencies; do not delete prose.

### 4. Process `docs/decisions/.pending_adr_review` (if it exists)
- For each new major framework, database driver, auth library, or infra file detected → CREATE a new ADR using `docs/decisions/_template.md`. Number sequentially: `0001-*.md`, `0002-*.md`, ...
- For each removed library → mark its existing ADR `Status: Deprecated` with reason and date.
- For each replaced library → mark prior ADR `Status: Superseded by ADR-NNNN`.
- SKIP minor version bumps and dev/test-only deps: `pytest`, `black`, `ruff`, `mypy`, `eslint`, `prettier`, `jest`, `vitest`, `mocha`, `brittle`, `standard`, `@types/*`.

### 5. Update `docs/decisions/index.md`
Reflect every ADR change (additions, status changes).

### 6. Delete `docs/decisions/.pending_adr_review`
After processing, remove it.

### 7. Update Known Dependencies baseline in `CLAUDE.md`
Match the new snapshot.

### 8. Generate or update all diagrams in `docs/diagrams/`
Follow `.claude/skills/diagrams/SKILL.md`.

### 9. Generate or update all flows in `docs/flows/`
Follow `.claude/skills/diagrams/SKILL.md`.

### 10. Update `docs/diagrams/index.md` and `docs/flows/index.md`
Set the `Last Updated` column for every regenerated file to today.

### 11. Output final summary
Print exactly:

```
✅ Init sync complete — updated: [files], created ADRs: [list], diagrams updated: [list], skipped: [reasons]
```

## Adaptation rules for this workstation

- The spec template is Python-oriented; in this workstation also detect TypeScript ORMs (Prisma, TypeORM, Drizzle, Mongoose), Zod schema groups, and Bare-runtime native addons.
- Treat `qvac/packages/*/` and `qvac-rnd-fabric-llm-bitnet/evaluations/` as the equivalent of `src/`.
- Never run package-manager install/build/test commands during `/init`. This skill is read-only with respect to source code.
- Do not modify `qvac/CLAUDE.md` — defer to it.

## Important rules
1. NEVER skip a step.
2. ALWAYS regenerate diagrams.
3. PRESERVE non-managed sections of `CLAUDE.md`.
4. USE Mermaid syntax inside markdown fences for every diagram.
5. ADD `Last Updated:` timestamps.
