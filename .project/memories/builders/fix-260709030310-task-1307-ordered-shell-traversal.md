---
type: fix
title: "task-1307-ordered-shell-traversal"
agent: builders
created: 2026-07-09T03:03:10
date: 2026-07-09
---

# task-1307-ordered-shell-traversal

## Problem
Accessibility suite failed 2/20 shell focus tests (Tab from sidebar missed search; reverse Shift+Tab missed sidebar before Enter/Space).

## Root Cause
Default ReadingOrderTraversalPolicy is geometric. Topbar (search/actions) sits above sidebar items, so paint/reading order was search → action → sidebar → content, not app-shell order.

## Fix
- `ds_shell.dart`: FocusTraversalGroup(OrderedTraversalPolicy) + FocusTraversalOrder regions.
- Tests assert primaryFocus order forward and reverse; Enter/Space activation after keyboard-only reverse traversal.

## Verified
- flutter test --concurrency=1 --no-pub test/accessibility/design_system_accessibility_test.dart → 20/20
- dart analyze --format=machine on 8 task files → 0
- dart format --set-exit-if-changed on 8 task files → 0
