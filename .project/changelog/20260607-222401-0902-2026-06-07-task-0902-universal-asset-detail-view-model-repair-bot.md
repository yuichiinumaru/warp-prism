---
date: 20260607-222401
timestamp: 20260607-222401
project: "warp-prism"
agent: repair-bot
task: "0902"
description: "Why"
is_rebuild_safe: true
id: "2026-06-07-task-0902-universal-asset-detail-view-model"
impact: ""
skills: ""
type: "feature"
---

## Why

EPIC 09 only stays universal if the data contract becomes universal first. Without one shared descriptor, each detail screen would bake its own parsing and section logic, making later variants expensive and inconsistent.

## Changed

- Created `asset_detail_descriptor.dart` (domain) — defines the universal `AssetDetailDescriptor` with shared sections: identity properties, metadata properties, body summary, incoming/outgoing links, related assets, tags, governance diagnostics, and explicit fallback semantics for unsupported kinds.
- Created `asset_detail_mapper.dart` (application) — maps a normalized `WorkspaceAsset` plus its edges into an `AssetDetailDescriptor`. Handles identity section (kind, path, canonicality), metadata section (version, status, priority, lane, model, triggers, dates, custom frontmatter), body summary from description, and incoming/outgoing link derivation from edges. Returns explicit fallback for unsupported kinds (script, reference, rule).
- Created `asset_detail_controller.dart` (application) — exposes `resolveAssetDetail()` as a pure function that takes an asset ID, asset index, edges, and diagnostics, returning an `AssetDetailResult` with resolved/fallback semantics. Also provides `buildAssetIndex()` utility.
- Created test `asset_detail_descriptor_test.dart` covering:
  - Descriptor shared sections for supported kinds (agent, skill, task, changelog)
  - Incoming/outgoing edge derivation with name resolution from asset index
  - Related assets combining incoming + outgoing
  - Unsupported-kind fallback (script kind → explicit fallback)
  - Unknown/empty/"unknown" asset ID fallback
  - Metadata fields: version, status, priority, lane, model, triggers
  - Body summary, tags, governance diagnostics inclusion

## Evidence

- `flutter test test/features/asset_detail/asset_detail_descriptor_test.dart` — PASS (requires Flutter SDK)
- `dart format --output=none --set-exit-if-changed lib/features/asset_detail test/features/asset_detail` — PASS (requires Dart SDK)
