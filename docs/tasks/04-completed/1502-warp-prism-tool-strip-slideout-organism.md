# Task 1502: PrismToolStripSlideout Organism

> **Status**: `[x]` Review Approved — independent review S=95 (held in 03-review; never 04-completed by this wave)
> **Review State**: `Review Approved`
> **Priority**: 🔴 P0
> **Type**: `feature`
> **Origin**: EPIC-15 (`docs/tasks/00-planning/EPIC-15-warp-prism-ads-organism-expansion-from-reference-harvest.md`) + harvest reports `docs/reports/ads-organism-harvest-unified-2026-07-10.md`, `docs/reports/ads-organism-harvest-shadowbroker-2026-07-10.md`, `docs/reports/ads-organism-harvest-osiris-2026-07-10.md`
> **Blocks**: Task 1519
> **Depends on**: Task 1500

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1502` plus optional slug for
> dependencies, blockers, review ledgers, reports, and architecture references.
> Lanes such as `02-doing` and `03-review` are mutable status, not identity.

---

## Objective

Implement `PrismToolStripSlideout`: vertical icon tool strip + exclusive slideout body. Opening tool A closes tool B. Fixture tools only; no live recon backends.

## Background Context

### Source origin (EPIC-15)

| Field | Value |
| --- | --- |
| **Proposed public name** | `PrismToolStripSlideout` |
| **Internal implementation (preferred)** | `DSToolStripSlideout` + `typedef PrismToolStripSlideout = DSToolStripSlideout` in `prism_aliases.dart` (match existing ADS pattern) |
| **Harvest organism ID** | `O-02` |
| **ShadowBroker origin** | Right HUD tool stack composition in `frontend/src/app/page.tsx` |
| **Osiris origin** | Exclusive right tool strip (~L932–1002 in `src/app/page.tsx`) — open one closes others |
| **Wave** | **A** |
| **Action type** | `NEW` |
| **Product consumers (later)** | HUD host (Task 1501 right slot); CyberCore tool launchers |
| **ADS-first rule** | Gallery + fixtures only — **no** Observatory product route rewrite required for exit |

### What already exists

- `DSTabBar` / `DSTabView` for tabbed bodies (compose, do not replace exclusive strip).
- `DSCommandPalette` for command search — different interaction.
- Glass panel + icon atoms.

### What is missing or broken

- No exclusive multi-tool slideout organism with icon rail + body panel.
- No shared exclusive-open controller contract for HUD tools.

### False-gap notes (do not re-implement)

- Do **not** clone `DSShell` / `DSSidebar` / `DSTopbar` as a second app shell — HUD workspace is an **additional** layout class over a stage slot.
- Do **not** port MapLibre, react-map-gl, force-graph JS, xterm.js, or reference megafiles.
- Do **not** invent domain one-off panels (Shodan/SCM/radio) — prefer generic slots + `PrismConnectorPanel` where applicable.
- Compose existing organisms (`DSDetailInspector`, `DSGraphCanvas`, `DSTimeline`, `DSCommandPalette`, toast system, tab bar, split pane) rather than forking them.

### Composition notes (molecules/atoms may derive later)

- Tool strip icon button
- Slideout glass body frame
- Exclusive panel controller

These molecules are **not** required deliverables of this task; implement inside the organism first, extract only if reuse is proven.

---

## Test Requirements

- MUST support N tool entries (id, icon, label, body builder).
- MUST enforce exclusive open: selecting a second tool closes the first.
- MUST support close/collapse to strip-only state.
- Widget tests MUST cover open, exclusive switch, close, empty tools list.
- Interactive icons MUST have Semantics labels (tool name).
- Gallery fixture with ≥2 mock tools and distinct body content.

---

## Exit Conditions

- [x] Implementation + `PrismToolStripSlideout` public alias exported.
- [x] Widget tests for exclusive open/close PASS.
- [x] Gallery minimal case present.
- [x] `dart analyze` + scoped `flutter test` PASS on touched suite.
- [x] Local changelog entry added under `docs/changelog/` (or project changelog engine path used by current Warp Prism closeout).
- [x] Completion Evidence is filled before review handoff.
- [x] After barrel/alias changes, `melos run test-boundaries` remains **6/6 PASS** (run from monorepo root; if melos unavailable, run package boundary suite under `packages/warp_prism_ui/test/boundaries/` and record exact command).

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: read `docs/tasks/00-planning/EPIC-15-warp-prism-ads-organism-expansion-from-reference-harvest.md`, `docs/reports/ads-organism-harvest-unified-2026-07-10.md`, `docs/reports/ads-organism-harvest-shadowbroker-2026-07-10.md`, `docs/reports/ads-organism-harvest-osiris-2026-07-10.md`, `packages/warp_prism_ui/lib/src/organisms/organisms.dart`, `packages/warp_prism_ui/lib/src/prism_aliases.dart`, `packages/warp_prism_ui/lib/warp_prism_ui.dart`, `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart`, `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_registry.dart`, `packages/warp_prism_ui/lib/src/atoms/ds_glass_panel.dart`, `packages/warp_prism_ui/lib/src/tokens/ds_colors.dart`, `packages/warp_prism_ui/lib/src/tokens/ds_spacing.dart`.
- [x] Define tool model (`id`, `icon`, `label`, `builder`/`child`).
- [x] Implement exclusive selection state (controlled + uncontrolled modes if useful).
- [x] Implement strip + slideout animation using existing motion tokens (keep simple).
- [x] Export barrel + Prism alias; add tests + gallery fixture.
- [x] **Simplicity pass**: remove unnecessary complexity introduced by this task; keep fixture-first contracts; no product route coupling.
- [x] **Regression verification**: run the validation commands listed below and paste outputs into Completion Evidence.

### Where

| File | Purpose |
| --- | --- |
| `packages/warp_prism_ui/lib/src/organisms/tool_strip_slideout/` | Create — module |
| `packages/warp_prism_ui/lib/src/organisms/tool_strip_slideout/ds_tool_strip_slideout.dart` | Create — implementation |
| `packages/warp_prism_ui/lib/src/organisms/organisms.dart` | Modify — export |
| `packages/warp_prism_ui/lib/src/prism_aliases.dart` | Modify — alias |
| `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` | Modify — gallery case |
| `packages/warp_prism_ui/test/organisms/tool_strip_slideout/` | Create — tests |

### How

1. Model exclusive selection as single nullable activeToolId.
2. Render icon strip; when active, show glass body panel with tool content.
3. Test exclusive behavior and a11y labels; register gallery fixture.

### Why

Exclusive tool strip is the consensus right-HUD interaction in both harvest sources; without it, multi-tool HUDs fight for space.

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
# flutter test test/organisms/tool_strip_slideout/
# flutter test test/organisms/*tool_strip_slideout*

# Public API / boundary harness (must stay 6/6 after alias/barrel work)
cd ../..
melos run test-boundaries
```


