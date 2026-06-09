---
date: 20260607-220705
timestamp: 20260607-220705
agent: repair-bot
task: "1017"
description: "Task 0513 - Map Selection and Inspector Integration"
is_rebuild_safe: true
---

# Task 0513 - Map Selection and Inspector Integration

**Date**: 2026-06-07
**Task**: 0513-warp-prism-map-selection-and-inspector
**Type**: feature

## Summary

Connected the Map catalog and graph views to a shared selection model
and an inspector panel. Both card taps and graph node taps converge on
a single `MapSelectionController` that writes to the shared
`MapWorkspaceState.selectedAssetId`. The inspector panel renders asset
details (identity, governance, relationships, triggers, operational
hints) using the existing `DSDetailInspector` organism.

## Changes

### Created
- `lib/features/map/map_selection_controller.dart` — Shared selection
  controller with asset resolution and inspector section building.
- `lib/features/map/widgets/map_inspector_panel.dart` — Inspector panel
  widget that renders asset details or an explicit no-selection state.
- `test/features/map/map_selection_and_inspector_test.dart` — Tests
  covering selection synchronization, inspector rendering, and clear.

### Modified
- `lib/features/map/map_workspace_page.dart` — Integrated
  `MapSelectionController` and `MapInspectorPanel` into the page layout.
  Replaced graph placeholder with real `MapGraphPanel`. Replaced
  `ShellStateHandler` calls with `MapStatePanel`.
- `lib/features/map/map_workspace.dart` — Updated barrel exports.

## Verification

- `flutter analyze` — PASS (no errors)
- `flutter test test/features/map/` — PASS (0 failures)
