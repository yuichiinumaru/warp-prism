# Public Barrel Audit — `warp_prism_ui`

> **Task**: 1302
> **Date**: 2026-06-09
> **Executor**: builders
> **Source**: `packages/warp_prism_ui/lib/warp_prism_ui.dart`

---

## 1. Barrel Structure

The public barrel at `warp_prism_ui.dart` exports 7 sub-barrels:

| # | Export | Layer |
|---|--------|-------|
| 1 | `src/tokens/tokens.dart` | Tokens |
| 2 | `src/atoms/atoms.dart` | Atoms |
| 3 | `src/molecules/molecules.dart` | Molecules |
| 4 | `src/organisms/organisms.dart` | Organisms |
| 5 | `src/templates/templates.dart` | Templates |
| 6 | `src/gallery/design_system_gallery_page.dart` | Gallery |
| 7 | `src/gallery/design_system_gallery_sections.dart` | Gallery |
| 8 | `src/prism_aliases.dart` | Aliases |

---

## 2. Complete Public Symbol Manifest

### 2.1 Tokens (9 types)

| Symbol | Kind | Prism* Alias | Status |
|--------|------|-------------|--------|
| `DSBreakpoints` | abstract class | `PrismBreakpoints` | Production |
| `DSColors` | abstract class | `PrismColors` | Production |
| `DSMotion` | abstract class | `PrismMotion` | Production |
| `DSOperationalCategory` | enum | `PrismOperationalCategory` | Production |
| `DSOperationalSeverity` | enum | `PrismOperationalSeverity` | Production |
| `DSOperationalState` | enum | `PrismOperationalState` | Production |
| `DSOperationalStateUI` | extension | — (accessed via `PrismOperationalState.x`) | Production |
| `DSRadii` | abstract class | `PrismRadii` | Production |
| `DSSemantics` | abstract class | `PrismSemantics` | Production |
| `DSShadows` | abstract class | `PrismShadows` | Production |
| `DSSpacing` | abstract class | `PrismSpacing` | Production |
| `DSTypography` | abstract class | `PrismTypography` | Production |

### 2.2 Atoms (18 types)

| Symbol | Kind | Prism* Alias | Status |
|--------|------|-------------|--------|
| `DSBadge` | class | `PrismBadge` | Production |
| `DSBadgeSize` | enum | — | Production |
| `DSBadgeVariant` | enum | — | Production |
| `DSChip` | class | — | Production |
| `DSChipSize` | enum | — | Production |
| `DSDivider` | class | — | Production |
| `DSGlowBorder` | class | — | Production |
| `DSGlowDivider` | class | — | Production |
| `DSGlassPanel` | class | — | Production |
| `DSGlassPanelSimple` | class | — | Production |
| `DSGlassPanelVariant` | enum | — | Production |
| `DSIcon` | class | `PrismIcon` | Production |
| `DSIconSize` | enum | — | Production |
| `DSIcons` | abstract class | — | Production |
| `DSSparkline` | class | `PrismSparkline` | Production |
| `DSStatusDot` | class | `PrismStatusDot` | Production |
| `DSText` | class | `PrismText` | Production |
| `DSTextVariant` | enum | — | Production |

### 2.3 Molecules (33 types)

