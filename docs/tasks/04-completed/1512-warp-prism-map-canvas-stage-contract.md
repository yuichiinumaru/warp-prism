# Task 1512: PrismMapCanvasStage Selection/Layer Contract

> **Review State**: `In 03-review`
> **Priority**: 🟡 P1
> **Type**: `feature`
> **Origin**: EPIC-15 (`docs/tasks/00-planning/EPIC-15-warp-prism-ads-organism-expansion-from-reference-harvest.md`) + harvest reports `docs/reports/ads-organism-harvest-unified-2026-07-10.md`, `docs/reports/ads-organism-harvest-shadowbroker-2026-07-10.md`, `docs/reports/ads-organism-harvest-osiris-2026-07-10.md`
> **Blocks**: Task 1513, Task 1519
> **Depends on**: Task 1500
>
> **Soft dependency**: Task 1501 preferred when demonstrating stage-inside-HUD; the **contract
> types + fake stage** MUST be unit-testable without a full HUD workspace.

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1512` plus optional slug for
> dependencies, blockers, review ledgers, reports, and architecture references.
> Lanes such as `02-doing` and `03-review` are mutable status, not identity.

---

## Objective

Define and implement `PrismMapCanvasStage` as a **contract organism**: layer registry, selection bus, popup factory slots, and a non-MapLibre placeholder stage renderer. Explicitly forbid shipping a MapLibre/react-map-gl port.

## Background Context

### Source origin (EPIC-15)

| Field | Value |
| --- | --- |
| **Proposed public name** | `PrismMapCanvasStage` |
| **Internal implementation (preferred)** | `DSMapCanvasStage` + `typedef PrismMapCanvasStage = DSMapCanvasStage` in `prism_aliases.dart` (match existing ADS pattern) |
| **Harvest organism ID** | `O-17` |
| **ShadowBroker origin** | `MaplibreViewer` composition contracts (layers, selection, popups) — **not** engine port |
| **Osiris origin** | `OsirisMap.tsx` composition contracts — **not** MapLibre port |
| **Wave** | **F** |
| **Action type** | `NEW` |
| **Product consumers (later)** | Contract-only stage host for map consumers; placeholder renderer allowed |
| **ADS-first rule** | Gallery + fixtures only — **no** Observatory product route rewrite required for exit |

### What already exists

- `PrismMapHudWorkspace` stage slot.
- `DSGraphCanvas` for graph (different domain).
- Layer control panel (Task 1503) as peer producer of layer state.

### What is missing or broken

- No formal stage contract types for selection/layer/popup composition.
- No placeholder map stage organism for gallery/CyberCore without engine.

### False-gap notes (do not re-implement)

- Do **not** clone `DSShell` / `DSSidebar` / `DSTopbar` as a second app shell — HUD workspace is an **additional** layout class over a stage slot.
- Do **not** port MapLibre, react-map-gl, force-graph JS, xterm.js, or reference megafiles.
- Do **not** invent domain one-off panels (Shodan/SCM/radio) — prefer generic slots + `PrismConnectorPanel` where applicable.
- Compose existing organisms (`DSDetailInspector`, `DSGraphCanvas`, `DSTimeline`, `DSCommandPalette`, toast system, tab bar, split pane) rather than forking them.

### Composition notes (molecules/atoms may derive later)

- Layer registry entry
- Selection bus event
- Popup host frame

These molecules are **not** required deliverables of this task; implement inside the organism first, extract only if reuse is proven.

---

## Test Requirements

- MUST expose layer registry API (add/remove/toggle visibility) via controller or callbacks.
- MUST emit selection events on fixture feature tap.
- MUST host popup factory for selected feature.
- Widget tests: register layer, select feature, clear selection, popup shown.
- A11y: stage labeled; interactive fixture markers labeled.
- Package MUST NOT depend on maplibre or webview map engines for this task.

---

## Exit Conditions

- [x] `PrismMapCanvasStage` + supporting types exported.
- [x] Tests + gallery placeholder stage PASS.
- [x] pubspec has no new MapLibre deps.
- [x] Analyze + scoped test PASS.
- [x] Local changelog entry added under `docs/changelog/` (or project changelog engine path used by current Warp Prism closeout).
- [x] Completion Evidence is filled before review handoff.
- [x] After barrel/alias changes, `melos run test-boundaries` remains **6/6 PASS** (run from monorepo root; if melos unavailable, run package boundary suite under `packages/warp_prism_ui/test/boundaries/` and record exact command).

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: read `docs/tasks/00-planning/EPIC-15-warp-prism-ads-organism-expansion-from-reference-harvest.md`, `docs/reports/ads-organism-harvest-unified-2026-07-10.md`, `docs/reports/ads-organism-harvest-shadowbroker-2026-07-10.md`, `docs/reports/ads-organism-harvest-osiris-2026-07-10.md`, `packages/warp_prism_ui/lib/src/organisms/organisms.dart`, `packages/warp_prism_ui/lib/src/prism_aliases.dart`, `packages/warp_prism_ui/lib/warp_prism_ui.dart`, `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart`, `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_registry.dart`, `packages/warp_prism_ui/lib/src/atoms/ds_glass_panel.dart`, `packages/warp_prism_ui/lib/src/tokens/ds_colors.dart`, `packages/warp_prism_ui/lib/src/tokens/ds_spacing.dart`.
- [x] Design layer/selection/popup contracts as Dart types.
- [x] Implement placeholder canvas (CustomPainter/stack) with fixture features.
- [x] Wire selection bus + popup overlay slot.
- [x] Tests + gallery + exports; document non-port constraint in dartdoc.
- [x] **Simplicity pass**: remove unnecessary complexity introduced by this task; keep fixture-first contracts; no product route coupling.
- [x] **Regression verification**: run the validation commands listed below and paste outputs into Completion Evidence.

### Where

| File | Purpose |
| --- | --- |
| `packages/warp_prism_ui/lib/src/organisms/map_canvas_stage/` | Create — contract + placeholder |
| `packages/warp_prism_ui/lib/src/organisms/map_canvas_stage/ds_map_canvas_stage.dart` | Create — implementation |
| `packages/warp_prism_ui/lib/src/organisms/map_canvas_stage/map_stage_contracts.dart` | Create — types |
| `packages/warp_prism_ui/lib/src/organisms/organisms.dart` | Modify — export |
| `packages/warp_prism_ui/lib/src/prism_aliases.dart` | Modify — alias |
| `packages/warp_prism_ui/pubspec.yaml` | Read — verify no MapLibre dep added |
| `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` | Modify — gallery |
| `packages/warp_prism_ui/test/organisms/map_canvas_stage/` | Create — tests |

### How

1. Write contracts first.
2. Placeholder stage second.
3. Integrate selection/popup.
4. Export/test/gallery.

### Why

Without a stage contract, map HUDs cannot share selection/layer language when real engines arrive later.

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

> [!CAUTION]
> **No MapLibre / react-map-gl / force-graph JS port.** Placeholder only. Real engine adapters are out of EPIC-15 scope.

---

## Validation Commands

```bash
# From packages/warp_prism_ui (preferred scoped package gates)
cd packages/warp_prism_ui
dart analyze lib test
flutter test test/organisms/
# Prefer organism-scoped path when present, e.g.:
# flutter test test/organisms/map_canvas_stage/
# flutter test test/organisms/*map_canvas_stage*

