---
name: audit-tasks
description: Task audit workflow that checks for stale tasks, dependency cycles, missing evidence, and lane integrity across the tasklist.
uses_skills:
  - project-management
  - harness-architecture
  - code-quality-harness
kind: audit
---

# audit-tasks

## Purpose

Run a comprehensive audit across all task lanes to detect stale tasks, broken dependencies, missing evidence, lane integrity violations, and governance issues.

## Steps

1. Scan all task files across all lane directories
2. Check for stale tasks (no updates beyond threshold)
3. Validate dependency graph for cycles and orphans
4. Verify frontmatter schema compliance
5. Check exit conditions completeness for review/completed tasks
6. Generate audit report with findings and recommendations
7. Emit audit changelog entry

## Skills Used

- `project-management`: Lane rules and task lifecycle validation
- `harness-architecture`: Governance rules and compliance checks
- `code-quality-harness`: Quality scoring for task evidence

## Artifacts Produced

- Audit report with findings
- Task remediation recommendations
- Audit changelog entry
