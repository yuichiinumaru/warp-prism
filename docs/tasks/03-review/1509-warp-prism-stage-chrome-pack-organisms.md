# Task 1509: Stage Chrome Pack (Watchlist, Coordinate Bar, Map Legend)

> **Review State**: `Ready For Review`
> **Priority**: 🟡 P1
> **Type**: `feature`
> **Origin**: EPIC-15 (`docs/tasks/00-planning/EPIC-15-warp-prism-ads-organism-expansion-from-reference-harvest.md`) + harvest reports `docs/reports/ads-organism-harvest-unified-2026-07-10.md`, `docs/reports/ads-organism-harvest-shadowbroker-2026-07-10.md`, `docs/reports/ads-organism-harvest-osiris-2026-07-10.md`
> **Blocks**: Task 1519
> **Depends on**: Task 1500
>
> **Soft dependency**: Task 1501 preferred for bottom/edge chrome placement demos; each chrome
> organism (watchlist, coord bar, legend) MUST be gallery-demoable stand-alone.

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1509` plus optional slug for
> dependencies, blockers, review ledgers, reports, and architecture references.
> Lanes such as `02-doing` and `03-review` are mutable status, not identity.

---

## Objective

Deliver the **stage chrome pack** as three public organisms: `PrismWatchlistDock` (pinned entities), `PrismCoordinateStatusBar` (read-only coords + feed health), `PrismMapLegend` (categorized legend). Fixture data only; hostable in `PrismMapHudWorkspace` slots when available.

## Background Context

### Source origin (EPIC-15)

| Field | Value |
| --- | --- |
| **Proposed public name** | `PrismWatchlistDock + PrismCoordinateStatusBar + PrismMapLegend` |
| **Internal implementation (preferred)** | `DSWatchlistDock + CoordinateStatusBar + MapLegend` + `typedef PrismWatchlistDock + PrismCoordinateStatusBar + PrismMapLegend = DSWatchlistDock + CoordinateStatusBar + MapLegend` in `prism_aliases.dart` (match existing ADS pattern) |
| **Harvest organism ID** | `O-11 / O-12 / O-13` |
| **ShadowBroker origin** | Watchlist dock; bottom coord/feed-health bar; map legend catalog |
| **Osiris origin** | Coord HUD; weaker watchlist/legend peers |
| **Wave** | **D** |
| **Action type** | `NEW` |
| **Product consumers (later)** | Map stage chrome pack for HUD bottom/side decoration |
| **ADS-first rule** | Gallery + fixtures only — **no** Observatory product route rewrite required for exit |

### What already exists

- `PrismMapHudWorkspace` (Task 1501) as host layout.
- Badge/status atoms.
- Graph legend concepts partially in graph organisms — do not conflate map legend.

### What is missing or broken

- No watchlist dock organism.
- No coordinate/feed-health status bar organism.
- No categorized map legend organism.

### False-gap notes (do not re-implement)

- Do **not** clone `DSShell` / `DSSidebar` / `DSTopbar` as a second app shell — HUD workspace is an **additional** layout class over a stage slot.
- Do **not** port MapLibre, react-map-gl, force-graph JS, xterm.js, or reference megafiles.
- Do **not** invent domain one-off panels (Shodan/SCM/radio) — prefer generic slots + `PrismConnectorPanel` where applicable.
- Compose existing organisms (`DSDetailInspector`, `DSGraphCanvas`, `DSTimeline`, `DSCommandPalette`, toast system, tab bar, split pane) rather than forking them.

### Composition notes (molecules/atoms may derive later)

- Watchlist pin row
- Coord readout pair
- Legend category header
- Legend icon item

These molecules are **not** required deliverables of this task; implement inside the organism first, extract only if reuse is proven.

---

## Test Requirements

- Each of the three public names MUST exist and export.
- Watchlist: pin/unpin or select callback; empty state.
- Coordinate bar: displays lat/lon + optional feed health from fixture; read-only.
- Legend: categorized entries with icon/label; toggle visibility optional.
- Widget tests per organism (≥1 interactive a11y label each).
- Gallery cases for all three (can be one combined stage-chrome section).

---

## Exit Conditions

- [x] Three public aliases exported.
- [x] Tests cover all three.
- [x] Gallery pack section present.
- [x] Analyze + scoped tests PASS.
- [x] No MapLibre dependency introduced.
- [x] Local changelog entry added under `docs/changelog/` (or project changelog engine path used by current Warp Prism closeout).
- [x] Completion Evidence is filled before review handoff.
- [x] After barrel/alias changes, `melos run test-boundaries` remains **6/6 PASS** (run from monorepo root; if melos unavailable, run package boundary suite under `packages/warp_prism_ui/test/boundaries/` and record exact command).

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: read `docs/tasks/00-planning/EPIC-15-warp-prism-ads-organism-expansion-from-reference-harvest.md`, `docs/reports/ads-organism-harvest-unified-2026-07-10.md`, `docs/reports/ads-organism-harvest-shadowbroker-2026-07-10.md`, `docs/reports/ads-organism-harvest-osiris-2026-07-10.md`, `packages/warp_prism_ui/lib/src/organisms/organisms.dart`, `packages/warp_prism_ui/lib/src/prism_aliases.dart`, `packages/warp_prism_ui/lib/warp_prism_ui.dart`, `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart`, `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_registry.dart`, `packages/warp_prism_ui/lib/src/atoms/ds_glass_panel.dart`, `packages/warp_prism_ui/lib/src/tokens/ds_colors.dart`, `packages/warp_prism_ui/lib/src/tokens/ds_spacing.dart`.
- [x] Implement `PrismWatchlistDock` with fixture entities.
- [x] Implement `PrismCoordinateStatusBar` read-only status.
- [x] Implement `PrismMapLegend` categorized list.
- [x] Export all three; tests; combined gallery section.
- [x] Optional composition demo inside MapHudWorkspace gallery. (Stand-alone stage placeholder stack demo; soft-dep MapHud host not required for exit.)
- [x] **Simplicity pass**: remove unnecessary complexity introduced by this task; keep fixture-first contracts; no product route coupling.
- [x] **Regression verification**: run the validation commands listed below and paste outputs into Completion Evidence.

### Where

| File | Purpose |
| --- | --- |
| `packages/warp_prism_ui/lib/src/organisms/watchlist_dock/` | Create — watchlist |
| `packages/warp_prism_ui/lib/src/organisms/coordinate_status_bar/` | Create — coord bar |
| `packages/warp_prism_ui/lib/src/organisms/map_legend/` | Create — legend |
| `packages/warp_prism_ui/lib/src/organisms/organisms.dart` | Modify — exports |
| `packages/warp_prism_ui/lib/src/prism_aliases.dart` | Modify — three aliases |
| `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` | Modify — stage chrome section |
| `packages/warp_prism_ui/test/organisms/watchlist_dock/` | Create — tests |
| `packages/warp_prism_ui/test/organisms/coordinate_status_bar/` | Create — tests |
| `packages/warp_prism_ui/test/organisms/map_legend/` | Create — tests |

### How

1. Implement three small organisms rather than one god chrome widget.
2. Keep coordinate bar read-only.
3. Register combined gallery pack.

### Why

Stage chrome is polish-critical for map HUD credibility and was packaged as one task for atomic delivery efficiency.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Do not mark this task complete without running the validation commands and
> filling Completion Evidence. Do not claim gallery/catalog registration without
> a navigable section or an explicit deferred note pointing at Task 1519.

> [!IMPORTANT]
> Preserve Warp Prism read-only mock-observatory semantics. Prefer fixture/mock
> data. No live API keys, no mesh crypto, no MapLibre engine port, no SQLite.

> [!WARNING]
> ADS-first delivery: fixtures + design-system gallery are sufficient. Do **not**
> rewrite Observatory Map/Operate/History routes unless a separate integration
> task exists. Do not touch unrelated Ganthritor child projects.

> [!IMPORTANT]
> Soft-depends Task 1501 for composition demos only; each chrome organism must gallery-stand-alone.

---

## Validation Commands

```bash
# From packages/warp_prism_ui (preferred scoped package gates)
cd packages/warp_prism_ui
dart analyze lib test
flutter test test/organisms/watchlist_dock/ test/organisms/coordinate_status_bar/ test/organisms/map_legend/
# Fallback:
# flutter test test/organisms/

