---
date: 20260607-212124
timestamp: 20260607-212124
agent: repair-bot
task: "1020"
description: "Task 1020 — Responsive Shell and Detail Pass"
is_rebuild_safe: true
scope: "design-system"
type: "feature"
---

# Task 1020 — Responsive Shell and Detail Pass

## What changed
- Created `ds_breakpoints.dart` token class with centralized breakpoint constants:
  - `narrow` (600px): below this, sidebar hidden and search bar collapses
  - `sidebarCollapse` (800px): sidebar switches between expanded and collapsed
  - `timelineDetail` (1000px): timeline switches between inline and side-by-side detail
  - `masterDetailSideBySide` (1200px): master-detail switches between overlay and side-by-side
- Exported `DSBreakpoints` from `tokens.dart` barrel
- Updated `DSShellResponsive` in `ds_shell.dart` to use `DSBreakpoints` instead of hardcoded values
  - Added narrow (<600px) behavior: hides sidebar entirely
  - Documented width contract in class docstring
- Updated `master_detail_template.dart` to use `DSBreakpoints` for all responsive decisions:
  - `MasterDetailTemplate`: uses `masterDetailSideBySide` and `sidebarCollapse`
  - `TimelineTemplate`: uses `timelineDetail`
- Updated `DSTopbar` in `ds_topbar.dart`:
  - Search bar now collapses below `DSBreakpoints.narrow` (600px) width
  - Search uses `ConstrainedBox(maxWidth: 300)` instead of fixed `SizedBox(width: 300)`
  - Breadcrumbs wrapped in Expanded to prevent overflow
- Documented responsive contract with docstrings on `DSShellResponsive` and templates

## Why
Breakpoints were scattered and duplicated across 3+ files with hardcoded pixel values.
The topbar search bar was fixed at 300px with no collapse behavior, causing overflow on
narrow screens. There was no breakpoint below 800px, meaning the sidebar would still
render on very narrow viewports. A centralized `DSBreakpoints` class ensures all responsive
decisions reference a single source of truth.

## Test coverage
- `test/design_system/responsive_shell_test.dart` — verifies breakpoint values, ordering,
  spacing between ranges, and layout token constants
