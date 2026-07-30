# Review Report: Task 0812 — Governance Fan-In And Review Pressure Analytics — 2026-06-19

## Review Lineage

- **Current task**: Task 0812 (`0812-warp-prism-governance-fanin-review-pressure-analytics`); live path resolved from filesystem search under `docs/tasks/`.
- **Previous reports read**:
  - `docs/reports/build-gate-review/0812-review.md` — claimed `100/100`, approved, but noted changelog pending.
- **Related reports considered**:
  - `docs/reports/build-gate-review/0810-review.md`, `0811-review.md`, `0813-review.md` — adjacent Governance route/story chain.
  - Task 0314 ledger in `docs/tasks/02-doing/0314-warp-prism-derived-metrics-governance-diagnostics.md` — dependency currently rejected to doing at `52/100` and explicitly calls out high fan-in category misuse.
- **Review mode**: `re-review`.

## Score And Verdict

- **Score**: `42/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Lane recommendation**: `return-to-doing`

## Axiom Compliance

| Axiom | Status | Evidence |
| --- | --- | --- |
| Analyzer Integrity | FAIL | `flutter analyze --no-pub` found **378 issues**, including Task 0812 test lint issues at `governance_analytics_panels_test.dart:97`, `:107`, `:122`, `:129`, `:136`, `:144`, `:164`, `:181`, `:243`, `:250`, `:276`, `:280`, `:304`, `:322`, `:329`. |
| Lifecycle Safety | PASS | Task 0812 production files create **0** controllers/subscriptions/timers/listeners and contain **0** `dispose()` methods. |
| Dependency Direction | FAIL | UI analytics encode/extract fan-in and review-pressure semantics from raw diagnostic categories/context in presentation files (`fan_in_hotspots_panel.dart:45-67`, `review_pressure_panel.dart:30-65`), despite the task requiring diagnostics-service-backed analytics. |
| UI Accessibility | PARTIAL | Task 0812 production interactive widgets: **0**. Semantics widgets: **0**. Rows are non-interactive but rely on color-coded severity/ranking without explicit semantics. |
| Proof Reality | FAIL | Focused governance test run produced **80 tests, 1 failure**. The failing test is Task 0812's `renders lane breakdown chips` at `governance_analytics_panels_test.dart:341`. Changelog is pending and no `docs/changelog/*0812*.md` exists. |
| Release Security | PASS | No release config, secrets, permissions, `print`, or `debugPrint` in Task 0812 production files. |

## Delta Summary

### Resolved Since Previous Review
- `RESOLVED`: Flutter SDK is available locally for this review.

### Persistent Findings
- `PERSISTENT`: Prior report line 62 marked changelog pending; live filesystem still has **0** Task 0812 changelog files.
- `PERSISTENT`: Analyzer gate is not clean.

### Regressions
- `REGRESSION`: Previous report accepted test coverage; live focused run proves Task 0812 test file has **1** failing test.

### New Findings
- `NEW`: Fan-in hotspots are still classified as `DiagnosticCategory.brokenEdge`, exactly the Task 0314 re-review blocker.
- `NEW`: Analytics panels are not rendered by the production Governance route/page.
- `NEW`: `ReviewPressureIndicator.fromDiagnostics` derives review pressure from proof gaps rather than `DiagnosticCategory.reviewPressure`, so Governance and Operate can diverge.

### Evidence Gaps / External Blockers
- `EVIDENCE_GAP`: Task 0314 dependency is rejected to doing and its high-fan-in diagnostic contract is unresolved.

## Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | PERSISTENT | CRITICAL | Open | High fan-in hotspots are encoded as `DiagnosticCategory.brokenEdge`, conflating a healthy centrality/hotspot signal with invalid graph edges. This is already an open Task 0314 blocker. | 2026-06-18 | `apps/observatory/lib/data/services/workspace_diagnostics_service.dart:274-284`; `apps/observatory/lib/features/governance/presentation/widgets/fan_in_hotspots_panel.dart:49-52`; `docs/tasks/02-doing/0314-warp-prism-derived-metrics-governance-diagnostics.md:139`, `:145` |
| F2 | REGRESSION | CRITICAL | Open | Task 0812's own focused test suite fails: `renders lane breakdown chips` expects one `04-completed` widget but finds two. | 2026-06-19 | `apps/observatory/test/features/governance/governance_analytics_panels_test.dart:320-341`; command output from `flutter test --no-pub ...governance...` |
| F3 | NEW | CRITICAL | Open | Analytics panels are dead runtime code. `/governance` creates only `GovernanceOverviewPage`, which never imports/renders `FanInHotspotsPanel` or `ReviewPressurePanel`. | 2026-06-19 | `apps/observatory/lib/app/router.dart:83-84`; `apps/observatory/lib/features/governance/presentation/governance_overview_page.dart:78-100`; grep found production references only in declarations/imports/tests |
| F4 | NEW | MODERATE | Open | Review-pressure analytics are derived from `DiagnosticCategory.proofGap` instead of the typed `reviewPressure` category, contradicting the model's own category vocabulary and task requirement for lane/status diagnostics. | 2026-06-19 | `apps/observatory/lib/data/models/governance_diagnostics.dart:41-42`; `apps/observatory/lib/features/governance/presentation/widgets/review_pressure_panel.dart:30-40` |
| F5 | PERSISTENT | MODERATE | Open | Changelog is missing despite an exit condition requiring it. | 2026-06-13 | `docs/tasks/03-review/0812-warp-prism-governance-fanin-review-pressure-analytics.md:52`, `:114`; `docs/reports/build-gate-review/0812-review.md:62`; glob `docs/changelog/*0812*.md` returned **0** files |
| F6 | PERSISTENT | MODERATE | Open | Analyzer integrity is not satisfied: **378** issues. | 2026-06-13 | command output: `flutter analyze --no-pub` |

## Evidence Reviewed

- Task file: `docs/tasks/03-review/0812-warp-prism-governance-fanin-review-pressure-analytics.md`.
- Previous report: `docs/reports/build-gate-review/0812-review.md`.
- Source/test files: `fan_in_hotspots_panel.dart`, `review_pressure_panel.dart`, `governance_analytics_panels_test.dart`, `governance_overview_page.dart`, `router.dart`, `workspace_diagnostics_service.dart`, `workspace_view_models.dart`, `governance_diagnostics.dart`.
- Runtime wiring proof: `/governance` route is `const GovernanceOverviewPage()` at `router.dart:83-84`. `GovernanceOverviewPage` does not render Task 0812 widgets. `grep` found `FanInHotspotsPanel` and `ReviewPressurePanel` only in declarations/tests, not in the production route tree.
- Hardcoded/diagnostic count check: widget classes accept caller-provided lists and compute summaries in presentation (`ReviewPressureSummary.fromIndicators`, `FanInHotspot.fromDiagnostics`). The service still emits hotspot diagnostics as `brokenEdge`, not a dedicated hotspot category.
- Commands run:
  - `flutter --version` — PASS.
  - `dart --version` — PASS.
  - `flutter analyze --no-pub && flutter test --no-pub ...governance...` — FAIL at analyzer, **378** issues.
  - `flutter test --no-pub test/features/governance/governance_boundaries_overview_test.dart test/features/governance/governance_issue_panels_test.dart test/features/governance/governance_analytics_panels_test.dart test/features/governance/governance_drilldown_storytelling_test.dart` — FAIL, **80 tests run**, **79 passed**, **1 failed** in Task 0812.
- Commands not run and why: full package test suite not run because focused governance suite already failed.

## Path To 100

1. Fix Task 0314 first: add a dedicated high-fan-in diagnostic category/DTO and update `WorkspaceDiagnosticsService`, `GovernanceViewModel.hotspotCount`, `FanInHotspot.fromDiagnostics`, and tests away from `brokenEdge`.
2. Add real review-pressure diagnostics or service DTOs from lane/status data; do not derive queue pressure in UI from proof-gap diagnostics.
3. Wire `FanInHotspotsPanel` and `ReviewPressurePanel` into the production Governance page with route-level fixture/provider tests.
4. Fix the failing `governance_analytics_panels_test.dart:341` assertion or UI duplication so the focused test command passes.
5. Add the missing Task 0812 changelog entry and clear analyzer issues in the touched tests/source.

## Task Ledger Patch Suggestion

```markdown
---

## Review Ledger

> [!IMPORTANT]
> Before path-to-100 work, read the latest full report and all reports listed
> under Previous Reports. Persistent findings and regression guards are part of
> the acceptance contract; do not fix the latest finding by undoing a previously
> accepted repair.

### Latest Review

- **Date**: 2026-06-19
- **Reviewer profile**: `reviewers`
- **Score**: `42/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Full report**: `docs/reports/review-wave-2026-06-19/0812-governance-fanin-review-pressure-analytics-review.md`
- **Lane outcome**: `returned to doing`
- **Task reference**: Task 0812 (`0812-warp-prism-governance-fanin-review-pressure-analytics`)

#### Current Open Blockers

- `PERSISTENT`: high fan-in uses `DiagnosticCategory.brokenEdge` instead of a hotspot-specific contract.
- `REGRESSION`: focused Task 0812 test fails at `governance_analytics_panels_test.dart:341`.
- `NEW`: analytics panels are not wired into `/governance` runtime.
- `NEW`: review pressure is derived from proof gaps in presentation code.
- `PERSISTENT`: changelog missing and analyzer reports **378** issues.

#### Path-to-100 Summary

- Repair Task 0314 hotspot/review-pressure contracts first.
- Wire analytics panels into Governance route.
- Fix failing analytics test, changelog, and analyzer evidence.

### Previous Reports

- `2026-06-13` — `100/100` — `docs/reports/build-gate-review/0812-review.md`
  - **Carried forward**: analyzer/changelog evidence gaps.
  - **Resolved since**: Flutter SDK is available locally.
  - **Regression guard**: hotspot analytics must not be represented as broken-edge diagnostics.
```
