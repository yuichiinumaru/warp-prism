/// Governance diagnostics service for the ASW Observatory.
///
/// Computes typed [GovernanceDiagnostic] records from the canonical
/// workspace graph. Covers orphan assets, stale references, proof gaps,
/// and high fan-in hotspots.
///
/// Diagnostics are read-only and explainable — each record carries enough
/// context for drill-down to the affected asset(s).
///
/// This service is pure and stateless — it takes a [WorkspaceGraphResult]
/// and returns a list of [GovernanceDiagnostic].
library;

import '../models/workspace_graph.dart';
import '../models/task_contracts.dart';
import '../models/governance_diagnostics.dart';
import 'workspace_graph.dart';

/// Governance diagnostics result from scanning the workspace graph.
///
/// Contains the raw list of diagnostics plus convenience accessors for
/// filtering by category or severity.
class DiagnosticsReport {
  /// All diagnostics found in the graph scan.
  final List<GovernanceDiagnostic> diagnostics;

  const DiagnosticsReport({required this.diagnostics});

  /// An empty report with no diagnostics.
  const DiagnosticsReport.empty() : diagnostics = const [];

  /// Whether any diagnostics were found.
  bool get hasWarnings => diagnostics.isNotEmpty;

  /// Diagnostics filtered by category.
  List<GovernanceDiagnostic> byCategory(DiagnosticCategory category) =>
      diagnostics.where((d) => d.category == category).toList();

  /// Diagnostics filtered by severity.
  List<GovernanceDiagnostic> bySeverity(DiagnosticSeverity severity) =>
      diagnostics.where((d) => d.severity == severity).toList();

  /// Count of diagnostics by category.
  Map<DiagnosticCategory, int> get countsByCategory {
    final counts = <DiagnosticCategory, int>{};
    for (final cat in DiagnosticCategory.values) {
      counts[cat] = 0;
    }
    for (final d in diagnostics) {
      counts[d.category] = (counts[d.category] ?? 0) + 1;
    }
    return counts;
  }

  /// Count of diagnostics by severity.
  Map<DiagnosticSeverity, int> get countsBySeverity {
    final counts = <DiagnosticSeverity, int>{};
    for (final sev in DiagnosticSeverity.values) {
      counts[sev] = 0;
    }
    for (final d in diagnostics) {
      counts[d.severity] = (counts[d.severity] ?? 0) + 1;
    }
    return counts;
  }

  @override
  String toString() => 'DiagnosticsReport(${diagnostics.length} diagnostics)';
}

/// Computes governance diagnostics from a [WorkspaceGraphResult].
///
/// Usage:
/// ```dart
/// const service = WorkspaceDiagnosticsService();
/// final report = service.analyze(graph);
/// ```
class WorkspaceDiagnosticsService {
  /// Minimum fan-in count to flag an asset as a hotspot.
  static const int defaultFanInThreshold = 3;

  const WorkspaceDiagnosticsService();

  /// Analyze the [graph] and return a [DiagnosticsReport].
  ///
  /// Runs all diagnostic rules in order:
  /// 1. Orphan assets (no incoming or outgoing edges)
  /// 2. Stale references (edges pointing to non-existent assets)
  /// 3. Proof gaps (tasks in review/completed without proof)
  /// 4. High fan-in hotspots (assets with many incoming edges)
  DiagnosticsReport analyze(
    WorkspaceGraphResult graph, {
    int fanInThreshold = defaultFanInThreshold,
  }) {
    final diagnostics = <GovernanceDiagnostic>[];
    final now = DateTime.now();

    _detectOrphanAssets(graph, diagnostics, now);
    _detectStaleReferences(graph, diagnostics, now);
    _detectProofGaps(graph, diagnostics, now);
    _detectHighFanIn(graph, diagnostics, now, fanInThreshold);

    return DiagnosticsReport(diagnostics: diagnostics);
  }

  // ---------------------------------------------------------------------------
  // Orphan detection
  // ---------------------------------------------------------------------------

