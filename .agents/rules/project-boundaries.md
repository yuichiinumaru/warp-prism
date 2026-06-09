---
id: warp-prism-project-boundaries
title: Warp Prism Project Boundaries
scope: warp-prism
status: active
---

# Warp Prism Project Boundaries

Warp Prism is a child project under Ganthritor with local task governance and
parent-canonical reusable harness assets.

## Hard Boundaries

- Work only inside `warp-prism/` unless the task explicitly names a parent
  Ganthritor harness surface.
- Do not modify sibling child projects.
- Do not convert mock observability screens into live runtime controls without a
  new planning artifact and task wave.
- Do not introduce SQLite.
- Do not add network or persistence dependencies for demo data unless a task
  explicitly changes the data contract.

## Current Product Contract

- Flutter desktop-first interface.
- Read-only ASW Observatory prototype.
- Mock workspace corpus is the default data source.
- Atomic Design System work precedes broad feature-screen polish.

## Parent-Canonical Harness Assets

These paths are inherited through symlinks and should not be replaced with local
copies:

- `.agents/skills`
- `.agents/agents`
- `.codex/agents`

If a reusable skill, workflow, or agent needs improvement, update the parent
Ganthritor harness through the parent governance workflow and record the change
in the parent changelog/harness-evolution ledger.
