---
id: T015
title: "Governance audit of task dependency chains"
status: review
priority: medium
owner: gt-security-reviewer
created: "2026-06-01"
updated: "2026-06-06"
skills:
  - code-quality-harness
  - project-management
workflows:
  - audit-tasks
  - gt-verify-task-completion
depends_on:
  - T009
  - T012
proof_state: complete
review_score: 9.0
---

# Governance Audit of Task Dependency Chains

## Goal
Verify that all task dependency chains in the mock corpus are acyclic, that every depends_on reference resolves to an existing task, and that no task is blocked by a task in a later lane.

## Scope
- Parse all task frontmatter for depends_on fields
- Build dependency graph and check for cycles
- Validate that no task in 02-doing depends on a task in 03-review or 04-completed
- Report orphaned tasks (no dependents and no dependencies)

## Exit Conditions
- [ ] Zero cycles detected in dependency graph
- [ ] All depends_on references resolve to existing task IDs
- [ ] Lane ordering constraint verified (no forward dependencies)
- [ ] Audit report written to docs/reports/

## Verification Commands
```bash
find assets/mock_workspace/docs/tasks -name "*.md" -exec grep -l "depends_on" {} \; | wc -l
```

## Completion Evidence
*Audit complete. All 22 task dependency references resolve. No cycles found. Lane ordering constraint holds.*
