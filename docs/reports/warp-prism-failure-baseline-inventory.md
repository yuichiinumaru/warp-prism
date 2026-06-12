# Warp Prism Failure Baseline Inventory

> **Date**: 2026-06-11
> **Task**: 1201
> **Scope**: Warp Prism package/app test baseline
> **Source commands**: `flutter test packages/warp_prism_ui/`, `flutter test apps/observatory/`, `flutter test apps/catalog/`, `flutter test apps/cybercore/`
> **Status**: Inventory only — no test or implementation files modified

---

## 1. Executive Summary

Current package/app test output contains **1,517 passing tests and 12 failing tests** across the four required commands. All 12 failures are in `apps/observatory/`. `packages/warp_prism_ui/`, `apps/catalog/`, and `apps/cybercore/` currently have zero failures.

| Package/App | Command | Exit | Pass | Fail | Total | Result |
|---|---:|---:|---:|---:|---:|---|
| `warp_prism_ui` | `flutter test packages/warp_prism_ui/` | 0 | 854 | 0 | 854 | PASS |
| `observatory` | `flutter test apps/observatory/` | 1 | 641 | 12 | 653 | FAIL |
| `catalog` | `flutter test apps/catalog/` | 0 | 10 | 0 | 10 | PASS |
| `cybercore` | `flutter test apps/cybercore/` | 0 | 12 | 0 | 12 | PASS |
| **TOTAL** | 4 required commands | — | **1,517** | **12** | **1,529** | **FAIL** |

### Current command output captured

```text
flutter test packages/warp_prism_ui/
→ EXIT:0
→ 00:46 +854: All tests passed!

flutter test apps/observatory/
→ EXIT:1
→ 00:40 +641 -12: Some tests failed.

flutter test apps/catalog/
→ EXIT:0
→ 00:48 +10: All tests passed!

flutter test apps/cybercore/
→ EXIT:0
→ 00:03 +12: All tests passed!
```

Raw command logs were captured in:

- `tmp/1201-test-output/ui-test.log`
- `tmp/1201-test-output/observatory-test.log`
- `tmp/1201-test-output/catalog-test.log`
- `tmp/1201-test-output/cybercore-test.log`

### Reviewer round 2 confirmation

A 2026-06-11 gt-build-review re-run observed the same failure baseline by count and identity: `packages/warp_prism_ui/` passed all 854 tests; `apps/observatory/` failed the same 12 tests; `apps/catalog/` passed all 10 tests on sequential rerun; and `apps/cybercore/` passed all 12 tests. A parallel `apps/catalog/` invocation crashed in Flutter tooling before test execution with a missing native-assets manifest, then the sequential rerun passed; that transient tool crash did not add a package test failure.

---

## 2. Taxonomy Mapping

The promotion taxonomy is taken from `.agents/rules/promotion-state-model.md`. This inventory does **not** use `pre-existing` as an unclassified catch-all. Each Observatory failure row below separates **Task relationship** from **Primary taxonomy class**: all failures are pre-existing/unrelated to Task 1201 because this task modified no implementation or test files, and each failure also has one concrete taxonomy class from the promotion model.

| Taxonomy class | Meaning in this inventory | Current observations |
|---|---|---|
| `broken compile` | File does not compile | **0 observed**. Current failures are runtime/widget-test failures. |
| `contract drift` | API signature/export/rendering contract mismatch | Observed in map catalog/search and inspector surface expectations. |
| `stale test` | Test expects old behavior while current product behavior has moved on | Observed in app shell router context, map text expectations, and duplicate text exact-count tests. |
| `real regression` | Task broke something that was working | **0 observed for Task 1201**. No implementation was changed. |
| `async/flaky` | Timer, overlay, lifecycle, or tap fragility | Observed in the Operate close-button callback failure. |
| `semantics drift` | Labels, roles, or accessibility expectations stale | **0 observed** in current failures. |
| `missing fixture` | Test data absent or malformed | **0 observed** in current failures. |
| `pre-existing (unrelated)` | Failure existed before or outside the task scope and Task 1201 did not touch the area | **Task relationship for all 12 current failures**; not used as the primary taxonomy class. |

---

## 3. Package/App Failure Inventory

### 3.1 `warp_prism_ui` — zero failures

```text
flutter test packages/warp_prism_ui/
→ EXIT:0
→ 00:46 +854: All tests passed!
```

