# Warp Prism Design System — Inventory and Mismatch Ledger

> **Generated**: 2026-06-07
> **Last refreshed**: 2026-07-17 (drain review inventory currency — EPIC 15/16 organism expansion)
> **Task**: 0014 — DS Token Contract and Inventory
> **Source**: Direct inspection of all **156** Dart files under `packages/warp_prism_ui/lib/src/` (live package reality as of 2026-07-17)

---

## 0. Live Package Snapshot (2026-07-17)

| Layer | Dart files | Approx. lines | Notes |
|-------|------------|---------------|-------|
| Tokens | **10** | ~1,402 | Includes `DSBreakpoints` + `DSOperationalState` |
| Atoms | **10** | ~1,972 | +`DSSparkline` since original inventory |
| Molecules | **21** | ~3,799 | Includes `DSInteractiveSurface` (`ds_interactive_surface.dart`) + toast/skeleton/drag/health/state/shimmer/uptime |
| Organisms | **109** | ~36,009 | Baseline operational suite + EPIC 15/16 harvest organisms (nested feature folders) |
| Templates | **2** | ~548 | Barrel + `master_detail_template.dart` (hosts 3 template classes) |
| Gallery | **3** | ~6,473 | Public design-system gallery pages |
| Top-level | **1** | ~1,412 | `prism_aliases.dart` (Prism* public API surface) |
| **Total `lib/src`** | **156** | ~51,615 | Matches `find packages/warp_prism_ui/lib/src -name '*.dart' \| wc -l` |

Public package barrel: `packages/warp_prism_ui/lib/warp_prism_ui.dart` exports only `src/prism_aliases.dart` + gallery. **DS\* names are internal** and are imported by package tests via `package:warp_prism_ui/src/...`.

Live layer counts (2026-07-17 drain review):

```text
find packages/warp_prism_ui/lib/src -name '*.dart' | wc -l
# → 156

# by top-level under lib/src:
#  109 organisms
#   21 molecules
#   10 tokens
#   10 atoms
#    3 gallery
#    2 templates
#    1 prism_aliases.dart
```

> **Note**: Detailed file tables in §1.x below remain a useful baseline catalog for tokens/atoms/molecules. Organism file enumeration in §1.4 was frozen at the pre–EPIC-15/16 **38**-file baseline; **authoritative organism/total counts are this §0 snapshot (109 / 156)**.

---

## 1. File Inventory

### 1.1 Tokens (10 files, ~1,402 lines)

| File | Class / Type | Purpose | Lines |
|------|--------------|---------|-------|
| `tokens/tokens.dart` | — | Barrel export (all 9 token modules) | 10 |
| `tokens/ds_colors.dart` | `DSColors` | Color tokens — obsidian, accents, status, governance, text, border, lane, asset, **operational-state aliases** | 254 |
| `tokens/ds_typography.dart` | `DSTypography` | Typography scale — display, heading, body, label, code, numeric | 186 |
| `tokens/ds_spacing.dart` | `DSSpacing` | Spacing scale — base (xxs..massive) + semantic layout dimensions | 72 |
| `tokens/ds_radii.dart` | `DSRadii` | Border radii — base (none..full) + semantic (card, button, chip, input, panel, modal) | 47 |
| `tokens/ds_shadows.dart` | `DSShadows` | Elevation shadows + glow helpers (cyan/violet/gold/success/error/warning) + inner shadow | 116 |
| `tokens/ds_motion.dart` | `DSMotion` | Durations, curves, semantic animation timings | 66 |
| `tokens/ds_semantics.dart` | `DSSemantics` | Pre-composed semantic `TextStyle`s (status, governance, asset, lane, proof) | 167 |
| `tokens/ds_breakpoints.dart` | `DSBreakpoints` | Responsive width thresholds for shell/templates | 32 |
| `tokens/ds_operational_state.dart` | `DSOperationalState`, `DSOperationalSeverity`, `DSOperationalCategory`, `DSOperationalStateUI` | Canonical 15-state operational vocabulary + UI metadata | 452 |

#### 1.1.1 `DSBreakpoints` contract

| Token | Value | Usage |
|-------|-------|-------|
| `narrow` | 600 | Search collapses; detail full-screen; min width before sidebar shows |
| `sidebarCollapse` | 800 | Sidebar icon-only below; expanded with labels above |
| `timelineDetail` | 1000 | Timeline + detail side-by-side above |
| `masterDetailSideBySide` | 1200 | Master-detail side-by-side above; overlay/full-screen below |

