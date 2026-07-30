# Review Report: Task 0412 — Overview Dashboard Derived Metrics — 2026-06-19

## Review Lineage

- **Current task**: Task 0412 (`0412-warp-prism-overview-dashboard-derived-metrics`); live path reviewed at `docs/tasks/03-review/0412-warp-prism-overview-dashboard-derived-metrics.md` before lane routing.
- **Previous reports read**:
  - `docs/reports/build-gate-review/0412-review.md` — claimed `100/100`, approved with Flutter SDK unavailable.
  - `docs/reports/review-wave-2026-06-19/0410-app-root-router-shell-skeleton-independent-review.md` — current upstream route rejection.
  - `docs/reports/review-wave-2026-06-19/0411-shell-navigation-responsive-frame-independent-review.md` — current upstream shell rejection.
  - `docs/reports/review-wave-3/0011-review.md` via Task 0011 ledger — `68/100`, rejected bootstrap prerequisite.
- **Related reports considered**:
  - `docs/reports/build-gate-review/0410-review.md`, `0411-review.md`, `0413-review.md` — shared EPIC-04 runtime path.
  - `docs/reports/warp-prism-task-gap-overlap-audit.md` — Overview metrics should be backed by EPIC-03 provider/diagnostic contracts.
- **Review mode**: re-review / independent runtime-wiring audit.

## Score And Verdict

