# Review Report: Task 0514 — Map empty/loading/error states and proof coverage — 2026-06-19

## Review Lineage

- **Current task**: Task 0514 (`0514-warp-prism-map-states-and-proof-coverage`); live path resolved by filesystem search at `docs/tasks/03-review/0514-warp-prism-map-states-and-proof-coverage.md` before routing.
- **Previous reports read**:
  - `docs/reports/build-gate-review/0514-review.md` — claimed `100/100`, now invalidated by live analyzer output and failing state/Map tests.
- **Related reports considered**:
  - `docs/reports/build-gate-review/0510-review.md` through `0513-review.md` — state handling sits on top of route, catalog, graph, and inspector.
- **Review mode**: re-review / independent parent-reviewer gate.

## Score And Verdict

- **Score**: `79/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Lane recommendation**: `return-to-doing`

## Axiom Compliance

| # | Axiom | Status | Evidence |
| --- | --- | --- | --- |
| 1 | Analyzer Integrity | **FAIL** | `flutter analyze lib/features/map test/features/map` reports **45 issues**, including Map state/test issues and unused imports in state widgets. |
| 2 | Lifecycle Safety | **PASS** | `MapStatePanel` creates **0** controllers/subscriptions/timers/listeners; **0** disposals required. Parent page resources are disposed as counted in Task 0510. |
| 3 | Dependency Direction | **PASS** | State panels are presentation-only widgets over typed feature state; no parser/filesystem access found. |
| 4 | UI Accessibility | **PARTIAL** | State copy is explicit and distinct (`loading`, `emptyCorpus`, `noResults`, `graphNoEdges`, `error`, `noSelection`), but buttons/action semantics are delegated to DS and not proven by state tests. |
| 5 | Proof Reality | **FAIL** | `flutter test test/features/map` is **95 total / 4 failed**; `map_surface_states_test.dart` fails its graph happy-path due `RenderFlex` overflow. Task claims analyzer/test pass at `docs/tasks/03-review/0514-warp-prism-map-states-and-proof-coverage.md:54-56`. |
| 6 | Release Security | **PASS** | No secrets, endpoints, signing changes, release logging, or write behavior in reviewed state files. |

## Delta Summary

### Resolved Since Previous Review

- `RESOLVED`: Dedicated `MapSurfaceState` enum exists at `apps/observatory/lib/features/map/widgets/map_state_panel.dart:16-35`.
- `RESOLVED`: `MapStatePanel` renders distinct copy for loading, empty corpus, no-results, graph-no-edges, error, and no-selection at `map_state_panel.dart:82-163`.
- `RESOLVED`: Changelog evidence exists for Task 0514 at `docs/changelog/20260607-220705-0000-2026-06-07-task-0514-map-states-proof-coverage-repair-bot.md`.

### Persistent Findings

- `PERSISTENT`: Prior report's passing gate claims are false under live SDK evidence.

### Regressions

- `REGRESSION`: Previous 100/100 score is unreproducible because live Map test and analyzer gates fail.

### New Findings

- `NEW`: `map_surface_states_test.dart` fails its Graph happy-path due a layout overflow in the Graph state surface path.
- `NEW`: Task 0514 state handling does not fix the larger route data gap: production Map starts as empty state because no repository-loaded assets reach the page.

### Evidence Gaps / External Blockers

- `EVIDENCE_GAP`: No passing proof exists for the full degraded-state suite.
- `EXTERNAL_BLOCKER`: None. Flutter and Dart are installed.

## Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | REGRESSION | High | Open | Analyzer and feature tests fail despite checked exit conditions. | 2026-06-19 | `flutter analyze lib/features/map test/features/map` → `45 issues found`; `flutter test test/features/map` → `95 total / 4 failed`; task says pass at `docs/tasks/03-review/0514-warp-prism-map-states-and-proof-coverage.md:54-56`. |
| F2 | NEW | High | Open | State test suite fails in graph happy-path due toolbar overflow. | 2026-06-19 | `map_surface_states_test.dart:88-126` fails; exception points to `apps/observatory/lib/features/map/widgets/map_graph_panel.dart:101`. |
| F3 | NEW | Moderate | Open | Explicit state panels exist, but production Map only proves empty/default state because real load/error/success transitions are not connected to repository async state. | 2026-06-19 | `MapWorkspaceProvider` supports manual `setLoading`, `setError`, `loadAssets` at `map_workspace_provider.dart:88-121`, but `MapWorkspacePage` never calls repository providers or `loadAssets`. |
| F4 | EVIDENCE_GAP | Moderate | Open | Action semantics/touch-target proof is indirect; state tests assert text/callbacks, not Semantics or 48x48 focusable targets. | 2026-06-19 | `map_surface_states_test.dart:133-400` verifies copy/callbacks only; no `SemanticsTester` or hit-size assertions. |

## Exact Evidence

- State enum covers exactly **6** states: `loading`, `emptyCorpus`, `noResults`, `graphNoEdges`, `error`, `noSelection` at `map_state_panel.dart:17-35`.
- `MapStatePanel` switch handles exactly **6** cases at `map_state_panel.dart:82-163`.
- Parent page state branches:
  - Catalog loading/error/empty/no-results at `apps/observatory/lib/features/map/map_workspace_page.dart:212-257`.
  - Graph loading/error/no-edges at `apps/observatory/lib/features/map/map_workspace_page.dart:279-316`.
  - Inspector no-selection at `apps/observatory/lib/features/map/widgets/map_inspector_panel.dart:40-46`.
- Lifecycle exact count for Task 0514-owned state panel: **0** controllers/subscriptions/timers/listeners created; **0** disposals required.

## Runtime Wiring Proof

1. `/map` route builds `MapWorkspacePage` through `apps/observatory/lib/app/router.dart:52-59` and `apps/observatory/lib/app/pages/map_page.dart:14-16`.
2. `MapWorkspacePage` reads `MapWorkspaceState` from its local stream at `apps/observatory/lib/features/map/map_workspace_page.dart:119-123`.
3. Catalog state rendering branches are executed in `_buildCatalogTab` at `map_workspace_page.dart:207-271`.
4. Graph state rendering branches are executed in `_buildGraphTab` at `map_workspace_page.dart:278-316`.
5. Inspector no-selection is executed in `MapInspectorPanel` at `map_inspector_panel.dart:40-46`.
6. Missing: no production async repository state is watched, so loading/error/success are only reachable by manual provider methods or test-injected `initialState`, not by actual app data flow.

## Commands

- `flutter --version` — Flutter `3.44.1`, Dart `3.12.1` installed.
- `HOME="$PWD/../../tmp/home" PUB_CACHE="$PWD/../../tmp/pub-cache" flutter analyze` — failed, `378 issues found`.
- `HOME="$PWD/../../tmp/home" PUB_CACHE="$PWD/../../tmp/pub-cache" flutter analyze lib/features/map test/features/map` — failed, `45 issues found`.
- `HOME="$PWD/../../tmp/home" PUB_CACHE="$PWD/../../tmp/pub-cache" flutter test test/features/map` — failed, `95 total / 4 failed`.

## Stale-Evidence Notes

- Previous report's SDK blocker is stale.
- Task 0514's checked analyzer/test exit conditions are stale false status because live gates fail.
- Changelog evidence exists for Task 0514 and is not a blocker.

## Path To 100

1. Fix graph toolbar overflow so `map_surface_states_test.dart` graph happy-path passes.
2. Connect Map loading/error/empty/success to `workspaceSnapshotAsyncProvider` or equivalent repository-backed async state, not only manual test injection.
3. Add Semantics/touch-target tests for state action buttons (`Retry`, `Clear filters`) and no-selection guidance.
4. Clear all Map analyzer issues and rerun `flutter test test/features/map` to 0 failures.

## Task Ledger Patch Suggestion

```markdown
### 2026-06-19 — reviewers independent re-review
**Score**: 79/100 — REJECTED_TO_DOING
**Verdict**: Return to `02-doing` for failing state proof, graph overflow, repository-backed async state wiring, and analyzer cleanup.
**Report**: `docs/reports/review-wave-2026-06-19/0514-map-states-proof-coverage-rereview.md`
**Commands**: `flutter analyze` → 378 issues; `flutter analyze lib/features/map test/features/map` → 45 issues; `flutter test test/features/map` → 95 total / 4 failed.
**Open blockers**: `map_surface_states_test.dart` graph happy-path fails, production Map states are test-injected/manual, analyzer not clean.
**Path to 100**: responsive graph toolbar, repository-backed async states, Semantics/touch-target state tests, analyzer clean, Map tests pass.
```
