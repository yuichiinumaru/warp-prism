# Task 1508: PrismStatusTicker Organism

> **Review State**: `Ready For Review`
> **Priority**: 🔴 P0
> **Type**: `feature`
> **Origin**: EPIC-15 (`docs/tasks/00-planning/EPIC-15-warp-prism-ads-organism-expansion-from-reference-harvest.md`) + harvest reports `docs/reports/ads-organism-harvest-unified-2026-07-10.md`, `docs/reports/ads-organism-harvest-shadowbroker-2026-07-10.md`, `docs/reports/ads-organism-harvest-osiris-2026-07-10.md`
> **Blocks**: Task 1519
> **Depends on**: Task 1500

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1508` plus optional slug for
> dependencies, blockers, review ledgers, reports, and architecture references.
> Lanes such as `02-doing` and `03-review` are mutable status, not identity.

---

## Objective

Implement `PrismStatusTicker` marquee/rotating status strip for fixture status items with optional severity styling via existing operational state tokens.

## Background Context

### Source origin (EPIC-15)

| Field | Value |
| --- | --- |
| **Proposed public name** | `PrismStatusTicker` |
| **Internal implementation (preferred)** | `DSStatusTicker` + `typedef PrismStatusTicker = DSStatusTicker` in `prism_aliases.dart` (match existing ADS pattern) |
| **Harvest organism ID** | `O-07` |
| **ShadowBroker origin** | Bottom ticker strip on map workspace |
| **Osiris origin** | `GlobalStatusBar.tsx` rotating/live status strip |
| **Wave** | **D** |
| **Action type** | `NEW` |
| **Product consumers (later)** | Shell polish; bottom HUD chrome |
| **ADS-first rule** | Gallery + fixtures only — **no** Observatory product route rewrite required for exit |

### What already exists

- Toast system for discrete notifications.
- `DSStatusGrid` for service grids.
- Operational state tokens.

### What is missing or broken

- No marquee/rotating continuous status ticker organism.
- No bottom-strip gallery demo for live status items.

### False-gap notes (do not re-implement)

- Do **not** clone `DSShell` / `DSSidebar` / `DSTopbar` as a second app shell — HUD workspace is an **additional** layout class over a stage slot.
- Do **not** port MapLibre, react-map-gl, force-graph JS, xterm.js, or reference megafiles.
- Do **not** invent domain one-off panels (Shodan/SCM/radio) — prefer generic slots + `PrismConnectorPanel` where applicable.
- Compose existing organisms (`DSDetailInspector`, `DSGraphCanvas`, `DSTimeline`, `DSCommandPalette`, toast system, tab bar, split pane) rather than forking them.

### Composition notes (molecules/atoms may derive later)

- Marquee item
- Ticker severity badge

These molecules are **not** required deliverables of this task; implement inside the organism first, extract only if reuse is proven.

---

## Test Requirements

- MUST accept a list of status items (text, optional severity).
- MUST rotate or marquee through items (testable via controller/timer mock).
- Widget tests: single item, multi item, empty list, severity styling.
- A11y: ticker region labeled; avoid inaccessible infinite-only content without static alternative when reduced motion if feasible.
- Gallery fixture with mock feed items.

---

## Exit Conditions

- [x] `PrismStatusTicker` exported.
- [x] Tests + gallery PASS.
- [x] Analyze + scoped test PASS.
- [x] Local changelog entry added under `docs/changelog/` (or project changelog engine path used by current Warp Prism closeout).
- [x] Completion Evidence is filled before review handoff.
- [x] After barrel/alias changes, `melos run test-boundaries` remains **6/6 PASS** (run from monorepo root; if melos unavailable, run package boundary suite under `packages/warp_prism_ui/test/boundaries/` and record exact command).

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: read `docs/tasks/00-planning/EPIC-15-warp-prism-ads-organism-expansion-from-reference-harvest.md`, `docs/reports/ads-organism-harvest-unified-2026-07-10.md`, `docs/reports/ads-organism-harvest-shadowbroker-2026-07-10.md`, `docs/reports/ads-organism-harvest-osiris-2026-07-10.md`, `packages/warp_prism_ui/lib/src/organisms/organisms.dart`, `packages/warp_prism_ui/lib/src/prism_aliases.dart`, `packages/warp_prism_ui/lib/warp_prism_ui.dart`, `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart`, `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_registry.dart`, `packages/warp_prism_ui/lib/src/atoms/ds_glass_panel.dart`, `packages/warp_prism_ui/lib/src/tokens/ds_colors.dart`, `packages/warp_prism_ui/lib/src/tokens/ds_spacing.dart`.
- [x] Define status item model.
- [x] Implement ticker with pause-on-hover optional.
- [x] Respect motion tokens; document reduced-motion note.
- [x] Tests + gallery + exports.
- [x] **Simplicity pass**: remove unnecessary complexity introduced by this task; keep fixture-first contracts; no product route coupling.
- [x] **Regression verification**: run the validation commands listed below and paste outputs into Completion Evidence.

### Where

| File | Purpose |
| --- | --- |
| `packages/warp_prism_ui/lib/src/organisms/status_ticker/` | Create — module |
| `packages/warp_prism_ui/lib/src/organisms/status_ticker/ds_status_ticker.dart` | Create — implementation |
| `packages/warp_prism_ui/lib/src/tokens/ds_operational_state.dart` | Read — severity styling |
| `packages/warp_prism_ui/lib/src/organisms/organisms.dart` | Modify — export |
| `packages/warp_prism_ui/lib/src/prism_aliases.dart` | Modify — alias |
| `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` | Modify — gallery |
| `packages/warp_prism_ui/test/organisms/status_ticker/` | Create — tests |

### How

1. Implement simple rotating ticker first; marquee polish second.
2. Style with glass bottom strip tokens.
3. Export/test/gallery.

### Why

Continuous status strip is shared chrome in both references and is absent from current ADS.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Do not mark this task complete without running the validation commands and
> filling Completion Evidence. Do not claim gallery/catalog registration without
> a navigable section or an explicit deferred note pointing at Task 1519.
>
> [!IMPORTANT]
> Preserve Warp Prism read-only mock-observatory semantics. Prefer fixture/mock
> data. No live API keys, no mesh crypto, no MapLibre engine port, no SQLite.
>
> [!WARNING]
> ADS-first delivery: fixtures + design-system gallery are sufficient. Do **not**
> rewrite Observatory Map/Operate/History routes unless a separate integration
> task exists. Do not touch unrelated Ganthritor child projects.


---

## Validation Commands

```bash
# From packages/warp_prism_ui (preferred scoped package gates)
cd packages/warp_prism_ui
dart analyze lib test
flutter test test/organisms/
# Prefer organism-scoped path when present, e.g.:
# flutter test test/organisms/status_ticker/
# flutter test test/organisms/*status_ticker*

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
  - Modified `packages/warp_prism_ui/lib/src/organisms/status_ticker/ds_status_ticker.dart`
    - default height 48; `explicitChildNodes` when tappable; chip Semantics(container+button)+48dp ConstrainedBox+Material
  - Modified `packages/warp_prism_ui/test/organisms/status_ticker/status_ticker_test.dart`
    - hardened button semantics + ≥48dp assertion
  - Package analyzer baseline (shared exit gate; not organism Where-table only):
    - `dart fix --apply` across lib/test (const/dangling docs)
    - `test/molecules/ds_scale_measure_bar_test.dart` — use public `PrismScaleMeasureBarFixtures`
    - `test/log_viewer_test.dart`, `test/organisms/command_palette_test.dart` — `flagsCollection` + drop unused imports
  - Changelog: `docs/changelog/2026-07-18-task-1508-status-ticker-path-to-100.md`