| Symbol | Kind | Prism* Alias | Status |
|--------|------|-------------|--------|
| `DSAssetCard` | class | `PrismAssetCard` | Production |
| `DSDraggableCard` | class | — | Experimental |
| `DSDragMoveEvent` | class | — | Experimental |
| `DSDragPayload` | class | — | Experimental |
| `DSDragReorderEvent` | class | — | Experimental |
| `DSDropTarget` | class | — | Experimental |
| `DSEvidenceIndicator` | class | `PrismEvidenceIndicator` | Production |
| `DSEvidenceRow` | class | `PrismEvidenceRow` | Production |
| `DSEvidenceState` | enum | `PrismEvidenceState` | Production |
| `DSFilterChipGroup` | class | `PrismFilterChipGroup` | Production |
| `DSFilterOption` | class | `PrismFilterOption` | Production |
| `DSHealthCard` | class | `PrismHealthCard` | Production |
| `DSMetricTile` | class | `PrismMetricTile` | Production |
| `DSMetricTileCompact` | class | `PrismMetricTileCompact` | Production |
| `DSMetricTileHealth` | enum | `PrismMetricTileHealth` | Production |
| `DSProvenancePill` | class | `PrismProvenancePill` | Production |
| `DSProvenanceSize` | enum | `PrismProvenanceSize` | Production |
| `DSSearchBar` | class | `PrismSearchBar` | Production |
| `DSShimmer` | class | `PrismShimmer` | Production |
| `DSSkeletonCard` | class | `PrismSkeletonCard` | Production |
| `DSSkeletonTableRows` | class | `PrismSkeletonTableRows` | Production |
| `DSSkeletonTextLine` | class | `PrismSkeletonTextLine` | Production |
| `DSStateSurface` | class | `PrismStateSurface` | Production |
| `DSStateType` | enum | `PrismStateType` | Production |
| `DSTaskCard` | class | `PrismTaskCard` | Production |
| `DSTimelineMarker` | class | `PrismTimelineMarker` | Production |
| `DSToast` | class | `PrismToast` | Production |
| `DSToastEntry` | class | — | Production |
| `DSToastManager` | class | `PrismToastManager` | Production |
| `DSToastManagerState` | class | — | Production |
| `DSToastSeverity` | enum | — | Production |
| `DSTrend` | enum | `PrismTrend` | Production |
| `DSUptimeBar` | class | `PrismUptimeBar` | Production |

### 2.4 Organisms (75 types)

| Symbol | Kind | Prism* Alias | Status |
|--------|------|-------------|--------|
| `DSDetailInspector` | class | — | Production |
| `DSDetailSection` | class | — | Production |
| `DSErrorBoundary` | class | `PrismErrorBoundary` | Production |
| `DSFallbackView` | class | `PrismFallbackView` | Production |
| `DSGraphCanvas` | class | — | Production |
| `DSHealthCardData` | class | `PrismHealthCardData` | Production |
| `DSLane` | class | `PrismLane` | Production |
| `DSLaneBoard` | class | `PrismLaneBoard` | Production |
| `DSLaneTask` | class | `PrismLaneTask` | Production |
| `DSLinkRow` | class | — | Production |
| `DSPropertyRow` | class | — | Production |
| `DSShell` | class | — | Production |
| `DSShellResponsive` | class | `PrismShellResponsive` | Production |
| `DSSidebar` | class | `PrismSidebar` | Production |
| `DSSidebarItem` | class | `PrismSidebarItem` | Production |
| `DSStatusGrid` | class | `PrismStatusGrid` | Production |
| `DSStoryCardQuick` | class | — | Production |
| `DSStoryInsight` | class | `PrismStoryInsight` | Production |
| `DSStoryNarrativeInsight` | class | — | Production |
| `DSStoryPanel` | class | `PrismStoryPanel` | Production |
| `DSTimeline` | class | `PrismTimeline` | Production |
| `DSTimelineEntry` | class | `PrismTimelineEntry` | Production |
| `DSTimelineGroup` | class | — | Production |
| `DSTimelineGrouped` | class | — | Production |
| `DSTopbar` | class | `PrismTopbar` | Production |
| `DSTopbarAction` | class | — | Production |
| `InsightRiskLevel` | enum | — | Production |
| `GraphEdge` | class (legacy) | — | Production |
| `GraphNode` | class (legacy) | — | Production |

**Organisms — Code Block sub-barrel** (`code_block/ds_code_block.dart`):

| Symbol | Kind | Prism* Alias | Status |
|--------|------|-------------|--------|
| `DSCodeBlock` | class | `PrismCodeBlock` | Production |

**Organisms — Markdown Renderer sub-barrel** (`markdown_renderer/ds_markdown_renderer.dart`):

| Symbol | Kind | Prism* Alias | Status |
|--------|------|-------------|--------|
| `DSMarkdownRenderer` | class | `PrismMarkdownRenderer` | Production |

**Organisms — Data Table sub-barrel** (`data_table/ds_data_table.dart`):

