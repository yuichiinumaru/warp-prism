# Observatory Failure Baseline Inventory

> **Date**: 2026-08-24 (path-to-100 evidence refresh after independent review return)
> **Source**: Scoped and full-package `flutter test apps/observatory --no-pub`
> + JSON result extraction + `flutter analyze apps/observatory --no-pub`
> + suite universe listing (`find … *_test.dart` = **45** suites)
> **Classification**: Inventory only — no production or test code modified under Task 1401
> **Task origin**: Task 1401, EPIC-14 stabilization wave
> **Predecessor**: `docs/reports/warp-prism-failure-baseline-inventory.md` (Task 1201)
> **Supersedes as current**:
> - 2026-06-09 inventory (653 / 589 / 64 runtime framing)
> - mid-wave 2026-07-09 inventory (12 non-success / 1042 analyzer)
> - fixer re-run 2026-07-09 inventory (1 residual suite / 2 history selection-sync errors / 816 green / 40 suites / 164 INFO)
> - 2026-07-18 inventory (claimed 44 green / 0 non-success, omitted widget_test.dart)

---

## 0. Honest status (read first)

Live Observatory diagnostics measured on 2026-08-24 show **44 passing suites (+810 tests)** and **1 residual non-success suite** (`apps/observatory/test/widget_test.dart` times out at `pumpAndSettle`).
Prior residual F01 (`history_story_modes_test` selection-sync) remains **remediated**.
Current residual F02 (`widget_test.dart` bootstrap smoke test timeout) is documented in §1.3.

| Metric | 2026-06-09 (hist.) | Mid-wave 2026-07-09 (hist.) | 2026-07-18 (hist.) | **Live 2026-08-23** |
|---|---|---|---|---|
| Inventory method | Full suite + `[E]` | 37 suites JSON | 44 suites list | Scoped app/data/features + isolated smoke + suite list (**45**) |
| Fully green suites | not recorded | claimed 25 | 44 | **44** |
| Non-success suites | claimed 64 runtime | claimed 12 | 0 | **1** (`widget_test.dart`) |
| Green test counter | claimed 589 | claimed 472 | +810 | **+810** (44 feature suites pass) |
| Non-success tests | claimed 64 | claimed 12 | 0 | **1** (`widget_test.dart` timeout) |
| Analyzer | not central | claimed 1042 err | 126 INFO | **127 INFO** (0 error / 0 warning), exit 0 |
| Dominant failure class | view / mapper | DS\* compile | none (claimed) | **view / test runtime timeout** |

> [!IMPORTANT]
> The 2026-07-18 claim of 0 non-success suites omitted `apps/observatory/test/widget_test.dart`.
> Suite universe is **45** suites (including `widget_test.dart`).
> Independent review on 2026-08-23 re-verified that `widget_test.dart` fails at line 12 with `pumpAndSettle timed out`.
> Path-to-100 refresh on 2026-08-24 re-ran the scoped corpus and analyzer: the current
> analyzer result is **127 INFO** (0 errors / 0 warnings; exit 0); the prior 124-INFO
> result remains historical evidence for 2026-08-23.

---

## 1. Live suite inventory (2026-08-24)

### 1.1 Outcome summary

| Outcome | Count |
|---|---:|
| Total `*_test.dart` suites | **45** |
| Fully green suites | **44** |
| Non-success suites | **1** (`widget_test.dart`) |
| Passing tests across 44 green suites | **+810** |
| Non-success test cases | **1** (`Observatory app bootstrap smoke test`) |
| Package result | **1 suite non-success (bootstrap smoke timeout)** |

### 1.2 Suite universe (45 total / 44 green / 1 fail)

Paths relative to `apps/observatory/test/`:

