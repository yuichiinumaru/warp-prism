/// Prism* Public API Aliases — type aliases for promoted operational components.
///
/// Per `docs/design/token-theme-catalog-policy.md` §2.4, all public widgets
/// exported by `warp_prism_ui` for consumer apps use the `Prism` prefix.
/// These aliases delegate to the DS* implementation classes.
///
/// Consumer apps import:
/// ```dart
/// import 'package:warp_prism_ui/warp_prism_ui.dart';
/// // Use: PrismStatusDot, PrismMetricTile, PrismTaskCard, etc.
/// ```
///
/// What they NEVER see: DSStatusDot, DSMetricTile, DSTaskCard, etc.
library;

import 'atoms/ds_badge.dart';
import 'atoms/ds_icon.dart';
import 'atoms/ds_sparkline.dart';
import 'atoms/ds_status_dot.dart';
import 'atoms/ds_text.dart';
import 'molecules/ds_asset_card.dart';
import 'molecules/ds_evidence_row.dart';
import 'molecules/ds_filter_chip_group.dart';
import 'molecules/ds_health_card.dart';
import 'molecules/ds_metric_tile.dart';
import 'molecules/ds_provenance_pill.dart';
import 'molecules/ds_search_bar.dart';
import 'molecules/ds_shimmer.dart';
import 'molecules/ds_skeleton_card.dart';
import 'molecules/ds_skeleton_table_rows.dart';
import 'molecules/ds_skeleton_text_line.dart';
import 'molecules/ds_state_surface.dart';
import 'molecules/ds_task_card.dart';
import 'molecules/ds_timeline_marker.dart';
import 'molecules/ds_toast.dart';
import 'molecules/ds_toast_manager.dart';
import 'molecules/ds_uptime_bar.dart';
import 'organisms/code_block/ds_code_block.dart';
import 'organisms/command_palette/ds_command_palette.dart';
import 'organisms/data_table/ds_data_table.dart';
import 'organisms/ds_error_boundary.dart';
import 'organisms/ds_fallback_view.dart';
import 'organisms/ds_lane_board.dart';
import 'organisms/ds_shell.dart';
import 'organisms/ds_sidebar.dart';
import 'organisms/ds_status_grid.dart';
import 'organisms/ds_story_panel.dart';
import 'organisms/ds_timeline.dart';
import 'organisms/ds_topbar.dart';
import 'organisms/log_viewer/ds_log_viewer.dart';
import 'organisms/markdown_renderer/ds_markdown_renderer.dart';
import 'organisms/split_pane/ds_split_pane.dart';
import 'organisms/tab_bar/ds_tab_bar.dart';
import 'organisms/virtual_scroll/ds_virtual_scroll.dart';
import 'tokens/ds_operational_state.dart';

// =============================================================================
// TOKENS — Operational State
// =============================================================================

/// Public alias for [DSOperationalState].
///
/// The canonical 15-state vocabulary covering lifecycle, health,
/// verification, and governance semantics.
typedef PrismOperationalState = DSOperationalState;

/// Public alias for [DSOperationalSeverity].
typedef PrismOperationalSeverity = DSOperationalSeverity;

/// Public alias for [DSOperationalCategory].
typedef PrismOperationalCategory = DSOperationalCategory;

/// Note: [DSOperationalStateUI] is an extension on [DSOperationalState].
/// Consumer apps access it via `PrismOperationalState.running.color` etc.

// =============================================================================
// ATOMS
// =============================================================================

/// Public alias for [DSStatusDot].
///
/// Supports all 15 operational states via named constructors.
typedef PrismStatusDot = DSStatusDot;

// =============================================================================
// MOLECULES
// =============================================================================

/// Public alias for [DSMetricTile].
///
/// Supports health states via [DSMetricTileHealth].
typedef PrismMetricTile = DSMetricTile;

/// Public alias for [DSMetricTileCompact].
typedef PrismMetricTileCompact = DSMetricTileCompact;

/// Public alias for [DSMetricTileHealth].
typedef PrismMetricTileHealth = DSMetricTileHealth;

/// Public alias for [DSTrend].
typedef PrismTrend = DSTrend;

/// Public alias for [DSStateSurface].
///
/// Supports data-loading states (empty, loading, error) and operational
/// states (disabled, stale, degraded, excluded).
typedef PrismStateSurface = DSStateSurface;

/// Public alias for [DSStateType].
typedef PrismStateType = DSStateType;

/// Public alias for [DSTaskCard].
typedef PrismTaskCard = DSTaskCard;

/// Public alias for [DSAssetCard].
typedef PrismAssetCard = DSAssetCard;

/// Public alias for [DSSearchBar].
typedef PrismSearchBar = DSSearchBar;

/// Public alias for [DSFilterChipGroup].
typedef PrismFilterChipGroup = DSFilterChipGroup;