Width ranges (documented in source):
- **narrow**: `< 600`
- **medium**: `600–1199`
- **wide**: `>= 1200`

#### 1.1.2 `DSOperationalState` contract

15 states across 4 categories:

| Category | States |
|----------|--------|
| Lifecycle | `pending`, `running`, `approved`, `rejected`, `promoted`, `archived` |
| Health | `healthy`, `degraded`, `error`, `disabled` |
| Verification | `unverified`, `exposed`, `redacted` |
| Governance | `stale`, `excluded` |

Supporting types:
- `DSOperationalSeverity`: `info`, `success`, `warning`, `error`, `critical`
- `DSOperationalCategory`: `lifecycle`, `health`, `verification`, `governance`
- Extension `DSOperationalStateUI` on `DSOperationalState` — color/icon/label/behavior via existing `DSColors` + `DSIcons` (no new hex values)

Color aliases on `DSColors` (operational):
`statusPending`, `statusRunning`, `statusApproved`, `statusRejected`, `statusPromoted`, `statusArchived`, `statusHealthy`, `statusDegraded`, `statusOpError`, `statusDisabled`, `statusUnverified`, `statusExposed`, `statusRedacted`, `statusStale`, `statusExcluded`

### 1.2 Atoms (10 files, ~1,972 lines)

| File | Class(es) | Purpose |
|------|-----------|---------|
| `atoms/atoms.dart` | — | Barrel export |
| `atoms/ds_text.dart` | `DSText`, `DSTextVariant` | Semantic text (18 variants) |
| `atoms/ds_icon.dart` | `DSIcon`, `DSIconSize`, `DSIcons` | Icon component + semantic icon constants |
| `atoms/ds_badge.dart` | `DSBadge`, `DSBadgeVariant`, `DSBadgeSize` | Count/status badge |
| `atoms/ds_chip.dart` | `DSChip`, `DSChipSize` | Label chip |
| `atoms/ds_status_dot.dart` | `DSStatusDot` | Status indicator with animation |
| `atoms/ds_divider.dart` | `DSDivider`, `DSGlowDivider` | Dividers |
| `atoms/ds_glow_border.dart` | `DSGlowBorder` | Animated glow border |
| `atoms/ds_glass_panel.dart` | `DSGlassPanel`, `DSGlassPanelSimple`, `DSGlassPanelVariant` | Glass panels |
| `atoms/ds_sparkline.dart` | `DSSparkline` | Compact sparkline atom |

### 1.3 Molecules (21 files, ~3,589 lines)

| File | Class(es) | Purpose |
|------|-----------|---------|
| `molecules/molecules.dart` | — | Barrel export (includes interactive surface) |
| `molecules/ds_interactive_surface.dart` | `DSInteractiveSurface` | Shared a11y interactive chrome (focus ring, 48×48 target, keyboard activate); public alias `PrismInteractiveSurface` |
| `molecules/ds_search_bar.dart` | `DSSearchBar` | Search input |
| `molecules/ds_filter_chip_group.dart` | `DSFilterChipGroup`, `DSFilterOption` | Filter chips |
| `molecules/ds_asset_card.dart` | `DSAssetCard` | Asset card (uses `DSInteractiveSurface`) |
| `molecules/ds_metric_tile.dart` | `DSMetricTile`, `DSMetricTileCompact`, `DSTrend`, `DSMetricTileHealth` | Metric tiles |
| `molecules/ds_provenance_pill.dart` | `DSProvenancePill`, `DSProvenanceSize` | Provenance indicator |
| `molecules/ds_task_card.dart` | `DSTaskCard` | Task card |
| `molecules/ds_evidence_row.dart` | `DSEvidenceRow`, `DSEvidenceIndicator`, `DSEvidenceState` | Evidence row |
| `molecules/ds_timeline_marker.dart` | `DSTimelineMarker` | Timeline marker |
| `molecules/ds_toast.dart` | `DSToast`, `DSToastEntry`, `DSToastSeverity` | Toast atom-of-molecule |
| `molecules/ds_toast_manager.dart` | `DSToastManager`, `DSToastManagerState` | Toast overlay manager |
| `molecules/ds_shimmer.dart` | `DSShimmer` | Shimmer loading effect |
| `molecules/ds_skeleton_card.dart` | `DSSkeletonCard` | Skeleton card placeholder |
| `molecules/ds_skeleton_text_line.dart` | `DSSkeletonTextLine` | Skeleton text line |
| `molecules/ds_skeleton_table_rows.dart` | `DSSkeletonTableRows` | Skeleton table rows |
| `molecules/ds_state_surface.dart` | `DSStateSurface`, `DSStateType` | Empty/loading/error surface |
| `molecules/ds_draggable_card.dart` | `DSDraggableCard`, `DSDragPayload`, `DSDragReorderEvent`, `DSDragMoveEvent` | Drag source |
| `molecules/ds_drop_target.dart` | `DSDropTarget` | Drop target |
| `molecules/ds_health_card.dart` | `DSHealthCard` | Health summary card |
| `molecules/ds_uptime_bar.dart` | `DSUptimeBar` | Uptime visualization |

