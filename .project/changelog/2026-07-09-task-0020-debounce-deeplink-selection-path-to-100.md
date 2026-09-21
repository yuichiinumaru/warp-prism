---
date: 20260709-235900
timestamp: 20260709-235900
project: "warp-prism"
agent: gt-flutter-engineer
task: "0020"
description: "Real search debounce, deep-link one-shot, selection tests"
is_rebuild_safe: true
id: "task-0020-debounce-deeplink-selection-path-to-100"
type: "fix"
---

# Task 0020: Enhanced Workspace Snapshot — Debounce / Deep-link / Selection path-to-100

## Summary

Addressed independent re-review S=76 blockers for Task 0020: replaced passthrough
search “debounce” with a real Timer-backed Riverpod Notifier, fixed deep-link
selection thrash (one-shot per asset id), and added honest provider + widget
proof for debounce coalescing, card/graph select, deep-link open, and clear closes.

## Changes

- `DebouncedSearchQuery` Notifier + `kSearchDebounceDuration` (300ms); rapid
  keystrokes coalesce to last value after quiet period; timer cancelled on dispose.
- `WorkspaceSnapshotPage` converted to `ConsumerStatefulWidget` with
  `_appliedDeepLinkId` one-shot (init + assetId change only).
- Public `projectGraph` for pure projection tests; graph panel `enablePhysics`
  flag for stable tests.
- Tests: enhanced suite **33** (was 25 model-only); page suite **8** (was 4).
  Combined run **41/41** green.
- Completion Evidence rewritten to match live counts (no invented +29).

## Verification

```bash
cd apps/observatory
flutter analyze lib/features/workspace_snapshot/
# No issues found!

flutter test test/features/workspace_snapshot/workspace_snapshot_enhanced_test.dart \
  test/features/workspace_snapshot/workspace_snapshot_page_test.dart
# All tests passed! (41)
```

## Notes

- Lane remains `docs/tasks/02-doing/` per wave instruction (no auto-promote).
- Residual risk: prerequisite Task 0019 still rejected this wave (symlink/evidence).

**Author**: gt-flutter-engineer
