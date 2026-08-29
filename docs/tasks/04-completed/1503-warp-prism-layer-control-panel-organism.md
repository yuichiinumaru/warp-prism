# Task 1503: PrismLayerControlPanel Organism

> **Review State**: `Ready For Review`
> **Priority**: 🔴 P0
> **Type**: `feature`
> **Origin**: EPIC-15 (`docs/tasks/00-planning/EPIC-15-warp-prism-ads-organism-expansion-from-reference-harvest.md`) + harvest reports `docs/reports/ads-organism-harvest-unified-2026-07-10.md`, `docs/reports/ads-organism-harvest-shadowbroker-2026-07-10.md`, `docs/reports/ads-organism-harvest-osiris-2026-07-10.md`
> **Blocks**: Task 1519
> **Depends on**: Task 1500
>
> **Soft dependency**: Task 1501 (`PrismMapHudWorkspace`) preferred for left-rail composition
> demos, but this organism MUST ship stand-alone in gallery with a fixture host if 1501 is incomplete.

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1503` plus optional slug for
> dependencies, blockers, review ledgers, reports, and architecture references.
> Lanes such as `02-doing` and `03-review` are mutable status, not identity.

---

## Objective

Implement `PrismLayerControlPanel` for grouped layer toggles with counts, optional freshness indicators, master toggle, and consent/hook stubs (callbacks only). Fixture layer catalog; no live map engine.

## Background Context

### Source origin (EPIC-15)

| Field | Value |
| --- | --- |
| **Proposed public name** | `PrismLayerControlPanel` |
| **Internal implementation (preferred)** | `DSLayerControlPanel` + `typedef PrismLayerControlPanel = DSLayerControlPanel` in `prism_aliases.dart` (match existing ADS pattern) |
| **Harvest organism ID** | `O-03` |
| **ShadowBroker origin** | `WorldviewLeftPanel.tsx` layer/group toggles |
| **Osiris origin** | `LayerPanel.tsx` grouped layers, counts, theme footer patterns |
| **Wave** | **B** |
| **Action type** | `NEW` |
| **Product consumers (later)** | Map / feed flags; optional left HUD slot of Task 1501 |
| **ADS-first rule** | Gallery + fixtures only — **no** Observatory product route rewrite required for exit |

### What already exists

- `DSFilterChipGroup` for simple chip filters.
- `DSStatusDot` / badges for freshness cues.
- HUD workspace slot from Task 1501 (soft integration target).

### What is missing or broken

- No grouped layer control organism with master toggle + counts + freshness.
- No consent-hook callback surface for privacy-sensitive layers.

### False-gap notes (do not re-implement)

- Do **not** clone `DSShell` / `DSSidebar` / `DSTopbar` as a second app shell — HUD workspace is an **additional** layout class over a stage slot.
- Do **not** port MapLibre, react-map-gl, force-graph JS, xterm.js, or reference megafiles.
- Do **not** invent domain one-off panels (Shodan/SCM/radio) — prefer generic slots + `PrismConnectorPanel` where applicable.
- Compose existing organisms (`DSDetailInspector`, `DSGraphCanvas`, `DSTimeline`, `DSCommandPalette`, toast system, tab bar, split pane) rather than forking them.

### Composition notes (molecules/atoms may derive later)

- Layer row
- Freshness pill
- Master toggle
- Consent gate chip

These molecules are **not** required deliverables of this task; implement inside the organism first, extract only if reuse is proven.

---

## Test Requirements

- MUST render layer groups with per-layer toggle.
- MUST support master toggle all-on/all-off (or per-group master).
- MUST display optional count and freshness fields from fixture model.
- Widget tests: toggle layer, master toggle, empty groups, disabled layer.
- A11y labels on toggles.
- Gallery fixture with mock layer catalog.

---

## Exit Conditions

- [x] `PrismLayerControlPanel` exported via barrel + aliases.
- [x] Widget tests PASS.
- [x] Gallery minimal case.
- [x] Analyze + scoped test PASS.
- [x] Local changelog entry added under `docs/changelog/` (or project changelog engine path used by current Warp Prism closeout).
- [x] Completion Evidence is filled before review handoff.
- [x] After barrel/alias changes, `melos run test-boundaries` remains **6/6 PASS** (run from monorepo root; if melos unavailable, run package boundary suite under `packages/warp_prism_ui/test/boundaries/` and record exact command).

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: read `docs/tasks/00-planning/EPIC-15-warp-prism-ads-organism-expansion-from-reference-harvest.md`, `docs/reports/ads-organism-harvest-unified-2026-07-10.md`, `docs/reports/ads-organism-harvest-shadowbroker-2026-07-10.md`, `docs/reports/ads-organism-harvest-osiris-2026-07-10.md`, `packages/warp_prism_ui/lib/src/organisms/organisms.dart`, `packages/warp_prism_ui/lib/src/prism_aliases.dart`, `packages/warp_prism_ui/lib/warp_prism_ui.dart`, `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart`, `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_registry.dart`, `packages/warp_prism_ui/lib/src/atoms/ds_glass_panel.dart`, `packages/warp_prism_ui/lib/src/tokens/ds_colors.dart`, `packages/warp_prism_ui/lib/src/tokens/ds_spacing.dart`.
- [x] Define `PrismLayerItem` / group models (id, label, enabled, count, freshness).
- [x] Implement panel UI with glass chrome.
- [x] Wire callbacks `onLayerChanged` / `onMasterToggle` / optional `onConsentRequired`.
- [x] Tests + gallery; optional demo embed in MapHudWorkspace gallery only if Task 1501 already landed.
- [x] **Simplicity pass**: remove unnecessary complexity introduced by this task; keep fixture-first contracts; no product route coupling.
- [x] **Regression verification**: run the validation commands listed below and paste outputs into Completion Evidence.

### Where

| File | Purpose |
| --- | --- |
| `packages/warp_prism_ui/lib/src/organisms/layer_control_panel/` | Create — module |
| `packages/warp_prism_ui/lib/src/organisms/layer_control_panel/ds_layer_control_panel.dart` | Create — implementation |
| `packages/warp_prism_ui/lib/src/organisms/organisms.dart` | Modify — export |
| `packages/warp_prism_ui/lib/src/prism_aliases.dart` | Modify — alias |
| `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` | Modify — gallery |
| `packages/warp_prism_ui/test/organisms/layer_control_panel/` | Create — tests |

### How

1. Translate harvest layer group UX to fixture models.
2. Compose toggles + badges with existing atoms.
3. Export + test + gallery.

### Why

Layer control is P0 consensus for map/feed workspaces; filters alone (chips) are insufficient for grouped geospatial/intel layers.

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

> [!WARNING]
> Soft-depends Task 1501 for optional HUD slot demos only. Panel must stand alone in gallery if 1501 is incomplete.

---

## Validation Commands

```bash
# From packages/warp_prism_ui (preferred scoped package gates)
cd packages/warp_prism_ui
dart analyze lib test
flutter test test/organisms/
# Prefer organism-scoped path when present, e.g.:
# flutter test test/organisms/layer_control_panel/
# flutter test test/organisms/*layer_control_panel*

