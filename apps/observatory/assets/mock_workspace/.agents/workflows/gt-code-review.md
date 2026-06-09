---
name: gt-code-review
description: Multi-tiered code review workflow with deterministic checks, adversarial review, scoring, and task routing.
uses_skills:
  - code-quality-harness
  - project-management
  - agent-wiki
kind: review
---

# gt-code-review

## Purpose

Execute a structured multi-tiered code review. Combines deterministic automated checks with adversarial manual review, produces a quality score, and routes the task based on findings.

## Steps

1. Receive task with implementation evidence
2. Run deterministic checks: lint, test, coverage, complexity
3. Perform adversarial review: edge cases, security, performance
4. Score the implementation (0-100)
5. Write review evidence into task completion section
6. Route: promote to completed if score >= threshold, else return to doing

## Skills Used

- `code-quality-harness`: Review rules, scoring criteria, quality gates
- `project-management`: Task routing and lane management
- `agent-wiki`: Recording review patterns for future reference

## Artifacts Produced

- Review report with score
- Task completion evidence
- Routing decision record
