# Task 1609: PrismTimingWaterfall + PrismTrafficInspector Pack

> **Review State**: `HELD_IN_REVIEW_PATH_TO_100`
> **Priority**: 🟡 P1
> **Type**: `feature`
> **Origin**: EPIC-16 (`docs/tasks/00-planning/EPIC-16-warp-prism-ads-cybercore-ops-and-agent-transcript-organisms.md`) + harvest reports `docs/reports/ads-harvest-session-synthesis-2026-07-10.md`, `docs/reports/ads-harvest-omniroute-visual-reference-2026-07-10.md`, `docs/reports/ads-harvest-references-catalog-triage-2026-07-10.md`, `docs/reports/ads-harvest-atomic-ds-references-2026-07-10.md`
> **Blocks**: Task 1613 (soft)
> **Depends on**: Task 1600
>
> **Soft**: Task 1601 gallery polish. Pack delivers **C-09** + **C-10** together as MVP.

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1609` plus optional slug for
> dependencies, blockers, review ledgers, reports, and architecture references.
> Lanes such as `02-doing` and `03-review` are mutable status, not identity.

---

## Objective

Implement an ops inspect pack:

1. **`PrismTimingWaterfall`** — request timing bars from fixture span data (no Recharts port).
2. **`PrismTrafficInspector`** — request/response inspect MVP (list + detail tabs/fields).

Fixture-first CyberCore; pure Flutter painting/layout (CustomPaint or simple bar rows). Public `Prism*` + `DS*` + aliases; minimal gallery cases.

## Background Context

### Source origin (EPIC-16)

| Field | Value |
| --- | --- |
| **Public names** | `PrismTimingWaterfall`, `PrismTrafficInspector` |
| **Internal** | `DSTimingWaterfall`, `DSTrafficInspector` + typedefs |
| **Harvest IDs** | **C-09**, **C-10** |
| **Origin** | OmniRoute traffic inspector + timing views |
| **Wave** | **L** |
| **Action type** | `NEW` (pack) |

### What already exists

- Data table, log viewer, tab bar, split pane, metric tiles, sparklines.
- No waterfall timing organism; no traffic inspect MVP.

### What is missing or broken

- No fixture-driven timing waterfall for latency spans.
- No request list + detail traffic inspector organism.

### False-gap notes

- Do **not** port Recharts or any JS chart library.
- Do **not** MITM live traffic or require proxy backends.
- Do **not** add network capture dependencies to `warp_prism_ui`.

### Composition notes

- Waterfall: rows of labeled spans with proportional width bars.
- Traffic inspector: list of requests + detail (headers/body summary as text fixtures); may embed waterfall for selected request.

---

## Test Requirements

- **TimingWaterfall**: render fixture spans; zero-duration and empty list safe; bar widths scale with duration.
- **TrafficInspector**: list fixture requests; select shows detail; empty list safe.
- Widget tests for both.
- A11y: list semantics; span labels include name + duration.
- Gallery fixtures with mock request IDs and timings.
- No Recharts/MapLibre deps in pubspec.

---

## Exit Conditions

- [x] Both public names exported.
- [x] Tests + minimal gallery for both PASS.
- [x] No Recharts; no live traffic capture.
- [x] Analyze + scoped tests PASS; boundaries **6/6** after barrel/alias.
- [x] Local changelog under `docs/changelog/`.
- [x] Completion Evidence filled.

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: read EPIC-16, harvest session synthesis + references triage (OmniRoute traffic), Task 1600 brief if present, `packages/warp_prism_ui/lib/src/organisms/data_table/ds_data_table.dart`, `packages/warp_prism_ui/lib/src/organisms/log_viewer/ds_log_viewer.dart`, `packages/warp_prism_ui/lib/src/organisms/tab_bar/ds_tab_bar.dart`, `packages/warp_prism_ui/lib/src/organisms/split_pane/ds_split_pane.dart`, `packages/warp_prism_ui/lib/src/atoms/ds_sparkline.dart`, `packages/warp_prism_ui/lib/src/organisms/organisms.dart`, `packages/warp_prism_ui/lib/src/prism_aliases.dart`, `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart`, `packages/warp_prism_ui/pubspec.yaml` (deps purity), `packages/warp_prism_ui/lib/src/tokens/ds_colors.dart`, `packages/warp_prism_ui/lib/src/tokens/ds_spacing.dart`.
- [x] Define span + request fixture models.
- [x] Implement waterfall bars (layout math documented in code comments briefly).
- [x] Implement traffic list + detail MVP (headers/body as plain text or code block).
- [x] Optionally compose waterfall inside traffic detail.
- [x] Export both aliases; tests; gallery.
- [x] **Simplicity pass**: MVP only — no full HAR editor, no live stream websocket.
- [x] **Regression verification**: validation commands; confirm no Recharts dep.

### Where

| File | Purpose |
| --- | --- |
| `packages/warp_prism_ui/lib/src/organisms/timing_waterfall/` | Create — module |
| `packages/warp_prism_ui/lib/src/organisms/timing_waterfall/ds_timing_waterfall.dart` | Create |
| `packages/warp_prism_ui/lib/src/organisms/traffic_inspector/` | Create — module |
| `packages/warp_prism_ui/lib/src/organisms/traffic_inspector/ds_traffic_inspector.dart` | Create |
| `packages/warp_prism_ui/lib/src/organisms/code_block/ds_code_block.dart` | Read — body display |
| `packages/warp_prism_ui/lib/src/organisms/organisms.dart` | Modify — export |
| `packages/warp_prism_ui/lib/src/prism_aliases.dart` | Modify — aliases |
| `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` | Modify — gallery |
| `packages/warp_prism_ui/pubspec.yaml` | Read — ensure no chart ports |
| `packages/warp_prism_ui/test/organisms/timing_waterfall/` | Create — tests |
| `packages/warp_prism_ui/test/organisms/traffic_inspector/` | Create — tests |
| `docs/changelog/` | Create — changelog |

### How

1. Span model: name, startMs, durationMs, optional depth.
2. Waterfall row layout with flex or fraction of max duration.
3. Traffic list selection drives detail panes.
4. Export/test/gallery/boundaries.

### Why

Ops timing + traffic inspect are core OmniRoute harvests for CyberCore console parity without proxy product scope.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> No Recharts. No live MITM. Fixtures only.

> [!IMPORTANT]
> Flutter-only rendering for bars. Keep package Flutter-SDK posture.

> [!WARNING]
> ADS-first. No Observatory rebrand. No MapLibre.

---

## Validation Commands

```bash
cd packages/warp_prism_ui
dart analyze lib test
flutter test test/organisms/timing_waterfall/
flutter test test/organisms/traffic_inspector/
# Ensure no forbidden deps:
grep -E 'recharts|maplibre|widgetbook' pubspec.yaml || true

