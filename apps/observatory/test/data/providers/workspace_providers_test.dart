/// Tests for workspace provider state transitions and view-model contracts.
///
/// Covers:
/// - Snapshot provider: loading, empty, success, error states
/// - Graph provider: derived from snapshot
/// - Metrics provider: computed from graph
/// - Diagnostics provider: computed from graph
/// - View-model contracts: construction from service outputs
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warp_prism_observatory/data/providers/workspace_providers.dart';
import 'package:warp_prism_observatory/data/providers/workspace_view_models.dart';
import 'package:warp_prism_observatory/data/services/workspace_graph.dart';
import 'package:warp_prism_observatory/data/services/workspace_metrics_service.dart';
import 'package:warp_prism_observatory/data/services/workspace_diagnostics_service.dart';
import 'package:warp_prism_observatory/data/models/workspace_graph.dart';
import 'package:warp_prism_observatory/data/models/task_contracts.dart';
import 'package:warp_prism_observatory/data/models/governance_diagnostics.dart';

void main() {
  group('WorkspaceOverviewViewModel', () {
    test('builds from metrics and diagnostics', () {
      const metrics = WorkspaceMetricsSummary(
        totalAssets: 10,
        assetsByKind: {
          AssetKind.task: 5,
          AssetKind.agent: 3,
          AssetKind.skill: 2,
        },
        tasksByLane: {
          TaskLane.open: 2,
          TaskLane.doing: 1,
          TaskLane.review: 1,
          TaskLane.completed: 1,
          TaskLane.planning: 0,
        },
        blockedTaskCount: 2,
        reviewQueueCount: 1,
        proofGapCount: 1,
        tasksWithoutVerification: 3,
        changelogWithTaskLink: 4,
        changelogWithoutTaskLink: 1,
        totalEdges: 15,
        skillsWithNoTriggers: 0,
        orphanWorkflowCount: 0,
      );

      final diagnostics = DiagnosticsReport(
        diagnostics: [
          GovernanceDiagnostic(
            assetId: 'task:001',
            severity: DiagnosticSeverity.error,
            category: DiagnosticCategory.proofGap,
            message: 'No proof',
            computedAt: DateTime(2026, 1, 1),
          ),
          GovernanceDiagnostic(
            assetId: 'task:002',
            severity: DiagnosticSeverity.warning,
            category: DiagnosticCategory.orphanAsset,
            message: 'Orphan',
            computedAt: DateTime(2026, 1, 1),
          ),
        ],
      );

      final vm = WorkspaceOverviewViewModel.from(
        metrics: metrics,
        diagnostics: diagnostics,
      );

      expect(vm.totalAssets, 10);
      expect(vm.blockedTaskCount, 2);
      expect(vm.reviewQueueCount, 1);
      expect(vm.proofGapCount, 1);
      expect(vm.criticalWarningCount, 1); // 1 error
      expect(vm.totalWarningCount, 2);
      expect(vm.totalEdges, 15);
      expect(vm.hasTasks, true);
      expect(vm.hasBlockers, true);
      expect(vm.hasWarnings, true);
      expect(vm.totalTaskCount, 5);
    });

    test('empty overview has all zeroes', () {
      const vm = WorkspaceOverviewViewModel.empty();
      expect(vm.totalAssets, 0);
      expect(vm.blockedTaskCount, 0);
      expect(vm.hasTasks, false);
      expect(vm.hasBlockers, false);
      expect(vm.hasWarnings, false);
    });
  });

  group('OperateViewModel', () {
    test('builds from metrics', () {
      const metrics = WorkspaceMetricsSummary(
        totalAssets: 8,
        assetsByKind: {AssetKind.task: 5},
        tasksByLane: {
          TaskLane.open: 2,
          TaskLane.doing: 1,
          TaskLane.review: 1,
          TaskLane.completed: 1,
          TaskLane.planning: 0,
        },
        blockedTaskCount: 1,
        reviewQueueCount: 1,
        proofGapCount: 0,
        tasksWithoutVerification: 2,
        changelogWithTaskLink: 0,
        changelogWithoutTaskLink: 0,
        totalEdges: 0,
        skillsWithNoTriggers: 0,
        orphanWorkflowCount: 0,
      );

      final vm = OperateViewModel.fromMetrics(metrics);
      expect(vm.totalTaskCount, 5);
      expect(vm.blockedTaskCount, 1);
      expect(vm.reviewQueueCount, 1);
      expect(vm.proofGapCount, 0);
      expect(vm.tasksWithoutVerification, 2);
    });

    test('empty operate view model', () {
      const vm = OperateViewModel.empty();
      expect(vm.totalTaskCount, 0);
      expect(vm.blockedTaskCount, 0);
    });
  });

  group('HistoryViewModel', () {
    test('builds from metrics', () {
      const metrics = WorkspaceMetricsSummary(
        totalAssets: 0,
        assetsByKind: {},
        tasksByLane: {},
        blockedTaskCount: 0,
        reviewQueueCount: 0,
        proofGapCount: 0,
        tasksWithoutVerification: 0,
        changelogWithTaskLink: 7,
        changelogWithoutTaskLink: 3,
        totalEdges: 20,
        skillsWithNoTriggers: 0,
        orphanWorkflowCount: 0,
      );

      final vm = HistoryViewModel.fromMetrics(metrics);
      expect(vm.totalChangelog, 10);
      expect(vm.changelogWithTaskLink, 7);
      expect(vm.changelogWithoutTaskLink, 3);
      expect(vm.totalEdges, 20);
    });

    test('empty history view model', () {
      const vm = HistoryViewModel.empty();
      expect(vm.totalChangelog, 0);
    });
  });

  group('GovernanceViewModel', () {
    test('builds from diagnostics report', () {
      final report = DiagnosticsReport(
        diagnostics: [
          GovernanceDiagnostic(
            assetId: 'task:001',
            severity: DiagnosticSeverity.error,
            category: DiagnosticCategory.proofGap,
            message: 'No proof',
            computedAt: DateTime(2026, 1, 1),
          ),
          GovernanceDiagnostic(
            assetId: 'agent:001',
            severity: DiagnosticSeverity.warning,
            category: DiagnosticCategory.orphanAsset,
            message: 'Orphan agent',
            computedAt: DateTime(2026, 1, 1),
          ),
          GovernanceDiagnostic(
            assetId: 'task:005',
            severity: DiagnosticSeverity.warning,
            category: DiagnosticCategory.brokenEdge,
            message: 'High fan-in',
            computedAt: DateTime(2026, 1, 1),
          ),
        ],
      );

      final vm = GovernanceViewModel.fromReport(report);
      expect(vm.totalCount, 3);
      expect(vm.hasDiagnostics, true);
      expect(vm.orphanCount, 1);
      expect(vm.proofGapCount, 1);
      expect(vm.hotspotCount, 1);
    });

    test('empty governance view model', () {
      const vm = GovernanceViewModel.empty();
      expect(vm.hasDiagnostics, false);
      expect(vm.totalCount, 0);
    });
  });

  group('MapViewModel', () {
    test('empty map view model', () {
      const vm = MapViewModel.empty();
      expect(vm.isEmpty, true);
      expect(vm.nodeCount, 0);
      expect(vm.edgeCount, 0);
    });

    test('wraps a graph result', () {
      const graph = WorkspaceGraphResult(
        assetsById: {
          'a': WorkspaceAsset(
            id: 'a',
            kind: AssetKind.agent,
            name: 'Agent A',
            path: 'agents/a.md',
          ),
        },
        edges: [],
        assetsByKind: {
          AssetKind.agent: [
            WorkspaceAsset(
              id: 'a',
              kind: AssetKind.agent,
              name: 'Agent A',
              path: 'agents/a.md',
            ),
          ],
        },
      );

      final vm = MapViewModel(graph: graph);
      expect(vm.nodeCount, 1);
      expect(vm.edgeCount, 0);
      expect(vm.isEmpty, false);
    });
  });

  group('Provider state contract', () {
    test('workspaceRootPathProvider returns a non-null string', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final root = container.read(workspaceRootPathProvider);
      expect(root, isNotNull);
      expect(root, isA<String>());
    });

    test('workspaceRepositoryProvider returns a repository', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final repo = container.read(workspaceRepositoryProvider);
      expect(repo, isNotNull);
      expect(repo.rootPath, isNotEmpty);
    });
  });
}
