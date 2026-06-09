---
name: builder-orchestration
description: Full builder orchestration lifecycle from task pickup through implementation, testing, design system work, and handoff to reviewer.
uses_skills:
  - coding-execution-harness
  - code-quality-harness
  - frontend-quality-harness
kind: orchestration
---

# builder-orchestration

## Purpose

Drive the complete builder lifecycle: pick up approved tasks from the open lane, implement code changes, run tests, build design system components, and hand off completed work to the reviewer.

## Steps

1. Pick up tasks from `docs/tasks/01-open/`
2. Move tasks to `docs/tasks/02-doing/`
3. Implement code changes with inline quality checks
4. Run test suite and verify coverage
5. Build design system components if required
6. Produce completion evidence
7. Hand off to reviewer-orchestration

## Skills Used

- `coding-execution-harness`: Code generation and iteration
- `code-quality-harness`: Inline quality gates during implementation
- `frontend-quality-harness`: Design system compliance checks

## Artifacts Produced

- Updated task files in doing lane
- Implementation evidence (screenshots, test output, coverage)
- Code changes ready for review
