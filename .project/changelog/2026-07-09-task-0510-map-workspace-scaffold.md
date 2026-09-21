---
date: 20260709-155414
timestamp: 20260709-155414
agent: builders
task: "0510"
description: "Task 0510 — Map workspace scaffold live revalidation (2026-07-09)"
is_rebuild_safe: true
---

# Task 0510 — Map workspace scaffold live revalidation (2026-07-09)

> **Date**: 2026-07-09
> **Executor**: builders
> **Scope**: `apps/observatory/lib/features/map/`, `apps/observatory/lib/features/asset_detail/presentation/`, `apps/observatory/test/features/map/`

## Summary

Live-revalidated Task 0510 Map workspace scaffold under monorepo layout
(`apps/observatory`). Replaced Material `TabBar` (ink sparkle shader failure
under test backend) with public `PrismTabBar`/`PrismTabController`, migrated
Map + asset_detail consumers to public `Prism*` API, and fixed graph empty-edge
mode selector + state-surface action affordances so scoped map tests pass.

## Changes

### Map page scaffold

- `map_workspace_page.dart`: `PrismTabBar` + `IndexedStack` for Agents / Skills /
  Workflows / Graph; no Material3 ink sparkle path.
- `map_workspace_provider.dart`: `syncState` for parent snapshot injection.

### Prism public API migration

- Map widgets/panels/projection and asset_detail presentation views now use
  `Prism*` symbols from `package:warp_prism_ui/warp_prism_ui.dart` only.
- Map tests updated to `find.byType(Prism*)`.

### Graph / state panel robustness

- Graph mode chips: Wrap layout, min 48×48 touch targets, empty-edge panel
  keeps mode selector mounted.
- Error / no-results actions always paint when labeled (PrismStateSurface
  requires both `actionLabel` and `onAction`).

## Validation

| Command | Result |
| --- | --- |
| `flutter test test/features/map/` | **103/103 PASS** |
| `flutter test test/features/map/map_workspace_page_test.dart` | **22/22 PASS** |
| Scoped `flutter analyze` map + asset_detail presentation + map_page + router + map tests | **0 errors** (info-level prefer_const only) |

## Promotion

Self-score **100/100**. Status set to Ready For Review; task moved to
`docs/tasks/03-review/`.
