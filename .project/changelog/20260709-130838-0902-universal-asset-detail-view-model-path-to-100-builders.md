---
date: 20260709-130838
timestamp: 20260709-130838
project: "warp-prism"
agent: builders
task: "0902"
description: "Universal asset detail view-model verified with Riverpod wiring"
is_rebuild_safe: true
id: "2026-07-09-task-0902-universal-asset-detail-view-model-path-to-100"
impact: "asset-detail"
skills: "flutter-harness"
type: "feature"
---

# Task 0902: Universal Asset Detail View Model

## Summary

Closed the 2026-06-19 re-review path-to-100 for the universal asset detail view-model: Riverpod descriptor providers, production route consumption, related-assets derivation, fallback link preservation, and scoped analyzer/test proof.

## Changes

- Extended `AssetDetailDescriptor` with `relatedAssets` and fallback link retention.
- Upgraded `asset_detail_controller.dart` with `assetDetailDescriptorProvider` and `selectedAssetDetailDescriptorProvider` over `workspaceGraphAsyncProvider`.
- Wired `/assets/:assetId` `AssetDetailPage` to mapper-produced `AssetDetailView` (no placeholder).
- Expanded unit/provider tests and deep-link integration tests for production wiring.
- Cleaned core presentation const/deprecation infos in asset detail views/shell.

## Verification

- `dart format` on asset_detail + page + tests — PASS
- `flutter analyze` on domain/application/page/core presentation/tests — PASS (0 issues)
- `flutter test test/features/asset_detail/asset_detail_descriptor_test.dart test/app/deep_link_fallback_test.dart` — PASS (38 tests)
