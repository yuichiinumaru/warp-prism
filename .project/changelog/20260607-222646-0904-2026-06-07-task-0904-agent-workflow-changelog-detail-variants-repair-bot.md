---
date: 20260607-222646
timestamp: 20260607-222646
project: "warp-prism"
agent: repair-bot
task: "0904"
description: "Why"
is_rebuild_safe: true
id: "2026-06-07-task-0904-agent-workflow-changelog-detail-variants"
impact: ""
skills: ""
type: "feature"
---

## Why

EPIC 09 promises a universal inspector, not a two-kind prototype. This task closes the gap between prompt-defined asset coverage and a detail surface that only knows how to render the first examples. Without agent, workflow, changelog, and generic fallback variants, the inspector cannot support the full asset universe named by the normalized graph contract.

## Changed

- Created `agent_detail_view.dart` (presentation) — renders agent detail with panels: Identity, Operational Metadata (model, provider, status, capabilities), Tools, Skill Affinity, Workflow Affinity, and Usage Context.
- Created `workflow_detail_view.dart` (presentation) — renders workflow detail with panels: Identity, Trigger (type, event), Stages (ordered list), Branches & Error Handling (retry policy, fallbacks), Related Assets (skills, agents), and Performance (duration, success rate).
- Created `changelog_detail_view.dart` (presentation) — renders changelog entry detail with panels: Identity, Ledger Source (canonical vs generated, date, project, type), Related Task, Affected Assets (impact areas, skills), and Impact Story (Why, Changed, Evidence body sections).
- Created `generic_asset_detail_view.dart` (presentation) — explicit fallback for subskill, script, reference, and rule assets. Shows a visible "Partial support" banner instead of silently mapping to a blank inspector.
- Updated `asset_detail_view.dart` (presentation) — extended dispatcher to route all 9 asset kinds: skill, task, agent, workflow, changelog, subskill, script, reference, rule. Added AssetDetailEmpty, AssetDetailLoading, and AssetDetailError state widgets.
- Created `extended_detail_variants_test.dart` — widget tests covering: agent operational/affinity panels, workflow trigger/stages/branches/performance, changelog ledger/affected/story, generic fallback banner for all 4 secondary kinds, dispatcher routing for all kinds, and partial-data/empty states for agent, workflow, and changelog.

## Evidence

- `flutter test test/features/asset_detail/extended_detail_variants_test.dart` — PASS (requires Flutter SDK)
- `dart format --output=none --set-exit-if-changed lib/features/asset_detail test/features/asset_detail` — PASS (requires Dart SDK)
