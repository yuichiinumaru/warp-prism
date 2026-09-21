---
date: 20260709-160000
timestamp: 20260709-160000
agent: builders
task: "0611"
description: "Task 0611 path-to-100 — wire OperatePage projection + a11y/filter proof"
is_rebuild_safe: true
---

# Task 0611 path-to-100 — Operate board route wiring

**Date**: 2026-07-09
**Task**: 0611-warp-prism-operate-board-surface-filters
**Type**: fix / feature completion

## Summary

Closed the review path-to-100 for Operate board filters by wiring `/operate`
(`OperatePage`) to the Task 0610 workspace snapshot projection, migrating the
board surface to the public `Prism*` API, restoring accessibility labels/hit
targets, and adding route + view integration tests.

## Changes

### Created
- `apps/observatory/lib/features/operate/operate_projection_builder.dart` — maps `WorkspaceAsset`/`TaskMetadata` → `OperateProjection`.

### Modified
- `apps/observatory/lib/app/pages/operate_page.dart` — ConsumerWidget shell loads `workspaceSnapshotAsyncProvider` and feeds `OperateWorkspaceView`.
- `apps/observatory/lib/features/operate/operate_workspace_view.dart` — Prism* public API, search/filter/clear a11y, 48dp min targets.
- `apps/observatory/lib/features/operate/operate_workspace_view_model.dart` — curly-brace lint cleanup in filter predicates.
- `apps/observatory/test/features/operate/operate_board_surface_test.dart` — view/page/a11y/projection-builder coverage (41 tests).

## Verification
- `flutter test --concurrency=1 --no-pub test/features/operate/operate_board_surface_test.dart` — PASS 41/41
- `flutter analyze --no-pub lib/app/pages/operate_page.dart lib/features/operate/operate_workspace_view.dart lib/features/operate/operate_workspace_view_model.dart lib/features/operate/operate_filters.dart lib/features/operate/operate_projection_builder.dart test/features/operate/operate_board_surface_test.dart` — no errors/warnings (info-only style nits remain in non-blocking const suggestions)
- `dart format --output=none --set-exit-if-changed` on task-owned files — PASS
