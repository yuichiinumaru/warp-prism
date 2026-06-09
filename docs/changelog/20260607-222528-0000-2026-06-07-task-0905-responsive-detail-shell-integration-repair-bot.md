---
date: 20260607-222528
timestamp: 20260607-222528
agent: repair-bot
task: "1022"
description: "Task 0905 — Responsive Detail Shell Integration"
is_rebuild_safe: true
---

# Task 0905 — Responsive Detail Shell Integration

**Date**: 2026-06-07
**Type**: feature
**Scope**: `lib/features/asset_detail/`, `lib/design_system/`, `lib/features/map/`, `lib/features/history/`

## Summary

Integrated the universal asset detail surface into the shell and consumer
workspaces with breakpoint-aware responsive behavior. All workspace surfaces
now delegate detail rendering to a shared `ResponsiveDetailShell` widget
instead of building local inspector layouts.

## What Changed

### New files:
- `lib/features/asset_detail/presentation/responsive_detail_shell.dart`
  — Core responsive wrapper. Renders detail using:
  - **Wide (>= 1200px)**: side-by-side split pane (master left, detail right)
  - **Medium (800-1199px)**: animated overlay drawer from right with scrim
  - **Narrow (< 800px)**: full-screen Scaffold with back arrow in AppBar
- `lib/features/asset_detail/presentation/asset_detail_consumer.dart`
  — Shared consumer wrapper for workspace surfaces. Bridges `selectedAssetId`
  to `ResponsiveDetailShell` with `detailBuilder` callback.
- `lib/features/asset_detail/asset_detail.dart` — Barrel export.
- `test/features/asset_detail/responsive_detail_integration_test.dart`
  — Widget tests for all three breakpoints, open/close/back sync,
  scrim tap, back arrow, breakpoint boundary values, and transitions.

### Modified files:
- `lib/design_system/templates/master_detail_template.dart`
  — Added `onDetailClose`, `detailTitle`, `detailKind` props.
  - Wide: split-pane (unchanged)
  - Medium: overlay drawer with scrim that triggers `onDetailClose`
  - Narrow: full-screen Scaffold with back arrow and `onDetailClose`
- `lib/design_system/organisms/ds_shell.dart`
  — `DSShellResponsive` now supports overlay inspector on medium
  layouts and full-screen inspector on narrow layouts.
  Added `onInspectorClose` callback.
- `lib/features/map/map_workspace_page.dart`
  — Replaced local `Row` layout with `AssetDetailConsumer`.
  Detail now uses responsive behavior across all breakpoints.
- `lib/features/history/presentation/history_page.dart`
  — Replaced hardcoded `MediaQuery` width check with
  `ResponsiveDetailShell`. Detail now responds to all breakpoints
  with proper close/back behavior.

## Behavioral Contract

- `onDetailClose` / `onInspectorClose` fires on ALL breakpoints:
  - Wide: via the `DSDetailInspector` close button in the detail header
  - Medium: via scrim tap or `DSDetailInspector` close button
  - Narrow: via back arrow in AppBar or `DSDetailInspector` close button
- Consumer surfaces must clear their selection state in response.
- No device-type names; all branching is width-based via `DSBreakpoints`.
