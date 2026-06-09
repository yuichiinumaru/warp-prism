---
name: gt-verify-task-completion
description: Verification workflow that validates task completion evidence against exit conditions, proof state, and governance requirements.
uses_skills:
  - code-quality-harness
  - project-management
  - harness-architecture
kind: verification
---

# gt-verify-task-completion

## Purpose

Verify that a task claiming completion actually meets all exit conditions. Checks proof state, evidence quality, governance compliance, and cross-references before allowing promotion to completed lane.

## Steps

1. Load task file and parse frontmatter
2. Check all exit conditions for completion markers
3. Validate proof_state against required evidence
4. Verify verification commands have passing results
5. Check cross-references to skills, workflows, and dependencies
6. Generate verification report
7. Update task review_score based on findings

## Skills Used

- `code-quality-harness`: Quality gates and scoring
- `project-management`: Lane promotion rules
- `harness-architecture`: Governance compliance checks

## Artifacts Produced

- Verification report
- Updated task review_score
- Completion or return decision
