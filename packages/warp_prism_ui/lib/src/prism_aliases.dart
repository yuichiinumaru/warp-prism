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

import 'package:flutter/material.dart';
import 'atoms/button/ds_button.dart';
import 'atoms/checkbox/ds_checkbox.dart';
import 'atoms/text_field/ds_text_field.dart';
import 'atoms/ds_badge.dart';
import 'atoms/ds_chip.dart';
import 'atoms/ds_divider.dart';
import 'atoms/ds_glass_panel.dart';
import 'atoms/ds_glow_border.dart';
import 'atoms/ds_icon.dart';
import 'atoms/ds_sparkline.dart';
import 'atoms/ds_status_dot.dart';
import 'atoms/ds_switch.dart';
import 'atoms/ds_text.dart';
import 'molecules/ds_asset_card.dart';
import 'molecules/ds_draggable_card.dart';
import 'molecules/ds_drop_target.dart';
import 'molecules/ds_evidence_row.dart';
import 'molecules/ds_filter_chip_group.dart';
import 'molecules/ds_health_card.dart';
import 'molecules/ds_interactive_surface.dart';
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
import 'molecules/ds_scale_measure_bar.dart';
import 'molecules/accordion/ds_accordion.dart';
import 'molecules/dialog/ds_dialog.dart';
import 'molecules/select/ds_select.dart';
import 'organisms/code_block/ds_code_block.dart';
import 'organisms/command_palette/ds_command_palette.dart';
import 'organisms/data_table/ds_data_table.dart';
import 'organisms/ds_detail_inspector.dart';
import 'organisms/ds_error_boundary.dart';
import 'organisms/ds_fallback_view.dart';
import 'organisms/ds_graph_canvas.dart';
import 'organisms/ds_lane_board.dart';
import 'organisms/ds_shell.dart';
import 'organisms/ds_sidebar.dart';
import 'organisms/ds_status_grid.dart';
import 'organisms/ds_story_panel.dart';
import 'organisms/ds_timeline.dart';
import 'organisms/ds_topbar.dart';
import 'organisms/log_viewer/ds_log_entry_model.dart';
import 'organisms/log_viewer/ds_log_entry_widget.dart';
import 'organisms/log_viewer/ds_log_filter_bar.dart';
import 'organisms/log_viewer/ds_log_severity.dart';
import 'organisms/log_viewer/ds_log_viewer.dart';
import 'organisms/markdown_renderer/ds_markdown_renderer.dart';
import 'organisms/split_pane/ds_split_pane.dart';
import 'organisms/tab_bar/ds_tab.dart';
import 'organisms/tab_bar/ds_tab_bar.dart';
import 'organisms/tab_bar/ds_tab_controller.dart';
import 'organisms/tab_bar/ds_tab_view.dart';
import 'organisms/virtual_scroll/ds_virtual_scroll.dart';
import 'organisms/page_shell/ds_page_shell.dart';
import 'organisms/map_hud_workspace/ds_map_hud_workspace.dart';
import 'organisms/tool_strip_slideout/ds_tool_strip_slideout.dart';
import 'organisms/filter_workbench/ds_filter_workbench.dart';
import 'organisms/tree/ds_tree.dart';
import 'organisms/tree/ds_tree_node.dart';
import 'organisms/agent_transcript/ds_agent_message.dart';
import 'organisms/agent_transcript/ds_agent_transcript.dart';
import 'organisms/tool_call_card/ds_tool_call_card.dart';
import 'organisms/message_status_history/ds_message_status_history.dart';
import 'organisms/layer_control_panel/ds_layer_control_panel.dart';
import 'organisms/time_machine_scrubber/ds_time_machine_scrubber.dart';
import 'organisms/entity_intel_panel/ds_entity_intel_panel.dart';
import 'organisms/entity_locate_search/ds_entity_locate_search.dart';
import 'organisms/status_ticker/ds_status_ticker.dart';
import 'organisms/artifact_workbench/ds_artifact_workbench.dart';
import 'organisms/provider_health_matrix/ds_provider_health_matrix.dart';
import 'organisms/mcp_capability_inspector/ds_mcp_capability_inspector.dart';
import 'organisms/timing_waterfall/ds_timing_waterfall.dart';
import 'organisms/traffic_inspector/ds_traffic_inspector.dart';
import 'organisms/execution_console/ds_execution_console.dart';
import 'organisms/watchlist_dock/ds_watchlist_dock.dart';
import 'organisms/coordinate_status_bar/ds_coordinate_status_bar.dart';
import 'organisms/map_legend/ds_map_legend.dart';
import 'organisms/osint_workbench/ds_osint_workbench.dart';
import 'organisms/ai_analyst_panel/ds_ai_analyst_panel.dart';
import 'organisms/floating_analytics_hud/ds_floating_analytics_hud.dart';
import 'organisms/map_canvas_stage/ds_map_canvas_stage.dart';
import 'organisms/ops_control_cluster/ds_ops_control_cluster.dart';
import 'organisms/connector_panel/ds_connector_panel.dart';
import 'organisms/workflow_canvas_stage/ds_workflow_canvas_stage.dart';
import 'organisms/view_presets/ds_view_presets.dart';
import 'organisms/workspace_share_card/ds_workspace_share_card.dart';
import 'organisms/entity_relation_card/ds_entity_relation_card.dart';
import 'organisms/terminal_workspace/ds_terminal_workspace.dart';
import 'organisms/agent_shell_panel/ds_agent_shell_panel.dart';
import 'organisms/keyboard_cheatsheet/ds_keyboard_cheatsheet.dart';
import 'organisms/media_detail_overlay/ds_media_detail_overlay.dart';
import 'organisms/breadcrumbs/ds_breadcrumbs.dart';
import 'tokens/ds_breakpoints.dart';
import 'tokens/ds_colors.dart';
import 'tokens/ds_cybercore_teal_skin.dart';
import 'tokens/ds_motion.dart';
import 'tokens/ds_operational_state.dart';
import 'tokens/ds_radii.dart';
import 'tokens/ds_semantics.dart';
import 'tokens/ds_shadows.dart';
import 'tokens/ds_spacing.dart';
import 'tokens/ds_typography.dart';
import 'gallery/design_system_gallery_registry.dart';
import 'gallery/design_system_gallery_sections.dart';

// Re-export the top-level [showPrismDialog] helper so consumer apps can call
// it through the public `package:warp_prism_ui/warp_prism_ui.dart` barrel.
// The helper lives in the dialog molecule source; surfaced here via a
// restricted `show` export so consumers do not need the internal molecules barrel.
export 'molecules/dialog/ds_dialog.dart' show showPrismDialog;

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

