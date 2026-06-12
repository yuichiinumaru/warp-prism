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
  (`Builder Done`), Task 0510 (`Builder Done`), and Task 1201 (`Open` lane
  mismatch).
- **2026-06-11 Path-to-100 remediation**: Task 1202 Completion Evidence was
  refreshed with the exact validation outputs below; the regression-verification
  subtask was marked `[x]` only after rerunning the checks.

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
- `rg "Review State" docs/tasks/02-doing/*.md | wc -l` → `115`
- `test ! -e docs/tasks/02-doing/0001-warp-prism-mock-workspace-contract-baseline.md` → `(no output)`
- `test -f docs/tasks/03-review/0001-warp-prism-mock-workspace-contract-baseline.md && rg -n "Review State" docs/tasks/03-review/0001-warp-prism-mock-workspace-contract-baseline.md` → `4:> **Review State**: Builder Done — implementation evidence missing; needs verification`
