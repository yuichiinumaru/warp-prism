---
name: gt-ganthritor-onboard
description: Bootstrap workflow for initializing a new Ganthritor workspace with required agents, skills, workflows, and directory structure.
uses_skills:
  - harness-architecture
  - project-management
  - agent-wiki
kind: onboarding
---

# gt-ganthritor-onboard

## Purpose

Initialize a complete Ganthritor workspace from scratch. Creates the directory skeleton, registers core agents, installs default skills, and seeds the tasklist with initial planning items.

## Steps

1. Validate workspace root and directory structure
2. Create `.agents/agents/`, `.agents/skills/`, `.agents/workflows/` directories
3. Register core orchestrator agents (architect, builder, reviewer)
4. Install harness-architecture skill as the meta-governance foundation
5. Seed `docs/tasks/` lane directories
6. Create manifest.yaml with initial asset counts
7. Emit onboarding changelog entry

## Skills Used

- `harness-architecture`: Governs asset creation during bootstrap
- `project-management`: Initializes tasklist and lane structure
- `agent-wiki`: Records onboarding decisions for continuity

## Artifacts Produced

- `manifest.yaml` with initial counts
- Core agent `.md` files in `.agents/agents/`
- Lane directories under `docs/tasks/`
- Onboarding changelog entry
