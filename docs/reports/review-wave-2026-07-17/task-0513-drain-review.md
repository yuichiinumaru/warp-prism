# Drain Review: Task 0513 — Map Selection And Inspector — 2026-07-17

## Review Lineage

- Prior independent: `docs/reports/review-wave-2026-07-09/task-0513-map-selection-inspector-independent-rereview.md` — **97/100**
- **Review mode**: independent drain re-review

## Score And Verdict

- **Prior score**: `97/100`
- **New score**: `94/100`
- **Verdict**: `ACCEPTED_PATH_TO_100`
- **Lane**: `docs/tasks/04-completed/`

## Delta Summary

### Resolved / Reconfirmed

- Single selection channel: `MapSelectionController` → `selectAsset` / `deselectAsset` / `selectedAssetId`.
- Catalog `_onAssetTap` and graph `_onNodeTap` converge.
- Selection suite **20/20**; map suite **105/105**; analyze clean.
- Production detail evolved to `AssetDetailConsumer` + `AssetDetailView` (Task 0905) — still PrismDetailInspector under kind variants.

### Persistent Findings

- None blocking exits.

### New Findings

- **NEW / Moderate (contract drift)**: Production Map page **no longer mounts** `MapInspectorPanel` (`map_workspace_page.dart:179` comment: “no surface-local MapInspectorPanel”). Tests still primarily prove `MapInspectorPanel` widget group; live path is universal detail. Dual inspector surface creates maintenance drift risk (sections in controller vs descriptor pipeline).
- **NEW / Low**: No page-level widget test that taps catalog card then graph node and asserts same detail title via `AssetDetailConsumer` path.

### Regressions

- None; selection controller still correct.

## Findings

| ID | Class | Severity | Status | Summary |
| --- | --- | --- | --- | --- |
| F1 | NEW | Moderate | Open | Dual inspector path: MapInspectorPanel (tests) vs AssetDetailView (prod) |
| F2 | NEW | Low | Open | Missing dual-origin page-level selection→detail widget proof |

## Exit Conditions

| Condition | Met? |
| --- | --- |
| Single selection controller | YES |
| Catalog + graph same selection | YES |
| Inspector with useful sections (via AssetDetailView/Prism*) | YES (evolved) |
| Sync + clear tests | YES 20/20 |
| analyze / tests / changelog | YES |

## Path To 100

1. Either retire `MapInspectorPanel` behind a deprecated alias and retarget tests to `AssetDetailView`/`descriptorFromWorkspaceAsset`, **or** document MapInspectorPanel as unit adapter only with one production smoke via AssetDetailConsumer.
2. Add one `MapWorkspacePage` dual-origin selection→detail title assertion.

## Lane Action

- Move → `docs/tasks/04-completed/`.