/// Public Prism-named extension providing UI metadata for [PrismOperationalState].
///
/// Consumers import `package:warp_prism_ui/warp_prism_ui.dart` and use:
/// ```dart
/// PrismOperationalState.running.color
/// PrismOperationalState.running.label
/// PrismOperationalState.running.icon
/// ```
extension PrismOperationalStateUI on DSOperationalState {
  /// Canonical color for this operational state.
  Color get color {
    switch (this) {
      case DSOperationalState.pending:
        return DSColors.statusPending;
      case DSOperationalState.running:
        return DSColors.statusRunning;
      case DSOperationalState.approved:
        return DSColors.statusApproved;
      case DSOperationalState.rejected:
        return DSColors.statusRejected;
      case DSOperationalState.promoted:
        return DSColors.statusPromoted;
      case DSOperationalState.archived:
        return DSColors.statusArchived;
      case DSOperationalState.healthy:
        return DSColors.statusHealthy;
      case DSOperationalState.degraded:
        return DSColors.statusDegraded;
      case DSOperationalState.error:
        return DSColors.statusOpError;
      case DSOperationalState.disabled:
        return DSColors.statusDisabled;
      case DSOperationalState.unverified:
        return DSColors.statusUnverified;
      case DSOperationalState.exposed:
        return DSColors.statusExposed;
      case DSOperationalState.redacted:
        return DSColors.statusRedacted;
      case DSOperationalState.stale:
        return DSColors.statusStale;
      case DSOperationalState.excluded:
        return DSColors.statusExcluded;
    }
  }

  /// Canonical Material icon for this operational state.
  IconData get icon {
    switch (this) {
      case DSOperationalState.pending:
        return DSIcons.pending;
      case DSOperationalState.running:
        return DSIcons.doing;
      case DSOperationalState.approved:
        return DSIcons.success;
      case DSOperationalState.rejected:
        return DSIcons.error;
      case DSOperationalState.promoted:
        return DSIcons.canonical;
      case DSOperationalState.archived:
        return DSIcons.archive;
      case DSOperationalState.healthy:
        return DSIcons.success;
      case DSOperationalState.degraded:
        return DSIcons.warning;
      case DSOperationalState.error:
        return DSIcons.error;
      case DSOperationalState.disabled:
        return DSIcons.blocked;
      case DSOperationalState.unverified:
        return DSIcons.pending;
      case DSOperationalState.exposed:
        return DSIcons.warning;
      case DSOperationalState.redacted:
        return DSIcons.local;
      case DSOperationalState.stale:
        return DSIcons.warning;
      case DSOperationalState.excluded:
        return DSIcons.blocked;
    }
  }

  /// Human-readable label for screen display and accessibility.
  String get label {
    switch (this) {
      case DSOperationalState.pending:
        return 'Pending';
      case DSOperationalState.running:
        return 'Running';
      case DSOperationalState.approved:
        return 'Approved';
      case DSOperationalState.rejected:
        return 'Rejected';
      case DSOperationalState.promoted:
        return 'Promoted';
      case DSOperationalState.archived:
        return 'Archived';
      case DSOperationalState.healthy:
        return 'Healthy';
      case DSOperationalState.degraded:
        return 'Degraded';
      case DSOperationalState.error:
        return 'Error';
      case DSOperationalState.disabled:
        return 'Disabled';
      case DSOperationalState.unverified:
        return 'Unverified';
      case DSOperationalState.exposed:
        return 'Exposed';
      case DSOperationalState.redacted:
        return 'Redacted';
      case DSOperationalState.stale:
        return 'Stale';
      case DSOperationalState.excluded:
        return 'Excluded';
    }
  }

  /// Screen reader label for accessibility (mirrors [DSOperationalStateUI]).
  String get semanticLabel {
    switch (this) {
      case DSOperationalState.pending:
        return 'Pending: awaiting start';
      case DSOperationalState.running:
        return 'Running: in progress';
      case DSOperationalState.approved:
        return 'Approved: passed review';
      case DSOperationalState.rejected:
        return 'Rejected: failed review';
      case DSOperationalState.promoted:
        return 'Promoted: advanced';
      case DSOperationalState.archived:
        return 'Archived: read-only';
      case DSOperationalState.healthy:
        return 'Healthy: operating normally';
      case DSOperationalState.degraded:
        return 'Degraded: reduced quality';
      case DSOperationalState.error:
        return 'Error: failure detected';
      case DSOperationalState.disabled:
        return 'Disabled: intentionally off';
      case DSOperationalState.unverified:
        return 'Unverified: no proof yet';
      case DSOperationalState.exposed:
        return 'Exposed: visible but unreviewed';
      case DSOperationalState.redacted:
        return 'Redacted: sensitive hidden';
      case DSOperationalState.stale:
        return 'Stale: needs refresh';
      case DSOperationalState.excluded:
        return 'Excluded: outside scope';
    }
  }

  /// Whether user can initiate actions in this state.
  bool get allowsActions {
    switch (this) {
      case DSOperationalState.archived:
      case DSOperationalState.excluded:
        return false;
      default:
        return true;
    }
  }

  /// Whether this is a final state with no automatic transitions.
  bool get isTerminal {
    switch (this) {
      case DSOperationalState.archived:
      case DSOperationalState.excluded:
        return true;
      default:
        return false;
    }
  }

  /// Whether UI should display a warning indicator.
  bool get showsWarning {
    switch (this) {
      case DSOperationalState.rejected:
      case DSOperationalState.degraded:
      case DSOperationalState.error:
      case DSOperationalState.exposed:
      case DSOperationalState.stale:
        return true;
      default:
        return false;
    }
  }
}

/// Public alias for [DSColors].
///
/// Design token palette: obsidian backgrounds, energy accents,
/// semantic status, governance, text, border, lane, and asset-kind colors.
///
/// **Observatory default** primary energy remains [PrismColors.accentCyan]
/// (`#00D4FF`). Do not treat CyberCore teal as a global rebrand — use
/// [PrismCyberCoreTealSkin] when a product app opts into OmniRoute mono-teal.
typedef PrismColors = DSColors;

/// Public alias for [DSCyberCoreTealSkin].
///
/// **Opt-in** CyberCore ThemeExtension skin (OmniRoute `#00FFCC` core teal).
/// Observatory must not require this extension. Install via
/// [PrismCyberCoreTealSkin.applyToTheme] or `ThemeData.extensions`.
///
/// ```dart
/// theme: const PrismCyberCoreTealSkin.omniRoute().applyToTheme(
///   ThemeData.dark().copyWith(
///     scaffoldBackgroundColor: PrismColors.obsidianDeep,
///   ),
/// ),
/// // Later: PrismCyberCoreTealSkin.of(context).accent
/// ```
typedef PrismCyberCoreTealSkin = DSCyberCoreTealSkin;

/// Public alias for [DSSpacing].
///
/// Design token spacing scale: base increments and semantic spacing
/// for cards, lists, sections, sidebar, topbar, and inspector.
typedef PrismSpacing = DSSpacing;