### 1.4 Organisms (38 files, ~9,052 lines)

Core shell / board / story surfaces:

| Area | Key classes |
|------|-------------|
| Shell | `DSShell`, `DSShellResponsive`, `DSSidebar`, `DSSidebarItem`, `DSTopbar`, `DSTopbarAction` |
| Board / timeline | `DSLaneBoard`, `DSLane`, `DSLaneTask`, `DSTimeline`, `DSTimelineEntry`, `DSTimelineGrouped`, `DSTimelineGroup` |
| Detail / story | `DSDetailInspector`, `DSDetailSection`, `DSPropertyRow`, `DSLinkRow`, `DSStoryPanel`, `DSStoryInsight`, `DSStoryNarrativeInsight`, `DSStoryCardQuick` |
| Graph (legacy + suite) | `DSGraphCanvas`, `GraphNode`, `GraphEdge` + `graph/` (`GraphCanvas`, `GraphModel`, `GraphPainter`, `ForceDirectedLayout`, …) |
| Status / resilience | `DSStatusGrid`, `DSHealthCardData`, `DSErrorBoundary`, `DSFallbackView` |
| Tab bar | `DSTab`, `DSTabBar`, `DSTabController`, `DSTabView` |
| Virtual scroll | `DSVirtualScrollConfig`, `DSVirtualList`, `DSVirtualGrid` |
| Log viewer | `DSLogViewer`, `DSLogEntry`, `DSLogEntryWidget`, `DSLogFilterBar`, `DSLogSeverity` |
| Data table | `DSDataTable`, `DSDataColumn`, `DSDataRow`, `DSTablePagination`, cell types, sort types |
| Command palette | `DSCommandPalette`, `DSCommand`, `DSCommandCategory`, `DSCommandPaletteShortcut` |
| Split pane | `DSSplitPane` |
| Markdown / code | `DSMarkdownRenderer`, `DSCodeBlock` |

Organism files live both at `organisms/*.dart` and under feature subfolders (`tab_bar/`, `virtual_scroll/`, `log_viewer/`, `data_table/`, `command_palette/`, `split_pane/`, `markdown_renderer/`, `code_block/`, `graph/`).

### 1.5 Templates (2 files, ~548 lines)

| File | Class(es) | Purpose |
|------|-----------|---------|
| `templates/templates.dart` | — | Barrel export |
| `templates/master_detail_template.dart` | `MasterDetailTemplate`, `CanvasTemplate`, `TimelineTemplate` | Page-level layouts |

### 1.6 Gallery (3 files, ~3,501 lines)

| File | Purpose |
|------|---------|
| `gallery/design_system_gallery_page.dart` | Gallery page host |
| `gallery/design_system_gallery_registry.dart` | Component registry |
| `gallery/design_system_gallery_sections.dart` | Section definitions |

### 1.7 Top-level / Public Barrel

| File | Purpose |
|------|---------|
| `packages/warp_prism_ui/lib/warp_prism_ui.dart` | Public package barrel — Prism* API + gallery only |
| `packages/warp_prism_ui/lib/src/prism_aliases.dart` | Prism* typedefs/aliases over internal DS* types (includes `PrismInteractiveSurface`) |

---

## 2. Canonical Naming Convention

**Standard**: All design system implementation classes use `DS` prefix (uppercase S). Consumer apps use `Prism*` via the public barrel.

