# Warp Prism — Operational Component MVP

> **Status**: Active design document
> **Author**: Task 1106 — Warp Prism Operational Component MVP
> **Date**: 2026-06-08
> **Last refreshed**: 2026-08-24 (path-to-100: gallery DSTaskCard + DSMetricTile health variants, narrow/long/scaled edge evidence synchronized into catalog/test matrix)
> **Depends on**: Task 1102 (inventory), Task 1104 (monorepo), Task 1105 (catalog policy)
> **Blocks**: Task 1110 (CyberCore pilot), Task 1111 (expansion gate)

---

## 1. Objective

Define the first reusable operational component MVP for `warp_prism_ui` — the
minimum set of enhanced components needed by CyberCore Pilot Surface A
(**Providers connections**, route `/providers`, from
`docs/design/cybercore-pilot-surface-matrix.md`). Each promoted component must
be app-agnostic, have catalog evidence, and pass the Task 1105 promotion gates.

> **Historical note**: Early drafts framed Pilot A as a “Task Governance Board.”
> Live Task 1102 inventory realigned Pilot A to **Providers** (`/providers`).
> Component selection (status dots, metric health, state surfaces, task/lane
> cards) remains valid as shared operational primitives for that pilot and
> later surfaces.

---

## 2. Component Classification

### 2.1 Already Reusable (No Enhancement Needed)

These components are already in `warp_prism_ui` and are fully app-agnostic:

| Component | Layer | Status | Notes |
|-----------|-------|--------|-------|
| `DSColors` | Token | ✅ Ready | All semantic color tokens present. Operational state aliases added in this task. |
| `DSTypography` | Token | ✅ Ready | 18-style type scale, no app coupling. |
| `DSSpacing` | Token | ✅ Ready | Base + semantic spacing. |
| `DSRadii` | Token | ✅ Ready | Base + semantic radii. |
| `DSShadows` | Token | ✅ Ready | Elevation + glow presets. |
| `DSMotion` | Token | ✅ Ready | Durations + curves. |
| `DSSemantics` | Token | ✅ Ready | Semantic text styles. |
| `DSBreakpoints` | Token | ✅ Ready | Responsive breakpoints. |
| `DSText` | Atom | ✅ Ready | All 18 variants. |
| `DSIcon` | Atom | ✅ Ready | All sizes + icon constants. |
| `DSBadge` | Atom | ✅ Ready | Count, semantic constructors. |
| `DSChip` | Atom | ✅ Ready | Interactive, focusable, factory constructors. |
| `DSDivider` | Atom | ✅ Ready | Subtle/default/glow variants. |
| `DSGlassPanel` | Atom | ✅ Ready | Subtle/elevated/modal variants. |
| `DSGlowBorder` | Atom | ✅ Ready | Decorative glow border. |
| `DSSearchBar` | Molecule | ✅ Ready | Generic search input. |
| `DSFilterChipGroup` | Molecule | ✅ Ready | Generic multi-select filter. |
| `DSAssetCard` | Molecule | ✅ Ready | App-agnostic asset card. |
| `DSProvenancePill` | Molecule | ✅ Ready | 6 canonicality states complete. |
| `DSEvidenceRow` | Molecule | ✅ Ready | 4 evidence states complete. |
| `DSTimelineMarker` | Molecule | ✅ Ready | Date/type/project badges. |
| `DSShell` | Organism | ✅ Ready | Responsive layout shell. |
| `DSSidebar` | Organism | ✅ Ready | Navigation sidebar. |
| `DSTopbar` | Organism | ✅ Ready | Title/breadcrumb/action topbar. |
| `DSTimeline` | Organism | ✅ Ready | Flat/grouped timeline. |
| `DSDetailInspector` | Organism | ✅ Ready | Section-based inspector. |
| `DSStoryPanel` | Organism | ✅ Ready | Narrative insight panel. |
| `DSGraphCanvas` | Organism | ✅ Ready | Force-directed graph. |
| `MasterDetailTemplate` | Template | ✅ Ready | Responsive master-detail. |
| `CanvasTemplate` | Template | ✅ Ready | Full-bleed canvas. |
| `TimelineTemplate` | Template | ✅ Ready | Timeline + detail. |

### 2.2 Promoted with Enhancement (This Task)

These components need operational state support before they can serve the
CyberCore Providers pilot and sibling operational surfaces:

| Component | Layer | Enhancement | CyberCore Reuse |
|-----------|-------|-------------|-----------------|
| **`DSStatusDot`** | Atom | Add 15 operational state constructors (`running`, `approved`, `rejected`, `promoted`, `archived`, `healthy`, `degraded`, `disabled`, `unverified`, `exposed`, `redacted`, `stale`, `excluded`) | Provider status badges, health indicators, row/state chips |
| **`DSMetricTile`** | Molecule | Add `health` state support (healthy/degraded/error/disabled) with automatic accent color mapping | Overview dashboard, provider health metrics, monitors |
| **`DSStateSurface`** | Molecule | Add 4 operational constructors (`disabled`, `stale`, `degraded`, `excluded`) for content-area state rendering | All empty/loading/error/operational states on `/providers` and later pilots |
| **`DSTaskCard`** | Molecule | Already app-agnostic. Add `Prism*` alias and catalog with all operational states | Generic operational card primitive (lane/task proof display); not product-specific governance UI |

