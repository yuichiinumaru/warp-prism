# Review Report: Task 0510 — Map workspace scaffold and route contract — 2026-06-19

## Review Lineage

- **Current task**: Task 0510 (`0510-warp-prism-map-workspace-scaffold`); live path resolved by filesystem search at `docs/tasks/03-review/0510-warp-prism-map-workspace-scaffold.md` before routing.
- **Previous reports read**:
  - `docs/reports/build-gate-review/0510-review.md` — claimed `100/100`, now invalidated by live Flutter SDK availability, analyzer output, and failing Map tests.
- **Related reports considered**:
  - `docs/reports/build-gate-review/0511-review.md` through `docs/reports/build-gate-review/0514-review.md` — cumulative Map surface changes now affect the scaffold route and test gate.
- **Review mode**: re-review / independent parent-reviewer gate.

## Score And Verdict

- **Score**: `78/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Lane recommendation**: `return-to-doing`

## Axiom Compliance

| # | Axiom | Status | Evidence |
| --- | --- | --- | --- |
| 1 | Analyzer Integrity | **FAIL** | `flutter analyze lib/features/map test/features/map` reports **45 issues** including unused imports and lint infos in Map files; package-level `flutter analyze` reports **378 issues**. |
| 2 | Lifecycle Safety | **PASS** | 1 `TabController` created at `apps/observatory/lib/features/map/map_workspace_page.dart:48,74`; listener removed and controller disposed at `apps/observatory/lib/features/map/map_workspace_page.dart:85-86`. 1 `StreamController` created at `apps/observatory/lib/features/map/map_workspace_provider.dart:34`; disposed at `apps/observatory/lib/features/map/map_workspace_provider.dart:138-140`. |
| 3 | Dependency Direction | **PARTIAL** | Feature imports data models only, but the route-local page owns a manual provider instead of consuming the app data/provider backbone, leaving the scaffold disconnected from the repository path. |
| 4 | UI Accessibility | **PARTIAL** | 4 `TabBar` tabs are labeled (`Agents`, `Skills`, `Workflows`, `Graph`) at `map_workspace_page.dart:50-67,177-199`; graph chips have Semantics at `map_graph_panel.dart:151-155`. The feature also has 2 `GestureDetector` source sites, and the catalog clear action at `map_catalog_panel.dart:130-139` has no Semantics/button/focus wrapper. |
| 5 | Proof Reality | **FAIL** | Live `flutter test test/features/map` result is **95 total / 4 failed**, contradicting prior 100/100 report claims. Task 0510 exit conditions still show unchecked analyzer/test/changelog boxes at `docs/tasks/03-review/0510-warp-prism-map-workspace-scaffold.md:51-57`. |
| 6 | Release Security | **PASS** | No hardcoded secrets, endpoints, signing, Android release config, or release logging found in the reviewed Map files. |

## Delta Summary

### Resolved Since Previous Review

- `RESOLVED`: The route scaffold exists: `appRouter` registers `/map` at `apps/observatory/lib/app/router.dart:52-59`; `MapPageShell` forwards to `MapWorkspacePage` at `apps/observatory/lib/app/pages/map_page.dart:10-16`.
- `RESOLVED`: The page exposes the four required subviews through `_tabs` at `apps/observatory/lib/features/map/map_workspace_page.dart:50-67`.

### Persistent Findings

- `PERSISTENT`: Changelog evidence remains absent for Task 0510. The task completion evidence says `Pending` at `docs/tasks/03-review/0510-warp-prism-map-workspace-scaffold.md:135-136`, and no Task 0510 changelog entry was found among `docs/changelog/*051*.md`.

### Regressions

- `REGRESSION`: The previous report claimed 100/100 despite stating Flutter SDK was unavailable. Live review has Flutter `3.44.1` and Dart `3.12.1`; analyzer/test gates now execute and fail.

### New Findings

- `NEW`: The Map feature test suite fails from scaffold-visible graph rendering overflows and no-results assertion drift.
- `NEW`: The production `/map` route instantiates `MapWorkspacePage` with no repository-backed initial state, so the scaffold route opens an empty feature-local provider rather than a loaded Map workspace.

### Evidence Gaps / External Blockers

- `EVIDENCE_GAP`: No fresh passing package-level analyzer/test evidence exists for Task 0510.
- `EXTERNAL_BLOCKER`: None. Flutter/Dart SDK is installed in this environment.

## Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | REGRESSION | High | Open | Analyzer gate is not clean; scoped Map analysis has 45 issues and package analysis has 378 issues. | 2026-06-19 | Command output: `flutter analyze lib/features/map test/features/map` → `45 issues found`; `flutter analyze` → `378 issues found`. |
| F2 | NEW | High | Open | The Map test gate fails: 95 tests run, 4 fail. | 2026-06-19 | Command output: `flutter test test/features/map` → `+95 -4`; failures include `map_graph_panel.dart:101` overflow and `map_catalog_panel_test.dart:429` missing `Clear filters`. |
| F3 | NEW | High | Open | Production route wiring stops at an empty manually-owned provider; no repository/view-model/load path feeds the Map scaffold. | 2026-06-19 | `/map` → `MapPageShell` at `apps/observatory/lib/app/router.dart:52-59`; `MapPageShell` → `MapWorkspacePage` at `apps/observatory/lib/app/pages/map_page.dart:14-16`; provider initialized only from `widget.initialState` at `apps/observatory/lib/features/map/map_workspace_page.dart:72`; no `loadAssets` call or Riverpod data provider watch in `map_workspace_page.dart:69-318`. |
| F4 | PERSISTENT | Moderate | Open | Required changelog evidence for Task 0510 is still missing. | Task evidence / 2026-06-13 report | `docs/tasks/03-review/0510-warp-prism-map-workspace-scaffold.md:135-136`; `docs/reports/build-gate-review/0510-review.md:63-65`. |
| F5 | NEW | Moderate | Open | The catalog clear affordance is a raw `GestureDetector` without Semantics/button/focus treatment. | 2026-06-19 | `apps/observatory/lib/features/map/widgets/map_catalog_panel.dart:129-139`. |

## Exact Evidence

- Task status/header: `docs/tasks/03-review/0510-warp-prism-map-workspace-scaffold.md:1-9` says Ready For Review, while exit boxes for route, tabs, tests, analyzer, feature tests, and changelog remain unchecked at `:51-57`.
- Previous report mismatch: `docs/reports/build-gate-review/0510-review.md:7-19` claims 100/100 and says SDK unavailable; live `flutter --version` reports Flutter `3.44.1`.
- Controller lifecycle count: **2 disposable resources created**, **2 disposed**.
  - `TabController`: created `map_workspace_page.dart:48,74`; listener added `:80`; listener removed `:85`; disposed `:86`.
  - `StreamController<MapWorkspaceState>`: created `map_workspace_provider.dart:34`; closed `:138-140`.
- Explicit feature interactive count from reviewed Map files: **4 tabs**, **3 graph mode chips**, **1 conditional catalog clear action**, **N asset cards where N = displayed assets**. Feature-local Semantics wrappers: **3 source widgets** in `map_graph_panel.dart:88-90,120-123,151-155`; no feature-local Semantics around the catalog clear action at `map_catalog_panel.dart:130-139`.

## Runtime Wiring Proof

Production route wiring exists but stops before real data hydration:

1. `apps/observatory/lib/main.dart:5-6` runs `ProviderScope(child: WarpPrismApp())`.
2. `apps/observatory/lib/app/app.dart:14-19` wires `MaterialApp.router` to `appRouter`.
3. `apps/observatory/lib/app/router.dart:52-59` registers `/map` and builds `MapPageShell`.
4. `apps/observatory/lib/app/pages/map_page.dart:14-16` returns `const MapWorkspacePage()`.
5. `apps/observatory/lib/features/map/map_workspace_page.dart:72` creates `MapWorkspaceProvider(initialState: widget.initialState)`; in production `initialState` is null, so `MapWorkspaceProvider` falls back to `const MapWorkspaceState()` at `map_workspace_provider.dart:36-37`.
6. No production code path calls `MapWorkspaceProvider.loadAssets()`; `grep` found `loadAssets` only in tests and provider definition. Result: the route can open but does not load the normalized workspace backbone.

## Commands

- `git status --short` — repository has substantial pre-existing uncommitted changes; review treated live filesystem as authoritative and avoided shared index rebuilds.
- `flutter --version` — Flutter `3.44.1`, Dart `3.12.1` installed.
- `dart --version` — Dart `3.12.1` installed.
- `HOME="$PWD/../../tmp/home" PUB_CACHE="$PWD/../../tmp/pub-cache" flutter analyze` from `apps/observatory` — **failed**, `378 issues found`.
- `HOME="$PWD/../../tmp/home" PUB_CACHE="$PWD/../../tmp/pub-cache" flutter analyze lib/features/map test/features/map` from `apps/observatory` — **failed**, `45 issues found`.
- `HOME="$PWD/../../tmp/home" PUB_CACHE="$PWD/../../tmp/pub-cache" flutter test test/features/map` from `apps/observatory` — **failed**, `95 total / 4 failed`.

## Stale-Evidence Notes

- The prior build-gate report's SDK blocker is stale. Flutter is installed and can run analyzer/tests.
- The prior `100/100` score is not reproducible: live commands fail.
- Historical lane paths are not scored down by themselves under lane-neutral policy; the blocker is false current completion evidence and failing gates.

## Path To 100

1. Wire production `/map` to the repository/provider backbone: build `MapWorkspaceState.catalogAssets` from `workspaceSnapshotAsyncProvider` or `workspaceGraphAsyncProvider`, then pass the loaded state to the Map feature without direct widget parsing.
2. Fix Map test failures: make `_ModeSelector` responsive/scrollable or wrap mode chips/counts so `map_graph_panel.dart:101` cannot overflow at 800px; align `MapNoResultsState` button behavior with its tests or update tests to the intended contract.
3. Clean all Map-scoped analyzer issues: remove unused imports in `map_graph_projection.dart`, `map_workspace_page.dart`, and Map widgets; fix `prefer_const_*`, dangling library comments, and deprecated `withOpacity` usages.
4. Add Task 0510 changelog evidence under `docs/changelog/` or explicitly document an approved exception.
5. Add an app-router widget test that pumps `WarpPrismApp`, navigates to `/map`, and proves the route renders loaded Map state through the same production provider path.

## Task Ledger Patch Suggestion

```markdown
### 2026-06-19 — reviewers independent re-review
**Score**: 78/100 — REJECTED_TO_DOING
**Verdict**: Return to `02-doing` for Map route data wiring, failing test gate, analyzer cleanup, and missing changelog evidence.
**Report**: `docs/reports/review-wave-2026-06-19/0510-map-workspace-scaffold-rereview.md`
**Commands**: `flutter analyze` → 378 issues; `flutter analyze lib/features/map test/features/map` → 45 issues; `flutter test test/features/map` → 95 total / 4 failed.
**Open blockers**: production `/map` route creates an empty manual `MapWorkspaceProvider`; Map tests fail; Task 0510 changelog evidence missing.
**Path to 100**: wire `/map` to repository-backed workspace assets, fix graph toolbar overflow and no-results test drift, clear analyzer issues, add changelog proof, add production route test.
```