| File | Test name | Taxonomy class | Chain position | Affected area | Evidence snippet |
|---|---|---|---|---|---|
| N/A | N/A | N/A | N/A | N/A | No failures observed. |

### 3.2 `observatory` — 12 failures

| # | File | Test name | Task relationship | Primary taxonomy class | Chain position | Affected area | Evidence snippet |
|---:|---|---|---|---|---|---|---|
| 1 | `apps/observatory/test/app/app_shell_smoke_test.dart` | `App shell smoke test app boots and renders the shell with default route` | `pre-existing (unrelated)` | `stale test` | `view` | App shell/router smoke test | `No GoRouter found in context`; failed assertion: `line 521 pos 12: 'inherited != null'`; stack points to `app_shell_smoke_test.dart:20:16`. |
| 2 | `apps/observatory/test/app/app_shell_smoke_test.dart` | `App shell smoke test default route lands on Overview` | `pre-existing (unrelated)` | `stale test` | `view` | App shell/router smoke test | `No GoRouter found in context`; failed assertion: `line 521 pos 12: 'inherited != null'`; stack points to `app_shell_smoke_test.dart:36:16`. |
| 3 | `apps/observatory/test/features/map/map_surface_states_test.dart` | `Map surface - happy path renders graph tab with projection when edges exist` | `pre-existing (unrelated)` | `stale test` | `view` | Map graph projection label | Expected at least one matching candidate; actual `Found 0 widgets with text "Containment"`. |
| 4 | `apps/observatory/test/features/map/map_workspace_page_test.dart` | `MapWorkspacePage widget shows catalog panel on first tab (Agents)` | `pre-existing (unrelated)` | `contract drift` | `view` | Map catalog/search surface | Expected at least one matching candidate; actual `Found 0 widgets with type "DSSearchBar"`. |
| 5 | `apps/observatory/test/features/map/map_catalog_panel_test.dart` | `MapNoResultsState widget shows message for query with no results` | `pre-existing (unrelated)` | `contract drift` | `view` | Map no-results action | Expected exactly one matching candidate; actual `Found 0 widgets with text "Clear filters"`. |
| 6 | `apps/observatory/test/features/map/map_workspace_page_test.dart` | `MapWorkspacePage widget switching tabs shows correct content` | `pre-existing (unrelated)` | `contract drift` | `view` | Map catalog/search surface | Expected at least one matching candidate; actual `Found 0 widgets with type "DSSearchBar"`. |
| 7 | `apps/observatory/test/features/map/map_selection_and_inspector_test.dart` | `MapInspectorPanel widget switches from selected to no-selection when cleared` | `pre-existing (unrelated)` | `contract drift` | `view` | Map inspector no-selection state | Expected at least one matching candidate; actual `Found 0 widgets with text "No asset selected"`. |
| 8 | `apps/observatory/test/features/map/map_workspace_page_test.dart` | `MapWorkspacePage widget renders with initial state specifying a subview` | `pre-existing (unrelated)` | `contract drift` | `view` | Map graph tab label | Expected at least one matching candidate; actual `Found 0 widgets with text "Asset Graph"`. |
| 9 | `apps/observatory/test/features/map/map_surface_states_test.dart` | `Map surface - error state error state shows retry button` | `pre-existing (unrelated)` | `contract drift` | `view` | Map error action | Expected at least one matching candidate; actual `Found 0 widgets with text "Retry"`. |
| 10 | `apps/observatory/test/features/operate/operate_task_detail_inspector_test.dart` | `OperateTaskDetailPanel renders exit conditions with checked state` | `pre-existing (unrelated)` | `stale test` | `view` | Operate task detail text contract | Expected exactly one matching candidate; actual `Found 2 widgets with text "Exit Conditions"`; matcher says `is too many`. |
| 11 | `apps/observatory/test/features/operate/operate_task_detail_inspector_test.dart` | `OperateTaskDetailPanel close button triggers onClose callback` | `pre-existing (unrelated)` | `async/flaky` | `view` | Operate close-button callback | Test warning: `tap()` offset would not hit the specified widget; final matcher: `Expected: true`; actual `<false>`. |
| 12 | `apps/observatory/test/features/governance/governance_analytics_panels_test.dart` | `ReviewPressurePanel renders lane breakdown chips` | `pre-existing (unrelated)` | `stale test` | `view` | Governance lane chip count | Expected exactly one matching candidate; actual `Found 2 widgets with text "04-completed"`; matcher says `is too many`. |