### 2.3 Deferred or Owned Elsewhere (Not in This Task)

| Component | Status (live) | Reason / owner |
|-----------|---------------|----------------|
| `DSLaneBoard` | Implemented; DnD deferred | Already functional. Drag-and-drop enhancement deferred to Task 1120. |
| `DSTaskCard` multi-category enrichment | Partial (sufficient for MVP) | Full multi-category state display (lane + health + proof + governance) deferred. Current proof state + priority display is sufficient for Pilot A. |
| Data Table (`DSDataTable`) | **Delivered by Task 1112** | Lives at `packages/warp_prism_ui/lib/src/organisms/data_table/`. Out of 1106 MVP scope; not “not implemented.” |
| Command Palette (`DSCommandPalette`) | **Delivered by Task 1113** | Lives at `packages/warp_prism_ui/lib/src/organisms/command_palette/`. Out of 1106 MVP scope; not “not implemented.” |

---

## 3. State Matrix

### 3.1 DSStatusDot — Full 15-State Support

| Operational State | Named Constructor | Color Source | Hex | Animated | Tooltip Default |
|-------------------|-------------------|-------------|-----|----------|-----------------|
| Pending | `DSStatusDot.pending()` | textTertiary | `#8888A0` | No | "Pending: awaiting start" |
| Running | `DSStatusDot.running()` | accentGold | `#FFB800` | Yes | "Running: in progress" |
| Approved | `DSStatusDot.approved()` | statusSuccess | `#10B981` | No | "Approved" |
| Rejected | `DSStatusDot.rejected()` | statusError | `#EF4444` | No | "Rejected" |
| Promoted | `DSStatusDot.promoted()` | accentCyan | `#00D4FF` | No | "Promoted" |
| Archived | `DSStatusDot.archived()` | textDisabled | `#505060` | No | "Archived" |
| Healthy | `DSStatusDot.healthy()` | statusSuccess | `#10B981` | No | "Healthy" |
| Degraded | `DSStatusDot.degraded()` | statusWarning | `#F59E0B` | No | "Degraded" |
| Error | `DSStatusDot.error()` | statusError | `#EF4444` | No | "Error" |
| Disabled | `DSStatusDot.disabled()` | textDisabled | `#505060` | No | "Disabled" |
| Unverified | `DSStatusDot.unverified()` | textTertiary | `#8888A0` | No | "Unverified" |
| Exposed | `DSStatusDot.exposed()` | statusError | `#EF4444` | Yes | "Exposed: at risk" |
| Redacted | `DSStatusDot.redacted()` | accentViolet | `#8B5CF6` | No | "Redacted" |
| Stale | `DSStatusDot.stale()` | statusWarning | `#F59E0B` | No | "Stale: needs refresh" |
| Excluded | `DSStatusDot.excluded()` | textDisabled | `#505060` | No | "Excluded" |

### 3.2 DSMetricTile — Health States

| Health State | Accent Color | Behavior |
|-------------|-------------|----------|
| `healthy` (default) | Caller-specified or `accentCyan` | Standard metric display |
| `degraded` | `statusWarning` | Warning-toned accent, value text uses warning color |
| `error` | `statusError` | Error-toned accent, value text uses error color |
| `disabled` | `textDisabled` | Muted accent, value text uses disabled color |

### 3.3 DSStateSurface — Operational State Constructors

| Constructor | Icon | Color | Title Default | Use Case |
|-------------|------|-------|---------------|----------|
| `.empty()` | inbox_outlined | textTertiary | (required) | No data |
| `.loading()` | progress indicator | accentCyan | "Loading..." | Data fetch |
| `.error()` | DSIcons.error | statusError | (required) | Fetch failure |
| `.disabled()` | block | textDisabled | (required) | Feature disabled |
| `.stale()` | update | statusWarning | (required) | Data outdated |
| `.degraded()` | warning_amber | statusWarning | (required) | Partial data |
| `.excluded()` | remove_circle_outline | textDisabled | (required) | Filtered out |

---

## 4. Prism* Public API Aliases

Per `token-theme-catalog-policy.md` §2.4, all public components exported from
`warp_prism_ui` use the `Prism` prefix. This task creates type aliases for the
MVP operational components:

| DS* Internal | Prism* Public | Type |
|-------------|---------------|------|
| `DSStatusDot` | `PrismStatusDot` | Type alias |
| `DSMetricTile` | `PrismMetricTile` | Type alias |
| `DSMetricTileCompact` | `PrismMetricTileCompact` | Type alias |
| `DSStateSurface` | `PrismStateSurface` | Type alias |
| `DSTaskCard` | `PrismTaskCard` | Type alias |
| `DSLaneBoard` | `PrismLaneBoard` | Type alias |
| `DSLane` | `PrismLane` | Type alias |
| `DSLaneTask` | `PrismLaneTask` | Type alias |
| `DSAssetCard` | `PrismAssetCard` | Type alias |
| `DSSearchBar` | `PrismSearchBar` | Type alias |
| `DSFilterChipGroup` | `PrismFilterChipGroup` | Type alias |
| `DSMetricTileHealth` | `PrismMetricTileHealth` | New enum |

