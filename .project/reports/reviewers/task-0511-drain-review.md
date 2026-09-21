# Drain Review: Task 0511 — Map Catalog Tabs And Filters — 2026-07-17

## Review Lineage

- **Current task**: Task 0511 (`warp-prism-map-catalog-tabs-and-filters`); was `docs/tasks/03-review/`
- **Previous reports (draft)**:
  - `docs/reports/review-wave-2026-07-09/task-0511-map-catalog-tabs-filters-independent-rereview.md` — **90/100**
  - `docs/reports/review-wave-2026-06-19/0511-map-catalog-tabs-filters-rereview.md` — 80/100
- **Review mode**: independent drain re-review
- **No git / no tasklist**

## Score And Verdict

- **Prior score**: `90/100`
- **New score**: `87/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Lane**: `docs/tasks/02-doing/`

## Delta Summary

### Resolved Since Prior Independent Review

- Catalog panel + card grid + no-results still correct; single collection filtering (`assetsForTab` + `filteredAssets`).
- Live map suite **105/105**; catalog analyze clean with map package.
- Changelog present: `docs/changelog/2026-07-09-task-0511-map-catalog-tabs-and-filters.md`.

### Persistent Findings

- **PERSISTENT / Moderate (a11y)**: Catalog “Clear all” remains raw `GestureDetector` without `Semantics(button: true)`, keyboard focus, or ≥48dp target (`map_catalog_panel.dart:122–131`). Prior 2026-06-19 / 2026-07-09 path-to-100 item **not remediated**.
- **PERSISTENT / Low**: When `assetsForTab` is empty but global `catalogAssets` is not, page falls through to `MapCatalogPanel` empty list instead of explicit empty-family state (`map_workspace_page.dart:254–281` — emptyCorpus only when *all* assets empty).

### New Findings

- **NEW / Low–Moderate**: Shared incomplete equality + full `syncState` replace (Task 0510 F3) can drop filter chips when catalog length changes mid-session; interactive filtering still works via provider stream for local toggles.
- **NEW / Low**: “Clear all” lacks `Tooltip` / accessible name regression test (a11y suite covers Operate Clear filters but not Map Clear all semantics).

### Regressions

- None in test suite.

## Findings

| ID | Class | Severity | Status | Summary |
| --- | --- | --- | --- | --- |
| F1 | PERSISTENT | Moderate | Open | Clear all GestureDetector a11y |
| F2 | PERSISTENT | Low | Open | Empty-family tab UX vs no-results |
| F3 | NEW | Low | Open | No Semantics regression test for Clear all |

## Exit Condition Verification

| Exit | Status | Live evidence |
| --- | --- | --- |
| Catalog Agents/Skills/Workflows | PASS | MapCatalogPanel |
| Search + chips deterministic | PASS | state + tests |
| Cards kind/canonicality/edges | PASS | MapAssetCardGrid |
| Happy + zero results tests | PASS | map_catalog_panel_test |
| analyze / test / changelog | PASS | green |

## Axiom Compliance

| Axiom | Status | Notes |
| --- | --- | --- |
| Analyzer Integrity | PASS | map scope clean |
| Lifecycle Safety | PASS | catalog widgets 0 controllers |
| Dependency Direction | PASS | WorkspaceAsset only |
| UI Accessibility | **FAIL (scoped)** | 1 raw Clear all control |
| Proof Reality | PASS | catalog + map suite |
| Release Security | PASS | |

## Commands Run

```text
cd apps/observatory
flutter test --concurrency=1 --no-pub test/features/map/
→ +105 All tests passed!
flutter analyze --no-pub lib/features/map/ test/features/map/
→ No issues found!
```

## Path To 100

1. Replace Clear all `GestureDetector` with `TextButton` / `InkWell` + `Semantics(button: true, label: 'Clear all filters')` (or Prism text button) meeting ≥48dp.
2. Add widget test asserting Clear all semantics / tappable label.
3. Optional: explicit empty-family panel when `assetsForTab.isEmpty && !hasFilters`.
4. Coordinate equality/`syncState` fix with Task 0510 so filters survive parent reinjection.

## Lane Action

- Move task file → `docs/tasks/02-doing/`.
