/// Tests for workspace provider state transitions and view-model contracts.
///
/// Covers:
/// - Snapshot provider: loading, empty, success, error states
/// - Graph / metrics / diagnostics providers derived from snapshot
/// - View-model contracts: construction from service outputs
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warp_prism_observatory/data/providers/workspace_providers.dart';
import 'package:warp_prism_observatory/data/providers/workspace_view_models.dart';
import 'package:warp_prism_observatory/data/repositories/workspace_repository.dart';
import 'package:warp_prism_observatory/data/repositories/workspace_load_state.dart';
import 'package:warp_prism_observatory/data/repositories/history_repository.dart';
import 'package:warp_prism_observatory/data/services/workspace_graph.dart';
import 'package:warp_prism_observatory/data/services/workspace_metrics_service.dart';
import 'package:warp_prism_observatory/data/services/workspace_diagnostics_service.dart';
import 'package:warp_prism_observatory/data/models/workspace_graph.dart';
import 'package:warp_prism_observatory/data/models/workspace_snapshot.dart';
import 'package:warp_prism_observatory/data/models/task_contracts.dart';
import 'package:warp_prism_observatory/data/models/changelog_contracts.dart';
import 'package:warp_prism_observatory/data/models/governance_diagnostics.dart';

/// Deterministic repository stub for provider transition tests.
class _FakeWorkspaceRepository implements WorkspaceRepository {
  _FakeWorkspaceRepository(this._state);

  final WorkspaceLoadState _state;

  @override
  String get rootPath => _state.rootPath;

  @override
  Future<WorkspaceLoadState> load() async => _state;
}

