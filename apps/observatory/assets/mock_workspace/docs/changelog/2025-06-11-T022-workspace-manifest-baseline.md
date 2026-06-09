---
id: 2025-06-11-T022-workspace-manifest-baseline
date: 2025-06-11
project: asw-observatory
task: T022
type: audit
impact:
  - governance
  - manifest
  - baseline
skills:
  - project-management
  - code-quality-harness
---

# Workspace manifest baseline verified

## Why

After creating all mock corpus files (agents, skills, workflows, tasks, changelog), the manifest needs verification against actual file counts. Without baseline verification, the observatory's integrity checks would report false positives or miss missing assets.

## Changed

- Counted all mock files: 9 agents, 13 skills, 11 workflows, 20 tasks, 12 changelog entries.
- Verified manifest counts match actual file counts (no discrepancies).
- Validated all `required_agents`, `required_skills`, and `required_workflows` lists against existing files.
- Confirmed task lane distribution: 3 planning, 4 open, 4 doing, 3 review, 6 completed.
- Added `archive_destination` and `archive_policy` to manifest for legacy file preservation.

## Evidence

- `assets/mock_workspace/docs/tasks/04-completed/T022-completed-workspace-manifest-baseline.md` documents the verification.
- `assets/mock_workspace/manifest.yaml` is the verified manifest.
