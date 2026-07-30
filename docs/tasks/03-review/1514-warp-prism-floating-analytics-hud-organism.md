# Task 1514: PrismFloatingAnalyticsHud Organism

> **Status**: `[x]` In Review — formal ACCEPTED_100 (2026-07-18 path-to-100)
> **Review State**: `In 03-review`
> **Priority**: 🟡 P1
> **Type**: `feature`
> **Origin**: EPIC-15 (`docs/tasks/00-planning/EPIC-15-warp-prism-ads-organism-expansion-from-reference-harvest.md`) + harvest reports `docs/reports/ads-organism-harvest-unified-2026-07-10.md`, `docs/reports/ads-organism-harvest-shadowbroker-2026-07-10.md`, `docs/reports/ads-organism-harvest-osiris-2026-07-10.md`
> **Blocks**: Task 1519
> **Depends on**: Task 1500
>
> **Soft dependency**: Task 1501 preferred as overlay host; floating HUD MUST demo over a plain
> colored stage fixture if Map HUD is incomplete.

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1514` plus optional slug for
> dependencies, blockers, review ledgers, reports, and architecture references.
> Lanes such as `02-doing` and `03-review` are mutable status, not identity.

---

## Objective

Implement `PrismFloatingAnalyticsHud`: draggable, minimizable multi-section analytics overlay with fixture metrics sections. Desktop pointer interactions first.

## Background Context

### Source origin (EPIC-15)

| Field | Value |
| --- | --- |
| **Proposed public name** | `PrismFloatingAnalyticsHud` |
| **Internal implementation (preferred)** | `DSFloatingAnalyticsHud` + `typedef PrismFloatingAnalyticsHud = DSFloatingAnalyticsHud` in `prism_aliases.dart` (match existing ADS pattern) |
| **Harvest organism ID** | `O-09` |
| **ShadowBroker origin** | `GtAnalyticsHud.tsx` draggable minimizable multi-section overlay |
| **Osiris origin** | N/A (SB-primary) |
| **Wave** | **G** |
| **Action type** | `NEW` |
| **Product consumers (later)** | Map/CyberCore floating metrics overlay |
| **ADS-first rule** | Gallery + fixtures only — **no** Observatory product route rewrite required for exit |

### What already exists

- Metric tiles, sparklines, glass panels.
- HUD workspace host.

### What is missing or broken

- No draggable multi-section floating analytics HUD organism.

### False-gap notes (do not re-implement)

- Do **not** clone `DSShell` / `DSSidebar` / `DSTopbar` as a second app shell — HUD workspace is an **additional** layout class over a stage slot.
- Do **not** port MapLibre, react-map-gl, force-graph JS, xterm.js, or reference megafiles.
- Do **not** invent domain one-off panels (Shodan/SCM/radio) — prefer generic slots + `PrismConnectorPanel` where applicable.
- Compose existing organisms (`DSDetailInspector`, `DSGraphCanvas`, `DSTimeline`, `DSCommandPalette`, toast system, tab bar, split pane) rather than forking them.

### Composition notes (molecules/atoms may derive later)

- Draggable chrome handle
- Minimize control
- Analytics section block

These molecules are **not** required deliverables of this task; implement inside the organism first, extract only if reuse is proven.

---

## Test Requirements

- MUST support minimize/expand.
- MUST support drag reposition within bounds (widget-testable via controller or gesture).
- MUST host multi-section content from fixtures.
- Widget tests: minimize, expand, section render, close if present.
- A11y labels on minimize/expand/close.
- Gallery fixture overlay.

---

## Exit Conditions

- [x] `PrismFloatingAnalyticsHud` exported.
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
- [x] Define section model.
- [x] Implement floating chrome with drag + minimize.
- [x] Fixture metrics sections.
- [x] Tests + gallery + exports.
- [x] **Simplicity pass**: remove unnecessary complexity introduced by this task; keep fixture-first contracts; no product route coupling.
- [x] **Regression verification**: run the validation commands listed below and paste outputs into Completion Evidence.

### Where

| File | Purpose |
| --- | --- |
| `packages/warp_prism_ui/lib/src/organisms/floating_analytics_hud/` | Create — module |
| `packages/warp_prism_ui/lib/src/organisms/floating_analytics_hud/ds_floating_analytics_hud.dart` | Create — implementation |
| `packages/warp_prism_ui/lib/src/molecules/ds_metric_tile.dart` | Read — compose |
| `packages/warp_prism_ui/lib/src/organisms/organisms.dart` | Modify — export |
| `packages/warp_prism_ui/lib/src/prism_aliases.dart` | Modify — alias |
| `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` | Modify — gallery |
| `packages/warp_prism_ui/test/organisms/floating_analytics_hud/` | Create — tests |

### How

1. Start with positioned glass panel + minimize; add drag.
2. Compose metric tiles.
3. Export/test/gallery.

### Why

Floating analytics HUD is a proven SB ops affordance for dense map workspaces.

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
# flutter test test/organisms/floating_analytics_hud/
# flutter test test/organisms/*floating_analytics_hud*

# Public API / boundary harness (must stay 6/6 after alias/barrel work)
cd ../..
melos run test-boundaries
```