WorkspaceSnapshot _sampleSnapshot() {
  final clMeta = ChangelogMetadata(
    id: '2026-06-05-T012',
    date: DateTime(2026, 6, 5),
    project: 'warp-prism',
    task: 'T012',
    type: ChangelogType.feature,
    impact: const ['graph'],
    skills: const ['harness-architecture'],
  );
  final taskMeta = TaskMetadata(
    id: 'T012',
    title: 'Edge inference',
    created: DateTime(2026, 6, 1),
    updated: DateTime(2026, 6, 7),
    skills: const ['coding-execution-harness'],
    workflows: const ['gt-harness-architecture'],
  );

  return WorkspaceSnapshot(
    agents: const [
      WorkspaceAsset(
        id: 'agent:a',
        kind: AssetKind.agent,
        name: 'Agent A',
        path: '.agents/agents/a.md',
      ),
    ],
    skills: const [],
    workflows: const [],
    tasks: [
      WorkspaceAsset(
        id: 'task:T012',
        kind: AssetKind.task,
        name: 'Task T012',
        path: 'docs/tasks/02-doing/T012.md',
        frontmatter: {
          'id': 'T012',
          'skills': const ['coding-execution-harness'],
          'workflows': const ['gt-harness-architecture'],
          '_taskMetadata': taskMeta,
        },
      ),
    ],
    changelogEntries: [
      WorkspaceAsset(
        id: 'changelog:2026-06-05-T012',
        kind: AssetKind.changelog,
        name: '2026-06-05-T012',
        path: 'docs/changelog/2026-06-05-T012.md',
        frontmatter: {
          'id': '2026-06-05-T012',
          'date': '2026-06-05',
          'project': 'warp-prism',
          'task': 'T012',
          'type': 'feature',
          'impact': const ['graph'],
          'skills': const ['harness-architecture'],
          'workflows': const ['builder-orchestration'],
          '_changelogMetadata': clMeta,
        },
      ),
    ],
    edges: const [],
    metadata: WorkspaceScanMetadata(
      rootPath: 'fake-root',
      scannedAt: DateTime(2026, 7, 9),
      filesScanned: 3,
      parseErrors: 0,
    ),
  );
}

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
            category: DiagnosticCategory.highFanIn,
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

      const vm = MapViewModel(graph: graph);
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
      expect(root, isNotEmpty);
    });

    test('workspaceRepositoryProvider returns canonical mock repository', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final repo = container.read(workspaceRepositoryProvider);
      expect(repo, isA<WorkspaceRepository>());
      expect(repo.rootPath, isNotEmpty);
      // Wired to the repository-layer MockWorkspaceRepository, not a local
      // source-bridge duplicate.
      expect(repo.runtimeType.toString(), contains('MockWorkspaceRepository'));
    });

    test('snapshot provider emits success for populated corpus', () async {
      final container = ProviderContainer(
        overrides: [
          workspaceRepositoryProvider.overrideWithValue(
            _FakeWorkspaceRepository(
              WorkspaceLoadState.success(
                snapshot: _sampleSnapshot(),
                rootPath: 'fake-root',
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final state = await container.read(workspaceSnapshotAsyncProvider.future);
      expect(state.status, WorkspaceLoadStatus.success);
      expect(state.snapshot, isNotNull);
      expect(state.snapshot!.totalAssets, 3);

      final graph = await container.read(workspaceGraphAsyncProvider.future);
      expect(graph.isEmpty, isFalse);
      expect(graph.nodeCount, greaterThan(0));

      final metrics = await container.read(workspaceMetricsAsyncProvider.future);
      expect(metrics.totalAssets, greaterThan(0));

      final diagnostics =
          await container.read(workspaceDiagnosticsAsyncProvider.future);
      expect(diagnostics, isA<DiagnosticsReport>());

      final timeline =
          await container.read(historyTimelineAsyncProvider.future);
      expect(timeline.isNotEmpty, isTrue);
      expect(timeline.count, 1);
      expect(timeline.facets.projects, contains('warp-prism'));
      expect(
        timeline.impactEdges.any(
          (e) => e.kind == HistoryImpactHopKind.taskToSkill,
        ),
        isTrue,
      );
    });

    test('snapshot provider emits empty for empty corpus', () async {
      final container = ProviderContainer(
        overrides: [
          workspaceRepositoryProvider.overrideWithValue(
            _FakeWorkspaceRepository(
              const WorkspaceLoadState.empty(rootPath: 'empty-root'),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final state = await container.read(workspaceSnapshotAsyncProvider.future);
      expect(state.status, WorkspaceLoadStatus.empty);
      expect(state.snapshot, isNull);

      final graph = await container.read(workspaceGraphAsyncProvider.future);
      expect(graph.isEmpty, isTrue);

      final metrics = await container.read(workspaceMetricsAsyncProvider.future);
      expect(metrics.totalAssets, 0);

      final diagnostics =
          await container.read(workspaceDiagnosticsAsyncProvider.future);
      expect(diagnostics.diagnostics, isEmpty);
    });

    test('snapshot provider surfaces repository error state', () async {
      final container = ProviderContainer(
        overrides: [
          workspaceRepositoryProvider.overrideWithValue(
            _FakeWorkspaceRepository(
              const WorkspaceLoadState.error(
                message: 'directory missing',
                rootPath: 'missing-root',
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final state = await container.read(workspaceSnapshotAsyncProvider.future);
      expect(state.status, WorkspaceLoadStatus.error);
      expect(state.errorMessage, 'directory missing');

      // Graph derivation fails closed on repository error so UI can show
      // AsyncValue.error rather than a silent empty graph.
      await expectLater(
        container.read(workspaceGraphAsyncProvider.future),
        throwsA(isA<StateError>()),
      );

      await expectLater(
        container.read(historyTimelineAsyncProvider.future),
        throwsA(isA<StateError>()),
      );
    });

    test('historyRepositoryProvider exposes HistoryRepository', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final repo = container.read(historyRepositoryProvider);
      expect(repo, isA<HistoryRepository>());
    });

    test('history timeline provider returns empty for empty corpus', () async {
      final container = ProviderContainer(
        overrides: [
          workspaceRepositoryProvider.overrideWithValue(
            _FakeWorkspaceRepository(
              const WorkspaceLoadState.empty(rootPath: 'empty-root'),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final timeline =
          await container.read(historyTimelineAsyncProvider.future);
      expect(timeline.isEmpty, isTrue);
      expect(timeline.impactEdges, isEmpty);
    });

    test('shell VM providers compose metrics and diagnostics', () async {
      final container = ProviderContainer(
        overrides: [
          workspaceRepositoryProvider.overrideWithValue(
            _FakeWorkspaceRepository(
              WorkspaceLoadState.success(
                snapshot: _sampleSnapshot(),
                rootPath: 'fake-root',
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final overview = await container.read(overviewViewModelProvider.future);
      expect(overview.totalAssets, greaterThan(0));

      final mapVm = await container.read(mapViewModelProvider.future);
      expect(mapVm.isEmpty, isFalse);

      final operate = await container.read(operateViewModelProvider.future);
      expect(operate.totalTaskCount, greaterThanOrEqualTo(0));

      final history = await container.read(historyViewModelProvider.future);
      expect(history.totalChangelog, greaterThanOrEqualTo(0));

      final governance =
          await container.read(governanceViewModelProvider.future);
      expect(governance, isA<GovernanceViewModel>());
    });

    test('snapshot provider surfaces AsyncLoading during reload', () async {
      final repo = _DelayedWorkspaceRepository(
        WorkspaceLoadState.success(
          snapshot: _sampleSnapshot(),
          rootPath: 'delayed-root',
        ),
        delay: const Duration(milliseconds: 40),
      );
      final container = ProviderContainer(
        overrides: [
          workspaceRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      // First build settles to data.
      final first = await container.read(workspaceSnapshotAsyncProvider.future);
      expect(first.status, WorkspaceLoadStatus.success);

      // Reload sets AsyncLoading before the delayed future resolves.
      final reloadFuture = container
          .read(workspaceSnapshotAsyncProvider.notifier)
          .reload();
      expect(
        container.read(workspaceSnapshotAsyncProvider).isLoading,
        isTrue,
      );
      await reloadFuture;
      expect(
        container.read(workspaceSnapshotAsyncProvider).hasValue,
        isTrue,
      );
    });
  });
}

/// Repository that delays [load] so AsyncLoading transitions are observable.
class _DelayedWorkspaceRepository implements WorkspaceRepository {
  _DelayedWorkspaceRepository(this._state, {required this.delay});

  final WorkspaceLoadState _state;
  final Duration delay;

  @override
  String get rootPath => _state.rootPath;

  @override
  Future<WorkspaceLoadState> load() async {
    await Future<void>.delayed(delay);
    return _state;
  }
}
