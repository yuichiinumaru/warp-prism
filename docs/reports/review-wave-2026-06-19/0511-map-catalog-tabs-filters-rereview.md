# Review Report: Task 0511 — Map catalog tabs, cards, and filter interactions — 2026-06-19

## Review Lineage

- **Current task**: Task 0511 (`0511-warp-prism-map-catalog-tabs-and-filters`); live path resolved by filesystem search at `docs/tasks/03-review/0511-warp-prism-map-catalog-tabs-and-filters.md` before routing.
- **Previous reports read**:
  - `docs/reports/build-gate-review/0511-review.md` — claimed `100/100`, now invalidated by live analyzer output and failing catalog/Map tests.
- **Related reports considered**:
  - `docs/reports/build-gate-review/0510-review.md` — route scaffold dependency.
  - `docs/reports/build-gate-review/0512-review.md` through `docs/reports/build-gate-review/0514-review.md` — downstream Map failures share the same `flutter test test/features/map` gate.
- **Review mode**: re-review / independent parent-reviewer gate.

## Score And Verdict

- **Score**: `80/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Lane recommendation**: `return-to-doing`

## Axiom Compliance

| # | Axiom | Status | Evidence |
| --- | --- | --- | --- |
| 1 | Analyzer Integrity | **FAIL** | `flutter analyze lib/features/map test/features/map` reports **45 issues**; package `flutter analyze` reports **378 issues**. Map catalog files have unused imports and `prefer_const_*` issues. |
| 2 | Lifecycle Safety | **PASS** | `MapCatalogPanel`, `MapAssetCardGrid`, and `MapNoResultsState` create **0** controllers/subscriptions/timers/listeners; **0** disposals required. |
| 3 | Dependency Direction | **PARTIAL** | Catalog consumes normalized `WorkspaceAsset` models and does not parse files, but live `/map` never receives repository-backed assets, so the implemented catalog is still test-injected in production. |
| 4 | UI Accessibility | **PARTIAL** | Catalog card interactivity is delegated to `DSAssetCard`; feature-local clear action is **1** raw `GestureDetector` at `map_catalog_panel.dart:130-139` with no feature-local Semantics/button/focus wrapper. |
| 5 | Proof Reality | **FAIL** | `flutter test test/features/map` is **95 total / 4 failed**. `map_catalog_panel_test.dart` has a direct failing assertion at line `429` expecting `Clear filters`. Task 0511 still reports SDK unavailable and changelog pending at `docs/tasks/03-review/0511-warp-prism-map-catalog-tabs-and-filters.md:125-127`. |
| 6 | Release Security | **PASS** | No secrets, endpoints, signing changes, release logging, or write behavior in reviewed catalog files. |

## Delta Summary

### Resolved Since Previous Review

- `RESOLVED`: Catalog panel exists and is wired into the Map page for Agents/Skills/Workflows at `apps/observatory/lib/features/map/map_workspace_page.dart:154-156,207-271`.
- `RESOLVED`: Filtering is centralized in `MapWorkspaceState.filteredAssets` at `apps/observatory/lib/features/map/map_workspace_state.dart:158-182`, not duplicated by tab.

### Persistent Findings

- `PERSISTENT`: Task 0511 changelog evidence remains pending: `docs/tasks/03-review/0511-warp-prism-map-catalog-tabs-and-filters.md:125-127`; no Task 0511 changelog file was found among `docs/changelog/*051*.md`.

### Regressions

- `REGRESSION`: Previous 100/100 report is unreproducible because Flutter SDK is available and the live gates fail.

### New Findings

- `NEW`: Catalog test proof is broken: `MapNoResultsState widget shows message for query with no results` fails because the expected `Clear filters` text is absent.
- `NEW`: Catalog action accessibility is incomplete for the feature-local `Clear all` affordance.
- `NEW`: Production catalog data flow is missing; `/map` instantiates an empty `MapWorkspaceState` unless tests inject assets.

### Evidence Gaps / External Blockers

- `EVIDENCE_GAP`: No passing catalog/Map feature test run exists.
- `EXTERNAL_BLOCKER`: None. Flutter and Dart are installed.

## Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | REGRESSION | High | Open | Analyzer is not clean for Map/catalog scope. | 2026-06-19 | `flutter analyze lib/features/map test/features/map` → `45 issues found`; catalog-specific examples: `map_catalog_panel.dart:15`, `map_asset_card_grid.dart:11`, `map_no_results_state.dart:9`. |
| F2 | NEW | High | Open | Catalog tests fail; no-results proof is not reproducible. | 2026-06-19 | `flutter test test/features/map` → `+95 -4`; `test/features/map/map_catalog_panel_test.dart:429` expected exactly one `Clear filters`, found 0. |
| F3 | NEW | High | Open | Catalog is not loaded from the repository/view-model data path in production. | 2026-06-19 | `/map` route creates `const MapWorkspacePage()` via `apps/observatory/lib/app/pages/map_page.dart:14-16`; provider defaults to empty state at `map_workspace_provider.dart:36-37`; no `loadAssets` production call in `map_workspace_page.dart`. |
| F4 | NEW | Moderate | Open | Feature-local catalog clear control lacks Semantics/button/focus treatment. | 2026-06-19 | `apps/observatory/lib/features/map/widgets/map_catalog_panel.dart:129-139`. |
| F5 | PERSISTENT | Moderate | Open | Changelog evidence is missing. | 2026-06-13 / 2026-06-19 | `docs/tasks/03-review/0511-warp-prism-map-catalog-tabs-and-filters.md:125-127`; previous report `docs/reports/build-gate-review/0511-review.md:63-65`. |

## Exact Evidence

- Catalog panel source: `apps/observatory/lib/features/map/widgets/map_catalog_panel.dart:77-163` renders search, chips, result count, clear action, and cards/no-results state.
- Filtering source of truth: `apps/observatory/lib/features/map/map_workspace_state.dart:139-182` derives `assetsForTab` and `filteredAssets` from one `catalogAssets` list.
- Lifecycle exact count for Task 0511-owned widgets: **0** controllers/subscriptions/timers/listeners created; **0** disposals required.
- Feature-local interactivity count in catalog widgets: **1** raw `GestureDetector` source site (`map_catalog_panel.dart:130`) plus **N** `DSAssetCard` callbacks where `N = filteredAssets.length` at runtime (`map_asset_card_grid.dart:46-57`).

## Runtime Wiring Proof

1. `apps/observatory/lib/app/router.dart:52-59` registers `/map`.
2. `apps/observatory/lib/app/pages/map_page.dart:14-16` builds `MapWorkspacePage`.
3. `apps/observatory/lib/features/map/map_workspace_page.dart:154-156` routes Agents/Skills/Workflows tabs to `_buildCatalogTab`.
4. `_buildCatalogTab` builds `MapCatalogPanel` at `map_workspace_page.dart:233-246` for empty corpus and `:260-271` for loaded data.
5. The production route passes no repository-backed assets, and `MapWorkspacePage.initState` creates a provider from null `initialState` at `map_workspace_page.dart:72`; therefore runtime wiring reaches the catalog UI shell but not a live normalized catalog dataset.

## Commands

- `flutter --version` — Flutter `3.44.1`, Dart `3.12.1` installed.
- `HOME="$PWD/../../tmp/home" PUB_CACHE="$PWD/../../tmp/pub-cache" flutter analyze` — failed, `378 issues found`.
- `HOME="$PWD/../../tmp/home" PUB_CACHE="$PWD/../../tmp/pub-cache" flutter analyze lib/features/map test/features/map` — failed, `45 issues found`.
- `HOME="$PWD/../../tmp/home" PUB_CACHE="$PWD/../../tmp/pub-cache" flutter test test/features/map` — failed, `95 total / 4 failed`.

## Stale-Evidence Notes

- Previous report `docs/reports/build-gate-review/0511-review.md` claimed SDK absence; SDK is present.
- Previous report's `100/100` score and `20+ test cases` claim are not enough: one of the catalog tests fails live.
- Historical lane path drift is not penalized; false current proof is penalized.

## Path To 100

1. Wire the Map catalog to repository-backed normalized assets via the app provider layer instead of relying on test-injected `initialState`.
2. Fix `MapNoResultsState` / `map_catalog_panel_test.dart` contract so query-only no-results either intentionally shows a `Clear filters` action or the test asserts the intended query-clear affordance.
3. Replace the catalog `GestureDetector` clear action with a semantic, focusable control (`TextButton`, `InkWell` with Semantics/FocusableActionDetector, or DS action molecule) meeting a 48x48 dp touch/focus target.
4. Clear all Map/catalog analyzer issues.
5. Add Task 0511 changelog proof under `docs/changelog/` or an approved exception.

## Task Ledger Patch Suggestion

```markdown
### 2026-06-19 — reviewers independent re-review
**Score**: 80/100 — REJECTED_TO_DOING
**Verdict**: Return to `02-doing` for catalog proof repair, production data wiring, accessibility, analyzer cleanup, and changelog evidence.
**Report**: `docs/reports/review-wave-2026-06-19/0511-map-catalog-tabs-filters-rereview.md`
**Commands**: `flutter analyze` → 378 issues; `flutter analyze lib/features/map test/features/map` → 45 issues; `flutter test test/features/map` → 95 total / 4 failed.
**Open blockers**: failing catalog no-results test, route not repository-fed, raw clear `GestureDetector`, missing Task 0511 changelog.
**Path to 100**: repository-fed catalog state, fixed no-results proof, semantic/focusable clear action, analyzer clean, changelog proof.
```
