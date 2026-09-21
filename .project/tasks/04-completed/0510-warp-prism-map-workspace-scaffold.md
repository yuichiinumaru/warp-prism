# Task 0510: Map workspace scaffold and route contract

> **Review State**: `ACCEPTED_100` — remain in `docs/tasks/03-review/`
> **Priority**: 🔴 P0
> **Type**: `feature`
> **Origin**: `EPIC-05-warp-prism-map-surface.md` plus user request to create actionable warp-prism tasks
> **Blocks**: Task 0511, Task 0512, Task 0513, Task 0514
> **Depends on**: `EPIC-03-warp-prism-data-layer-graph-backbone.md`, `Task 0410`, `Task 0411`, `Task 0413`

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 0510` plus optional slug for dependencies,
> blockers, review ledgers, reports, and architecture references. Lanes such as
> `02-doing` and `03-review` are mutable status, not identity. If a live file path
> is needed, resolve it from `docs/tasks/tasklist.md` or search under `docs/tasks/`.

---

## Objective

Create the Map workspace feature scaffold that gives warp-prism a real Map route, a feature-local state contract, and a DS-composed shell ready to host catalog and graph content without parsing markdown directly inside widgets. Completion means an executor can open the Map surface through the app router, switch between the four required subviews (`Agents`, `Skills`, `Workflows`, `Graph`), and extend the page in follow-up tasks without reworking the route or state shape.

## Background Context

### O que já existe:
- `warp-prism/lib/design_system/templates/master_detail_template.dart` and `warp-prism/lib/design_system/organisms/ds_shell.dart` provide reusable shell primitives, even though their APIs are currently inconsistent.
- `warp-prism/lib/design_system/organisms/ds_sidebar.dart`, `ds_topbar.dart`, `ds_graph_canvas.dart`, and `ds_detail_inspector.dart` already define the main Map-oriented DS organisms that the surface should compose.
- `warp-prism/lib/data/models/models.dart` and `warp-prism/lib/data/parsers/workspace_parser.dart` show the current data-layer direction, but they still reflect the earlier generic/YAML model rather than the normalized graph contract from the roadmap.
- `warp-prism/docs/prompt.txt` and `warp-prism/docs/research.md` define Map as a first-class workspace with catalog tabs, graph modes, and selection-driven inspection.

### O que está faltando / quebrado:
- `warp-prism/docs/draft.md` documents that `lib/main.dart`, `lib/app/app.dart`, and `lib/app/router.dart` were missing or not located during the audit, so the product shell entrypoint is not yet a safe base for Map.
- There is no existing `lib/features/map/` module, no feature-local provider/view-model contract, and no route-level widget for the Map workspace.
- The DS template layer currently references class names and constructor APIs that do not match the actual organism implementations, so the Map surface needs a narrow scaffold contract instead of duplicating that mismatch.
- No widget tests currently prove that a Map route exposes the required Map tabs and can render shell-level loading/error placeholders.

---

## Test Requirements

- DEVE expor uma rota navegável da surface Map no shell do app, sem parsing direto de arquivos markdown dentro do widget de página.
- DEVE apresentar quatro subviews nomeadas `Agents`, `Skills`, `Workflows`, e `Graph` a partir de um estado tipado único da feature.
- DEVE permitir que tarefas posteriores adicionem catálogo, grafo e inspector sem refatorar a assinatura pública do estado da página.
- DEVE ter pelo menos um teste de widget cobrindo a renderização da rota Map e um edge case de estado inicial vazio/carregando.

---

## Exit Conditions (GDD/TDD)

- [x] Existe um módulo `lib/features/map/` com página, estado e contratos mínimos da surface Map.
- [x] A rota do app consegue abrir a surface Map dentro do shell planejado para warp-prism.
- [x] A página mostra os quatro tabs/subviews requeridos pelo epic (`Agents`, `Skills`, `Workflows`, `Graph`).
- [x] Existe pelo menos um teste em `test/features/map/` cobrindo a rota Map e um estado não-happy-path.
- [x] `flutter analyze` passa sem erros (scoped map + map_page; 0 errors, 1 pre-existing info prefer_const in graph edges test)
- [x] `flutter test test/features/map/` passa com 0 falhas (119/119 expert 2026-07-18)
- [x] Entrada de changelog adicionada via engine em `docs/changelog/`

---

## Details

### What

Subtasks:
- [x] **Ler código existente**: monorepo paths under `apps/observatory/`, Prism public API, router, map feature, tests
- [x] Criar a base da feature Map (`page`, `state`, `provider/view-model` ou equivalente) usando contratos compatíveis com os epics 03 e 04.
- [x] Registrar a rota Map no app shell e garantir que a página consegue renderizar tabs/subviews e placeholders sem depender ainda das implementações completas do catálogo e do grafo.
- [x] Criar testes de widget para a rota Map, incluindo um cenário de estado inicial não carregado/com conteúdo vazio.
- [x] **Refactoring pass**: Map page uses public `PrismTabBar`/`PrismTabController` (no Material3 ink sparkle); map widgets/tests/asset_detail consumers migrated to public `Prism*` API.
- [x] **Documentation update**: local changelog + builders continuity entry.
- [x] **Verificação de regressão**: `flutter test test/features/map/` → 103/103 PASS; scoped analyze → 0 errors.

### Where

| Arquivo | Propósito |
|---------|-----------|
| `apps/observatory/lib/features/map/map_workspace_page.dart` | Modificar — PrismTabBar scaffold + IndexedStack subviews |
| `apps/observatory/lib/features/map/map_workspace_provider.dart` | Modificar — `syncState` for parent injection |
| `apps/observatory/lib/features/map/widgets/*` | Modificar — public Prism* consumer API |
| `apps/observatory/lib/features/asset_detail/presentation/*` | Modificar — public Prism* consumer API (Map dependency) |
| `apps/observatory/lib/app/pages/map_page.dart` | Ler — route shell forwards to MapWorkspacePage |
| `apps/observatory/lib/app/router.dart` | Ler — `/map` → MapPageShell |
| `apps/observatory/test/features/map/*` | Modificar — Prism* finders + scaffold edge cases |

### How

1. Feature-local typed state (`MapWorkspaceState` + `MapSubview`) with catalog/query/filter/selection extension points.
2. Route `/map` via `MapPageShell` → `MapWorkspacePage` with four tabs through `PrismTabBar`.
3. Placeholders and catalog/graph/inspector panels driven by state, no markdown parsing in page widgets.
4. Widget + unit tests prove tabs, loading/empty/error, and tab switching without Material ink sparkle.

### Why

Sem esta task, os trabalhos de catálogo, grafo e inspector seriam forçados a discutir novamente rota, layout, estado compartilhado e boundary entre UI e parser. Isso aumenta blast radius e incentiva soluções locais inconsistentes. O scaffold cria a base única e executável para toda a EPIC 05.

---

## ⛔ Anti-Hallucination Guardrails

> [!CAUTION]
> DO NOT implementar parsing de markdown, leitura direta de assets ou listas hardcoded de nós/cards dentro da página Map para “destravar” a UI. A page deve depender de contratos de dados e placeholders explícitos.

> [!IMPORTANT]
> Prefer public `Prism*` API from `package:warp_prism_ui/warp_prism_ui.dart`. Do not reintroduce private `DS*` symbols in consumer app code.

---

## 📋 Completion Evidence (preenchido pelo agente executor)

> **OBRIGATÓRIO ao fechar a task.** O agente deve preencher esta seção ANTES de mover para `completed/`.
> Sem evidência = task NÃO pode ser movida.

### 2026-07-18 — Path-to-100 residual remediation (post drain 88/100)

Drain findings (F1–F4) already landed in live code from prior mid-flight wave;
this session verified, closed the remaining analyze info, and refreshed evidence.

#### Drain residual resolution

| ID | Finding | Resolution | Proof |
| --- | --- | --- | --- |
| F1 | Incomplete `MapWorkspaceState.==` / `hashCode` | Includes `activeFilters` (`setEquals`), `activeGraphMode`, catalog identity (`listEquals`), `graphEdges`, `additionalState` | `map_workspace_state.dart:234–264`; test `equality includes activeFilters, graph mode, and catalog identity` |
| F2 | Retry clears error only | `MapWorkspacePage.onRetry` + `MapPageShell` invalidates `workspaceSnapshotAsyncProvider` + `workspaceGraphAsyncProvider` | `map_workspace_page.dart:160–168`; `map_page.dart:21–24`; tests `error Retry invokes onRetry` + `error surface exposes Retry that invalidates snapshot` |
| F3 | `syncState` full-replace wipe/stale | Merge: preserve query/filters/selection/subview/mode/additionalState; take catalog/loading/error/edges from parent | `map_workspace_provider.dart:132–159`; tests `syncState merges…` + `syncState retains graphEdges…` |
| F4 | Format dirt | Clean | `dart format --output=none --set-exit-if-changed` → exit 0 |

#### Arquivos (live residual surface)

- `apps/observatory/lib/features/map/map_workspace_state.dart` — full equality/hashCode
- `apps/observatory/lib/features/map/map_workspace_provider.dart` — merge `syncState`
- `apps/observatory/lib/features/map/map_workspace_page.dart` — `onRetry`, empty-family, PrismTabBar scaffold
- `apps/observatory/lib/app/pages/map_page.dart` — shell hydration + invalidate on Retry
- `apps/observatory/test/features/map/map_workspace_page_test.dart` — equality, syncState, onRetry, MapPageShell provider path
- `apps/observatory/test/features/map/map_graph_builder_edges_test.dart` — `prefer_const` hygiene (this session)

#### Validation (fresh 2026-07-18, cwd `apps/observatory`)

```text
flutter analyze --no-pub lib/features/map/ test/features/map/ lib/app/pages/map_page.dart lib/app/router.dart
→ No issues found! (0 errors / 0 warnings / 0 info)

flutter test --concurrency=1 --no-pub test/features/map/
→ +117 All tests passed!

dart format --output=none --set-exit-if-changed lib/features/map/ test/features/map/ lib/app/pages/map_page.dart
→ Formatted 21 files (0 changed); FORMAT_EXIT=0
```

#### Entrypoint Chain Proof

- **Claim**: `/map` hydrates catalog from workspace snapshot; Retry reloads snapshot
- **Entrypoint**: GoRouter `/map` → `MapPageShell`
- **Adapter**: `MapPageShell.build` watches `workspaceSnapshotAsyncProvider` / `workspaceGraphAsyncProvider`, injects `MapWorkspaceState`, wires `onRetry` → `ref.invalidate(...)`
- **Feature**: `MapWorkspacePage` + `MapWorkspaceProvider.syncState` merge path
- **Regression tests**: `MapPageShell provider path loading → data hydrates…`; `error surface exposes Retry that invalidates snapshot`
- **Evidence classification**: `temp-fixture integration` (ProviderScope overrides)

#### Changelog Draft (builder — do not publish)

```yaml
task: 0510
agent: gt-flutter-engineer
project: warp-prism
title: Map workspace scaffold path-to-100 residuals
description: >
  Verified full MapWorkspaceState equality, merge-style syncState, shell Retry
  invalidation, MapPageShell provider-path tests; suite 117/117, analyze clean.
summary: Path-to-100 residual closeout for Task 0510 after 88/100 drain reject.
verification: >
  flutter analyze map scope → No issues found;
  flutter test test/features/map/ → 117/117 PASS
```

- **Prior changelog note**: `docs/changelog/2026-07-09-task-0510-map-workspace-scaffold.md` (historical)
- **Agente executor**: gt-flutter-engineer under builders
- **Data de conclusão (path-to-100)**: 2026-07-18
- **Self-score (prior builder)**: **98/100**
- **Expert score (2026-07-18 gt-flutter-expert)**: **100/100** after identical-sync + content-refresh test; map suite **119/119**; lane left in `02-doing` (no promote).

## Builder Self-Review (path-to-100)

| Criterion | Result |
|---|---|
| Map module exists with page/state/provider | PASS |
| `/map` route opens MapPageShell → MapWorkspacePage | PASS |
| Four tabs Agents/Skills/Workflows/Graph | PASS |
| Widget test covers route + loading/empty | PASS |
| Equality includes filters/mode/catalog identity | PASS |
| syncState merges, does not wipe UI | PASS |
| Retry invalidates workspace snapshot | PASS |
| MapPageShell + ProviderScope tests | PASS |
| Scoped tests 117/117 | PASS |
| Scoped analyze 0 issues | PASS |
| Format clean | PASS |
| No markdown parsing in page | PASS |
| Prism* public API | PASS |

**Verdict**: Path-to-100 residuals remediated. **Left in `docs/tasks/02-doing/`** per orchestrator (no promote to 03-review).

---

## Review Ledger

> [!IMPORTANT]
> Before path-to-100 work, read the latest full report and all reports listed
> under Previous Reports.

### Latest Review

- **Date**: 2026-07-09
- **Reviewer profile**: `reviewers`
- **Score**: `90/100`
- **Verdict**: `HELD_IN_REVIEW_PATH_TO_100`
- **Full report**: `docs/reports/review-wave-2026-07-09/task-0510-map-workspace-scaffold-independent-rereview.md`
- **Lane outcome**: remains in `03-review`
- **Task reference**: Task 0510 (`warp-prism-map-workspace-scaffold`)

#### Current Open Blockers

- `NEW` / Moderate: incomplete `MapWorkspaceState.==` (ignores filters/graph mode/catalog identity; only asset list length).
- `NEW` / Low: Map error Retry clears local error only (no workspace reload).
- `NEW` / Low: evidence count 103 vs live 104.

#### Path-to-100 Summary

- Fix `MapWorkspaceState` equality/hashCode for filter/mode/catalog identity.
- Retry should invalidate `workspaceSnapshotAsyncProvider` (or accept reload callback).
- One `MapPageShell` + provider-override widget test.
- Align Completion Evidence test count to 104.
- **Regression guard**: keep `MapPageShell` repository hydration; do not revert to empty-only `const MapWorkspacePage()`.

### Previous Reports

- `2026-06-19` — `78/100` — `docs/reports/review-wave-2026-06-19/0510-map-workspace-scaffold-rereview.md`
  - **Resolved since**: analyze clean; 104/104; MapPageShell data path; changelog
  - **Regression guard**: production `/map` must load catalog from workspace snapshot provider
- `2026-06-13` — `100/100` — `docs/reports/build-gate-review/0510-review.md` (superseded; SDK blocked)

### 2026-07-17 — Independent drain re-review (reviewers / Batch 3)

- **Score**: `88/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Lane**: `docs/tasks/02-doing/`
- **Report**: `docs/reports/review-wave-2026-07-17/task-0510-drain-review.md`
- **Note**: Incomplete equality + syncState full-replace wipe/stale race; Retry without invalidate; format dirt. Map suite 105/105.

### 2026-07-18 — Builder path-to-100 residual closeout

- **Executor**: gt-flutter-engineer under builders
- **Action**: Verified F1–F4 already in live code; const hygiene on graph-edges test; fresh 117/117 + analyze clean
- **Lane**: remains `docs/tasks/02-doing/` (orchestrator: no promote)
- **Open blockers**: none known at builder closeout

### 2026-07-18 — Expert path-to-100 (gt-flutter-expert / builders)

- **Score before**: `88/100` (drain)
- **Score after fix**: `100/100`
- **Full report**: `docs/reports/review/expert-2026-07-18-task-0510.md`
- **Fixes**:
  1. `didUpdateWidget` parent inject now gates on `!identical` (WorkspaceAsset.== is identity-light)
  2. Widget test: content-only description refresh after parent inject
- **Validation**: map suite **+119** All tests passed; scoped analyze No issues found
- **Lane**: remains `docs/tasks/02-doing/` (no promote)
- **Open blockers**: none

### 2026-07-18 — Formal independent re-review (gt-flutter-code-reviewer / builders)

- **Score**: `100/100`
- **Verdict**: `ACCEPT` / `APPROVED_PROMOTE_TO_REVIEW`
- **Full report**: `docs/reports/review/formal-2026-07-18-task-0510.md`
- **Lane outcome**: `docs/tasks/03-review/`
- **Validation**: live re-verify on filesystem + scoped/package gates (see report)
- **Open blockers**: none
- **Live**: map suite +119; analyze No issues; format 0 changed; dispose 1:1; Retry invalidate; merge syncState; identical inject

### 2026-08-23 — Independent adversarial live re-review

- **Reviewer**: independent live-filesystem reviewer
- **Score**: **100/100**
- **Verdict**: `ACCEPTED_100`; remain in `docs/tasks/03-review/`
- **Report**: `docs/reports/review/0510-map-workspace-scaffold-adversarial-review-2026-08-23.md`
- **Fresh proof**: scoped map analyzer `No issues found`; Map suite `+119 All tests passed`; non-mutating format `22 files (0 changed)`; `/map` router → `MapPageShell` → provider hydration and dual Retry invalidation verified.
- **Open blockers**: none for Task 0510.
