# EPIC 10 — Polish Baseline Audit

> **Generated**: 2026-06-07 by Task 1000 (historical root-`lib/` snapshot)
> **Live refresh**: 2026-07-09 by gt-evidence-refresher (builders) — monorepo path remap + validation unblocked
> **Scope**: Reconcile Flutter codebase, stack docs, and EPIC 10 polish goals
> **Method**: Original read-only audit of Where-table hosts; 2026-07-09 revalidation against Melos monorepo paths

---

## 0. Live Monorepo Delta (2026-07-09) — SOURCE OF TRUTH FOR PATHS

The 2026-06-07 body (§1–§11) remains the **historical baseline snapshot** of the pre-Melos root-`lib/` tree. It is **not** the live file map. Use this section for current ownership.

### 0.1 Topology

| Surface | Live path | Status vs 2026-06-07 |
|---------|-----------|----------------------|
| Workspace root | Melos `pubspec.yaml` (`workspace: packages/**, apps/**`) | **Changed** — not a single Flutter app |
| Root `lib/` | **ABSENT** | Historical host paths non-reproducible |
| Design system | `packages/warp_prism_ui/lib/src/` | Migrated; **128** package `*.dart` files total (**86** lib + **42** under `test/`; **40** `*_test.dart`) |
| Observatory app | `apps/observatory/` | `main.dart` + features: shell, overview, map, operate, history, governance, asset_detail |
| Catalog / gallery | `apps/catalog/` + `packages/warp_prism_ui/lib/src/gallery/` | **Exists** (was missing) |
| CyberCore pilot | `apps/cybercore/` | Out of EPIC 10 host scope |
| README | Flutter + Melos monorepo docs | **Resolved** — no longer Next.js/v0 |
| Flutter SDK | Flutter 3.44.1 / Dart 3.12.1 | **Unblocked** |

### 0.2 Path Remap (task Where table → live hosts)

| Historical (2026-06-07) | Live monorepo host |
|-------------------------|--------------------|
| `lib/design_system/templates/master_detail_template.dart` | `packages/warp_prism_ui/lib/src/templates/master_detail_template.dart` |
| `lib/design_system/organisms/ds_shell.dart` | `packages/warp_prism_ui/lib/src/organisms/ds_shell.dart` |
| `lib/design_system/organisms/ds_sidebar.dart` | `packages/warp_prism_ui/lib/src/organisms/ds_sidebar.dart` |
| `lib/design_system/organisms/ds_topbar.dart` | `packages/warp_prism_ui/lib/src/organisms/ds_topbar.dart` |
| `lib/design_system/organisms/ds_lane_board.dart` | `packages/warp_prism_ui/lib/src/organisms/ds_lane_board.dart` |
| `lib/design_system/atoms/ds_glass_panel.dart` | `packages/warp_prism_ui/lib/src/atoms/ds_glass_panel.dart` |
| `lib/data/parsers/workspace_parser.dart` | `apps/observatory/lib/data/parsers/workspace_parser.dart` |
| `lib/data/models/models.dart` | `apps/observatory/lib/data/models/models.dart` (legacy; backbone under same models dir) |
| *(missing)* `main.dart` / pages | `apps/observatory/lib/main.dart` + `lib/features/*` |
| *(missing)* gallery | `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_page.dart` |
| *(missing)* demo script | `docs/demo/epic-10-demo-script.md` |
| *(missing)* breakpoint tokens | `packages/warp_prism_ui/lib/src/tokens/ds_breakpoints.dart` |

### 0.3 Stack Divergence — Live Reclassification

| Item | 2026-06-07 | 2026-07-09 live | Classification |
|------|------------|-----------------|----------------|
| `README.md` Next.js | **stale doc** | Flutter/Melos monorepo README | **Resolved** (runtime-aligned doc) |
| Flutter package identity | root `pubspec` as app | Melos workspace + `warp_prism_ui` / apps | **runtime truth** |
| Root `lib/` tree | **runtime truth** | **ABSENT** after migration | **historical only** |
| `main.dart` absence | **blocked decision** | Observatory/catalog/cybercore mains exist | **Resolved as host** |
| Flutter SDK missing | validation **BLOCKED** | SDK present; scoped analyze/test runnable | **Resolved** (machine gate) |
| Mock `.md` vs `.yaml` | **stale doc** / format gap | Still a corpus-contract concern (see mock corpus tasks) | **partial / separate lane** |