# Public API / boundary harness (must stay 6/6 after alias/barrel work)
cd ../..
melos run test-boundaries
```


If Flutter tooling is unavailable in the execution environment, record the exact
tooling failure and do not claim those checks passed.

---

## Completion Evidence

- **Files created/modified**:
  - Created `packages/warp_prism_ui/lib/src/organisms/layer_control_panel/ds_layer_control_panel.dart`
  - Created `packages/warp_prism_ui/lib/src/organisms/layer_control_panel/layer_control_panel.dart`
  - Created `packages/warp_prism_ui/test/organisms/layer_control_panel/layer_control_panel_test.dart`
  - Modified `packages/warp_prism_ui/lib/src/organisms/organisms.dart` (append-only export; preserved MapHud, ToolStrip, PageShell, Tree, AgentTranscript)
  - Modified `packages/warp_prism_ui/lib/src/prism_aliases.dart` (import + typedefs)
  - Modified `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` (minimal case + fixture demo)
  - Created `docs/changelog/2026-07-10-task-1503-layer-control-panel-organism.md`
- **Public API name verified**: `typedef PrismLayerControlPanel = DSLayerControlPanel` (+ `PrismLayerGroup`, `PrismLayerItem`, `PrismLayerFreshness`) via `package:warp_prism_ui/warp_prism_ui.dart` → `src/prism_aliases.dart`; organisms barrel exports implementation
- **Tests or validation commands**:
  ```text
  cd packages/warp_prism_ui
  dart analyze lib/src/organisms/layer_control_panel lib/src/organisms/organisms.dart \
    lib/src/prism_aliases.dart lib/src/gallery/design_system_gallery_sections.dart \
    test/organisms/layer_control_panel
  # → No issues found

  flutter test test/organisms/layer_control_panel/
  # → All tests passed (12)
  ```
- **Boundary harness**:
  ```text
  # melos not on PATH; package suite used instead:
  cd packages/warp_prism_ui && dart run test/boundaries/boundary_test.dart
  # → Boundary harness: 6/6 PASS, 0 FAIL, 0 violation(s)
  ```
- **Local changelog entry**: `docs/changelog/2026-07-10-task-1503-layer-control-panel-organism.md`
- **Agent-wiki / docs institutionalization**: N/A
- **Executor**: gt-flutter-engineer (builders subagent)
- **Completion date**: 2026-07-10
- **Lane note**: Remains in `02-doing/` with Review State `Ready For Review` per builder instructions (no move to `03-review`).

---

## Review Ledger

> [!IMPORTANT]
> Before path-to-100 work, read the latest full report and all reports listed
> under Previous Reports. Persistent findings and regression guards are part of
> the acceptance contract.

### Latest Review

- **Date**: 2026-07-11
- **Reviewer profile**: `reviewers` (gt-flutter-code-reviewer + gt-code-quality-reviewer)
- **Score**: `96/100`
- **Verdict**: `HELD_IN_REVIEW_PATH_TO_100`
- **Full report**: `docs/reports/review-wave-2026-07-11/task-1503-independent-review.md`
- **Lane outcome**: moved to `docs/tasks/03-review/` (never `04-completed/`)
- **Task reference**: Task 1503 (`warp-prism-layer-control-panel-organism`)
- **Live prove (this review)**: organism suite PASS; aliases present; boundaries **6/6 PASS**; scoped analyze clean

#### Current Open Blockers

- None blocking binary exits.
- Optional: split models from UI monofile (~1040 LOC).

#### Path-to-100 Summary

- See full report Path To 100 (optional polish only unless noted).

### Previous Reports

- none found (initial independent review 2026-07-11)

### Re-Review 2026-07-16 — adversarial (implacable reviewer)

- **Date**: 2026-07-16
- **Reviewer profile**: `reviewers`
- **Score**: `96/100` (confirmed)
- **Verdict**: `HELD_IN_REVIEW_PATH_TO_100`
- **Full report**: `docs/reports/review/task-1503-epic15-adversarial-review-2026-07-16.md`
- **Lane outcome**: remains in `03-review/`

#### Re-review delta
- **REGRESSION** F1: `dart format` gate reformatted 1 impl + 1 test file (−2 from shared drift)
- **SUPERSEDED** I2: gallery now in dedicated `epic15-layers-filters` section (Task 1519)
- **NEW** I3: boundary harness 7/7 PASS (positive drift; new barrel DS-hide check)
- **PERSISTENT** I1: 1040 LOC single-file optional (non-blocking)
- All PASS claims re-proved: analyze clean, 12/12 green, Prism aliases present, consent logic intact

#### Path-to-100
1. Apply `dart format` to `packages/warp_prism_ui` before EPIC-15 wave closeout
2. Optional: extract layer models when reused by ≥2 organisms

### Previous Reports
- 2026-07-11 — 96/100 `docs/reports/review-wave-2026-07-11/task-1503-independent-review.md`
  - **Carried forward**: I1 (models co-located)
  - **Resolved since**: I2 (gallery re-home to dedicated epic15-layers-filters)

### Regression Guards

- Re-run organism-scoped `flutter test test/organisms/<module>/` after any organism/alias/gallery edit.
- Re-run `dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .` (or `dart run melos run test-boundaries`) after public DS/Prism surface changes — must stay **7/7 PASS**.
- Consumers must import `package:warp_prism_ui/warp_prism_ui.dart` (Prism* aliases); do not expose raw DS* via public barrel.

---

## Review Ledger — 2026-07-17 Drain Wave (Batch 9)

| Field | Value |
| --- | --- |
| **Score** | 94/100 |
| **Verdict** | PASS path-to-100 residual |
| **Lane** | 04-completed |
| **Report** | `docs/reports/review-wave-2026-07-17/task-1503-drain-review.md` |
| **Top finding** | Format dirty + monolith residual |
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

**Residuals applied**: `dart format` organism+test (format residual closed).
**Live**: layer_control_panel **12/12 PASS**; format clean.
**Remaining**: optional monolith split deferred (info only).



---

### 2026-07-18 — independent path100 re-review (BATCH R5 / reviewers)

| Field | Value |
| --- | --- |
| **Score** | 100/100 |
| **Verdict** | ACCEPTED_COMPLETED |
| **path-to-100 applied** | YES |
| **Lane** | `04-completed/` |
| **Report** | `docs/reports/review-wave-2026-07-18/task-1503-path100-rereview.md` |
| **Top finding** | None task-scope (optional monolith split deferred) |
| **Exits** | layer_control +12 PASS; consent/master/groups; format clean |
| **Reviewer** | independent (parent agentID=reviewers) |
| **Prior treated as** | draft — live re-proved after batch5 residual wave |