| Layer | Convention | Examples |
|-------|-----------|----------|
| Tokens | `DS{Domain}` | `DSColors`, `DSTypography`, `DSSpacing`, `DSRadii`, `DSShadows`, `DSMotion`, `DSSemantics`, `DSBreakpoints`, `DSOperationalState` |
| Atoms | `DS{Component}` | `DSText`, `DSIcon`, `DSBadge`, `DSChip`, `DSStatusDot`, `DSDivider`, `DSGlowBorder`, `DSGlassPanel`, `DSSparkline` |
| Molecules | `DS{Component}` | `DSInteractiveSurface`, `DSSearchBar`, `DSAssetCard`, `DSToast`, `DSStateSurface`, … |
| Organisms | `DS{Component}` | `DSShell`, `DSTabBar`, `DSVirtualList`, `DSLogViewer`, … |
| Templates | `{Name}Template` | `MasterDetailTemplate`, `CanvasTemplate`, `TimelineTemplate` |
| Graph suite (internal) | Graph* / Force* | `GraphCanvas`, `GraphModel`, `ForceDirectedLayout` (non-DS names, co-located under organisms/graph) |
| Public API | `Prism{Name}` | Via `prism_aliases.dart` (e.g. `PrismInteractiveSurface`) |

**Verification (2026-07-09)**: `rg 'Ds[A-Z]' packages/warp_prism_ui/lib/src/` returns **0 matches**. No competing `Ds*` convention remains.

---

## 3. Color Token Contract

### 3.1 Obsidian Backgrounds (6 tokens)
| Token | Hex | Usage |
|-------|-----|-------|
| `obsidianDeep` | `#050508` | Root background |
| `obsidianBase` | `#0A0A0F` | Primary surface |
| `obsidianElevated` | `#0F1015` | Cards, panels |
| `obsidianHover` | `#14141C` | Interactive hover |
| `obsidianActive` | `#1A1A24` | Active/selected |
| `glassOverlay` | `#1E1E28` | Glass panel overlay |

### 3.2 Energy Accents (9 tokens)
| Token | Hex |
|-------|-----|
| `accentCyan` / `Muted` / `Dim` | `#00D4FF` / `#0099B8` / `#006680` |
| `accentViolet` / `Muted` / `Dim` | `#8B5CF6` / `#6B4CD4` / `#4C3899` |
| `accentGold` / `Muted` / `Dim` | `#FFB800` / `#CC9400` / `#997000` |

### 3.3 Semantic Status (12 tokens)
Success / Warning / Error / Info × (primary, muted, dim) — hex values unchanged from prior contract.

### 3.4 Governance Colors (6 tokens)
`governanceCanonical`, `governanceLocal`, `governanceGenerated`, `governanceAppendOnly`, `governanceArchive`, `governanceMock`

### 3.5 Text Colors (5 tokens)
| Token | Hex (live) | Usage |
|-------|------------|-------|
| `textPrimary` | `#F0F0F5` | High emphasis |
| `textSecondary` | `#A0A0B0` | Medium emphasis |
| `textTertiary` | `#8888A0` | Low emphasis (updated from earlier `#606070`) |
| `textDisabled` | `#505060` | Disabled (updated from earlier `#404050`) |
| `textInverse` | `#0A0A0F` | Light backgrounds |

### 3.6 Border / Lane / Asset
Unchanged structure: 4 border tokens, 5 lane tokens, 9 asset-kind tokens.

### 3.7 Operational State Color Aliases (15 tokens)
See §1.1.2 — all reuse existing palette via const aliases.

### 3.8 Utility
`transparent`, `white`, `black`

### 3.9 Lookup Methods
- `DSColors.forAssetKind(String kind)`
- `DSColors.forLane(String lane)`
- `DSColors.forCanonicity(String canonicity)`

---

## 4. Typography Contract

### 4.1 Font Families
| Token | Value | pubspec Status |
|-------|-------|----------------|
| `fontFamilyMono` | `JetBrainsMono` | ✅ Declared |
| `fontFamilySans` | `Inter` | ⚠️ NOT declared — system sans fallback |

### 4.2 Font Weights
`weightLight` w300 · `weightRegular` w400 · `weightMedium` w500 · `weightSemibold` w600 · `weightBold` w700

### 4.3 Type Scale (18 styles)
displayLarge/Medium/Small · headingLarge/Medium/Small · bodyLarge/Medium/Small · labelLarge/Medium/Small · codeLarge/Medium/Small · numericLarge/Medium/Small

---

## 5. Spacing Contract

Base: `xxs` 2 → `massive` 64 (10 steps).  
Semantic: card insets, list gaps, sidebar widths, inspector width, topbar height, card min height, icon button sizes.

---

## 6. Radii Contract

Base: `none` 0 → `full` 9999.  
Semantic: `card`, `button`, `chip`, `input`, `panel`, `modal`.

---

