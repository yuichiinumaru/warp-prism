---
date: 20260718-052500
timestamp: 20260718-052500
project: warp-prism
agent: gt-flutter-engineer
task: "1514"
description: "Resubmit path-to-100: 48dp chrome, drag a11y, analyzer clean, split"
is_rebuild_safe: true
---

# Task 1514: PrismFloatingAnalyticsHud — Review Resubmit Fixes

## Summary

Addressed HELD_IN_REVIEW_RESUBMIT findings (score 82 → path-to-100) for
`PrismFloatingAnalyticsHud`. Fixture metrics only; desktop pointer drag first.

## Changes

- Controller: public fields eliminate `prefer_initializing_formals` infos
- Drag handle / minimize / close: min 48×48 interactive constraints
- Title drag shares `Drag analytics HUD` semantic label
- Module split: models + controller + fixtures + widget
- Tests: 48dp header controls + draggable semantics (13 total)

## Verification

```bash
cd packages/warp_prism_ui
dart analyze lib/src/organisms/floating_analytics_hud test/organisms/floating_analytics_hud
# No issues found! (exit 0)

dart format --output=none --set-exit-if-changed \
  lib/src/organisms/floating_analytics_hud test/organisms/floating_analytics_hud
# Formatted 0 changed (exit 0)

flutter test test/organisms/floating_analytics_hud/ --concurrency=1
# All tests passed (13)

dart analyze lib test
# No issues found! (exit 0)

dart run test/boundaries/boundary_test.dart
# Boundary harness: 7/7 PASS
```

## Changelog Draft

```yaml
task: 1514
agent: gt-flutter-engineer
project: warp-prism
title: PrismFloatingAnalyticsHud path-to-100 a11y + split
description: >
  48dp header controls, drag semantics, zero scoped analyzer issues,
  module file split; fixture metrics overlay only.
summary: Floating analytics HUD resubmit ready for re-review.
verification: scoped analyze/format/tests + package analyze + 7/7 boundaries
```
