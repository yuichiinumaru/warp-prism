---
name: architect-orchestration
description: Full architect orchestration lifecycle from PRD intake through task decomposition, planning review, and task handoff to builder.
uses_skills:
  - project-management
  - harness-architecture
  - development-methodologies
kind: orchestration
---

# architect-orchestration

## Purpose

Drive the complete architect lifecycle: receive a PRD or goal, decompose it using RF8 methodology, create auditable tasks, review planning evidence, and hand off approved tasks to the builder wave.

## Steps

1. Receive PRD or goal statement
2. Apply RF8 decomposition: Goal → Domain → Feature → Representation → Specs → Behaviour → Test → Eval
3. Create tasks in `docs/tasks/00-planning/`
4. Review planning evidence and dependencies
5. Promote approved tasks to `docs/tasks/01-open/`
6. Hand off task batch to builder-orchestration

## Skills Used

- `project-management`: Task creation and lane management
- `harness-architecture`: Governance rules for task structure
- `development-methodologies`: RF8 decomposition framework

## Artifacts Produced

- Task files in planning and open lanes
- Planning evidence documents
- Dependency graph for task batch