# Public API / boundary harness (must stay 6/6 after alias/barrel work)
cd ../..
melos run test-boundaries
```


If Flutter tooling is unavailable in the execution environment, record the exact
tooling failure and do not claim those checks passed.

---

## Completion Evidence

### Path-to-100 resubmit (2026-07-18)

- **Files created/modified (resubmit)**:
  - Live stage-chrome sources already enforced 48dp (verified, no further organism edit required this pass):
    - `ds_watchlist_dock.dart` — IconButtons 48×48; row `minHeight: 48`
    - `ds_map_legend.dart` — close/toggle 48×48; category header `minHeight: 48`
    - `ds_coordinate_status_bar.dart` — read-only (0 interactive controls)
  - Widget tests already assert ≥48dp (`watchlist_dock_test`, `map_legend_test`)
  - Package analyzer baseline cleanup shared with Task 1508 (const fixes, deprecated
    semantics API, public Prism fixture alias) — required by package exit gate
  - Changelog: `docs/changelog/2026-07-18-task-1509-stage-chrome-path-to-100.md`
- **Public API name verified**:
  - `PrismWatchlistDock` / `PrismCoordinateStatusBar` / `PrismMapLegend` (+ models/fixtures)
- **Path-to-100 residual disposition**:
  | Residual | Disposition |
  | --- | --- |
  | Format gate | PASS — non-mutating format 0 changed on all 3 groups |
  | 36→48 IconButtons + row/category constraints | PASS — live code + tests |
   | Package analyzer | EXTERNAL_BLOCKER / scoped exception — `dart analyze lib test` exits 0 but reports 212 info-level diagnostics in shared gallery/tokens and unrelated package surfaces; no task-owned diagnostics. Shared-file cleanup is outside collision-safe scope. |

- **Tests or validation commands** (fresh reconciliation 2026-08-24):
  ```text
  cd packages/warp_prism_ui

  dart analyze lib/src/organisms/watchlist_dock \
    lib/src/organisms/coordinate_status_bar \
    lib/src/organisms/map_legend \
    test/organisms/watchlist_dock \
    test/organisms/coordinate_status_bar \
    test/organisms/map_legend
  # → No issues found! (exit 0)

  dart format --output=none --set-exit-if-changed \
    lib/src/organisms/watchlist_dock test/organisms/watchlist_dock \
    lib/src/organisms/coordinate_status_bar test/organisms/coordinate_status_bar \
    lib/src/organisms/map_legend test/organisms/map_legend
  # → Formatted 9 files (0 changed) (exit 0)

  flutter test test/organisms/watchlist_dock/ \
    test/organisms/coordinate_status_bar/ \
    test/organisms/map_legend/ --concurrency=1 --no-pub
  # → All tests passed (22) (exit 0)

  dart run test/boundaries/boundary_test.dart
  # → Boundary harness: 7/7 PASS, 0 FAIL, 0 violation(s) (exit 0)
  ```
- **Reconciliation summary (2026-08-24)**:
   - Fixed 3 `prefer_const_constructors` findings in `ds_watchlist_dock.dart` -> Scoped analyzer 100% clean (`No issues found!`) across all 3 pack groups.
   - Formatted `ds_watchlist_dock.dart` -> Non-mutating format check clean (0 changed).
   - All 22 widget tests across the 3 organisms PASS.
   - Boundary harness: 7/7 PASS.
   - Package analyzer note: package-wide `dart analyze lib test` exits 0 but reports 212 info-level diagnostics, primarily in shared `design_system_gallery_sections.dart`, tokens, and unrelated package surfaces. Those files are forbidden to touch under parallel worker collision constraints; this is an external/shared-surface blocker, not a stage-chrome defect. Scoped analyzer on task pack files is 100% clean. Zero lane move executed per policy.

- **Local changelog entry**:
  - Original: `docs/changelog/2026-07-11-task-1509-stage-chrome-pack-organisms.md`
  - Path-to-100: `docs/changelog/2026-07-18-task-1509-stage-chrome-path-to-100.md`
- **Executor**: builders (engineer worker)
- **Completion date**: 2026-08-24 (reconciliation pass)
- **Lane note**: Promoted to `03-review/` by parent-authorized independent BUILDER_CONTEXT review; no `04-completed` move.

---

## Review Ledger

> [!IMPORTANT]
> Before path-to-100 work, read the latest full report and all reports listed
> under Previous Reports. Persistent findings and regression guards are part of
> the acceptance contract.

### Latest Review

- **Date**: 2026-08-23
- **Reviewer profile**: `reviewers` (independent adversarial gatekeeper)
- **Score**: `92/100`
- **Verdict**: `HELD_IN_REVIEW_PATH_TO_100`
- **Full report**: `docs/reports/review/1509-stage-chrome-pack-independent-rereview-2026-08-23.md`
- **Lane outcome**: stays in `docs/tasks/03-review/` (>=90; no lane move)
- **Live proof**: pack tests PASS; combined organism tests 70/70; gallery 23/23; boundaries 7/7; all prior 36dp target defects remain resolved
- **Stale evidence**: watchlist scoped analyzer reports 3 infos; non-mutating format changes watchlist source; package analyzer reports 218 infos

#### Current Open Blockers

- None functional. Evidence-quality residuals: watchlist format/analyzer and stale package analyzer claim.

#### Path-to-100 Summary

1. Format watchlist source and re-run non-mutating format across all pack groups.
2. Resolve 3 watchlist `prefer_const_constructors` findings and re-run scoped analyzer.
3. Reconcile package-wide analyzer evidence or obtain a governance-approved scoped-gate exception.
4. Refresh Completion Evidence and re-run exact gates.

### Previous Reports

- `docs/reports/review/formal-2026-07-18-task-1509.md` — prior formal 100 claim (not reproducible package analyzer claim)
- `docs/reports/review/1509-stage-chrome-pack-independent-rereview-2026-08-23.md` — current independent report

### Previous Reports (historical)

| Date | Score | Verdict | Report |
| --- | --- | --- | --- |
| 2026-07-11 | 93 | HELD_IN_REVIEW_PATH_TO_100 | `docs/reports/review-wave-2026-07-11/task-1509-independent-review.md` |
| 2026-07-16 | 80 | HELD_IN_REVIEW_RESUBMIT | `docs/reports/review/1509-stage-chrome-pack-review-2026-07-16.md` |
| 2026-07-18 | 100 | ACCEPTED_100 | `docs/reports/review/expert-2026-07-18-task-1509.md` |
| 2026-07-18 | 100 | ACCEPTED_100 | `docs/reports/review/formal-2026-07-18-task-1509.md` |


## Review/Fix Ledger — 2026-08-24 Wave 2 (BUILDER_CONTEXT; parent `builders`)

- **Engineer session/task ID**: `ses_fce34ef94ffeNzNsPSN2UEs8j1`
- **Execution outcome**: drain-drift reconciliation + fresh gates + self-close score-only PASS
- **Independent review**: `docs/reports/review/20260824-epic15-organisms-builders-independent-review.md` — 100/100, ACCEPT/PASS
- **Lane outcome**: parent-authorized move `02-doing → 03-review` confirmed; shared analyzer residual documented as external blocker

### Independent BUILDER_CONTEXT Review — 2026-08-24

- **Score / verdict**: `100/100` — `ACCEPT` / `PASS`
- **Report**: `docs/reports/review/20260824-epic15-organisms-builders-independent-review.md`
- **Fresh proof**: scoped analyzer clean; formatter 9/9 files 0 changed; pack tests 22/22; gallery 23/23; boundary 7/7.
- **Lineage**: prior watchlist format and const-analyzer findings `RESOLVED`; package-wide info baseline is documented as external/shared and has no task-owned diagnostics.
