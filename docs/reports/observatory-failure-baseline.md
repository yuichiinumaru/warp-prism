# Observatory Failure Baseline Inventory

> **Date**: 2026-09-02 (current unit-test and analyzer evidence refresh)
> **Source**: Unit-test corpus `flutter test apps/observatory/test --no-pub`
> + scoped feature run + `flutter analyze apps/observatory --no-pub`
> + separate optional integration-harness attempt
> + suite universe listing (`apps/observatory/test/**/*_test.dart` = **45** suites)
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

Live Observatory diagnostics measured on 2026-09-02 show **45 passing unit-test suites (+811 tests)**, including `apps/observatory/test/widget_test.dart`.
Prior residual F01 (`history_story_modes_test` selection-sync) remains **remediated**.
The optional visual-capture integration harness remains a separate infrastructure/runtime concern and is documented in §1.3; it is not part of the 45-file unit-test corpus.

| Metric | 2026-06-09 (hist.) | Mid-wave 2026-07-09 (hist.) | 2026-07-18 (hist.) | **Live 2026-08-23** |
|---|---|---|---|---|
| Inventory method | Full suite + `[E]` | 37 suites JSON | 44 suites list | Unit-test corpus + scoped rerun + analyzer + separate integration attempt (**45** unit suites) |
| Fully green suites | not recorded | claimed 25 | 44 | **45** |
| Non-success suites | claimed 64 runtime | claimed 12 | 0 | **0** in unit-test corpus; optional integration harness timed out during shutdown |
| Green test counter | claimed 589 | claimed 472 | +810 | **+811** unit-test cases |
| Non-success tests | claimed 64 | claimed 12 | 0 | **0** unit-test cases |
| Analyzer | not central | claimed 1042 err | 126 INFO | **124 INFO** (0 error / 0 warning), exit 0 |
| Dominant failure class | view / mapper | DS\* compile | none (claimed) | **optional integration-harness shutdown/runtime** |

> [!IMPORTANT]
> The 2026-07-18 claim of 0 non-success suites omitted `apps/observatory/test/widget_test.dart`.
> The 2026-08-24 F02 timeout was subsequently rechecked on 2026-09-02: the isolated
> bootstrap smoke test passes, so F02 is historical/remediated rather than current.
> The unit-test suite universe is **45** suites and includes `widget_test.dart`.
> The optional visual-capture integration test is a separate harness under
> `apps/observatory/integration_test/`; its current attempt exceeded the bounded
> shutdown window with a `stream_channel` close/add error. That is not included in
> the unit-test baseline or green-test count.
> Current analyzer evidence is **124 INFO** (0 errors / 0 warnings; exit 0).

---

## 1. Live suite inventory (2026-09-02)

### 1.1 Outcome summary

| Outcome | Count |
|---|---:|
| Total unit-test `*_test.dart` suites | **45** |
| Fully green unit-test suites | **45** |
| Non-success unit-test suites | **0** |
| Passing unit-test cases | **+811** |
| Non-success unit-test cases | **0** |
| Unit-test package result | **All tests passed!** |
| Optional integration-harness result | **Bounded attempt timed out during stream shutdown; excluded from unit baseline** |

### 1.2 Suite universe (45 total / 45 green / 0 fail)

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
widget_test.dart                                      # PASS (bootstrap smoke test)
```

### 1.3 Non-success unit-test suites (0 / 45)

No unit-test suite currently has a non-success outcome. The formerly residual
`widget_test.dart` bootstrap smoke test passed on 2026-09-02.

### 1.4 Optional integration harness (separate from unit-test baseline)

| # | Suite | Kind | Status (2026-09-02) | Chain position | Taxonomy | Error signature |
|---|---|---|---|---|---|---|
| I01 | `integration_test/observatory_visual_capture_test.dart` | integration/runtime | **INCONCLUSIVE** (bounded attempt timed out) | Test harness / shutdown | Stream-channel shutdown | `Bad state: Cannot close sink while adding stream` |

The test reached the capture test and emitted passing progress through `+811`,
then did not terminate within the 75-second bounded attempt. Flutter's shutdown
reported `Cannot close sink while adding stream` / `Cannot add event while adding
stream`. Because this is an optional integration harness rather than one of the
45 files under `apps/observatory/test/`, it is reported separately and excluded
from the unit-test pass/fail totals. It should not be called a unit-test failure
or silently treated as package-green integration evidence.

### 1.5 Prior residual F01 — remediated (historical)

| # | Suite | Kind | Prior status (2026-07-09) | Live 2026-08-24 | Chain position (historical) | Taxonomy (historical) |
|---|---|---|---|---|---|---|
| F01 | `features/history/history_story_modes_test.dart` | runtime | 30 pass / 2 error | **+31 All tests passed** | View / Test stale (was) | Widget assertion / selection sync (was) |

### 1.6 Live command anchors

```text
find apps/observatory/test -name '*_test.dart' | wc -l
→ 45

