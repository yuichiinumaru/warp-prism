# Warp Prism Agent Constitution

> **Status**: Active child-project governance
> **Parent**: Ganthritor `AGENTS.md`
> **Project**: Warp Prism — Flutter ASW Observatory prototype
> **Last Updated**: 2026-06-06

This file localizes Ganthritor governance for agents working inside
`warp-prism/`. It is intentionally small: reusable skills and agent definitions
remain parent-canonical through symlinks, while product rules, task lanes,
reports, changelog notes, and profiles stay local to Warp Prism.

## 1. Scope

Warp Prism is a read-only Flutter observatory for an Agent System Workspace. Its
current goal is to turn mock ASW data into a high-polish desktop-first interface
covering:

- Map: agents, skills, workflows, tasks, changelog, and dependency graphs.
- Operate: task-board and execution-state projection.
- History: changelog/timeline story of workspace evolution.
- Governance: stale/orphan/canonicality diagnostics.
- Universal asset detail views.

Do not treat Warp Prism as the Ganthritor runtime. Do not add backend writes,
runtime mutation, live orchestration, or hidden service dependencies unless a
future local task explicitly changes the product contract.

## 2. Parent/Child Harness Boundary

Parent-canonical reusable surfaces are symlinked from the Ganthritor root:

| Child path | Authority |
| --- | --- |
| `.agents/skills` | Parent `../.agents/skills` |
| `.agents/agents` | Parent `../.agents/agents` |
| `.codex/agents` | Parent `../.codex/agents` |

Child-local surfaces are owned by Warp Prism:

| Child path | Purpose |
| --- | --- |
| `AGENTS.md` | This local constitution |
| `.agents/rules/` | Warp Prism rules |
| `.agents/workflows/` | Warp Prism rituals |
| `.memories/_by_lane/` | Local role continuity (parent-linked via `.memories`) |
| `docs/tasks/` | Local task namespace |
| `.changelog/` (compat `docs/changelog` → `../.changelog`) | Canonical child changelog ledger |
| `docs/reports/` | Local audits, reports, and bootstrap evidence |

Do not copy parent skills or agents into the child project. If a reusable
behavior is missing, update the parent-canonical harness through Ganthritor
harness governance.

## 3. Task Governance

Warp Prism owns a local `docs/tasks/` namespace. It does not inherit parent task
ranges. Executable task identity is `Task NNNN` inside Warp Prism only.

- `docs/tasks/00-planning/`: roadmaps, epics, stories, plans, holds,
  candidates. These are not executable tasks.
- `docs/tasks/01-open/`: template-complete executable tasks ready for builders.
- `docs/tasks/02-doing/`: one executor actively working.
- `docs/tasks/03-review/`: completed work awaiting independent review.
- `docs/tasks/04-completed/`: reviewer-approved work.

Executable tasks must follow `docs/tasks/000-template.md`, be at least 50 lines,
include checkbox subtasks, include a `Where` table, and include validation
commands. The first subtask must require reading existing code/docs before any
mutation.

## 4. Protected Files

Treat these files as protected. Read them before proposing edits and ask the
user before changing broad project contracts:

- `AGENTS.md`
- `README.md`
- `pubspec.yaml`
- platform/build configuration files

## 5. Product Constraints

- Keep the app read-only until a task explicitly authorizes mutation.
- Prefer mock workspace fixtures over live infrastructure.
- Do not introduce SQLite. If durable state ever becomes necessary, route design
  through PostgreSQL/Redis governance in the parent constitution.
- Do not touch unrelated Ganthritor child projects from Warp Prism tasks.
- Match Flutter/Dart project conventions already present in `lib/` and
  `pubspec.yaml`.
- Keep the visual direction aligned with the ASW Observatory brief: ultradark
  obsidian glass, restrained hacker/protoss accents, and desktop-first clarity.

## 6. Required Onboard

Before executing a Warp Prism task, run the local onboarding workflow:

```text
.agents/workflows/onboard.md
```

At minimum, read:

1. this `AGENTS.md`;
2. `.agents/rules/project-boundaries.md`;
3. `.agents/rules/task-governance.md`;
4. the assigned task file;
5. relevant planning/report context under `docs/`;
6. every file listed in the task `Where` table before editing.

## 7. Changelog and Continuity

For local Warp Prism-only changes, add entries under `.changelog/` (compat
symlink `docs/changelog` → `../.changelog`) via the manage-changelog engine.
For parent-significant harness changes, also use the parent Ganthritor
changelog engine.

Use `agent-wiki` / `agentlog` for durable role continuity under
`.memories/_by_lane/<lane>/` (`.memories` → `../.memories/warp-prism`). Residual
`.agents/profiles/` is not the live write root after profiles→memories migration.