/// Public alias for [DSTypography].
///
/// Design token type styles: display, heading, body, label, code,
/// and numeric styles for dense information architecture.
typedef PrismTypography = DSTypography;

/// Public alias for [DSBreakpoints].
///
/// Responsive breakpoint contract for shell, templates, and organisms.
typedef PrismBreakpoints = DSBreakpoints;

/// Public alias for [DSRadii].
///
/// Border radius scale for the glass/obsidian aesthetic.
typedef PrismRadii = DSRadii;

/// Public alias for [DSShadows].
///
/// Shadow and glow effects for depth in the ultradark theme.
typedef PrismShadows = DSShadows;

/// Public alias for [DSMotion].
///
/// Animation curves and durations for consistent motion design.
typedef PrismMotion = DSMotion;

/// Public alias for [DSSemantics].
///
/// Pre-composed semantic styles combining colors, typography, and meaning.
typedef PrismSemantics = DSSemantics;

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

/// Public alias for [DSInteractiveSurface].
///
/// Shared interactive surface contract for molecule primitives
/// (focus ring, min touch target, keyboard activation).
typedef PrismInteractiveSurface = DSInteractiveSurface;

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

/// Public alias for [DSAccordion].
typedef PrismAccordion = DSAccordion;

/// Public alias for [DSAccordionItem].
typedef PrismAccordionItem = DSAccordionItem;

/// Public alias for [DSAccordionSection].
typedef PrismAccordionSection = DSAccordionSection;

/// Public alias for [DSDialog].
typedef PrismDialog = DSDialog;

/// Public alias for [DSDialogAction].
typedef PrismDialogAction = DSDialogAction;

/// Public alias for [DSDialogSize].
typedef PrismDialogSize = DSDialogSize;

/// Public helper function to display a [PrismDialog] or custom modal in a popup route.
const showPrismDialog = DSDialog.show;

/// Public alias for [DSSelect].
typedef PrismSelect<T> = DSSelect<T>;

/// Public alias for [DSSelectItem].
typedef PrismSelectItem<T> = DSSelectItem<T>;

/// Public alias for [DSSelectOption].
typedef PrismSelectOption<T> = DSSelectOption<T>;

// =============================================================================
// ORGANISMS
// =============================================================================

/// Public alias for [DSLaneBoard].
typedef PrismLaneBoard = DSLaneBoard;

/// Public alias for [DSLane].
typedef PrismLane = DSLane;

/// Public alias for [DSLaneTask].
typedef PrismLaneTask = DSLaneTask;

/// Public alias for [DSPageShell].
///
/// In-content page chrome (icon + title + subtitle + actions + toolbar).
/// Distinct from app frame [PrismShell] / [PrismTopbar] / [PrismSidebar].
typedef PrismPageShell = DSPageShell;

/// Public alias for [DSMapHudWorkspace].
///
/// Full-bleed stage + multi-region HUD layout (left/right/bottom/top chrome
/// with hide/restore). Map-first workspace host — not a [PrismShell] clone.
typedef PrismMapHudWorkspace = DSMapHudWorkspace;

/// Public alias for [DSToolStripSlideout].
///
/// Vertical icon tool strip + exclusive glass slideout body. Opening tool B
/// closes tool A; re-tap or close collapses to strip-only.
typedef PrismToolStripSlideout = DSToolStripSlideout;

/// Public alias for [DSToolStripItem].
///
/// Fixture tool entry: id, icon, label, and body builder.
typedef PrismToolStripItem = DSToolStripItem;

/// Public alias for [DSFilterWorkbench].
///
/// Sectioned filter panel with apply/clear, optional advanced section/modal,
/// and [PrismFilterChipGroup] composition — beyond chip groups alone.
typedef PrismFilterWorkbench = DSFilterWorkbench;

/// Public alias for [DSFilterSection].
typedef PrismFilterSection = DSFilterSection;

/// Public alias for [DSFilterCriterion].
typedef PrismFilterCriterion = DSFilterCriterion;

/// Public alias for [DSFilterCriterionKind].
typedef PrismFilterCriterionKind = DSFilterCriterionKind;

/// Public alias for [DSTree].
///
/// Hierarchical content tree (expand/collapse, selection, status/meta).
/// Distinct from app-nav [PrismSidebar].
typedef PrismTree = DSTree;

/// Public alias for [DSTreeNode].
typedef PrismTreeNode = DSTreeNode;

/// Public alias for [DSAgentTranscript].
///
/// Scrollable multi-role **chat** conversation (user / assistant / system)
/// with typed message blocks. Distinct from EPIC-15 agent shell terminal
/// transcript and from [PrismLogViewer] severity streams.
typedef PrismAgentTranscript = DSAgentTranscript;

/// Public alias for [DSAgentMessage].
typedef PrismAgentMessage = DSAgentMessage;

/// Public alias for [DSAgentMessageBlock].
typedef PrismAgentMessageBlock = DSAgentMessageBlock;

/// Public alias for [DSAgentRole].
typedef PrismAgentRole = DSAgentRole;

/// Public alias for [DSAgentMessageBlockType].
typedef PrismAgentMessageBlockType = DSAgentMessageBlockType;

/// Public alias for [DSToolCallCard].
///
/// Expandable tool invocation card (name / args / result / error). Fixture
/// display only — no live tool execution or MCP calls.
typedef PrismToolCallCard = DSToolCallCard;

/// Public alias for [DSToolCallData].
typedef PrismToolCallData = DSToolCallData;

/// Public alias for [DSToolCallStatus].
typedef PrismToolCallStatus = DSToolCallStatus;

/// Public alias for [DSMessageStatusHistory].
///
/// Compact pipeline status step strip (pending / running / success / error).
/// Distinct from [PrismTimeline] event logs.
typedef PrismMessageStatusHistory = DSMessageStatusHistory;

/// Public alias for [DSMessageStatusStep].
typedef PrismMessageStatusStep = DSMessageStatusStep;

/// Public alias for [DSMessageStatusStepState].
typedef PrismMessageStatusStepState = DSMessageStatusStepState;

/// Public alias for [DSProviderHealthMatrix].
///
/// Provider → account/model ops health grid (fixture-first CyberCore).
/// Distinct from flat [PrismStatusGrid] multi-service dashboards.
typedef PrismProviderHealthMatrix = DSProviderHealthMatrix;

/// Public alias for [DSProviderHealthCell].
typedef PrismProviderHealthCell = DSProviderHealthCell;

/// Public alias for [DSProviderHealthProvider].
typedef PrismProviderHealthProvider = DSProviderHealthProvider;

/// Shared multi-provider fixture matrix (gallery + demos). Mock names only.
List<PrismProviderHealthProvider> prismProviderHealthMatrixFixtureProviders() =>
    dsProviderHealthMatrixFixtureProviders();

