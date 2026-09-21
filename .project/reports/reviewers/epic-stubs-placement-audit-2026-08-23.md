# EPIC Stub Placement Audit — EPIC-00 through EPIC-14

- **Date**: 2026-08-23
- **Reviewer**: `reviewers`
- **Scope**: All 15 files matching `docs/tasks/03-review/EPIC-*.md` (`EPIC-00` through `EPIC-14`).
- **Mode**: Read-only governance audit. No EPIC files were moved, renamed, deleted, or edited.

## Executive finding

All 15 files are planning artifacts, not executable Ready-For-Review tasks. Fourteen explicitly state `Executable? No — planning artifact only`; EPIC-11 does too, despite a drained closeout and internal builder-review language. Under Warp Prism governance, this is a placement violation:

- `AGENTS.md` defines `docs/tasks/00-planning/` as the home for roadmaps, epics, stories, plans, holds, and candidates, and says these are not executable tasks.
- `AGENTS.md` defines `docs/tasks/03-review/` as completed work awaiting independent review.
- `docs/governance/promotion-state-model.md` states `00-planning/` has no promotion states and planning artifacts are not executable; `03-review/` may contain only `Ready For Review` or `Review Approved` states.

The presence of acceptance criteria, candidate task tables, planning closeout prose, or an internal builder score does not convert an `Executable? No` epic plan into an executable task. The canonical recommended home for every file is `docs/tasks/00-planning/` (with any historical closeout/report retained by the parent’s chosen archival policy).

## Per-EPIC classification

| EPIC | Header/status evidence | Completion/review evidence | Classification | Recommended action |
| --- | --- | --- | --- | --- |
| EPIC-00 | `Planning Status: Active Epic`; `Executable? No — planning artifact only` | No `Completion Evidence`, `Review Ledger`, independent report, or accepted score found | Planning-only artifact misplaced in `03-review` | Parent should route to `docs/tasks/00-planning/` |
| EPIC-01 | `Planning Status: Active Epic`; `Executable? No — planning artifact only` | No completion evidence, review ledger, independent report, or accepted score found | Planning-only artifact misplaced in `03-review` | Route to `docs/tasks/00-planning/` |
| EPIC-02 | `Planning Status: Active Epic`; `Executable? No — planning artifact only` | No completion evidence, review ledger, independent report, or accepted score found | Planning-only artifact misplaced in `03-review` | Route to `docs/tasks/00-planning/` |
| EPIC-03 | `Planning Status: Active Epic`; `Executable? No — planning artifact only` | No completion evidence, review ledger, independent report, or accepted score found | Planning-only artifact misplaced in `03-review` | Route to `docs/tasks/00-planning/` |
| EPIC-04 | `Planning Status: Active Epic`; `Executable? No — planning artifact only` | No completion evidence, review ledger, independent report, or accepted score found | Planning-only artifact misplaced in `03-review` | Route to `docs/tasks/00-planning/` |
| EPIC-05 | `Planning Status: Active Epic`; `Executable? No — planning artifact only` | No completion evidence, review ledger, independent report, or accepted score found | Planning-only artifact misplaced in `03-review` | Route to `docs/tasks/00-planning/` |
| EPIC-06 | `Planning Status: Active Epic`; `Executable? No — planning artifact only` | Planning prose contains a `review score` field in a task-card schema reference, not completion evidence or a review ledger | Planning-only artifact misplaced in `03-review` | Route to `docs/tasks/00-planning/` |
| EPIC-07 | `Planning Status: Active Epic`; `Executable? No — planning artifact only` | No completion evidence, review ledger, independent report, or accepted score found | Planning-only artifact misplaced in `03-review` | Route to `docs/tasks/00-planning/` |
| EPIC-08 | `Planning Status: Active Epic`; `Executable? No — planning artifact only` | No completion evidence, review ledger, independent report, or accepted score found | Planning-only artifact misplaced in `03-review` | Route to `docs/tasks/00-planning/` |
| EPIC-09 | `Planning Status: Active Epic`; `Executable? No — planning artifact only` | No completion evidence, review ledger, independent report, or accepted score found | Planning-only artifact misplaced in `03-review` | Route to `docs/tasks/00-planning/` |
| EPIC-10 | `Planning Status: Active Epic`; `Executable? No — planning artifact only` | No completion evidence, review ledger, independent report, or accepted score found | Planning-only artifact misplaced in `03-review` | Route to `docs/tasks/00-planning/` |
| EPIC-11 | `Planning Status: Drained — Ready For Review`; still `Executable? No — planning artifact only`; `Review State: Ready For Review` and internal builder review `100/100` | Has a planning closeout, task-placement table, internal builder score, and “promoted to 03-review” prose; no independent executable task packet | Planning-only artifact misplaced in `03-review` (exception: historical closeout evidence is real but does not alter artifact type) | Return canonical plan to `docs/tasks/00-planning/`; preserve closeout/report history according to parent archival decision |
| EPIC-12 | `Planning Status: Active Epic`; `Executable? No — planning artifact only` | No completion evidence, review ledger, independent report, or accepted score found | Planning-only artifact misplaced in `03-review` | Route to `docs/tasks/00-planning/` |
| EPIC-13 | `Planning Status: Active Epic`; `Executable? No — planning artifact only` | No completion evidence, review ledger, independent report, or accepted score found | Planning-only artifact misplaced in `03-review` | Route to `docs/tasks/00-planning/` |
| EPIC-14 | `Planning Status: Active Epic`; `Executable? No — planning artifact only` | No completion evidence, review ledger, independent report, or accepted score found | Planning-only artifact misplaced in `03-review` | Route to `docs/tasks/00-planning/` |

## Evidence methodology

Read-only inventory commands used:

```text
python header scan over sorted docs/tasks/03-review/EPIC-*.md
# Found exactly 15 files: EPIC-00 through EPIC-14
# 14 Active Epic headers with Executable? No
# EPIC-11 Drained — Ready For Review, but still Executable? No

marker scan for Completion Evidence, Review Ledger, Full report,
ACCEPTED, REJECT, Score, Ready For Review, and Review State
# EPIC-00..10 and EPIC-12..14: no completion/review packet markers
# EPIC-06's “review score” is only a planning task-card field reference
# EPIC-11: internal builder score and planning closeout only
```

Governance sources read directly:

- `AGENTS.md`, section 3 Task Governance (lines 55–70)
- `docs/governance/promotion-state-model.md`, states and lane mapping (lines 16–34, 177–188)
- `docs/tasks/03-review/EPIC-11-warp-prism-cybercore-frontend.md`, lines 3–5, 123–180 (the exceptional drained closeout)
- `docs/tasks/03-review/EPIC-12-warp-prism-test-suite-stabilization-and-promotion-gates.md`, lines 1–8 (representative active planning stub)

## Recommended governance disposition

1. Parent should move all 15 EPIC stubs to `docs/tasks/00-planning/` without treating them as executable task promotions.
2. Preserve EPIC-11’s historical drained closeout and task-placement table as planning history; do not use its internal 100/100 score as an independent review approval for an executable surface.
3. If any epic needs independent review, create a separate executable task packet under `docs/tasks/01-open/` with a `Where` table, checkbox subtasks, validation commands, completion evidence, and a real review ledger; leave the epic as planning authority.
4. Do not mark these EPIC files `04-completed/`; they are not executable promoted tasks.

## Final status

- **15/15** classified as planning-only artifacts misplaced in `docs/tasks/03-review/`.
- **0/15** classified as genuinely reviewable executable surfaces.
- **0 files moved or deleted** by this audit.
