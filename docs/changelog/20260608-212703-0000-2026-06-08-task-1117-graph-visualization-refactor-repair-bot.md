---
date: 20260608-212703
timestamp: 20260608-212703
agent: repair-bot
task: "1038"
description: "Task 1117: Graph Visualization Refactor — Model/Layout/Painter Split"
is_rebuild_safe: true
---

# Task 1117: Graph Visualization Refactor — Model/Layout/Painter Split

**Date**: 2026-06-08
**Status**: Complete (pending review)
**Type**: refactor

## Summary

Refactored the 483-line `DSGraphCanvas` monolith into composable layers.
The graph canvas concern is now decomposed into four independent, testable
files inside `packages/warp_prism_ui/lib/src/organisms/graph/`:

- `graph_model.dart` — `GraphModel`, `GraphNode`, `GraphEdge` with typed
  `GraphNodeId`/`GraphEdgeId` wrappers. Pure data, no Flutter widget dependency.
  Query methods: `nodeById()`, `edgesForNode()`, `adjacentNodes()`.
- `graph_layout_engine.dart` — `GraphLayoutEngine` abstract interface.
- `force_directed_layout.dart` — `ForceDirectedLayout implements
  GraphLayoutEngine`. Extracted from monolith `_updatePhysics`. Configurable
  parameters (repulsion, attraction, damping, center gravity, node spacing).
  Public `simulateStep()` for animated use by the orchestrator widget.
- `graph_painter.dart` — `GraphPainter extends CustomPainter`. Public,
  testable with `PictureRecorder`. Accepts `GraphPainterConfig` for style.
- `graph_canvas.dart` — `GraphCanvas` orchestrator widget that composes
  model, layout engine, painter, and interaction handlers.

## Backward Compatibility

`DSGraphCanvas` (in `ds_graph_canvas.dart`) is preserved as a thin
backward-compatible wrapper. All original parameters work unchanged:
`nodes`, `edges`, `onNodeTap`, `onNodeDoubleTap`, `onNodeDragEnd`,
`enablePhysics`, `nodeSpacing`. Legacy `GraphNode` (string ID, mutable
position) and `GraphEdge` (string source/target) remain as the public API.
Internally they are converted to the typed model and delegated to
`GraphCanvas`.

## New Barrel Exports

`organisms.dart` re-exports the graph sub-barrel (hiding `GraphNode`/
`GraphEdge` to avoid name collision with legacy types). Users can import
the typed model directly via:
`import 'package:warp_prism_ui/src/organisms/graph/graph.dart' as graph;`

## Tests

- `graph_model_test.dart` — 18 tests (model construction, queries, typed IDs)
- `force_directed_layout_test.dart` — 7 tests (positions within bounds,
  <100ms for 10-node graph, determinism, empty/single-node edge cases)
- `graph_painter_test.dart` — 11 tests (paints without throwing, highlighting,
  empty/missing positions, shouldRepaint, custom config)
- `backward_compat_test.dart` — 7 tests (legacy API preserved, new types accessible)

All 45 tests pass.

## Gallery

Added force-directed graph demo with sample nodes/edges to the organisms
section of `design_system_gallery_sections.dart`.

## Files Created/Modified

| File | Action |
|------|--------|
| `lib/src/organisms/graph/graph_model.dart` | Created |
| `lib/src/organisms/graph/graph_layout_engine.dart` | Created |
| `lib/src/organisms/graph/force_directed_layout.dart` | Created |
| `lib/src/organisms/graph/graph_painter.dart` | Created |
| `lib/src/organisms/graph/graph_canvas.dart` | Created |
| `lib/src/organisms/graph/graph.dart` | Created (barrel) |
| `lib/src/organisms/ds_graph_canvas.dart` | Refactored (wrapper) |
| `lib/src/organisms/organisms.dart` | Modified (graph export) |
| `lib/src/gallery/design_system_gallery_sections.dart` | Modified (graph demo) |
| `test/organisms/graph/graph_model_test.dart` | Created |
| `test/organisms/graph/force_directed_layout_test.dart` | Created |
| `test/organisms/graph/graph_painter_test.dart` | Created |
| `test/organisms/graph/backward_compat_test.dart` | Created |
