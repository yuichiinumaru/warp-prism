# Task 0313: Warp-Prism Graph Normalization And Edge Inference

> **Status**: `[x]` Ready For Review — independent path-to-100 re-review 2026-07-10 S=100
> **Review State**: `Ready For Review` — independent S=100 (2026-07-10); promoted to `03-review/`
> **Priority**: 🟡 P1
> **Type**: `feature`
> **Origin**: EPIC 03 promotion from `warp-prism/docs/tasks/00-planning/EPIC-03-warp-prism-data-layer-graph-backbone.md`
> **Blocks**: Task 0314, Task 0315, future EPIC 05/06/07/08 implementation waves
> **Depends on**: Task 0310, Task 0311, Task 0312

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 0313` plus optional slug for dependencies,
> blockers, review ledgers, reports, and architecture references.

---

## Objective

Build the graph normalization layer that turns the repository snapshot into one navigable workspace graph with typed nodes and inferred edges for containment, routing, dependencies, references, change impact, proof/evidence, and usage relationships. This task is only complete when Map, Operate, History, and Governance can all consume the same graph object instead of rebuilding relationships per screen.

## Background Context

### O que ja existe:
- Task 0310 will define the normalized backbone contract.
- Task 0312 will expose a typed workspace snapshot from the mock corpus.
- `warp-prism/docs/research.md` explicitly recommends one normalized graph shared by the Harness Map and Execution Ledger.

### O que esta faltando / quebrado:
- There is no service that builds one graph from parsed assets.
- Current `AssetEdge` is too generic and cannot express required edge kinds such as `contains`, `routesTo`, `dependsOn`, `references`, `changedBy`, `proves`, and `uses`.
- The future Map, History, and Governance surfaces would currently have to infer relationships independently.

---

## Test Requirements

- Graph normalization DEVE emit one canonical graph object containing typed assets plus typed edges.
- Edge inference DEVE cover at least containment, routes-to, depends-on, references, changed-by/proves, and uses relationships when the source metadata supports them.
- The graph builder DEVE preserve source path and canonicality metadata needed by Governance and detail surfaces.
- Graph tests DEVE assert representative links spanning `.agents/`, tasks, and changelog assets.

---

## Exit Conditions (GDD/TDD)

- [x] Graph normalization and edge-inference services exist under `warp-prism/lib/data/services/`.
- [x] One canonical graph result type is returned for downstream consumers instead of multiple screen-specific relationship builders.
- [x] `flutter analyze lib/data/services lib/data/repositories test/data/services` passes without errors.
- [x] `flutter test test/data/services/workspace_graph_builder_test.dart` passes with 0 failures. (30/30 PASS live 2026-07-09 path-to-100)
- [x] Entry in changelog is added via the engine with `--project warp-prism`.

---

## Details

### What

Subtasks:
- [x] **Ler codigo existente**: `warp-prism/docs/prompt.txt`, `warp-prism/docs/research.md`, `warp-prism/docs/tasks/00-planning/EPIC-03-warp-prism-data-layer-graph-backbone.md`, `warp-prism/lib/data/models/models.dart`, planned repository contracts from Task 0312, and the parser output shape from Task 0311
- [x] Define the canonical graph result type and keep its ownership inside the data/domain layer rather than inside UI widgets.
- [x] Implement edge inference rules for containment, route, dependency, evidence, and usage relationships.
- [x] Add tests that prove one changelog entry can link to a task, and one task can link to a workflow/skill/agent chain through normalized edges.
- [x] **Refactoring pass**: Review implementation for simplicity. If you wrote 200 lines that could be 50, rewrite them.
- [x] **Documentation update**: If edge inference rules become durable knowledge, record them with `agent-wiki` and/or `warp-prism/docs/` as appropriate.
- [x] **Verificacao de regressao**: execute `flutter analyze lib/data/services lib/data/repositories test/data/services` and `flutter test test/data/services/workspace_graph_builder_test.dart` — **PASS 2026-07-09 under apps/observatory**

### Where

| Arquivo | Proposito |
|---------|-----------|
| `warp-prism/docs/prompt.txt` | Ler - confirmar kinds e edge semantics exigidos |
| `warp-prism/docs/research.md` | Ler - confirmar o uso de um unico grafo compartilhado |
| `warp-prism/lib/data/models/models.dart` | Ler - consumir os tipos normalizados |
| `warp-prism/lib/data/repositories/workspace_repository.dart` | Ler - integrar o snapshot do repositorio |
| `warp-prism/lib/data/services/workspace_graph_builder.dart` | Criar - montagem do grafo canonical |
| `warp-prism/lib/data/services/edge_inference_service.dart` | Criar - regras de inferencia de arestas |
| `warp-prism/lib/data/services/workspace_graph.dart` | Criar - tipo de retorno do grafo construido |
| `warp-prism/test/data/services/workspace_graph_builder_test.dart` | Criar - testes de normalizacao e inferencia |

### How

1. Start from repository snapshot inputs and keep inference pure so tests can run without widget setup.
2. Encode inference rules from metadata rather than path-name guessing whenever structured fields exist.
3. Keep graph output stable enough that future providers can cache or derive filtered projections from it.
4. Prefer one graph build pipeline over multiple specialized mini-builders.

### Why

The app promise is one observability console over two domains, not several disconnected lists. If the graph is not normalized centrally, Map, Operate, History, and Governance will drift into separate truth models and break cross-navigation.

---

## ⛔ Anti-Hallucination Guardrails

> [!CAUTION]
> Do NOT hardcode screen-specific edge lists inside widgets as a substitute for graph normalization.

> [!IMPORTANT]
> Infer edges from typed metadata first. Path heuristics may complement the model only when the contract does not yet expose the relationship explicitly.

---

## 📋 Completion Evidence (preenchido pelo agente executor)

- **Arquivos criados/modificados** (package root: `apps/observatory/`):
  - `lib/data/services/workspace_graph.dart` — canonical `WorkspaceGraphResult`
  - `lib/data/services/edge_inference_service.dart` — pure edge inference (contains, routesTo, dependsOn, references, changedBy, proves, uses)
  - `lib/data/services/workspace_graph_builder.dart` — single graph build pipeline with deduplication
  - `lib/data/services/services.dart` — barrel export
  - `lib/data/models/workspace_graph.dart` — typed `WorkspaceAsset` / `WorkspaceEdge` / `EdgeKind` / `Canonicality`
  - `test/data/services/workspace_graph_builder_test.dart` — normalization + inference suite
- **Testes que verificam o trabalho**: `workspace_graph_builder_test.dart` — **27/27 passed** (builder, inference service, result helpers; changelog→task and task→skill/workflow chains)
- **Resultado dos comandos de validacao** (cwd `apps/observatory`, 2026-07-09):
  - `flutter analyze lib/data/services lib/data/repositories test/data/services` → **No issues found!**
  - `flutter test test/data/services/workspace_graph_builder_test.dart` → **All tests passed! (+27)**
- **Entrada no CHANGELOG**: `docs/changelog/20260607-215829-0313-2026-06-07-task-0313-graph-normalization-edge-inference-repair-bot.md`
- **Agent-wiki / docs institucionalizacao**: builders continuity handoff for review promotion
- **Self-review score**: 100/100 (implementation present, all exit conditions green, no code defects found in scoped re-check)
- **Agente executor**: hermes-agent (impl); omniroute/builder path-to-100 validation + self-review 2026-07-09
- **Data de conclusao**: 2026-06-07 (impl); validation unblocked 2026-07-09

## Review Ledger

### Path-to-100 Remediation (2026-07-09, gt-flutter-engineer)
- **Score (self)**: `100/100`
- **Lane**: remain `02-doing` (await independent re-review)
- **Closed blockers**:
  - `normalizeAssetId(kind, raw)` strips repeated prefixes; used in inference + parser edge builders
  - `inferPathContainment` returns null when path skill ≠ `skillDirectoryPattern`
  - Exact `targetId` tests for bare / prefixed / double-prefixed inputs
  - Live: **30/30** graph builder tests PASS
- **Changelog**: `docs/changelog/2026-07-09-task-0311-0313-path-to-100-parser-repo-graph.md`

### Latest Independent Review (prior)
- **Date**: 2026-07-09
- **Reviewer profile**: `reviewers`
- **Score**: `88/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Full report**: `docs/reports/review-wave-2026-07-09/task-0313-graph-normalization-independent-rereview.md`
- **Lane outcome**: returned to `02-doing` (remediated; still awaiting re-review)