### 3.3 `catalog` — zero failures

```text
flutter test apps/catalog/
→ EXIT:0
→ 00:48 +10: All tests passed!
```

| File | Test name | Taxonomy class | Chain position | Affected area | Evidence snippet |
|---|---|---|---|---|---|
| N/A | N/A | N/A | N/A | N/A | No failures observed. |

### 3.4 `cybercore` — zero failures

```text
flutter test apps/cybercore/
→ EXIT:0
→ 00:03 +12: All tests passed!
```

| File | Test name | Taxonomy class | Chain position | Affected area | Evidence snippet |
|---|---|---|---|---|---|
| N/A | N/A | N/A | N/A | N/A | No failures observed. |

---

## 4. Failure Clusters and Chain Position Notes

### App shell/router smoke

- **Failures**: 2
- **Files**: `apps/observatory/test/app/app_shell_smoke_test.dart`
- **Chain position**: `view`
- **Pattern**: Tests call `GoRouter.of(context)` using a context obtained from `find.byType(MaterialApp)`. The current output reports `No GoRouter found in context`, so the smoke test is stale relative to the current `MaterialApp.router` setup or needs a router-aware test context.

### Map surface and catalog

- **Failures**: 7
- **Files**:
  - `apps/observatory/test/features/map/map_surface_states_test.dart`
  - `apps/observatory/test/features/map/map_workspace_page_test.dart`
  - `apps/observatory/test/features/map/map_catalog_panel_test.dart`
  - `apps/observatory/test/features/map/map_selection_and_inspector_test.dart`
- **Chain position**: `view`
- **Pattern**: Current widget output does not match test expectations for graph labels, search bar type, no-results action text, graph tab label, retry action text, or inspector no-selection text. These are classified as contract drift or stale test expectations, all pre-existing/unrelated to Task 1201.

### Operate task detail inspector

- **Failures**: 2
- **File**: `apps/observatory/test/features/operate/operate_task_detail_inspector_test.dart`
- **Chain position**: `view`
- **Pattern**: One failure is a duplicate text exact-count mismatch for `Exit Conditions`; the other is a close-button callback failure with a tap hit-test warning. The callback failure has an `async/flaky` component, but it remains pre-existing/unrelated to this inventory task.

### Governance analytics

- **Failures**: 1
- **File**: `apps/observatory/test/features/governance/governance_analytics_panels_test.dart`
- **Chain position**: `view`
- **Pattern**: The lane chip count expectation finds two `04-completed` widgets and fails with `is too many`. This is a stale test expectation or view duplication issue, pre-existing/unrelated to Task 1201.

---

## 5. Promotion-State Implications

| Area | Failure count | Promotion implication |
|---|---:|---|
| `warp_prism_ui` | 0 | No current UI package failures observed by this inventory run. |
| `observatory` | 12 | Current consumer/app gate is red. Failures are documented and classified as pre-existing/unrelated to Task 1201. |
| `catalog` | 0 | No current catalog app failures observed. |
| `cybercore` | 0 | No current cybercore app failures observed. |

Task 1201 is an inventory-only governance task. It does not fix these failures. The correct stabilization handoff is to use this inventory as the map for follow-up tasks rather than treating `pre-existing` as an unclassified bypass.

---

## 6. Verification and Regression Check

### Count verification

The observatory log was parsed for unique `[E]` failure entries. The extraction command found **12 unique failing tests**, matching the 12 rows in Section 3.2.

```text
Extracted unique failing tests from tmp/1201-test-output/observatory-test.log
→ 12
```

### Count reconciliation

| Source | Expected failures | Report failures | Match |
|---|---:|---:|---|
| `flutter test apps/observatory/` final line | 12 | 12 | YES |
| Unique `[E]` extraction from observatory log | 12 | 12 | YES |
| Other package/app commands | 0 | 0 | YES |

### Files created/modified

- Created: `docs/reports/warp-prism-failure-baseline-inventory.md`
- Created: `docs/changelog/20260611-000000-1201-warp-prism-failure-baseline-inventory-builders.md`
- Modified: `docs/tasks/02-doing/1201-warp-prism-test-failure-baseline-inventory.md`

No implementation files, tests, or product runtime behavior were changed.
