/// Design System Gallery Registry — single source of truth for all sections.
///
/// This registry exposes all gallery sections with stable IDs, titles, and builders.
/// Both the gallery page and tests consume this registry to prevent drift.
library;

import 'package:flutter/material.dart';
import 'design_system_gallery_sections.dart';

/// A specification for one gallery section.
///
/// Each section has a stable [id] used for programmatic identification,
/// a human-readable [title] displayed in the UI, and a [builder] function
/// that constructs the section widget.
class DSGallerySectionSpec {
  /// Stable identifier for this section.
  ///
  /// Must be unique across all sections. Used for duplicate-ID checks
  /// and programmatic navigation.
  final String id;

  /// Human-readable title displayed in the section card header.
  final String title;

  /// Subtitle describing the section contents.
  final String subtitle;

  /// Builder function that constructs the section widget.
  ///
  /// Returns a [_SectionCard] widget containing the section content.
  final Widget Function() builder;

  const DSGallerySectionSpec({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.builder,
  });
}

/// Registry of all gallery sections in display order.
///
/// This is the single source of truth for:
/// - [DesignSystemGalleryPage] rendering all sections
/// - Catalog tests verifying all sections render
/// - Duplicate-ID uniqueness checks
///
/// When adding a new gallery section, add it here and the page/tests
/// will automatically include it.
const dsGallerySections = <DSGallerySectionSpec>[
  DSGallerySectionSpec(
    id: 'tokens',
    title: 'Tokens',
    subtitle: 'Colors · Typography · Spacing · Radii · Shadows · Motion',
    builder: DSGallerySections.buildTokensSection,
  ),
  DSGallerySectionSpec(
    id: 'atoms',
    title: 'Atoms',
    subtitle:
        'DSText · DSIcon · DSBadge · DSChip · DSButton · DSStatusDot · DSCard',
    builder: DSGallerySections.buildAtomsSection,
  ),
  DSGallerySectionSpec(
    id: 'molecules',
    title: 'Molecules',
    subtitle:
        'DSSearchBar · DSSectionHeader · DSStateSurface · DSShimmer · DSSkeletonCard',
    builder: DSGallerySections.buildMoleculesSection,
  ),
  DSGallerySectionSpec(
    id: 'operational-states',
    title: 'Operational States',
    subtitle:
        'DSOperationalState badges and status indicators for tasks/agents',
    builder: DSGallerySections.buildOperationalStatesSection,
  ),
  DSGallerySectionSpec(
    id: 'organisms',
    title: 'Organisms',
    subtitle:
        'DSSidebar · DSTopBar · DSSearchPanel · DSFilterBar · DSErrorBoundary · '
        '(EPIC-15 / EPIC-16 families → dedicated sections)',
    builder: DSGallerySections.buildOrganismsSection,
  ),
  // EPIC-15 family sections (Task 1519) — Map HUD / OSINT / terminal discoverability.
  // Ordered immediately after Organisms so TOC groups HUD → layers → intel →
  // stage chrome → recon → stage/relations → ops → terminal before EPIC-16.
  DSGallerySectionSpec(
    id: 'epic15-hud',
    title: 'Map HUD Layout',
    subtitle: 'PrismMapHudWorkspace · PrismToolStripSlideout',
    builder: DSGallerySections.buildEpic15HudSection,
  ),
  DSGallerySectionSpec(
    id: 'epic15-layers-filters',
    title: 'Layers & Filters',
    subtitle: 'PrismLayerControlPanel · PrismFilterWorkbench',
    builder: DSGallerySections.buildEpic15LayersFiltersSection,
  ),
  DSGallerySectionSpec(
    id: 'epic15-intel',
    title: 'Intel & Locate',
    subtitle: 'PrismEntityIntelPanel · PrismEntityLocateSearch',
    builder: DSGallerySections.buildEpic15IntelSection,
  ),
  DSGallerySectionSpec(
    id: 'epic15-stage-chrome',
    title: 'Time, Status & Stage Chrome',
    subtitle:
        'PrismTimeMachineScrubber · PrismStatusTicker · PrismWatchlistDock · '
        'PrismCoordinateStatusBar · PrismMapLegend',
    builder: DSGallerySections.buildEpic15StageChromeSection,
  ),
  DSGallerySectionSpec(
    id: 'epic15-cybercore-recon',
    title: 'CyberCore Recon & AI',
    subtitle: 'PrismOsintWorkbench · PrismAiAnalystPanel',
    builder: DSGallerySections.buildEpic15CyberCoreReconSection,
  ),
  DSGallerySectionSpec(
    id: 'epic15-stage-relations',
    title: 'Stage & Relations',
    subtitle: 'PrismMapCanvasStage · PrismEntityRelationCard',
    builder: DSGallerySections.buildEpic15StageRelationsSection,
  ),
  DSGallerySectionSpec(
    id: 'epic15-ops',
    title: 'Ops Pack',
    subtitle:
        'PrismFloatingAnalyticsHud · PrismOpsControlCluster · '
        'PrismConnectorPanel · PrismViewPresets · PrismWorkspaceShareCard',
    builder: DSGallerySections.buildEpic15OpsSection,
  ),
  DSGallerySectionSpec(
    id: 'epic15-terminal',
    title: 'Terminal',
    subtitle: 'PrismTerminalWorkspace · PrismAgentShellPanel',
    builder: DSGallerySections.buildEpic15TerminalSection,
  ),
  DSGallerySectionSpec(
    id: 'epic15-optional-polish',
    title: 'Optional Wave I Polish',
    subtitle:
        'PrismKeyboardCheatsheet · PrismScaleMeasureBar · '
        'PrismMediaDetailOverlay · risk toast (Toasts section)',
    builder: DSGallerySections.buildEpic15OptionalPolishSection,
  ),
  // EPIC-16 family sections (Task 1613) — ordered after EPIC-15 so TOC
  // groups content chrome → transcript → CyberCore ops → workflow/execution.
  DSGallerySectionSpec(
    id: 'epic16-content-chrome',
    title: 'Content Chrome',
    subtitle: 'PrismPageShell · PrismTree',
    builder: DSGallerySections.buildContentChromeSection,
  ),
  DSGallerySectionSpec(
    id: 'epic16-agent-transcript',
    title: 'Agent Transcript',
    subtitle:
        'PrismAgentTranscript · PrismToolCallCard · '
        'PrismMessageStatusHistory · PrismArtifactWorkbench',
    builder: DSGallerySections.buildAgentTranscriptSection,
  ),
  DSGallerySectionSpec(
    id: 'epic16-cybercore-ops',
    title: 'CyberCore Ops',
    subtitle:
        'PrismProviderHealthMatrix · PrismMcpCapabilityInspector · '
        'PrismTimingWaterfall · PrismTrafficInspector',
    builder: DSGallerySections.buildCyberCoreOpsSection,
  ),
  DSGallerySectionSpec(
    id: 'epic16-workflow-execution',
    title: 'Workflow & Execution',
    subtitle: 'PrismWorkflowCanvasStage · PrismExecutionConsole',
    builder: DSGallerySections.buildWorkflowExecutionSection,
  ),
  DSGallerySectionSpec(
    id: 'virtual-scroll',
    title: 'Virtual Scroll',
    subtitle: 'High-performance scrollable lists with virtualization',
    builder: DSGallerySections.buildVirtualScrollSection,
  ),
  DSGallerySectionSpec(
    id: 'health-dashboard',
    title: 'Health Dashboard',
    subtitle: 'System health monitoring and status cards',
    builder: DSGallerySections.buildHealthDashboardSection,
  ),
  DSGallerySectionSpec(
    id: 'toasts',
    title: 'Toasts',
    subtitle: 'DSToast notifications and inline alerts',
    builder: DSGallerySections.buildToastsSection,
  ),
  DSGallerySectionSpec(
    id: 'accessibility-focus',
    title: 'Accessibility & Focus States',
    subtitle: 'Focus rings, semantic labels, and accessibility demonstrations',
    builder: DSGallerySections.buildAccessibilitySection,
  ),
  DSGallerySectionSpec(
    id: 'templates',
    title: 'Templates',
    subtitle: 'MasterDetailTemplate · CanvasTemplate · TimelineTemplate',
    builder: DSGallerySections.buildTemplatesSection,
  ),
];

/// Returns all registered section IDs.
///
/// Used by tests to verify ID uniqueness.
List<String> get dsGallerySectionIds =>
    dsGallerySections.map((s) => s.id).toList();

/// Returns all registered section titles.
///
/// Used by tests to verify all sections render.
List<String> get dsGallerySectionTitles =>
    dsGallerySections.map((s) => s.title).toList();
