# Drain Review: Task 0310 — Backbone Model Contract Audit — 2026-07-17

## Review Lineage

- **Prior draft**: 2026-07-09 independent **95/100** HELD_IN_REVIEW_PATH_TO_100
- **Review mode**: drain re-review
- **No git / no tasklist**

## Score And Verdict

- **Prior score**: `95/100`
- **New score**: `95/100`
- **Verdict**: `ACCEPTED_COMPLETE` (S≥90)
- **Lane**: `docs/tasks/04-completed/`

## Live Validation

| Command | Result |
| --- | --- |
| `flutter analyze lib/data/models` | **No issues found** |
| `flutter test test/data/models/workspace_graph_models_test.dart` | **27/27 PASS** |

## Exit Conditions

| Condition | Met | Evidence |
| --- | --- | --- |
| Normalized backbone + barrel | YES | workspace_graph, task_contracts, changelog_contracts, governance_diagnostics, data_models |
| Legacy superseded with ownership | YES | models.dart SUPERSEDED notice; barrel prefers backbone |
| Analyze / tests | YES | clean + 27/27 |
| Changelog | YES | `20260709-122047-0310-…` |

## Findings

| ID | Class | Sev | Status | Summary |
| --- | --- | --- | --- | --- |
| F4 | PERSISTENT | Low | Open (accepted residual) | Legacy `models.dart` still importable for compatibility |
| NEW | — | — | None blocking | Dual-surface residual unchanged; not an exit failure |

## Path-to-100 residual (non-blocking)

1. Retire or fully isolate legacy `Asset`/`AssetType`/`AssetEdge` when consumers finish migration.
2. Honest self-score ≤97 until dual surface gone.

## Why complete at 95

Binary exits green under live SDK; residual is documented ownership debt, not incomplete contract delivery.
