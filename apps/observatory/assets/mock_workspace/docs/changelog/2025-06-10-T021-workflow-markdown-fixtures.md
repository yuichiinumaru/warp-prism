---
id: 2025-06-10-T021-workflow-markdown-fixtures
date: 2025-06-10
project: asw-observatory
task: T021
type: feature
impact:
  - harness-map
  - workflows
  - orchestration
skills:
  - harness-architecture
  - project-management
---

# Workflow markdown fixtures created

## Why

The workspace graph needs 11 workflow nodes to demonstrate orchestration patterns. Without workflow fixtures with proper frontmatter (name, description, uses_skills, kind), the graph would show agents and skills but no workflow connections.

## Changed

- Created 11 workflow markdown files under `assets/mock_workspace/.agents/workflows/`.
- Each workflow has valid YAML frontmatter with `name`, `description`, `uses_skills`, and `kind` fields.
- Workflow kinds include: `onboard`, `orchestration`, `planning`, `audit`, `review`, `verification`, `research`.
- Connected workflows to skills via `uses_skills` references that resolve to existing skill directories.
- Verified all workflow→skill references are bidirectional (skills list their workflows in frontmatter).

## Evidence

- `assets/mock_workspace/docs/tasks/04-completed/T021-completed-workflow-markdown-fixtures.md` documents the completion.
- `assets/mock_workspace/manifest.yaml` declares `counts.workflows: 11`.
