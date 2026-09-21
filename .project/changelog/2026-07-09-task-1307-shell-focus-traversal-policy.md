---
date: 20260709-060244
timestamp: 20260709-060244
agent: builders
task: "1307"
description: "[2026-07-09] - Task 1307 Shell Focus Traversal Policy"
is_rebuild_safe: true
---

## [2026-07-09] - Task 1307 Shell Focus Traversal Policy
### Fixed
- Root-caused shell Tab failures: default geometric `ReadingOrderTraversalPolicy` put topbar/search ahead of sidebar items even though the product contract is sidebar → search → action → content.
- Added `FocusTraversalGroup(policy: OrderedTraversalPolicy())` with `NumericFocusOrder` regions on `DSShell` (sidebar 0, topbar 1, content 2, inspector 3) so keyboard traversal matches intentional app-shell order.
- Strengthened accessibility tests to assert forward Tab order, reverse Shift+Tab order via `FocusManager.instance.primaryFocus`, and Enter/Space activation after keyboard-only reverse traversal (exactly one activation each).
- Validation from `packages/warp_prism_ui`: accessibility suite 20/20; scoped `dart analyze --format=machine` 0 issues on 8 task files; scoped `dart format --set-exit-if-changed` 0 changes.
**Author**: builders