If Flutter tooling is unavailable in the execution environment, record the exact
tooling failure and do not claim those checks passed.

---

## Completion Evidence

- **Files created/modified** (resubmit 2026-07-18 path-to-100):
  - `packages/warp_prism_ui/lib/src/organisms/floating_analytics_hud/ds_floating_analytics_hud.dart` — HUD widget (~560 LOC after split)
  - `packages/warp_prism_ui/lib/src/organisms/floating_analytics_hud/ds_floating_analytics_hud_controller.dart` — public-field controller (lint-clean)
  - `packages/warp_prism_ui/lib/src/organisms/floating_analytics_hud/ds_floating_analytics_models.dart` — section/metric models
  - `packages/warp_prism_ui/lib/src/organisms/floating_analytics_hud/ds_floating_analytics_fixtures.dart` — fixture metrics
  - `packages/warp_prism_ui/lib/src/organisms/floating_analytics_hud/floating_analytics_hud.dart` — module barrel
  - `packages/warp_prism_ui/test/organisms/floating_analytics_hud/floating_analytics_hud_test.dart` — 13 tests (48dp + drag semantics)
  - Prior land: organisms.dart export, prism aliases, gallery demo
- **Public API name verified**: `PrismFloatingAnalyticsHud` via `typedef PrismFloatingAnalyticsHud = DSFloatingAnalyticsHud` in `prism_aliases.dart`
- **Resubmit blockers closed** (review 2026-07-16 score 82):
  1. Task-scoped analyzer: **0** info (`prefer_initializing_formals` fixed via public fields)
  2. Drag handle / minimize / close hit targets ≥ 48dp
  3. Title drag exposes same `Drag analytics HUD` semantic label
  4. Widget tests: 48dp header controls + draggable semantics
  5. Megafile split: models + controller + fixtures + widget
- **Tests or validation commands** (pack gate 2026-07-18T05:25Z):
  ```text
  cd packages/warp_prism_ui
  dart analyze lib/src/organisms/floating_analytics_hud test/organisms/floating_analytics_hud
  # → No issues found!  (exit 0)

  dart format --output=none --set-exit-if-changed \
    lib/src/organisms/floating_analytics_hud test/organisms/floating_analytics_hud
  # → Formatted 0 changed  (exit 0)

  flutter test test/organisms/floating_analytics_hud/ --concurrency=1
  # → All tests passed! (13)  (exit 0)

  dart analyze lib test
  # → No issues found!  (exit 0)

  dart run test/boundaries/boundary_test.dart
  # → Boundary harness: 7/7 PASS  (exit 0)
  ```
- **Boundary harness**: 7/7 PASS (`dart run test/boundaries/boundary_test.dart` from `packages/warp_prism_ui`)
- **Local changelog entry**: `docs/changelog/2026-07-18-task-1514-floating-analytics-hud-resubmit.md` (+ prior `2026-07-15-task1514-floating-analytics-hud-organism.md`)
- **Agent-wiki / docs institutionalization**: N/A
- **Executor**: gt-flutter-engineer (under builders)
- **Completion date**: 2026-07-18
- **Lane note**: Ready For Review — remains in `02-doing/` per builder instruction (no promote / no move to `03-review`)

---

## Review Ledger

> [!IMPORTANT]
> Before path-to-100 work, read the latest full report and all reports listed
> under Previous Reports. Persistent findings and regression guards are part of
> the acceptance contract.

### Latest Review

- **Date**: 2026-07-18
- **Reviewer profile**: `gt-flutter-code-reviewer` (formal path-to-100 under builders)
- **Score**: `100/100`
- **Verdict**: `ACCEPTED_100`
- **Full report**: `docs/reports/review/formal-2026-07-18-task-1514.md`
- **Lane outcome**: remains `03-review/`
- **Task reference**: Task 1514 (`1514-warp-prism-floating-analytics-hud-organism`)

#### Current Open Blockers

- none

#### Prior Open Blockers (closed this path-to-100)

- ~~I1 extract header/sections from 564-LOC host~~ → `ds_floating_analytics_hud_chrome.dart` (host 357 LOC); 13/13 tests; analyze clean

### Previous Reports

| Date | Score | Verdict | Report |
| --- | ---: | --- | --- |
| 2026-07-16 | 82 | HELD_IN_REVIEW_RESUBMIT | `docs/reports/review/1514-floating-analytics-hud-review-2026-07-16.md` |
| 2026-07-18 | 100 | ACCEPTED_100 (expert) | `docs/reports/review/expert-2026-07-18-task-1514.md` |
| 2026-07-18 | 99→100 | ACCEPTED_100 (formal path-to-100) | `docs/reports/review/formal-2026-07-18-task-1514.md` |

#### Prior Open Blockers (closed)

- ~~3 prefer_initializing_formals infos~~ → controller public fields
- ~~36dp minimize/close / small drag handle~~ → 48dp constraints
- ~~Title drag unlabeled~~ → drag semantic label
- ~~919-line megafile~~ → models/controller/fixtures/widget split
- ~~Host size mutated during build~~ → post-frame capture + live RenderBox on pan (expert 2026-07-18)

#### Regression Guards

- Header drag/minimize/close ≥ 48
- Drag semantic label on handle + title
- No mid-build `_hostSize` assignment
