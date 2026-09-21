---
date: 20260609-230000
timestamp: 20260609-230000
agent: builders
task: "1303"
description: "Task 1303: Component Contract Reconciliation"
is_rebuild_safe: true
---

# Task 1303: Component Contract Reconciliation

> **Date**: 2026-06-09
> **Executor**: builders
> **Type**: remediation
> **Scope**: warp_prism_ui test files + ds_search_bar.dart

## Summary

Fixed 14 contract test failures across 5 test files caused by Wave 4 component
changes. Test expectations were updated to match the current component API.

## Root Causes and Fixes

### atoms_contract_test.dart (1 failure)

- **DSStatusDot animated**: `AnimatedBuilder` finder expected 1 but found 2
  (MaterialApp internals contribute an additional AnimatedBuilder).
  Fix: `findsAtLeastNWidgets(1)`.

### molecules_contract_test.dart (8 failures)

- **6 DSSearchBar tests**: `TextField` requires a `Material` ancestor. Tests
  were wrapping in `MaterialApp(home: DSSearchBar())` without `Scaffold`.
  Fix: wrap all DSSearchBar tests in `Scaffold(body: DSSearchBar(...))`.

- **DSStateType count**: Enum expanded from 3→7 (disabled, stale, degraded,
  excluded added in Task 1118). Fix: expect 7.

### templates_contract_test.dart (3 failures)

- **showDetail side-by-side**: Default test surface (800px) constrains content
  area to 560px after sidebar (240px), falling below 1200px threshold.
  Fix: `setSurfaceSize(Size(1600, 900))`.

- **search bar not found**: DSTopbar collapses search when
  `maxWidth < DSBreakpoints.narrow` (600px). At 800px surface, content area
  is 560px. Fix: `setSurfaceSize(Size(1600, 900))` and look for
  `DSSearchBar` instead of `TextField`.

- **duplicate "History" text**: Sidebar label + topbar title both render
  "History". Fix: `findsNWidgets(2)`.

### operational_components_test.dart (1 failure)

- **Semantics label lookup**: `find.byType(Semantics).first` picks up child
  Semantics (from DSGlassPanelSimple, DSStatusDot) that lack the tile label.
  Fix: use `find.byWidgetPredicate` to find Semantics with 'degraded' label.

### state_surface_test.dart (1 failure)

- **DSStateType count**: Same as molecules — 3→7. Fix: expect 7.

## Code Fix

- **ds_search_bar.dart**: Added `_controller.addListener` in `initState` to
  call `setState` when text changes. Without this, the clear button could
  never appear after dynamic text entry (the widget never rebuilt).

## Verification

All 191 tests across the 5 files pass. `dart analyze` reports 0 errors, 0
warnings on changed files.
