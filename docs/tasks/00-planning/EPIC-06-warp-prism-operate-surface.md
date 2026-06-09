# EPIC 06 — Warp-Prism Operate Surface

> **Planning Status**: Active Epic
> **Executable?**: No — planning artifact only.
> **Promotion Gate**: Promote after mock task corpus and lane parser contracts are stable.

## Goal

Build the Execution Ledger task surface for current work, lanes, blockers, proof state, review pressure, and task details.

## Source Evidence

- `prompt.txt` requires five task lanes: `00-planning`, `01-open`, `02-doing`, `03-review`, `04-completed`.
- `prompt.txt` defines task card fields: ID, title, priority, lane, owner, proof state, review score, linked skills/workflows, blockers/dependencies.
- `research.md` frames tasks as a governed evidence pipeline rather than a generic kanban board.

## Scope

- Lane board consuming parsed task assets.
- Task cards with proof/review/dependency metadata.
- Task detail surface integration.
- Lane-level storytelling such as review queue pressure or blocker clusters.
- Filters by lane, owner, skill, workflow, proof state.

## Out of Scope

- Drag/drop lane mutation.
- Writing task files.
- Promoting/closing tasks from the UI.

## Candidate Stories

- Lane board layout.
- Task card metadata display.
- Task detail drill-down.
- Dependency/blocker visualization.
- Proof/review state filters.

## Dependencies

- EPIC 02 for task corpus.
- EPIC 03 for task parser and graph links.
- EPIC 04 for shell route/layout.
- EPIC 09 for full universal detail, if task details are deferred there.

## Acceptance Criteria for Epic Completion

- All five lanes are visible and populated from mock data.
- Task details show metadata, markdown body, verification commands, and evidence.
- Related skills/workflows/changelog links are navigable or inspectable.
- UI makes blocked, review, and proof-risk work obvious.
