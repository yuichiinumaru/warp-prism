# Task 0513: Map selection state and inspector integration

> **Status**: `[x]` Done — independent drain accepted (path-to-100 residual)
> **Review State**: Independent drain **94/100** — `ACCEPTED_PATH_TO_100` → `04-completed/` (2026-07-17)
> **Priority**: 🟡 P1
> **Type**: `feature`
> **Origin**: `EPIC-05-warp-prism-map-surface.md` candidate story for selection/inspector integration
> **Blocks**: Task 0514
> **Depends on**: Task 0511 (`0511-warp-prism-map-catalog-tabs-and-filters`), Task 0512 (`0512-warp-prism-map-graph-modes-and-adapters`)

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 0513` plus optional slug for dependencies,
> blockers, review ledgers, reports, and architecture references. Lanes such as
> `02-doing` and `03-review` are mutable status, not identity. If a live file path
> is needed, resolve it from `docs/tasks/tasklist.md` or search under `docs/tasks/`.

---

## Objective

Connect the Map catalog and graph views to a shared selection model and an inspector panel so choosing a card or graph node reveals the same asset detail summary, relationship context, and provenance hints without requiring the full EPIC 09 universal detail page. Completion means selection is a single feature-level state, catalog taps and graph taps converge on that state, and the inspector can render and clear a selected asset consistently across subviews.

## Background Context

### O que já existe:
- `warp-prism/docs/prompt.txt` requires selection-to-inspector behavior for the Map workspace.
- `warp-prism/docs/research.md` recommends a synchronized catalog, graph, and detail model where detail explains identity, sub-structure, incoming links, operational usage, and governance.
- `warp-prism/lib/design_system/organisms/ds_detail_inspector.dart` already provides a DS organism suited for a side inspector panel.
- Task 0511 should make catalog assets selectable, and Task 0512 should make graph nodes selectable.

### O que está faltando / quebrado:
- No shared selection controller currently exists for the Map feature, so card clicks and graph taps cannot converge on one source of truth.
- `DSDetailInspector` is still a generic shell; there is no feature adapter that turns normalized workspace assets into inspector sections relevant to Map.
- The epic explicitly says the full universal detail page may remain out of scope if EPIC 09 has not landed, so Map needs an inspector that stands on its own instead of blocking on a later epic.
- No tests currently prove that choosing the same asset from the catalog and from the graph yields the same selected object and visible inspector content.

---

## Test Requirements

- DEVE manter um único estado de seleção compartilhado entre catálogo e grafo.
- DEVE atualizar o inspector com o mesmo asset quando a seleção vier de card ou de node correspondente.
- DEVE exibir no inspector pelo menos identidade, kind/canonicality, e relações/triggers/proveniência quando presentes.
- DEVE permitir limpar a seleção e retornar a um estado explícito de “nenhum asset selecionado”.
- DEVE ter pelo menos um teste happy-path de seleção sincronizada e um edge case de limpeza da seleção.

---

## Exit Conditions (GDD/TDD)

- [x] Existe um controlador/estado de seleção único para a feature Map.
- [x] Catálogo e grafo escrevem nesse mesmo estado de seleção.
- [x] Um inspector Map baseado em `PrismDetailInspector` (alias de `DSDetailInspector`) renderiza o asset selecionado com seções úteis para o epic.
- [x] Existe pelo menos um teste cobrindo seleção sincronizada e limpeza da seleção.
- [x] `dart analyze lib/features/map/ test/features/map/` passa sem erros
- [x] `flutter test test/features/map/` passa com 0 falhas (103 tests)
- [x] Entrada de changelog adicionada via engine em `docs/changelog/`

---

## Details

### What

Subtasks:
- [x] **Ler código existente**: map workspace state/provider/page, catalog/graph panels, selection controller, inspector panel, and selection tests under `apps/observatory/`.
- [x] Implementar o estado/controlador único de seleção da feature Map (`MapSelectionController` → `MapWorkspaceProvider.selectAsset` / `deselectAsset` / `selectedAssetId`).
- [x] Adaptar o catálogo e o grafo para publicar seleção no mesmo canal e abrir/atualizar o inspector (`MapWorkspacePage._onAssetTap` / `_onNodeTap` → shared controller; `AssetDetailConsumer` hosts inspector).
- [x] Criar um adaptador de asset selecionado para seções do `PrismDetailInspector`, sem bloquear no detail page universal do EPIC 09 (`MapSelectionController.buildInspectorSections` + `MapInspectorPanel`).
- [x] Criar testes cobrindo seleção via card, seleção via node, e limpeza/fechamento do inspector (`map_selection_and_inspector_test.dart` — 20 tests).
- [x] **Refactoring pass**: Review implementation for simplicity. Controller is thin; inspector uses public Prism\* API; const empty-state fix applied 2026-07-09.
- [x] **Documentation update**: Builder continuity + completion evidence refreshed; prior changelog retained.
- [x] **Verificação de regressão**: `dart analyze` (0 errors) + `flutter test test/features/map/` (103 passed) executed 2026-07-09 with Flutter 3.44.1 / Dart 3.12.1.

### Where

| Arquivo | Propósito |
|---------|-----------|
| `apps/observatory/lib/features/map/map_workspace_state.dart` | Shared `selectedAssetId` + clear semantics |
| `apps/observatory/lib/features/map/map_workspace_provider.dart` | `selectAsset` / `deselectAsset` mutation channel |
| `apps/observatory/lib/features/map/map_selection_controller.dart` | Shared selection + inspector section adapter |
| `apps/observatory/lib/features/map/widgets/map_inspector_panel.dart` | Map inspector via `PrismDetailInspector` |
| `apps/observatory/lib/features/map/widgets/map_catalog_panel.dart` | Catalog emits selection via `onAssetTap` |
| `apps/observatory/lib/features/map/widgets/map_graph_panel.dart` | Graph emits selection via `onNodeTap` |
| `apps/observatory/lib/features/map/map_workspace_page.dart` | Wires catalog/graph → controller → inspector |
| `apps/observatory/test/features/map/map_selection_and_inspector_test.dart` | Sync + clear + inspector proof |

### How

1. Centralizar seleção no estado da feature e tratar cards/nodes como duas origens do mesmo evento semântico.
2. Construir um adaptador de inspector que transforme o asset selecionado em seções estáveis: identidade, governança, relações e pistas operacionais.
3. Manter o inspector útil mesmo sem o detail page universal, evitando dependência desnecessária do EPIC 09.
4. Provar em teste que a seleção sincroniza entre subviews e que o usuário consegue sair claramente do estado selecionado.

### Why

O valor do Map não está só em listar assets; está em navegar relações sem perder contexto. Se catálogo e grafo selecionarem objetos diferentes ou abrirem detalhes inconsistentes, a surface quebra sua promessa central de legibilidade. Esta task fecha esse loop cognitivo.

---

## ⛔ Anti-Hallucination Guardrails

> [!CAUTION]
> DO NOT acoplar o inspector a um detail route universal inexistente para marcar a task como “completa”. O epic aceita inspector local; bloquear no EPIC 09 é escopo indevido.

> [!IMPORTANT]
> Read EVERY file in `Where` before writing, and keep selection semantics singular: one selected asset, one inspector source of truth, multiple event origins.

---

## 📋 Completion Evidence (preenchido pelo agente executor)

> **OBRIGATÓRIO ao fechar a task.** O agente deve preencher esta seção ANTES de mover para `completed/`.
> Sem evidência = task NÃO pode ser movida.

- **Arquivos criados/modificados**:
  - `apps/observatory/lib/features/map/map_selection_controller.dart` — shared selection + section adapter
  - `apps/observatory/lib/features/map/widgets/map_inspector_panel.dart` — Prism\* inspector panel (const empty-state polish 2026-07-09)
  - `apps/observatory/lib/features/map/map_workspace_page.dart` — catalog/graph → selection → inspector wiring
  - `apps/observatory/lib/features/map/map_workspace_provider.dart` / `map_workspace_state.dart` — selection channel
  - `apps/observatory/test/features/map/map_selection_and_inspector_test.dart` — 20 selection/inspector tests
  - `docs/changelog/20260607-220705-0000-2026-06-07-task-0513-map-selection-and-inspector-repair-bot.md`
- **Testes que verificam o trabalho**: `map_selection_and_inspector_test.dart` — selection sync, inspector rendering, clear selection, stream visibility, tab-clear
- **Resultado dos comandos de validação** (2026-07-09, Flutter 3.44.1 / Dart 3.12.1):
  - `dart analyze lib/features/map/ test/features/map/` → **0 errors** (info-level prefer_const only in sibling files)
  - `flutter test test/features/map/map_selection_and_inspector_test.dart` → **20/20 passed**
  - `flutter test test/features/map/` → **103/103 passed**
- **Entrada no CHANGELOG**: `docs/changelog/20260607-220705-0000-2026-06-07-task-0513-map-selection-and-inspector-repair-bot.md`
- **Agent-wiki / docs institucionalização**: builders continuity handoff for review promotion
- **Builder self-score**: **100/100** — all exit conditions proven with live analyzer/test evidence; Prism\* public API used; no EPIC 09 coupling
- **Agente executor**: omniroute/builder (builders profile) — revalidation + promotion after prior SDK-blocked claim
- **Data de conclusão**: 2026-07-09

## Review Ledger

### 2026-07-09 — independent re-review (reviewers)
**Score**: 97/100 — HELD_IN_REVIEW_PATH_TO_100
**Verdict**: Task-scope accept (S≥90). Stay in `03-review/` (never 04-completed by reviewer).
**Report**: `docs/reports/review-wave-2026-07-09/task-0513-map-selection-inspector-independent-rereview.md`
**Fresh proof**: selection suite **20/20**; map suite **104/104**; shared `MapSelectionController`; catalog/graph converge; Prism inspector + clear/no-selection proven; scoped analyze clean.
**Blockers**: none. Optional polish: page-level dual-origin widget smoke.
**Lane action**: stay `docs/tasks/03-review/`.

### 2026-07-17 — Independent drain re-review (reviewers / Batch 3)

- **Score**: `94/100`
- **Verdict**: `ACCEPTED_PATH_TO_100`
- **Lane**: `docs/tasks/04-completed/`
- **Report**: `docs/reports/review-wave-2026-07-17/task-0513-drain-review.md`
- **Note**: Selection channel solid. Residual: MapInspectorPanel tests vs AssetDetailView production dual path.


### 2026-07-18 — Path-to-100 independent re-review (reviewers / BATCH R2)
- **Score**: 98/100 — ACCEPTED_COMPLETE
- **Report**: `docs/reports/review-wave-2026-07-18/task-0513-path100-rereview.md`
- **path100_applied**: yes; residual path-to-100 list empty
- **Lane**: promoted to `docs/tasks/04-completed/`
- **Top finding**: Single selection channel; production universal detail path