# Public API / boundary harness (must stay 6/6 after alias/barrel work)
cd ../..
melos run test-boundaries
```


If Flutter tooling is unavailable in the execution environment, record the exact
tooling failure and do not claim those checks passed.

---

## Completion Evidence

- **Files created/modified** (resubmit 2026-07-18 path-to-100):
  - `packages/warp_prism_ui/lib/src/organisms/map_canvas_stage/ds_map_canvas_stage.dart` — slim host (~300 LOC)
  - `packages/warp_prism_ui/lib/src/organisms/map_canvas_stage/map_stage_placeholder_widgets.dart` — status strip, 48dp markers, popup dismiss, labeled background clear, grid painter
  - `packages/warp_prism_ui/lib/src/organisms/map_canvas_stage/ds_map_canvas_stage_controller.dart` — controller + fixtures
  - `packages/warp_prism_ui/lib/src/organisms/map_canvas_stage/map_stage_contracts.dart` — layer/selection/popup types
  - `packages/warp_prism_ui/lib/src/organisms/map_canvas_stage/map_canvas_stage.dart` — module barrel
  - `packages/warp_prism_ui/test/organisms/map_canvas_stage/map_canvas_stage_test.dart` — 13 tests (incl. 48dp + background semantics)
  - Prior land: organisms.dart export, prism aliases, gallery demo
- **Public API name verified**: `PrismMapCanvasStage` via `typedef PrismMapCanvasStage = DSMapCanvasStage` in `prism_aliases.dart`
- **No MapLibre**: `pubspec.yaml` has no maplibre/react-map-gl/webview map engines; dartdoc non-port constraint retained
- **Resubmit blockers closed** (review 2026-07-16 score 87):
  1. Feature markers / Clear / popup dismiss hit targets ≥ 48dp (`kMinInteractiveDimension`)
  2. Background clear: `Semantics(label: 'Clear map selection', button: true)`
  3. Megafile split: host + placeholder widgets + controller + contracts
  4. Format gate clean on module
- **Tests or validation commands** (reconciliation & path-to-100 closeout 2026-08-24):
  ```text
  cd packages/warp_prism_ui
  dart format --output=none --set-exit-if-changed \
    lib/src/organisms/map_canvas_stage test/organisms/map_canvas_stage
  # → Formatted 6 files (0 changed)  (exit 0)

  dart analyze lib/src/organisms/map_canvas_stage test/organisms/map_canvas_stage
  # → No issues found!  (exit 0)

  flutter test test/organisms/map_canvas_stage/ --concurrency=1 --no-pub
  # → All tests passed! (13)  (exit 0)

  dart analyze lib test
   # → 204 infos (pre-existing gallery/shared infos only; 0 errors/warnings)  (exit 0)

  dart run test/boundaries/boundary_test.dart
  # → Boundary harness: 7/7 PASS  (exit 0)
  ```
- **Boundary harness**: 7/7 PASS (`dart run test/boundaries/boundary_test.dart` from `packages/warp_prism_ui`)
- **Local changelog entry**: `docs/changelog/2026-07-18-task-1512-map-canvas-stage-resubmit.md` (+ prior `2026-07-15-task-1512-map-canvas-stage-contract.md`)
- **Agent-wiki / docs institutionalization**: N/A
- **Executor**: builder-engineer (builders lane worker)
- **Completion date**: 2026-08-24
 - **Lane note**: Reconciled and independently accepted — moved to `03-review/` under explicit parent authorization
- **Changelog Draft**:
  ```yaml
  task: 1512
  agent: builder-engineer
  project: warp-prism
  title: PrismMapCanvasStage path-to-100 reconciliation
  description: Formatted source, resolved const constructor info, verified 13/13 tests & 7/7 boundaries.
  summary: Map canvas stage path-to-100 reconciled and validated.
  verification: 13 tests + scoped analyze clean + 0 format drift + 7/7 boundaries
  ```

---

## Review Ledger

### Latest Review — EPIC-15 bundled independent BUILDER_CONTEXT review

- **Date**: 2026-08-24
- **Reviewer profile**: `builders` (independent BUILDER_CONTEXT reviewer)
- **Score**: `100/100`
- **Verdict**: `ACCEPTED_100`
- **Full report**: `docs/reports/review/20260824-epic15-independent-builder-review.md`
- **Lane outcome**: moved from `docs/tasks/02-doing/` to `docs/tasks/03-review/` under explicit parent authorization
- **Fresh proof**: scoped formatter/analyzer/tests PASS; full organism suite 671/671; gallery 22/22; package analyzer exit 0 with 204 pre-existing infos; final boundary spot-check 7/7
- **Residual**: none within the task surface; package analyzer count reconciled from stale 205 to fresh 204 in Completion Evidence

### Previous Review Ledger

> [!IMPORTANT]
> Before path-to-100 work, read the latest full report and all reports listed
> under Previous Reports. Persistent findings and regression guards are part of
> the acceptance contract.

### Latest Review

- **Date**: 2026-07-18
- **Reviewer profile**: `reviewers` (skeptical final gate)
- **Score**: `96/100`
- **Verdict**: `HELD_IN_REVIEW_PATH_TO_100`
- **Full report**: `docs/reports/review/1512-map-canvas-stage-final-gate-2026-07-18.md`
- **Lane outcome**: remains in `03-review/`
- **Task reference**: Task 1512 (`1512-warp-prism-map-canvas-stage-contract`)

#### Current Open Blockers

- `EVIDENCE_GAP-GALLERY`: the complete gallery test invocation timed out at 120s with Flutter tester SIGTERM/cleanup errors. Isolated footer, late EPIC-15 host-scroll, EPIC-15 builder, registry-title, and independent-builder tests all pass.

#### Path-to-100 Summary

- Resolve/document the full-gallery runtime budget without weakening targeted gallery proofs.

### Previous Reports

| Date | Score | Verdict | Report |
| --- | ---: | --- | --- |
| 2026-07-16 | 87 | HELD_IN_REVIEW_RESUBMIT | `docs/reports/review/1512-map-canvas-stage-contract-review-2026-07-16.md` |
| 2026-07-18 | 100 | ACCEPTED_100 (expert) | `docs/reports/review/expert-2026-07-18-task-1512.md` |
| 2026-07-18 | 100 | ACCEPTED_100 (formal) | `docs/reports/review/formal-2026-07-18-task-1512.md` |
| 2026-07-18 | 96 | HELD_IN_REVIEW_PATH_TO_100 (skeptical final gate) | `docs/reports/review/1512-map-canvas-stage-final-gate-2026-07-18.md` |

#### Prior Open Blockers (closed)

- ~~Touch targets below 48dp (markers/clear/dismiss)~~ → ConstrainedBox / hitSize 48
- ~~Background clear unlabeled~~ → Semantics + onTap
- ~~Mega-widget 854 LOC~~ → split into host + placeholder widgets + controller
- ~~Background clear always a button with no selection~~ → button only when `hasSelection` (expert 2026-07-18)

#### Regression Guards

- Marker/clear/dismiss size ≥ 48 in widget tests
- Background clear semantics: not button when idle; labeled button when selected


## Review/Fix Ledger — 2026-08-24 Wave 3 (BUILDER_CONTEXT; parent `builders`)

- **Engineer session/task ID**: `ses_fce10876affeTtHKJp2uFQZ2fw`
- **Execution outcome**: drain-drift reconciliation + fresh gates + self-close score-only PASS
- **Next routing**: independent BUILDER_CONTEXT re-review dispatched by parent


## Final Review Disposition

- **Verdict**: **PASS (reconciled from reviewer packet)** — W3a verification wave 2026-09-02: organism source + claimed API verified present; focused suite green (188 focused family tests; full organism suite +680); fixture-first held (no MapLibre/xterm/live-OSINT/clone paths); Prism aliases + barrel verified; boundary 15/15; analyzer 0E/0W. No defect named for this task by the reviewer. Score: family-green 95 (reconciled; per-task score not reviewer-emitted due to provider failure on the formalization follow-up — evidence packet authoritative).
- **Reviewer session**: W3a organisms wave 2026-09-02 (ses_f9cebe293ffewfceUI8tDwxZ9H — verification complete; formalization follow-up lost to provider failure; disposition reconciled centrally per drain plan §4).
