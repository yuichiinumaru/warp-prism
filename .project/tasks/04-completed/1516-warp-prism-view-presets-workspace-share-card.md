# Task 1516: PrismViewPresets + PrismWorkspaceShareCard

> **Review State**: `Open`
> **Priority**: 🟡 P1
> **Type**: `feature`
> **Origin**: EPIC-15 (`docs/tasks/00-planning/EPIC-15-warp-prism-ads-organism-expansion-from-reference-harvest.md`) + harvest reports `docs/reports/ads-organism-harvest-unified-2026-07-10.md`, `docs/reports/ads-organism-harvest-shadowbroker-2026-07-10.md`, `docs/reports/ads-organism-harvest-osiris-2026-07-10.md`
> **Blocks**: Task 1519
> **Depends on**: Task 1500
>
> **Soft dependency**: Task 1501 preferred for “apply preset to workspace” demos; presets/share
> MUST work against a pure fixture state model without live map engines.

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1516` plus optional slug for
> dependencies, blockers, review ledgers, reports, and architecture references.
> Lanes such as `02-doing` and `03-review` are mutable status, not identity.

---

## Objective

Implement `PrismViewPresets` (named camera/layer preset grid) and `PrismWorkspaceShareCard` (read-only shareable view-state summary). No auth/share backend; clipboard/callback only.

## Background Context

### Source origin (EPIC-15)

| Field | Value |
| --- | --- |
| **Proposed public name** | `PrismViewPresets + PrismWorkspaceShareCard` |
| **Internal implementation (preferred)** | `DSViewPresets + WorkspaceShareCard` + `typedef PrismViewPresets + PrismWorkspaceShareCard = DSViewPresets + WorkspaceShareCard` in `prism_aliases.dart` (match existing ADS pattern) |
| **Harvest organism ID** | `O-18 / O-19` |
| **ShadowBroker origin** | N/A (Osiris-primary for presets/share) |
| **Osiris origin** | `ViewPresets.tsx`; `SharePanel.tsx` read-only shareable view-state summary |
| **Wave** | **G** |
| **Action type** | `NEW` |
| **Product consumers (later)** | Map workspace presets; read-only share card — no auth product |
| **ADS-first rule** | Gallery + fixtures only — **no** Observatory product route rewrite required for exit |

### What already exists

- Layer models from Task 1503 if present; stage contract from Task 1512 optional.
- Glass cards, buttons.

### What is missing or broken

- No view preset grid organism.
- No read-only workspace share summary card.

### False-gap notes (do not re-implement)

- Do **not** clone `DSShell` / `DSSidebar` / `DSTopbar` as a second app shell — HUD workspace is an **additional** layout class over a stage slot.
- Do **not** port MapLibre, react-map-gl, force-graph JS, xterm.js, or reference megafiles.
- Do **not** invent domain one-off panels (Shodan/SCM/radio) — prefer generic slots + `PrismConnectorPanel` where applicable.
- Compose existing organisms (`DSDetailInspector`, `DSGraphCanvas`, `DSTimeline`, `DSCommandPalette`, toast system, tab bar, split pane) rather than forking them.

### Composition notes (molecules/atoms may derive later)

- Preset tile
- Share field row
- Copy summary button

These molecules are **not** required deliverables of this task; implement inside the organism first, extract only if reuse is proven.

---

## Test Requirements

- Presets: render fixture presets; select emits callback with preset id/payload.
- Share card: shows summary fields; copy/share callback; no network.
- Widget tests: select preset, empty presets, copy action.
- A11y labels on preset tiles and share/copy.
- Gallery fixtures for both.

---

## Exit Conditions

- [x] Both public names exported.
- [x] Tests + gallery PASS.
- [x] No auth product surface.
- [x] Analyze + scoped test PASS.
- [x] Local changelog entry added under `docs/changelog/` (or project changelog engine path used by current Warp Prism closeout).
- [x] Completion Evidence is filled before review handoff.
- [x] After barrel/alias changes, `melos run test-boundaries` remains **6/6 PASS** (run from monorepo root; if melos unavailable, run package boundary suite under `packages/warp_prism_ui/test/boundaries/` and record exact command).

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: read `docs/tasks/00-planning/EPIC-15-warp-prism-ads-organism-expansion-from-reference-harvest.md`, `docs/reports/ads-organism-harvest-unified-2026-07-10.md`, `docs/reports/ads-organism-harvest-shadowbroker-2026-07-10.md`, `docs/reports/ads-organism-harvest-osiris-2026-07-10.md`, `packages/warp_prism_ui/lib/src/organisms/organisms.dart`, `packages/warp_prism_ui/lib/src/prism_aliases.dart`, `packages/warp_prism_ui/lib/warp_prism_ui.dart`, `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart`, `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_registry.dart`, `packages/warp_prism_ui/lib/src/atoms/ds_glass_panel.dart`, `packages/warp_prism_ui/lib/src/tokens/ds_colors.dart`, `packages/warp_prism_ui/lib/src/tokens/ds_spacing.dart`.
- [x] Define preset + share summary models.
- [x] Implement preset grid.
- [x] Implement share card (read-only).
- [x] Tests + gallery + exports.
- [x] **Simplicity pass**: remove unnecessary complexity introduced by this task; keep fixture-first contracts; no product route coupling.
- [x] **Regression verification**: run the validation commands listed below and paste outputs into Completion Evidence.

### Where

| File | Purpose |
| --- | --- |
| `packages/warp_prism_ui/lib/src/organisms/view_presets/` | Create — presets |
| `packages/warp_prism_ui/lib/src/organisms/workspace_share_card/` | Create — share card |
| `packages/warp_prism_ui/lib/src/organisms/organisms.dart` | Modify — exports |
| `packages/warp_prism_ui/lib/src/prism_aliases.dart` | Modify — aliases |
| `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` | Modify — gallery |
| `packages/warp_prism_ui/test/organisms/view_presets/` | Create — tests |
| `packages/warp_prism_ui/test/organisms/workspace_share_card/` | Create — tests |

### How

1. Fixture presets with fake camera/layer payload.
2. Share card prints JSON/summary; copy callback only.
3. Export/test/gallery.

### Why

Presets/share improve multi-operator map workflows without requiring backend auth in ADS phase.

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
flutter test test/organisms/view_presets/ test/organisms/workspace_share_card/
# Fallback:
# flutter test test/organisms/
```