- **Score**: `62/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Lane recommendation**: `return-to-doing`

## Axiom Compliance

| Axiom | Status | Evidence |
| --- | --- | --- |
| Analyzer Integrity | FAIL | Scoped analyzer returned `29 issues found`; Task 0412-owned issues include unused import in `apps/observatory/lib/features/overview/overview_page.dart:12`, unnecessary import in `overview_provider.dart:13`, and task test issues in `test/features/overview/overview_provider_test.dart:12` and `:22`. Full package analyze returned `378 issues found`. |
| Lifecycle Safety | PASS | Task 0412 core files create `0` controllers, `0` subscriptions, `0` timers, `0` listeners, and need `0` disposals. `OverviewPageShell` creates no disposable resource and performs a mounted check after async delay (`apps/observatory/lib/app/pages/overview_page.dart:45-52`). |
| Dependency Direction | PARTIAL | Overview model/provider are app feature code importing data models only (`overview_provider.dart:12-14`). However, runtime page integration is under `app/pages/overview_page.dart`, and it does not use repository/provider load state despite the task requirement. |
| UI Accessibility | PARTIAL | `OverviewPage` has `13` metric tiles (`5` totals, `5` lane, `3` risk) rendered through `DSMetricTile`, whose package implementation wraps each tile in `Semantics` (`packages/warp_prism_ui/lib/src/molecules/ds_metric_tile.dart:47-50`). Story panel rows are visual/text but have no explicit task-owned semantics. Interactive elements in Task 0412 files: `0`. |
| Proof Reality | FAIL | The Overview is not backed by live repository/provider state. Runtime `OverviewPageShell` always computes metrics from `assets: const []` after a hardcoded 300 ms delay (`apps/observatory/lib/app/pages/overview_page.dart:45-55`), so task claims of repository/provider-backed metrics are false. |
| Release Security | PASS | Reviewed Task 0412 files add no secrets, endpoints, release config, `print()`, or `debugPrint()` calls. |

## Delta Summary

### Resolved Since Previous Review

- `RESOLVED`: Targeted Overview tests run and pass: `overview_provider_test.dart` plus `overview_page_test.dart` are included in the `48/48` passing targeted test set.
- `RESOLVED`: Metrics derivation is at least unit-testable as a pure `OverviewProvider.compute()` contract.

### Persistent Findings

- `PERSISTENT`: Upstream shell/router startup failures from Tasks 0410 and 0411 remain open.
- `PERSISTENT`: Previous report's Flutter-SDK-unavailable statement is stale.

### Regressions

- `REGRESSION`: None proven against a clean previously accepted runtime state.

### New Findings

- `NEW`: Runtime Overview page uses hardcoded empty data (`assets: const []`), violating Task 0412's provider/repository-backed requirement.
- `NEW`: Analyzer integrity fails in task-owned files.

### Evidence Gaps / External Blockers

- `EVIDENCE_GAP`: No test proves `OverviewPageShell` consumes `workspaceSnapshotProvider`, `workspaceAssetsProvider`, repository state, or any actual mock workspace asset list.
- `EXTERNAL_BLOCKER`: None.

## Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | NEW | High | Open | Overview runtime is helper-only/demo-loaded: it computes from `assets: const []`, so production shell always shows zero metrics instead of repository/provider data. | 2026-06-19 | `apps/observatory/lib/app/pages/overview_page.dart:45-55` |
| F2 | PERSISTENT | High | Open | Upstream Task 0410/0411 shell route proof is rejected, blocking final acceptance of the routed Overview surface. | 2026-06-19 | `docs/reports/review-wave-2026-06-19/0410-app-root-router-shell-skeleton-independent-review.md`; `0411-shell-navigation-responsive-frame-independent-review.md` |
| F3 | NEW | Moderate | Open | Analyzer fails on task-owned overview files/tests. | 2026-06-19 | `apps/observatory/lib/features/overview/overview_page.dart:12`; `apps/observatory/lib/features/overview/overview_provider.dart:13`; `apps/observatory/test/features/overview/overview_provider_test.dart:12` |
| F4 | EVIDENCE_GAP | Moderate | Open | Tests prove `OverviewProvider.compute()` with synthetic lists, but not runtime repository/provider wiring. | 2026-06-19 | `apps/observatory/test/features/overview/overview_provider_test.dart:22-40`; `apps/observatory/lib/app/pages/overview_page.dart:31-63` |

## Evidence Reviewed

- **Task file**: `docs/tasks/03-review/0412-warp-prism-overview-dashboard-derived-metrics.md`.
- **Source/test files**: `apps/observatory/lib/features/overview/overview_metrics.dart`, `overview_provider.dart`, `overview_page.dart`, `overview.dart`, `apps/observatory/lib/app/pages/overview_page.dart`, `apps/observatory/lib/app/router.dart`, `test/features/overview/overview_provider_test.dart`, `overview_page_test.dart`.
- **Runtime wiring proof**: `appRouter` routes `/overview` to `OverviewPageShell` (`apps/observatory/lib/app/router.dart:46-49`). `OverviewPageShell` calls `_simulateLoad()` in `initState()` (`app/pages/overview_page.dart:38-42`), waits `300 ms`, and computes `OverviewProvider.compute(assets: const [])` (`:45-55`). Therefore the changed Overview UI is runtime-wired, but its data source is a hardcoded empty list, not the live repository/provider path.
- **Commands run**:
  - `dart format --set-exit-if-changed lib/app lib/features/overview lib/features/shell test/app/app_shell_smoke_test.dart test/app/shell_responsive_layout_test.dart test/features/overview test/features/shell test/app/deep_link_fallback_test.dart` — PASS, `22 files (0 changed)`.
  - `flutter analyze lib/app lib/features/overview lib/features/shell test/app/app_shell_smoke_test.dart test/app/shell_responsive_layout_test.dart test/app/deep_link_fallback_test.dart test/features/overview test/features/shell` — FAIL, `29 issues found`.
  - `flutter analyze` — FAIL, `378 issues found`.
  - `flutter test test/app/app_shell_smoke_test.dart test/app/shell_responsive_layout_test.dart test/features/overview/overview_provider_test.dart test/features/overview/overview_page_test.dart test/features/shell/shell_state_handler_test.dart test/app/deep_link_fallback_test.dart` — PASS, `48/48`.
- **Commands not run and why**: `dart pub outdated` not run because package-registry network access was not requested.

## Stale-Evidence Notes

- Completion evidence and previous review say validation was blocked by absent Flutter SDK. Current evidence shows Flutter/Dart are present and tests run. This is a proof-reality defect, not lane-path drift.

## Path To 100

1. Wire `OverviewPageShell` to the real workspace provider/repository state. It should consume current workspace assets and governance diagnostics, not `const []`.
2. Add a widget/provider integration test that overrides the real workspace provider with non-empty mock assets and verifies the routed `/overview` page renders those counts without direct constructor injection.
3. Add a test for repository load failure and empty data using the same runtime provider path.
4. Fix overview analyzer issues (`unused_import`, `unnecessary_import`, test helper naming/const lints) and rerun scoped + full analyzer.
5. Resolve upstream Tasks 0410 and 0411 route/shell proof blockers.

## Lane-Neutral References

Task identity is Task 0412. Historical lane paths and old root-level `lib/...` references are informational only; current rejection is based on live `apps/observatory/` runtime proof and analyzer failure.

## Task Ledger Patch Suggestion

```markdown
### Latest Review

- **Date**: 2026-06-19
- **Reviewer profile**: `reviewers`
- **Score**: `62/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Full report**: `docs/reports/review-wave-2026-06-19/0412-overview-dashboard-derived-metrics-independent-review.md`
- **Lane outcome**: returned to doing
- **Task reference**: Task 0412 (`0412-warp-prism-overview-dashboard-derived-metrics`)

#### Current Open Blockers

- `NEW`: runtime Overview computes from `assets: const []`, not repository/provider state.
- `PERSISTENT`: upstream Task 0410/0411 shell startup proof is rejected.
- `NEW`: scoped analyzer fails with `29` issues; full package analyzer fails with `378`.
- `EVIDENCE_GAP`: tests cover synthetic provider computation but not the routed provider-backed Overview path.

#### Path-to-100 Summary

- Wire Overview to real workspace providers, add routed provider override tests for non-empty/empty/error data, clear analyzer issues, and rerun clean validation after upstream route fixes.
```
