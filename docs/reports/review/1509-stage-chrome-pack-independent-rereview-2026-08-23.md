# Independent Adversarial Re-Review: Task 1509 — Stage Chrome Pack

> **Date**: 2026-08-23
> **Reviewer**: `reviewers` (independent adversarial gatekeeper)
> **Task**: `docs/tasks/03-review/1509-warp-prism-stage-chrome-pack-organisms.md`
> **Score**: **92/100** — Elite
> **Verdict**: **HELD_IN_REVIEW_PATH_TO_100**
> **Lane routing**: stays in `docs/tasks/03-review/` (>=90; no lane move)

## Review Lineage

Previous reports read:

- `docs/reports/review-wave-2026-07-11/task-1509-independent-review.md` — 93/100.
- `docs/reports/review/1509-stage-chrome-pack-review-2026-07-16.md` — 80/100, rejected for 36dp controls, format, and package analyzer evidence.
- `docs/reports/review/expert-2026-07-18-task-1509.md` — claimed 100/100 after path-to-100.
- `docs/reports/review/formal-2026-07-18-task-1509.md` — claimed 100/100 final gate.

This review independently re-runs all scoped evidence and treats stale formal claims as unproven.

## Delta Summary

### RESOLVED

- Watchlist expand, unpin, and select regions are now constrained to at least 48dp (`ds_watchlist_dock.dart:417-431`, `500-532`, `575-594`). Select and unpin are sibling semantics nodes, avoiding the earlier swallowed-unpin defect.
- Map legend close, category, and visibility controls now use at least 48dp constraints (`ds_map_legend.dart:463-474`, `517-565`, `666-694`).
- Coordinate status bar is read-only and exposes labeled feed chips.
- Scoped pack tests pass and the pack has gallery registration.

### NEW / PERSISTENT

- **F1 — Watchlist source is not format-clean (−2)**: non-mutating format reports `Changed lib/src/organisms/watchlist_dock/ds_watchlist_dock.dart`. The task claims all three groups had `0 changed`; current live proof contradicts it.
- **F2 — Scoped analyzer is not clean for watchlist (−2)**: `dart analyze` over the watchlist/coordinate/map-legend source/tests reports **3 info-level issues**, all in `ds_watchlist_dock.dart:130,138,148` (`prefer_const_constructors`). The task claims package analyzer `No issues found`; current live proof contradicts it.
- **F3 — Package analyzer claim stale (−4)**: current `dart analyze lib test` reports **218 info-level issues**, not zero. This is shared baseline evidence, but Task 1509 explicitly relies on the package gate and claims it is clean.

No remaining 36dp target was found by targeted search, and no lifecycle defect was found.

## Live Verification

| Gate | Result |
| --- | --- |
| Scoped analyzer: watchlist/coordinate/map legend | **PARTIAL** — 3 watchlist info findings |
| Non-mutating format: all 3 pack groups | **FAIL** — watchlist source would change; coord/legend clean |
| Pack widget tests | **PASS** — 22 pack tests in combined 70-test organism run |
| Combined EPIC-15 organism tests | **PASS** — 70/70 |
| Gallery suite | **PASS** — 23/23 |
| Direct boundary harness | **PASS** — 7/7 |
| `melos run test-boundaries` | **PASS** — 7/7 |
| Full package analyzer | **FAIL/EVIDENCE GAP** — 218 infos |
| Aliases | **PASS** — Watchlist, CoordinateStatusBar, MapLegend and models/fixtures in `prism_aliases.dart:776-813` |
| Gallery registration | **PASS** — `epic15-stage-chrome` and `_StageChromePackDemo` |

## Axiom Compliance

| Axiom | Status | Evidence |
| --- | --- | --- |
| Analyzer Integrity | **FAIL/PARTIAL** | Watchlist scoped analyzer 3 infos; full package 218 infos; prior clean claims stale |
| Lifecycle Safety | **PASS** | No timers/controllers/subscriptions in the three organisms; synchronous local state only |
| Dependency Direction | **PASS** | Boundary 7/7; no MapLibre or app imports |
| UI Accessibility | **PASS** | Four prior 36dp classes corrected; row/category min-heights 48; sibling unpin semantics |
| Proof Reality | **PARTIAL** | Functional tests and gallery green, but format/analyzer claims not reproducible |
| Release Security | **PASS** | Fixture-only stage chrome; no network/secrets |

## Accessibility Audit

- Watchlist panel is an explicit-child semantic region.
- Expand control is a labeled `IconButton` with 48×48 constraints.
- Select row has a labeled selected button semantic and a 48dp minimum.
- Unpin is an independent labeled button semantic and 48×48 control.
- Map legend close/toggle controls are labeled and 48×48.
- Map legend category header has button/expanded semantics and 48dp minimum.
- Coordinate bar intentionally has zero interactive controls.

## Lifecycle Audit

All three organisms are synchronous stateful/stateless UI surfaces. Targeted source contains no `Timer`, `AnimationController`, `TextEditingController`, `ScrollController`, `StreamSubscription`, `await`, or listener lifecycle pair requiring cancellation. No async cancellation issue found.

## Path To 100

1. Format `ds_watchlist_dock.dart` and re-run non-mutating format on all three pack groups.
2. Resolve the three `prefer_const_constructors` findings in `ds_watchlist_dock.dart` and re-run scoped analyzer.
3. Correct Task 1509 Completion Evidence: it must not claim package analyzer `No issues found` while the live package reports 218 infos.
4. Either close/rebaseline the package analyzer info baseline or explicitly obtain a governance-approved scoped-gate exception.
5. Re-run pack tests, gallery, boundaries, and all exact evidence commands.

## Lane Action

Score **92** is in the 90–99 band. Keep Task 1509 in `docs/tasks/03-review/`; do not move to `02-doing/` or `04-completed/`.

## Evidence Reviewed

- `ds_watchlist_dock.dart`, `ds_coordinate_status_bar.dart`, `ds_map_legend.dart` and their test directories.
- Public aliases, gallery registry/sections, task Completion Evidence.
- Prior independent, expert, and formal reports listed in Review Lineage.
- Current package/scoped analyzer, non-mutating format, 70 organism tests, 23 gallery tests, and direct/Melos boundary commands.