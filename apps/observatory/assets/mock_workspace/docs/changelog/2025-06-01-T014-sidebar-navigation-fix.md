---
id: 2025-06-01-T014-sidebar-navigation-fix
date: 2025-06-01
project: asw-observatory
task: T014
type: remediation
impact:
  - operate
  - navigation
  - sidebar
skills:
  - design-system-harness
  - remediation-harness
---

# Sidebar navigation fix returned from review

## Why

The sidebar navigation did not highlight the active workspace when switching between Map, Operate, History, and Governance. Users could not tell which workspace they were viewing. The review cycle returned this task for remediation.

## Changed

- Added active state styling to `DSSidebar` items using `DSColors.accentCyan` highlight.
- Implemented `onWorkspaceChanged` callback that updates the active item index.
- Added `Semantics` wrapper with `selected: true/false` for accessibility.
- Fixed sidebar collapse behavior: collapsed state now shows icons only with tooltip labels.

## Evidence

- `assets/mock_workspace/docs/tasks/03-review/T014-review-returned-sidebar-navigation-fix.md` documents the review return.
- `lib/design_system/organisms/ds_sidebar.dart` (260 lines) implements the fix.
