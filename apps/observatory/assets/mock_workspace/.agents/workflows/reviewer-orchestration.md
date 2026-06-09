---
name: reviewer-orchestration
description: Full reviewer orchestration lifecycle from task receipt through multi-tiered review, security audit, scoring, and task promotion to completed.
uses_skills:
  - code-quality-harness
  - remediation-harness
  - agent-wiki
kind: orchestration
---

# reviewer-orchestration

## Purpose

Drive the complete reviewer lifecycle: receive completed work from builder, run deterministic checks, adversarial review, security audit, score the task, and promote to completed or return for remediation.

## Steps

1. Receive task from `docs/tasks/02-doing/`
2. Move task to `docs/tasks/03-review/`
3. Run deterministic quality checks (lint, test, coverage)
4. Perform adversarial review for edge cases
5. Execute security audit if task touches critical paths
6. Score task and write review evidence
7. Promote to `docs/tasks/04-completed/` or return to doing

## Skills Used

- `code-quality-harness`: Review rules and scoring criteria
- `remediation-harness`: Routing when issues require fixes
- `agent-wiki`: Recording review patterns and learnings

## Artifacts Produced

- Task review evidence and scoring
- Security audit reports (when applicable)
- Changelog entries for completed tasks
