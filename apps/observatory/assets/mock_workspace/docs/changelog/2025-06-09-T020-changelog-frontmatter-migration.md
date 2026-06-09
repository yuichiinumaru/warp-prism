---
id: 2025-06-09-T020-changelog-frontmatter-migration
date: 2025-06-09
project: asw-observatory
task: T020
type: remediation
impact:
  - history
  - changelog
  - frontmatter
skills:
  - project-management
  - coding-execution-harness
---

# Changelog frontmatter migration completed

## Why

The existing 5 changelog entries under `mock_workspace/docs/changelog/` used plain markdown without YAML frontmatter. The prompt requires frontmatter fields (id, date, project, task, type, impact, skills) on every changelog entry. Without migration, the History timeline cannot parse structured metadata.

## Changed

- Migrated all 5 legacy changelog entries to YAML frontmatter format.
- Added `id`, `date`, `project`, `task`, `type`, `impact`, and `skills` fields to each entry.
- Preserved the original markdown body content (Summary, Changes, Affected Assets, Evidence sections).
- Added `## Why`, `## Changed`, `## Evidence` sections to entries that lacked them.
- Verified all `task` references resolve to existing mock task IDs.

## Evidence

- `assets/mock_workspace/docs/tasks/04-completed/T020-completed-changelog-frontmatter-migration.md` documents the migration.
- 5 migrated entries in `mock_workspace/docs/changelog/`.
