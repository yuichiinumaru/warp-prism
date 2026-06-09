---
id: T022
title: "Completed: workspace manifest baseline"
status: completed
priority: high
owner: architect-orchestrator
created: "2026-05-10"
updated: "2026-05-15"
skills:
  - harness-architecture
  - project-management
  - agent-wiki
workflows:
  - architect-orchestration
  - plan-evidence-to-tasks
depends_on: []
proof_state: complete
review_score: 9.5
---

# Completed: Workspace Manifest Baseline

## Goal
Create the assets/mock_workspace/manifest.yaml baseline that defines required counts, agent/skill/workflow inventories, task lane definitions, and changelog schema for the entire mock corpus.

## Scope
- Define counts: 9 agents, 13 skills, 11 workflows, 20 tasks, 12 changelog entries, 5 lanes
- List all required asset identifiers
- Define task lane structure and changelog frontmatter schema
- Define archive destination and policy

## Exit Conditions
- [x] manifest.yaml exists at assets/mock_workspace/manifest.yaml
- [x] Counts match the contract (section 2)
- [x] All required asset identifiers listed match the files created in T018-T021

## Verification Commands
```bash
cat assets/mock_workspace/manifest.yaml | head -20
grep "agents: 9" assets/mock_workspace/manifest.yaml
grep "skills: 13" assets/mock_workspace/manifest.yaml
grep "workflows: 11" assets/mock_workspace/manifest.yaml
```

## Completion Evidence
- **Files created**: assets/mock_workspace/manifest.yaml
- **Validation**: All counts match contract; file is valid YAML
- **Reviewer**: architect-orchestrator
- **Completion date**: 2026-05-15