## 7. Motion Contract

Durations: `instant` 0 → `slowest` 500ms.  
Curves: `standard`, `enter`, `exit`, `emphasized`, `spring`, `linear`.  
Semantic: `hoverDuration`, `focusDuration`, `pageDuration`, `panelDuration`, `staggerDelay`.

---

## 8. Shadows Contract

Elevations 1–4, glow helpers (`glowCyan` / `Violet` / `Gold` / `Success` / `Error` / `Warning` with intensity), `innerShadow`.

---

## 9. Mismatch Ledger

### 9.1 Resolved (from draft.md and prior reviews)

| Claim | Actual | Status |
|-------|--------|--------|
| `DsColors` vs `DSColors` | All `DSColors` | ✅ Resolved |
| `DsShell(... body: ...)` | `DSShell(... content: ...)` | ✅ Resolved |
| Competing `Ds*` API | 0 matches under `lib/src` | ✅ Resolved |
| Missing token tests | `packages/warp_prism_ui/test/tokens/` (contract + operational state) | ✅ Resolved |
| Inventory undercount (38 files / 7 tokens) | Refreshed to 10 tokens including breakpoints + operational state | ✅ Resolved |
| Inventory undercount (84 files / 20 molecules) | Live **156** / **21** molecules including `DSInteractiveSurface` (organisms expanded post-EPIC 15/16) | ✅ Resolved (2026-07-17 count refresh) |
| Package residual described as 🔴 ERROR-class | Live package analyze **0 ERROR / 0 WARNING / 137 INFO** (lint/hint only) | ✅ Severity corrected (2026-07-09); counts refreshed 2026-07-17 |
| “No app main.dart” Critical | `apps/{catalog,cybercore,observatory}/lib/main.dart` all exist | ✅ Stale claim removed |

### 9.2 Active Gaps (honest scope)

| Issue | Severity | Scope owner | Description |
|-------|----------|-------------|-------------|
| **Inter font not declared** | 🟡 Medium | Future typography task | `DSTypography.fontFamilySans = 'Inter'` but only `JetBrainsMono` in pubspec |
| **No `ThemeData` / `ThemeExtension` bridge** | 🟡 Medium | Explicitly delegated (Task 0014 Test Requirements) | Tokens are static constants; Theme bridge is out of this task |
| **Package-wide INFO lint residual** | 🟢 Low (package hygiene) | Downstream UI sweep / format+const cleanup | Full-package `dart analyze --format=machine .` → **137 INFO**, **0 ERROR**, **0 WARNING** (2026-07-17). Dominated by `prefer_const_constructors` (91), `deprecated_member_use` (22), and minor style hints. **Not a token-layer gate and not ERROR-class.** |

### 9.3 Font Contract Decision (unchanged options)
1. Add Inter to assets + pubspec  
2. Monospace-first (JetBrainsMono only)  
3. Keep system sans fallback (current)

---

## 10. Barrel Export Verification

```
warp_prism_ui.dart                 (public — Prism* + gallery only)
  → src/prism_aliases.dart
  → src/gallery/*

Internal barrels (DS* implementation; package-private via src/ import):
  src/tokens/tokens.dart           (10 token modules)
  src/atoms/atoms.dart             (10 atom modules)
  src/molecules/molecules.dart     (21 molecule modules; exports ds_interactive_surface first)
  src/organisms/organisms.dart     (109 organism dart files under tree; barrel exports family modules)
  src/templates/templates.dart     (2 template modules)
```

Token barrel exports (live `tokens.dart`):
`ds_breakpoints`, `ds_colors`, `ds_operational_state`, `ds_typography`, `ds_spacing`, `ds_radii`, `ds_shadows`, `ds_motion`, `ds_semantics`.

No duplicate `Ds*` / `DS*` dual convention. Public surface is Prism*-only (including `PrismInteractiveSurface`).

---

## 11. Analyzer Gate Scope (Task 0014 honesty)

### 11.1 In-scope (Task 0014 exit conditions)

| Command | Scope | Expected | Live (2026-07-09 builder-fixer) |
|---------|-------|----------|----------------------------------|
| `flutter test --concurrency=1 --no-pub test/tokens/` | Token contract + operational state tests | 0 failures | **123/123** passed, EXIT 0 |
| `flutter analyze --no-pub lib/src/tokens test/tokens` | Token sources + token tests | 0 issues | **No issues found!** EXIT 0 |
| `dart format --output=none --set-exit-if-changed lib/src/tokens test/tokens` | Token format | 0 changed | **0 changed** EXIT 0 |

