---
date: 20260607-212114
timestamp: 20260607-212114
agent: repair-bot
task: "1010"
description: "Task 1010 — Accessibility Contrast and Focus Pass"
is_rebuild_safe: true
scope: "design-system"
type: "remediation"
---

# Task 1010 — Accessibility Contrast and Focus Pass

## What changed
- Raised `textTertiary` from `#606070` to `#8888A0` in `ds_colors.dart` for WCAG AA compliance (~6.0:1 on obsidianDeep)
- Raised `textDisabled` from `#404050` to `#505060` (disabled text exempt from WCAG but improved baseline)
- Added keyboard focus support (FocusNode, Enter/Space activation, visible focus ring) to:
  - `_SidebarItemWidget` in `ds_sidebar.dart`
  - `DSTopbarAction` in `ds_topbar.dart`
  - `DSChip` in `ds_chip.dart`
  - `DSTaskCard` in `ds_task_card.dart`
  - `_FilterChip` in `ds_filter_chip_group.dart`
  - `DSLinkRow` in `ds_detail_inspector.dart`
- Added `Semantics` wrappers to all interactive and structural components:
  - `DSSidebar`, `_SidebarItemWidget`, `_DefaultHeader`
  - `DSTopbar`, `_Breadcrumbs`, `DSTopbarAction`
  - `DSChip`, `DSTaskCard`, `_PriorityBadge`, `_ReviewScore`
  - `DSFilterChipGroup`, `_FilterChip`
  - `DSText` (all variants wrapped with Semantics, optional `semanticsLabel` override)
  - `DSDetailInspector`, `_InspectorHeader`, `_InspectorSection`, `DSPropertyRow`, `DSLinkRow`
  - `DSLaneBoard`, `_LaneColumn`, `_LaneHeader`, `_EmptyLane`
- All focus indicators use cyan ring: `DSColors.accentCyan.withOpacity(0.5)` with 2px width
- All interactive elements show `DSColors.obsidianActive` background on keyboard focus

## Why
The obsidian dark theme had textTertiary at #606070 which yielded only 2.7:1 contrast ratio on
obsidianDeep (#050508), failing WCAG AA for normal text (requires 4.5:1). All interactive
components relied solely on mouse hover with no keyboard activation path, making the design
system unusable for keyboard-only navigation and screen readers.

## Test coverage
- `test/design_system/accessibility_focus_contrast_test.dart` — verifies contrast ratios,
  color distinctness, token integrity, and focus indicator visibility
