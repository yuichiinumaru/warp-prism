---
date: 20260630-013232
timestamp: 20260630-013232
agent: builders
task: "1202"
description: "Changelog — Task 1202: Promotion State Model Definition"
is_rebuild_safe: true
---

# Changelog — Task 1202: Promotion State Model Definition

> **Date**: 2026-06-09
> **Task**: 1202
> **Type**: governance
> **Executor**: builders (architect)

## What changed

- Created `docs/governance/promotion-state-model.md` — canonical governance
  document defining the 10 promotion states, transition rules, gate definitions
  (Package Gate, Consumer Gate), gate matrix, failure taxonomy, and lane mapping.
- Updated `docs/tasks/000-template.md` — added `Review State` field referencing
  the promotion state model.
- Updated `.agents/rules/task-governance.md` — added "Promotion States" section
  with state table, gate requirements summary, lane move rules, and failure
  classification reference.
- Reconciled the example evidence with the live lanes: Task 0001 is documented
  as a pre-existing `03-review/`/`Builder Done` lane-state defect, and Task 0010
  is used as the replacement `02-doing/` example. Current `02-doing/` examples
  now include Task 0010 (`Blocked`), Task 0011 (`Builder Done`), Task 0312
  (`Builder Done`), Task 0510 (`Builder Done`), and Task 1101 (`Open` lane
  mismatch). Task 1201 and Task 1205 are documented separately as current
  `03-review/` / `Ready For Review` examples.
- **2026-06-11 Path-to-100 remediation**: Task 1202 Completion Evidence was
  refreshed with the exact validation outputs below; the regression-verification
  subtask was marked `[x]` only after rerunning the checks.
- **2026-06-11 follow-up remediation**: Task 1201 and Task 1205 live-state
  evidence was updated from stale `02-doing/` / `Open` examples to their current
  `03-review/` / `Ready For Review` state, Task 1101 was used as the current
  `Open` lane-mismatch example, and the stable header-only `Review State` count was
  updated to `95`.

## Why

Without formal promotion semantics, builders mark tasks `[x]` Done and move on.
Reviewers cannot tell which tasks need review, which are blocked by pre-existing
failures, and which are truly promoted. This governance layer replaces the
ambiguous `[x]` Done with explicit states that track the full lifecycle from
Open to Promoted.

## Impact

- All future executable tasks should include the `Review State` field.
- Existing tasks with `[x]` Done in `02-doing/` are retroactively identified as
  `Builder Done` — they need gate verification and review packets before
  advancing.
- Tasks 1203, 1206, and all future template updates are now unblocked.

## 2026-06-11 Validation Evidence

- `test -f docs/governance/promotion-state-model.md` → `(no output)`
- `rg "Review State" docs/tasks/000-template.md` → `> **Review State**: \`Open\` | \`Doing\` | \`Builder Done\` | \`Package Gate Failed\` | \`Consumer Gate Failed\` | \`Ready For Review\` | \`Review Approved\` | \`Promoted\` | \`Superseded\` | \`Blocked\` — see \`docs/governance/promotion-state-model.md\``
- `rg "promotion-state-model\|Promotion States\|Gate Requirements\|Lane Move Rules" .agents/rules/task-governance.md` → `Reference selectors for audits: \`promotion-state-model|Promotion States|Gate Requirements|Lane Move Rules\`.`
- `rg "^> \*\*Review State\*\*" docs/tasks/02-doing/*.md | wc -l` → `95` (header-only count; avoids body-reference drift)
- `test ! -e docs/tasks/02-doing/0001-warp-prism-mock-workspace-contract-baseline.md` → `(no output)`
- `test -f docs/tasks/03-review/0001-warp-prism-mock-workspace-contract-baseline.md && rg -n "Review State" docs/tasks/03-review/0001-warp-prism-mock-workspace-contract-baseline.md` → `4:> **Review State**: Builder Done — implementation evidence missing; needs verification`
- `test -f docs/tasks/03-review/1201-warp-prism-test-failure-baseline-inventory.md && rg -n "Review State" docs/tasks/03-review/1201-warp-prism-test-failure-baseline-inventory.md` → `4:> **Review State**: \`Ready For Review\` — inventory-only governance deliverable accepted for review; consumer/app gate remains red because \`apps/observatory/\` has 12 classified pre-existing/unrelated failures that this task inventories rather than fixes.`
- `test -f docs/tasks/03-review/1205-warp-prism-boundary-test-harness.md && rg -n "Review State" docs/tasks/03-review/1205-warp-prism-boundary-test-harness.md` → `4:> **Review State**: \`Ready For Review\` — boundary harness implementation and canonical Melos entrypoint pass; package analyzer remains red with 467 pre-existing external-blocker issues classified in \`docs/reports/build-gate-review/1205-review.md\` via \`docs/governance/pre-existing-failure-policy.md\`.`
- `rg -n "Review State|Status" docs/tasks/02-doing/1101-warp-prism-charter-and-naming-convergence.md` → `3:> **Status**: \`[/]\` Open\n4:> **Review State**: Open — unstarted task; lane mismatch (should be in 01-open/)`
