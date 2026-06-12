/// Typed view-model contracts for workspace consumers.
///
/// These contracts expose presentation-ready data shapes that UI surfaces
/// (Overview, Map, Operate, History, Governance) consume instead of
/// parsing raw data or touching repositories directly.
///
/// Each view-model is a plain immutable data class — it does not own
/// loading logic. Providers build these from service outputs.
library;

import 'package:flutter/foundation.dart';
import '../models/workspace_graph.dart';
import '../models/task_contracts.dart';
import '../models/governance_diagnostics.dart';
import '../services/workspace_metrics_service.dart';
import '../services/workspace_diagnostics_service.dart';
import '../services/workspace_graph.dart';

// ---------------------------------------------------------------------------
// Shell Overview Contract
// ---------------------------------------------------------------------------

/// Top-level view model for the Overview (shell) surface.
///
/// Aggregates asset totals, blocker summary, review queue pressure,
/// governance warnings, and graph health into a single contract that
/// the shell can render without touching individual services.
@immutable
class WorkspaceOverviewViewModel {
  /// Total number of assets in the workspace.
  final int totalAssets;

  /// Asset counts grouped by kind.
  final Map<AssetKind, int> assetsByKind;

  /// Number of blocked tasks (tasks with unresolved dependencies).
  final int blockedTaskCount;

  /// Number of tasks in the review lane.
  final int reviewQueueCount;

  /// Number of tasks lacking proof.
  final int proofGapCount;

  /// Number of high-severity governance warnings.
  final int criticalWarningCount;

  /// Number of total governance warnings.
  final int totalWarningCount;

  /// Total edges in the normalized graph.
  final int totalEdges;

  /// Task breakdown by lane.
  final Map<TaskLane, int> tasksByLane;

  const WorkspaceOverviewViewModel({
    required this.totalAssets,
    required this.assetsByKind,
    required this.blockedTaskCount,
    required this.reviewQueueCount,
    required this.proofGapCount,
    required this.criticalWarningCount,
    required this.totalWarningCount,
    required this.totalEdges,
    required this.tasksByLane,
  });

  /// Build from metrics and diagnostics service outputs.
  factory WorkspaceOverviewViewModel.from({
    required WorkspaceMetricsSummary metrics,
    required DiagnosticsReport diagnostics,
  }) {
    final criticalCount =
        diagnostics.bySeverity(DiagnosticSeverity.error).length +
        diagnostics.bySeverity(DiagnosticSeverity.critical).length;

    return WorkspaceOverviewViewModel(
      totalAssets: metrics.totalAssets,
      assetsByKind: metrics.assetsByKind,
      blockedTaskCount: metrics.blockedTaskCount,
      reviewQueueCount: metrics.reviewQueueCount,
      proofGapCount: metrics.proofGapCount,
      criticalWarningCount: criticalCount,
      totalWarningCount: diagnostics.diagnostics.length,
      totalEdges: metrics.totalEdges,
      tasksByLane: metrics.tasksByLane,
    );
  }

  /// An empty overview with all zeroes.
  const WorkspaceOverviewViewModel.empty()
    : totalAssets = 0,
      assetsByKind = const {},
      blockedTaskCount = 0,
      reviewQueueCount = 0,
      proofGapCount = 0,
      criticalWarningCount = 0,
      totalWarningCount = 0,
      totalEdges = 0,
      tasksByLane = const {};

  /// Whether the workspace has any tasks.
  bool get hasTasks => tasksByLane.values.fold(0, (a, b) => a + b) > 0;

  /// Whether there are any blockers to show.
  bool get hasBlockers => blockedTaskCount > 0;

  /// Whether there are governance warnings.
  bool get hasWarnings => totalWarningCount > 0;

  /// Total task count across all lanes.
  int get totalTaskCount => tasksByLane.values.fold(0, (a, b) => a + b);
}

// ---------------------------------------------------------------------------
// Map Surface Contract
// ---------------------------------------------------------------------------

/// View model for the Map (graph visualization) surface.
///
/// Carries the graph result plus summary metrics relevant to the map.
@immutable
class MapViewModel {
  /// The normalized workspace graph.
  final WorkspaceGraphResult graph;

  /// Total node count.
  int get nodeCount => graph.nodeCount;

  /// Total edge count.
  int get edgeCount => graph.edgeCount;

  /// Whether the graph is empty.
  bool get isEmpty => graph.isEmpty;

  const MapViewModel({required this.graph});

  /// An empty map view model.
  const MapViewModel.empty() : graph = const WorkspaceGraphResult.empty();
}

// ---------------------------------------------------------------------------
// Operate Surface Contract
// ---------------------------------------------------------------------------