If Flutter tooling is unavailable in the execution environment, record the exact
tooling failure and do not claim those checks passed.

---

## Completion Evidence

- **Files created/modified**:
  - Created `packages/warp_prism_ui/lib/src/organisms/tool_strip_slideout/ds_tool_strip_slideout.dart`
  - Created `packages/warp_prism_ui/lib/src/organisms/tool_strip_slideout/tool_strip_slideout.dart`
  - Created `packages/warp_prism_ui/test/organisms/tool_strip_slideout/tool_strip_slideout_test.dart`
  - Modified `packages/warp_prism_ui/lib/src/organisms/organisms.dart` (export append)
  - Modified `packages/warp_prism_ui/lib/src/prism_aliases.dart` (import + typedefs)
  - Modified `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` (minimal case + demo)
  - Created `docs/changelog/2026-07-10-task-1502-tool-strip-slideout-organism.md`
- **Public API name verified**: `typedef PrismToolStripSlideout = DSToolStripSlideout` (+ `PrismToolStripItem`) via `package:warp_prism_ui/warp_prism_ui.dart` → `src/prism_aliases.dart`; organisms barrel exports implementation
- **Tests or validation commands**:
  ```text
  cd packages/warp_prism_ui
  dart analyze lib/src/organisms/tool_strip_slideout lib/src/organisms/organisms.dart \
    lib/src/prism_aliases.dart lib/src/gallery/design_system_gallery_sections.dart \
    test/organisms/tool_strip_slideout
  # → No issues found (3 pre-existing prefer_const_constructors infos in gallery tree block only)

  flutter test test/organisms/tool_strip_slideout/
  # → All tests passed (10)
  ```
- **Boundary harness**:
  ```text
  dart run test/boundaries/boundary_test.dart
  # → Boundary harness: 6/6 PASS, 0 FAIL, 0 violation(s)
  # melos run test-boundaries unavailable in this environment; package path used
  ```
- **Local changelog entry**: `docs/changelog/2026-07-10-task-1502-tool-strip-slideout-organism.md`
- **Agent-wiki / docs institutionalization**: N/A (organism land; contract already locked in Task 1500 brief)
- **Executor**: gt-flutter-engineer (builders worker)
- **Completion date**: 2026-07-10

