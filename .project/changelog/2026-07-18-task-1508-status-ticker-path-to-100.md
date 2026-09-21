---
date: 20260718-120000
timestamp: 20260718-120000
project: warp-prism
agent: gt-flutter-engineer
task: "1508"
description: "Path-to-100 resubmit: ticker a11y 48dp, package analyzer zero, format"
is_rebuild_safe: true
---

# Task 1508: PrismStatusTicker Path-to-100 Resubmit

## Summary

Addressed `HELD_IN_REVIEW_RESUBMIT` (S=84) residuals for `PrismStatusTicker`:

1. Format gate green on status ticker source/test.
2. Package-wide `dart analyze lib test` → **No issues found** (zero infos/warnings/errors).
3. Interactive chip button semantics + ≥48dp targets proven by widget test.
4. Default strip height raised to 48; region uses `explicitChildNodes` when tappable.

## Changes (this resubmit)

- `ds_status_ticker.dart`: default `height` 48; `explicitChildNodes` when `onItemTap != null`;
  tappable chips use container button semantics + 48×48 `ConstrainedBox` + transparent `Material`.
- `status_ticker_test.dart`: hardened a11y target assertion.
- Package analyzer baseline cleanup (shared debt outside organism Where table, required by exit gate):
  `dart fix --apply` const/dangling-doc cleanups; Prism fixture alias fix in scale-measure test;
  deprecated `hasFlag` → `flagsCollection` in log_viewer/command_palette tests.

## Verification

```bash
cd packages/warp_prism_ui
dart analyze lib test
# → No issues found (exit 0)

dart format --output=none --set-exit-if-changed \
  lib/src/organisms/status_ticker test/organisms/status_ticker
# → 0 changed (exit 0)

flutter test test/organisms/status_ticker/
# → All tests passed (14) (exit 0)

dart run test/boundaries/boundary_test.dart
# → Boundary harness: 7/7 PASS (exit 0)
```
