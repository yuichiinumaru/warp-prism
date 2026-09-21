# Evidence Refresh — Governance Wave (Tasks 1202, 1206, 1208) — 2026-06-20

## Summary
Refreshed path-to-100 evidence for three governance tasks returned from 2026-06-17 independent review. All three tasks remain in `02-doing/` with updated evidence matching live filesystem state.

## Tasks Updated

### Task 1202: Promotion State Model Definition
**Changes:**
- Updated Exit Condition "Promotion examples are reconciled with live lanes" to match current live state (98 tasks in 02-doing)
- Corrected example task states:
  - Task 0010: `Ready For Review` (was `Blocked`)
  - Task 0011: `Ready For Review` (was `Builder Done`)
  - Task 0312: `Consumer Gate Failed` (was `Builder Done`)
  - Task 0510: `Doing` (was `Builder Done`)
  - Task 1101: `Promoted` in 04-completed (was `Open` lane mismatch in 02-doing)
  - Task 1201: sole `03-review` `Ready For Review` example
  - Task 1205: `Doing` in 02-doing (returned from review, not promoted)
- Updated header-only Review State count from 95 to 98
- Added 2026-06-20 evidence refresh section with fresh validation command outputs
- Updated `docs/governance/promotion-state-model.md` examples to match live headers

**Validation commands re-run (all pass):**
- `rg "^> \*\*Review State\*\*" docs/tasks/02-doing/*.md | wc -l` → `98`
- Template Review State field present and correct
- Task governance references promotion-state-model
- Task 0001 not in 02-doing; in 03-review with `Builder Done`
- Task 1201 in 03-review with `Ready For Review`
- Task 0010, 0011 in 02-doing with `Ready For Review`
- Task 0312 in 02-doing with `Consumer Gate Failed`
- Task 0510 in 02-doing with `Doing`
- Task 1101 in 04-completed with `Promoted`

### Task 1206: Pre-existing Failure Classification Policy
**Changes:**
- Updated Review State header: prerequisite Task 1202 evidence refreshed; policy surfaces remain aligned
- Added 2026-06-20 evidence refresh section confirming prerequisite unblocked
- All document-only validation checks pass (file existence, grep references, baseline path)
- Markdown `dart format` probe correctly classified as N/A

**Validation commands re-run (all pass):**
- `.agents/rules/pre-existing-failure-policy.md` exists
- `docs/governance/pre-existing-failure-policy.md` exists
- `docs/reports/warp-prism-test-failure-baseline.md` exists
- Both promotion-state model surfaces reference the policy
- Task Where table and validation commands use correct baseline path
- No stale `warp-prism-failure-baseline-inventory` reference found

### Task 1208: Existing Task Lane Reconciliation
**Changes:**
- Updated live 02-doing count from 95 to 98 (2026-06-20 scan)
- Updated Background Context with current count
- Updated Exit Condition deferred lane move note (Task 1205 in 02-doing, not 03-review; Task 1205 in 04-completed was incorrect)
- Updated Classification Distribution to live 2026-06-20 scan:
  - DONE_READY_FOR_REVIEW: 13 tasks (headers show `Ready For Review`)
  - PARTIAL_BLOCKED: 72 tasks
  - NEEDS_REPAIR: 5 tasks
  - SUPERSEDED: 0 tasks
  - Promotion-state breakdown: Ready For Review 13; Package Gate Failed 22; Consumer Gate Failed 11; Blocked 21; Builder Done 24; Doing 6; Open 1
- Updated snapshot report `docs/reports/warp-prism-review-backlog-snapshot.md` with live counts and corrected category mapping
- Header-aware validation passes: 98 files, every file has exactly one header Review State

**Validation commands re-run (all pass):**
- `ls docs/tasks/02-doing/*.md | wc -l` → `98`
- Header-aware check → `OK total_files=98`
- Baseline and gate matrix files exist
- Category mapping regex finds updated categories

## Files Modified
1. `docs/tasks/02-doing/1202-warp-prism-promotion-state-model-definition.md`
2. `docs/governance/promotion-state-model.md`
3. `docs/tasks/02-doing/1206-warp-prism-pre-existing-failure-classification-policy.md`
4. `docs/tasks/02-doing/1208-warp-prism-existing-task-lane-reconciliation.md`
5. `docs/reports/warp-prism-review-backlog-snapshot.md`

## Files NOT Modified (Per Constraints)
- No lane moves executed (reviewers own promotion)
- No tasklist/changelog generated surface rebuilds
- No unrelated task files modified
- No parent repo agents/skills touched

## Blockers
- None. All three tasks have refreshed evidence aligned with live filesystem.
- Task 1206 prerequisite (Task 1202) is now corrected and unblocked.
- All validation commands pass with fresh outputs recorded in task evidence.

## Next Steps
- Parent orchestrator may advance any/all three tasks to `03-review/` when review wave is scheduled.
- Tasks are in `Doing` state with `Ready For Review` evidence; they await reviewer quota.
