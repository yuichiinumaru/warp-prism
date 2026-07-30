# Task 1501: PrismMapHudWorkspace Organism

> **Status**: `[x]` Review Approved — independent review S=94 (held in 03-review; never 04-completed by this wave)
> **Review State**: `Review Approved`
> **Priority**: 🔴 P0
> **Type**: `feature`
> **Origin**: EPIC-15 (`docs/tasks/00-planning/EPIC-15-warp-prism-ads-organism-expansion-from-reference-harvest.md`) + harvest reports `docs/reports/ads-organism-harvest-unified-2026-07-10.md`, `docs/reports/ads-organism-harvest-shadowbroker-2026-07-10.md`, `docs/reports/ads-organism-harvest-osiris-2026-07-10.md`
> **Blocks**: Task 1503, Task 1509, Task 1512, Task 1514, Task 1516
> **Depends on**: Task 1500

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1501` plus optional slug for
> dependencies, blockers, review ledgers, reports, and architecture references.
> Lanes such as `02-doing` and `03-review` are mutable status, not identity.

---

## Objective

Implement `PrismMapHudWorkspace` — a desktop-first full-bleed **stage + multi-region HUD layout organism** (stage slot, left rail, right strip region, bottom chrome, optional top cluster, UI hide/restore) using existing glass tokens. This is **not** a `DSShell` clone and does not require Observatory route wiring.

## Background Context

### Source origin (EPIC-15)

| Field | Value |
| --- | --- |
| **Proposed public name** | `PrismMapHudWorkspace` |
| **Internal implementation (preferred)** | `DSMapHudWorkspace` + `typedef PrismMapHudWorkspace = DSMapHudWorkspace` in `prism_aliases.dart` (match existing ADS pattern) |
| **Harvest organism ID** | `O-01` |
| **ShadowBroker origin** | `frontend/src/app/page.tsx` dual-HUD composition (left/right/bottom chrome over map stage) |
| **Osiris origin** | `src/app/page.tsx` canvas HUD composition (full-bleed stage + floating panels) |
| **Wave** | **A** |
| **Action type** | `NEW` |
| **Product consumers (later)** | ADS gallery first; later Map/CyberCore consumers |
| **ADS-first rule** | Gallery + fixtures only — **no** Observatory product route rewrite required for exit |

### What already exists

- `DSShell` / `DSSidebar` / `DSTopbar` for classic app chrome.
- `DSGlassPanel` atom and spacing/color tokens for glass HUD chrome.
- Gallery organisms section pattern in `design_system_gallery_sections.dart`.
- Harvest composition model documented in unified + per-source reports.

### What is missing or broken

- No organism that models map-first multi-HUD regions with a pluggable stage child.
- No hide/restore UI chrome contract for dense ops desktops.
- No exclusive region controller shared with tool slideouts (pair with Task 1502).

### False-gap notes (do not re-implement)

- Do **not** clone `DSShell` / `DSSidebar` / `DSTopbar` as a second app shell — HUD workspace is an **additional** layout class over a stage slot.
- Do **not** port MapLibre, react-map-gl, force-graph JS, xterm.js, or reference megafiles.
- Do **not** invent domain one-off panels (Shodan/SCM/radio) — prefer generic slots + `PrismConnectorPanel` where applicable.
- Compose existing organisms (`DSDetailInspector`, `DSGraphCanvas`, `DSTimeline`, `DSCommandPalette`, toast system, tab bar, split pane) rather than forking them.

### Composition notes (molecules/atoms may derive later)

- HUD edge toggle control
- Collapsible glass chrome frame
- Exclusive panel controller (shared later with slideout)

These molecules are **not** required deliverables of this task; implement inside the organism first, extract only if reuse is proven.

---

## Test Requirements

- Widget MUST accept a required `stage` child and optional left/right/bottom/top HUD slots.
- Widget MUST support hide-all-HUD / restore chrome without disposing stage.
- Widget MUST stack HUD regions above the stage without stealing full-viewport navigation semantics from `DSShell`.
- Widget tests MUST cover: default regions visible, hide chrome, restore chrome, empty optional slots.
- Interactive chrome (hide/restore control) MUST have Semantics labels suitable for a11y.
- Gallery MUST show at least one fixture workspace with mock stage (colored box / placeholder map — **not** MapLibre).

---

## Exit Conditions

- [x] `packages/warp_prism_ui/lib/src/organisms/map_hud_workspace/` (or equivalent) implements the organism with public name `PrismMapHudWorkspace`.
- [x] `organisms.dart` exports the implementation; `prism_aliases.dart` exposes `PrismMapHudWorkspace`.
- [x] Widget tests exist under `packages/warp_prism_ui/test/organisms/` covering hide/restore and slots.
- [x] Minimal gallery case registered (section method or deferred ticket note pointing to Task 1519 with proof widget in test).
- [x] `dart analyze` clean on touched paths; scoped `flutter test` for the new suite PASS.
- [x] Local changelog entry added under `docs/changelog/` (or project changelog engine path used by current Warp Prism closeout).
- [x] Completion Evidence is filled before review handoff.
- [x] After barrel/alias changes, `melos run test-boundaries` remains **6/6 PASS** (run from monorepo root; if melos unavailable, run package boundary suite under `packages/warp_prism_ui/test/boundaries/` and record exact command).

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: read `docs/tasks/00-planning/EPIC-15-warp-prism-ads-organism-expansion-from-reference-harvest.md`, `docs/reports/ads-organism-harvest-unified-2026-07-10.md`, `docs/reports/ads-organism-harvest-shadowbroker-2026-07-10.md`, `docs/reports/ads-organism-harvest-osiris-2026-07-10.md`, `packages/warp_prism_ui/lib/src/organisms/organisms.dart`, `packages/warp_prism_ui/lib/src/prism_aliases.dart`, `packages/warp_prism_ui/lib/warp_prism_ui.dart`, `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart`, `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_registry.dart`, `packages/warp_prism_ui/lib/src/atoms/ds_glass_panel.dart`, `packages/warp_prism_ui/lib/src/tokens/ds_colors.dart`, `packages/warp_prism_ui/lib/src/tokens/ds_spacing.dart`, `packages/warp_prism_ui/lib/src/organisms/ds_shell.dart`, `packages/warp_prism_ui/lib/src/organisms/ds_sidebar.dart`.
- [x] Design slot API: `stage`, `leftHud`, `rightHud`, `bottomChrome`, `topChrome`, `hudVisible`, `onToggleHudVisibility`.
- [x] Implement glass HUD region wrappers using `DSGlassPanel` / tokens; no MapLibre dependency.
- [x] Implement hide/restore control with a11y label.
- [x] Export barrel + Prism alias.
- [x] Write widget tests for open regions, hide, restore, optional null slots.
- [x] Add gallery fixture with placeholder stage (solid/gradient mock).
- [x] **Simplicity pass**: remove unnecessary complexity introduced by this task; keep fixture-first contracts; no product route coupling.
- [x] **Regression verification**: run the validation commands listed below and paste outputs into Completion Evidence.

### Where

| File | Purpose |
| --- | --- |
| `packages/warp_prism_ui/lib/src/organisms/map_hud_workspace/` | Create — workspace organism module |
| `packages/warp_prism_ui/lib/src/organisms/map_hud_workspace/ds_map_hud_workspace.dart` | Create — implementation |
| `packages/warp_prism_ui/lib/src/organisms/organisms.dart` | Modify — export |
| `packages/warp_prism_ui/lib/src/prism_aliases.dart` | Modify — `PrismMapHudWorkspace` alias |
| `packages/warp_prism_ui/lib/warp_prism_ui.dart` | Read — ensure public surface remains aliases-only |
| `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` | Modify — minimal gallery case |
| `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_registry.dart` | Modify if new top-level section required |
| `packages/warp_prism_ui/test/organisms/map_hud_workspace/` | Create — widget tests |
| `packages/warp_prism_ui/lib/src/organisms/ds_shell.dart` | Read — non-clone reference |
| `packages/warp_prism_ui/lib/src/atoms/ds_glass_panel.dart` | Read — glass chrome |

### How

1. Read harvest page composition patterns; extract region model only.
2. Implement layout as `Stack`/`Overlay` of stage + positioned HUD slots with tokens.
3. Wire public alias and barrel; keep consumers on Prism name.
4. Add tests + gallery fixture; run analyze/test/boundaries.

### Why

Both references prove map-first multi-HUD is the missing layout class for CyberCore ops and a richer Map surface. Without it, later panels have no coherent host.

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
# flutter test test/organisms/map_hud_workspace/
# flutter test test/organisms/*map_hud_workspace*

# Public API / boundary harness (must stay 6/6 after alias/barrel work)
cd ../..
melos run test-boundaries
```


