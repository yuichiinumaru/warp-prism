---
id: 2025-06-08-T019-skill-hierarchy-fixtures
date: 2025-06-08
project: asw-observatory
task: T019
type: feature
impact:
  - harness-map
  - skills
  - hierarchy
skills:
  - harness-architecture
  - indexing-skills
---

# Mock skill hierarchy fixtures created

## Why

The skill hierarchy is the deepest part of the workspace graph: 13 super-skills each containing sub-skills, workflows, references, and scripts. Without realistic fixtures, the Map graph would show flat skill nodes without the `contains` edges that demonstrate hierarchy.

## Changed

- Created 13 super-skill directories under `assets/mock_workspace/.agents/skills/`.
- Each super-skill has a `SKILL.md` with frontmatter (name, description, triggers, sub_skills, canonicality, tags).
- Created sub-skill, workflow, reference, and script files for each super-skill.
- Total file count: 50+ files across the skill hierarchy.
- Verified `contains` edges: every sub-skill references its parent super-skill.

## Evidence

- `assets/mock_workspace/docs/tasks/04-completed/T019-completed-mock-skill-hierarchy-fixtures.md` documents the completion.
- `assets/mock_workspace/manifest.yaml` declares `counts.skills: 13`.
