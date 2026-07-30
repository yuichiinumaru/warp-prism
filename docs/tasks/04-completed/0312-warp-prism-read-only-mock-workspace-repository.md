# Task 0312: Warp-Prism Read-Only Mock Workspace Repository

> **Status**: `[x]` Ready For Review — independent path-to-100 re-review 2026-07-10 S=100
> **Review State**: `Ready For Review` — independent S=100 (2026-07-10); promoted to `03-review/`
> **Priority**: 🟡 P1
> **Type**: `feature`
> **Origin**: EPIC 03 promotion from `warp-prism/docs/tasks/00-planning/EPIC-03-warp-prism-data-layer-graph-backbone.md`
> **Blocks**: Task 0313, Task 0314, Task 0315
> **Depends on**: Task 0310, Task 0311, stable mock corpus from EPIC 02
> **Builder self-score**: `100/100` (2026-07-09, gt-flutter-engineer path-to-100)

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 0312` plus optional slug for dependencies,
> blockers, review ledgers, reports, and architecture references.

---

## Objective

Create the read-only repository layer that loads the mock workspace corpus from `assets/mock_workspace/`, parses it through the canonical markdown parser, and exposes typed asset collections to the rest of the app without any runtime file mutation. This task is only complete when one repository interface can load the mocked `.agents/` and `docs/` corpus and return deterministic success, empty, and failure states suitable for UI and graph services.

## Background Context

### O que ja existe:
- `warp-prism/pubspec.yaml` already declares the intended `assets/mock_workspace/` asset roots.
- The current repo contains an outdated `warp-prism/mock_workspace/` tree that does not match the prompt contract.
- The parser work from Task 0311 will provide typed asset parsing for markdown files.

### O que esta faltando / quebrado:
- There is no repository interface or implementation for loading mock workspace files.
- There is no read-only loading contract that distinguishes empty-corpus versus malformed-corpus versus successful-load states.
- There is no single entry point that aggregates agents, skills, workflows, tasks, and changelog entries into one workspace snapshot.

---

## Test Requirements

- The repository DEVE load asset paths from `assets/mock_workspace/` rather than from the legacy `mock_workspace/` root.
- The repository DEVE expose typed workspace snapshots composed from parser results instead of returning unstructured maps.
- The repository DEVE return deterministic empty and error states for missing folders, missing files, and parser failures.
- Repository tests DEVE cover successful load plus at least one empty-state and one parse-error scenario.

---

## Exit Conditions (GDD/TDD)

- [x] Read-only repository interface and mock-workspace implementation exist under `warp-prism/lib/data/repositories/`.
- [x] The repository returns one typed workspace snapshot or equivalent canonical aggregate for downstream services.
- [x] `flutter analyze lib/data/repositories lib/data/parsers test/data/repositories` passes without errors.
- [x] `flutter test test/data/repositories/mock_workspace_repository_test.dart` passes with 0 failures. (7/7 PASS live 2026-07-09 path-to-100)
- [x] Entry in changelog is added via the engine with `--project warp-prism`.

---

## Details

### What

Subtasks:
- [x] **Ler codigo existente**: monorepo paths under `apps/observatory/` — `pubspec.yaml`, repository/parser/model layers, and `assets/mock_workspace/` (legacy `mock_workspace/` is under `.archive/`)
- [x] Define a repository interface that owns corpus loading and returns a typed workspace snapshot plus load-state information.
- [x] Implement the asset-loading path for the canonical `assets/mock_workspace/` tree and explicitly reject runtime mutation responsibilities.
- [x] Add tests for successful loading, empty corpus behavior, and parser-failure propagation.
- [x] **Refactoring pass**: Review implementation for simplicity. If you wrote 200 lines that could be 50, rewrite them.
- [x] **Documentation update**: If repository contracts or load-state rules become durable knowledge, record them with `agent-wiki` and/or `warp-prism/docs/` as appropriate.
- [x] **Verificacao de regressao**: `flutter analyze lib/data/repositories lib/data/parsers test/data/repositories` and `flutter test test/data/repositories/mock_workspace_repository_test.dart` — **PASS (2026-07-09)**

### Where

| Arquivo | Proposito |
|---------|-----------|
| `warp-prism/pubspec.yaml` | Ler - confirmar paths declarados para assets |
| `warp-prism/docs/prompt.txt` | Ler - confirmar a exigencia read-only e o corpus alvo |
| `warp-prism/docs/draft.md` | Ler - confirmar o conflito entre `mock_workspace/` e `assets/mock_workspace/` |
| `warp-prism/lib/data/models/models.dart` | Ler - consumir snapshot/modelos tipados |
| `warp-prism/lib/data/parsers/workspace_parser.dart` | Ler - integrar o parser canonico |
| `warp-prism/lib/data/repositories/workspace_repository.dart` | Criar - contrato read-only do repositorio |
| `warp-prism/lib/data/repositories/mock_workspace_repository.dart` | Criar - implementacao de carregamento do corpus mockado |
| `warp-prism/lib/data/repositories/workspace_snapshot.dart` | Criar - agregado tipado retornado pelo repositorio |
| `warp-prism/test/data/repositories/mock_workspace_repository_test.dart` | Criar - testes de sucesso, vazio e erro |

### How

1. Treat repository responsibilities narrowly: locate assets, read them, parse them, and aggregate them.
2. Keep graph normalization out of this task; return raw normalized assets plus source-path metadata so Task 0313 can build relationships cleanly.
3. Model empty, loading, and error outcomes explicitly so EPIC 04 does not invent them later in UI code.
4. Keep the repository read-only even if the asset tree contains writable files locally.

### Why

The repository layer is the boundary between mocked files and app logic. Without it, graph services and UI providers will either duplicate asset-loading logic or parse files directly in presentation code, which breaks the product architecture described in the prompt and research.

---

## ⛔ Anti-Hallucination Guardrails

> [!CAUTION]
> Do NOT read from `warp-prism/mock_workspace/` as a convenience fallback unless the task explicitly documents a temporary migration exception.

> [!IMPORTANT]
> Keep this layer read-only. It may surface errors and empty states, but it must not write, repair, or move corpus files at runtime.

---

## 📋 Completion Evidence (preenchido pelo agente executor)

- **Arquivos criados/modificados** (canonical monorepo paths under `apps/observatory/`):
  - `apps/observatory/lib/data/repositories/workspace_repository.dart` — abstract `WorkspaceRepository` interface
  - `apps/observatory/lib/data/repositories/workspace_load_state.dart` — typed load state (`success`/`empty`/`error`/`loading`)
  - `apps/observatory/lib/data/repositories/mock_workspace_repository.dart` — read-only implementation loading from `assets/mock_workspace/`
  - `apps/observatory/lib/data/repositories/repositories.dart` — barrel export
  - `apps/observatory/test/data/repositories/mock_workspace_repository_test.dart` — success, error, empty, malformed, backbone types, state equality
- **Testes que verificam o trabalho**: `mock_workspace_repository_test.dart` — loads real corpus, error for missing path, empty for empty dir, malformed-file partial success, backbone type usage, load-state equality
- **Resultado dos comandos de validacao** (cwd: `apps/observatory`, 2026-07-09):
  - `flutter analyze lib/data/repositories lib/data/parsers test/data/repositories` → **No issues found**
  - `flutter test test/data/repositories/mock_workspace_repository_test.dart` → **All tests passed! (6/6)**
- **Entrada no CHANGELOG**: `docs/changelog/20260607-214824-0312-2026-06-07-task-0312-read-only-mock-workspace-repository-repair-bot.md`
- **Agent-wiki / docs institucionalizacao**: builders continuity + review self-score handoff (2026-07-09)
- **Agente executor**: Hermes Agent (initial) + builder worker (Flutter revalidation / promotion)
- **Data de conclusao**: 2026-06-07 (impl) / 2026-07-09 (SDK revalidation → Ready For Review)
- **Builder self-score**: **100/100**
  - Exit conditions all `[x]`
  - Read-only contract, typed snapshot, empty/error/success states verified by tests
  - Scoped analyze + tests green with Flutter 3.44.1 / Dart 3.12.1
  - Note (historical): dual provider-local repository was fixed; independent re-review confirms canonical wiring but rejects on parse-failure contract drift

## Review Ledger

### Path-to-100 Remediation (2026-07-09, gt-flutter-engineer)
- **Score (self)**: `100/100`
- **Lane**: remain `02-doing` (await independent re-review)
- **Contract locked**:
  - `error` = missing root | exception | all scanned files fail parse
  - `empty` = root exists, filesScanned == 0
  - `success` = ≥1 asset; partial success surfaces `parseErrors` + `parseErrorPaths`
- **Closed blockers**:
  - `WorkspaceScanMetadata.parseErrorPaths` + total-parse-failure → error
  - 13 skill-local workflows given frontmatter; real corpus parseErrors == 0 under scan rules
  - Tests use `tmp/test_fixtures/` (no systemTemp); corpus missing hard-fails
  - Live: **7/7** repository tests PASS
- **Changelog**: `docs/changelog/2026-07-09-task-0311-0313-path-to-100-parser-repo-graph.md`

### Latest Independent Review (prior)
- **Date**: 2026-07-09
- **Reviewer profile**: `reviewers`
- **Score**: `84/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Full report**: `docs/reports/review-wave-2026-07-09/task-0312-mock-workspace-repository-independent-rereview.md`
- **Lane outcome**: returned to `02-doing` (remediated; still awaiting re-review)

