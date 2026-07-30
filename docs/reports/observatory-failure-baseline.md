# Observatory Failure Baseline Inventory

> **Date**: 2026-07-18 (path-to-100 residual close after drain rejection)
> **Source**: Full-package `flutter test apps/observatory --concurrency=2 --no-pub`
> + targeted `history_story_modes_test` + `flutter analyze apps/observatory --no-pub`
> + suite universe listing (`find … *_test.dart` = **44**)
> **Classification**: Inventory only — no production or test code modified under Task 1401
> **Task origin**: Task 1401, EPIC-14 stabilization wave
> **Predecessor**: `docs/reports/warp-prism-failure-baseline-inventory.md` (Task 1201)
> **Supersedes as current**:
> - 2026-06-09 inventory (653 / 589 / 64 runtime framing)
> - mid-wave 2026-07-09 inventory (12 non-success / 1042 analyzer)
> - fixer re-run 2026-07-09 inventory (1 residual suite / 2 history selection-sync errors / 816 green / 40 suites / 164 INFO)
> - drain 2026-07-17 live still had residual claim stale vs product green

---

## 0. Honest status (read first)

Live Observatory diagnostics are **fully green** for the package test suite.
Prior residual F01 (`history_story_modes_test` selection-sync) is **remediated**.

| Metric | 2026-06-09 (hist.) | Mid-wave 2026-07-09 (hist.) | Fixer 2026-07-09 (prior residual) | **Live 2026-07-18** |
|---|---|---|---|---|
| Inventory method | Full suite + `[E]` | 37 suites JSON | 40 suites JSON | Full suite + suite list (**44**) |
| Fully green suites | not recorded | claimed 25 | 39 | **44** |
| Non-success suites | claimed 64 runtime | claimed 12 | **1** | **0** |
| Green test counter | claimed 589 | claimed 472 | 816 | **+810 All tests passed** |
| Non-success tests | claimed 64 | claimed 12 | **2** | **0** |
| Analyzer | not central | claimed 1042 err | 164 INFO | **126 INFO** (0 error / 0 warning), exit 0 |
| Dominant failure class | view / mapper | DS\* compile | history selection sync | **none (package green)** |

> [!IMPORTANT]
> Do not re-assert the 2026-07-09 residual table as current. F01 is historical.
> Suite universe advanced from **40 → 44** (four new suites listed in §1.2).
> Pass totals differ by method (per-suite JSON sum vs full-suite counter); this
> inventory anchors **full-suite `+810 All tests passed!`** as the live package proof.
>
> Expert re-stamp 2026-07-18 (gt-flutter-expert): suite universe still **44/44**,
> `flutter analyze apps/observatory --no-pub` → **126 INFO** (0 error / 0 warning;
> was 127 — prefer_const hygiene drift only). Residual table remains empty.
>
> Formal independent re-review 2026-07-18 (gt-flutter-code-reviewer): full suite
> re-run → **+810 All tests passed** (currency vs prior same-day +808; residual
> still **0**; suite universe still **44/44**; analyzer still **126 INFO**).

---

## 1. Live suite inventory (2026-07-18)

### 1.1 Outcome summary

| Outcome | Count |
|---|---:|
| Total `*_test.dart` suites | **44** |
| Fully green suites | **44** |
| Non-success suites | **0** |
| Full-suite pass counter | **+810** |
| Non-success tests | **0** |
| Package result | **All tests passed!** |

### 1.2 Suite universe (44 / 44 green)

Paths relative to `apps/observatory/test/`:

```text
app/app_bootstrap_test.dart
app/app_shell_smoke_test.dart
app/asset_detail_route_test.dart
app/deep_link_fallback_test.dart
app/production_router_test.dart                    # NEW vs 40-suite universe
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
features/history/history_story_modes_test.dart     # prior residual; now green +31
features/map/map_catalog_panel_test.dart
features/map/map_graph_builder_edges_test.dart     # NEW vs 40-suite universe
features/map/map_graph_panel_test.dart
features/map/map_graph_projection_test.dart
features/map/map_selection_and_inspector_test.dart
features/map/map_surface_states_test.dart
features/map/map_workspace_page_test.dart
features/operate/operate_board_surface_test.dart
features/operate/operate_path_wins_lane_test.dart  # NEW vs 40-suite universe
features/operate/operate_storytelling_test.dart
features/operate/operate_task_detail_inspector_test.dart
features/overview/overview_page_test.dart
features/overview/overview_provider_path_test.dart # NEW vs 40-suite universe
features/overview/overview_provider_test.dart
features/overview/overview_shell_test.dart
features/shell/shell_state_handler_test.dart
features/workspace_snapshot/workspace_snapshot_enhanced_test.dart
features/workspace_snapshot/workspace_snapshot_page_test.dart
```

### 1.3 Non-success suites (0 / 44)

**None.** Live residual table is empty.

### 1.4 Prior residual F01 — remediated (historical)

| # | Suite | Kind | Prior status (2026-07-09) | Live 2026-07-18 | Chain position (historical) | Taxonomy (historical) |
|---|---|---|---|---|---|---|
| F01 | `features/history/history_story_modes_test.dart` | runtime | 30 pass / 2 error (selection sync) | **+31 All tests passed** | View / Test stale (was) | Widget assertion / selection sync (was) |

Historical signatures (do not treat as live):

```text
# 2026-07-09 fixer residual (SUPERSEDED)
selection from impact mode appears in inspector → Found 0 widgets with text "Impact Path"
mode switch preserves selected entry → Bad state: Too many elements (ensureVisible)

# 2026-07-18 reconfirm
flutter test apps/observatory/test/features/history/history_story_modes_test.dart --no-pub
→ +31: All tests passed!
```

