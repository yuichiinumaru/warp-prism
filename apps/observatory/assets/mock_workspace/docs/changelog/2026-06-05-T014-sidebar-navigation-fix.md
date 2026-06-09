---
id: 2026-06-05-T014-sidebar-navigation-fix
date: 2026-06-05
project: warp-prism
task: T014
type: fix
skills:
  - design-system-harness
  - remediation-harness
workflows:
  - gt-code-review
  - reviewer-orchestration
impact:
  - sidebar
  - navigation
  - fix
---

# Sidebar Navigation Selection Fix

Fixed sidebar selection state not updating when route changes via browser back/forward navigation.

## Why

The sidebar selectedId was bound to a local index that only updated on tap, not on route change. This caused the sidebar highlight to desync from the actual route after browser navigation.

## Changed

- Sidebar selection now derives from GoRouter's StatefulNavigationShell.currentIndex
- Removed competing manual index state from AppShell
- Navigation tap calls navigationShell.goBranch with initialLocation guard
- Selection state is route-derived, not manually maintained

## Evidence

- Task T014 in review lane (returned for additional testing)
- AppShell uses navigationShell.currentIndex for selectedId
- Browser back/forward keeps sidebar in sync with route
