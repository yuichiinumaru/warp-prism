---
id: 2025-04-10-T004-workspace-snapshot-export
date: 2025-04-10
project: asw-observatory
task: T004
type: feature
impact:
  - export
  - snapshot
  - governance
skills:
  - project-management
  - agent-wiki
---

# Workspace snapshot export feature

## Why

Operators need to export a point-in-time snapshot of the entire workspace graph for audit trails, compliance reports, and handoff documentation. Without export, governance surfaces are read-only with no way to produce artifacts.

## Changed

- Defined the snapshot export contract: JSON graph + markdown summary.
- Specified which fields are included per asset kind (id, kind, name, canonicality, edges).
- Added `proof_state` and `review_score` fields to the export schema.
- Planned the export button in the Governance workspace.

## Evidence

- `assets/mock_workspace/docs/tasks/01-open/T004-implement-workspace-snapshot-export.md` defines the feature scope.
- Export targets `lib/data/models/` for serialization.
