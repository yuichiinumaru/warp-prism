---
date: 20260609-233000
timestamp: 20260609-233000
project: warp-prism
agent: builders
task: "1408"
description: "Migrate 50 deep relative imports in Observatory features/ to package-style imports"
is_rebuild_safe: true
---

# Task 1408: Observatory Package Imports Cleanup

## Summary

Migrated all 50 deep relative imports (3+ levels of `../`) in
`apps/observatory/lib/features/` to package-style imports using
`package:warp_prism_observatory/data/...`. This eliminates fragile
relative paths that break on file moves and makes the import graph
easier to audit.

## Changes

### Import migration (35 files)

All `../../../data/` (3-level) and `../../../../data/` (4-level) relative
imports in `features/` were replaced with `package:warp_prism_observatory/data/...`
imports. Target paths:

- `data/models/task_contracts.dart`
- `data/models/workspace_graph.dart`
- `data/models/changelog_contracts.dart`
- `data/models/workspace_snapshot.dart`
- `data/models/governance_diagnostics.dart`
- `data/models/data_models.dart`
- `data/sources/preset_local_workspace_source.dart`
- `data/services/workspace_graph_builder.dart`
- `data/services/workspace_graph.dart`

No circular imports introduced. No barrel consolidation performed (explicit
per-file imports retained for auditability).

### Affected feature directories

- `features/asset_detail/` (6 files)
- `features/governance/` (6 files)
- `features/history/` (2 files)
- `features/map/` (4 files)
- `features/operate/` (6 files)
- `features/overview/` (3 files)
- `features/workspace_snapshot/` (8 files)

## Verification

- `flutter analyze apps/observatory/`: 0 errors, 0 warnings (362 pre-existing info-level lint hints)
- `flutter test test/boundaries/boundary_test.dart`: 4/4 PASS
- `flutter test` (Observatory): 602 PASS, 51 FAIL (pre-existing assertion failures, unrelated to import changes)
- Zero deep relative imports remain in `lib/features/` (verified via `rg "import '\.\./\.\./\.\."`)