```text
app/app_bootstrap_test.dart
app/app_shell_smoke_test.dart
app/asset_detail_route_test.dart
app/deep_link_fallback_test.dart
app/production_router_test.dart
app/shell_responsive_layout_test.dart
data/history/history_repository_test.dart
data/models/workspace_graph_models_test.dart
data/parsers/workspace_markdown_parser_test.dart
data/parsers/workspace_task_projection_parser_test.dart
data/providers/workspace_providers_test.dart
data/repositories/mock_workspace_repository_test.dart
data/services/workspace_diagnostics_service_test.dart
data/services/workspace_graph_builder_test.dart
data/sources/preset_local_workspace_source_test.dart
features/asset_detail/asset_detail_descriptor_test.dart
features/asset_detail/extended_detail_variants_test.dart
features/asset_detail/responsive_detail_integration_test.dart
features/asset_detail/skill_task_detail_widgets_test.dart
features/governance/governance_analytics_panels_test.dart
features/governance/governance_boundaries_overview_test.dart
features/governance/governance_drilldown_storytelling_test.dart
features/governance/governance_issue_panels_test.dart
features/governance/governance_page_shell_test.dart
features/history/history_page_test.dart
features/history/history_story_modes_test.dart
features/map/map_catalog_panel_test.dart
features/map/map_graph_builder_edges_test.dart
features/map/map_graph_panel_test.dart
features/map/map_graph_projection_test.dart
features/map/map_selection_and_inspector_test.dart
features/map/map_surface_states_test.dart
features/map/map_workspace_page_test.dart
features/operate/operate_board_surface_test.dart
features/operate/operate_path_wins_lane_test.dart
features/operate/operate_storytelling_test.dart
features/operate/operate_task_detail_inspector_test.dart
features/overview/overview_page_test.dart
features/overview/overview_provider_path_test.dart
features/overview/overview_provider_test.dart
features/overview/overview_shell_test.dart
features/shell/shell_state_handler_test.dart
features/workspace_snapshot/workspace_snapshot_enhanced_test.dart
features/workspace_snapshot/workspace_snapshot_page_test.dart
widget_test.dart                                      # RESIDUAL (1 fail: pumpAndSettle timeout)
```

### 1.3 Non-success suites (1 / 45)

| # | Suite | Kind | Status (2026-08-24) | Chain position | Taxonomy | Error signature |
|---|---|---|---|---|---|---|
| F02 | `widget_test.dart` | runtime | **FAIL** (1 test error) | View / Test | Runtime Assertion / Timeout | `pumpAndSettle timed out at widget_test.dart:12` |

Signature details:

```text
Observatory app bootstrap smoke test
pumpAndSettle timed out at apps/observatory/test/widget_test.dart:12
```

### 1.4 Prior residual F01 — remediated (historical)

| # | Suite | Kind | Prior status (2026-07-09) | Live 2026-08-24 | Chain position (historical) | Taxonomy (historical) |
|---|---|---|---|---|---|---|
| F01 | `features/history/history_story_modes_test.dart` | runtime | 30 pass / 2 error | **+31 All tests passed** | View / Test stale (was) | Widget assertion / selection sync (was) |

### 1.5 Live command anchors

```text
find apps/observatory/test -name '*_test.dart' | wc -l
→ 45

flutter test apps/observatory/test/app/ apps/observatory/test/data/ apps/observatory/test/features/ --concurrency=4 --no-pub
→ +810: All tests passed!

flutter test apps/observatory/test/widget_test.dart --no-pub
→ Observatory app bootstrap smoke test [E]: pumpAndSettle timed out at widget_test.dart:12

flutter analyze apps/observatory --no-pub
→ 127 issues found. (0 error / 0 warning / 127 info; exit 0)
```

Saved logs (this pass): `tmp/1401-analyze.out`, `tmp/1401-full-suite.out`,
`tmp/1401-scoped.out`, `tmp/1401-widget.out`, `tmp/1401-suite-list.txt`.
These workspace-local logs were refreshed on 2026-08-24; the full-package log
also records the documented F02 timeout (and a shutdown error from the optional
visual-capture integration target), so the scoped run and isolated smoke log are
the authoritative gates for this inventory.

---

## 2. Analyzer baseline (package-level)

Command:

```bash
flutter analyze apps/observatory --no-pub
```

Live result (2026-08-24 path-to-100 re-run):

```text
127 issues found. (ran in 1.2s)
```

| Severity | Count |
|---|---:|
| error | **0** |
| warning | **0** |
| info | **127** |
| **total** | **127** |
| process exit | **0** |

### 2.1 What the infos are (class, not flood)

Dominated by style infos such as `prefer_const_constructors`,
`prefer_const_literals_to_create_immutables`, `unnecessary_import`,
`dangling_library_doc_comments`, and similar. **No undefined DS\* / Prism\***
compile errors in this baseline.

### 2.2 DS\* vs Prism\* on Observatory lib (currency check)

Mid-wave inventory claimed dominant root cause = hidden `DS*` after Prism public
API migration. Live package has **0 analyzer errors**. The DS\* compile
cluster is **historical only**.