- **Public API name verified**: `PrismStatusTicker` (+ Item/Mode/Controller/Fixtures) via `prism_aliases.dart`
- **Path-to-100 residual disposition**:
  | Residual | Disposition |
  | --- | --- |
  | Format gate | PASS — `dart format --output=none --set-exit-if-changed` 0 changed |
   | Package analyzer | EXTERNAL_BLOCKER / scoped exception — `dart analyze lib test` exits 0 but reports 212 info-level diagnostics in shared gallery/tokens and unrelated package surfaces; no task-owned diagnostics. Shared-file cleanup is outside collision-safe scope. |

  | Chip button semantics + 48dp | PASS — live + widget test |
- **Tests or validation commands** (fresh reconciliation 2026-08-24):
  ```text
  cd packages/warp_prism_ui

  dart analyze lib/src/organisms/status_ticker test/organisms/status_ticker
  # → No issues found! (exit 0)

  dart format --output=none --set-exit-if-changed \
    lib/src/organisms/status_ticker test/organisms/status_ticker
  # → Formatted 3 files (0 changed) (exit 0)

  flutter test test/organisms/status_ticker/ --concurrency=1 --no-pub
  # → All tests passed (14) (exit 0)

  dart run test/boundaries/boundary_test.dart
  # → Boundary harness: 7/7 PASS, 0 FAIL, 0 violation(s) (exit 0)
  ```
