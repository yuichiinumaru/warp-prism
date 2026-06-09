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
