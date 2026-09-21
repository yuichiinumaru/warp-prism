---
date: 20260710-011830
timestamp: 20260710-011830
agent: builders
task: "0905"
description: "Changelog: Task 0905 — Universal AssetDetailView in responsive shell"
is_rebuild_safe: true
---

# Changelog: Task 0905 — Universal AssetDetailView in responsive shell

> **Date**: 2026-07-09
> **Task**: 0905
> **Type**: fix | feature
> **Status**: Ready for re-review (lane remains `02-doing` per executor instruction)
> **Author**: gt-flutter-engineer

## Summary

Path-to-100 after 84/100 rejection: Map, Operate, and History detail content
now flow through descriptor adapters → universal `AssetDetailView` instead of
surface-local inspectors. Medium overlay scrim gains dismiss semantics.
Deep-link full-page vs in-shell breakpoints documented as intentional contract.

## Files created/modified

| File | Action |
|------|--------|
| `apps/observatory/lib/features/asset_detail/application/surface_detail_adapters.dart` | Created — WorkspaceAsset / TaskProjection / HistoryEntry → descriptor |
| `apps/observatory/lib/features/asset_detail/asset_detail.dart` | Export adapters |
| `apps/observatory/lib/features/map/map_workspace_page.dart` | detailBuilder → AssetDetailView |
| `apps/observatory/lib/features/operate/operate_workspace_view.dart` | detailBuilder → AssetDetailView |
| `apps/observatory/lib/features/history/presentation/history_page.dart` | _buildDetailPanel → AssetDetailView |
| `apps/observatory/lib/features/asset_detail/presentation/responsive_detail_shell.dart` | Scrim Semantics + deep-link contract docs |
| `apps/observatory/test/features/asset_detail/responsive_detail_integration_test.dart` | Medium scrim semantics test |
| `apps/observatory/test/features/history/history_page_test.dart` | Assert AssetDetailView / universal sections |
| `packages/warp_prism_ui/lib/src/molecules/ds_draggable_card.dart` | Compile unblock: drop invalid empty CustomSemanticsAction map |

## Validation

- `flutter test test/features/asset_detail/responsive_detail_integration_test.dart` — **26** pass (was 25 + scrim semantics)
- `flutter test test/features/history/history_page_test.dart` — pass
- `flutter test test/features/operate/operate_board_surface_test.dart` + `operate_task_detail_inspector_test.dart` — pass
- Scoped analyze — 0 errors (prefer_const infos only)