### Residuals

- Shared exclusive-open controller co-owned with HUD host composition is still deferred (Task 1501 note) — organism owns exclusive state internally; HUD wiring is a later integration concern.
- Gallery case lives under existing `organisms` section; Task 1519 owns final `epic15-hud` section ordering.
- Melos `test-boundaries` script not available in path; package `dart run test/boundaries/boundary_test.dart` used and passed 6/6.

---

## Review Ledger

### 2026-07-11 — independent reviewers (gt-flutter-code-reviewer + gt-code-quality-reviewer)

- **Score**: `95/100`
- **Verdict**: `APPROVED_TO_REVIEW`
- **Lane**: moved `docs/tasks/02-doing/` → `docs/tasks/03-review/`
- **Report**: `docs/reports/review-wave-2026-07-11/task-1502-independent-review.md`
- **Live gates**:
  - Scoped `dart analyze` → **PASS** No issues found
  - `flutter test test/organisms/tool_strip_slideout/` → **10/10 PASS** (open / exclusive / close / empty / a11y)
  - Boundary harness `dart run test/boundaries/boundary_test.dart` → **6/6 PASS**
  - Public aliases `PrismToolStripSlideout` + `PrismToolStripItem` + gallery demo (≥2 tools) → **PASS**
- **Blockers**: none
- **Residuals (non-blocking)**: shared exclusive controller with HUD deferred; gallery re-home Task 1519; optional controlled-collapse-via-prop test for path-to-100 polish.
- **Policy**: never `04-completed/` in this wave.

### Re-Review 2026-07-16 — adversarial (implacable reviewer)

- **Date**: 2026-07-16
- **Reviewer profile**: `reviewers`
- **Score**: `95/100` (confirmed)
- **Verdict**: `APPROVED_TO_REVIEW`
- **Full report**: `docs/reports/review/task-1502-epic15-adversarial-review-2026-07-16.md`
- **Lane outcome**: remains in `03-review/`

#### Re-review delta
- **REGRESSION** F1: `dart format` gate reformatted 2 organism files (−3 from shared drift; shared across EPIC-15)
- **SUPERSEDED** I3: gallery now in dedicated `epic15-hud` section (Task 1519)
- **NEW** I4: boundary harness 7/7 PASS (positive drift)
- All original PASS claims re-proved live: analyze clean, 10/10 test green, Prism aliases present, exclusive behavior confirmed

#### Path-to-100
1. Apply `dart format` to `packages/warp_prism_ui` before EPIC-15 wave closeout
2. Optional: controlled-collapse test for 50-case regression proof

### Previous Reports
- 2026-07-11 — 95/100 `docs/reports/review-wave-2026-07-11/task-1502-independent-review.md`

---

## Review Ledger — 2026-07-17 Drain Wave (Batch 9)

| Field | Value |
| --- | --- |
| **Score** | 94/100 |
| **Verdict** | PASS path-to-100 residual |
| **Lane** | 04-completed |
| **Report** | `docs/reports/review-wave-2026-07-17/task-1502-drain-review.md` |
| **Top finding** | Format-dirty organism+test (−4) |
| **Reviewer** | independent (parent agentID=reviewers) |
| **Prior treated as** | draft — live re-proved |

---

### 2026-07-18 — builders path-to-100 residual batch5

| Field | Value |
| --- | --- |
| **Wave** | path-to-100-wave-2026-07-17 / batch5 |
| **Executor** | builders (parent agentID=builders) |
| **Lane** | remain `docs/tasks/03-review/` (no lane move; no git/tasklist) |
| **Notes** | `docs/reports/path-to-100-wave-2026-07-17/batch5-notes.md` |

**Residuals applied**: `dart format` organism+test; controlled `activeToolId: 'x' → null` collapse test without strip tap.
**Live**: tool_strip_slideout **11/11 PASS**; format clean.
**Remaining**: shared exclusive controller with HUD deferred.



---

### 2026-07-18 — independent path100 re-review (BATCH R5 / reviewers)

| Field | Value |
| --- | --- |
| **Score** | 100/100 |
| **Verdict** | ACCEPTED_COMPLETED |
| **path-to-100 applied** | YES |
| **Lane** | `04-completed/` |
| **Report** | `docs/reports/review-wave-2026-07-18/task-1502-path100-rereview.md` |
| **Top finding** | None task-scope |
| **Exits** | tool_strip +11 PASS; controlled null collapse; format clean; 48dp targets |
| **Reviewer** | independent (parent agentID=reviewers) |
| **Prior treated as** | draft — live re-proved after batch5 residual wave |
