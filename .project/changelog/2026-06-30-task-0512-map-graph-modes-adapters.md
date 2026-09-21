---
date: 20260630-074745
timestamp: 20260630-074745
agent: builders
task: "0512"
description: "Map Graph Modes & Adapters"
is_rebuild_safe: true
---

# Map Graph Modes & Adapters

- **Task**: 0512
- **Date**: 2026-06-30
- **Author**: gt-flutter-engineer (builders)
- **Status**: Completed

## Changes
- Adopted `PrismGraphNode`, `PrismGraphEdge` from UI kit aliases to fix analyzer errors.
- Exposed `GraphNode` and `GraphEdge` through `PrismGraphNode` and `PrismGraphEdge` in `warp_prism_ui.dart`'s `prism_aliases.dart`.
- Fixed `_ModeSelector` overflow at 800px by using `Wrap` instead of `Row`+`Spacer`.
- Swapped `GestureDetector` for `FocusableActionDetector` paired with proper mouse/keyboard states in mode chips.
- Wired Maps tab `MapPageShell` through `workspaceSnapshotAsyncProvider` to ensure production runtime has data.
- Built explicit widget test coverage in `test/features/map/map_graph_panel_test.dart` for Graph tab switching and compact view boundaries.
- Replaced deprecated `.withOpacity` calls inside `MapGraphPanel` with modern `.withValues(alpha:)`.
