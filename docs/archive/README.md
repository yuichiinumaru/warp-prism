# Warp Prism Archive

This directory serves as the canonical home for historical, superseded, and retired artifacts under the **Archive-First Law** (zero deletion of repository artifacts by autonomous agents).

## State-Based Declutter Rule

Warp Prism uses lifecycle state—never epic numbers or task ID ranges—to distinguish active operational assets from historical corpus:

- **CURRENT OPERATING SET**:
  - All non-terminal tasks in active lanes (`docs/tasks/00-planning/`, `docs/tasks/01-open/`, `docs/tasks/02-doing/`, `docs/tasks/03-review/`).
  - Active planning documents and architecture roadmaps.
  - Current canonical architectural decisions and active contracts.
  - Evidence packets actively needed by in-flight work.

- **HISTORICAL CORPUS**:
  - Terminal tasks in `docs/tasks/04-completed/`.
  - Superseded planning artifacts and retired RFCs.
  - Old wave records and one-off execution scratch scripts.

> **State-Based Invariant**: Classification is strictly by lifecycle state, never by epic number or task ID range. Active tasks and planning may belong to any epic (for example, active tasks existing under EPIC-18/EPIC-19).

## Archive Subdirectories

- `root-scratch/`: Historical one-off fix, patch, test snippet, and migration scripts moved from the repository root, documented with full provenance in `PROVENANCE.md`.