| Symbol | Kind | Prism* Alias | Status |
|--------|------|-------------|--------|
| `DSActionItem` | class | — | Production |
| `DSActionsCell` | class | — | Production |
| `DSBadgeCell` | class | — | Production |
| `DSCellRenderer` | typedef | — | Production |
| `DSDataColumn` | class | `PrismDataColumn` | Production |
| `DSDataRow` | class | `PrismDataRow` | Production |
| `DSDataTable` | class | `PrismDataTable` | Production |
| `DSSecretCell` | class | — | Production |
| `DSSortDirection` | enum | — | Production |
| `DSSortState` | class | — | Production |
| `DSStatusCell` | class | `PrismStatusCell` | Production |
| `DSTablePagination` | class | — | Production |
| `DSTimestampCell` | class | — | Production |

**Organisms — Graph sub-barrel** (`graph/graph.dart`, `GraphNode`/`GraphEdge` hidden):

| Symbol | Kind | Prism* Alias | Status |
|--------|------|-------------|--------|
| `ForceDirectedConfig` | class | — | Experimental |
| `ForceDirectedLayout` | class | — | Experimental |
| `GraphCanvas` | class | — | Experimental |
| `GraphEdgeId` | class | — | Experimental |
| `GraphLayoutEngine` | abstract class | — | Experimental |
| `GraphModel` | class | — | Experimental |
| `GraphNodeId` | class | — | Experimental |
| `GraphPainter` | class | — | Experimental |
| `GraphPainterConfig` | class | — | Experimental |
| `defaultNodeColor` | function | — | Experimental |

**Organisms — Log Viewer sub-barrel** (`log_viewer/log_viewer.dart`):

| Symbol | Kind | Prism* Alias | Status |
|--------|------|-------------|--------|
| `DSLogEntry` | class | — | Production |
| `DSLogEntryWidget` | class | — | Production |
| `DSLogFilterBar` | class | — | Production |
| `DSLogSeverity` | enum | — | Production |
| `DSLogSeverityUI` | extension | — | Production |
| `DSLogViewer` | class | `PrismLogViewer` | Production |

**Organisms — Command Palette sub-barrel** (`command_palette/command_palette.dart`):

| Symbol | Kind | Prism* Alias | Status |
|--------|------|-------------|--------|
| `DSCommand` | class | `PrismCommand` | Production |
| `DSCommandCategory` | enum | — | Production |
| `DSCommandPalette` | class | `PrismCommandPalette` | Production |
| `DSCommandPaletteShortcut` | class | — | Production |
| `showDSCommandPalette` | function | — | Production |

**Organisms — Tab Bar sub-barrel** (`tab_bar/tab_bar.dart`):

| Symbol | Kind | Prism* Alias | Status |
|--------|------|-------------|--------|
| `DSTab` | class | — | Production |
| `DSTabBar` | class | `PrismTabBar` | Production |
| `DSTabController` | class | — | Production |
| `DSTabView` | class | — | Production |

**Organisms — Split Pane sub-barrel** (`split_pane/split_pane.dart`):

| Symbol | Kind | Prism* Alias | Status |
|--------|------|-------------|--------|
| `DSSplitPane` | class | `PrismSplitPane` | Production |

**Organisms — Virtual Scroll sub-barrel** (`virtual_scroll/virtual_scroll.dart`):

| Symbol | Kind | Prism* Alias | Status |
|--------|------|-------------|--------|
| `DSVirtualGrid` | class | `PrismVirtualGrid` | Production |
| `DSVirtualList` | class | `PrismVirtualList` | Production |
| `DSVirtualScrollConfig` | class | — | Production |

### 2.5 Templates (3 types)

| Symbol | Kind | Prism* Alias | Status |
|--------|------|-------------|--------|
| `CanvasTemplate` | class | — | Production |
| `MasterDetailTemplate` | class | — | Production |
| `TimelineTemplate` | class | — | Production |

### 2.6 Gallery (2 types)

| Symbol | Kind | Prism* Alias | Status |
|--------|------|-------------|--------|
| `DSGallerySections` | abstract class | — | Gallery-only |
| `DesignSystemGalleryPage` | class | — | Gallery-only |

### 2.7 Prism* Aliases (72 typedefs)

All aliases are in `src/prism_aliases.dart`. They are `typedef` declarations
mapping `Prism*` names to `DS*` implementations.