flutter test apps/observatory/test --no-pub
→ +811: All tests passed!

flutter test apps/observatory/test/app/ apps/observatory/test/data/ apps/observatory/test/features/ --concurrency=4 --no-pub
→ +810: All tests passed!

flutter test apps/observatory/test/widget_test.dart --no-pub
→ +1: All tests passed!

flutter analyze apps/observatory --no-pub
→ 124 issues found. (0 error / 0 warning / 124 info; exit 0)

# Optional integration harness, bounded to 75 seconds:
timeout 75s flutter test apps/observatory/integration_test/observatory_visual_capture_test.dart --no-pub
→ timed out during shutdown after stream-channel close/add errors (exit 124)
```

The unit-test corpus and analyzer were run on 2026-09-02. The optional
integration-harness attempt is intentionally recorded separately because it is
not under `apps/observatory/test/` and its shutdown behavior is not a unit-test
failure. No generated capture artifact is used as acceptance evidence.

---

## 2. Analyzer baseline (package-level)

Command:

```bash
flutter analyze apps/observatory --no-pub
```

Live result (2026-09-02 refresh):

```text
124 issues found. (ran in 4.7s)
```

| Severity | Count |
|---|---:|
| error | **0** |
| warning | **0** |
| info | **124** |
| **total** | **124** |
| process exit | **0** |

The 2026-08-24 re-run recorded 127 INFO and the 2026-08-23 run recorded 124 INFO;
both remain historical. The current count is 124 INFO from 2026-09-02.

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
| Runtime widget assertion | **0 unit suites** | Prior F02 `widget_test.dart` timeout now passes; see §4.5 |
| Integration harness shutdown | **1 suite (inconclusive)** | Optional visual-capture harness timed out on shutdown; §1.4 |
| Corpus / parser | **0 failing suites** | Parser suites green |
| Projection / mapper | **0 failing suites** | Not a live blocker |
| Analyzer error residual | **0** | Info-only package analyze (124 INFO) |

### 3.1 Top-down vs bottom-up

- **Top-down (corpus → parser)**: not a live failure mode (no failing suites).
- **Bottom-up (view / test expectation)**: no live unit-test failure; the previously
  observed bootstrap pumpAndSettle timeout no longer reproduces.
- **Test-harness/runtime**: the optional integration capture harness has a
  shutdown-termination defect recorded in §1.4 (hypothesis: an unresolved stream
  keeps the integration test's channel open after the assertion passes).

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

### 4.5 2026-08-24 claim — 44 green / 1 non-success / 127 INFO

Superseded as current. The F02 `widget_test.dart` bootstrap smoke timeout did not
reproduce on 2026-09-02: the isolated suite passes and the full unit-test corpus
is green at +811. The 2026-08-24 evidence remains valid history for that date.

### 4.6 Optional integration harness note (2026-09-02)

The bounded attempt to run
`apps/observatory/integration_test/observatory_visual_capture_test.dart` under
`flutter test` timed out at 75 seconds during shutdown with
`Bad state: Cannot close sink while adding stream` /
`Cannot add event while adding stream` (exit 124). The test itself emitted passing
progress before shutdown. This harness is excluded from the unit-test baseline
and should not be represented as either unit-test failure or green integration
evidence without further investigation.

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
