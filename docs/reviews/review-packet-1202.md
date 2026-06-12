# Review Packet — Task 1202

> **Task**: 1202
> **Title**: Promotion State Model Definition
> **Type**: governance
> **Submitted by**: builders
> **Submitted date**: 2026-06-11
> **Review packet version**: 1

## Evidence Summary

Task 1202 defines the Warp Prism promotion-state model and reconciles the model with the current task governance surfaces. The review defect from the prior build-gate review was metadata/evidence drift, not missing core governance content: the prior packet claimed Task 0001 was a `02-doing/` example even though the live file is in `docs/tasks/03-review/0001-warp-prism-mock-workspace-contract-baseline.md` with `Review State: Builder Done`.

## What Changed in This Remediation

- Kept Task 0001 out of the `02-doing/` example set and documented it as a pre-existing `03-review/`/`Builder Done` governance defect.
- Added Task 0010 as the replacement `02-doing/` example while retaining 0011, 0312, 0510, and 1201 as current `02-doing/` examples.
- Aligned active-work vocabulary across:
  - `.agents/rules/promotion-state-model.md`
  - `docs/governance/promotion-state-model.md`
  - `.agents/rules/task-governance.md`
  - `docs/tasks/000-template.md`
- `Doing` is now explicitly canonical; `In Progress` is explicitly documented as a legacy alias only, not a distinct promotion state.
- Marked the Task 1202 regression-verification subtask `[x]` only after rerunning the required validation commands.
- Updated Task 1202 Completion Evidence and the Task 1202 changelog to match the live repository state.

## Validation Commands

```bash
test -f docs/governance/promotion-state-model.md
rg "Review State" docs/tasks/000-template.md
rg "promotion-state-model\|Promotion States\|Gate Requirements\|Lane Move Rules" .agents/rules/task-governance.md
rg "Review State" docs/tasks/02-doing/*.md | wc -l
test ! -e docs/tasks/02-doing/0001-warp-prism-mock-workspace-contract-baseline.md
cat docs/changelog/2026-06-09-task-1202-promotion-state-model-definition.md
```

## Reviewer Notes

This packet is for governance/docs evidence only. It does not move files between lanes, does not edit unrelated task content, and does not claim Task 0001 is ready for review.
