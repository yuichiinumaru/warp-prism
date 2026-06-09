---
name: warp-prism-onboard
description: Local onboarding workflow for agents executing Warp Prism tasks.
---

# Warp Prism Onboard Workflow

Use this workflow before executing, reviewing, or modifying a Warp Prism task.

## Step 1 — Read Governance

- Read `AGENTS.md`.
- Read `.agents/rules/project-boundaries.md`.
- Read `.agents/rules/task-governance.md`.
- If harness behavior is needed, use symlinked parent skills under
  `.agents/skills/` rather than copying parent files.

## Step 2 — Read Product Evidence

Read only what is relevant to the assigned work, but do not skip the primary
contract documents when starting a new wave:

- `docs/prompt.txt`
- `docs/research.md`
- `docs/draft.md`
- `docs/reports/warp-prism-task-gap-overlap-audit.md`
- `docs/reports/warp-prism-task-namespace-renumbering-map.md`

## Step 3 — Resolve Task Context

- Find the assigned task in `docs/tasks/`.
- Read the full task before acting.
- Read every file listed in the task `Where` table before editing.
- Confirm dependency tasks named in `Depends on` are satisfied or explicitly not
  required for the current operation.

## Step 4 — Execute Narrowly

- Modify only files required by the task.
- Preserve read-only product semantics unless the task explicitly changes them.
- Avoid broad refactors and unrelated cleanup.
- Keep validation commands scoped to the task.

## Step 5 — Close Out

- Fill `Completion Evidence` in the task before moving to review.
- Add a local changelog entry under `docs/changelog/` for Warp Prism-only work.
- Use parent Ganthritor changelog/harness ledgers only when parent-significant
  harness assets changed.
- Record durable continuity through `agent-wiki` when the work creates reusable
  operational knowledge.
