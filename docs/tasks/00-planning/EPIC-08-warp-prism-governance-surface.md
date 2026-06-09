# EPIC 08 — Warp-Prism Governance Surface

> **Planning Status**: Active Epic
> **Executable?**: No — planning artifact only.
> **Promotion Gate**: Promote after graph diagnostics service exists or is fully specified.

## Goal

Build diagnostic panels that expose canonicality, generated/read-only boundaries, orphaned assets, stale references, proof gaps, fan-in hotspots, and review pressure.

## Source Evidence

- `prompt.txt` requires Governance diagnostics: orphan workflows, skills with no triggers, tasks without verification commands, changelog entries without linked task, canonical/generated/archive assets, stale references, high fan-in skills, review queue pressure.
- `research.md` emphasizes source-of-truth vs generated read models and parent-canonical/child-local governance status.

## Scope

- Diagnostic model contracts.
- Governance overview panels.
- Drill-down from warning to affected assets.
- Severity/category semantics.
- Storytelling summaries for governance risk.

## Out of Scope

- Automatic repair.
- File mutation or canonical script execution.
- Real child/parent convergence audits.

## Candidate Stories

- Diagnostic service current-state audit.
- Orphan/stale/proof-gap panels.
- Canonicality/generated/archive visual semantics.
- High fan-in and review-pressure analytics.
- Governance drill-down to asset detail.

## Dependencies

- EPIC 01 for semantic colors/pills.
- EPIC 03 for graph metrics/diagnostics.
- EPIC 04 for route/layout.
- EPIC 09 for universal detail drill-down.

## Acceptance Criteria for Epic Completion

- Required diagnostic categories are computed from mock graph data.
- Warnings are explainable and link to affected assets.
- Generated vs canonical vs append-only vs mock assets are visually distinct.
- The screen remains read-only and does not imply unsafe mutation powers.