/// Public alias for [DSFilterOption].
typedef PrismFilterOption = DSFilterOption;

/// Public alias for [DSEvidenceRow].
typedef PrismEvidenceRow = DSEvidenceRow;

/// Public alias for [DSEvidenceIndicator].
typedef PrismEvidenceIndicator = DSEvidenceIndicator;

/// Public alias for [DSEvidenceState].
typedef PrismEvidenceState = DSEvidenceState;

/// Public alias for [DSProvenancePill].
typedef PrismProvenancePill = DSProvenancePill;

/// Public alias for [DSProvenanceSize].
typedef PrismProvenanceSize = DSProvenanceSize;

/// Public alias for [DSTimelineMarker].
typedef PrismTimelineMarker = DSTimelineMarker;

// =============================================================================
// ORGANISMS
// =============================================================================

/// Public alias for [DSLaneBoard].
typedef PrismLaneBoard = DSLaneBoard;

/// Public alias for [DSLane].
typedef PrismLane = DSLane;

/// Public alias for [DSLaneTask].
typedef PrismLaneTask = DSLaneTask;

// =============================================================================
// COMPONENTS — Additional promoted types
// =============================================================================

/// Public alias for [DSBadge].
typedef PrismBadge = DSBadge;

/// Public alias for [DSIcon].
typedef PrismIcon = DSIcon;

/// Public alias for [DSText].
typedef PrismText = DSText;

/// Public alias for [DSDataTable].
typedef PrismDataTable = DSDataTable;

/// Public alias for [DSDataColumn].
typedef PrismDataColumn = DSDataColumn;

/// Public alias for [DSDataRow].
typedef PrismDataRow = DSDataRow;

/// Public alias for [DSStatusCell].
typedef PrismStatusCell = DSStatusCell;

/// Public alias for [DSStatusGrid].
typedef PrismStatusGrid = DSStatusGrid;

/// Public alias for [DSHealthCardData].
typedef PrismHealthCardData = DSHealthCardData;

/// Public alias for [DSErrorBoundary].
typedef PrismErrorBoundary = DSErrorBoundary;

/// Public alias for [DSFallbackView].
typedef PrismFallbackView = DSFallbackView;

/// Public alias for [DSTimeline].
typedef PrismTimeline = DSTimeline;

/// Public alias for [DSTimelineEntry].
typedef PrismTimelineEntry = DSTimelineEntry;

/// Public alias for [DSShellResponsive].
typedef PrismShellResponsive = DSShellResponsive;

/// Public alias for [DSSidebar].
typedef PrismSidebar = DSSidebar;

/// Public alias for [DSSidebarItem].
typedef PrismSidebarItem = DSSidebarItem;

/// Public alias for [DSTopbar].
typedef PrismTopbar = DSTopbar;

/// Public alias for [DSStoryPanel].
typedef PrismStoryPanel = DSStoryPanel;

/// Public alias for [DSStoryInsight].
typedef PrismStoryInsight = DSStoryInsight;

/// Public alias for [DSToast].
typedef PrismToast = DSToast;

/// Public alias for [DSToastManager].
typedef PrismToastManager = DSToastManager;

/// Public alias for [DSSparkline].
typedef PrismSparkline = DSSparkline;

/// Public alias for [DSUptimeBar].
typedef PrismUptimeBar = DSUptimeBar;

/// Public alias for [DSHealthCard].
typedef PrismHealthCard = DSHealthCard;

/// Public alias for [DSShimmer].
typedef PrismShimmer = DSShimmer;

/// Public alias for [DSSkeletonCard].
typedef PrismSkeletonCard = DSSkeletonCard;

/// Public alias for [DSSkeletonTextLine].
typedef PrismSkeletonTextLine = DSSkeletonTextLine;

/// Public alias for [DSSkeletonTableRows].
typedef PrismSkeletonTableRows = DSSkeletonTableRows;

/// Public alias for [DSVirtualList].
typedef PrismVirtualList = DSVirtualList;

/// Public alias for [DSVirtualGrid].
typedef PrismVirtualGrid = DSVirtualGrid;

/// Public alias for [DSTabBar].
typedef PrismTabBar = DSTabBar;

/// Public alias for [DSSplitPane].
typedef PrismSplitPane = DSSplitPane;

/// Public alias for [DSCodeBlock].
typedef PrismCodeBlock = DSCodeBlock;

/// Public alias for [DSMarkdownRenderer].
typedef PrismMarkdownRenderer = DSMarkdownRenderer;

/// Public alias for [DSCommandPalette].
typedef PrismCommandPalette = DSCommandPalette;

/// Public alias for [DSCommand].
typedef PrismCommand = DSCommand;

/// Public alias for [DSLogViewer].
typedef PrismLogViewer = DSLogViewer;
