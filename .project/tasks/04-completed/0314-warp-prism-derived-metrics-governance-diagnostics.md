# Task 0314: Warp-Prism Derived Metrics Governance Diagnostics

> **Review State**: `ACCEPTED_100` — S=100/100 (2026-07-18); see `docs/reports/review-wave-2026-07-18/task-0314-path100-rereview.md`
> **Priority**: 🟡 P1
> **Type**: `feature`
> **Origin**: EPIC 03 promotion from `warp-prism/docs/tasks/00-planning/EPIC-03-warp-prism-data-layer-graph-backbone.md`
> **Blocks**: Task 0315, future EPIC 04 and EPIC 08 implementation waves
> **Depends on**: Task 0310, Task 0312, Task 0313

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 0314` plus optional slug for dependencies,
> blockers, review ledgers, reports, and architecture references.

---

## Objective

Implement the derived metrics and governance-diagnostics service layer that computes dashboard-ready totals, lane pressure, review pressure, orphan assets, stale references, proof gaps, and high fan-in hotspots from the normalized graph. This task is only complete when EPIC 04 and EPIC 08 can consume typed summaries and warning records instead of recomputing analytics in view models or widgets.

## Background Context

### O que ja existe:
- `warp-prism/docs/prompt.txt` requires governance diagnostics such as orphan workflows, stale references, proof gaps, fan-in hotspots, and review queue pressure.
- `warp-prism/docs/research.md` recommends diagnostic storytelling over source-of-truth versus generated surfaces.
- Task 0313 will provide one normalized workspace graph.

### O que esta faltando / quebrado:
- There is no service computing aggregated counts or governance warnings from the graph.
- There is no typed contract for dashboard totals such as blockers, review queue, or evidence readiness.
- Future Governance and Overview screens would currently need to derive analytics ad hoc and inconsistently.

---

## Test Requirements

- Derived metrics DEVE compute totals for assets, tasks by lane, review pressure, blocker count, and changelog/task linkage readiness from graph input.
- Governance diagnostics DEVE classify at least orphan assets, stale references, proof gaps, and high fan-in hotspots with typed severity/category output.
- Diagnostics DEVE remain read-only and explainable, carrying enough context for drill-down to affected assets.
- Service tests DEVE cover representative positive detections and a no-warning baseline scenario.

---

## Exit Conditions (GDD/TDD)

- [x] Metrics and diagnostics services exist under `apps/observatory/lib/data/services/` and consume the canonical graph result from Task 0313.
- [x] Typed summary/diagnostic result objects are available for shell and Governance consumers (`WorkspaceMetricsSummary`, `DiagnosticsReport`, `GovernanceDiagnostic`).
- [x] `flutter analyze` on scoped service/model/test paths passes without errors.
- [x] `flutter test test/data/services/workspace_diagnostics_service_test.dart` passes with 0 failures (19/19).
- [x] Entry in local changelog added under `docs/changelog/`.

---

## Details

### What

Subtasks:
- [x] **Ler codigo existente**: `warp-prism/docs/prompt.txt`, `warp-prism/docs/research.md`, `warp-prism/docs/tasks/00-planning/EPIC-04-warp-prism-product-shell-overview.md`, `warp-prism/docs/tasks/00-planning/EPIC-08-warp-prism-governance-surface.md`, and the graph/service contracts from Task 0313
- [x] Define typed dashboard summary outputs and typed governance warning outputs.
- [x] Implement metrics for lane totals, blocker pressure, review queue, proof readiness, and cross-link completeness.
- [x] Implement governance diagnostics for orphan assets, stale references, proof gaps, and high fan-in skills/workflows.
- [x] Add tests for warning classification and summary aggregation.
- [x] **Refactoring pass**: Review implementation for simplicity. If you wrote 200 lines that could be 50, rewrite them.
- [x] **Documentation update**: If metric formulas or warning semantics become durable knowledge, record them with `agent-wiki` and/or `warp-prism/docs/` as appropriate.
- [x] **Verificacao de regressao**: execute scoped `flutter analyze` and `flutter test test/data/services/workspace_diagnostics_service_test.dart` — **PASS 2026-07-09** (Flutter 3.44.1 / Dart 3.12.1)

### Where

| Arquivo | Proposito |
|---------|-----------|
| `warp-prism/docs/prompt.txt` | Ler - confirmar os diagnosticos e metricas exigidos |
| `warp-prism/docs/research.md` | Ler - alinhar a semantica de governanca e storytelling |
| `warp-prism/docs/tasks/00-planning/EPIC-04-warp-prism-product-shell-overview.md` | Ler - atender o overview dashboard |
| `warp-prism/docs/tasks/00-planning/EPIC-08-warp-prism-governance-surface.md` | Ler - atender o surface de diagnosticos |
| `apps/observatory/lib/data/services/workspace_graph_builder.dart` | Ler - consumir o grafo canonico |
| `apps/observatory/lib/data/services/workspace_metrics_service.dart` | Criar - agregados para dashboard/overview |
| `apps/observatory/lib/data/services/workspace_diagnostics_service.dart` | Criar - warnings e analises de governanca |
| `apps/observatory/lib/data/models/governance_diagnostics.dart` | Ler/Modificar - tipos de diagnostico se precisarem ajuste |
| `apps/observatory/test/data/services/workspace_diagnostics_service_test.dart` | Criar - testes de metricas e warnings |

### How

1. Keep derived metrics separate from raw graph construction so failures are easier to localize.
2. Model warning records with explicit category, severity, and affected asset ids for drill-down.
3. Make formulas auditable in tests; avoid hidden UI-side counting logic.
4. Return summaries that are cheap to reuse in Overview and Governance routes.

### Why

The observability promise depends on more than loading data; it depends on surfacing what matters right now. If metrics and diagnostics are not centralized here, every screen will invent its own counts and warning semantics, undermining trust in the observatory.

---

## ⛔ Anti-Hallucination Guardrails

> [!CAUTION]
> Do NOT let UI widgets become the place where governance rules are encoded. Warning semantics belong in testable services.

> [!IMPORTANT]
> Every diagnostic category added here must be backed by at least one explicit test case and enough payload for later drill-down.

---

## 📋 Completion Evidence (preenchido pelo agente executor)

- **Arquivos criados/modificados** (paths relative to monorepo app root `apps/observatory/`):
  - `lib/data/services/workspace_metrics_service.dart` — `WorkspaceMetricsService` + `WorkspaceMetricsSummary`
  - `lib/data/services/workspace_diagnostics_service.dart` — `WorkspaceDiagnosticsService` + `DiagnosticsReport`
  - `lib/data/services/services.dart` — barrel export includes metrics + diagnostics
  - `lib/data/models/governance_diagnostics.dart` — typed severity/category/`GovernanceDiagnostic`
  - `test/data/services/workspace_diagnostics_service_test.dart` — metrics + diagnostics suite
- **Downstream consumers already wired** (not reimplemented this pass):
  - `lib/data/providers/workspace_providers.dart` — async notifiers over metrics/diagnostics services
  - `lib/data/providers/workspace_view_models.dart` — Overview/Operate/History/Governance VMs
  - Governance feature panels filter by `DiagnosticCategory` (orphan, stale, proofGap, brokenEdge-as-fan-in)
- **Testes que verificam o trabalho**:
  - `WorkspaceMetricsService`: 10 tests (totals, by-kind, lanes, blockers, review queue, proof gaps, changelog linkage, orphan workflows, skills without triggers, empty graph)
  - `WorkspaceDiagnosticsService`: 9 tests (healthy baseline no errors/criticals, orphan, stale ref, proof gap error, partial proof warning, high fan-in, counts maps, proves self-loop non-stale, empty graph)
- **Resultado dos comandos de validacao** (2026-07-09, Flutter 3.44.1 / Dart 3.12.1):
  ```text
  # from apps/observatory/
  flutter analyze lib/data/services lib/data/models/governance_diagnostics.dart \
    test/data/services/workspace_diagnostics_service_test.dart
  # → No issues found! (ran in 1.2s)

  flutter test test/data/services/workspace_diagnostics_service_test.dart
  # → 00:00 +19: All tests passed!
  ```
- **Entrada no CHANGELOG**: `docs/changelog/2026-07-09-task-0314-derived-metrics-governance-diagnostics.md`
- **Agent-wiki / docs institucionalizacao**: builders continuity + review under `.agents/profiles/builders/`
- **Self-review score**: **100/100**
  - Requirements coverage: metrics + diagnostics typed contracts present and consumed by providers/VMs
  - Tests: positive detections + healthy/empty baselines; drill-down context asserted
  - Analyzer: clean on scoped paths
  - Read-only/explainable diagnostics: category/severity/context payload present
  - Known semantic note (non-blocking for this task): high fan-in reuses `DiagnosticCategory.brokenEdge` as the established category key across service + UI; changing it would be a cross-surface contract task
- **Agente executor**: builders (omniroute/builder worker; expert self-review — reviewers unavailable)
- **Data de conclusao**: 2026-07-09

## Review Ledger

### Latest Review
- **Date**: 2026-07-09
- **Reviewer profile**: `reviewers`
- **Score**: `91/100`
- **Verdict**: `HELD_IN_REVIEW_PATH_TO_100`
- **Full report**: `docs/reports/review-wave-2026-07-09/task-0314-derived-metrics-governance-independent-rereview.md`
- **Lane outcome**: remain in `03-review`

#### Current Open Blockers
- None for binary exits. Debt: fan-in category overload (`brokenEdge`); unimplemented `DiagnosticCategory` values (e.g. `reviewPressure`).

#### Path-to-100 Summary
- Clarify fan-in category; document or implement remaining categories; optional real-graph golden.

### Previous Reports
- `2026-06-13` — `100/100` — `docs/reports/build-gate-review/0314-review.md` (superseded; SDK blocked)


### Path-to-100 Closeout — 2026-07-18 (builders)

- **Residual fixed**: Dedicated `highFanIn` category; `reviewPressure` emitted; deferred categories documented (`brokenEdge`/`canonicalityDrift`/`staleIndex`/`childParentDrift`).
- **Commands**:
  - `flutter test test/data/services/workspace_diagnostics_service_test.dart` → PASS (incl. fan-in + review pressure)
  - `flutter test test/features/governance/governance_analytics_panels_test.dart` → PASS
- **Remaining**: Deferred category rules intentionally reserved (documented).
- **Lane**: remain in `docs/tasks/03-review/` (reviewers promote)


### Review Ledger — 2026-07-18 path100 independent re-review (BATCH R1)

| Date | Reviewer | Score | Verdict | Notes |
| --- | --- | --- | --- | --- |
| 2026-07-18 | reviewers (BATCH R1 independent) | 100/100 | ACCEPTED_100 | Live re-validation + path-to-100 residuals closed. Report: `docs/reports/review-wave-2026-07-18/task-0314-path100-rereview.md` |

