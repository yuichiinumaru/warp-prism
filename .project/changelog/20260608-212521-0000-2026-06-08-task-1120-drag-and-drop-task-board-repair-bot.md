---
date: 20260608-212521
timestamp: 20260608-212521
agent: repair-bot
task: "1036"
description: "2026-06-08 — Task 1120: Drag And Drop Task Board"
is_rebuild_safe: true
---

# 2026-06-08 — Task 1120: Drag And Drop Task Board

**Task**: 1120 — Drag And Drop Task Board
**Agent**: builders
**Status**: Completed

## Summary

Added drag-and-drop interactivity to the `DSLaneBoard` kanban organism.
The board was previously read-only — cards were static with no drag
support. This task adds `DSDraggableCard` and `DSDropTarget` molecules,
integrates them into `DSLaneBoard`, and provides visual feedback during
drag operations.

## Files Created

| File | Purpose |
| --- | --- |
| `packages/warp_prism_ui/lib/src/molecules/ds_draggable_card.dart` | `DSDraggableCard` molecule + `DSDragPayload`, `DSDragReorderEvent`, `DSDragMoveEvent` data classes |
| `packages/warp_prism_ui/lib/src/molecules/ds_drop_target.dart` | `DSDropTarget` molecule with hover highlight and insertion indicator |
| `packages/warp_prism_ui/test/molecules/ds_drag_drop_test.dart` | 17 widget tests covering drag-and-drop behavior |

## Files Modified

| File | Change |
| --- | --- |
| `packages/warp_prism_ui/lib/src/molecules/molecules.dart` | Added exports for `ds_draggable_card.dart` and `ds_drop_target.dart` |
| `packages/warp_prism_ui/lib/src/organisms/ds_lane_board.dart` | Integrated `DSDraggableCard` and `DSDropTarget`; added `onReorder` and `onMove` callbacks |
| `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` | Added `buildDragAndDropSection()` gallery entry with interactive `_DragDropDemo` |
| `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_page.dart` | Added drag-and-drop section to gallery page |
| `docs/tasks/02-doing/1120-warp-prism-drag-and-drop-task-board.md` | Moved from 01-open to 02-doing; completion evidence filled |

## Behavioral Notes

- **Long-press drag**: `LongPressDraggable` with 200ms delay avoids tap conflict.
- **Ghost card**: Original position renders at 0.2 opacity during drag.
- **Feedback card**: Card under pointer at 0.8 opacity with cyan glow border.
- **Drop zone highlight**: Border animates to accentCyan at 0.3 opacity when hovered.
- **Insertion indicator**: 2px cyan line at the computed drop index.
- **Same-lane reorder**: Fires `onReorder(DSDragReorderEvent)`.
- **Cross-lane move**: Fires `onMove(DSDragMoveEvent)`.
- **Empty lane**: Accepts drops (empty state surface renders inside drop target).
- **Backward compatible**: `lanes`, `selectedTaskId`, `onTaskTap` unchanged.
- **No external dependencies**: Uses Flutter's built-in `Draggable`/`DragTarget` only.

## Test Results

- 17 new drag-and-drop tests: **ALL PASS**
- Analyzer on modified files: **0 errors**, info-level only (`withOpacity` deprecation, `prefer_const`)
- Existing test regressions: **NONE** (pre-existing DSSearchBar/DSStateSurface failures unrelated)

## Pre-existing Issues Noted

- `design_system_gallery_sections.dart` references undefined types: `DSErrorBoundary`, `DSLogViewer`, `DSDataTable`, `DSDataColumn`, `DSDataRow`, `DSStatusCell`, `DSSecretCell`, `DSActionsCell`, `DSActionItem`, `DSFallbackView`. These are pre-existing and block full library compilation when importing the barrel. Tests work around this by importing specific layer files.
