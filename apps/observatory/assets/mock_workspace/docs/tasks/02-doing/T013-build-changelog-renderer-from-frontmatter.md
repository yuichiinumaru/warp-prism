---
id: T013
title: "Build changelog renderer from frontmatter"
status: doing
priority: medium
owner: builder-orchestrator
created: "2026-06-04"
updated: "2026-06-07"
skills:
  - coding-execution-harness
  - frontend-quality-harness
workflows:
  - builder-orchestration
depends_on:
  - T010
proof_state: none
review_score: 6.5
---

# Build Changelog Renderer from Frontmatter

## Goal
Create a widget that reads parsed changelog frontmatter and renders entries as a timeline with metadata badges (project, task, type, impact, skills).

## Scope
- Parse changelog .md files using parseChangelog()
- Render each entry as a DSTimelineMarker with metadata pills
- Filter by project, type, and date range
- Link each entry to its referenced task

## Exit Conditions
- [ ] Changelog screen renders all 12+ mock changelog entries
- [ ] Each entry shows date, title, project, type, and linked skills
- [ ] Clicking a task reference navigates to the task detail view

## Verification Commands
```bash
flutter test test/features/governance/changelog_renderer_test.dart
```

## Completion Evidence
*Not yet completed — task is in doing lane.*
