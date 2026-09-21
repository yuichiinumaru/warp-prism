# Review Wave 2 — Task 0006

**Date**: 2026-06-14
**Reviewer profile**: reviewers
**Task**: `docs/tasks/02-doing/0006-warp-prism-mock-corpus-validation-and-legacy-archive.md`
**Score**: 62/100 — Rejected and routed to `02-doing/`

## Summary

Task 0006 is not independently reproducible from its own recorded validation contract. The task says the primary command is `python3 tool/validate_mock_workspace.py`, but that command fails from the repository root because the active corpus now lives under `apps/observatory/assets/mock_workspace/`. The validator can pass only with `--project-root apps/observatory`.

More importantly, the legacy archive policy is not complete on the live filesystem: `mock_workspace/` still exists with 18 files while `.archive/mock_workspace/` also exists with 18 files. The task required moving the legacy corpus under `.archive/` without deletion/collision; the current state is a duplicated archive, leaving the legacy root still live and discoverable.

A rejection ledger was added to the task, its Review State was downgraded, and the task file was routed to `docs/tasks/02-doing/`.

## Evidence

| Check | Result |
| --- | --- |
| `python3 tool/validate_mock_workspace.py` | FAIL — missing root `assets/mock_workspace/manifest.yaml`. |
| `python3 tool/validate_mock_workspace.py --project-root apps/observatory` | PASS — validator logic works with app-root override. |
| Root canonical corpus exists | FAIL for old contract — `assets/mock_workspace/` does not exist. |
| App canonical corpus exists | PASS — `apps/observatory/assets/mock_workspace/` exists and validates. |
| Legacy root state | FAIL — `mock_workspace/` still exists with 18 files. |
| Archive state | PARTIAL — `.archive/mock_workspace/` exists with 18 files. |
| Changelog evidence | PASS — `docs/changelog/20260607-000000-0006-2026-06-07-task-0006-mock-corpus-validation-archive-repair-bot.md` exists. |
| Lane routing | DONE — task file moved to `docs/tasks/02-doing/`. |

## Findings

### Critical

1. **Primary validation command is false in current repo layout** — The command recorded in the task and build-gate report fails from repo root. This violates the reproducible validator exit condition.
2. **Legacy archive policy not completed** — Legacy `mock_workspace/` remains in the live root with the same 18 files also present under `.archive/mock_workspace/`. The archive requirement was a move/preservation operation, not a duplicate that leaves the old source active.

### Medium

1. **Manifest archive wording is stale/incorrect** — `apps/observatory/assets/mock_workspace/manifest.yaml` says `warp-prism/archive/mock_workspace/`, while the actual approved destination in task governance is `.archive/`.
2. **Task evidence still references obsolete root paths** — The monorepo migration moved the active corpus into `apps/observatory/`; the task was not reconciled.

## Path to 100

- Make the validator default command monorepo-aware, or update the task contract and evidence to require `--project-root apps/observatory` consistently.
- Complete the archive policy by ensuring no live root `mock_workspace/` remains while preserving all legacy files under the collision-checked `.archive/mock_workspace/` destination.
- Fix manifest archive policy wording to the actual `.archive/mock_workspace/` destination.
- Rerun and record the corrected validation command plus archive absence/presence checks.
- Return the task to `03-review/` only after `Review State: Ready For Review` and evidence are updated.
