# Task 1507: PrismTimeMachineScrubber Organism

> **Review State**: `Ready For Review`
> **Priority**: 🔴 P0
> **Type**: `feature`
> **Origin**: EPIC-15 (`docs/tasks/00-planning/EPIC-15-warp-prism-ads-organism-expansion-from-reference-harvest.md`) + harvest reports `docs/reports/ads-organism-harvest-unified-2026-07-10.md`, `docs/reports/ads-organism-harvest-shadowbroker-2026-07-10.md`, `docs/reports/ads-organism-harvest-osiris-2026-07-10.md`
> **Blocks**: Task 1519
> **Depends on**: Task 1500

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1507` plus optional slug for
> dependencies, blockers, review ledgers, reports, and architecture references.
> Lanes such as `02-doing` and `03-review` are mutable status, not identity.

---

## Objective

Implement `PrismTimeMachineScrubber` with density histogram, playhead/scrubber, and basic playback controls over fixture time series. Compose alongside `DSTimeline` event lists — do not replace them.

## Background Context

### Source origin (EPIC-15)

| Field | Value |
| --- | --- |
| **Proposed public name** | `PrismTimeMachineScrubber` |
| **Internal implementation (preferred)** | `DSTimeMachineScrubber` + `typedef PrismTimeMachineScrubber = DSTimeMachineScrubber` in `prism_aliases.dart` (match existing ADS pattern) |
| **Harvest organism ID** | `O-06` |
| **ShadowBroker origin** | `TimelineScrubber.tsx` + `TimelinePanel.tsx` density + playback |
| **Osiris origin** | Weaker peer — time UX secondary; harvest scrubber from SB primarily |
| **Wave** | **D** |
| **Action type** | `NEW` |
| **Product consumers (later)** | History + Map time filtering; pairs with existing `DSTimeline` list (do not replace) |
| **ADS-first rule** | Gallery + fixtures only — **no** Observatory product route rewrite required for exit |

### What already exists

- `DSTimeline` event list organism.
- `DSTimelineMarker` molecule.
- History surface product code (integration optional).

### What is missing or broken

- No density-histogram + playback scrubber organism.
- No fixture time-machine gallery demo.

### False-gap notes (do not re-implement)

- Do **not** clone `DSShell` / `DSSidebar` / `DSTopbar` as a second app shell — HUD workspace is an **additional** layout class over a stage slot.
- Do **not** port MapLibre, react-map-gl, force-graph JS, xterm.js, or reference megafiles.
- Do **not** invent domain one-off panels (Shodan/SCM/radio) — prefer generic slots + `PrismConnectorPanel` where applicable.
- Compose existing organisms (`DSDetailInspector`, `DSGraphCanvas`, `DSTimeline`, `DSCommandPalette`, toast system, tab bar, split pane) rather than forking them.

### Composition notes (molecules/atoms may derive later)

- Density histogram bar
- Transport control cluster
- Playhead handle

These molecules are **not** required deliverables of this task; implement inside the organism first, extract only if reuse is proven.

---

## Test Requirements

- MUST render density buckets from fixture series.
- MUST move playhead via scrub and optional play/pause.
- MUST emit range/playhead change callbacks.
- Widget tests: scrub, play/pause, empty series, min/max bounds.
- A11y labels on transport controls.
- Gallery fixture with mock density data.

---

## Exit Conditions

- [x] `PrismTimeMachineScrubber` exported.
- [x] Tests + gallery PASS.
- [x] Analyze + scoped test PASS.
- [x] Docs note pairing with `DSTimeline` (list).
- [x] Local changelog entry added under `docs/changelog/` (or project changelog engine path used by current Warp Prism closeout).
- [x] Completion Evidence is filled before review handoff.
- [x] After barrel/alias changes, `melos run test-boundaries` remains **6/6 PASS** (run from monorepo root; if melos unavailable, run package boundary suite under `packages/warp_prism_ui/test/boundaries/` and record exact command).

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: read `docs/tasks/00-planning/EPIC-15-warp-prism-ads-organism-expansion-from-reference-harvest.md`, `docs/reports/ads-organism-harvest-unified-2026-07-10.md`, `docs/reports/ads-organism-harvest-shadowbroker-2026-07-10.md`, `docs/reports/ads-organism-harvest-osiris-2026-07-10.md`, `packages/warp_prism_ui/lib/src/organisms/organisms.dart`, `packages/warp_prism_ui/lib/src/prism_aliases.dart`, `packages/warp_prism_ui/lib/warp_prism_ui.dart`, `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart`, `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_registry.dart`, `packages/warp_prism_ui/lib/src/atoms/ds_glass_panel.dart`, `packages/warp_prism_ui/lib/src/tokens/ds_colors.dart`, `packages/warp_prism_ui/lib/src/tokens/ds_spacing.dart`.
- [x] Define time series / bucket model.
- [x] Implement histogram + scrubber + transport.
- [x] Dartdoc pairing guidance with `DSTimeline`.
- [x] Tests + gallery + exports.
- [x] **Simplicity pass**: remove unnecessary complexity introduced by this task; keep fixture-first contracts; no product route coupling.
- [x] **Regression verification**: run the validation commands listed below and paste outputs into Completion Evidence.

### Where

| File | Purpose |
| --- | --- |
| `packages/warp_prism_ui/lib/src/organisms/time_machine_scrubber/` | Create — module |
| `packages/warp_prism_ui/lib/src/organisms/time_machine_scrubber/ds_time_machine_scrubber.dart` | Create — implementation |
| `packages/warp_prism_ui/lib/src/organisms/ds_timeline.dart` | Read — compose/pair, do not fork |
| `packages/warp_prism_ui/lib/src/organisms/organisms.dart` | Modify — export |
| `packages/warp_prism_ui/lib/src/prism_aliases.dart` | Modify — alias |
| `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` | Modify — gallery |
| `packages/warp_prism_ui/test/organisms/time_machine_scrubber/` | Create — tests |

### How

1. Build scrubber from SB harvest behaviour, tokenized.
2. Keep playback simple (timer-based) with fixtures.
3. Export/test/gallery.

### Why

Time density + playback is missing relative to event list timeline; Map/History need both.

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


---

## Validation Commands

```bash
# From packages/warp_prism_ui (preferred scoped package gates)
cd packages/warp_prism_ui
dart analyze lib test
flutter test test/organisms/
# Prefer organism-scoped path when present, e.g.:
# flutter test test/organisms/time_machine_scrubber/
# flutter test test/organisms/*time_machine_scrubber*

