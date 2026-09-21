---
date: 20260709-160956
timestamp: 20260709-160956
project: "warp-prism"
agent: builders
task: "0813"
description: "Governance drill-down and risk storytelling"
is_rebuild_safe: true
id: "2026-07-09-task-0813-governance-drilldown-storytelling"
impact: "Governance warnings become navigable; risk stories stay diagnostic-sourced"
skills: "flutter-harness,coding-execution-harness"
type: "feature"
---

## Why

Governance warnings and hotspots previously terminated as static text. Risk
stories were not composed into the live Governance page, so the workspace felt
like a dead-end dashboard even after 0810–0812 panels existed.

## Changed

- Hardened `governance_drilldown_controller.dart` with navigable/unresolved
  targets and `AssetSelectionController.detailRoute` for `/assets/:assetId`.
- Rebuilt `governance_story_summary.dart` on `PrismStoryPanel` with
  diagnostic-derived narratives and drill-down footer links.
- Wired `onDrilldown` into issue rows and fan-in hotspot rows.
- Composed stories + issue groups + hotspots into `GovernanceOverviewPage` with
  default GoRouter navigation and non-blocking unresolved fallback.
- Expanded `governance_drilldown_storytelling_test.dart` and adjusted boundary
  overview expectations for dual surfaces after composition.

## Evidence

- `flutter test test/features/governance/governance_drilldown_storytelling_test.dart` — 36/36 PASS
- `flutter test test/features/governance/` — 94/94 PASS
- `dart analyze lib/features/governance` — 0 errors / 0 warnings
