# EPIC 07 — Warp-Prism History Surface

> **Planning Status**: Active Epic
> **Executable?**: No — planning artifact only.
> **Promotion Gate**: Promote after changelog fixtures and impact edges exist.

## Goal

Build the History surface that turns changelog entries into timeline, project story, and impact-story views connected to tasks, skills, workflows, and agents.

## Source Evidence

- `prompt.txt` requires a changelog timeline with filters by project/type/skill/task and an impact path: changelog → task → skill/workflow.
- `research.md` recommends Timeline, Project Story, and Impact Story modes.
- `draft.md` reports only 5 changelog examples and missing frontmatter in the generated repo.

## Scope

- Chronological changelog timeline.
- Filters by project, type, task, skill, and impact tags.
- Story grouping by project/milestone/task.
- Impact path visualization.
- Concise data storytelling panels.

## Out of Scope

- Changelog editing or generation.
- Release publication workflows.
- Real parent Ganthritor changelog ingestion.

## Candidate Stories

- Changelog parser integration.
- Timeline organism usage.
- Filter and grouping controls.
- Story mode panels.
- Impact path links.

## Dependencies

- EPIC 02 for changelog corpus.
- EPIC 03 for changelog graph edges.
- EPIC 04 for shell route/layout.

## Acceptance Criteria for Epic Completion

- Changelog entries render chronologically and are filterable.
- Entries link to related tasks and skills/workflows through normalized edges.
- Story mode explains why changes matter, not just what changed.
- Empty/malformed changelog states are handled gracefully.
