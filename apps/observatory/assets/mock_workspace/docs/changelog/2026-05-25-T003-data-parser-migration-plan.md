---
id: 2026-05-25-T003-data-parser-migration-plan
date: 2026-05-25
project: warp-prism
task: T003
type: feature
skills:
  - project-management
  - development-methodologies
workflows:
  - architect-orchestration
impact:
  - parser
  - planning
  - migration
---

# Data Parser Migration Planned

Planned the migration from legacy heading-based markdown to frontmatter-based parsing for all workspace asset types.

## Why

The existing parser used regex-based heading extraction which was fragile and could not handle nested YAML structures. A frontmatter-first approach enables typed metadata extraction for all asset kinds.

## Changed

- Scoped parser migration into 3 phases: FrontmatterParser, WorkspaceMarkdownParser, kind-specific enrichers
- Defined parsing contract: all assets must have --- delimited YAML frontmatter
- Planned error handling: ParseException with file path context
- Linked to T010 (parser pipeline) and T013 (changelog renderer) as implementation tasks

## Evidence

- Task T003 created in 00-planning lane
- Parsing contract documented in task body
- Downstream tasks T010 and T013 reference T003 as prerequisite