#### Current Open Blockers
- None for path-to-100 engineering items. Awaiting independent re-review score ≥90.

#### Path-to-100 Summary
- DONE: normalize IDs; exact targetId tests; skillDirectoryPattern honored; gates re-run.

### Previous Reports
- `2026-06-17` — `60/100` — `docs/reports/review-wave-3/0313-review.md`
- `2026-06-13` — `100/100` — `docs/reports/build-gate-review/0313-review.md` (superseded)

### Path-to-100 delta (2026-07-09 gt-flutter-engineer)
- `workspace_graph.dart` — `normalizeAssetId`
- `edge_inference_service.dart` — all target prefixes via normalize; skillDirectoryPattern enforced
- `workspace_markdown_parser.dart` — edge builders use normalizeAssetId
- Tests: exact targetIds + double-prefix + pattern mismatch
- Live: 30/30 graph suite PASS


### Independent path-to-100 re-review — 2026-07-10 (gt-code-quality-reviewer)

- **Date**: 2026-07-10
- **Reviewer**: `gt-code-quality-reviewer` (reviewers profile)
- **Score**: `100/100`
- **Verdict**: `APPROVED_PROMOTE_TO_REVIEW`
- **Lane outcome**: `docs/tasks/03-review/`
- **Cheap live validation**: flutter test workspace_graph_builder_test.dart → 30/30 PASS; normalizeAssetId + skillDirectoryPattern present
- **Findings**: None blocking.
- **Wave report**: `docs/reports/review-wave-2026-07-10/path-to-100-mass-rereview.md`
- **No git operations**.

### Independent path-to-100 deep re-review — 2026-07-10 (gt-flutter-code-reviewer + gt-code-quality-reviewer)

- **Date**: 2026-07-10
- **Reviewer profile**: `reviewers`
- **Score**: `100/100`
- **Verdict**: `ACCEPTED_100`
- **Full report**: `docs/reports/review-wave-2026-07-10/task-0313-path-to-100-independent-rereview.md`
- **Lane outcome**: remain `docs/tasks/03-review/` (never `04-completed/`)
- **Live proof**: 30/30; normalizeAssetId strips double-prefix; skillDirectoryPattern mismatch → null; exact targetId asserts
- **Open blockers**: none
- **No git operations**.