### 0.4 EPIC 10 Goal Status Delta (inventory only — not full re-audit)

| Goal slice | Historical finding | Live observation (spot-check) |
|------------|--------------------|-------------------------------|
| 1010 Accessibility | textTertiary fail; no Focus/Semantics | `textTertiary` = `#8888A0`; FocusTraversal/Semantics present in shell/topbar/molecules; contrast tests exist |
| 1020 Responsive | hardcoded 1200/800/1000; no narrow | `DSBreakpoints` token exists; shell docs narrow 600px |
| 1030 States | empty only; no loading/error | shimmer/skeleton molecules + state surface tests present |
| 1040 Glass | tiers + Simple fallback | Still present (`subtle`/`elevated`/`modal` + Simple) |
| 1050 Demo narrative | no gallery/demo path | Gallery page + `docs/demo/epic-10-demo-script.md` exist; feature screens host narrative |

**Handoff table in §4 is HISTORICAL** (2026-06-07 basename scopes + risks). For live edit targets use **§0.2 path remap** and **§0.6 live handoff**. Later EPIC 10 slice tasks own implementation progress; this baseline’s durable value is the goal→file ownership map plus the live path remap and live handoff below.

### 0.5 Validation Results (2026-07-09)

| Command | Result | Notes |
|---------|--------|-------|
| `flutter --version` | Flutter 3.44.1 / Dart 3.12.1 | Unblocked |
| `test -d lib` | `ROOT_LIB:ABSENT` | Confirms historical paths superseded |
| Host path existence (Where remap) | All **EXISTS** | See §0.2 |
| `dart analyze --format=machine packages/warp_prism_ui/lib` | **82 issues: ERROR 0, WARNING 1, INFO 81** | UI package host for polish widgets |
| `dart analyze --format=machine` observatory demo-feature scope (`lib/main.dart`, `lib/app`, shell/map/operate/history/governance/overview) | **48 issues: ERROR 0, WARNING 0, INFO 48** | Demo host surfaces; not monorepo-wide claim |
| `flutter test` (scoped polish) `packages/warp_prism_ui/test/accessibility_focus_contrast_test.dart` + `state_surface_test.dart` | **+43 All tests passed!** | Docs-audit proof only; full monorepo suite not claimed |
| Test inventory | ui 40, observatory 39, catalog 1, cybercore 2 `*_test.dart` | Was 0 at original audit |

### 0.6 Live Handoff Table for Tasks 1010–1050 (monorepo-qualified)

