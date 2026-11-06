# Epic Template

Living-program authoring aid — **not** an executable task. Copy the instance
shape below into `.project/tasks/epics/E##-slug.md`. Tasks need no Story;
Stories need no Epic; use this only when a program genuinely needs a durable
cross-story home. Path-projection markers are rewritten only where the
tasklist-sync generator is installed; elsewhere they stay inert comments.

---
epic_id: E##
title: "<short epic title>"
status: active   # active | frozen | archived
owner_lane: architects
# Optional machine list of story ids (E##-S##)
story_ids: []
# Optional rollup of task ids across stories (prefer stories for attachment)
task_ids: []
---

# Epic E##: <Title>

> **Type**: `EPIC` (living program — **not** an executable task)
> **Status**: Active | Frozen | Archived
> **Home**: `.project/tasks/epics/E##-slug.md` (non-lane)
> **Template**: `.project/tasks/templates/epic.md`

---

## Objective

[One paragraph: program outcome and why it exists.]

## Non-goals

- [What this epic will not own]

## Stories

Hand-authored links to story files (stable story ids). Prefer one row per story.

| Story ID | Title | File |
|----------|-------|------|
| E##-S01 | <title> | [E##-S01-slug.md](../stories/E##-S01-slug.md) |

Add new stories by appending rows; do not reopen frozen stories for unrelated scope.

## Tasks (canonical, optional rollup)

IDs only — prefer listing tasks on **stories**. Use this section only for
epic-level orphan notes or temporary attachment before a story exists.

- Task NNNN

## Path projection (generated)

> Rewritten by tasklist-sync where installed (generator:
> `.opencode/tools/_project/tasks/`); elsewhere leave the markers untouched.

<!-- task-path-sync:start -->
| ID | Title | Path |
|----|-------|------|
| _(run tasklist-sync)_ | | |
<!-- task-path-sync:end -->

## Success picture

- [Measurable program outcomes]

## Notes

- Orphan tasks outside this epic are expected until deliberate remount.
