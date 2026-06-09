---
id: 2025-04-01-T003-data-parser-migration
date: 2025-04-01
project: asw-observatory
task: T003
type: feature
impact:
  - parser
  - data-layer
  - frontmatter
skills:
  - coding-execution-harness
  - harness-architecture
---

# Data parser migration planned

## Why

The workspace parser needed to evolve from raw YAML loading to frontmatter-aware markdown parsing. The prompt requires `.md` files with YAML frontmatter, not pure `.yaml` files.

## Changed

- Mapped the migration path from `workspace_parser.dart` YAML-only to frontmatter + markdown body parsing.
- Identified 40+ mock files across agents, skills, workflows, tasks, and changelog that need frontmatter.
- Defined the frontmatter schema per asset kind (id, name, description, skills, workflows, etc.).
- Planned backward compatibility with existing YAML-only mocks during transition.

## Evidence

- `assets/mock_workspace/docs/tasks/00-planning/T003-plan-data-parser-migration.md` defines the migration contract.
- `lib/data/parsers/workspace_parser.dart` (394 lines) is the current parser.