/// Compact two-provider / two-cell fixture for tests.
List<PrismProviderHealthProvider> prismProviderHealthMatrixMinimalFixture() =>
    dsProviderHealthMatrixMinimalFixture();

/// Public alias for [DSMcpCapabilityInspector].
///
/// Capability-gated MCP tools/resources/prompts inspector (fixture-first).
/// No live MCP JSON-RPC client in the ADS package.
typedef PrismMcpCapabilityInspector = DSMcpCapabilityInspector;

/// Public alias for [DSMcpCapabilityKind].
typedef PrismMcpCapabilityKind = DSMcpCapabilityKind;

/// Public alias for [DSMcpCapabilities].
typedef PrismMcpCapabilities = DSMcpCapabilities;

/// Public alias for [DSMcpToolItem].
typedef PrismMcpToolItem = DSMcpToolItem;

/// Public alias for [DSMcpResourceItem].
typedef PrismMcpResourceItem = DSMcpResourceItem;

/// Public alias for [DSMcpPromptItem].
typedef PrismMcpPromptItem = DSMcpPromptItem;

/// Public alias for [DSMcpRootItem].
typedef PrismMcpRootItem = DSMcpRootItem;

/// Public alias for [DSMcpPingResult].
typedef PrismMcpPingResult = DSMcpPingResult;

/// Public alias for [DSMcpCapabilitySelection].
typedef PrismMcpCapabilitySelection = DSMcpCapabilitySelection;

/// Gallery/standard capability flags (tools + resources + prompts).
PrismMcpCapabilities prismMcpCapabilityInspectorStandardCapabilities() =>
    dsMcpCapabilityInspectorStandardCapabilities();

/// Tools + resources only (prompts gated off).
PrismMcpCapabilities prismMcpCapabilityInspectorToolsResourcesOnly() =>
    dsMcpCapabilityInspectorToolsResourcesOnly();

/// Empty capability set.
PrismMcpCapabilities prismMcpCapabilityInspectorEmptyCapabilities() =>
    dsMcpCapabilityInspectorEmptyCapabilities();

/// Fixture tools for gallery + demos.
List<PrismMcpToolItem> prismMcpCapabilityInspectorFixtureTools() =>
    dsMcpCapabilityInspectorFixtureTools();

/// Fixture resources for gallery + demos.
List<PrismMcpResourceItem> prismMcpCapabilityInspectorFixtureResources() =>
    dsMcpCapabilityInspectorFixtureResources();

/// Fixture prompts for gallery + demos.
List<PrismMcpPromptItem> prismMcpCapabilityInspectorFixturePrompts() =>
    dsMcpCapabilityInspectorFixturePrompts();

/// Optional roots stub fixture.
List<PrismMcpRootItem> prismMcpCapabilityInspectorFixtureRoots() =>
    dsMcpCapabilityInspectorFixtureRoots();

/// Optional ping stub fixture.
List<PrismMcpPingResult> prismMcpCapabilityInspectorFixturePing() =>
    dsMcpCapabilityInspectorFixturePing();

/// Compact tools+resources fixture for minimal tests.
({
  PrismMcpCapabilities capabilities,
  List<PrismMcpToolItem> tools,
  List<PrismMcpResourceItem> resources,
})
prismMcpCapabilityInspectorMinimalFixture() =>
    dsMcpCapabilityInspectorMinimalFixture();

/// Public alias for [DSTimingWaterfall].
///
/// Fixture span bars for request/execution latency (no Recharts). Pure Flutter
/// layout — CyberCore ops C-09. Pair with [PrismTrafficInspector] for detail.
typedef PrismTimingWaterfall = DSTimingWaterfall;

/// Public alias for [DSTimingSpan].
typedef PrismTimingSpan = DSTimingSpan;

/// Public alias for [DSTimingWaterfallLayout].
typedef PrismTimingWaterfallLayout = DSTimingWaterfallLayout;

/// Multi-phase timing fixture spans (gallery + demos).
List<PrismTimingSpan> prismTimingWaterfallFixtureSpans() =>
    dsTimingWaterfallFixtureSpans();

/// Compact timing fixture including a zero-duration span (tests).
List<PrismTimingSpan> prismTimingWaterfallMinimalFixture() =>
    dsTimingWaterfallMinimalFixture();

/// Public alias for [DSTrafficInspector].
///
/// Request list + detail tabs MVP (fixture-first CyberCore C-10). No live
/// MITM / proxy capture — compose optional [PrismTimingWaterfall] in detail.
typedef PrismTrafficInspector = DSTrafficInspector;

/// Public alias for [DSTrafficRequest].
typedef PrismTrafficRequest = DSTrafficRequest;

/// Public alias for [DSTrafficDetailTab].
typedef PrismTrafficDetailTab = DSTrafficDetailTab;

/// Multi-request traffic fixture set for gallery and demos.
List<PrismTrafficRequest> prismTrafficInspectorFixtureRequests() =>
    dsTrafficInspectorFixtureRequests();

/// Compact two-request traffic fixture for tests.
List<PrismTrafficRequest> prismTrafficInspectorMinimalFixture() =>
    dsTrafficInspectorMinimalFixture();

/// Public alias for [DSWorkflowCanvasStage].
///
/// Workflow **DAG** stage contract (nodes/edges + selection bus) — EPIC-16 C-11.
/// Distinct from map canvas stage (geo/layer/feature selection; Task 1512).
/// Fixture-first fake stage; pure Flutter layout — no MapLibre, no force-graph JS.
typedef PrismWorkflowCanvasStage = DSWorkflowCanvasStage;

/// Public alias for [DSWorkflowNode].
typedef PrismWorkflowNode = DSWorkflowNode;

/// Public alias for [DSWorkflowEdge].
typedef PrismWorkflowEdge = DSWorkflowEdge;

/// Public alias for [DSWorkflowNodeKind].
typedef PrismWorkflowNodeKind = DSWorkflowNodeKind;

/// Public alias for [DSWorkflowEdgeKind].
typedef PrismWorkflowEdgeKind = DSWorkflowEdgeKind;

/// Public alias for [DSWorkflowSelection].
typedef PrismWorkflowSelection = DSWorkflowSelection;

/// Public alias for [DSWorkflowCanvasLayout].
typedef PrismWorkflowCanvasLayout = DSWorkflowCanvasLayout;

/// Gallery fixture nodes: ingest → route → respond (+ tool branch).
List<PrismWorkflowNode> prismWorkflowCanvasStageFixtureNodes() =>
    dsWorkflowCanvasStageFixtureNodes();

/// Gallery fixture edges for [prismWorkflowCanvasStageFixtureNodes].
List<PrismWorkflowEdge> prismWorkflowCanvasStageFixtureEdges() =>
    dsWorkflowCanvasStageFixtureEdges();

