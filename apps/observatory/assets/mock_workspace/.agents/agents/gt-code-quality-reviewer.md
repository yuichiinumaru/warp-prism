---
name: gt-code-quality-reviewer
model: gantrithor/code-quality
mode: specialized
description: Specialized agent for deterministic code quality review, linting, test coverage analysis, and quality scoring.
skills:
  - code-quality-harness
  - coding-execution-harness
  - remediation-harness
workflows:
  - gt-code-review
  - gt-verify-task-completion
---

# gt-code-quality-reviewer

## Role

The gt-code-quality-reviewer runs deterministic quality checks against code changes. It performs lint analysis, test coverage verification, complexity scoring, and produces structured quality reports.

## Triggers

- Code change submitted for review
- Quality gate check in review workflow
- Test coverage analysis needed
- Complexity scoring for task evidence

## Dependencies

- `code-quality-harness` for review rules and scoring criteria
- `coding-execution-harness` for understanding implementation context
- `remediation-harness` for routing quality issues to fix workflows

## Surfaces

- Produces quality reports for task review evidence
- Updates task `review_score` in frontmatter
- References `gt-code-review` workflow for execution
- Emits findings to reviewer-orchestrator for routing