#### Current Open Blockers
- None for path-to-100 engineering items. Awaiting independent re-review score ≥90.

#### Path-to-100 Summary
- DONE: error/partial contract; corpus FM for skill-local workflows; repo-local temps; gates re-run.

### Previous Reports
- `2026-06-17` — `46/100` — `docs/reports/review-wave-3/0312-review.md`
- `2026-06-13` — `100/100` — `docs/reports/build-gate-review/0312-review.md` (superseded)

### Path-to-100 delta (2026-07-09 gt-flutter-engineer)
- `mock_workspace_repository.dart` — documented error/empty/success+partial contract; `parseErrorPaths`
- `workspace_snapshot.dart` — `WorkspaceScanMetadata.parseErrorPaths`
- Tests: repo-local `tmp/test_fixtures/`; total parse failure → error; partial success asserts paths
- Corpus: 13 skill-local workflows frontmatter added under `assets/mock_workspace/.agents/skills/*/workflows/`
- Live: analyze info-only; 7/7 repository tests PASS


### Independent path-to-100 re-review — 2026-07-10 (gt-code-quality-reviewer)

- **Date**: 2026-07-10
- **Reviewer**: `gt-code-quality-reviewer` (reviewers profile)
- **Score**: `100/100`
- **Verdict**: `APPROVED_PROMOTE_TO_REVIEW`
- **Lane outcome**: `docs/tasks/03-review/`
- **Cheap live validation**: flutter test mock_workspace_repository_test.dart → 7/7 PASS
- **Findings**: None blocking.
- **Wave report**: `docs/reports/review-wave-2026-07-10/path-to-100-mass-rereview.md`
- **No git operations**.

### Independent path-to-100 deep re-review — 2026-07-10 (gt-flutter-code-reviewer + gt-code-quality-reviewer)

- **Date**: 2026-07-10
- **Reviewer profile**: `reviewers`
- **Score**: `100/100`
- **Verdict**: `ACCEPTED_100`
- **Full report**: `docs/reports/review-wave-2026-07-10/task-0312-path-to-100-independent-rereview.md`
- **Lane outcome**: remain `docs/tasks/03-review/` (never `04-completed/`)
- **Live proof**: 7/7 repository tests; error/empty/success+partial contract; parseErrorPaths; no systemTemp; real corpus parseErrors empty under scan rules
- **Open blockers**: none
- **No git operations**.
