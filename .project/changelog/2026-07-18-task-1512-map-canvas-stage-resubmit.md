---
date: 20260718-052500
timestamp: 20260718-052500
project: warp-prism
agent: gt-flutter-engineer
task: "1512"
description: "Resubmit path-to-100: 48dp targets, background a11y, file split"
is_rebuild_safe: true
---

# Task 1512: PrismMapCanvasStage — Review Resubmit Fixes

## Summary

Addressed HELD_IN_REVIEW_RESUBMIT findings (score 87 → path-to-100) for
`PrismMapCanvasStage`. Placeholder-only contract retained (no MapLibre port).

## Changes

- Feature markers: 48dp hit box with smaller visual glyph
- Status-strip Clear + popup dismiss: min 48×48 interactive targets
- Background clear: explicit `Semantics(label: 'Clear map selection', button: true)`
- Split mega-widget into host + `map_stage_placeholder_widgets.dart` + controller
- Tests: 48dp hit targets + background accessible label (13 total)

## Verification

```bash
cd packages/warp_prism_ui
dart analyze lib/src/organisms/map_canvas_stage test/organisms/map_canvas_stage
# No issues found! (exit 0)

dart format --output=none --set-exit-if-changed \
  lib/src/organisms/map_canvas_stage test/organisms/map_canvas_stage
# Formatted 0 changed (exit 0)

flutter test test/organisms/map_canvas_stage/ --concurrency=1
# All tests passed (13)

dart analyze lib test
# No issues found! (exit 0)

dart run test/boundaries/boundary_test.dart
# Boundary harness: 7/7 PASS
```

## Changelog Draft

```yaml
task: 1512
agent: gt-flutter-engineer
project: warp-prism
title: PrismMapCanvasStage path-to-100 a11y + module split
description: >
  48dp interactive targets, labeled background clear, placeholder widget
  extraction; fixture-only stage (no MapLibre).
summary: Map stage contract resubmit ready for re-review.
verification: scoped analyze/format/tests + package analyze + 7/7 boundaries
```
