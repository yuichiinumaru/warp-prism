# Review Report: Task 0513 — Map selection state and inspector integration — 2026-06-19

## Review Lineage

- **Current task**: Task 0513 (`0513-warp-prism-map-selection-and-inspector`); live path resolved by filesystem search at `docs/tasks/03-review/0513-warp-prism-map-selection-and-inspector.md` before routing.
- **Previous reports read**:
  - `docs/reports/build-gate-review/0513-review.md` — claimed `100/100`, now invalidated by live analyzer output and failing `flutter test test/features/map` gate.
- **Related reports considered**:
  - `docs/reports/build-gate-review/0511-review.md` — catalog selection origin.
  - `docs/reports/build-gate-review/0512-review.md` — graph node selection origin.
  - `docs/reports/build-gate-review/0514-review.md` — no-selection state coverage.
- **Review mode**: re-review / independent parent-reviewer gate.

## Score And Verdict

- **Score**: `84/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Lane recommendation**: `return-to-doing`

## Axiom Compliance

| # | Axiom | Status | Evidence |
| --- | --- | --- | --- |
| 1 | Analyzer Integrity | **FAIL** | `flutter analyze lib/features/map test/features/map` reports **45 issues**; inspector/selection files participate via unused imports and const/style warnings in nearby Map files. |
| 2 | Lifecycle Safety | **PASS** | `MapSelectionController` and `MapInspectorPanel` create **0** controllers/subscriptions/timers/listeners; **0** disposals required. The owning `MapWorkspaceProvider` stream controller is closed at `map_workspace_provider.dart:138-140`. |
| 3 | Dependency Direction | **PASS** | Selection/inspector consume feature state and normalized `WorkspaceAsset` only; no data parser or presentation-to-data-cycle violation found. |
| 4 | UI Accessibility | **PARTIAL** | No-selection copy is explicit at `map_inspector_panel.dart:87-94`; close control is delegated to `DSDetailInspector`. Selection origins include catalog/graph controls, and graph mode chips remain GestureDetector-based without keyboard proof. |
| 5 | Proof Reality | **FAIL** | Task marks analyzer/test exit conditions checked at `docs/tasks/03-review/0513-warp-prism-map-selection-and-inspector.md:55-57`, but live `flutter test test/features/map` is **95 total / 4 failed** and analyzer fails. |
| 6 | Release Security | **PASS** | No secrets, endpoints, signing changes, release logging, or write behavior in reviewed selection/inspector files. |

## Delta Summary

### Resolved Since Previous Review

- `RESOLVED`: Shared selection controller exists at `apps/observatory/lib/features/map/map_selection_controller.dart:24-56`.
- `RESOLVED`: Catalog and graph tap handlers converge on `_selectionController.selectAsset` at `apps/observatory/lib/features/map/map_workspace_page.dart:109-115`.
- `RESOLVED`: Inspector renders selected asset sections through `MapInspectorPanel` at `apps/observatory/lib/features/map/widgets/map_inspector_panel.dart:40-57`.
- `RESOLVED`: Changelog evidence exists for Task 0513 at `docs/changelog/20260607-220705-0000-2026-06-07-task-0513-map-selection-and-inspector-repair-bot.md`.

### Persistent Findings

- `PERSISTENT`: The prior report's claim that `flutter analyze` and `flutter test test/features/map/` pass is false against live evidence.

### Regressions

- `REGRESSION`: Previous 100/100 score cannot stand now that Flutter gates are executable and fail.

### New Findings

- `NEW`: Selection/inspector runtime only has meaningful assets when tests inject `catalogAssets`; production `/map` still starts empty, so the inspector's selected asset path is unreachable with real data.
- `NEW`: Task 0513 depends on graph/catalog origins, and the shared Map suite fails from those origins; this blocks acceptance even though the standalone selection controller design is sound.

### Evidence Gaps / External Blockers

- `EVIDENCE_GAP`: No production-route test proves selecting a repository-loaded asset opens the inspector.
- `EXTERNAL_BLOCKER`: None. Flutter and Dart are installed.

## Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | REGRESSION | High | Open | Analyzer and Map feature test gates fail despite checked exit conditions. | 2026-06-19 | `flutter analyze lib/features/map test/features/map` → `45 issues found`; `flutter test test/features/map` → `95 total / 4 failed`; task says pass at `docs/tasks/03-review/0513-warp-prism-map-selection-and-inspector.md:55-57`. |
| F2 | NEW | High | Open | Production route does not load assets, so real catalog/graph selection cannot populate the inspector. | 2026-06-19 | `MapPageShell` builds `const MapWorkspacePage()` at `apps/observatory/lib/app/pages/map_page.dart:14-16`; provider initializes from null state at `map_workspace_page.dart:72`; selected asset resolution searches `state.catalogAssets` at `map_selection_controller.dart:63-71`. |
| F3 | EVIDENCE_GAP | Moderate | Open | No app-route/integration test proves catalog card or graph node selection opens inspector through the production route. | 2026-06-19 | Existing `map_selection_and_inspector_test.dart` uses synthetic `_testAssets` at lines `20-64`; route-level tests are absent from grep results. |
| F4 | NEW | Moderate | Open | Inspector relationships only inspect edges embedded on the selected asset, so incoming relationships from other assets are not globally derived. | 2026-06-19 | `map_selection_controller.dart:117-145` filters `asset.edges`, not all workspace edges from `catalogAssets`. |

## Exact Evidence

- Shared selection: `MapSelectionController.selectAsset` delegates to one provider at `apps/observatory/lib/features/map/map_selection_controller.dart:42-56`.
- Catalog origin: `_onAssetTap` at `apps/observatory/lib/features/map/map_workspace_page.dart:109-111`.
- Graph origin: `_onNodeTap` at `apps/observatory/lib/features/map/map_workspace_page.dart:113-115`.
- Inspector builder: `AssetDetailConsumer.detailBuilder` returns `MapInspectorPanel` at `apps/observatory/lib/features/map/map_workspace_page.dart:125-140`.
- Lifecycle exact count for Task 0513-owned selection/inspector files: **0** controllers/subscriptions/timers/listeners created; **0** disposals required.

## Runtime Wiring Proof

1. `/map` route: `apps/observatory/lib/app/router.dart:52-59` → `MapPageShell`.
2. `MapPageShell`: `apps/observatory/lib/app/pages/map_page.dart:14-16` → `MapWorkspacePage`.
3. `MapWorkspacePage.initState`: creates `MapWorkspaceProvider` and `MapSelectionController` at `map_workspace_page.dart:72-74`.
4. Catalog path: `MapCatalogPanel.onAssetTap` is passed `_onAssetTap` at `map_workspace_page.dart:270`, which calls `_selectionController.selectAsset` at `:109-111`.
5. Graph path: `MapGraphPanel.onNodeTap` is passed `_onNodeTap` at `map_workspace_page.dart:312`, which calls `_selectionController.selectAsset` at `:113-115`.
6. Inspector path: `AssetDetailConsumer` receives `selectedAssetId` and builds `MapInspectorPanel` at `map_workspace_page.dart:125-140`.
7. Missing production proof: the selected asset lookup requires `catalogAssets` (`map_selection_controller.dart:63-71`), but production route passes none.

## Commands

- `flutter --version` — Flutter `3.44.1`, Dart `3.12.1` installed.
- `HOME="$PWD/../../tmp/home" PUB_CACHE="$PWD/../../tmp/pub-cache" flutter analyze` — failed, `378 issues found`.
- `HOME="$PWD/../../tmp/home" PUB_CACHE="$PWD/../../tmp/pub-cache" flutter analyze lib/features/map test/features/map` — failed, `45 issues found`.
- `HOME="$PWD/../../tmp/home" PUB_CACHE="$PWD/../../tmp/pub-cache" flutter test test/features/map` — failed, `95 total / 4 failed`.

## Stale-Evidence Notes

- Previous report's SDK blocker is stale.
- Task 0513's checked analyzer/test exit conditions are stale false status because live gates fail.
- Task 0513 has changelog evidence; unlike Tasks 0510-0512, changelog is not a blocker here.

## Path To 100

1. Make `/map` load repository-backed assets so catalog and graph selections can resolve real `WorkspaceAsset`s in `MapSelectionController.selectedAsset`.
2. Add a route-level widget/integration test: navigate to `/map`, wait for loaded assets, select a catalog card, verify `MapInspectorPanel` shows identity/governance/relationships, then clear selection.
3. Derive incoming relationship context from the full workspace edge set, not only `selectedAsset.edges`, or document that only outgoing/embedded edges are in scope.
4. Fix shared Map suite failures from Tasks 0511/0512 and clear all Map analyzer issues.

## Task Ledger Patch Suggestion

```markdown
### 2026-06-19 — reviewers independent re-review
**Score**: 84/100 — REJECTED_TO_DOING
**Verdict**: Return to `02-doing` for production data wiring, route-level selection proof, analyzer/test gate repair, and fuller relationship context.
**Report**: `docs/reports/review-wave-2026-06-19/0513-map-selection-inspector-rereview.md`
**Commands**: `flutter analyze` → 378 issues; `flutter analyze lib/features/map test/features/map` → 45 issues; `flutter test test/features/map` → 95 total / 4 failed.
**Open blockers**: inspector selection depends on empty production `catalogAssets`; no route-level proof; shared Map tests fail.
**Path to 100**: repository-fed Map state, production selection-to-inspector test, global incoming/outgoing relationship derivation, analyzer clean, Map tests pass.
```
