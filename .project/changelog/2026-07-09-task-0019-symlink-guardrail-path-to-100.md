---
date: 20260709-211900
timestamp: 20260709-211900
project: "warp-prism"
agent: gt-flutter-engineer
task: "0019"
description: "Task 0019 — symlink followLinks:false + skippedSymlinks + real tests"
is_rebuild_safe: true
scope: "data-layer, workspace-snapshot, scanner"
type: "fix"
---

# Task 0019: Preset Workspace Snapshot — symlink guardrail path-to-100

## Summary

Independent re-review (2026-07-09, S=74) rejected false symlink-safe claims.
Implemented real symlink policy on `PresetLocalWorkspaceSource`, recorded
provenance on `WorkspaceScanMetadata.skippedSymlinks`, and added real tests.

## Changes

- `apps/observatory/lib/data/sources/preset_local_workspace_source.dart`
  - `followLinks` constructor flag, **default `false`**
  - all directory listing via `Directory.list(followLinks: followLinks)`
  - scan-root and entry symlink detection via `FileSystemEntity.isLink`
  - skipped paths recorded on metadata
- `apps/observatory/lib/data/models/workspace_snapshot.dart`
  - added `WorkspaceScanMetadata.skippedSymlinks` (`List<String>`, default `[]`)
- `apps/observatory/test/data/sources/preset_local_workspace_source_test.dart`
  - symlink scan-root skip (default)
  - symlink scan-root follow (`followLinks: true`)
  - symlink entry skip inside real directory
- Production snapshot UI prefer_const infos cleared via `dart fix`
  (`lib/features/workspace_snapshot/**` — 13 const fixes)

## Verification

```text
# apps/observatory
dart analyze --format=machine lib/features/workspace_snapshot/ \
  lib/data/sources/ lib/data/models/workspace_snapshot.dart
# → 0 lines (0 INFO / 0 WARNING / 0 ERROR)

flutter test test/data/sources/preset_local_workspace_source_test.dart
# → 12/12 passed (9 prior + 3 symlink cases)

flutter test test/features/workspace_snapshot/workspace_snapshot_page_test.dart \
  --name 'renders '
# → 4/4 passed (loading / metrics / error / empty)
```

Lane remains `02-doing` pending independent re-review (do not auto-promote).
