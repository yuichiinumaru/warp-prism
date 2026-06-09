---
id: planning-artifact-naming
title: Planning Artifact Naming and Promotion Governance
scope: universal
applies_to:
  - docs/tasks/00-planning/**
  - child-project-task-systems
triggers:
  - planning artifact
  - epic
  - story
  - strategic hold
  - task candidate
  - 00-planning
priority: high
status: active
---

# Planning Artifact Naming and Promotion Governance

> Status: Active
> Scope: `docs/tasks/00-planning/**` and project-local task systems.

## Purpose

`00-planning/` is a staging lane for ideas, epics, stories, roadmap context,
RF8 planning, and strategic holds. It is not a builder pickup queue.

Planning artifacts must be visually and semantically distinct from executable
tasks so agents do not mistake a broad plan, story, or strategically deferred
candidate for work that is ready to start.

## Core Rule

Only files promoted to executable task lanes (`01-open/`, `02-doing/`,
`03-review/`, `04-completed/`) receive executable task identity such as
`Task NNNN` and filenames such as `NNNN-project-description.md`.

Files in `00-planning/` MUST NOT use executable task identity unless they are
explicit historical imports being preserved as-is. Use planning prefixes instead.

## Planning Artifact Prefixes

Use these prefixes in `00-planning/`:

| Prefix | Meaning | Executable? |
| --- | --- | --- |
| `ROADMAP-` | Whole-project or wave ordering map. | No |
| `EPIC-` | Large milestone or domain of work. | No |
| `STORY-` | User-visible or capability slice that may later become one or more tasks. | No |
| `PLAN-` | RF8, architecture, sequencing, or evidence plan. | No |
| `HOLD-` | Task-like candidate intentionally withheld for a macro planning or roadmap gate. | No |
| `CANDIDATE-` | Near-task draft that still needs promotion checks before `01-open/`. | No |

Recommended filename forms:

```text
ROADMAP-<project>-<slug>.md
EPIC-<nn>-<project>-<slug>.md
STORY-<epic-nn>-<story-nn>-<project>-<slug>.md
PLAN-<project>-<slug>.md
HOLD-<project>-<slug>.md
CANDIDATE-<project>-<slug>.md
```

Do not name a planning artifact `NNNN-project-description.md` merely because it
will probably become a task later.

## Strategic Holds

A strategic hold is a task-like candidate that may be technically specifiable
but should not be exposed to builders yet because a larger planning gate,
external dependency, cross-project sequence, architecture decision, or roadmap
timing constraint makes early execution harmful.

Use `HOLD-*` when:

- the artifact is not blocked by another ordinary task, but by a macro roadmap
  or architecture gate;
- a builder might otherwise pick it up too early from `01-open/`;
- executing it early would force guesses, duplicate future work, or couple to an
  unstable upstream design.

Each `HOLD-*` artifact should include:

- `Planning Status: Strategically Deferred`;
- a concrete `Promotion Gate`;
- the reason it is held;
- the planned promotion target, if known.

When the macro gate clears, promote the artifact by creating a new executable
task file in `01-open/` with local task numbering. Do not simply rename the hold
file if doing so would erase planning history.

## Child Project Task Systems

When a child project owns its own local `docs/tasks/` tree, that path defines a
separate task namespace. Local executable task numbers SHOULD start at `0001`
unless a project-local roadmap explicitly defines another scheme.

Do not inherit parent repository epic blocks or numeric ranges solely because
the child project lives inside a parent checkout. Parent task ranges are only
for the parent ledger unless the child task is intentionally being managed in
that parent ledger.

## Promotion Gate to `01-open/`

Promotion from `00-planning/` to `01-open/` requires:

1. a concrete, single-owner executable objective;
2. file scope and dependencies resolved enough to prevent guesswork;
3. validation commands and expected outputs identified;
4. template compliance for executable tasks;
5. local task number assigned in the owning task namespace;
6. no unresolved strategic hold gate.

After promotion, reference the executable task as `Task NNNN` plus optional slug.
Before promotion, reference the artifact by its planning filename and prefix.

## Anti-Patterns

- Putting `Task 0001` in `00-planning/` when it is not builder-ready.
- Using a parent task range for a child-local task ledger.
- Moving strategic holds into `01-open/` just because no immediate code blocker
  exists.
- Treating `EPIC-*` or `STORY-*` as runnable implementation work.
- Renaming a hold into a task without preserving the macro planning rationale.
