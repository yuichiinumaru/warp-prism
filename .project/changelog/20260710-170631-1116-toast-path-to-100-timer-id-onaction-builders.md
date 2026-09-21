---
date: 20260710-170631
timestamp: 20260710-170631
agent: builders
task: "1116"
description: "Task 1116: Path-to-100 — Timer Id + Entry onAction + Hover Proof"
is_rebuild_safe: true
---

# Task 1116: Path-to-100 — Timer Id + Entry onAction + Hover Proof

> **Task**: 1116
> **Agent**: gt-flutter-engineer (builders)
> **Date**: 2026-07-10
> **Type**: remediation
> **Scope**: warp-prism-ui toast molecules (shared with Task 1308)

## Summary

Closed independent re-review **84/100** path-to-100 for Task 1116 (F1 stale
timer index, F2 entry-owned action contract, F3 pause-on-hover unproven).
Live sources already carried the Task 1308 timer-id re-resolve; this wave
confirmed entry-owned `onAction`/`dismissOnAction`, hover/id regression suite,
and re-ran scoped gates.

## Code Contract (live)

1. `ds_toast_manager.dart` `_startTimer`: Timer callback re-resolves by
   `entry.id` (never trusts captured list index after `maxVisible`/dismiss).
2. `ds_toast_manager.dart` `_resyncHoverTimers`: after dismiss rebuild, re-sync
   pause/timer state from `_hoveredIds`.
3. `ds_toast.dart` `DSToastEntry`: `VoidCallback? onAction`,
   `bool dismissOnAction` (default `true`); manager invokes then optional dismiss.
4. `ds_toast_test.dart`: pause-on-hover, maxVisible eviction id safety,
   dismiss-A-while-B-hovered, `dismissOnAction` true/false (suite **47**).

## Verification (from `packages/warp_prism_ui`)

- `flutter test --concurrency=1 --no-pub test/molecules/ds_toast_test.dart` → **47/47** ×3
- `dart analyze --format=machine` on toast source + test → **0** machine issues
- `dart format --output=none --set-exit-if-changed` on 3 scoped files → 0 changed

## Coordination

- Task **1308** owns async lifecycle stabilization and originally landed timer-id
  re-resolve + first pause-on-hover test.
- Task **1116** owns the notification toast system feature contract (severity,
  stacking, Riverpod docs, entry-owned action, full regression suite).

## Lane

Left in `docs/tasks/02-doing/`. **ready_for_reviewer: yes**. No git.