### 1.5 Live command anchors

```text
find apps/observatory/test -name '*_test.dart' | wc -l
→ 44

flutter test apps/observatory --concurrency=2 --no-pub
→ +810: All tests passed!

flutter test apps/observatory/test/features/history/history_story_modes_test.dart --no-pub
→ +31: All tests passed!

flutter analyze apps/observatory --no-pub
→ 127 issues found. (0 error / 0 warning / 127 info; exit 0)
  # expert re-stamp 2026-07-18 later same day: 126 INFO (0/0/126; exit 0)
```

Saved logs (this pass): `tmp/1401-analyze.out`, `tmp/1401-full-suite.out`,
`tmp/1401-suite-list.txt`.

---

## 2. Analyzer baseline (package-level)

Command:

```bash
flutter analyze apps/observatory --no-pub
```

Live result (2026-07-18 expert re-stamp; prior same-day log had 127 INFO):

```text
126 issues found. (ran in 1.0s)
```

| Severity | Count |
|---|---:|
| error | **0** |
| warning | **0** |
| info | **126** |
| **total** | **126** |
| process exit | **0** |

### 2.1 What the infos are (class, not flood)

Dominated by style infos such as `prefer_const_constructors`,
`prefer_const_literals_to_create_immutables`, `unnecessary_import`,
`dangling_library_doc_comments`, and similar. **No undefined DS\* / Prism\***
compile errors in this baseline.

### 2.2 DS\* vs Prism\* on Observatory lib (currency check)

Mid-wave inventory claimed dominant root cause = hidden `DS*` after Prism public
API migration. Live package is **green with 0 analyzer errors**. The DS\* compile
cluster is **historical only**.

---

## 3. Root-cause taxonomy (current)

| Class | Live volume | Notes |
|---|---|---|
| Compile / load | **0 suites** | Mid-wave DS\* flood cleared |
| Runtime widget assertion | **0 suites** | F01 history selection sync remediated |
| Corpus / parser | **0 failing suites** | Parser suites green |
| Projection / mapper | **0 failing suites** | Not a live blocker |
| Analyzer error residual | **0** | Info-only package analyze |

### 3.1 Top-down vs bottom-up

- **Top-down (corpus → parser)**: not a live failure mode (no failing suites).
- **Bottom-up (view / test expectation)**: prior sole residual remediated; no live bottom-up failures.

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

### 4.4 Independent re-review claim — 39/39 / +736 / 0 fail

Prior reviewer snapshot (partial suite universe). Live is **44** suites /
**+810** / **0** fail.

### 4.5 Drain review 2026-07-17 — product green vs inventory residual

Drain re-review measured `history_story_modes` +31 and full suite +778 with
inventory still claiming 2 residual errors — **Proof Reality reject**. This
document closes that gap.

---

## 5. Files read (anti-hallucination evidence)

### 5.1 Test files executed

Every path under `apps/observatory/test/**/*_test.dart` (full set = **44**,
listed in §1.2). Full-package run: `tmp/1401-full-suite.out`. Suite list:
`tmp/1401-suite-list.txt`.

### 5.2 Diagnostics / residual reconfirm

| Path | Why |
|---|---|
| `apps/observatory/test/features/history/history_story_modes_test.dart` | Prior F01 residual; reconfirmed green +31 |
| `tmp/1401-analyze.out` | Analyzer severity counts (prior 127 INFO; expert re-stamp 126) |
| `tmp/1401-full-suite.out` | Package green +810 (formal re-review) |
| `tmp/1401-suite-list.txt` | Suite universe 44 |
| `docs/reports/review-wave-2026-07-17/task-1401-drain-review.md` | Drain residual contract |

---

## 6. Deterministic extraction method (not `[E]` grep)

Preferred recipes:

```bash
# Package-level green proof (this pass anchor):
flutter analyze apps/observatory --no-pub | tee tmp/1401-analyze.out
flutter test apps/observatory --concurrency=2 --no-pub | tee tmp/1401-full-suite.out
find apps/observatory/test -name '*_test.dart' | sort | tee tmp/1401-suite-list.txt | wc -l

# Optional per-suite JSON (still valid when residual hunting):
mkdir -p tmp/1401-suite-json
echo -e "suite\texit\tpass\tfail\terror\tskip" > tmp/1401-suite-summary.tsv
find apps/observatory/test -name '*_test.dart' | sort | while read f; do
  base=$(echo "$f" | sed 's|apps/observatory/test/||;s|/|__|g;s|\.dart$||')
  out="tmp/1401-suite-json/${base}.json"
  flutter test "$f" --reporter=json --no-pub >"$out" 2>"tmp/1401-suite-json/${base}.err" || true
done
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
| H1 | ~~Fix history selection-sync~~ — **DONE** (live green) | — |
| H2 | Keep corpus frontmatter scan in CI (`no_fm=0`) after Task 1403 | Corpus governance |
| H3 | Re-run this inventory before every promotion of Task 1401 | builders / reviewers |
| H4 | Optional: reduce 126 analyzer INFO style noise | polish lane (not package blocker) |

---

## 8. Completion snapshot (Task 1401)

| Check | Result |
|---|---|
| Inventory path | `docs/reports/observatory-failure-baseline.md` |
| Live suite count | **44** |
| Live green suites | **44** |
| Live non-success suites | **0** |
| Live full-suite result | **+810 All tests passed!** |
| Live analyzer | **126 info / 0 error / 0 warning** (exit 0) |
| F01 residual | **Historical / remediated** |
| Historical 64-runtime / 12-compile / 2-error tables | Labeled historical only |
| DS\* compile dominant cause | Obsolete |
| VCS | No git/jj operations performed |
