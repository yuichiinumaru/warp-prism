---
date: 20260823-000000
timestamp: 20260823-000000
project: warp-prism
agent: task-governance
task: "status-lane-canonicality"
description: "Remove redundant task Status headers and codify lane-derived lifecycle truth"
is_rebuild_safe: true
---

# Task Governance: Lane-Derived Status

## Summary
Removed task-level `Status` header fields from the Warp Prism task corpus and
updated the task template and applicable governance rules so lifecycle/readiness
status is derived solely from the containing task lane directory.

## Changes
- Removed 169 task-header `Status` lines under `docs/tasks/`.
- Preserved five historical inline `Status` notes in Review Ledger/body prose.
- Updated `docs/tasks/000-template.md` with explicit lane-derived status guidance.
- Updated local `AGENTS.md` and lane/task artifact rules.
- Updated parent `AGENTS.md` with the cross-project convention.
- Updated sibling templates in `pm_lens`, `cryptosentinel-v1`, `optillm-go`,
  `research`, and `templar-archives`.
- Updated optillm-go task-governance guidance that still required header status.

## Verification
- Scoped Warp Prism scan reports no task-header `Status` lines; only five
  historical Review Ledger/body lines remain.
- Sibling inventory recorded legacy header counts for follow-up cleanup; no
  bulk edits were applied outside templates and explicitly inspected governance
  guidance.
