# Task 0511: Map catalog tabs, cards, and filter interactions

> **Status**: `[x]` Ready For Review — formal independent accept 2026-07-18 (**100/100**)
> **Review State**: Formal accept **100/100** — promoted to `03-review/` (gt-flutter-code-reviewer)
> **Priority**: 🟡 P1
> **Type**: `feature`
> **Origin**: `EPIC-05-warp-prism-map-surface.md` candidate stories for catalog tabs and search/filter/chip interaction
> **Blocks**: Task 0513, Task 0514
> **Depends on**: Task 0510 (`0510-warp-prism-map-workspace-scaffold`)

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 0511` plus optional slug for dependencies,
> blockers, review ledgers, reports, and architecture references. Lanes such as
> `02-doing` and `03-review` are mutable status, not identity. If a live file path
> is needed, resolve it from `docs/tasks/tasklist.md` or search under `docs/tasks/`.

---

## Objective

Implement the catalog side of the Map surface so users can browse `Agents`, `Skills`, and `Workflows` as DS-composed asset cards with search and filter interactions driven by repository/view-model data rather than static demo lists. Completion means each tab exposes the correct asset family, asset cards surface kind/canonicality/relationship context, and query/filter changes deterministically update the visible result set and empty states.

## Background Context

### O que já existe:
- `warp-prism/docs/prompt.txt` requires Map tabs, asset cards, and relationships for agents, skills, workflows, scripts, references, tasks, and changelog entries.
- `warp-prism/docs/research.md` recommends a synchronized catalog + graph + detail model, where cards show more than a filename and reveal provenance, triggers, and link density.
- Design-system molecules (`PrismAssetCard`, `PrismSearchBar`, `PrismFilterChipGroup`) provide the catalog UI primitives via `warp_prism_ui`.
- Task 0510 established the Map route and feature-local state contract under `apps/observatory/lib/features/map/`.

### O que está faltando / quebrado:
- ~~No catalog panel~~ **Resolved**: `MapCatalogPanel` + grid + no-results.
- ~~No deterministic filter tests~~ **Resolved**: unit + widget coverage.
- ~~Flutter SDK validation blocked~~ **Resolved**: live SDK on 2026-07-09.

---

## Test Requirements

- DEVE mostrar somente assets da família correta em cada tab de catálogo (`Agents`, `Skills`, `Workflows`).
- DEVE aplicar query de busca e filtros/chips sobre a mesma coleção normalizada, sem branches paralelos por tab.
- DEVE exibir em cada card pelo menos kind, canonicality/status, e um resumo de relacionamentos/triggers quando os dados existirem.
- DEVE renderizar um empty state específico para “nenhum resultado” quando filtros ou query eliminarem todos os assets visíveis.
- DEVE ter pelo menos um teste happy-path de filtragem e um edge case de zero resultados.

---

## Exit Conditions (GDD/TDD)

- [x] Existe um painel/lista de catálogo da Map surface para `Agents`, `Skills`, e `Workflows`.
- [x] Busca e filtros/chips alteram os assets visíveis de forma determinística e testada.
- [x] Asset cards exibem metadados relevantes do epic em vez de apenas nome/descrição.
- [x] Existe pelo menos um teste de widget e/ou view-model para happy path de filtragem e um cenário de zero resultados.
- [x] `flutter analyze` passa sem erros (scoped map + catalog: 0 errors)
- [x] `flutter test test/features/map/` passa com 0 falhas (119/119 expert 2026-07-18)
- [x] Entrada de changelog adicionada em `docs/changelog/`

---

## Details

### What

Subtasks:
- [x] **Ler código existente**: map workspace state/provider/page, catalog widgets, Prism public API, catalog tests
- [x] Implementar o painel de catálogo da Map surface com tabs reais para `Agents`, `Skills`, e `Workflows` e lista/grid de cards baseado em estado derivado.
- [x] Conectar query e chips/filtros à mesma fonte de verdade da feature para evitar drift entre tabs e contadores.
- [x] Implementar estado explícito de “nenhum resultado” para busca/filtro e cobrir a interação com testes.
- [x] **Refactoring pass**: const lint hygiene on catalog panel + tests; no structural rewrite needed.
- [x] **Documentation update**: local changelog + builders continuity handoff.
- [x] **Verificação de regressão**: `flutter analyze` (catalog scoped) + `flutter test test/features/map/` — PASS

### Where

| Arquivo | Propósito |
|---------|-----------|
| `apps/observatory/lib/features/map/map_workspace_page.dart` | Tabs + catalog/graph composition |
| `apps/observatory/lib/features/map/map_workspace_state.dart` | Query, filters, derived filteredAssets |
| `apps/observatory/lib/features/map/map_workspace_provider.dart` | Mutations for query/filters/assets |
| `apps/observatory/lib/features/map/widgets/map_catalog_panel.dart` | Catalog panel (search/chips/cards) |
| `apps/observatory/lib/features/map/widgets/map_asset_card_grid.dart` | PrismAssetCard grid adapter |
| `apps/observatory/lib/features/map/widgets/map_no_results_state.dart` | No-results empty state |
| `apps/observatory/test/features/map/map_catalog_panel_test.dart` | Filtering + widget proofs |
| `docs/changelog/2026-07-09-task-0511-map-catalog-tabs-and-filters.md` | Changelog note |

### How

1. Single `catalogAssets` collection; tab family via `assetsForTab`; query+chips via `filteredAssets`.
2. Thin `_AssetCardAdapter` maps `WorkspaceAsset` → `PrismAssetCard` (kind, canonicality, edges, tags/triggers).
3. Page-level loading/error/empty-corpus/no-results gates before catalog panel.
4. Tests cover family filtering, query, chips, combined filters, zero results, clear filters.

### Why

O catálogo é a porta de entrada mais legível da EPIC 05. Sem ele, a surface Map vira apenas um canvas abstrato e perde a capacidade de responder rapidamente “o que existe”.

---

## ⛔ Anti-Hallucination Guardrails

> [!CAUTION]
> DO NOT introduzir listas manuais diferentes por tab só para montar a demo. O catálogo deve vir da mesma coleção normalizada usada pelo resto da Map surface.

> [!IMPORTANT]
> Read EVERY file in `Where` before writing, and keep filter semantics explicit in tests so later tasks can extend the card metadata without changing what “query” and “chip filter” mean.

---

## 📋 Completion Evidence (preenchido pelo agente executor)

> **OBRIGATÓRIO ao fechar a task.** O agente deve preencher esta seção ANTES de mover para `completed/`.
> Sem evidência = task NÃO pode ser movida.

### 2026-07-18 — Path-to-100 residual remediation (post drain 87/100)

Drain findings (F1–F3) already landed in live code from prior mid-flight wave;
this session verified a11y + empty-family paths and refreshed suite evidence
(shared map suite with Task 0510).

#### Drain residual resolution

| ID | Finding | Resolution | Proof |
| --- | --- | --- | --- |
| F1 | Clear all raw `GestureDetector` a11y | `Semantics(button: true, label: 'Clear all filters')` + `TextButton` min 48×48 | `map_catalog_panel.dart:121–140`; test `Clear all is a semantic button with ≥48dp target` |
| F2 | Empty-family tab falls to no-results | `MapSurfaceState.emptyFamily` when `assetsForTab.isEmpty && !hasFilters` | `map_workspace_page.dart:275–281`; tests `empty-family tab shows dedicated empty-family panel` + `empty family is distinct from empty corpus` |
| F3 | No Semantics regression test for Clear all | Widget test asserts label, 48dp, tap | `map_catalog_panel_test.dart:417–454` |
| Shared | Equality/`syncState` filter survival | Coordinated with Task 0510 merge `syncState` + full `==` | shared provider/state tests |

#### Arquivos (catalog residual surface)

- `apps/observatory/lib/features/map/widgets/map_catalog_panel.dart` — accessible Clear all
- `apps/observatory/lib/features/map/map_workspace_page.dart` — empty-family gate
- `apps/observatory/lib/features/map/widgets/map_state_panel.dart` — `MapSurfaceState.emptyFamily`
- `apps/observatory/lib/features/map/map_workspace_state.dart` — single-collection `assetsForTab` / `filteredAssets`
- `apps/observatory/test/features/map/map_catalog_panel_test.dart` — filter + Clear all a11y
- `apps/observatory/test/features/map/map_surface_states_test.dart` — empty-family distinctness

#### Validation (fresh 2026-07-18, cwd `apps/observatory`)

```text
flutter analyze --no-pub lib/features/map/ test/features/map/ lib/app/pages/map_page.dart lib/app/router.dart
→ No issues found!