---

## Completion Evidence

- **Files created/modified**:
  - `packages/warp_prism_ui/lib/src/organisms/view_presets/ds_view_presets.dart` (created)
  - `packages/warp_prism_ui/lib/src/organisms/view_presets/view_presets.dart` (created)
  - `packages/warp_prism_ui/lib/src/organisms/workspace_share_card/ds_workspace_share_card.dart` (created)
  - `packages/warp_prism_ui/lib/src/organisms/workspace_share_card/workspace_share_card.dart` (created)
  - `packages/warp_prism_ui/lib/src/organisms/organisms.dart` (modified)
  - `packages/warp_prism_ui/lib/src/prism_aliases.dart` (modified)
  - `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` (modified)
  - `packages/warp_prism_ui/test/organisms/view_presets/view_presets_test.dart` (created)
  - `packages/warp_prism_ui/test/organisms/workspace_share_card/workspace_share_card_test.dart` (created)
- **Public API name verified**: `PrismViewPresets + PrismWorkspaceShareCard` export path
- **Tests or validation commands**:
  - `dart analyze lib/src/organisms/view_presets/ lib/src/organisms/workspace_share_card/ test/organisms/view_presets/ test/organisms/workspace_share_card/` -> PASS (No issues found)
  - `flutter test test/organisms/view_presets/ test/organisms/workspace_share_card/ --concurrency=1 --no-pub` -> PASS (All tests passed)
- **Boundary harness**:
  - `flutter test test/boundaries/boundary_test.dart --no-pub` -> PASS (7/7 boundary checks passed)
- **Local changelog entry**: `docs/changelog/20260715-123000-1516-view-presets-workspace-share-card-builders.md`
- **Agent-wiki / docs institutionalization**: N/A
- **Executor**: builders
- **Completion date**: 2026-07-15
- **Reviewer**: reviewers
- **Review date**: 2026-07-16

## Review Ledger

| Date | Reviewer | Score | Verdict | Report |
| --- | --- | --- | --- | --- |
| 2026-07-16 | reviewers | **96** | **PASS** (narrow patch recommended) | `docs/reports/review/1516-view-presets-workspace-share-card-review-2026-07-16.md` |

### Path-to-100 residual

- Copy button touch target proof (48x48 min) + corresponding Widget test assertion.

---

## Review Ledger — 2026-07-17 Drain Wave (Batch 9)

| Field | Value |
| --- | --- |
| **Score** | 93/100 |
| **Verdict** | PASS path-to-100 residual |
| **Lane** | 04-completed |
| **Report** | `docs/reports/review-wave-2026-07-17/task-1516-drain-review.md` |
| **Top finding** | Copy button missing explicit 48×48 minSize |
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

**Residuals applied**: copy `ElevatedButton` `minimumSize: Size(48,48)` + ≥48 touch-target test; format clean on view_presets + workspace_share_card.
**Live**: workspace_share_card tests **PASS** (includes touch-target); format clean.
**Remaining**: none task-scope.



---

### 2026-07-18 — independent path100 re-review (BATCH R5 / reviewers)

| Field | Value |
| --- | --- |
| **Score** | 100/100 |
| **Verdict** | ACCEPTED_COMPLETED |
| **path-to-100 applied** | YES |
| **Lane** | `04-completed/` |
| **Report** | `docs/reports/review-wave-2026-07-18/task-1516-path100-rereview.md` |
| **Top finding** | None |
| **Exits** | view_presets + share card tests PASS; copy ≥48; format clean |
| **Reviewer** | independent (parent agentID=reviewers) |
| **Prior treated as** | draft — live re-proved after batch5 residual wave |
