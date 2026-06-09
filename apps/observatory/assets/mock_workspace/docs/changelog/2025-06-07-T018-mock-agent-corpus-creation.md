---
id: 2025-06-07-T018-mock-agent-corpus-creation
date: 2025-06-07
project: asw-observatory
task: T018
type: feature
impact:
  - harness-map
  - agents
  - mock-corpus
skills:
  - harness-architecture
  - agent-wiki
workflows:
  - gt-ganthritor-onboard
  - gt-harness-architecture
---

# Mock agent corpus created

## Why

The observatory needs realistic mock agent data to populate the Map workspace. Without 9 agents with proper frontmatter (name, model, mode, description, skills, workflows), the graph visualization and agent catalog would be empty.

## Changed

- Created 9 mock agent markdown files under `assets/mock_workspace/.agents/agents/`.
- Each agent has valid YAML frontmatter with `name`, `model`, `mode`, `description`, `skills`, and `workflows` fields.
- Agents reference real skills and workflows from the corpus: `architect-orchestrator` uses `project-management` and `harness-architecture`, `gt-security-reviewer` uses `code-quality-harness`, etc.
- Verified all agent->skill and agent->workflow references resolve to existing mock files.

## Evidence

- `assets/mock_workspace/docs/tasks/04-completed/T018-completed-mock-agent-corpus-creation.md` documents the completion.
- 9 agent files in `assets/mock_workspace/.agents/agents/`.