/// Compact two-node fixture for tests.
List<PrismWorkflowNode> prismWorkflowCanvasStageMinimalNodes() =>
    dsWorkflowCanvasStageMinimalNodes();

/// Compact edge fixture for tests.
List<PrismWorkflowEdge> prismWorkflowCanvasStageMinimalEdges() =>
    dsWorkflowCanvasStageMinimalEdges();

/// Public alias for [DSViewPreset].
typedef PrismViewPreset = DSViewPreset;

/// Public alias for [DSViewPresets].
typedef PrismViewPresets = DSViewPresets;

/// Public alias for [DSWorkspaceShareSummary].
typedef PrismWorkspaceShareSummary = DSWorkspaceShareSummary;

/// Public alias for [DSWorkspaceShareCard].
typedef PrismWorkspaceShareCard = DSWorkspaceShareCard;

/// Public alias for [DSExecutionConsole].
///
/// Run-grouped fixture execution log + structured output panel (EPIC-16 C-12).
/// Distinct from [PrismLogViewer] (severity event stream), EPIC-15 terminal
/// workspace, and agent shell panel. Fixture stream only — no PTY / shell exec.
typedef PrismExecutionConsole = DSExecutionConsole;

/// Public alias for [DSExecutionLine].
typedef PrismExecutionLine = DSExecutionLine;

/// Public alias for [DSExecutionLineLevel].
typedef PrismExecutionLineLevel = DSExecutionLineLevel;

/// Public alias for [DSExecutionRunGroup].
typedef PrismExecutionRunGroup = DSExecutionRunGroup;

/// Public alias for [DSExecutionRunStatus].
typedef PrismExecutionRunStatus = DSExecutionRunStatus;

/// Public alias for [DSExecutionConsoleController].
typedef PrismExecutionConsoleController = DSExecutionConsoleController;

/// Multi-group execution console fixture lines (gallery + demos).
List<PrismExecutionLine> prismExecutionConsoleFixtureLines() =>
    dsExecutionConsoleFixtureLines();

/// Multi-group execution console fixture run groups (gallery + demos).
List<PrismExecutionRunGroup> prismExecutionConsoleFixtureRunGroups() =>
    dsExecutionConsoleFixtureRunGroups();

/// Compact two-group execution fixture for tests.
({List<PrismExecutionRunGroup> groups, List<PrismExecutionLine> lines})
prismExecutionConsoleMinimalFixture() => dsExecutionConsoleMinimalFixture();

/// Public alias for [DSLayerControlPanel].
///
/// Grouped layer toggles with counts, freshness, master toggle, and
/// consent-gate callbacks. Fixture catalog only — no MapLibre.
typedef PrismLayerControlPanel = DSLayerControlPanel;

/// Public alias for [DSLayerGroup].
typedef PrismLayerGroup = DSLayerGroup;

/// Public alias for [DSLayerItem].
typedef PrismLayerItem = DSLayerItem;

/// Public alias for [DSLayerFreshness].
typedef PrismLayerFreshness = DSLayerFreshness;

/// Public alias for [DSTimeMachineScrubber].
///
/// Density histogram + playhead scrubber + playback transport over a fixture
/// time series. **Not** an event list — pair with [PrismTimeline] for
/// chronological changelog / narrative entries (list = story; scrubber =
/// temporal control surface).
typedef PrismTimeMachineScrubber = DSTimeMachineScrubber;

/// Public alias for [DSTimeDensityBucket].
typedef PrismTimeDensityBucket = DSTimeDensityBucket;

/// Public alias for [DSTimeDensitySeverity].
typedef PrismTimeDensitySeverity = DSTimeDensitySeverity;

/// Public alias for [DSEntityIntelPanel].
///
/// Pluggable dossier registry host: resolve a body builder by selection type.
/// Compose [PrismDetailInspector] pattern; fixture-first multi-body intel.
typedef PrismEntityIntelPanel = DSEntityIntelPanel;

/// Public alias for [DSEntitySelection].
typedef PrismEntitySelection = DSEntitySelection;

/// Public alias for [DSEntityIntelDossier].
typedef PrismEntityIntelDossier = DSEntityIntelDossier;

/// Public alias for [DSEntityIntelBodyBuilder].
typedef PrismEntityIntelBodyBuilder = DSEntityIntelBodyBuilder;

/// Public alias for [DSEntityIntelFixtures].
typedef PrismEntityIntelFixtures = DSEntityIntelFixtures;

/// Public alias for [DSEntityLocateSearch].
///
/// Multi-corpus entity/place locate with result list and locate callback.
/// Emits [PrismLocateResult] payloads — **not** a [PrismCommandPalette] clone
/// (commands vs spatial/entity locate; EPIC-15 O-05 / Task 1506).
typedef PrismEntityLocateSearch = DSEntityLocateSearch;

/// Public alias for [DSLocateCorpus].
typedef PrismLocateCorpus = DSLocateCorpus;

/// Public alias for [DSLocateEntry].
typedef PrismLocateEntry = DSLocateEntry;

/// Public alias for [DSLocateResult].
///
/// Entity/spatial locate payload (`entityId`, `entityType`, optional coords).
/// Distinct from [PrismCommand] command-id execution.
typedef PrismLocateResult = DSLocateResult;

/// Public alias for [DSArtifactWorkbench].
///
/// Side-panel list + multi-type preview workbench for agent-generated
/// artifacts (code / markdown / text MVP). Distinct from EPIC-15 media
/// detail overlay and from [PrismLogViewer].
typedef PrismArtifactWorkbench = DSArtifactWorkbench;

/// Public alias for [DSArtifact].
typedef PrismArtifact = DSArtifact;

/// Public alias for [DSArtifactType].
typedef PrismArtifactType = DSArtifactType;

/// Multi-type artifact fixture set for gallery and tests (local content only).
List<PrismArtifact> prismArtifactWorkbenchFixtures() =>
    dsArtifactWorkbenchFixtures();

/// Unknown-type artifact fixture for fallback demos/tests.
PrismArtifact prismArtifactUnknownFixture({String id = 'art-unknown-1'}) =>
    dsArtifactUnknownFixture(id: id);

/// Public alias for [DSStatusTicker].
///
/// Marquee / rotating fixture status strip for continuous chrome (bottom HUD).
/// Severity accents use [PrismOperationalState] tokens. Distinct from
/// [PrismStatusGrid] health cards and discrete [PrismToast] notifications.
///
/// Reduced motion ([MediaQuery.disableAnimations] / `animate: false`) shows a
/// static multi-item strip so content is never infinite-animation-only.
typedef PrismStatusTicker = DSStatusTicker;

/// Public alias for [DSStatusTickerItem].
typedef PrismStatusTickerItem = DSStatusTickerItem;

