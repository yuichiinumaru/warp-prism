---
id: warp-prism-task-governance
title: Warp Prism Local Task Governance
scope: warp-prism/docs/tasks
status: active
---

# Warp Prism Local Task Governance

Warp Prism uses a local task namespace under `docs/tasks/`. Parent Ganthritor
task numbers and epic blocks do not apply unless a task is intentionally managed
in the parent ledger.

## Lanes

| Lane | Meaning |
| --- | --- |
| `00-planning/` | Roadmaps, epics, plans, stories, holds, candidates; not executable. |
| `01-open/` | Template-complete executable tasks ready for builder pickup. |
| `02-doing/` | One executor is actively working. |
| `03-review/` | Completed work awaiting independent review. |
| `04-completed/` | Reviewer-approved work. |

## Planning Names

Planning artifacts must use prefixes such as `ROADMAP-*`, `EPIC-*`, `STORY-*`,
`PLAN-*`, `HOLD-*`, or `CANDIDATE-*`. Do not use `Task NNNN` identity in
`00-planning/` for ordinary planning artifacts.

## Executable Task Requirements

Every executable task must:

1. follow `docs/tasks/000-template.md`;
2. have at least 50 lines;
3. include checkbox subtasks;
4. make the first subtask “Read existing code before modifying” or an equivalent
   explicit read-before-write instruction;
5. include a `Where` table;
6. include binary exit conditions and validation commands;
7. include a `Completion Evidence` section;
8. record changelog evidence before review handoff.

## Identity Policy

Use lane-neutral references such as `Task 0011` or `Task 0011 (bootstrap main
router shell)`. Lanes are mutable status and should not be used as stable task
identity in dependencies or reports.

## Promotion States

Every executable task has a **Review State** that tracks its promotion lifecycle
independently of its lane. The promotion state model is defined in
`docs/governance/promotion-state-model.md` and referenced by the task template.
`Doing` is the canonical active-work state and canonical alias for the previous
`In Progress` label. `In Progress` is a legacy alias only; it is not a distinct
promotion state.
Reference selectors for audits: `promotion-state-model|Promotion States|Gate Requirements|Lane Move Rules`.

### States

| State | Marker | Meaning |
|-------|--------|---------|
| **Open** | `[ ]` | Task defined, no work started. |
| **Doing** (`In Progress` legacy alias) | `[/]` | Executor actively working. Use `Doing` for new task headers. |
| **Builder Done** | `[x]` Builder Done | Implementation complete. Gates not yet verified. |
| **Package Gate Failed** | `[/]` Package Gate Failed | Package-level test/analyze fails. |
| **Consumer Gate Failed** | `[/]` Consumer Gate Failed | Consumer app fails after change. |
| **Ready For Review** | `[x]` Ready For Review | All gates pass. Review packet exists. |
| **Review Approved** | `[x]` Review Approved | Reviewer confirmed correctness. |
| **Promoted** | `[x]` Promoted | Moved to `04-completed/`. Terminal. |
| **Superseded** | `[~]` | Obsolete. Terminal. |
| **Blocked** | `[!]` | External dependency prevents progress. |

### Gate Requirements

Gate requirements depend on task type. See the **Gate Matrix** in
`docs/governance/promotion-state-model.md` for the full matrix. Summary:

- **Package Gate**: `flutter analyze` and `flutter test` pass in the owning
  package after the task's changes.
- **Consumer Gate**: Downstream consumer apps (observatory, catalog, cybercore)
  still compile and test after the change propagates through imports.
- **Review Packet**: Required to advance from `Builder Done` to
  `Ready For Review`. See EPIC-12, Task 1207.

### Lane Move Rules

- A task can only move to `03-review/` when its Review State is
  `Ready For Review`.
- A task can only move to `04-completed/` when its Review State is
  `Review Approved`.
- `Builder Done` tasks remain in `02-doing/` until gates pass and a review
  packet is generated. If a file is observed in `03-review/` with `Builder Done`,
  classify it as a pre-existing lane-state defect until the parent resolves the
  lane move or evidence mismatch. Known example: Task 0001 is in
  `docs/tasks/03-review/0001-warp-prism-mock-workspace-contract-baseline.md`
  with `Review State: Builder Done` and no corresponding `02-doing/0001-*` file.

### Failure Classification

When a gate fails, the failure must be classified per the **Failure Taxonomy**
in `docs/governance/promotion-state-model.md`. Pre-existing unrelated failures
do not block promotion but must be documented.