cd ../..
melos run test-boundaries
```

If Flutter tooling is unavailable, record the exact tooling failure and do not
claim those checks passed.

---

## Completion Evidence

- **Files created/modified**:
  - Created `packages/warp_prism_ui/lib/src/organisms/timing_waterfall/ds_timing_waterfall.dart`
  - Created `packages/warp_prism_ui/lib/src/organisms/timing_waterfall/timing_waterfall.dart`
  - Created `packages/warp_prism_ui/lib/src/organisms/traffic_inspector/ds_traffic_inspector.dart`
  - Created `packages/warp_prism_ui/lib/src/organisms/traffic_inspector/traffic_inspector.dart`
  - Created `packages/warp_prism_ui/test/organisms/timing_waterfall/ds_timing_waterfall_test.dart`
  - Created `packages/warp_prism_ui/test/organisms/traffic_inspector/ds_traffic_inspector_test.dart`
  - Modified `packages/warp_prism_ui/lib/src/organisms/organisms.dart` (append exports)
  - Modified `packages/warp_prism_ui/lib/src/prism_aliases.dart` (append aliases + fixture helpers)
  - Modified `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` (gallery demos + subtitle)
  - Created `docs/changelog/2026-07-11-task-1609-timing-waterfall-traffic-inspector-pack.md`
- **Public API names verified**: `PrismTimingWaterfall`, `PrismTrafficInspector` (+ `PrismTimingSpan`, `PrismTimingWaterfallLayout`, `PrismTrafficRequest`, `PrismTrafficDetailTab`, fixture helpers)
- **Tests or validation commands**:
  ```text
  dart analyze lib/src/organisms/timing_waterfall \
    lib/src/organisms/traffic_inspector \
    lib/src/prism_aliases.dart lib/src/organisms/organisms.dart \
    lib/src/gallery/design_system_gallery_sections.dart \
    test/organisms/timing_waterfall test/organisms/traffic_inspector
  # No issues found — exit 0

  flutter test test/organisms/timing_waterfall/ test/organisms/traffic_inspector/
  # All tests passed! — 23/23 — exit 0

  grep -E 'recharts|maplibre|widgetbook' pubspec.yaml || true
  # no forbidden deps — exit 0
  ```
- **Boundary harness**: `dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .` → **6/6 PASS** (exit 0)
- **Local changelog entry**: `docs/changelog/2026-07-11-task-1609-timing-waterfall-traffic-inspector-pack.md`
- **Agent-wiki / docs institutionalization**: N/A
- **Executor**: gt-flutter-engineer
- **Completion date**: 2026-07-11

---

## Review Ledger

### Latest Review — drain 2026-07-17

- **Date**: 2026-07-17
- **Reviewer profile**: `reviewers` (gt-flutter-code-reviewer + code-quality-harness + flutter-harness + review-report-lineage)
- **Score**: `91/100`
- **Verdict**: `APPROVED_PATH_TO_100`
- **Full report**: `docs/reports/review-wave-2026-07-17/task-1609-drain-review.md`
- **Lane outcome**: moved `03-review/` → `04-completed/`
- **Task reference**: Task 1609
- **Top residual**: traffic row excludeChildSemantics still open; equality omits timingSpans

#### Path-to-100 residuals (non-blocking for S≥90 closeout)

- See full report Path To 100. Shared: `dart format` on EPIC-16 organism/test/golden surfaces.
- Package-wide analyzer infos (141) are residual package hygiene, not scoped-task exit failures.

### Previous Latest Review
- **Date**: 2026-07-11
- **Reviewer profile**: `reviewers` (`gt-flutter-code-reviewer` + `code-quality-harness` + `flutter-harness`)
- **Score**: `95/100`
- **Verdict**: `HELD_IN_REVIEW_PATH_TO_100`
- **Full report**: `docs/reports/review-wave-2026-07-11/task-1609-independent-review.md`
- **Live prove**: analyze clean; scoped organism tests PASS; boundary harness **6/6 PASS**
- **Lane outcome**: moved `02-doing/` → `03-review/` (never `04-completed/`)
- **Policy**: independent initial review; no git / no tasklist


---

## Review Ledger — 2026-07-18 Path-to-100 Re-review (Batch R6)

| Field | Value |
| --- | --- |
| **Date** | 2026-07-18 |
| **Reviewer** | independent `reviewers` (parent agentID=reviewers) |
| **Harnesses** | code-quality-harness + flutter-harness |
| **Score** | 100/100 |
| **Verdict** | ACCEPTED_100 |
| **Path-to-100 applied** | YES |
| **Lane** | → `04-completed/` |
| **Full report** | `docs/reports/review-wave-2026-07-18/task-1609-path100-rereview.md` |
| **Top finding** | none — a11y excludeChildSemantics + timingSpans equality + format closed |
| **Exits** | PASS |
| **Live gates** | format 0; analyze 0; organism/gallery/goldens PASS; boundaries 7/7 |