flutter test --concurrency=1 --no-pub test/features/map/
→ +117 All tests passed!  (includes catalog suite + Clear all a11y + empty-family)
```

#### Changelog Draft (builder — do not publish)

```yaml
task: 0511
agent: gt-flutter-engineer
project: warp-prism
title: Map catalog Clear-all a11y and empty-family UX
description: >
  Verified Semantics+TextButton Clear all (≥48dp), empty-family panel vs
  no-results, single-collection filter contract; map suite 117/117.
summary: Path-to-100 residual closeout for Task 0511 after 87/100 drain reject.
verification: >
  flutter analyze map scope → No issues found;
  flutter test test/features/map/ → 117/117 PASS
```

- **Prior changelog note**: `docs/changelog/2026-07-09-task-0511-map-catalog-tabs-and-filters.md` (historical)
- **Agente executor**: gt-flutter-engineer under builders
- **Data de conclusão (path-to-100)**: 2026-07-18
- **Self-review score (prior builder)**: **98/100**
- **Expert score (2026-07-18 gt-flutter-expert)**: **100/100** after empty-family+filters → no-results unification; map suite **119/119**; lane left in `02-doing` (no promote).

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
- **Full report**: `docs/reports/review-wave-2026-07-09/task-0511-map-catalog-tabs-filters-independent-rereview.md`
- **Lane outcome**: remains in `03-review`
- **Task reference**: Task 0511 (`warp-prism-map-catalog-tabs-and-filters`)

#### Current Open Blockers

- `PERSISTENT` / Moderate: “Clear all” is raw `GestureDetector` without Semantics/button focus (`map_catalog_panel.dart:122–131`).
- `NEW` / Low: empty family tab falls through to no-results UX when other kinds exist.
- Shared with 0510: incomplete `MapWorkspaceState.==` for filters.

#### Path-to-100 Summary

- Replace Clear all with TextButton/InkWell + Semantics (≥48dp).
- Align equality fix with Task 0510 (include `activeFilters`).
- Optional explicit empty-family state when `assetsForTab.isEmpty && !hasFilters`.
- **Regression guard**: single-collection filtering + zero-results tests must stay green.

### Previous Reports

- `2026-06-19` — `80/100` — `docs/reports/review-wave-2026-06-19/0511-map-catalog-tabs-filters-rereview.md`
  - **Carried forward**: Clear all a11y
  - **Resolved since**: tests 104/104; production catalog data path; changelog; analyzer clean
  - **Regression guard**: keep deterministic filter unit tests and no-results clear action
- `2026-06-13` — `100/100` — `docs/reports/build-gate-review/0511-review.md` (superseded; SDK blocked)

### 2026-07-17 — Independent drain re-review (reviewers / Batch 3)

- **Score**: `87/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Lane**: `docs/tasks/02-doing/`
- **Report**: `docs/reports/review-wave-2026-07-17/task-0511-drain-review.md`
- **Note**: Clear all still raw GestureDetector (a11y); empty-family UX residual. Map suite 105/105.