- **Reconciliation summary (2026-08-24)**:
   - Scoped analyzer clean: 0 issues on `status_ticker` files.
   - Scoped format clean: 0 changed on `status_ticker` files.
   - Unit tests: 14/14 PASS.
   - Boundary harness: 7/7 PASS.
   - Package analyzer note: package-wide `dart analyze lib test` exits 0 but reports 212 info-level diagnostics, primarily in shared `design_system_gallery_sections.dart`, tokens, and unrelated package surfaces. Those files are forbidden to touch under parallel worker collision policy; this is an external/shared-surface blocker, not a status-ticker defect. Task-scoped organism analyzer is 100% clean. Zero lane move executed per policy.

- **Local changelog entry**:
  - Original: `docs/changelog/2026-07-11-task-1508-status-ticker-organism.md`
  - Path-to-100: `docs/changelog/2026-07-18-task-1508-status-ticker-path-to-100.md`
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
- **Score**: `96/100`
- **Verdict**: `HELD_IN_REVIEW_PATH_TO_100`
- **Full report**: `docs/reports/review/1508-status-ticker-independent-rereview-2026-08-23.md`
- **Lane outcome**: stays in `docs/tasks/03-review/` (>=90; no lane move)
- **Live proof**: scoped analyzer PASS; scoped format PASS; status ticker functional tests PASS; combined EPIC-15 organism tests 70/70; gallery 23/23; boundaries 7/7
- **Stale evidence**: package `dart analyze lib test` reports 218 infos, contradicting prior `No issues found` claim

#### Current Open Blockers

- None functional. Evidence-quality residual: package analyzer Completion Evidence is stale (218 infos).

#### Path-to-100 Summary

1. Reconcile the package-wide analyzer gate or obtain a governance-approved scoped-gate exception.
2. Refresh Completion Evidence to stop claiming a clean package analyzer while 218 infos remain.
3. Re-run exact package/scoped analyzer, format, tests, gallery, and boundary commands.

### Previous Reports

- `docs/reports/review/formal-2026-07-18-task-1508.md` — prior formal 100 claim (not reproducible package analyzer claim)
- `docs/reports/review/1508-status-ticker-independent-rereview-2026-08-23.md` — current independent report

### Previous Reports (historical)

| Date | Score | Verdict | Report |
| --- | --- | --- | --- |
| 2026-07-11 | 95 | HELD_IN_REVIEW_PATH_TO_100 | `docs/reports/review-wave-2026-07-11/task-1508-independent-review.md` |
| 2026-07-16 | 84 | HELD_IN_REVIEW_RESUBMIT | `docs/reports/review/1508-status-ticker-review-2026-07-16.md` |
| 2026-07-18 | 100 | ACCEPTED_100 | `docs/reports/review/expert-2026-07-18-task-1508.md` |
| 2026-07-18 | 100 | ACCEPTED_100 | `docs/reports/review/formal-2026-07-18-task-1508.md` |


## Review/Fix Ledger — 2026-08-24 Wave 2 (BUILDER_CONTEXT; parent `builders`)

- **Engineer session/task ID**: `ses_fce34ef94ffeNzNsPSN2UEs8j1`
- **Execution outcome**: drain-drift reconciliation + fresh gates + self-close score-only PASS
- **Independent review**: `docs/reports/review/20260824-epic15-organisms-builders-independent-review.md` — 98/100, APPROVED_PATH100/PASS
- **Lane outcome**: parent-authorized move `02-doing → 03-review` confirmed; shared analyzer residual documented as external blocker

### Independent BUILDER_CONTEXT Review — 2026-08-24

- **Score / verdict**: `98/100` — `APPROVED_PATH100` / `PASS`
- **Report**: `docs/reports/review/20260824-epic15-organisms-builders-independent-review.md`
- **Fresh proof**: scoped analyzer clean; formatter 3/3 files 0 changed; organism tests 14/14; gallery 23/23; boundary 7/7.
- **External blocker**: package analyzer exits 0 with 212 info-level diagnostics in shared/unrelated surfaces; no task-owned diagnostics. This is explicitly documented and accepted for this collision-constrained fixture/gallery scope, with shared-owner cleanup as residual path-to-100.
