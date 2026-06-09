---
id: 2025-03-15-T001-workspace-onboarding
date: 2025-03-15
project: asw-observatory
task: T001
type: feature
impact:
  - harness-map
  - onboarding
  - workspace-graph
skills:
  - harness-architecture
  - project-management
workflows:
  - architect-orchestration
  - plan-evidence-to-tasks
---

# Workspace onboarding epic planned

## Why

The ASW Observatory had no structured way to ingest an agent workspace. Without a planning epic, every surface would be built ad-hoc against raw YAML files instead of a normalized graph model.

## Changed

- Defined the Workspace Onboarding Epic covering agent, skill, workflow, task, and changelog ingestion.
- Specified the directory contract: `.agents/agents/`, `.agents/skills/`, `.agents/workflows/`, `docs/tasks/`, `docs/changelog/`.
- Established the `AssetKind` enum (9 values) and `EdgeKind` enum (7 values) as the domain backbone.
- Drafted the manifest schema for `assets/mock_workspace/manifest.yaml`.

## Evidence

- `assets/mock_workspace/docs/tasks/00-planning/T001-plan-workspace-onboarding-epic.md` defines scope and exit conditions.
- Manifest YAML declares `counts.agents: 9`, `counts.skills: 13`, `counts.workflows: 11`.
