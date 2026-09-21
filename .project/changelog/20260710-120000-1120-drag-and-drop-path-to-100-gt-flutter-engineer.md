---
date: 20260710-120000
timestamp: 20260710-120000
project: warp-prism
agent: gt-flutter-engineer
task: "1120"
description: "Path-to-100: continuous onMove insertion index, real DnD proof tests, keyboard reorder/move"
is_rebuild_safe: true
---

# Task 1120: Drag And Drop Task Board — Path to 100

## Summary

Closed independent re-review blockers (score 68): vacuous DnD tests, missing
continuous `DragTarget.onMove` insertion tracking, and keyboard reorder/move.

## Changes

- `DSDropTarget`: `onMove` recalculates insertion index from feedback mid-probe
  (Flutter `DragTargetDetails.offset` is feedback top-left, not raw pointer).
- `DSDraggableCard`: Alt+Up/Down reorder, Alt+Left/Right cross-lane move via
  focus-ancestor `onKeyEvent`; semantic drag hints updated.
- `DSLaneBoard`: wires keyboard callbacks into `onReorder` / `onMove` with
  adjacent-lane ids.
- `ds_drag_drop_test.dart`: real gesture proof for ghost/feedback, drop→
  onReorder/onMove, hover highlight, continuous insertion index 0→2, keyboard
  paths, board wiring (24 tests).

## Verification

```text
flutter test --concurrency=1 --no-pub test/molecules/ds_drag_drop_test.dart
# → +24 All tests passed

dart analyze --format=machine \
  lib/src/molecules/ds_draggable_card.dart \
  lib/src/molecules/ds_drop_target.dart \
  lib/src/organisms/ds_lane_board.dart \
  test/molecules/ds_drag_drop_test.dart
# → INFO only (prefer_const); 0 ERROR / 0 WARNING
```