| Task | Scope | Live candidate hosts (read/modify) | Main residual risk (inventory) |
|------|-------|------------------------------------|--------------------------------|
| **1010 — Accessibility** | Contrast, focus, keyboard, semantics | `packages/warp_prism_ui/lib/src/tokens/ds_colors.dart`, `…/atoms/ds_text.dart`, `…/organisms/ds_sidebar.dart`, `…/ds_topbar.dart`, `…/ds_lane_board.dart`, `…/ds_shell.dart` (`FocusTraversalGroup`), `…/tokens/ds_semantics.dart`, `…/test/accessibility_focus_contrast_test.dart` | Contrast floor and focus/semantics already land in UI package; residual risk is **coverage gaps** on secondary molecules/organisms and demo-host proof in observatory, not “missing app”. |
| **1020 — Responsive** | Breakpoints, collapse, overflow | `packages/warp_prism_ui/lib/src/tokens/ds_breakpoints.dart`, `…/organisms/ds_shell.dart`, `…/ds_topbar.dart`, `…/ds_sidebar.dart`, `…/ds_lane_board.dart`, `…/templates/master_detail_template.dart`, observatory feature shells under `apps/observatory/lib/features/{shell,map,operate,history,governance,overview}/` | Tokens exist (`narrow`=600); risk is **inconsistent consumer use** and topbar/search collapse coherence across feature hosts, not absence of breakpoints. |
| **1030 — States** | Empty / loading / error coherence | `packages/warp_prism_ui/lib/src/molecules/ds_state_surface.dart`, `…/ds_shimmer.dart`, `…/ds_skeleton_*.dart`, `…/organisms/ds_lane_board.dart`, `…/ds_timeline.dart`, `…/test/state_surface_test.dart`, observatory data load surfaces (`apps/observatory/lib/data/`, feature workspaces) | Widget kit exists; risk is **wiring consistency** on real load paths (parser/provider/feature empty-loading-error), not greenfield widgets. |
| **1040 — Performance / Glass** | Blur tiers, lazy builders, budget | `packages/warp_prism_ui/lib/src/atoms/ds_glass_panel.dart` (`subtle`/`elevated`/`modal` + `DSGlassPanelSimple`), `…/atoms/ds_glow_border.dart`, `…/organisms/ds_story_panel.dart`, `docs/reports/epic-10-glass-performance-budget.md` (if present) | Tiers + Simple fallback still present; risk is **nested blur / overuse on dense screens**, not missing glass API. |
| **1050 — Demo Narrative** | Storytelling copy, demo flow, gallery | `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_page.dart`, `…/organisms/ds_story_panel.dart`, `…/ds_timeline.dart`, `docs/demo/epic-10-demo-script.md`, `apps/observatory/lib/features/*` (Map/Operate/History/Governance hosts), `apps/catalog/` | Gallery + demo script **exist**; residual risk is **end-to-end narrative coherence** across observatory routes, not “no demo surface”. |

> §0.6 is the **live** handoff. §4 keeps the original 2026-06-07 wording for audit trail only.

---

## 1. Executive Summary (HISTORICAL — 2026-06-07)

> **SUPERSEDED for live paths and blockers** by §0. Kept as the original Task 1000 audit narrative.

The Warp-Prism project is a Flutter desktop-first ASW Observatory prototype. It contains a **40-file design system** (tokens, atoms, molecules, organisms, templates) and a **data layer** (models + YAML parser), but has **no `main.dart`, no app router, no pages, and no runnable Flutter application shell**. The `README.md` is stale Next.js boilerplate from v0. Flutter SDK is **not installed** on the audit machine, so `flutter analyze` and `flutter test` could not be executed.

EPIC 10 polish work is **conditionally blocked**: the design system widgets exist and can be polished in isolation, but no demo surface (Map, Operate, History, Governance, Gallery) exists yet to host polish.

---

## 2. Stack Divergence Classification (HISTORICAL — 2026-06-07)

> Live reclassification: §0.3. Historical table preserved for audit trail.

| Item | Classification | Evidence | Recommendation |
|------|---------------|----------|----------------|
| `README.md` Next.js content | **stale doc** | `README.md` references `npm run dev`, `app/page.tsx`, v0. File has 33 lines of Next.js boilerplate. | Replace with Flutter project README (`flutter pub get`, `flutter run`, architecture overview). |
| `pubspec.yaml` Flutter declaration | **runtime truth** | `pubspec.yaml` declares `asw_observatory`, Flutter SDK >=3.0.0, go_router, flutter_riverpod, yaml, graphview, fl_chart, collection, intl. | No change needed. |
| `lib/` Dart file tree | **runtime truth** | 40 `.dart` files across `design_system/` and `data/`. All import Flutter Material. | No change needed. |
| `main.dart` absence | **blocked decision** | No `lib/main.dart`, `lib/app/app.dart`, or `lib/app/router.dart` exist. App cannot compile. | Must be created before any polish task can run end-to-end. |
| Mock data format | **stale doc** | `prompt.txt` requires `.md` with YAML frontmatter; existing mocks are `.yaml` pure files under `mock_workspace/`. `pubspec.yaml` declares asset paths under `assets/mock_workspace/`. | Align mock data to `.md` + frontmatter or update prompt contract. |

