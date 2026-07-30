# Drain Review: Task 1408 — Observatory Package Imports Cleanup — 2026-07-17

## Review Lineage

- **Previous reports**:
  - `docs/reports/review-wave-2026-07-09/task-1408-imports-cleanup-independent-rereview.md` — **100/100** (claimed deep relative = 0)
  - `docs/reports/build-gate-review/1408-review-2026-07-09-import-scope.md` — **100/100**
- **Review mode**: drain re-review (import-scope contract); no git

## Score And Verdict

- **Prior score (draft)**: `100/100`
- **New score**: `74/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Lane recommendation**: `docs/tasks/02-doing/`
- **Lane outcome**: moved to `docs/tasks/02-doing/`

## Delta Summary

### REGRESSION (blocking)

Primary exit condition **fails**:

```text
rg "import '\.\./\.\./\.\." apps/observatory/lib/features/
```

**5 matches** in `lib/features/governance/presentation/governance_page_shell.dart`:

| Line | Import |
| --- | --- |
| 16 | `../../../data/models/governance_diagnostics.dart` |
| 17 | `../../../data/models/workspace_graph.dart` |
| 18 | `../../../data/providers/workspace_providers.dart` |
| 19 | `../../../data/services/workspace_diagnostics_service.dart` |
| 20 | `../../../data/services/workspace_graph.dart` |

Prior independent review explicitly re-proved **0** deep relatives and scored 100. Live is a clear **REGRESSION** of the import-scope contract (3+ `../` levels).

### Allowed residual (unchanged)

- 3× shallow `../../data/` map-root imports still present (out of scope per simplicity pass).

## Findings

| ID | Class | Severity | Status | Summary |
| --- | --- | --- | --- | --- |
| F1 | REGRESSION | High | Open | 5 deep relative imports reintroduced in governance_page_shell |
| F2 | PERSISTENT | Low (allowed) | Open / out of scope | 3 map shallow `../../data/` |
| F3 | SUPERSEDED | — | Closed | Prior package DS* red | Cleared historically |

## Exit Condition Verification

| # | Condition | Met? | Live proof |
| --- | --- | --- | --- |
| 1 | All deep relative (3+) in `lib/features/` migrated | **NO** | 5 hits in governance_page_shell |
| 2 | Import-scope analyze / package URIs | **PARTIAL** | Existing package URIs elsewhere OK; residual deep relatives unresolved |
| 3 | Changelog | **PASS** | present (stale residual=0 claim) |
| 4 | Completion Evidence | **FAIL currency** | Claims 0 deep residual |

## Path To 100

1. Migrate the 5 `../../../data/...` imports in `governance_page_shell.dart` to `package:warp_prism_observatory/...` URIs.
2. Re-prove: `rg "import '\.\./\.\./\.\." lib/features/` → **0**.
3. `dart analyze` on the residual file + package URI target existence walk.
4. Refresh Completion Evidence / ledger (do not claim 0 until live).

## Score Math (start 100)

| Item | Delta |
| --- | --- |
| Primary exit fail (5 deep relatives) | −22 |
| Stale CE / ledger residual=0 claim | −4 |
| **Total** | **74** |

## Lane Action

- Move → `docs/tasks/02-doing/` (S<90; builder fix required)
