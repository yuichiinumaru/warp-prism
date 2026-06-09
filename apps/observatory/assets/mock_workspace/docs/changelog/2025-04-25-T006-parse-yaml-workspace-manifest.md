---
id: 2025-04-25-T006-parse-yaml-workspace-manifest
date: 2025-04-25
project: asw-observatory
task: T006
type: feature
impact:
  - parser
  - manifest
  - workspace-graph
skills:
  - coding-execution-harness
  - harness-architecture
---

# YAML workspace manifest parser implemented

## Why

The workspace manifest (`manifest.yaml`) declares expected asset counts, required agents/skills/workflows, and the changelog frontmatter schema. Without parsing it, the observatory cannot validate workspace integrity or detect missing assets.

## Changed

- Implemented manifest parsing in `workspace_parser.dart` with `counts`, `required_agents`, `required_skills`, `required_workflows`, and `changelog_frontmatter_schema` fields.
- Added validation logic to compare parsed counts against actual asset files.
- Connected manifest data to the Governance workspace for staleness detection.

## Evidence

- `assets/mock_workspace/docs/tasks/01-open/T006-parse-yaml-workspace-manifest.md` defines the parsing contract.
- `assets/mock_workspace/manifest.yaml` is the source manifest with counts: agents=9, skills=13, workflows=11, tasks=20, changelog_entries=12.