If Flutter tooling is unavailable in the execution environment, record the exact
tooling failure and do not claim those checks passed.

---

## Completion Evidence

- **Files created/modified**:
  - Created `packages/warp_prism_ui/lib/src/organisms/map_hud_workspace/ds_map_hud_workspace.dart`
  - Created `packages/warp_prism_ui/lib/src/organisms/map_hud_workspace/map_hud_workspace.dart`
  - Created `packages/warp_prism_ui/test/organisms/map_hud_workspace/map_hud_workspace_test.dart`
  - Modified `packages/warp_prism_ui/lib/src/organisms/organisms.dart` (append export)
  - Modified `packages/warp_prism_ui/lib/src/prism_aliases.dart` (import + `PrismMapHudWorkspace` typedef)
  - Modified `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` (organisms case + demo)
  - Created `docs/changelog/2026-07-10-task-1501-map-hud-workspace-organism.md`
- **Public API name verified**: `typedef PrismMapHudWorkspace = DSMapHudWorkspace` in `prism_aliases.dart`; re-exported via `package:warp_prism_ui/warp_prism_ui.dart` (aliases-only public surface). Barrel: `organisms.dart` → `map_hud_workspace/map_hud_workspace.dart`.
- **Tests or validation commands**:
  ```text
  cd packages/warp_prism_ui
  dart analyze lib/src/organisms/map_hud_workspace lib/src/organisms/organisms.dart \
    lib/src/prism_aliases.dart lib/src/gallery/design_system_gallery_sections.dart \
    test/organisms/map_hud_workspace
  # → No issues found (exit 0)

  flutter test test/organisms/map_hud_workspace/
  # → All tests passed! (8) (exit 0)
  ```
