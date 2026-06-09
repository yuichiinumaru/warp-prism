---
name: gt-harness-architecture
description: Workflow for creating, modifying, and governing Agent System Workspace assets including agents, skills, workflows, and tools.
uses_skills:
  - harness-architecture
  - indexing-skills
  - agent-wiki
kind: governance
---

# gt-harness-architecture

## Purpose

Execute harness architecture operations: create new agents, skills, or workflows; modify existing assets; validate compliance with workspace contract; and regenerate indexes.

## Steps

1. Receive asset creation or modification request
2. Apply harness-architecture rules for asset structure
3. Create or modify asset file with proper frontmatter
4. Update manifest.yaml with new counts
5. Regenerate affected indexes
6. Record decision in agent-wiki
7. Emit harness changelog entry

## Skills Used

- `harness-architecture`: Core governance rules for asset creation
- `indexing-skills`: Index regeneration after changes
- `agent-wiki`: Decision recording for continuity

## Artifacts Produced

- New or modified asset files
- Updated manifest.yaml
- Regenerated index files
- Harness changelog entry