/// View model for the Operate (task lanes) surface.
///
/// Carries task lane breakdowns plus operational risk signals.
@immutable
class OperateViewModel {
  /// Task counts grouped by lane.
  final Map<TaskLane, int> tasksByLane;

  /// Number of blocked tasks.
  final int blockedTaskCount;

  /// Number of tasks in the review queue.
  final int reviewQueueCount;

  /// Number of proof gaps.
  final int proofGapCount;

  /// Number of tasks without verification commands.
  final int tasksWithoutVerification;

  const OperateViewModel({
    required this.tasksByLane,
    required this.blockedTaskCount,
    required this.reviewQueueCount,
    required this.proofGapCount,
    required this.tasksWithoutVerification,
  });

  /// Build from metrics service output.
  factory OperateViewModel.fromMetrics(WorkspaceMetricsSummary metrics) {
    return OperateViewModel(
      tasksByLane: metrics.tasksByLane,
      blockedTaskCount: metrics.blockedTaskCount,
      reviewQueueCount: metrics.reviewQueueCount,
      proofGapCount: metrics.proofGapCount,
      tasksWithoutVerification: metrics.tasksWithoutVerification,
    );
  }

  /// An empty operate view model.
  const OperateViewModel.empty()
    : tasksByLane = const {},
      blockedTaskCount = 0,
      reviewQueueCount = 0,
      proofGapCount = 0,
      tasksWithoutVerification = 0;

  /// Total task count.
  int get totalTaskCount => tasksByLane.values.fold(0, (a, b) => a + b);
}

// ---------------------------------------------------------------------------
// History Surface Contract
// ---------------------------------------------------------------------------

/// View model for the History (changelog timeline) surface.
@immutable
class HistoryViewModel {
  /// Number of changelog entries linked to tasks.
  final int changelogWithTaskLink;

  /// Number of changelog entries without a task link.
  final int changelogWithoutTaskLink;

  /// Total edges in the graph.
  final int totalEdges;

  const HistoryViewModel({
    required this.changelogWithTaskLink,
    required this.changelogWithoutTaskLink,
    required this.totalEdges,
  });

  /// Build from metrics service output.
  factory HistoryViewModel.fromMetrics(WorkspaceMetricsSummary metrics) {
    return HistoryViewModel(
      changelogWithTaskLink: metrics.changelogWithTaskLink,
      changelogWithoutTaskLink: metrics.changelogWithoutTaskLink,
      totalEdges: metrics.totalEdges,
    );
  }

  /// An empty history view model.
  const HistoryViewModel.empty()
    : changelogWithTaskLink = 0,
      changelogWithoutTaskLink = 0,
      totalEdges = 0;

  /// Total changelog entries.
  int get totalChangelog => changelogWithTaskLink + changelogWithoutTaskLink;
}

// ---------------------------------------------------------------------------
// Governance Surface Contract
// ---------------------------------------------------------------------------

/// View model for the Governance (provenance and diagnostics) surface.
@immutable
class GovernanceViewModel {
  /// All diagnostics from the workspace scan.
  final List<GovernanceDiagnostic> diagnostics;

  /// Count of diagnostics by category.
  final Map<DiagnosticCategory, int> countsByCategory;

  /// Count of diagnostics by severity.
  final Map<DiagnosticSeverity, int> countsBySeverity;

  /// Number of orphan assets.
  final int orphanCount;

  /// Number of proof gaps.
  final int proofGapCount;

  /// Number of high fan-in hotspots.
  final int hotspotCount;

  const GovernanceViewModel({
    required this.diagnostics,
    required this.countsByCategory,
    required this.countsBySeverity,
    required this.orphanCount,
    required this.proofGapCount,
    required this.hotspotCount,
  });

  /// Build from diagnostics service output.
  factory GovernanceViewModel.fromReport(DiagnosticsReport report) {
    return GovernanceViewModel(
      diagnostics: report.diagnostics,
      countsByCategory: report.countsByCategory,
      countsBySeverity: report.countsBySeverity,
      orphanCount: report.byCategory(DiagnosticCategory.orphanAsset).length,
      proofGapCount: report.byCategory(DiagnosticCategory.proofGap).length,
      hotspotCount: report.byCategory(DiagnosticCategory.brokenEdge).length,
    );
  }

  /// An empty governance view model.
  const GovernanceViewModel.empty()
    : diagnostics = const [],
      countsByCategory = const {},
      countsBySeverity = const {},
      orphanCount = 0,
      proofGapCount = 0,
      hotspotCount = 0;

  /// Whether there are any diagnostics.
  bool get hasDiagnostics => diagnostics.isNotEmpty;

  /// Total diagnostic count.
  int get totalCount => diagnostics.length;
}
