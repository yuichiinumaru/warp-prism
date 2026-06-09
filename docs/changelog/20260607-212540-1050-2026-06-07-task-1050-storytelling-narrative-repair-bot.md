---
date: 20260607-212540
timestamp: 20260607-212540
agent: repair-bot
task: "1050"
description: "Storytelling demo narrative pass"
is_rebuild_safe: true
id: "2026-06-07-task-1050-storytelling-narrative"
impact: ""
project: "warp-prism"
skills: "design-system, story-panel, demo-narrative, documentation, design-system-harness, project-management"
type: "feature"
---

# Storytelling demo narrative pass

Extended DSStoryPanel with a narrative contract that supports four insight layers (insight, evidence, risk, connection) required by the EPIC 10 demo walkthrough.

## Why

EPIC 10 needs a coherent demo story, not just polished widgets. Without a written narrative contract tying the five epic questions to real surfaces, the observatory can ship visually polished components that still fail the user's comprehension test.

## Changed

- Added `InsightRiskLevel` enum (none/low/medium/high/critical) to `ds_story_panel.dart`
- Added `DSStoryNarrativeInsight` class extending `DSStoryInsight` with `evidence`, `riskLevel`, and `connection` fields
- Created `docs/demo/epic-10-demo-script.md` — full walkthrough covering Map, Operate, History, Governance, and Connections beats
- Created `test/design_system/story_panel_narrative_test.dart` — 12 tests validating the narrative contract model
- All five epic acceptance questions mapped to real file-backed surfaces or labeled as blocked

## Evidence

- `flutter test test/design_system/story_panel_narrative_test.dart` — BLOCKED (Flutter SDK not installed)
- `flutter analyze` — BLOCKED (Flutter SDK not installed)
- Narrative contract model: testable without runtime, validated structurally
