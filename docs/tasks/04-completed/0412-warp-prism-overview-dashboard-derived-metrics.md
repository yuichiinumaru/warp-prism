# Task 0412: Warp Prism Overview Dashboard Derived Metrics

> **Status**: `[x]` Done — held in review (path-to-100)
> **Review State**: Independent re-review **91/100** — `HELD_IN_REVIEW_PATH_TO_100` (2026-07-09)
> **Priority**: 🔴 P0
> **Type**: `feature`
> **Origin**: EPIC-04 Warp Prism Product Shell and Overview
> **Blocks**: Task 0413
> **Depends on**: Task 0410, Task 0411, and EPIC-03 data/provider contract evidence

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 0412` plus optional slug for dependencies,
> blockers, review ledgers, reports, and architecture references. Lanes such as
> `02-doing` and `03-review` are mutable status, not identity. If a live file path
> is needed, resolve it from `docs/tasks/tasklist.md` or search under `docs/tasks/`.

---

## Objective

Build the Overview surface as the first real product page inside the shell, including derived metrics for agents, skills, sub-skills, workflows, task lanes, changelog entries, blockers, review queue pressure, governance warnings, and a “current story” panel backed by repository/provider state instead of hardcoded widget literals.

## Background Context

### O que já existe:
- `warp-prism/docs/prompt.txt` defines the exact Overview metrics and requires a current-story panel.
- Design-system primitives `PrismMetricTile` / `PrismStoryPanel` (via `warp_prism_ui`) expose UI primitives suitable for dashboard composition.
- `apps/observatory/lib/data/models/` and providers/services provide the repository/provider contract backbone.

### O que está faltando / quebrado:
- (Resolved) Overview feature, provider, and tests now exist under `apps/observatory/lib/features/overview/`.
- (Resolved 2026-07-09) Shell previously simulated empty assets; now wires to `workspaceSnapshotAsyncProvider` + diagnostics.

---

## Test Requirements

- The Overview MUST render metric groups for totals and operational risk using provider/repository data, not hardcoded counts embedded in widgets.
- The Overview MUST display task counts by lane and MUST expose at least blockers, review queue count, and governance warnings as separate observable values.
- The current-story panel MUST summarize the mock workspace using a structured view model or presenter input rather than static prose in the widget tree.
- The task MUST include widget or provider tests covering at least one non-empty dataset and one edge condition where counts drop to zero.
- The page MUST remain design-system-driven by composing existing metric/story primitives instead of bespoke dashboard styling.

---

## Exit Conditions (GDD/TDD)

- [x] A routed Overview page exists under `apps/observatory/lib/features/overview/` and is reachable from the shell (`/overview` via `OverviewPageShell`).
- [x] A repository/provider/view-model contract exists for derived Overview metrics (`OverviewProvider` + `OverviewMetrics`).
- [x] The Overview renders totals for agents, skills, sub-skills, workflows, tasks by lane, and changelog entries.
- [x] The Overview separately renders active blockers, review queue count, governance warnings, and a current-story panel.
- [x] Test coverage proves derived values are data-driven and handles at least one empty-or-zero edge case.
- [x] Scoped format: `dart format --set-exit-if-changed lib/features/overview/ lib/app/pages/overview_page.dart test/features/overview/` passes.
- [x] Scoped analyze: `dart analyze lib/features/overview/ lib/app/pages/overview_page.dart test/features/overview/` → No issues found.
- [x] Scoped tests: `flutter test test/features/overview/` → **18/18 passed**.
- [x] Changelog entry added: `docs/changelog/2026-07-09-task-0412-overview-dashboard-derived-metrics-path-to-100.md`.
- [~] Full changelog engine `validate` residual: pre-existing failure in `1302-public-barrel-audit.md` (missing `timestamp`) — **unrelated to Task 0412**.

---

## Details

### What

Subtasks:
- [x] **Ler o código existente antes de modificar**: read Task 0410/0411 outputs, data models, DS primitives, providers, and existing overview feature before writing.
- [x] Define the Overview repository/provider or presenter contract needed to compute required metrics from current mock workspace data.
- [x] Create the routed Overview page and compose metric tiles, lane summaries, and the current-story panel.
- [x] Add tests for derived metrics and at least one zero-data edge case.
- [x] Wire shell to real workspace providers (no simulated empty-only path in production).
- [x] **Refactoring pass**: keep the metric derivation logic outside the widget tree.
- [x] **Documentation update**: local changelog + builders continuity entry.
- [x] **Verificação de regressão**: scoped format, analyze, and Flutter tests green.

### Where

| Arquivo | Propósito |
|---------|-----------|
| `apps/observatory/lib/app/router.dart` | Wire the Overview page into the routed shell. |
| `apps/observatory/lib/data/models/` | Model vocabulary for dashboard derivation. |
| `apps/observatory/lib/data/providers/workspace_providers.dart` | Snapshot/diagnostics providers consumed by shell. |
| `apps/observatory/lib/features/overview/` | Overview page, provider, and metrics contract. |
| `apps/observatory/lib/app/pages/overview_page.dart` | Shell bridge: ConsumerWidget over workspace providers. |
| `packages/warp_prism_ui` | PrismMetricTile / PrismStoryPanel primitives. |
| `apps/observatory/test/features/overview/` | Provider, page, and shell tests. |

### How

1. Metrics list mapped to `WorkspaceAsset` kind counts + `TaskMetadata` lane/blocker fields + diagnostics severity weights.
2. Derivation stays in `OverviewProvider.compute`.
3. Shell watches Riverpod providers and feeds `OverviewPage(metrics: ...)`.
4. Tests cover non-empty, empty, blockers, gov warnings, story panel, and shell forced states.

### Why

Overview is the first proof that the observatory explains what exists and what matters now. Hardcoded numbers or widget-local logic would poison later surfaces.

---

## ⛔ Anti-Hallucination Guardrails

> [!CAUTION]
> Do not hardcode fake metric totals just to make the dashboard look complete.

> [!CAUTION]
> Do not bury derivation logic inside `build()` methods where later screens cannot reuse or test it.

> [!IMPORTANT]
> If EPIC-03 data gaps block one of the required metrics, document the exact missing contract and leave the task open rather than silently degrading the requirement.

---

## 📋 Completion Evidence (preenchido pelo agente executor)

- **Arquivos criados/modificados (2026-07-09 path-to-100)**:
  - `apps/observatory/lib/app/pages/overview_page.dart` — rewired as ConsumerWidget over workspace providers
  - `apps/observatory/test/features/overview/overview_shell_test.dart` — shell wiring tests
  - `apps/observatory/test/features/overview/overview_provider_test.dart` — analyzer info cleanup
  - Prior feature surface (already present): `overview_metrics.dart`, `overview_provider.dart`, `overview_page.dart`, `overview.dart`, provider/page tests
- **Testes que verificam o trabalho**:
  - `overview_provider_test.dart`: non-empty totals, edges, empty zero-fill, P0 blockers, P0 complete not blocker, gov warnings, story panel, equality
  - `overview_page_test.dart`: totals, lanes, operational risk, story, zero-data
  - `overview_shell_test.dart`: forced metrics, loading, error, zero-metrics structure
- **Resultado dos comandos de validação** (from `apps/observatory/`):
  - `dart format --set-exit-if-changed lib/features/overview/ lib/app/pages/overview_page.dart test/features/overview/` → pass
  - `dart analyze lib/features/overview/ lib/app/pages/overview_page.dart test/features/overview/` → No issues found
  - `flutter test test/features/overview/ --reporter compact` → **All tests passed! (18)**
- **Entrada no CHANGELOG**: `docs/changelog/2026-07-09-task-0412-overview-dashboard-derived-metrics-path-to-100.md`
- **Agent-wiki**: builders continuity entry for Task 0412 path-to-100
- **Self-score**: **100/100** (builder expert self-review) — superseded by independent ledger below
- **Agente executor**: builders (omniroute/builder)
- **Data de conclusão**: 2026-07-09

---

## Review Ledger

> [!IMPORTANT]
> Before path-to-100 work, read the latest full report and all reports listed
> under Previous Reports.

### Latest Review

- **Date**: 2026-07-09
- **Reviewer profile**: `reviewers`
- **Score**: `91/100`
- **Verdict**: `HELD_IN_REVIEW_PATH_TO_100`
- **Full report**: `docs/reports/review-wave-2026-07-09/task-0412-overview-dashboard-derived-metrics-independent-rereview.md`
- **Lane outcome**: remains in `03-review`
- **Task reference**: Task 0412 (`warp-prism-overview-dashboard-derived-metrics`)

#### Current Open Blockers

- `NEW` / Low: 3 analyzer infos (`overview_provider.dart` / provider tests).
- `NEW` / Low: Shell widget tests use force-* only; production AsyncValue path untested.

#### Path-to-100 Summary

- Clean 3 analyzer infos (unnecessary imports + `_asset` rename).
- One shell test with `workspaceSnapshotAsyncProvider` override (data + error).
- **Regression guard**: metrics stay in `OverviewProvider.compute`, not widget literals.

### Previous Reports

- `2026-06-19` — prior independent — `docs/reports/review-wave-2026-06-19/0412-overview-dashboard-derived-metrics-independent-review.md`
- `2026-06-14` — `100/100` — `docs/reports/build-gate-review/0412-review.md` (superseded; SDK blocked)


### 2026-07-18 — Path-to-100 independent re-review (reviewers / BATCH R2)
- **Score**: 98/100 — ACCEPTED_COMPLETE
- **Report**: `docs/reports/review-wave-2026-07-18/task-0412-path100-rereview.md`
- **path100_applied**: yes; residual path-to-100 list empty
- **Lane**: promoted to `docs/tasks/04-completed/`
- **Top finding**: Provider-path proof complete; forced* only dual harness residual
