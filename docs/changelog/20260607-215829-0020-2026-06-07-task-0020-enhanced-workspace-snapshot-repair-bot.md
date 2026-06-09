---
date: 20260607-215829
timestamp: 20260607-215829
agent: repair-bot
task: "0020"
description: "Why"
is_rebuild_safe: true
id: "task-0020-enhanced-workspace-snapshot"
impact: ""
project: "warp-prism"
skills: "workspace-snapshot, search, graph, detail-inspector, code-review"
type: "feature"
---

## Why

The basic workspace snapshot (Task 0019) shows what exists in the workspace but
lacks search, filtering, graph visualization, and asset detail inspection. Without
these features, the snapshot is a static list rather than a credible observatory
surface.

## Changed

- Extended `WorkspaceSnapshot` model with relationship edges, derived metrics
  (blocked tasks, review queue, governance warnings), search, and filter methods.
- Added global search bar with debounced filtering across all asset types.
- Added filter chips for asset kind, task lane, and provenance classification.
- Added graph tab with containment and operational projection modes using
  `DSGraphCanvas`.
- Added asset detail inspector panel that opens on card click, graph node click,
  or deep-link navigation using `DSDetailInspector`.
- Added deep-link routes for agent, skill, workflow, task, and changelog assets.
- Added derived metric tiles showing computed values beyond raw counts.
- Updated all list panels with onTap handlers for detail inspection.
- Added comprehensive tests for search, filtering, graph projection, and
  derived metrics.

## Evidence

- All new files created under `lib/features/workspace_snapshot/widgets/` and
  `lib/data/services/`.
- Tests in `test/features/workspace_snapshot/workspace_snapshot_enhanced_test.dart`.
- Deep-link routes in `lib/app/router.dart`.