- **Boundary harness**: `melos` not on PATH; ran `dart run test/boundaries/boundary_test.dart` from `packages/warp_prism_ui` → **Boundary harness: 6/6 PASS, 0 FAIL** (exit 0)
- **Local changelog entry**: `docs/changelog/2026-07-10-task-1501-map-hud-workspace-organism.md`
- **Agent-wiki / docs institutionalization**: N/A
- **Executor**: gt-flutter-engineer (builder worker under parent builders)
- **Completion date**: 2026-07-10
- **Lane note**: Remains in `02-doing/` per instruction; Review State set to Ready For Review (do not move to `03-review` from this executor).
- **Residual risks**:
  - Gallery case lives under existing `organisms` section (id `organisms`); Task 1519 may re-home to `epic15-hud`.
  - HUD hide unmounts region widgets (stage never unmounted); if consumers need keep-alive region state, use controlled visibility + own state.
  - Exclusive open controller shared with Task 1502 tool strip is intentionally deferred.

---

## Review Ledger

### 2026-07-11 — independent reviewers (gt-flutter-code-reviewer + gt-code-quality-reviewer)

- **Score**: `94/100`
- **Verdict**: `APPROVED_TO_REVIEW`
- **Lane**: moved `docs/tasks/02-doing/` → `docs/tasks/03-review/`
- **Report**: `docs/reports/review-wave-2026-07-11/task-1501-independent-review.md`
- **Live gates**:
  - Scoped `dart analyze` → **PASS** No issues found
  - `flutter test test/organisms/map_hud_workspace/` → **8/8 PASS**
  - Boundary harness `dart run test/boundaries/boundary_test.dart` → **6/6 PASS**
  - Public alias `PrismMapHudWorkspace` + organisms export + gallery `_MapHudWorkspaceDemo` → **PASS**
