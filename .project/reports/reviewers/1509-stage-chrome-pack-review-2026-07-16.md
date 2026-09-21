# Task 1509 Independent Re-Review — Stage Chrome Pack

- **Date**: 2026-07-16
- **Reviewer profile**: reviewers
- **Scope**: `docs/tasks/03-review/1509-warp-prism-stage-chrome-pack-organisms.md`, watchlist/coordinate/map-legend source/tests, Prism aliases, gallery registration, boundary harness
- **Score**: 80/100
- **Verdict**: REJECT — route back to `docs/tasks/02-doing/`

## Axiom Compliance

| Axiom | Status | Evidence |
| --- | --- | --- |
| Analyzer Integrity | FAIL | Required `dart analyze lib test` returned **141 info-level issues**. Scoped reviewed surfaces were clean. |
| Lifecycle Safety | PASS | No controllers/subscriptions/timers created in the three stage-chrome organisms. |
| Dependency Direction | PASS | No MapLibre or forbidden app imports; boundary harness **7/7 PASS**. |
| UI Accessibility | FAIL | Multiple interactive controls are constrained to **36x36**, below the 48x48 axiom. |
| Proof Reality | PARTIAL | Scoped tests pass live, but package analyzer and format gate are red. |
| Release Security | PASS | Fixture-only chrome; no MapLibre dependency, no network/secrets. |

## Live Commands

```text
cd packages/warp_prism_ui

dart analyze lib test
# FAIL: 141 info-level issues

flutter test test/organisms/status_ticker/ test/organisms/watchlist_dock/ test/organisms/coordinate_status_bar/ test/organisms/map_legend/ test/organisms/osint_workbench/ test/organisms/ai_analyst_panel/
# PASS: 61 tests

dart run test/boundaries/boundary_test.dart
# PASS: 7/7

dart analyze lib/src/organisms/watchlist_dock lib/src/organisms/coordinate_status_bar lib/src/organisms/map_legend ...
# PASS: No issues found

dart format --output=none --set-exit-if-changed [reviewed organism/test paths]
# FAIL: would change 12 files, including all three 1509 source/test groups
```

## Findings

### MODERATE — Package analyzer exit condition is red
- **Evidence**: `dart analyze lib test` returned **141** info-level issues.
- **Impact**: Axiom 1 is not satisfied and the task cannot be accepted as complete.
- **Fix**: Clean/rebaseline package analyzer or update task validation with governance-approved scoped gate.

### MODERATE — Format gate fails for all 1509 organism groups
- **Evidence**: non-mutating format reported changes for `watchlist_dock`, `coordinate_status_bar`, `map_legend`, and their tests.
- **Impact**: Unformatted reviewed surfaces cannot pass quality gate.
- **Fix**: Run `dart format` on the three organism directories and test directories, then re-run `--set-exit-if-changed`.

### MODERATE — 36dp interactive controls violate the 48x48 touch-target axiom
- **Evidence**:
  - Watchlist expand button has `BoxConstraints(minWidth: 36, minHeight: 36)` at `ds_watchlist_dock.dart:431-437`.
  - Watchlist unpin button has `BoxConstraints(minWidth: 36, minHeight: 36)` at `ds_watchlist_dock.dart:568-579`.
  - Map legend close button has `BoxConstraints(minWidth: 36, minHeight: 36)` at `ds_map_legend.dart:488-499`.
  - Map legend visibility toggle has `BoxConstraints(minWidth: 36, minHeight: 36)` at `ds_map_legend.dart:689-707`.
- **Impact**: UI Accessibility axiom fails. This is not cosmetic; it blocks keyboard/touch accessibility acceptance.
- **Fix**: Raise all four control types to `minWidth: 48, minHeight: 48`; add tests that assert sizes.

### LOW — Row-level interactive targets do not prove 48dp minimum
- **Evidence**: Watchlist row `InkWell` at `ds_watchlist_dock.dart:514-518` and map legend category `InkWell` at `ds_map_legend.dart:552-556` have no min-height constraints.
- **Impact**: Dense rows may fall below 48dp depending on typography and padding.
- **Fix**: Add `ConstrainedBox(minHeight: 48)` around row/category hit regions.

## Exact Counts

- Lifecycle-managed objects created: **0**.
- Default watchlist interactive elements: **9** (**1** expand + **4** rows + **4** unpin buttons).
- Default map legend interactive elements without close: **9** (**3** category headers + **6** visibility toggles). With close: **10**.
- Coordinate bar interactive elements: **0**; read-only as required.
- Public Prism aliases verified for 1509: **12** across watchlist, coordinate, and map legend models/fixtures.

## Path to 100

1. Format the 1509 source/tests and re-run non-mutating format check.
2. Raise all IconButton constraints from 36x36 to 48x48.
3. Add 48dp constraints to watchlist rows and map legend category rows; add widget tests for target sizes.
4. Resolve/rebaseline package analyzer so `dart analyze lib test` returns zero issues.
5. Re-run scoped tests for the three organisms, boundary harness, analyzer, and format gate.
