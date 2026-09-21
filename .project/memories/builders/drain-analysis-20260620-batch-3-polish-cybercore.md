# Drain Analysis 2026-06-20 — Batch 3 Polish / CyberCore / Components

> Source: `gt-mechanical-investigator` task `ses_11caac659ffezF0kfyAtjuzAHG`.
> Scope: `02-doing/1000-1070`, `1102`, `1104-1126`.
> Status: PARTIAL — subagent hit step limit after reading governance plus 9 of 45 scoped task files. This packet preserves the returned findings and must not be treated as full-batch coverage.

## Files Read By Subagent

- `AGENTS.md`
- `.agents/rules/project-boundaries.md`
- `.agents/rules/task-governance.md`
- `.agents/workflows/gt-builder-orchestrator-drain.md`
- `docs/dependency-tree.md`
- `docs/reports/builders/harness-upgrades.md`
- Task files read: `1000`, `1010`, `1020`, `1030`, `1040`, `1050`, `1060`, `1070`, `1102`.

## Partial Triage Matrix

| Task | Review State | Latest Known Score | Key Finding | Recommended Action |
| --- | --- | ---: | --- | --- |
| `1000` | Doing | 42 | Baseline stale after monorepo migration. | `fixer_then_review`, likely after stabilization roots. |
| `1010` | Doing | 78 | Focus behavior untested, null callback issues. | `fixer_then_review`; accessibility focus pass. |
| `1020` | Doing | 72 | Constant tests do not prove rendered transitions. | `fixer_then_review`; responsive UI tests. |
| `1030` | Doing | 84 | History bypasses shared state, Map retry no-op. | `fixer_then_review`; may be reviewer-patchable if score revalidates >=90 after upstream. |
| `1040` | Doing | 62 | Budget inventory false; `DSToast`/`DSCommandPalette` use blur. | `fixer_then_review`; performance evidence needed. |
| `1050` | Doing | 54 | Demo script contradicts actual routes; stale blockers. | `builder_wave`; route/storytelling reconciliation. |
| `1060` | Doing | 38 | Audit marks rejected prerequisites PASS. | `fixer_then_review`; truth audit reset. |
| `1070` | Ready For Review but rejected | 68 | Open lane drifted; Task `1103` identity defects. | `fixer_then_review` / governance evidence refresh. |
| `1102` | Blocked | 44 | Inventory corrupted; CyberCore evidence contract unmet. | `blocked` until approved CyberCore screenshot/source evidence exists. |

## Remaining Unread In This Batch

`1104`, `1105`, `1106`, `1107`, `1108`, `1109`, `1110`, `1111`, `1112`, `1113`, `1114`, `1115`, `1116`, `1117`, `1119`, `1120`, `1121`, `1122`, `1123`, `1126`.

## High-Risk Items From Harness Upgrade Log

The subagent highlighted these as priority reads/fixes for the parent:

- `1121`: prior independent score 30/100; TapGestureRecognizer lifecycle leak, 24x24 touch target, hardcoded constants.
- `1122`: returned from review with tab close crash, split-pane trailing max constraint, and live verification blocker.
- `1123`: prior independent score 49/100; benchmark fails to compile and does not prove 60fps; lifecycle bug in `DSVirtualList`.
- `1102`: hard evidence blocker for CyberCore source/screenshot contract.

## Batch-Level Pattern

8 of the 9 read tasks were rejected back to `02-doing` during June 17-19 review waves. Treat previous build-gate 100/100 scores as non-authoritative until current reviewer-owned rfloop evidence revalidates them.

## Caveat

This batch is incomplete. Before any `1104-1126` implementation dispatch, the parent must read the task and matching review report or dispatch a smaller follow-up triage batch.
