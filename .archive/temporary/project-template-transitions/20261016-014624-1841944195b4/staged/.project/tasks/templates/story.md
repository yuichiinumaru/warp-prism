# Story Template

Scoped-slice authoring aid — **not** an executable task. Copy the instance
shape below into `.project/tasks/stories/E##-S##-slug.md`. Tasks need no
Story; Stories need no Epic; use this only when a slice genuinely needs a
durable home above tasks. Path-projection markers are rewritten only where
the tasklist-sync generator is installed; elsewhere they stay inert comments.

---
epic_id: E##
story_id: E##-S##
title: "<short story title>"
status: active   # active | frozen | archived
# Canonical task identity list (IDs only; no lane paths)
task_ids: []
---

# Story E##-S##: <Title>

> **Type**: `STORY` (scoped slice — **not** an executable task)
> **Epic**: [E##](../epics/E##-slug.md)
> **Home**: `.project/tasks/stories/E##-S##-slug.md` (non-lane)
> **Template**: `.project/tasks/templates/story.md`

---

## Objective

[Concrete slice outcome. Freeze this story when tasks ship; new scope = new story.]

## Scope

### In scope
- …

### Out of scope
- …

## Tasks (canonical)

**IDs only.** Never write mutable lane paths here.

- Task NNNN

Frontmatter `task_ids` should match this list when both are used.

## Path projection (generated)

> Rewritten by tasklist-sync where installed (generator:
> `.opencode/tools/_project/tasks/`, from the canonical ID list above and/or
> frontmatter `task_ids`); elsewhere leave the markers untouched.
> Contract: `<!-- task-path-sync:start -->` … `<!-- task-path-sync:end -->`
> Missing IDs → `MISSING` (never invent paths).

<!-- task-path-sync:start -->
| ID | Title | Path |
|----|-------|------|
| _(run tasklist-sync)_ | | |
<!-- task-path-sync:end -->

## Acceptance (story level)

- [ ] All listed tasks through review/completed as required by the program
- [ ] Scope frozen or explicit successor story linked
