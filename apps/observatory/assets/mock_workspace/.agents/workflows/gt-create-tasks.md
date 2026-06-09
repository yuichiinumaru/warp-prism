---
name: gt-create-tasks
description: Task creation workflow that decomposes goals into structured task files with proper frontmatter, dependencies, and exit conditions.
uses_skills:
  - project-management
  - development-methodologies
  - harness-architecture
kind: creation
---

# gt-create-tasks

## Purpose

Create well-structured task files from goals or evidence. Each task gets proper YAML frontmatter, RF8-aligned scope, exit conditions, and verification commands.

## Steps

1. Receive goal statement or evidence bundle
2. Decompose using RF8 methodology
3. Generate task file with frontmatter (id, title, status, priority, owner, skills, workflows, depends_on)
4. Write markdown body with Goal, Scope, Exit Conditions, Verification Commands sections
5. Place in appropriate lane directory
6. Update tasklist index

## Skills Used

- `project-management`: Task structure and lane placement
- `development-methodologies`: RF8 decomposition
- `harness-architecture`: Task governance rules

## Artifacts Produced

- Task `.md` files with valid frontmatter
- Updated tasklist index
