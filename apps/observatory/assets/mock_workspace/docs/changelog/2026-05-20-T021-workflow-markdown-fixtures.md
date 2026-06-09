---
id: 2026-05-20-T021-workflow-markdown-fixtures
date: 2026-05-20
project: warp-prism
task: T021
type: feature
skills:
  - harness-architecture
  - project-management
workflows:
  - gt-ganthritor-onboard
  - builder-orchestration
impact:
  - workflows
  - mock-data
  - orchestration
---

# Workflow Markdown Fixtures Baseline

Created 11 workflow .md files with frontmatter linking to skills and agents.

## Why

The workspace graph needs workflow nodes to show orchestration paths. Without workflow fixtures, the Map surface cannot render agent-to-workflow-to-skill dependency chains.

## Changed

- 11 workflow files: gt-research-orchestration, gt-code-review, gt-verify-task-completion, reviewer-orchestration, architect-orchestration, gt-create-tasks, plan-evidence-to-tasks, audit-tasks, gt-harness-architecture, gt-ganthritor-onboard, builder-orchestration
- Each workflow references uses_skills with valid skill IDs
- Frontmatter includes description, tags, and uses_skills fields

## Evidence

- 11 workflow files validated by WorkspaceMarkdownParser
- All uses_skills references resolve to existing SKILL.md files
- Task T021 marked complete
