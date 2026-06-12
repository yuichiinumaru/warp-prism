# Continuity: Task 1206 — Pre-existing Failure Classification Policy

> **Date**: 2026-06-09 16:06 UTC
> **Task**: 1206
> **Status**: Builder Done
> **Agent**: builders

## What Was Done

Created `docs/governance/pre-existing-failure-policy.md` — the formal policy
for classifying and handling pre-existing test failures during task promotion.

### Key Decisions

- **Policy location**: `docs/governance/` (consistent with sibling
  `promotion-state-model.md` in the same directory).
- **Three failure classes**: Pre-existing (unrelated), Pre-existing (related),
  Regression (caused). Decision tree with clear stop-at-first-match logic.
- **Promotion rules**: Unrelated does not block. Related blocks until resolved
  or justified with reviewer sign-off. Regression always blocks.
- **Evidence requirements**: Baseline comparison (before/after test runs) is
  primary evidence. Git blame and baseline inventory are secondary.
- **Anti-gaming rules**: "Pre-existing" is not a magic word — evidence required.
  Baseline must be captured before changes. Scope creep into failing areas
  makes failures related.
- **Reviewer checklist**: 7-point checklist for evaluating pre-existing claims.

### Files Modified

- CREATED: `docs/governance/pre-existing-failure-policy.md`
- MODIFIED: `.agents/rules/promotion-state-model.md` (3 reference additions)
- CREATED: `docs/changelog/20260609-160654-1206-pre-existing-failure-policy-builders.md`
- MODIFIED: `docs/tasks/02-doing/1206-warp-prism-pre-existing-failure-classification-policy.md`
  (subtask checkboxes, exit conditions, completion evidence)

### Baseline Reference

The policy references the current failure baseline:
- 64 Observatory pre-existing failures (EPIC-14 owns remediation)
- 24 UI wave4-regressions (Tasks 1303, 1304, 1307, 1309 own remediation)

### Follow-up Needed

- Task remains in `02-doing/` as Builder Done. Needs reviewer to move to
  `03-review/` after confirming the policy is consistent and complete.
- `agent-wiki` was not available; profile note written manually.
