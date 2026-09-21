---
date: 20260710-140000
timestamp: 20260710-140000
project: warp-prism
agent: "builders"
task: "1117"
description: "2026-07-10 — Task 1117 path-to-100: layoutEngine injection + nodeSpacing forward after 88 reject"
is_rebuild_safe: true
---

# Task 1117: Graph LayoutEngine Wiring Path-to-100

**Agent**: builders (gt-flutter-engineer)
**Task**: 1117
**Type**: refactor / design-system

## Summary

Closed independent re-review residual (88/100): `GraphCanvas.layoutEngine` was
dead wiring and `DSGraphCanvas.nodeSpacing` was not forwarded. Path-to-100
verifies live injection wiring, adds regression-proof injection tests, and
clears production scoped analyzer INFOs (`withOpacity` → `withValues`).

Lane left in `docs/tasks/02-doing/` for independent reviewer re-pick. No git.

## Changes

- `packages/warp_prism_ui/lib/src/organisms/graph/graph_canvas.dart`
  - Resolves `widget.layoutEngine ?? const ForceDirectedLayout()`
  - One-shot `layout()` via injected engine when positions are unseeded
  - Continuous physics only when engine is `ForceDirectedLayout` (uses
    injected config, including `nodeSpacing`)
  - Reseeds positions when injected engine or model changes
  - INFO cleanup: `withValues(alpha:)`, `const DSStateSurface.empty`
- `packages/warp_prism_ui/lib/src/organisms/ds_graph_canvas.dart`
  - Forwards `nodeSpacing` into `ForceDirectedLayout` /
    `ForceDirectedConfig` as the delegate `layoutEngine`
- `packages/warp_prism_ui/lib/src/organisms/graph/graph_painter.dart`
  - INFO cleanup: edge colors use `withValues(alpha:)`
- `packages/warp_prism_ui/test/organisms/graph/backward_compat_test.dart`
  - Spy `GraphLayoutEngine` proves `layout()` is invoked and drives
    `Positioned` placement
  - ForceDirected config injection + DSGraphCanvas `nodeSpacing` forward
    + default 150 assertions
- `packages/warp_prism_ui/test/organisms/graph/force_directed_layout_test.dart`
  - `nodeSpacing` config retention + simulateStep gate coverage

## Verification

```bash
cd packages/warp_prism_ui
dart analyze lib/src/organisms/graph/ lib/src/organisms/ds_graph_canvas.dart
# → 0 issues

flutter test --concurrency=1 --no-pub test/organisms/graph/
# → +51 All tests passed
```

## Explicit non-claims

- Does **not** add hierarchical/DAG layouts (1117b), filters/minimap (1117c),
  or graph Semantics/keyboard (1117d).
- Does **not** move the task out of `02-doing/` — reviewer re-picks.
- Package-wide melos residual outside graph scope is not claimed green.