---

## 3. Summary Counts

| Layer | Total Symbols | With Prism* Alias | No Alias |
|-------|--------------|-------------------|----------|
| Tokens | 12 | 10 | 2 |
| Atoms | 18 | 4 | 14 |
| Molecules | 33 | 20 | 13 |
| Organisms | 75 | 30 | 45 |
| Templates | 3 | 0 | 3 |
| Gallery | 2 | 0 | 2 |
| **Total** | **143** | **64** | **79** |

---

## 4. Prism* Alias Coverage

### 4.1 Types WITH Prism* Aliases (64)

All token abstract classes, operational state enums, and the majority of
production molecules and promoted organisms have aliases. See the tables above
for the full list.

### 4.2 Types WITHOUT Prism* Aliases (79)

These fall into several categories:

**Supporting types (enums, configs, events) — OK without alias:**
`DSBadgeVariant`, `DSBadgeSize`, `DSChipSize`, `DSIconSize`, `DSGlassPanelVariant`,
`DSTextVariant`, `DSToastSeverity`, `DSToastEntry`, `DSToastManagerState`,
`DSSortDirection`, `DSSortState`, `DSCellRenderer`, `DSActionItem`,
`DSVirtualScrollConfig`, `DSCommandCategory`, `DSLogSeverity`, `DSLogSeverityUI`,
`DSDragPayload`, `DSDragReorderEvent`, `DSDragMoveEvent`, `InsightRiskLevel`,
`DSTab`, `DSTabController`, `DSTimelineGroup`, `DSCommandPaletteShortcut`

**Infrastructure atoms (used internally, not promoted) — OK without alias:**
`DSDivider`, `DSGlowBorder`, `DSGlowDivider`, `DSGlassPanel`, `DSGlassPanelSimple`,
`DSChip`, `DSIcons`

**Organisms not yet promoted to Prism* namespace — REVIEW NEEDED:**
`DSShell`, `DSDetailInspector`, `DSDetailSection`, `DSPropertyRow`, `DSLinkRow`,
`DSTopbarAction`, `DSTimelineGrouped`, `DSStoryCardQuick`, `DSStoryNarrativeInsight`,
`DSGraphCanvas`, `GraphNode` (legacy), `GraphEdge` (legacy),
`DSBadgeCell`, `DSTimestampCell`, `DSSecretCell`, `DSActionsCell`, `DSTablePagination`,
`DSLogEntry`, `DSLogEntryWidget`, `DSLogFilterBar`, `DSTabView`

**Templates — no alias (Prism prefix not applied to templates):**
`MasterDetailTemplate`, `CanvasTemplate`, `TimelineTemplate`

**Gallery — no alias (demo-only):**
`DesignSystemGalleryPage`, `DSGallerySections`

**Graph composable layers — experimental, no alias:**
`GraphNodeId`, `GraphEdgeId`, `GraphModel`, `GraphLayoutEngine`,
`ForceDirectedConfig`, `ForceDirectedLayout`, `GraphPainter`, `GraphPainterConfig`,
`GraphCanvas`, `defaultNodeColor`

---

## 5. Experimental Components (Wave 4 — Not Yet Stabilized)

| Component | Reason | Recommendation |
|-----------|--------|----------------|
| `DSDraggableCard` | Wave 4 drag-and-drop. API may change. | Keep in public barrel, add Prism* alias after stabilization |
| `DSDragPayload` | Event model for drag-and-drop | Stabilize with DSDraggableCard |
| `DSDragReorderEvent` | Event model for drag-and-drop | Stabilize with DSDraggableCard |
| `DSDragMoveEvent` | Event model for drag-and-drop | Stabilize with DSDraggableCard |
| `DSDropTarget` | Wave 4 drag-and-drop | Keep in public barrel, add Prism* alias after stabilization |
| Graph composable layers (`GraphNodeId`, `GraphEdgeId`, `GraphModel`, `GraphLayoutEngine`, `ForceDirectedConfig`, `ForceDirectedLayout`, `GraphPainter`, `GraphPainterConfig`, `GraphCanvas`, `defaultNodeColor`) | Wave 4 graph decomposition. The typed model types (`GraphNode`, `GraphEdge`) are explicitly hidden from the organisms barrel to avoid collision with legacy types from `ds_graph_canvas.dart`. | Stabilize after graph migration is complete |
| `DSStoryNarrativeInsight` | Extended insight type, not yet in gallery | Verify usage before promoting |
| `DSStoryCardQuick` | Quick-glance card, not yet in gallery | Verify usage before promoting |

