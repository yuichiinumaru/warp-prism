# Task 1510 Independent Re-Review — PrismOsintWorkbench

- **Date**: 2026-07-16
- **Reviewer profile**: reviewers
- **Scope**: `docs/tasks/03-review/1510-warp-prism-osint-workbench-organism.md`, OSINT workbench source/tests, Prism aliases, gallery registration, boundary harness
- **Score**: 86/100
- **Verdict**: REJECT — route back to `docs/tasks/02-doing/`

## Axiom Compliance

| Axiom | Status | Evidence |
| --- | --- | --- |
| Analyzer Integrity | FAIL | Required `dart analyze lib test` returned **141 info-level issues**. Scoped reviewed surfaces were clean. |
| Lifecycle Safety | PASS | No controllers/subscriptions/timers created by `DSOsintWorkbench`. |
| Dependency Direction | PASS | No live API, MapLibre, storage, Riverpod, or app imports; boundary harness **7/7 PASS**. |
| UI Accessibility | PARTIAL | Core controls have labels; history row target size is unproven/sub-48 risk. |
| Proof Reality | PARTIAL | Scoped tests pass live, but package analyzer and format gate are red. |
| Release Security | PASS | Grep found no live OSINT APIs, API key, localStorage, sqlite, MapLibre, http, dio, or HttpClient paths in this organism. |

## Live Commands

```text
cd packages/warp_prism_ui

dart analyze lib test
# FAIL: 141 info-level issues

flutter test test/organisms/status_ticker/ test/organisms/watchlist_dock/ test/organisms/coordinate_status_bar/ test/organisms/map_legend/ test/organisms/osint_workbench/ test/organisms/ai_analyst_panel/
# PASS: 61 tests

dart run test/boundaries/boundary_test.dart
# PASS: 7/7

dart analyze lib/src/organisms/osint_workbench test/organisms/osint_workbench ...
# PASS: No issues found

dart format --output=none --set-exit-if-changed [reviewed organism/test paths]
# FAIL: would change 12 files, including osint_workbench source/test
```

## Findings

### MODERATE — Package analyzer exit condition is red
- **Evidence**: `dart analyze lib test` returned **141** info-level issues.
- **Impact**: The task’s validation command is not satisfied.
- **Fix**: Clean/rebaseline package analyzer or document a governance-approved scoped gate.

### MODERATE — Format gate fails for this organism
- **Evidence**: non-mutating format reported `Changed lib/src/organisms/osint_workbench/ds_osint_workbench.dart` and `Changed test/organisms/osint_workbench/osint_workbench_test.dart`.
- **Impact**: Unformatted source cannot pass.
- **Fix**: Run `dart format lib/src/organisms/osint_workbench test/organisms/osint_workbench` and re-run `--set-exit-if-changed`.

### LOW — Public constructor permits one tab despite task requiring multi-tab fixture workbench
- **Evidence**: constructor asserts only `tools.length >= 1` at `ds_osint_workbench.dart:620-646`; task requirement says MUST host **≥2** fixture tool tabs.
- **Impact**: The shipped default fixtures satisfy ≥2, but public contract allows consumers/tests to instantiate a one-tab workbench contrary to the task contract.
- **Fix**: Change assertion to `tools.length >= 2` or explicitly document that ≥2 applies only to fixtures/gallery and add a test for the intended contract.

### LOW — History row interactive target lacks explicit 48dp constraint
- **Evidence**: `_HistoryRow` is an `InkWell` at `ds_osint_workbench.dart:1280-1325` with padding only; no `ConstrainedBox(minHeight: 48)`.
- **Impact**: UI Accessibility axiom is only partially proven for history rows.
- **Fix**: Add min-height 48 and a widget test asserting row size.

## Exact Counts

- Lifecycle-managed objects created: **0**.
- Default fixture tool tabs: **2** (`dns`, `ip`) verified by tests and fixtures.
- Core interactive controls in default post-query path: **2** tool tabs + **1** submit + **N** history rows + optional **M** map handoff buttons for geo results.
- 1510 public Prism aliases verified: **7** (`PrismOsintWorkbench`, tool, result, result field, history entry, map handoff, fixtures).

## Path to 100

1. Format OSINT source/test and re-run non-mutating format check.
2. Resolve/rebaseline package analyzer so `dart analyze lib test` is clean.
3. Decide and encode the ≥2 tab public contract: assert it or document fixture-only scope.
4. Add 48dp constraint/test for history rows.
5. Re-run scoped OSINT tests, scoped/package analyzer, boundary harness, and format gate.
