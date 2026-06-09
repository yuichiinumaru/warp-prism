---
id: T021
title: "Completed: workflow markdown fixtures"
status: completed
priority: high
owner: gt-task-architect
created: "2026-05-12"
updated: "2026-05-19"
skills:
  - harness-architecture
  - project-management
workflows:
  - gt-create-tasks
  - gt-harness-architecture
depends_on:
  - T018
  - T019
proof_state: complete
review_score: 9.0
---

# Completed: Workflow Markdown Fixtures

## Goal
Create all 11 required workflow .md files with YAML frontmatter under assets/mock_workspace/.agents/workflows/.

## Scope
- 11 workflow files: gt-ganthritor-onboard, architect-orchestration, builder-orchestration, reviewer-orchestration, gt-create-tasks, plan-evidence-to-tasks, audit-tasks, gt-harness-architecture, gt-code-review, gt-verify-task-completion, gt-research-orchestration
- Frontmatter: name, description, uses_skills, kind

## Exit Conditions
- [x] 11 workflow .md files exist in assets/mock_workspace/.agents/workflows/
- [x] Each file has valid YAML frontmatter with all required fields
- [x] All referenced skills resolve to existing SKILL.md files

## Verification Commands
```bash
ls assets/mock_workspace/.agents/workflows/*.md | wc -l
grep -l "^name:" assets/mock_workspace/.agents/workflows/*.md | wc -l
```

## Completion Evidence
- **Files created**: 11 workflow .md files in assets/mock_workspace/.agents/workflows/
- **Validation**: ls produces 11; all have valid frontmatter
- **Reviewer**: gt-task-architect
- **Completion date**: 2026-05-19