These prove the **token contract and inventory** deliverables.

### 11.2 Explicitly out of scope for Task 0014

| Command | Why out of scope |
|---------|------------------|
| Full-package `dart analyze` / `flutter analyze packages/warp_prism_ui` | Surfaces **downstream** organism/const/lint hygiene. Residual is **INFO-only** as of 2026-07-09 (not ERROR-class public-barrel compile failures). Owned by later DS composition / public-API / lint-sweep tasks — not token inventory. |
| Full `test/organisms/**` suite | Not part of token contract exit conditions |

### 11.3 Known package residual class (documented, not fixed here)

Historical independent review (2026-06-30, score 78/100) observed full-package analyzer ≈880 issues including ERROR-class test imports of internal DS* symbols. **That ERROR class is no longer live.**

Live full-package residual (2026-07-17):

```text
cd packages/warp_prism_ui
dart analyze --format=machine .
# → 137 INFO, 0 WARNING, 0 ERROR  (EXIT 0)

# Top codes (INFO):
#    91 PREFER_CONST_CONSTRUCTORS
#    22 DEPRECATED_MEMBER_USE
#    10 PREFER_CONST_DECLARATIONS
#     5 PREFER_INITIALIZING_FORMALS
#     4 NO_LEADING_UNDERSCORES_FOR_LOCAL_IDENTIFIERS
#     4 DANGLING_LIBRARY_DOC_COMMENTS
#   …minor style hints
```

Remediation for INFO residual belongs to:
- Const/lint cleanup sweeps
- Deprecation migrations
- Not to the token inventory itself

---

## 12. Test Coverage for Tokens

| File | Role |
|------|------|
| `packages/warp_prism_ui/test/tokens/ds_token_contract_test.dart` | Structural contract for colors, type, space, radii, shadows, motion, semantics, breakpoints, barrel |
| `packages/warp_prism_ui/test/tokens/ds_operational_state_test.dart` | 15-state vocabulary + severity/category/UI extension |

Package-wide test tree (context only): Dart tests under `packages/warp_prism_ui/test/` (tokens, atoms, molecules, organisms, templates, gallery, goldens, boundaries, accessibility, performance).

---

## 13. Live Command Evidence (2026-07-09 builder-fixer)

Environment: Flutter 3.44.1 / Dart 3.12.1.

```text
# cwd: packages/warp_prism_ui

$ flutter analyze --no-pub lib/src/tokens test/tokens
Analyzing 2 items...
No issues found! (ran in 2.3s)
# EXIT 0

$ flutter test --concurrency=1 --no-pub test/tokens/
...
00:03 +123: All tests passed!
# EXIT 0

$ dart format --output=none --set-exit-if-changed lib/src/tokens test/tokens
Formatted 12 files (0 changed) in 0.08 seconds.
# EXIT 0

$ dart analyze --format=machine .
# 137 INFO lines, 0 ERROR, 0 WARNING; analyzer process EXIT 0 (2026-07-17)

$ find lib/src -name '*.dart' | wc -l
156

$ find lib/src/molecules -name '*.dart' | wc -l
21
# includes ds_interactive_surface.dart (class DSInteractiveSurface)

$ find lib/src/organisms -name '*.dart' | wc -l
109
```

App entrypoints (stale “no main.dart” gap disproved):

```text
apps/catalog/lib/main.dart
apps/cybercore/lib/main.dart
apps/observatory/lib/main.dart
```

---

*Report originally generated by Task 0014 execution. Refreshed 2026-07-09 (path-to-100 after 78) for `DSBreakpoints`/`DSOperationalState`. Refreshed again 2026-07-09 (builder-fixer after 88/100) for live **85**/`DSInteractiveSurface` inventory honesty and INFO-only package residual severity. Refreshed 2026-07-17 for post–EPIC-15/16 **156**/`lib/src` inventory currency and package residual **137 INFO**.*

## Residual INFO currency — 2026-07-17

| Scope | Live count | Severity |
|-------|------------|----------|
| `packages/warp_prism_ui/lib` | **24 INFO**, 0 ERROR, 0 WARNING | INFO lint residual |
| `packages/warp_prism_ui` (full package incl. tests) | **137 INFO**, 0 ERROR, 0 WARNING | INFO lint residual |

Prior claimed 158/144/23 superseded by this count. Token-layer gate remains clean (0 issues on `lib/src/tokens` + `test/tokens`).