/// Public alias for [DSStatusTickerMode].
typedef PrismStatusTickerMode = DSStatusTickerMode;

/// Public alias for [DSStatusTickerController].
typedef PrismStatusTickerController = DSStatusTickerController;

/// Public alias for [DSStatusTickerFixtures].
typedef PrismStatusTickerFixtures = DSStatusTickerFixtures;

/// Public alias for [DSWatchlistDock].
///
/// Compact pinned-entity dock for stage chrome (expand/collapse, select,
/// unpin). Fixture pin set only — EPIC-15 O-11 / Task 1509.
typedef PrismWatchlistDock = DSWatchlistDock;

/// Public alias for [DSWatchlistItem].
typedef PrismWatchlistItem = DSWatchlistItem;

/// Public alias for [DSWatchlistFixtures].
typedef PrismWatchlistFixtures = DSWatchlistFixtures;

/// Public alias for [DSCoordinateStatusBar].
///
/// Read-only stage coordinate + feed-health strip. Fixture coords/feeds only
/// — no MapLibre / live geocoder (EPIC-15 O-12 / Task 1509).
typedef PrismCoordinateStatusBar = DSCoordinateStatusBar;

/// Public alias for [DSCoordinateFeedHealth].
typedef PrismCoordinateFeedHealth = DSCoordinateFeedHealth;

/// Public alias for [DSCoordinateFeedStatus].
typedef PrismCoordinateFeedStatus = DSCoordinateFeedStatus;

/// Public alias for [DSCoordinateStatusFixtures].
typedef PrismCoordinateStatusFixtures = DSCoordinateStatusFixtures;

/// Public alias for [DSMapLegend].
///
/// Categorized map/stage legend catalog (icon + label, collapsible groups,
/// optional visibility toggles). Distinct from graph canvas legends
/// (EPIC-15 O-13 / Task 1509).
typedef PrismMapLegend = DSMapLegend;

/// Public alias for [DSMapLegendCategory].
typedef PrismMapLegendCategory = DSMapLegendCategory;

/// Public alias for [DSMapLegendItem].
typedef PrismMapLegendItem = DSMapLegendItem;

/// Public alias for [DSMapLegendFixtures].
typedef PrismMapLegendFixtures = DSMapLegendFixtures;

/// Public alias for [DSOsintWorkbench].
///
/// Tabbed recon workbench: tool tab registry, query submit, session history,
/// structured fixture results, and optional map handoff when a result carries
/// geo coordinates. **Fixture-first only** — no live OSINT APIs, no API keys,
/// no MapLibre (EPIC-15 O-08 / Task 1510). Harvests mode contract from Osiris
/// `OsintPanel` / ShadowBroker `ReconPanel` — not megafile structure.
typedef PrismOsintWorkbench = DSOsintWorkbench;

/// Public alias for [DSOsintTool].
typedef PrismOsintTool = DSOsintTool;

/// Public alias for [DSOsintResult].
typedef PrismOsintResult = DSOsintResult;

/// Public alias for [DSOsintResultField].
typedef PrismOsintResultField = DSOsintResultField;

/// Public alias for [DSOsintHistoryEntry].
typedef PrismOsintHistoryEntry = DSOsintHistoryEntry;

/// Public alias for [DSOsintMapHandoff].
typedef PrismOsintMapHandoff = DSOsintMapHandoff;

/// Public alias for [DSOsintFixtures].
typedef PrismOsintFixtures = DSOsintFixtures;

/// Public alias for [DSOsintFixtureResolver].
typedef PrismOsintFixtureResolver = DSOsintFixtureResolver;

/// Public alias for [DSAiAnalystPanel].
///
/// Fixture-first chat/intel turns panel with composer and scripted replies.
/// No live model keys or network — EPIC-15 O-15 / Task 1511.
/// Distinct from [PrismAgentTranscript] (read-only multi-block chat) and from
/// [PrismAgentShellPanel] (terminal/session shell).
typedef PrismAiAnalystPanel = DSAiAnalystPanel;

/// Public alias for [DSAiAnalystTurn].
typedef PrismAiAnalystTurn = DSAiAnalystTurn;

/// Public alias for [DSAiAnalystRole].
typedef PrismAiAnalystRole = DSAiAnalystRole;

/// Public alias for [DSAiAnalystTurnStatus].
typedef PrismAiAnalystTurnStatus = DSAiAnalystTurnStatus;

/// Public alias for [DSAiAnalystController].
typedef PrismAiAnalystController = DSAiAnalystController;

/// Public alias for [DSAiAnalystReplyAdapter].
typedef PrismAiAnalystReplyAdapter = DSAiAnalystReplyAdapter;

/// Default deterministic fixture reply adapter (keyword script, no network).
String prismAiAnalystDefaultFixtureReply(
  String userMessage,
  List<PrismAiAnalystTurn> history,
) => dsAiAnalystDefaultFixtureReply(userMessage, history);

/// Multi-turn fixture conversation for gallery and tests.
List<PrismAiAnalystTurn> prismAiAnalystFixtureTurns({DateTime? anchor}) =>
    dsAiAnalystFixtureTurns(anchor: anchor);

/// Single-turn error fixture for demos/tests.
PrismAiAnalystTurn prismAiAnalystErrorFixtureTurn({
  String id = 'ai-err-1',
  DateTime? timestamp,
}) => dsAiAnalystErrorFixtureTurn(id: id, timestamp: timestamp);

/// Public alias for [DSFloatingAnalyticsHud].
///
/// Draggable, minimizable multi-section analytics overlay for stage hosts.
/// Fixture metrics only — no live telemetry (EPIC-15 O-09 / Task 1514).
/// Distinct from [PrismStatusGrid] health cards and app-frame [PrismShell].
typedef PrismFloatingAnalyticsHud = DSFloatingAnalyticsHud;

/// Public alias for [DSFloatingAnalyticsSection].
typedef PrismFloatingAnalyticsSection = DSFloatingAnalyticsSection;

/// Public alias for [DSFloatingAnalyticsMetric].
typedef PrismFloatingAnalyticsMetric = DSFloatingAnalyticsMetric;

/// Public alias for [DSFloatingAnalyticsHudController].
typedef PrismFloatingAnalyticsHudController = DSFloatingAnalyticsHudController;

/// Public alias for [DSFloatingAnalyticsFixtures].
typedef PrismFloatingAnalyticsFixtures = DSFloatingAnalyticsFixtures;

/// Public alias for [DSOpsControlCluster].
///
/// Dense ops launcher cluster (status + navigate affordances). Fixture-first
/// — no deploy mutation / admin write paths (EPIC-15 O-16 / Task 1515).
typedef PrismOpsControlCluster = DSOpsControlCluster;

/// Public alias for [DSOpsLauncher].
typedef PrismOpsLauncher = DSOpsLauncher;

