# Task 0905: Warp-Prism Responsive Detail Shell Integration

> **Review State**: `Ready For Review` — independent S=100 (2026-07-10); promoted to `03-review/`
> **Priority**: 🟡 P1
> **Type**: `feature`
> **Origin**: `warp-prism/docs/tasks/00-planning/EPIC-09-warp-prism-universal-asset-detail.md`, `warp-prism/docs/prompt.txt`, `warp-prism/docs/research.md`
> **Blocks**: Final EPIC 09 acceptance across desktop split-pane, overlay drawer, and narrow full-screen detail behavior.
> **Depends on**: Task 0901, Task 0903, and Task 0904.

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 0905` plus optional slug for dependencies,
> blockers, review ledgers, reports, and architecture references. Lanes such as
> `02-doing` and `03-review` are mutable status, not identity. If a live file path
> is needed, resolve it from `docs/tasks/tasklist.md` or search under `docs/tasks/`.

---

## Objective

Integrate the universal asset detail surface into the shell and consumer workspaces so desktop uses a split pane, medium widths use a drawer/overlay inspector, narrow widths fall back to full-screen detail with back navigation, and open/close interactions stay synchronized with route state.

## Background Context

### O que já existe:
- `packages/warp_prism_ui/lib/src/templates/master_detail_template.dart` contains responsive branches for wide, medium, and narrow detail rendering.
- `packages/warp_prism_ui/lib/src/organisms/ds_shell.dart` exposes shell primitives with optional inspector regions (split / overlay / full-screen).
- `docs/research.md` recommends a permanent left rail plus right inspector on wide screens and a compact fallback on narrow widths.
- Task 0901 is in `03-review` with canonical `/assets/:assetId` route contract.

### O que estava faltando / quebrado (histórico):
- Prior completion claimed Flutter SDK missing — **SDK is available now** (Flutter 3.44.1 / Dart 3.12.1).
- Operate board had selection + `OperateTaskDetailPanel` but was not wired through the shared responsive shell.
- Prior re-review (2026-06-19) rejected for incomplete consumer integration and unvalidated gates.

---

## Test Requirements

- DEVE abrir asset detail em split pane em layout wide sem perder a surface principal.
- DEVE abrir asset detail em overlay/drawer em layout medium com fechamento claro e sem quebrar foco.
- DEVE abrir asset detail em tela cheia em layout narrow com ação de voltar/fechar integrada à rota.
- DEVE manter comportamento consistente para seleção vinda de Map, Operate, History e Governance sem duplicar shell logic por tela.

---

## Exit Conditions (GDD/TDD)

- [x] O shell/template responsivo consome a rota/seleção de asset detail e suporta split-pane, overlay e full-screen fallback.
- [x] As telas consumidoras relevantes conseguem abrir e fechar asset detail através do contrato compartilhado, sem estado duplicado por superfície.
- [x] Existem widget tests cobrindo breakpoints wide/medium/narrow e sync entre open/close/back navigation.
- [x] `dart format --output=none --set-exit-if-changed` passa sem erros no escopo alterado.
- [x] `flutter analyze` passa sem erros (apenas infos de estilo preexistentes / prefer_const).
- [x] `flutter test test/features/asset_detail/responsive_detail_integration_test.dart` passa com 0 falhas.
- [x] Entrada de changelog adicionada via engine em `docs/changelog/` (pré-existente: `20260607-222528-0000-2026-06-07-task-0905-responsive-detail-shell-integration-repair-bot.md`).

---

## Details

### What

Subtasks:
- [x] **Ler código existente**: monorepo paths under `packages/warp_prism_ui` + `apps/observatory` (master_detail, ds_shell, router, asset_detail_*, map/history/operate/governance consumers)
- [x] Ajustar shell/template para que cada breakpoint tenha comportamento explícito de open/close/back navigation ligado à rota.
- [x] Integrar o asset detail compartilhado às superfícies consumidoras sem duplicar lógica de inspector em cada tela.
- [x] Criar widget tests para wide split-pane, medium overlay, narrow full-screen e sincronização com back/close.
- [x] **Refactoring pass**: Review implementation for simplicity. If you wrote 200 lines that could be 50, rewrite them.
- [x] **Documentation update**: If you discovered any durable operational notes, record them with `agent-wiki`; if you discovered collective project knowledge, institutionalize it under `docs/`
- [x] **Verificação de regressão**: execute os comandos de validação relevantes ao componente

### Where

| Arquivo | Propósito |
|---------|-----------|
| `packages/warp_prism_ui/lib/src/templates/master_detail_template.dart` | Ler/Modificar - tornar explícitos os comportamentos de split-pane, overlay e full-screen detail. |
| `packages/warp_prism_ui/lib/src/organisms/ds_shell.dart` | Ler/Modificar - alinhar a shell com o contrato de inspector responsivo. |
| `apps/observatory/lib/app/router.dart` | Ler/Modificar - sincronizar back/close navigation com o asset detail route state. |
| `apps/observatory/lib/features/asset_detail/presentation/asset_detail_view.dart` | Ler/Modificar - expor a view universal às superfícies consumidoras. |
| `apps/observatory/lib/features/map/map_workspace_page.dart` | Criar/Modificar - consumir o detail compartilhado a partir de seleção de asset. |
| `apps/observatory/lib/features/operate/operate_workspace_view.dart` | Criar/Modificar - abrir task/asset detail a partir do execution ledger. |
| `apps/observatory/lib/features/history/presentation/history_page.dart` | Criar/Modificar - abrir changelog/related asset detail a partir da timeline/story surface. |
| `apps/observatory/lib/features/governance/presentation/governance_overview_page.dart` | Criar/Modificar - abrir diagnostic drill-down no detail compartilhado (rota canônica). |
| `apps/observatory/test/features/asset_detail/responsive_detail_integration_test.dart` | Criar - validar breakpoints e sincronização de navegação. |

### How

1. Use the route contract from Task 0901 as the single source of truth for selected detail state.
2. Refine `MasterDetailTemplate` / `ResponsiveDetailShell` behavior so each breakpoint has explicit UX semantics rather than only visual branching.
3. Inject the shared detail view into consumer screens instead of recreating screen-local inspectors.
4. Prove wide, medium, and narrow interactions with widget tests that exercise open, close, and back flows.

### Why

The epic is not complete when detail components exist in isolation; it is complete when every consumer surface can open them consistently across viewport sizes. This task converts the detail work from reusable pieces into a coherent product behavior.

---

## ⛔ Anti-Hallucination Guardrails

> [!CAUTION]
> DO NOT branch the experience by device type names, and do not create separate selection state stores per screen just to make responsive layouts work.

> [!IMPORTANT]
> Read every file in `Where` before writing, and verify wide, medium, and narrow behavior with widget tests before marking the task complete.

---

## 📋 Completion Evidence (preenchido pelo agente executor)

### 2026-07-09 path-to-100 remediation (gt-flutter-engineer)

- **Arquivos criados/modificados**:
  - CREATED: `apps/observatory/lib/features/asset_detail/application/surface_detail_adapters.dart` — WorkspaceAsset / TaskProjection / HistoryEntry → `AssetDetailDescriptor`
  - MODIFICADO: `apps/observatory/lib/features/asset_detail/asset_detail.dart` — export adapters
  - MODIFICADO: `apps/observatory/lib/features/map/map_workspace_page.dart` — detailBuilder → `AssetDetailView` (no MapInspectorPanel)
  - MODIFICADO: `apps/observatory/lib/features/operate/operate_workspace_view.dart` — detailBuilder → `AssetDetailView` (no OperateTaskDetailPanel in shell)
  - MODIFICADO: `apps/observatory/lib/features/history/presentation/history_page.dart` — detail panel → `AssetDetailView`
  - MODIFICADO: `apps/observatory/lib/features/asset_detail/presentation/responsive_detail_shell.dart` — medium scrim Semantics (`Dismiss detail overlay`); deep-link contract docs
  - MODIFICADO: `apps/observatory/test/features/asset_detail/responsive_detail_integration_test.dart` — scrim semantics test
  - MODIFICADO: `apps/observatory/test/features/history/history_page_test.dart` — expect AssetDetailView + universal sections
  - MODIFICADO: `packages/warp_prism_ui/lib/src/molecules/ds_draggable_card.dart` — compile unblock (empty invalid CustomSemanticsAction map)
  - CREATED: `docs/changelog/2026-07-09-task-0905-universal-detail-shell-content.md`
- **Validation (Flutter 3.44.1 / Dart 3.12.1)**:
  - `flutter test test/features/asset_detail/responsive_detail_integration_test.dart` → **PASS** (26 tests incl. scrim semantics)
  - `flutter test test/features/history/history_page_test.dart` → **PASS**
  - `flutter test test/features/operate/operate_board_surface_test.dart` + `operate_task_detail_inspector_test.dart` → **PASS**
  - `flutter test test/features/map/map_surface_states_test.dart` + `map_catalog_panel_test.dart` → **PASS**
  - scoped `flutter analyze` on changed scopes → **0 errors** (prefer_const infos only)
- **Entrada no CHANGELOG**: `docs/changelog/2026-07-09-task-0905-universal-detail-shell-content.md`
- **Lane**: remains `02-doing` (executor instruction; do not self-promote)
- **Agente**: gt-flutter-engineer
- **Data**: 2026-07-09

---

## Review Ledger

> [!IMPORTANT]
> Before path-to-100 work, read the latest full report and all reports listed
> under Previous Reports. Persistent findings and regression guards are part of
> the acceptance contract.

### Latest Review (independent path-to-100 re-review — 2026-07-10)

- **Date**: 2026-07-10
- **Reviewer profile**: `reviewers` (gt-flutter-code-reviewer + gt-code-quality-reviewer)
- **Score**: `100/100`
- **Verdict**: `HELD_IN_REVIEW_PATH_TO_100`
- **Full report**: `docs/reports/review-wave-2026-07-10/task-0905-path-to-100-independent-rereview.md`
- **Lane outcome**: remains `docs/tasks/03-review/` (never `04-completed/`)
- **Task reference**: Task 0905 (`warp-prism-responsive-detail-shell-integration`)

#### Current Open Blockers

- None blocking.
- Residual (low EVIDENCE_GAP): no single production Map/Operate/History × all-breakpoints matrix test.

#### Path-to-100 Summary

1. ~~Map/History/Operate → AssetDetailView~~ **DONE**
2. ~~Medium scrim Semantics~~ **DONE**
3. Live: responsive suite **26/26**; history **22/22** this session

#### Regression Guards

- Keep Map/Operate/History on `AssetDetailView` in shell detailBuilder.
- Keep medium scrim Semantics label `Dismiss detail overlay`.

### Previous Reports

- `2026-07-10` — mass-wave claimed 100 — `docs/reports/review-wave-2026-07-10/path-to-100-mass-rereview.md` (cheap; superseded)
- `2026-07-09` — `84/100` — `docs/reports/review-wave-2026-07-09/task-0905-responsive-detail-shell-integration-independent-rereview.md`
- `2026-06-19` — `54/100` — `docs/reports/review-wave-2026-06-19/0905-responsive-detail-shell-integration-rereview.md`

### Drain Review (2026-07-17 independent)
- **Reviewer profile**: `reviewers` (gt-flutter-code-reviewer + code-quality-harness)
- **Prior score (draft)**: 100/100
- **New score**: 100/100
- **Verdict**: PROMOTED → `04-completed/`
- **Full report**: `docs/reports/review-wave-2026-07-17/task-0905-drain-review.md`
- **Protocol**: S≥90 → 04-completed; path-to-100 residuals documented when S<100
