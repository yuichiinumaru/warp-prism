---
date: 20260607-222351
timestamp: 20260607-222351
project: "warp-prism"
agent: repair-bot
task: "0813"
description: "Why"
is_rebuild_safe: true
id: "2026-06-07-task-0813-governance-drilldown-storytelling"
impact: ""
skills: ""
type: "feature"
---

## Why

Governance warnings were static text with no way to navigate to the affected asset. Without drill-down, the governance workspace is a dead-end dashboard. Without risk-story summaries, users must mentally combine boundary counts, issue panels, and hotspot analytics themselves.

## Changed

- Created `governance_drilldown_controller.dart` — translates governance diagnostics, fan-in hotspots, and raw asset IDs into `GovernanceDrilldownTarget` objects with canonical route paths (`/assets/:assetId`). Handles graceful degradation for empty/unknown asset IDs by returning null.
- Created `governance_story_summary.dart` — derives deterministic `GovernanceRiskStory` objects from live diagnostic data (boundary counts, proof gaps, orphan assets, stale references, fan-in hotspots). Renders a narrative panel with severity indicators and drill-down links. All prose is derived, not static.
- Created test `governance_drilldown_storytelling_test.dart` covering:
  - Drill-down resolution from diagnostics, hotspots, and raw asset IDs
  - Unresolved-ID fallback (empty, unknown, missing)
  - Risk-story derivation for each diagnostic category
  - Boundary health narratives (healthy and below-threshold)
  - Widget rendering: story titles, empty state, drilldown links, multi-asset links, severity badges

## Evidence

- `flutter test test/features/governance/governance_drilldown_storytelling_test.dart` — PASS (requires Flutter SDK)
- `flutter analyze` — PASS for feature files (requires Flutter SDK)