### 2026-07-18 — Builder path-to-100 residual closeout

- **Executor**: gt-flutter-engineer under builders
- **Action**: Verified Clear all Semantics+TextButton, empty-family panel, a11y test; shared equality/syncState with 0510
- **Lane**: remains `docs/tasks/02-doing/` (orchestrator: no promote)
- **Open blockers**: none known at builder closeout

### 2026-07-18 — Expert path-to-100 (gt-flutter-expert / builders)

- **Score before**: `87/100` (drain)
- **Score after fix**: `100/100`
- **Full report**: `docs/reports/review/expert-2026-07-18-task-0511.md`
- **Fixes**:
  1. Unified no-results when `filteredAssets.isEmpty` after empty-family gate (empty-family + filters → Clear filters UX)
  2. Widget test for empty-family + active filters
- **Validation**: map suite **+119** All tests passed; Clear-all a11y + empty-family still green
- **Lane**: remains `docs/tasks/02-doing/` (no promote)
- **Open blockers**: none

### 2026-07-18 — Formal independent re-review (gt-flutter-code-reviewer / builders)

- **Score**: `100/100`
- **Verdict**: `ACCEPT` / `APPROVED_PROMOTE_TO_REVIEW`
- **Full report**: `docs/reports/review/formal-2026-07-18-task-0511.md`
- **Lane outcome**: `docs/tasks/03-review/`
- **Validation**: live re-verify on filesystem + scoped/package gates (see report)
- **Open blockers**: none
- **Live**: shared map +119; Clear-all Semantics+48dp; empty-family + empty-family+filters→no-results