---

## 5. Catalog Cases

Each promoted component gets catalog cases in `DSGallerySections`:

### 5.1 Operational States Section (new)

- All 15 `DSStatusDot` variants rendered in a grid
- Animated variants (running, exposed) shown with pulse
- Operational state color tokens labeled

### 5.2 Enhanced Molecules Section

- `DSMetricTile` with each health state (healthy, degraded, error, disabled)
- `DSMetricTileCompact` with health states
- `DSStateSurface` with new constructors (disabled, stale, degraded, excluded)
- `DSTaskCard` cases for default/complete, selected/partial, missing proof,
  and a narrow viewport with a long title
- Long-label metric example to make truncation behavior inspectable in the
  gallery, alongside the health variants

### 5.3 Edge-condition evidence

The operational gallery/test contract includes component-specific evidence for:

- long text on `DSMetricTile` and `DSTaskCard`;
- narrow viewports at 180px (`DSMetricTile`) and 200px (`DSTaskCard`);
- high text scaling at `TextScaler.linear(2.0)` for both components.

---

## 6. Test Requirements

| Component | Test Type | Cases |
|-----------|----------|-------|
| `DSStatusDot` | Widget | All 15 constructors render, each has correct color, animated variants exist |
| `DSMetricTile` | Widget | Default render, each health state, compact variant with health; long text, 180px viewport, and 2.0x text scale |
| `DSStateSurface` | Widget | All 7 constructors render, correct icon/color per state |
| `DSTaskCard` | Widget | Default/selected/proof-state behavior; long title at 200px viewport and 2.0x text scale |
| All promoted | Barrel | `Prism*` aliases resolve to correct types |

---

## 7. Files Modified/Created

| File | Action |
|------|--------|
| `docs/design/operational-component-mvp.md` | **Created** — this document |
| `packages/warp_prism_ui/lib/src/tokens/ds_colors.dart` | **Modified** — add missing operational state aliases |
| `packages/warp_prism_ui/lib/src/atoms/ds_status_dot.dart` | **Modified** — add 10 new operational constructors |
| `packages/warp_prism_ui/lib/src/molecules/ds_metric_tile.dart` | **Modified** — add `DSMetricTileHealth` enum and health-aware rendering |
| `packages/warp_prism_ui/lib/src/molecules/ds_state_surface.dart` | **Modified** — add 4 operational constructors |
| `packages/warp_prism_ui/lib/src/prism_aliases.dart` | **Created** — Prism* type aliases |
| `packages/warp_prism_ui/lib/warp_prism_ui.dart` | **Modified** — export prism_aliases |
| `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` | **Modified** — add operational states section |
| `packages/warp_prism_ui/test/molecules/operational_components_test.dart` | **Created** — tests for enhanced components |
| `docs/changelog/` | **Modified** — changelog entry |

---

## 8. Promotion Checklist

- [x] **Read existing code**: All relevant files read before modification.
- [x] **Catalog case exists**: Operational states section added to gallery.
- [x] **State matrix documented**: §3 above.
- [x] **Widget test passes**: `operational_components_test.dart` + `design_system_gallery_test.dart` + related suites — **213/213 pass** (2026-08-23 path-to-100 re-verify; includes DSTaskCard, DSMetricTile health variants, long-text, narrow viewport, 2.0x high text scale).
- [x] **Semantics test passes**: DSStatusDot tooltip Semantics; operational badge/status coverage in `ds_operational_state_test.dart`.
- [ ] **Golden test baseline**: Deferred — separate golden files exist for status_dot/metric_tile; not required to close 1106 MVP scope.
- [x] **Prism* public alias created**: `prism_aliases.dart` created and exported.
- [x] **Dependency isolation verified**: Zero imports from apps, Riverpod, go_router, or data layer.
- [x] **No new primitive tokens**: All new tokens are semantic aliases of existing primitives.
- [x] **Changelog entry added**: `docs/changelog/20260608-213011-0000-2026-06-08-task-1106-operational-component-mvp-repair-bot.md` (+ 2026-07-18 path-to-100 note).
- [x] **Melos analyze (monorepo)**: `melos run analyze` → **SUCCESS** (2026-07-18). Uses `--no-fatal-infos`; observatory still emits prefer_const infos (non-fatal; not 1106-owned).
- [x] **Package lib analyze**: `flutter analyze lib` on `warp_prism_ui` → **0 errors/warnings** (4 residual infos outside MVP files, exit 0).
- [~] **Melos full test**: Full monorepo `melos run test` is multi-app; 1106 package gate is **scoped operational suites + gallery registry**. Package-wide organism suites owned by 1112–1123 / EPIC-15/16.
