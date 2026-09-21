# Task 1508 Independent Re-Review — PrismStatusTicker

- **Date**: 2026-07-16
- **Reviewer profile**: reviewers
- **Scope**: `docs/tasks/03-review/1508-warp-prism-status-ticker-organism.md`, status ticker source/tests, Prism aliases, gallery registration, public boundary harness
- **Score**: 84/100
- **Verdict**: REJECT — route back to `docs/tasks/02-doing/`

## Axiom Compliance

| Axiom | Status | Evidence |
| --- | --- | --- |
| Analyzer Integrity | FAIL | Required package gate `dart analyze lib test` returned **141 info-level issues**. Scoped reviewed surfaces were clean, but the task exit command is package-wide and red. |
| Lifecycle Safety | PASS | `DSStatusTicker` creates **1** `Timer`, **1** `AnimationController`, and **1** optional owned `DSStatusTickerController`; `dispose()` cancels/disposes/removes all **3** at `ds_status_ticker.dart:392-397`. Timer callback checks `mounted` at `ds_status_ticker.dart:449-451`. |
| Dependency Direction | PASS | No Riverpod/GoRouter/app imports. Boundary harness returned **7/7 PASS**. |
| UI Accessibility | PARTIAL | Region semantics/reduced-motion fallback exist. Optional tappable ticker chips lack their own button semantics and 48x48 target. |
| Proof Reality | PARTIAL | Scoped tests pass live, but package analyzer and format gate are red. Prior ledger claimed pass despite package analyzer infos. |
| Release Security | PASS | Fixture-only status feed; no live network/secrets observed in this organism. |

## Live Commands

```text
cd packages/warp_prism_ui

dart analyze lib test
# FAIL: 141 info-level issues

flutter test test/organisms/status_ticker/ test/organisms/watchlist_dock/ test/organisms/coordinate_status_bar/ test/organisms/map_legend/ test/organisms/osint_workbench/ test/organisms/ai_analyst_panel/
# PASS: 61 tests

dart run test/boundaries/boundary_test.dart
# PASS: 7/7

dart analyze lib/src/organisms/status_ticker ... lib/src/gallery/design_system_gallery_registry.dart
# PASS: No issues found

dart format --output=none --set-exit-if-changed [reviewed organism/test paths]
# FAIL: would change 12 files, including status_ticker source/test
```

## Findings

### MODERATE — Package analyzer exit condition is red
- **Evidence**: `dart analyze lib test` produced **141** info-level issues.
- **Impact**: Axiom 1 requires zero warnings and zero info-level issues. The task’s own validation command is not satisfied.
- **Fix**: Either clean the package analyzer baseline or change the task gate to a documented scoped analyzer command accepted by governance; do not claim package analyzer PASS while infos remain.

### MODERATE — Format gate fails for this organism
- **Evidence**: `dart format --output=none --set-exit-if-changed ...` reported `Changed lib/src/organisms/status_ticker/ds_status_ticker.dart` and `Changed test/organisms/status_ticker/status_ticker_test.dart`.
- **Impact**: Review cannot accept unformatted source.
- **Fix**: Run `dart format lib/src/organisms/status_ticker test/organisms/status_ticker` and re-run non-mutating format check.

### LOW — Optional interactive ticker chips are not independently accessible
- **Evidence**: `_StatusChip` becomes an `InkWell` when `onItemTap != null` at `ds_status_ticker.dart:771-778`, but no `Semantics(button: true, label: ...)` and no `BoxConstraints(minWidth: 48, minHeight: 48)` are applied.
- **Impact**: Default non-interactive ticker is safe; interactive consumers get sub-48 hit targets and weak screen-reader affordance.
- **Fix**: Wrap tappable chips in `Semantics(button: true, label: item.accessibilitySummary)` and a `ConstrainedBox(minWidth: 48, minHeight: 48)`.

## Exact Counts

- Controllers/subscriptions/timers created: **3** lifecycle-managed objects (`Timer`, `AnimationController`, owned `DSStatusTickerController`).
- Matching disposals/cancellations/listener removals: **3**.
- Public Prism aliases verified for 1508: **5** (`PrismStatusTicker`, item, mode, controller, fixtures).
- Task-local tests run live: included in **61/61** EPIC-15 organism tests.

## Path to 100

1. Format `status_ticker` source/test and re-run `dart format --output=none --set-exit-if-changed ...`.
2. Resolve or formally rebaseline package-wide `dart analyze lib test` so it returns zero issues.
3. Add tappable chip semantics + 48dp constraints and a widget test asserting chip semantics/button flag and target size.
4. Re-run: scoped analyzer, package analyzer, status ticker tests, boundary harness, non-mutating format gate.
