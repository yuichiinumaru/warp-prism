---
date: 20260709-221609
timestamp: 20260709-221609
agent: builders
task: "1308"
description: "Task 1308: Timer Re-resolve by Id + Pause-on-Hover Regression"
is_rebuild_safe: true
---

# Task 1308: Timer Re-resolve by Id + Pause-on-Hover Regression

> **Task**: 1308
> **Agent**: builders
> **Date**: 2026-07-09
> **Type**: remediation
> **Scope**: warp-prism-ui/molecules toast lifecycle

## Summary

Path-to-100 after independent re-review 87/100. Fixed stale list-index capture
in toast auto-dismiss timer; added pause-on-hover widget regression; left
package-wide analyzer residual as EXTERNAL_BLOCKER.

## Code Changes

1. `ds_toast_manager.dart` `_startTimer`: Timer callback re-resolves entry by
   `entry.id` (never trusts captured list `idx` after `maxVisible` front-removal
   or other `_entries` mutations).
2. `ds_toast_test.dart`: new test
   `pause-on-hover keeps toast visible past duration until unhover`
   (suite **41/41**).
3. Stale sibling `docs/tasks/04-completed/1308-...` archived to
   `.archive/docs/tasks/04-completed/1308-warp-prism-toast-async-lifecycle-stabilization-stale-pre-timer-id-fix-20260709.md`.

## Verification (from `packages/warp_prism_ui`)

- `flutter test --concurrency=1 --no-pub test/molecules/ds_toast_test.dart` → **41/41** ×3
- `dart analyze --format=machine` on toast source + test → **0** machine issues
- `dart format --output=none --set-exit-if-changed` on 3 scoped files → 0 changed
- Package `dart analyze lib/` residual: **1 ERROR + 75 INFO**, **0 in toast files** —
  classified **EXTERNAL_BLOCKER** (not Task 1308 scope; not fixed here)

## Regression Guards Retained

- Live-region label includes optional message
- Mounted guards on dismiss / clear / _onHoverChanged
- Action + dismiss ≥48×48
- Internal src/ imports for package tests