/// Public alias for [DSOpsControlClusterFixtures].
typedef PrismOpsControlClusterFixtures = DSOpsControlClusterFixtures;

/// Public alias for [DSConnectorPanel].
///
/// Generic minimizable panel chrome: header, badge, refresh, minimize, body
/// slot. Prefer over domain one-off panels (EPIC-15 O-20 / Task 1515).
typedef PrismConnectorPanel = DSConnectorPanel;

/// Public alias for [DSConnectorPanelFixtures].
typedef PrismConnectorPanelFixtures = DSConnectorPanelFixtures;

/// Public alias for [DSMapCanvasStage].
///
/// Engine-agnostic map/stage **contract** organism: layer registry, selection
/// bus, popup factory slot, and fixture placeholder renderer.
///
/// **Not a MapLibre / react-map-gl port.** Real engines are out of EPIC-15
/// scope (O-17 / Task 1512). Prefer as [PrismMapHudWorkspace] stage child.
typedef PrismMapCanvasStage = DSMapCanvasStage;

/// Public alias for [DSMapCanvasStageController].
///
/// Layer registry (add/remove/toggle visibility), feature catalog, and
/// selection bus (select/clear + listeners).
typedef PrismMapCanvasStageController = DSMapCanvasStageController;

/// Public alias for [DSMapStageLayerEntry].
typedef PrismMapStageLayerEntry = DSMapStageLayerEntry;

/// Public alias for [DSMapStageFeature].
typedef PrismMapStageFeature = DSMapStageFeature;

/// Public alias for [DSMapStageSelectionEvent].
typedef PrismMapStageSelectionEvent = DSMapStageSelectionEvent;

/// Public alias for [DSMapStageSelectionKind].
typedef PrismMapStageSelectionKind = DSMapStageSelectionKind;

/// Public alias for [DSMapStagePopupBuilder].
typedef PrismMapStagePopupBuilder = DSMapStagePopupBuilder;

/// Public alias for [DSMapStageSelectionListener].
typedef PrismMapStageSelectionListener = DSMapStageSelectionListener;

/// Public alias for [DSMapCanvasStageFixtures].
typedef PrismMapCanvasStageFixtures = DSMapCanvasStageFixtures;

/// Public alias for [DSTerminalWorkspace].
///
/// Multi-pane sovereign console shell with fixture panes (not a real PTY).
typedef PrismTerminalWorkspace = DSTerminalWorkspace;

/// Public alias for [DSTerminalPane].
typedef PrismTerminalPane = DSTerminalPane;

/// Public alias for [DSTerminalLayoutMode].
typedef PrismTerminalLayoutMode = DSTerminalLayoutMode;

/// Public alias for [DSTerminalWorkspaceController].
typedef PrismTerminalWorkspaceController = DSTerminalWorkspaceController;

/// Public alias for [DSAgentShellLineType].
typedef PrismAgentShellLineType = DSAgentShellLineType;

/// Public alias for [DSAgentShellLine].
typedef PrismAgentShellLine = DSAgentShellLine;

/// Public alias for [DSAgentShellPanelController].
typedef PrismAgentShellPanelController = DSAgentShellPanelController;

/// Public alias for [DSAgentShellPanel].
typedef PrismAgentShellPanel = DSAgentShellPanel;

// =============================================================================
// COMPONENTS — Additional promoted types
// =============================================================================

/// Public alias for [DSBadge].
typedef PrismBadge = DSBadge;

/// Public alias for [DSIcon].
typedef PrismIcon = DSIcon;

/// Public alias for [DSIcons].
typedef PrismIcons = DSIcons;

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

/// Public alias for [DSLogEntry].
typedef PrismLogEntry = DSLogEntry;

/// Public alias for [DSLogSeverity].
typedef PrismLogSeverity = DSLogSeverity;

/// Public alias for [DSLogEntryWidget].
typedef PrismLogEntryWidget = DSLogEntryWidget;

/// Public alias for [DSLogFilterBar].
typedef PrismLogFilterBar = DSLogFilterBar;

// =============================================================================
// ATOMS — Additional aliases
// =============================================================================

/// Public alias for [DSButton].
typedef PrismButton = DSButton;

/// Public alias for [DSButtonVariant].
typedef PrismButtonVariant = DSButtonVariant;

/// Public alias for [DSButtonSize].
typedef PrismButtonSize = DSButtonSize;

/// Public alias for [DSCheckbox].
typedef PrismCheckbox = DSCheckbox;

/// Public alias for [DSTextField].
typedef PrismTextField = DSTextField;

/// Public alias for [DSSwitch].
typedef PrismSwitch = DSSwitch;

/// Public alias for [DSChip].
typedef PrismChip = DSChip;

/// Public alias for [DSChipSize].
typedef PrismChipSize = DSChipSize;

/// Public alias for [DSDivider].
typedef PrismDivider = DSDivider;

/// Public alias for [DSGlowDivider].
typedef PrismGlowDivider = DSGlowDivider;

/// Public alias for [DSGlassPanel].
typedef PrismGlassPanel = DSGlassPanel;

/// Public alias for [DSGlassPanelSimple].
typedef PrismGlassPanelSimple = DSGlassPanelSimple;

/// Public alias for [DSGlassPanelVariant].
typedef PrismGlassPanelVariant = DSGlassPanelVariant;

/// Public alias for [DSGlowBorder].
typedef PrismGlowBorder = DSGlowBorder;

/// Public alias for [DSBadgeSize].
typedef PrismBadgeSize = DSBadgeSize;

/// Public alias for [DSBadgeVariant].
typedef PrismBadgeVariant = DSBadgeVariant;

/// Public alias for [DSIconSize].
typedef PrismIconSize = DSIconSize;

/// Public alias for [DSTextVariant].
typedef PrismTextVariant = DSTextVariant;

// =============================================================================
// MOLECULES — Additional aliases
// =============================================================================

/// Public alias for [DSDraggableCard].
typedef PrismDraggableCard = DSDraggableCard;

/// Public alias for [DSDragPayload].
typedef PrismDragPayload = DSDragPayload;

/// Public alias for [DSDragMoveEvent].
typedef PrismDragMoveEvent = DSDragMoveEvent;

/// Public alias for [DSDragReorderEvent].
typedef PrismDragReorderEvent = DSDragReorderEvent;

/// Public alias for [DSDragReorderIntent] (keyboard Alt+Up/Down).
typedef PrismDragReorderIntent = DSDragReorderIntent;

/// Public alias for [DSDragMoveLaneIntent] (keyboard Alt+Left/Right).
typedef PrismDragMoveLaneIntent = DSDragMoveLaneIntent;

/// Public alias for [DSDropTarget].
typedef PrismDropTarget = DSDropTarget;

/// Public alias for [DSToastEntry].
typedef PrismToastEntry = DSToastEntry;