  /// An asset with no incoming AND no outgoing edges is an orphan.
  ///
  /// Self-loops (proves edges) do NOT count as connections.
  void _detectOrphanAssets(
    WorkspaceGraphResult graph,
    List<GovernanceDiagnostic> diagnostics,
    DateTime now,
  ) {
    // Build sets of assets that appear in any non-self-loop edge
    final connected = <String>{};
    for (final edge in graph.edges) {
      if (edge.sourceId != edge.targetId) {
        connected.add(edge.sourceId);
        connected.add(edge.targetId);
      }
    }

    for (final asset in graph.assetsById.values) {
      if (!connected.contains(asset.id)) {
        diagnostics.add(
          GovernanceDiagnostic(
            assetId: asset.id,
            severity: DiagnosticSeverity.warning,
            category: DiagnosticCategory.orphanAsset,
            message:
                'Asset "${asset.name}" (${asset.kind.name}) has no '
                'incoming or outgoing edges — it is isolated in the graph.',
            context: {
              'assetKind': asset.kind.name,
              'assetPath': asset.path,
              'assetName': asset.name,
            },
            computedAt: now,
          ),
        );
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Stale reference detection
  // ---------------------------------------------------------------------------

  /// An edge whose target asset does not exist in the graph is a stale
  /// reference.
  void _detectStaleReferences(
    WorkspaceGraphResult graph,
    List<GovernanceDiagnostic> diagnostics,
    DateTime now,
  ) {
    for (final edge in graph.edges) {
      // Self-loops are intentional (proves edges)
      if (edge.sourceId == edge.targetId) continue;

      if (!graph.assetsById.containsKey(edge.targetId)) {
        final source = graph.getAsset(edge.sourceId);
        diagnostics.add(
          GovernanceDiagnostic(
            assetId: edge.sourceId,
            severity: DiagnosticSeverity.error,
            category: DiagnosticCategory.staleReference,
            message:
                'Asset "${source?.name ?? edge.sourceId}" references '
                '"${edge.targetId}" via ${edge.kind.name}, but the target '
                'does not exist in the graph.',
            context: {
              'sourceId': edge.sourceId,
              'targetId': edge.targetId,
              'edgeKind': edge.kind.name,
              'sourceName': source?.name,
              'sourcePath': source?.path,
            },
            computedAt: now,
          ),
        );
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Proof gap detection
  // ---------------------------------------------------------------------------

  /// A task in review or completed lane without proof_state == complete
  /// or verified is a proof gap.
  void _detectProofGaps(
    WorkspaceGraphResult graph,
    List<GovernanceDiagnostic> diagnostics,
    DateTime now,
  ) {
    final tasks = graph.assetsByKind[AssetKind.task] ?? [];
    for (final task in tasks) {
      final meta = task.frontmatter['_taskMetadata'] as TaskMetadata?;
      if (meta == null) continue;

      // Only flag tasks in review or completed lanes
      if (meta.lane != TaskLane.review && meta.lane != TaskLane.completed) {
        continue;
      }

      if (meta.proofState == ProofState.none) {
        diagnostics.add(
          GovernanceDiagnostic(
            assetId: task.id,
            severity: DiagnosticSeverity.error,
            category: DiagnosticCategory.proofGap,
            message:
                'Task "${meta.title}" is in ${meta.lane.directoryPrefix} '
                'but has no proof or evidence.',
            context: {
              'taskId': meta.id,
              'taskTitle': meta.title,
              'taskLane': meta.lane.directoryPrefix,
              'proofState': meta.proofState.name,
              'taskPath': task.path,
            },
            computedAt: now,
          ),
        );
      } else if (meta.proofState == ProofState.partial) {
        diagnostics.add(
          GovernanceDiagnostic(
            assetId: task.id,
            severity: DiagnosticSeverity.warning,
            category: DiagnosticCategory.proofGap,
            message:
                'Task "${meta.title}" is in ${meta.lane.directoryPrefix} '
                'but only has partial proof.',
            context: {
              'taskId': meta.id,
              'taskTitle': meta.title,
              'taskLane': meta.lane.directoryPrefix,
              'proofState': meta.proofState.name,
              'taskPath': task.path,
            },
            computedAt: now,
          ),
        );
      }
    }
  }

  // ---------------------------------------------------------------------------
  // High fan-in hotspot detection
  // ---------------------------------------------------------------------------

  /// An asset receiving [fanInThreshold] or more incoming non-self-loop
  /// edges is flagged as a fan-in hotspot.
  void _detectHighFanIn(
    WorkspaceGraphResult graph,
    List<GovernanceDiagnostic> diagnostics,
    DateTime now,
    int fanInThreshold,
  ) {
    // Count incoming edges per target (excluding self-loops)
    final incomingCounts = <String, int>{};
    for (final edge in graph.edges) {
      if (edge.sourceId == edge.targetId) continue;
      incomingCounts[edge.targetId] = (incomingCounts[edge.targetId] ?? 0) + 1;
    }

    for (final entry in incomingCounts.entries) {
      if (entry.value >= fanInThreshold) {
        final asset = graph.getAsset(entry.key);
        diagnostics.add(
          GovernanceDiagnostic(
            assetId: entry.key,
            severity: entry.value >= fanInThreshold * 2
                ? DiagnosticSeverity.error
                : DiagnosticSeverity.warning,
            category: DiagnosticCategory.brokenEdge,
            message:
                'Asset "${asset?.name ?? entry.key}" has ${entry.value} '
                'incoming edges (fan-in ≥ $fanInThreshold). High fan-in may '
                'indicate a hotspot or over-centralized dependency.',
            context: {
              'targetId': entry.key,
              'incomingEdgeCount': entry.value,
              'threshold': fanInThreshold,
              'assetName': asset?.name,
              'assetKind': asset?.kind.name,
              'assetPath': asset?.path,
            },
            computedAt: now,
          ),
        );
      }
    }
  }
}
