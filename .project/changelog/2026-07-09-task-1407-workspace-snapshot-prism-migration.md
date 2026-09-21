---
date: 20260709-220613
timestamp: 20260709-220613
agent: builders
task: "1407"
description: "Task 1407 — Workspace Snapshot DS* → Prism* Residual Migration"
is_rebuild_safe: true
---

# Task 1407 — Workspace Snapshot DS* → Prism* Residual Migration

> **Date**: 2026-07-09
> **Executor**: gt-flutter-engineer
> **Scope**: `apps/observatory/lib/features/workspace_snapshot/**`,
>   `apps/observatory/test/features/workspace_snapshot/`
> **Status**: Changelog draft / local ledger only (not changelog-engine published)

## Summary

Resolved residual **F-1407-03** from the Observatory test retirement audit:
production `workspace_snapshot` still constructed hidden `DS*` APIs through the
public Prism barrel, which blocked suite load for
`workspace_snapshot_page_test.dart` and any test importing the product router.

Migrated the feature to public `Prism*` typedefs from
`package:warp_prism_ui/warp_prism_ui.dart`. No product behavior redesign;
read-only snapshot surface preserved.

## Changes

### Production (`lib/features/workspace_snapshot/`)

- Renamed all consumer `DS*` tokens/widgets to `Prism*`
  (`PrismStateSurface`, `PrismColors`, `PrismMetricTile`, `PrismTopbar`,
  `PrismAssetCard`, `PrismTaskCard`, `PrismGraphCanvas`, `PrismDetailInspector`,
  etc.).
- Graph panel now constructs `PrismGraphNode` / `PrismGraphEdge` (public aliases)
  instead of unexported `GraphNode` / `GraphEdge` types.
- Doc comments updated to Prism wording; local projection models in
  `workspace_snapshot_provider.dart` unchanged.

### Tests

- `workspace_snapshot_page_test.dart`: removed deferred-keep annotation;
  suite now loads and passes (loading / metrics / error / empty).
- Enhanced model suite unchanged and still green.

## Verification

```bash
flutter test apps/observatory/test/features/workspace_snapshot/
# → All tests passed (+29)

flutter test apps/observatory/
# → All tests passed (+736)
```

## Residual notes

- Observatory package suite is fully green after this residual.
- Broader package may still use `ds_compat` elsewhere; out of Task 1407 residual
  scope. F-1407-01/02 were already applied earlier in this task.
