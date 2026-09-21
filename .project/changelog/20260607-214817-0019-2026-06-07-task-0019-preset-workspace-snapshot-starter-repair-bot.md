---
date: 20260607-214817
timestamp: 20260607-214817
agent: repair-bot
task: "0019"
description: "Task 0019 — Preset Workspace Snapshot Starter"
is_rebuild_safe: true
scope: "data-layer, workspace-snapshot"
type: "feature"
---

# Task 0019 — Preset Workspace Snapshot Starter

## What changed
- Created `lib/data/models/workspace_snapshot.dart` — typed aggregate holding agents, skills, workflows, tasks (by lane), changelog entries, and scan metadata
- Created `lib/data/sources/workspace_source.dart` — abstract `WorkspaceSource` interface with `load(String rootPath)` contract
- Created `lib/data/sources/preset_local_workspace_source.dart` — filesystem scanner using `dart:io` that enumerates `.agents/` and `docs/` directories
- Created `lib/data/sources/sources.dart` — barrel export for sources layer
- Created `lib/features/workspace_snapshot/workspace_snapshot_provider.dart` — Riverpod AsyncNotifierProvider loading snapshot from configurable root path
- Created `lib/features/workspace_snapshot/workspace_snapshot_page.dart` — main surface composing DS primitives (metric tiles, asset cards, task cards, topbar, state surfaces)
- Created `lib/features/workspace_snapshot/widgets/agent_list_panel.dart` — agent card list using DSAssetCard
- Created `lib/features/workspace_snapshot/widgets/skill_list_panel.dart` — skill/sub-skill card list using DSAssetCard
- Created `lib/features/workspace_snapshot/widgets/workflow_list_panel.dart` — workflow card list using DSAssetCard
- Created `lib/features/workspace_snapshot/widgets/task_lane_panel.dart` — tasks grouped by lane using DSTaskCard
- Created `lib/features/workspace_snapshot/widgets/changelog_list_panel.dart` — changelog entries using DSGlassPanelSimple
- Updated `lib/app/router.dart` — added `/workspace-snapshot` route
- Updated `lib/data/models/data_models.dart` — added workspace_snapshot export
- Created `test/data/sources/preset_local_workspace_source_test.dart` — scanner tests for success, empty, malformed, multi-asset, and all-lane scenarios

## Why
The current plan requires EPIC-03 data layer before any useful surface exists. This task provides immediate value by reading from a real workspace path and displaying it using DS primitives. It validates the scanner/parser architecture against real data before investing in graph normalization.
