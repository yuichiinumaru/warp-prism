---
date: 20260709-235900
timestamp: 20260709-235900
project: warp-prism
agent: builders
task: "0001"
description: "Path-to-100: fix live manifest archive_destination/archive_policy to .archive/mock_workspace/ after 88/100 re-review"
is_rebuild_safe: true
---

# Task 0001: Mock Workspace Contract — Archive Path String Fix (88/100)

## Summary

Independent re-review scored Task 0001 at **88/100** and returned it to
`02-doing/`. Changelog evidence and Review State were already correct; the live
manifest still had wrong archive path strings. This pass applies the exact
path-to-100 strings on disk and refreshes evidence **without self-promoting**
out of `02-doing/`.

## Changes

- **apps/observatory/assets/mock_workspace/manifest.yaml** — set live values to:
  - `archive_destination: .archive/mock_workspace/`
  - `archive_policy: All 18 legacy files move to .archive/mock_workspace/ preserving directory structure. No destructive deletion.`
  - Removed residual `warp-prism/archive/mock_workspace/` from `archive_policy`.
  - Replaced imprecise `archive_destination: .archive/` with `.archive/mock_workspace/`.
- **docs/tasks/02-doing/0001-warp-prism-mock-workspace-contract-baseline.md** —
  refreshed Completion Evidence with exact live paths; set Review State to
  `Ready For Review` while remaining in lane `02-doing` (no self-promote).
  Live changelog path cited:
  `docs/changelog/20260607-120000-0001-2026-06-07-0001-mock-workspace-contract-architect-orchestrator.md`

## Verification

- [x] `python3 tool/validate_mock_workspace.py --project-root apps/observatory` → EXIT 0
- [x] `rg -n "counts:|required_agents:|required_skills:|required_workflows:|archive_destination:" apps/observatory/assets/mock_workspace/manifest.yaml` → EXIT 0; line 74 is `.archive/mock_workspace/`
- [x] `rg -n "Parser deltas|Legacy corpus mapping|Required counts" docs/mock-workspace-corpus-contract.md` → EXIT 0
- [x] `rg -n "warp-prism/archive/mock_workspace" apps/observatory/assets/mock_workspace/manifest.yaml docs/mock-workspace-corpus-contract.md` → 0 hits
- [x] `test -f docs/changelog/20260607-120000-0001-2026-06-07-0001-mock-workspace-contract-architect-orchestrator.md` → LIVE_CHANGELOG_OK
- [x] Task file remains at `docs/tasks/02-doing/0001-warp-prism-mock-workspace-contract-baseline.md` (no self-promote)