---

## 3. Root-cause taxonomy (current)

| Class | Live volume | Notes |
|---|---|---|
| Compile / load | **0 suites** | Mid-wave DS\* flood cleared |
| Runtime widget assertion | **1 suite** | F02 `widget_test.dart` pumpAndSettle timeout |
| Corpus / parser | **0 failing suites** | Parser suites green |
| Projection / mapper | **0 failing suites** | Not a live blocker |
| Analyzer error residual | **0** | Info-only package analyze (127 INFO) |

### 3.1 Top-down vs bottom-up

- **Top-down (corpus → parser)**: not a live failure mode (no failing suites).
- **Bottom-up (view / test expectation)**: F02 (`widget_test.dart`) fails at bootstrap pumpAndSettle.

---

## 4. Historical baselines (do not treat as current)

### 4.1 2026-06-09 — claimed 653 / 589 / 64

Superseded. Kept only for lineage. Do not promote as live.

### 4.2 Mid-wave 2026-07-09 — claimed 12 non-success / 1042 analyzer

Superseded. DS\* compile-dominant inventory incorrectly treated as current after
Prism migration completed.

### 4.3 Fixer re-run 2026-07-09 — 40 suites / 39 green / 2 history errors / 816 / 164 INFO

Superseded as **current residual**. Valid as historical residual ledger for the
selection-sync defect that later cleared. Do not re-assert F01 as live.

### 4.4 2026-07-18 claim — 44 suites / 0 non-success / 126 INFO

Superseded. Omitted `apps/observatory/test/widget_test.dart` (which fails with pumpAndSettle timeout).

---

## 5. Files read (anti-hallucination evidence)

### 5.1 Test files executed

Every path under `apps/observatory/test/**/*_test.dart` (full set = **45**,
listed in §1.2).

### 5.2 Diagnostics / residual reconfirm

| Path | Why |
|---|---|
| `apps/observatory/test/widget_test.dart` | F02 residual (pumpAndSettle timeout) |
| `apps/observatory/test/features/history/history_story_modes_test.dart` | Prior F01 residual; reconfirmed green +31 |
| `docs/reports/review/independent-2026-08-23-task-1401.md` | Independent review report 2026-08-23 |

---

## 6. Deterministic extraction method (not `[E]` grep)

Preferred recipes:

```bash
# Scoped package test run (44 feature/app/data suites):
flutter test apps/observatory/test/app/ apps/observatory/test/data/ apps/observatory/test/features/ --concurrency=4 --no-pub

# Targeted smoke test failure verification:
flutter test apps/observatory/test/widget_test.dart --no-pub

# Package analyzer:
flutter analyze apps/observatory --no-pub
```

Count rules:

1. **Package green** iff full-suite ends with `All tests passed!` and zero
   non-success suite exits when using per-suite mode.
2. **Suite green** (JSON mode) iff process exit 0 **and** zero `failure` **and**
   zero `error` in `testDone`.
3. Do **not** use sole `[E]` line grep on expanded human output as proof.

---

## 7. Recommended follow-ups (out of Task 1401 inventory scope)

| ID | Action | Owner hint |
|---|---|---|
| H1 | Fix `widget_test.dart` pumpAndSettle timeout (add provider override or advance timer) | Task 1402 / builders |
| H2 | Keep corpus frontmatter scan in CI (`no_fm=0`) after Task 1403 | Corpus governance |
| H3 | Re-run this inventory before every promotion of Task 1401 | builders / reviewers |
| H4 | Optional: reduce 127 analyzer INFO style noise | polish lane (not package blocker) |

---

## 8. Completion snapshot (Task 1401)

| Check | Result |
|---|---|
| Inventory path | `docs/reports/observatory-failure-baseline.md` |
| Live suite count | **45** |
| Live green suites | **44** |
| Live non-success suites | **1** (`widget_test.dart`) |
| Live full-suite result | **44 suites pass (+810 tests) / 1 suite fails (bootstrap timeout)** |
| Live analyzer | **127 info / 0 error / 0 warning** (exit 0) |
| F01 residual | **Historical / remediated** |
| F02 residual | **`widget_test.dart` pumpAndSettle timeout at line 12** |
| Historical 64-runtime / 12-compile / 2-error tables | Labeled historical only |
| DS\* compile dominant cause | Obsolete |
| VCS | No git/jj operations performed |