- **Blockers**: none
- **Residuals (non-blocking)**: exclusive controller shared with 1502 deferred; gallery under `organisms` (1519); hide unmounts HUD widgets; optional StatefulWidget stage-survival proof for path-to-100 polish.
- **Policy**: never `04-completed/` in this wave.

### Re-Review 2026-07-16 — adversarial (implacable reviewer)

- **Date**: 2026-07-16
- **Reviewer profile**: `reviewers`
- **Score**: `94/100` (confirmed)
- **Verdict**: `APPROVED_TO_REVIEW`
- **Full report**: `docs/reports/review/task-1501-epic15-adversarial-review-2026-07-16.md`
- **Lane outcome**: remains in `03-review/`

#### Re-review delta
- **REGRESSION** F1: `dart format` gate reformatted 2 organism files (−3 from shared drift; shared across EPIC-15)
- **SUPERSEDED** I3: gallery re-homed to dedicated `epic15-hud` section (Task 1519)
- **NEW** I4: boundary harness 7/7 PASS (positive drift; new barrel DS-hide check)
- All original PASS claims re-proved live: analyze clean, 8/8 test green, Prism alias present

#### Path-to-100
1. Apply `dart format .` to `packages/warp_prism_ui` before end of EPIC-15 wave (1519/1521)
2. Optional: Stage survival test across hide/restore (blocker-free)

### Previous Reports
- 2026-07-11 — 94/100 `docs/reports/review-wave-2026-07-11/task-1501-independent-review.md`

### Independent drain review — 2026-07-17 (gt-flutter-code-reviewer + code-quality-harness)
- **Score**: `95/100` (prior draft 94)
- **Verdict**: `ACCEPTED_WITH_PATH_TO_100`
- **Full report**: `docs/reports/review-wave-2026-07-17/task-1501-drain-review.md`
- **Live proof**: map_hud tests **8/8**; analyze clean; boundaries **7/7**
- **Lane**: moved `03-review/` → `04-completed/`
- **Path to 100**: StatefulWidget stage-survival test polish

---

### 2026-07-18 — builders path-to-100 residual batch5

| Field | Value |
| --- | --- |
| **Wave** | path-to-100-wave-2026-07-17 / batch5 |
| **Executor** | builders (parent agentID=builders) |
| **Lane** | remain `docs/tasks/03-review/` (no lane move; no git/tasklist) |
| **Notes** | `docs/reports/path-to-100-wave-2026-07-17/batch5-notes.md` |

**Residuals applied**: StatefulWidget stage-survival counter test across hide/restore (`_StageSurvivalProbe` mountCount).
**Live**: map_hud_workspace tests **PASS** (includes survival case).
**Remaining**: exclusive controller shared with 1502 deferred (out of DoD).



---

### 2026-07-18 — independent path100 re-review (BATCH R5 / reviewers)

| Field | Value |
| --- | --- |
| **Score** | 100/100 |
| **Verdict** | ACCEPTED_COMPLETED |
| **path-to-100 applied** | YES |
| **Lane** | `04-completed/` |
| **Report** | `docs/reports/review-wave-2026-07-18/task-1501-path100-rereview.md` |
| **Top finding** | None task-scope (shared exclusive controller deferred w/ 1502) |
| **Exits** | map_hud +9 PASS; FocusNode dispose; stage survival; format clean; alias |
| **Reviewer** | independent (parent agentID=reviewers) |
| **Prior treated as** | draft — live re-proved after batch5 residual wave |