# Public API / boundary harness (must stay 6/6 after alias/barrel work)
cd ../..
melos run test-boundaries
```


If Flutter tooling is unavailable in the execution environment, record the exact
tooling failure and do not claim those checks passed.

---

## Completion Evidence

- **Files created/modified**:
  - Created `packages/warp_prism_ui/lib/src/organisms/time_machine_scrubber/ds_time_machine_scrubber.dart`
  - Created `packages/warp_prism_ui/lib/src/organisms/time_machine_scrubber/time_machine_scrubber.dart`
  - Created `packages/warp_prism_ui/test/organisms/time_machine_scrubber/time_machine_scrubber_test.dart`
  - Modified `packages/warp_prism_ui/lib/src/organisms/organisms.dart` (append-only export)
  - Modified `packages/warp_prism_ui/lib/src/prism_aliases.dart` (import + typedefs + pairing dartdoc)
  - Modified `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` (minimal case + fixture demo)
  - Created `docs/changelog/2026-07-11-task-1507-time-machine-scrubber-organism.md`
  - Created `docs/changelog/2026-07-18-task-1507-path-to-100-format-gate.md`
  - Path-to-100 (2026-07-18): format gate re-proved clean on task surface; no implementation churn required
- **Public API name verified**: `typedef PrismTimeMachineScrubber = DSTimeMachineScrubber` (+ `PrismTimeDensityBucket`, `PrismTimeDensitySeverity`) via `package:warp_prism_ui/warp_prism_ui.dart` → `src/prism_aliases.dart`; organisms barrel exports implementation. Dartdoc notes pairing with `PrismTimeline` / `DSTimeline` (list ≠ scrubber).
- **Tests or validation commands** (fresh reconciliation 2026-08-24):
  ```text
  cd packages/warp_prism_ui

  dart format --output=none --set-exit-if-changed \
    lib/src/organisms/time_machine_scrubber \
    test/organisms/time_machine_scrubber
  # exit 0 — Formatted 3 files (0 changed)

  dart analyze lib/src/organisms/time_machine_scrubber \
    test/organisms/time_machine_scrubber
  # exit 0 — No issues found!

  flutter test test/organisms/time_machine_scrubber/ --concurrency=1 --no-pub
  # exit 0 — All tests passed! (11)
  ```
- **Boundary harness**:
  ```text
  cd packages/warp_prism_ui && dart run test/boundaries/boundary_test.dart
  # exit 0 — Boundary harness: 7/7 PASS, 0 FAIL, 0 violation(s)
  ```
  - **Reconciliation summary (2026-08-24)**:
   - Formatted `ds_time_machine_scrubber.dart` and `time_machine_scrubber_test.dart` -> format check clean (0 changed).
   - Added direct keyboard slider semantics test `slider semantics handle increase and decrease actions` -> 11/11 tests pass.
   - All historical findings RESOLVED. Builder self-review performed no lane move; parent-authorized promotion is recorded in the independent review report.

- **Local changelog entry**:
  - `docs/changelog/2026-07-11-task-1507-time-machine-scrubber-organism.md`
  - `docs/changelog/2026-07-18-task-1507-path-to-100-format-gate.md`
- **Agent-wiki / docs institutionalization**: N/A
- **Executor**: builders (engineer worker)
- **Completion date**: 2026-08-24 (reconciliation pass)
- **Lane note**: Promoted to `03-review/` by parent-authorized independent BUILDER_CONTEXT review; no `04-completed` move.

---

## Review Ledger

> [!IMPORTANT]
> Before path-to-100 work, read the latest full report and all reports listed
> under Previous Reports. Persistent findings and regression guards are part of
> the acceptance contract.

### Path-to-100 Remediation (2026-07-18)

- **Executor**: gt-flutter-engineer (builders)
- **Addressed**:
  1. **Format gate** — task surface + shared barrels/gallery re-checked with
     `dart format --output=none --set-exit-if-changed`; **0 changed**, exit 0.
- **Re-prove**: analyze PASS; organism tests **10/10 PASS**; boundaries **7/7 PASS**;
  format **PASS**.
- **Open blockers after remediation**: none for this task surface.

### Latest Review

- **Date**: 2026-07-18
- **Reviewer profile**: `gt-flutter-code-reviewer` (builders; flutter-harness + code-quality-harness + design-system-harness)
- **Score**: `100/100`
- **Verdict**: `ACCEPTED_100`
- **Full report**: `docs/reports/review/formal-2026-07-18-task-1507.md`
- **Lane outcome**: **moved to `03-review/`** (formal gate; S=100; no git)
- **Task reference**: Task 1507 (`warp-prism-time-machine-scrubber-organism`)
- **Live prove (this review)**: package analyze clean; format 0 changed; organism tests **10/10 PASS**; boundaries **7/7 PASS**

#### Current Open Blockers

- None

#### Path-to-100 Summary

1. ~~Format gate~~ DONE (builder + expert re-prove)
2. ~~All axioms + exit conditions~~ DONE — formal score 100

### Independent adversarial gatekeeper re-review (2026-07-18)

- **Reviewer profile**: `reviewers` (parent agentID=reviewers)
- **Score**: `95/100`
- **Verdict**: `PASS WITH NOTES`
- **Full report**: `docs/reports/review/1507-time-machine-scrubber-independent-gatekeeper-rereview-2026-07-18.md`
- **Fresh live proof**: scoped analyzer clean; organism pack **45/45 PASS** (10 Task 1507); gallery **23/23 PASS**; boundaries **7/7 PASS** direct and via `dart run melos run test-boundaries`.
- **Finding**: required non-mutating format probe is red (`Formatted 15 files (4 changed)`, exit 1), including `ds_time_machine_scrubber.dart` and shared alias/gallery. Slider/transport semantics and 48dp targets are present; direct keyboard slider proof is absent.
- **Routing**: stays in `docs/tasks/03-review/` (score >=90).

### Previous Reports

| Date | Score | Verdict | Report |
| --- | --- | --- | --- |
| 2026-07-11 | 95 | HELD_IN_REVIEW_PATH_TO_100 | `docs/reports/review-wave-2026-07-11/task-1507-independent-review.md` |
| 2026-07-16 | 88 | REJECT | `docs/reports/review/1507-time-machine-scrubber-review-2026-07-16.md` |
| 2026-07-18 | 100 | ACCEPTED_100 | `docs/reports/review/expert-2026-07-18-task-1507.md` |
| 2026-07-18 | 100 | ACCEPTED_100 | `docs/reports/review/formal-2026-07-18-task-1507.md` |

### Regression Guards

- Re-run organism-scoped `flutter test test/organisms/<module>/` after any organism/alias/gallery edit.
- Re-run `dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart` after public DS/Prism surface changes — must stay **7/7 PASS**.
- Consumers must import `package:warp_prism_ui/warp_prism_ui.dart` (Prism* aliases); do not expose raw DS* via public barrel.
- Re-run `dart format --output=none --set-exit-if-changed` on task surface after any edit.


## Review/Fix Ledger — 2026-08-24 Wave 2 (BUILDER_CONTEXT; parent `builders`)

- **Engineer session/task ID**: `ses_fce34ef94ffeNzNsPSN2UEs8j1`
- **Execution outcome**: drain-drift reconciliation + fresh gates + self-close score-only PASS
- **Independent review**: `docs/reports/review/20260824-epic15-organisms-builders-independent-review.md` — 100/100, ACCEPT/PASS
- **Lane outcome**: parent-authorized move `02-doing → 03-review` confirmed

### Independent BUILDER_CONTEXT Review — 2026-08-24

- **Score / verdict**: `100/100` — `ACCEPT` / `PASS`
- **Report**: `docs/reports/review/20260824-epic15-organisms-builders-independent-review.md`
- **Fresh proof**: scoped analyzer clean; formatter 3/3 files 0 changed; organism tests 11/11; gallery 23/23; boundary 7/7.
- **Lineage**: prior format and slider-semantics evidence gaps `RESOLVED`; no open task-owned finding.
