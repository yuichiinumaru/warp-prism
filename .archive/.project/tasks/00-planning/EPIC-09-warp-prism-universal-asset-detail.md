# EPIC 09 — Warp-Prism Universal Asset Detail

> **Planning Status**: Active Epic
> **Executable?**: No — planning artifact only.
> **Promotion Gate**: Promote after asset model and shell routing can identify assets by stable IDs.

## Goal

Create a universal detail page/drawer/split-pane inspector for any asset kind in the normalized workspace graph.

## Source Evidence

- `prompt.txt` requires Asset Detail for skill, task, and agent examples, including incoming/outgoing links and related tasks/changelog entries.
- `research.md` recommends detail panels that expose identity, role, sub-structure, incoming links, operational usage, and governance.

## Scope

- Stable asset route/deep-link shape.
- Detail layouts for agent, skill, subskill, workflow, task, changelog, script, reference, and rule where available.
- Incoming/outgoing edge lists.
- Related tasks/changelog/skills/workflows panels.
- Detail drawer/split-pane integration for desktop and full-screen fallback for narrow layouts.

## Out of Scope

- Editing assets.
- Rendering arbitrary markdown with full rich-text parity unless needed by a promoted task.
- Real external file opening.

## Candidate Stories

- Asset ID and route contract.
- Skill detail surface.
- Task detail surface.
- Agent/workflow/changelog detail variants.
- Edge navigation and related asset lists.
- Responsive detail behavior.

## Dependencies

- EPIC 03 for stable asset IDs and edges.
- EPIC 04 for route/shell integration.
- EPIC 05-08 consume this detail surface.

## Acceptance Criteria for Epic Completion

- Any asset card/node can open a relevant detail view.
- Detail view shows metadata, markdown/body summary, incoming/outgoing links, and related assets.
- Deep links or route state can identify selected assets where feasible.
- Unknown/unsupported asset kinds degrade gracefully.