---

## 6. `src/` Types Leaking Into Public API

### 6.1 Gallery Code Exported Publicly

**Finding**: `DesignSystemGalleryPage` and `DSGallerySections` are exported
publicly alongside production components. These are demo/gallery-only types
that import from `warp_prism_ui.dart` (the barrel itself) and use DS* names
directly.

**Impact**: Consumer apps see gallery types in their autocomplete. The gallery
page references every DS type internally, so it creates a coupling surface
between demo code and the production barrel.

**Recommendation**: The gallery exports should be separated. Options:
1. Move gallery to a separate export: `export 'package:warp_prism_ui/warp_prism_gallery.dart'`
2. Or keep gallery in the barrel but add a doc comment marking it as non-production.

### 6.2 Legacy Graph Types Collision

**Finding**: `ds_graph_canvas.dart` exports `GraphNode` and `GraphEdge` (legacy
string-ID types). The `graph/graph.dart` sub-barrel also exports `GraphNode` and
`GraphEdge` (typed model types). The organisms barrel resolves this with
`export 'graph/graph.dart' hide GraphNode, GraphEdge;`.

**Impact**: The legacy `GraphNode`/`GraphEdge` from `ds_graph_canvas.dart` use
`String` IDs. The new typed versions from `graph_model.dart` use `GraphNodeId`
and `GraphEdgeId`. Both are public but the typed versions are hidden.

**Recommendation**: After graph migration, hide the legacy types and expose the
typed model. This is blocked by graph stabilization.

### 6.3 DSToastManagerState Leaked

**Finding**: `DSToastManagerState` is a public `State<>` class exported from
`ds_toast_manager.dart`. State classes should typically be private.

**Impact**: Minor. Consumer code could depend on the State class directly.

**Recommendation**: Consider making `DSToastManagerState` private in a future
cleanup, or document it as an implementation detail.

---

## 7. Recommendations

### 7.1 Add Prism* Aliases For

These production types are missing Prism* aliases and are commonly used by
consumer-facing code:

| Type | Suggested Alias | Priority |
|------|----------------|----------|
| `DSChip` | `PrismChip` | Medium |
| `DSIcons` | `PrismIcons` | Medium |
| `DSToastSeverity` | `PrismToastSeverity` | Low |
| `DSToastEntry` | `PrismToastEntry` | Low |
| `DSTab` | `PrismTab` | Low |
| `DSTabController` | `PrismTabController` | Low |
| `DSTabView` | `PrismTabView` | Low |
| `DSShell` | `PrismShell` | Medium |
| `DSDetailInspector` | `PrismDetailInspector` | Medium |
| `DSTopbarAction` | `PrismTopbarAction` | Low |

### 7.2 Separate Gallery From Production

Create a separate gallery barrel or add explicit documentation that gallery
exports are non-production. Current structure:

```
warp_prism_ui.dart  →  exports gallery (demo) alongside production
```

Recommended:

```
warp_prism_ui.dart       →  production only (tokens + atoms + molecules + organisms + templates + aliases)
warp_prism_gallery.dart  →  gallery/demo (imports from warp_prism_ui.dart)
```

### 7.3 Stabilize Experimental Components Before Consumer Release

The drag-and-drop and graph composable layer components should not be relied
upon by consumer apps until they complete stabilization. Add `@experimental`
annotations or doc comments marking them.

### 7.4 Enforce Barrel-Only Imports

The boundary test harness (Task 1205) should verify that consumer apps only
import from `package:warp_prism_ui/warp_prism_ui.dart` and never from
`src/` paths directly.

---

## 8. Validation

```bash
# Barrel compiles
dart analyze packages/warp_prism_ui/   # PASS (info-level lints only)

# Manifest file exists
test -f docs/design/public-barrel-audit.md   # PASS
```