/// Public alias for [DSToastSeverity].
typedef PrismToastSeverity = DSToastSeverity;

/// Public alias for [DSToastManagerState].
typedef PrismToastManagerState = DSToastManagerState;

// =============================================================================
// ORGANISMS — Additional aliases
// =============================================================================

/// Public alias for [DSDetailInspector].
typedef PrismDetailInspector = DSDetailInspector;

/// Public alias for [DSDetailSection].
typedef PrismDetailSection = DSDetailSection;

/// Public alias for [DSPropertyRow].
typedef PrismPropertyRow = DSPropertyRow;

/// Public alias for [DSLinkRow].
typedef PrismLinkRow = DSLinkRow;

/// Public alias for [DSGraphCanvas].
typedef PrismGraphCanvas = DSGraphCanvas;

/// Public alias for [DSEntityRelationCard].
typedef PrismEntityRelationCard = DSEntityRelationCard;

/// Public alias for [GraphNode].
typedef PrismGraphNode = GraphNode;

/// Public alias for [GraphEdge].
typedef PrismGraphEdge = GraphEdge;

/// Public alias for [DSShell].
typedef PrismShell = DSShell;

/// Public alias for [DSTopbarAction].
typedef PrismTopbarAction = DSTopbarAction;

/// Public alias for [DSStoryCardQuick].
typedef PrismStoryCardQuick = DSStoryCardQuick;

/// Public alias for [DSStoryNarrativeInsight].
typedef PrismStoryNarrativeInsight = DSStoryNarrativeInsight;

/// Public alias for [InsightRiskLevel].
typedef PrismInsightRiskLevel = InsightRiskLevel;

/// Public alias for [DSTimelineGroup].
typedef PrismTimelineGroup = DSTimelineGroup;

/// Public alias for [DSTimelineGrouped].
typedef PrismTimelineGrouped = DSTimelineGrouped;

/// Public alias for [DSTab].
typedef PrismTab = DSTab;

/// Public alias for [DSTabController].
typedef PrismTabController = DSTabController;

/// Public alias for [DSTabView].
typedef PrismTabView = DSTabView;

/// Public alias for [DSVirtualScrollConfig].
typedef PrismVirtualScrollConfig = DSVirtualScrollConfig;

// =============================================================================
// DATA TABLE — Additional aliases
// =============================================================================

/// Public alias for [DSActionItem].
typedef PrismActionItem = DSActionItem;

/// Public alias for [DSActionsCell].
typedef PrismActionsCell = DSActionsCell;

/// Public alias for [DSBadgeCell].
typedef PrismBadgeCell = DSBadgeCell;

/// Public alias for [DSSecretCell].
typedef PrismSecretCell = DSSecretCell;

/// Public alias for [DSTimestampCell].
typedef PrismTimestampCell = DSTimestampCell;

/// Public alias for [DSTablePagination].
typedef PrismTablePagination = DSTablePagination;

/// Public alias for [DSSortState].
typedef PrismSortState = DSSortState;

/// Public alias for [DSSortDirection].
typedef PrismSortDirection = DSSortDirection;

/// Public alias for [DSCellRenderer].
typedef PrismCellRenderer = DSCellRenderer;

// =============================================================================
// COMMAND PALETTE — Additional aliases
// =============================================================================

/// Public alias for [DSCommandPaletteShortcut].
typedef PrismCommandPaletteShortcut = DSCommandPaletteShortcut;

/// Public alias for [DSCommandCategory].
typedef PrismCommandCategory = DSCommandCategory;

// =============================================================================
// GALLERY — Public Prism* surface (DSGallery* remains internal)
// =============================================================================

/// Public alias for [DSGallerySectionSpec].
///
/// Stable gallery section contract: id, title, subtitle, and builder.
typedef PrismGallerySectionSpec = DSGallerySectionSpec;

/// Public alias for [DSGallerySections].
///
/// Static section builders for the design-system gallery proof surface.
typedef PrismGallerySections = DSGallerySections;

// =============================================================================
// EPIC-15 Wave I optional polish — Tasks 1522 / 1523 (O-24 / O-26 / O-27 / O-28)
// =============================================================================

/// Public alias for [DSKeyboardCheatsheet].
///
/// Modal keyboard shortcut reference overlay with keycap rows. Fixture
/// shortcuts only — no key-binding engine (EPIC-15 O-24 / Task 1522).
/// Distinct from [PrismCommandPalette] (execute commands vs reference map).
typedef PrismKeyboardCheatsheet = DSKeyboardCheatsheet;

/// Public alias for [DSKeyboardShortcut].
typedef PrismKeyboardShortcut = DSKeyboardShortcut;

/// Public alias for [DSKeyboardShortcutGroup].
typedef PrismKeyboardShortcutGroup = DSKeyboardShortcutGroup;

/// Public alias for [DSKeyboardCheatsheetFixtures].
typedef PrismKeyboardCheatsheetFixtures = DSKeyboardCheatsheetFixtures;

/// Public alias for [DSScaleMeasureBar].
///
/// **Molecule** (not organism): compact read-only map scale chrome with
/// fixture label/segments. No zoom math / MapLibre (EPIC-15 O-26 / Task 1522).
typedef PrismScaleMeasureBar = DSScaleMeasureBar;

/// Public alias for [DSScaleSegment].
typedef PrismScaleSegment = DSScaleSegment;

/// Public alias for [DSScaleMeasureBarFixtures].
typedef PrismScaleMeasureBarFixtures = DSScaleMeasureBarFixtures;

/// Public alias for [DSToastRiskTier].
///
/// Risk-aware toast variant tiers for the **existing** toast manager —
/// not a second toast stack (EPIC-15 O-28 / Task 1522).
typedef PrismToastRiskTier = DSToastRiskTier;

/// Public alias for [DSMediaDetailOverlay].
///
/// Lightbox-style fixture media review overlay. Placeholder frames only —
/// no hls.js / WebRTC / live CCTV (EPIC-15 O-27 / Task 1523).
typedef PrismMediaDetailOverlay = DSMediaDetailOverlay;

/// Public alias for [DSMediaDetailItem].
typedef PrismMediaDetailItem = DSMediaDetailItem;

/// Public alias for [DSMediaDetailFixtures].
typedef PrismMediaDetailFixtures = DSMediaDetailFixtures;

// =============================================================================
// BREADCRUMBS — Task 1706
// =============================================================================

/// Public alias for [DSBreadcrumbs].
///
/// Hierarchical navigation path display with custom separators, active item
/// highlight, click callbacks, optional auto-derivation from route location,
/// and middle-item collapse/truncation for long breadcrumb paths.
typedef PrismBreadcrumbs = DSBreadcrumbs;

/// Public alias for [DSBreadcrumbItem].
typedef PrismBreadcrumbItem = DSBreadcrumbItem;
