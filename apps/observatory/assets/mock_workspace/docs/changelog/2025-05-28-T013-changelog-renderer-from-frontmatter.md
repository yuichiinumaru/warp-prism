---
id: 2025-05-28-T013-changelog-renderer-from-frontmatter
date: 2025-05-28
project: asw-observatory
task: T013
type: feature
impact:
  - history
  - changelog
  - timeline
skills:
  - design-system-harness
  - project-management
---

# Changelog renderer built from frontmatter

## Why

The History workspace needs to render changelog entries as a timeline grouped by project and milestone. Without a renderer that reads frontmatter fields (id, date, project, task, type, impact, skills), the timeline would show raw markdown without structured metadata.

## Changed

- Built `DSTimelineGrouped` renderer that reads changelog frontmatter and groups entries by `project` field.
- Each entry renders `date`, `type` badge, `impact` pills, and linked `task` reference.
- Connected entries to the graph model via `changedBy` edge to the referenced task.
- Added `DSTimelineMarker` styling per entry type (feature=cyan, audit=violet, remediation=amber, governance=rose).

## Evidence

- `assets/mock_workspace/docs/tasks/02-doing/T013-build-changelog-renderer-from-frontmatter.md` defines the renderer contract.
- `lib/design_system/organisms/ds_timeline.dart` (207 lines) implements the timeline.