---

## 3. EPIC 10 Goal → Real Flutter File Matrix (HISTORICAL — 2026-06-07)

> **Not live status.** Status columns below snapshot pre-Melos root-`lib/` polish gaps. For live path ownership see §0.2; for 2026-07-09 goal delta see §0.4; for monorepo-qualified handoff see §0.6.

### 3.1 Accessibility (contrast, focus, keyboard)

| Goal | Files that own it today | Status |
|------|------------------------|--------|
| WCAG 4.5:1 contrast for text | `ds_colors.dart` (defines all text/background colors), `ds_text.dart` (applies colors) | **Partially met**. `textTertiary` (#606070) on `obsidianDeep` (#050508) yields ~2.7:1 — fails WCAG AA for normal text. `textSecondary` (#A0A0B0) passes at ~6.8:1. `textPrimary` (#F0F0F5) passes at ~17:1. |
| Keyboard focus traversal | `ds_sidebar.dart`, `ds_topbar.dart`, `ds_lane_board.dart` | **Missing**. No `FocusNode`, `FocusTraversalGroup`, or `Shortcuts` widgets found anywhere. All interactive widgets use `GestureDetector` + `MouseRegion` only — no keyboard activation. |
| Visible focus indicators | All atoms/molecules/organisms | **Missing**. No `Focus`-aware decoration, no focus ring styles in tokens, no `FocusTraversalPolicy` defined. |
| Semantic labels | `ds_text.dart`, `ds_status_dot.dart`, `ds_icon.dart` | **Missing**. No `Semantics` widget wrappers found in any component. |

### 3.2 Responsive Layout

| Goal | Files that own it today | Status |
|------|------------------------|--------|
| Breakpoints for shell adaptation | `ds_shell.dart` (DSShellResponsive: 1200px wide, 800px sidebar) | **Exists but partial**. Two breakpoints defined (1200, 800). No narrow/mobile breakpoint. Sidebar collapses at <800px. Inspector hides at <1200px. |
| Master-detail responsive split | `master_detail_template.dart` (1200px side-by-side, 800px overlay, <800px full-detail) | **Exists**. Three responsive modes implemented. |
| Timeline responsive split | `master_detail_template.dart` (TimelineTemplate: 1000px breakpoint) | **Exists**. Uses 1000px threshold. |
| Lane board horizontal overflow | `ds_lane_board.dart` (SingleChildScrollView horizontal) | **Exists**. Lanes scroll horizontally. Clamp 280-320px per lane. |
| Topbar search collapse | `ds_topbar.dart` | **Missing**. Search bar is always 300px fixed width; no collapse behavior for narrow screens. |

**Breakpoint inventory** (all hardcoded, not centralized):

| Value | Where | Purpose |
|-------|-------|---------|
| 1200px | `ds_shell.dart` (DSShellResponsive.breakpoint) | Full sidebar + inspector |
| 1200px | `master_detail_template.dart` (_MasterDetailTemplateState) | Side-by-side master-detail |
| 1000px | `master_detail_template.dart` (TimelineTemplate) | Timeline + detail panel |
| 800px | `ds_shell.dart` (DSShellResponsive) | Full vs collapsed sidebar |
| 800px | `master_detail_template.dart` | Overlay detail vs full-screen |

**Risk**: Breakpoints are scattered and duplicated. Should be centralized into a `DSBreakpoints` token class.

### 3.3 Empty / Loading / Error States

| Goal | Files that own it today | Status |
|------|------------------------|--------|
| Empty lane state | `ds_lane_board.dart` (_EmptyLane) | **Exists**. Shows icon + "No tasks" text. |
| Empty timeline state | `ds_timeline.dart` (_EmptyTimeline) | **Exists**. Shows icon + "No changelog entries" text. |
| Loading states | None | **Missing**. No shimmer, skeleton, or progress indicator widgets in design system. |
| Error states | None | **Missing**. No error panel, retry button, or error boundary widget. |
| Empty graph state | `ds_graph_canvas.dart` | **Not audited in detail** (not in required file list). Likely missing. |
| Empty asset detail | `ds_detail_inspector.dart` | **Not audited in detail** (not in required file list). Likely missing. |

### 3.4 Performance / Glass / Blur

| Goal | Files that own it today | Status |
|------|------------------------|--------|
| Glass panel blur control | `ds_glass_panel.dart` | **Exists with fallback**. DSGlassPanel uses BackdropFilter (blur 5-20); DSGlassPanelSimple is a no-blur fallback using solid color. Four named constructors: subtle (5), default (10), elevated (15), modal (20). |
| Glow border animation cost | `ds_glow_border.dart` | **Exists**. Animated variant uses AnimationController + AnimatedBuilder. Could be expensive if overused. |
| Lazy list builders | `ds_lane_board.dart`, `ds_sidebar.dart`, `ds_timeline.dart` | **Exists**. All use ListView.builder. |
| Opacity/clip nesting | `ds_glass_panel.dart`, `ds_glow_border.dart` | **Risk**. GlassPanel uses ClipRRect + BackdropFilter. GlowBorder uses ClipRRect + boxShadow. CanvasTemplate overlay uses withOpacity(0.95). Nesting these would compound cost. |

### 3.5 Demo Narrative / Storytelling

| Goal | Files that own it today | Status |
|------|------------------------|--------|
| Story panel for guided insights | `ds_story_panel.dart` (DSStoryPanel, DSStoryInsight, DSStoryCardQuick) | **Exists**. Accepts title, subtitle, insights list, footer. Uses glass panel. |
| Timeline with grouping | `ds_timeline.dart` (DSTimeline, DSTimelineGrouped, DSTimelineGroup) | **Exists**. Supports grouped entries with headers and per-group icons/colors. |
| Governance colors (canonicality) | `ds_colors.dart` (6 governance colors + forCanonicity helper) | **Exists**. parentCanonical, childLocal, generated, appendOnly, archive, mock. |
| Lane colors | `ds_colors.dart` (5 lane colors + forLane helper) | **Exists**. planning, open, doing, review, completed. |
| Asset kind colors | `ds_colors.dart` (9 asset colors + forAssetKind helper) | **Exists**. agent, skill, subskill, workflow, task, changelog, script, reference, rule. |
| Demo page / gallery | None | **Missing**. No `design_system_gallery_page.dart`, no `pages/` directory, no demo script. |

---

## 4. Handoff Table for Tasks 1010-1050 (HISTORICAL — 2026-06-07)

> **Superseded for live edit targets by §0.6.** Paths below are basenames from the original root-`lib/` design system; resolve through §0.2. Risks that say “no gallery / no app / no SDK” are historical — do not re-open them as current blockers.

| Task | Scope | Candidate Files (Read/Modify) | Main Risk |
|------|-------|------------------------------|-----------|
| **1010 — Accessibility** | Contrast, focus, keyboard, semantics | `ds_colors.dart` (fix textTertiary contrast), `ds_text.dart` (add Semantics), `ds_sidebar.dart` (add keyboard nav), `ds_topbar.dart` (add keyboard nav), `ds_lane_board.dart` (add focus), all molecules (add Semantics wrappers), `ds_semantics.dart` | Fixing textTertiary contrast may change the "ultradark" aesthetic feel. Focus traversal needs testing without a runnable app. |
| **1020 — Responsive** | Breakpoints, collapse behavior, overflow | `ds_shell.dart`, `master_detail_template.dart`, `ds_topbar.dart`, `ds_sidebar.dart`, `ds_lane_board.dart` | Breakpoints are hardcoded in 3+ files. Centralizing them is a refactor, not just a polish pass. No narrow (<600px) support exists. |
| **1030 — States** | Empty, loading, error consistency | `ds_lane_board.dart`, `ds_timeline.dart`, NEW files needed: loading skeleton, error panel, generic empty state | Most state widgets need to be created from scratch. Only empty lane and empty timeline exist today. |
| **1040 — Performance/Glass** | Blur audit, lazy builders, profiling | `ds_glass_panel.dart`, `ds_glow_border.dart`, `ds_story_panel.dart` (uses elevated glass) | No profiling tools available without Flutter SDK. Blur nesting risk is theoretical until the app has screens. |
| **1050 — Demo Narrative** | Storytelling copy, demo flow, gallery | `ds_story_panel.dart`, `ds_timeline.dart`, `ds_colors.dart`, `ds_semantics.dart`, NEW: gallery page, demo script | No gallery page exists. No demo path exists. Story panel is a widget, not a screen. Narrative work is blocked until screens exist. |

---

## 5. Detailed Inventories (HISTORICAL — 2026-06-07)

> Live package inventory and a11y/responsive/state surfaces have grown under `packages/warp_prism_ui/`. Treat this section as the original audit trail, not current gap status.

### 5.1 Accessibility Surfaces

| Surface | Widget | Focus Support | Semantics | Keyboard Activation |
|---------|--------|--------------|-----------|-------------------|
| Sidebar item | `_SidebarItemWidget` in `ds_sidebar.dart` | MouseRegion only | None | None (GestureDetector only) |
| Topbar action | `DSTopbarAction` in `ds_topbar.dart` | MouseRegion only | None | None |
| Task card | `DSTaskCard` in `ds_task_card.dart` | Not audited | Not audited | Not audited |
| Lane board | `DSLaneBoard` | No focus traversal | None | None |
| Timeline entry | `DSTimelineMarker` in `ds_timeline_marker.dart` | Not audited | Not audited | Not audited |
| Filter chips | `DSFilterChipGroup` in `ds_filter_chip_group.dart` | Not audited | Not audited | Not audited |
| Search bar | `DSSearchBar` in `ds_search_bar.dart` | Likely has (TextField) | Likely has | Likely has |

### 5.2 Responsive Breakpoints

All breakpoints are **hardcoded literals**, not centralized tokens:

- `DSShellResponsive.breakpoint`: 1200.0 (constructor param, default)
- `_MasterDetailTemplateState.build`: `> 1200` (wide), `> 800` (medium)
- `TimelineTemplate.build`: `> 1000` (wide)
- `DSShellResponsive.build`: `>= 800` (showFullSidebar)

**Gap**: No `DSBreakpoints` token class. No narrow breakpoint (<600px). No orientation-independent layout switching.

### 5.3 State Rendering Inventory

| State Type | Widgets That Handle It | Widgets That Don't |
|------------|----------------------|-------------------|
| Empty | `_EmptyLane` (ds_lane_board), `_EmptyTimeline` (ds_timeline) | Graph canvas, detail inspector, story panel, search results, filter results |
| Loading | None | Everything |
| Error | None | Everything |
| Skeleton/Shimmer | None | Everything |

### 5.4 Blur / Glass Usage

| Widget | Blur Level | Has Fallback? | Usage Context |
|--------|-----------|---------------|---------------|
| `DSGlassPanel` (default) | sigma 10 | `DSGlassPanelSimple` exists | General panels |
| `DSGlassPanel.subtle` | sigma 5 | Via Simple fallback | Subtle cards |
| `DSGlassPanel.elevated` | sigma 15 | Via Simple fallback | Story panels, elevated cards |
| `DSGlassPanel.modal` | sigma 20 | Via Simple fallback | Modal overlays |
| Canvas overlay in `CanvasTemplate` | withOpacity(0.95), no blur | None | Graph inspector overlay |

**Note**: `DSGlassPanelSimple` exists as a no-blur performance alternative. Research.md recommends "sparse glassmorphism" — the current tiered approach (5/10/15/20) is reasonable but must not be stacked.

### 5.5 Demo Narrative Surfaces

| Surface | Widget/Token | Exists? | What It Provides |
|---------|-------------|---------|-----------------|
| Story panel | `DSStoryPanel` | Yes | Title, subtitle, insights list, glass panel |
| Quick story card | `DSStoryCardQuick` | Yes | Value + trend card for dashboard highlights |
| Grouped timeline | `DSTimelineGrouped` | Yes | Grouped changelog with project/milestone headers |
| Governance colors | `DSColors.forCanonicity()` | Yes | 6 canonicality color mappings |
| Lane colors | `DSColors.forLane()` | Yes | 5 lane color mappings |
| Semantic text styles | `DSSemantics` | Yes | Status, governance, asset, lane, proof state text styles |
| Gallery page | — | **No** | No design system gallery exists |
| Demo script | — | **No** | No demo narrative path documented |

---

## 6. Dart File Inventory (40 files) (HISTORICAL — 2026-06-07 root-`lib/`)

### Tokens (8 files)
- `ds_colors.dart` — 178 lines, comprehensive color palette
- `ds_typography.dart` — 186 lines, JetBrainsMono + Inter, 18 text styles
- `ds_spacing.dart` — 72 lines, semantic spacing scale
- `ds_radii.dart` — exists (not read in detail)
- `ds_shadows.dart` — exists (not read in detail)
- `ds_motion.dart` — exists (not read in detail)
- `ds_semantics.dart` — 150 lines, pre-composed semantic styles
- `tokens.dart` — barrel export

### Atoms (9 files)
- `ds_text.dart` — 139 lines, 18 named constructors, selectable support
- `ds_icon.dart` — exists
- `ds_badge.dart` — exists
- `ds_chip.dart` — exists
- `ds_divider.dart` — exists
- `ds_status_dot.dart` — exists
- `ds_glow_border.dart` — 154 lines, animated glow variant
- `ds_glass_panel.dart` — 140 lines, 4 tiers + Simple fallback
- `atoms.dart` — barrel export

### Molecules (9 files)
- `ds_search_bar.dart` — exists
- `ds_filter_chip_group.dart` — exists
- `ds_asset_card.dart` — exists
- `ds_metric_tile.dart` — exists
- `ds_provenance_pill.dart` — exists
- `ds_evidence_row.dart` — exists
- `ds_timeline_marker.dart` — exists
- `ds_task_card.dart` — exists
- `molecules.dart` — barrel export

### Organisms (9 files)
- `ds_shell.dart` — 142 lines, basic + responsive shell
- `ds_sidebar.dart` — 260 lines, expandable sidebar with items
- `ds_topbar.dart` — 187 lines, title/breadcrumbs/search/actions
- `ds_graph_canvas.dart` — exists (not read in detail)
- `ds_lane_board.dart` — 216 lines, kanban board with 5 lanes
- `ds_timeline.dart` — 207 lines, flat + grouped timeline
- `ds_detail_inspector.dart` — exists (not read in detail)
- `ds_story_panel.dart` — 224 lines, narrative panels
- `organisms.dart` — barrel export

### Templates (2 files)
- `master_detail_template.dart` — 496 lines, 3 templates (MasterDetail, Canvas, Timeline)
- `templates.dart` — barrel export

### Data Layer (2 files)
- `models.dart` — 598 lines, Agent/Skill/Workflow/Task/ChangelogEntry/AssetEdge
- `workspace_parser.dart` — 394 lines, YAML parser for agents/skills/workflows/changelog

### Barrel (1 file)
- `design_system.dart` — barrel export

---

## 7. Model Gap Analysis (HISTORICAL — 2026-06-07)

> Live models live under `apps/observatory/lib/data/models/` (including legacy `models.dart` plus newer backbone/contracts). Do not treat the gap table below as a current data-layer audit.

| Prompt Requirement | models.dart Reality | Gap |
|-------------------|-------------------|-----|
| `AssetKind` enum (9 values) | `AssetType` enum (5 values: agent, skill, workflow, task, doc) | Missing: subskill, changelog, script, reference, rule |
| `EdgeKind` enum (7 values) | `AssetEdge` has String edgeType | No enum; edge types are freeform strings |
| `Canonicality` enum (6 values) | Not present in models | `DSColors` has color mappings for 6 canonicality values but no model enum |
| `WorkspaceAsset` unified base | `Asset` abstract class exists | Acceptable equivalent |
| `WorkspaceEdge` | `AssetEdge` class exists | Has sourceId, targetId, edgeType (string) |

---

## 8. Validation Command Results

> **Live 2026-07-09 results**: see §0.5 (SDK unblocked; scoped analyze/test). Table below is the original blocked audit.

| Command | Result | Notes |
|---------|--------|-------|
| `flutter analyze` | **BLOCKED** (historical) | Flutter SDK not found on machine. No `flutter` binary in PATH. |
| `flutter test` | **BLOCKED** (historical) | Flutter SDK not found. No test files exist (0 `*_test.dart` files found). |
| `flutter pub get` | **BLOCKED** (historical) | Flutter SDK not found. |

---

## 9. Blockers for EPIC 10

> **Historical blockers (2026-06-07).** Live status: items 1–4 largely **resolved** by monorepo + bootstrap (see §0). Model/mock/API items tracked by later foundation/data tasks, not re-litigated here.

1. **No main.dart / app shell**: EPIC 10 polish requires screens to polish. No `main.dart`, `app.dart`, `router.dart`, or any page exists.
2. **No Flutter SDK on audit machine**: Cannot validate with `flutter analyze` or `flutter test`.
3. **No test files**: Zero `*_test.dart` files in the project. Regression testing is impossible.
4. **README is stale**: Still describes Next.js/v0 project. Would misroute any contributor.
5. **Model gaps**: `AssetType` has 5 values vs 9 needed; no `Canonicality` enum; no `EdgeKind` enum.
6. **Mock data format**: Existing mocks are `.yaml` pure, not `.md` with YAML frontmatter as required by prompt.
7. **API mismatches documented in draft.md**: Template-to-organism API inconsistencies (DsColors vs DSColors, DsMotion vs DSMotion, parameter name mismatches) — these may or may not have been fixed since the draft was written.

---

## 10. What Can Be Polished Now vs What Is Blocked (HISTORICAL — 2026-06-07)

> Live: app shell, gallery, demo script, tests, and Flutter SDK exist (§0). The “blocked until screens exist” list is historical.

### Can proceed (design system widget-level polish):
- Contrast ratio fixes in `ds_colors.dart` (textTertiary)
- Focus traversal additions to interactive atoms/molecules/organisms
- Semantics wrappers on all components
- Breakpoint centralization into a token class
- Loading/error state widget creation
- Glass panel tier validation and documentation
- Centralized responsive breakpoint tokens

### Blocked (needs app surfaces first):
- End-to-end keyboard navigation testing
- Screen-level responsive behavior
- Demo narrative path / gallery page
- Storytelling copy for Map/Operate/History/Governance
- Performance profiling on real screens
- Loading/error states on actual data flows
- Empty state behavior in context (graph, search, detail)

---

## 11. Operational Recommendations (HISTORICAL — 2026-06-07)

> Live status: README is Melos/Flutter-aligned; mains exist; `DSBreakpoints` and contrast floor work advanced under later EPIC 10 slices. Keep only still-open residual risks from §0.4/§0.6.

1. **Immediate**: Replace `README.md` with Flutter project documentation.
2. **Before EPIC 10 tasks**: Create `main.dart` + app shell + router so polish can be visually verified.
3. **During Task 1010**: Fix `textTertiary` contrast (raise to at least #808090 for WCAG AA on #050508).
4. **During Task 1020**: Create `DSBreakpoints` token class. Centralize all breakpoint values.
5. **During Task 1030**: Create reusable loading skeleton and error panel atoms.
6. **Model alignment**: Rename `AssetType` → `AssetKind`, add missing values, add `Canonicality` and `EdgeKind` enums before data layer work.
