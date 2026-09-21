---
type: fix
title: "task-1308-path-to-100-toast-lifecycle"
agent: builders
created: 2026-07-09T03:01:21
date: 2026-07-09
---

# task-1308-path-to-100-toast-lifecycle

Task 1308 Round-2 path-to-100 remediation (after 84/100 rejection).

## Changes
1. `ds_toast.dart`: outer live-region Semantics.label includes optional entry.message; action TextButton minimumSize = kMinInteractiveDimension (48x48).
2. `ds_toast_manager.dart`: mounted guards at start of dismiss(), clear(), _onHoverChanged() before setState.
3. `ds_toast_test.dart`: title+message semantics test + action 48x48 test (40/40).

## Verification (packages/warp_prism_ui)
- flutter test --concurrency=1 --no-pub test/molecules/ds_toast_test.dart → 40/40 ×3
- dart analyze --format=machine (3 scoped files) → 0 issues
- dart format --output=none --set-exit-if-changed (3 files) → 0 changed

## Lane
Moved docs/tasks/02-doing/1308-... → docs/tasks/03-review/1308-...

## External
Package-wide analyzer remains EXTERNAL_BLOCKER; unrelated package files untouched.

Self-score: 100/100 task scope pending independent review.
