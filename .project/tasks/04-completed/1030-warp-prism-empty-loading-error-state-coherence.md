# Task 1030: Warp-Prism Empty, Loading, and Error State Coherence

> **Review State**: `Ready For Review` — independent S=100 (2026-07-10); promoted to `03-review/`
> **Priority**: 🟡 P1
> **Type**: `feature`
> **Origin**: EPIC 10 candidate story "Empty/loading/error state pass" plus prompt requirements for clear status handling
> **Blocks**: Task 1060
> **Depends on**: Task 1000

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1030` plus optional slug for dependencies,
> blockers, review ledgers, reports, and architecture references. Lanes such as
> `02-doing` and `03-review` are mutable status, not identity. If a live file path
> is needed, resolve it from `docs/tasks/tasklist.md` or search under `docs/tasks/`.

---

## Objective

Standardize how the observatory communicates no data, loading work, and parser/runtime failure so the demo never falls back to blank panels, ambiguous emptiness, or disconnected one-off error copy across boards, graph hosts, detail inspectors, and story surfaces.

## Background Context

### O que ja existe:
- `warp-prism/lib/design_system/organisms/ds_lane_board.dart` already contains a minimal `_EmptyLane` view.
- `warp-prism/lib/design_system/organisms/ds_story_panel.dart` and `warp-prism/lib/design_system/organisms/ds_detail_inspector.dart` are likely hosts for guided status communication when data is partial or absent.
- `warp-prism/lib/data/parsers/workspace_parser.dart` is the data entry point most likely to surface parse errors or missing content once the mock workspace is loaded.

### O que esta faltando / quebrado:
- There is no shared state component or explicit contract for loading, empty, and error rendering across the design system.
- The current empty state in the lane board is localized and not obviously reusable for graph, inspector, or story surfaces.
- No tests prove that parser failures or empty datasets surface user-readable state instead of silent nothingness.

---

## Test Requirements

- DEVE fornecer um padrao reutilizavel para `loading`, `empty` e `error` nos hosts alterados por esta task.
- DEVE exibir uma mensagem acionavel ou contextual, nao apenas icone ou espaco vazio, em cada estado tratado.
- DEVE ter pelo menos um teste automatizado cobrindo os tres estados no componente compartilhado ou na primeira integracao que o usar.

---

## Exit Conditions (GDD/TDD)

- [x] Componente ou contrato compartilhado de state rendering criado e usado nos hosts priorizados pelo baseline
- [x] Estados de parser/empty/error conectados a pelo menos board, inspector ou story host reais
- [x] Teste de regressao criado para loading/empty/error states
- [x] Scoped analyze: `cd packages/warp_prism_ui && flutter analyze lib/src/molecules/ds_state_surface.dart` — No issues found
- [x] Scoped test: `cd packages/warp_prism_ui && flutter test test/state_surface_test.dart` — 26/26 passed
- [x] Path note: monorepo migration relocated surfaces from root `lib/`/`test/` to `packages/warp_prism_ui/`
- [x] Entrada de changelog adicionada via engine em `docs/changelog/`

---

## Details

### What

Subtasks:
- [x] **Ler codigo existente**: `warp-prism/docs/reports/epic-10-polish-baseline.md`, `warp-prism/lib/data/parsers/workspace_parser.dart`, `warp-prism/lib/data/models/models.dart`, `warp-prism/lib/design_system/molecules/molecules.dart`, `warp-prism/lib/design_system/organisms/ds_lane_board.dart`, `warp-prism/lib/design_system/organisms/ds_graph_canvas.dart`, `warp-prism/lib/design_system/organisms/ds_story_panel.dart`, `warp-prism/lib/design_system/organisms/ds_detail_inspector.dart`
- [x] Criar um padrao compartilhado de state surface que sirva para loading, empty e error sem duplicar copy e layout basico em cada organism
- [x] Integrar o padrao aos hosts mais relevantes do demo identificados pelo Task 1000
- [x] Adicionar teste dedicado cobrindo os tres estados e as mensagens essenciais
- [x] **Refactoring pass**: Review implementation for simplicity. If you wrote 200 lines that could be 50, rewrite them.
- [x] **Documentation update**: If you discovered any durable operational notes, record them with `agent-wiki`; if you discovered collective project knowledge, institutionalize it under `docs/`
- [x] **Verificacao de regressao**: Flutter SDK present (3.44.1). Scoped analyze + `state_surface_test.dart` PASS (2026-07-09). Stale "SDK not installed" blocker cleared.

### Where

| Arquivo | Proposito |
|---------|-----------|
| `warp-prism/docs/reports/epic-10-polish-baseline.md` | Ler - escolher os hosts de maior prioridade |
| `warp-prism/lib/data/parsers/workspace_parser.dart` | Ler / Modificar - origem de erros ou dados ausentes |
| `warp-prism/lib/data/models/models.dart` | Ler / Modificar - contratos para representar estado quando necessario |
| `warp-prism/lib/design_system/molecules/molecules.dart` | Ler / Modificar - export do componente compartilhado |
| `warp-prism/lib/design_system/molecules/ds_state_surface.dart` | Criar - componente reutilizavel de loading/empty/error |
| `warp-prism/lib/design_system/organisms/ds_lane_board.dart` | Ler / Modificar - substituir `_EmptyLane` local por contrato comum quando couber |
| `warp-prism/lib/design_system/organisms/ds_graph_canvas.dart` | Ler / Modificar - estado sem dados/erro do graph host |
| `warp-prism/lib/design_system/organisms/ds_story_panel.dart` | Ler / Modificar - fallback narrativo quando faltarem insights |
| `warp-prism/lib/design_system/organisms/ds_detail_inspector.dart` | Ler / Modificar - estado vazio/erro do inspector |
| `warp-prism/test/design_system/state_surface_test.dart` | Criar - regressao dos tres estados |

> **Live monorepo paths (post-migration)**:
> - `packages/warp_prism_ui/lib/src/molecules/ds_state_surface.dart`
> - `packages/warp_prism_ui/test/state_surface_test.dart`

### How

1. Introduce one shared state surface rather than ad hoc empty/error blocks in each organism.
2. Keep the copy terse and domain-specific so the observatory still feels like a serious console.
3. Wire parser or data-host failures into that surface where practical instead of swallowing them.
4. Test the shared contract directly so later host adoption is cheap and safe.

### Why

EPIC 10 is explicitly about coherence. Inconsistent state handling breaks comprehension faster than missing chrome because users cannot tell whether the system is loading, empty, or actually broken.

---

## ⛔ Anti-Hallucination Guardrails

> [!CAUTION]
> Do not replace every missing-state nuance with the same generic message; loading, empty, and error must remain semantically distinct.

> [!IMPORTANT]
> Prefer reusing one state surface contract over scattering one-off fallback widgets across organisms.

---

## 📋 Completion Evidence (preenchido pelo agente executor)

### 2026-07-09 path-to-100 remediation (gt-flutter-engineer)

- **Arquivos modificados (F2 fix)**:
  - `apps/observatory/lib/features/map/widgets/map_state_panel.dart` — error/noResults only wire action when callback non-null
  - `apps/observatory/lib/features/map/widgets/map_no_results_state.dart` — remove `onClearFilters ?? () {}`
  - `apps/observatory/test/features/map/map_surface_states_test.dart` — null action → no Retry; real action invokes
  - `apps/observatory/test/features/map/map_catalog_panel_test.dart` — null Clear → no button
  - `docs/changelog/2026-07-09-task-1030-noop-action-removal.md`
- **Prior shared surface (unchanged, still green)**:
  - `packages/warp_prism_ui/lib/src/molecules/ds_state_surface.dart`
  - `packages/warp_prism_ui/test/state_surface_test.dart` — **35** tests (live count)
- **Validation (2026-07-09)**:
  - Flutter 3.44.1 / Dart 3.12.1
  - `flutter test test/features/map/map_surface_states_test.dart` → **PASS**
  - `flutter test test/features/map/map_catalog_panel_test.dart` → **PASS**
  - `cd packages/warp_prism_ui && flutter test test/state_surface_test.dart` → **35/35 PASS**
- **Entrada no CHANGELOG**: `docs/changelog/2026-07-09-task-1030-noop-action-removal.md`
- **Lane**: remains `02-doing` (executor instruction; do not self-promote)
- **Residual (optional F3)**: parser/repository → UI error-surface E2E still optional per path-to-100
- **Agente**: gt-flutter-engineer
- **Data**: 2026-07-09

---

## Review Ledger

> [!IMPORTANT]
> Before path-to-100 work, read the latest full report and all reports listed
> under Previous Reports. Persistent findings and regression guards are part of
> the acceptance contract; do not fix the latest finding by undoing a previously
> accepted repair.

### Latest Review (independent path-to-100 re-review — 2026-07-10)

- **Date**: 2026-07-10
- **Reviewer profile**: `reviewers` (gt-flutter-code-reviewer + gt-code-quality-reviewer)
- **Score**: `100/100`
- **Verdict**: `HELD_IN_REVIEW_PATH_TO_100`
- **Full report**: `docs/reports/review-wave-2026-07-10/task-1030-path-to-100-independent-rereview.md`
- **Lane outcome**: remains `docs/tasks/03-review/` (never `04-completed/`)
- **Task reference**: Task 1030 (`warp-prism-empty-loading-error-state-coherence`)

#### Current Open Blockers

- None blocking.
- Residual (optional): parser/repository → UI error-surface E2E still unproven.

#### Path-to-100 Summary

1. ~~Remove no-op Retry/Clear fallbacks~~ **DONE**
2. ~~Null action hides affordance (tests)~~ **DONE**
3. Live: package state_surface **35/35**; map surface/catalog null-action proofs this session

#### Regression Guards

- Never install `onAction ?? () {}` / `onClearFilters ?? () {}` no-ops.
- Keep History on `PrismStateSurface.loading/error/empty`.
- Package contract: null `onAction` hides button.

### Previous Reports

- `2026-07-10` — mass-wave claimed 100 — `docs/reports/review-wave-2026-07-10/path-to-100-mass-rereview.md` (cheap; superseded)
- `2026-07-09` — `89/100` — `docs/reports/review-wave-2026-07-09/task-1030-state-coherence-independent-rereview.md`
- `2026-06-17` — `84/100` — `docs/reports/review-wave-2026-06-17/task-1030-review.md`

### Drain Review (2026-07-17 independent)
- **Reviewer profile**: `reviewers` (gt-flutter-code-reviewer + code-quality-harness)
- **Prior score (draft)**: 100/100
- **New score**: 100/100
- **Verdict**: PROMOTED → `04-completed/`
- **Full report**: `docs/reports/review-wave-2026-07-17/task-1030-drain-review.md`
- **Protocol**: S≥90 → 04-completed; path-to-100 residuals documented when S<100
