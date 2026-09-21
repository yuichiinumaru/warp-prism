---
date: 20260709-000000
timestamp: 20260709-000000
project: warp-prism
agent: builders
task: "0001"
description: "Path-to-100 archive policy and evidence refresh after 87/100 review return"
is_rebuild_safe: true
---

# Task 0001: Mock Workspace Contract — Path-to-100 Refresh

## Summary

Remediated Task 0001 after independent reviewer score 87/100. Live validator and
rg checks already passed; the remaining defects were archive-policy wording,
stale changelog evidence path, and Review State / lane inconsistency.

## Changes

- **apps/observatory/assets/mock_workspace/manifest.yaml** — set
  `archive_destination: .archive/mock_workspace/` and rewritten
  `archive_policy` to name `.archive/mock_workspace/` instead of
  `warp-prism/archive/mock_workspace/`.
- **docs/tasks/03-review/0001-warp-prism-mock-workspace-contract-baseline.md** —
  corrected completion evidence to the live changelog entry
  `docs/changelog/20260607-120000-0001-2026-06-07-0001-mock-workspace-contract-architect-orchestrator.md`,
  set Review State to `Ready For Review`, appended 2026-07-09 path-to-100 and
  post-promotion evidence, and moved the task from `02-doing/` to `03-review/`.

## Verification

- `python3 tool/validate_mock_workspace.py --project-root apps/observatory` → `VALIDATION PASSED: all checks OK`
- `rg -n "counts:|required_agents:|required_skills:|required_workflows:|archive_destination:" apps/observatory/assets/mock_workspace/manifest.yaml` → PASS (lines 5, 13, 24, 39, 74)
- `rg -n "Parser deltas|Legacy corpus mapping|Required counts" docs/mock-workspace-corpus-contract.md` → PASS (lines 16, 136, 165)
- No remaining `warp-prism/archive/mock_workspace` hits in manifest or contract.
- `IN_REVIEW:OK` / `NOT_IN_DOING:OK` after lane promotion.
