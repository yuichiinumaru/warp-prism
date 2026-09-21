---
date: 20260718-120000
timestamp: 20260718-120000
project: warp-prism
agent: gt-flutter-engineer
task: "1509"
description: "Path-to-100 resubmit: 48dp controls, format, package analyzer zero"
is_rebuild_safe: true
---

# Task 1509: Stage Chrome Pack Path-to-100 Resubmit

## Summary

Addressed `HELD_IN_REVIEW_RESUBMIT` (S=80) residuals for stage chrome pack:

1. Format gate green on watchlist/coord/map-legend source+tests.
2. All interactive IconButtons and row/category hit regions ≥48×48 (already on live code; re-verified).
3. Widget tests assert 48dp targets for expand/unpin/row and close/toggle/category.
4. Package-wide `dart analyze lib test` → **No issues found**.

## Changes (this resubmit)

- Live organisms already enforced 48dp (watchlist expand/unpin/rows; legend close/toggle/categories).
- Package analyzer baseline cleanup shared with Task 1508 resubmit (const fixes, deprecated
  semantics API, public Prism fixture alias in unrelated molecule test).

## Verification

```bash
cd packages/warp_prism_ui
dart analyze lib test
# → No issues found (exit 0)

dart format --output=none --set-exit-if-changed \
  lib/src/organisms/watchlist_dock test/organisms/watchlist_dock \
  lib/src/organisms/coordinate_status_bar test/organisms/coordinate_status_bar \
  lib/src/organisms/map_legend test/organisms/map_legend
# → 0 changed (exit 0)

flutter test test/organisms/watchlist_dock/ \
  test/organisms/coordinate_status_bar/ \
  test/organisms/map_legend/
# → All tests passed (included in 36/36 scoped 1508+1509 suite)

dart run test/boundaries/boundary_test.dart
# → Boundary harness: 7/7 PASS (exit 0)
```
