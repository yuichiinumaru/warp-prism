# Changelog — Stabilization Wave Corrections

> **Date**: 2026-06-09
> **Type**: planning | governance | correction
> **Status**: Complete — corrections applied based on review of stabilization wave artifacts.

## Summary

Applied corrections identified during review of stabilization wave planning
artifacts against the analysis document (`warp-prism-analysis.txt`). Two new
tasks created, four existing files corrected, one priority elevated.

## Corrections Applied

### New Tasks Created

| Task | Name | Location | Rationale |
|------|------|----------|-----------|
| 1208 | Existing Task Lane Reconciliation and Review Backlog Snapshot | `docs/tasks/01-open/` | Analysis identified 79 tasks in `02-doing/` with ambiguous status. Without classifying them, the promotion state model has no impact on the existing backlog. |
| 1126 | README Monorepo Reality Alignment | `docs/tasks/01-open/` | README describes a single-app structure with `lib/` at root. Real structure is Melos monorepo with `apps/` and `packages/`. Analysis lists this as P0 quick win. |

### Files Modified

| File | Change | Rationale |
|------|--------|-----------|
| `EPIC-12` | Added task 1208 to candidate table and dependencies | New task must be tracked by its epic. |
| `EPIC-13` | Added reordering note explaining Gallery Compile promoted from 1309 to 1304 | Analysis originally proposed 1309; model moved it to 1304 because it's a real package gate blocker. Decision is defensible but must be documented. |
| Task 1408 | Priority elevated from P2 to P1 | Analysis lists "Fix Observatory broken relative imports" as P0 item 1. P2 was too low. |
| `warp-prism-stabilization-strategy.md` | Updated dependency chain, task count (24→26), execution order (added 1208 and 1126), and Observatory priority note | Must reflect the new tasks and corrected priorities. |

### What Was NOT Changed

- No tasks in `02-doing/` were modified (that is Task 1208's job).
- No code files were modified.
- No existing EPICs were restructured.
- No features were added.
- The EPIC-13 numbering shift was documented, not reverted (the reordering is a better execution order).

## Review Findings Addressed

| Finding | Status |
|---------|--------|
| Missing task for 79-task backlog reconciliation | ✅ Created 1208 |
| Missing README alignment task | ✅ Created 1126 |
| EPIC-13 reordering undocumented | ✅ Note added |
| Task 1408 priority too low | ✅ Elevated to P1 |
| Task 1110 fixture path mismatch | 📝 Deferred — not critical for stabilization |
| Dependency 1205→1301 not formal | 📝 Already documented in task header (soft dependency) |
