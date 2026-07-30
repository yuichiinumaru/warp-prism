/// Tests for the Operate board surface and filters.
///
/// Covers:
/// - Five canonical lanes render when mock corpus is available
/// - Filters by owner, skill, workflow, and proof state
/// - Lane counts are coherent with filtered subset
/// - Combinable filters do not mutate the base dataset
/// - Empty/loading/error states
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_observatory/app/pages/operate_page.dart';
import 'package:warp_prism_observatory/data/models/task_contracts.dart';
import 'package:warp_prism_observatory/data/models/workspace_graph.dart';
import 'package:warp_prism_observatory/features/operate/operate_filters.dart';
import 'package:warp_prism_observatory/features/operate/operate_projection_builder.dart';
import 'package:warp_prism_observatory/features/operate/operate_workspace_view.dart';
import 'package:warp_prism_observatory/features/operate/operate_workspace_view_model.dart';
import 'package:warp_prism_observatory/features/operate/task_projection.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// Test task projections spanning all five lanes.
final _testTasks = [
  TaskProjection(
    id: 'T001',
    title: 'Plan Architecture',
    lane: TaskLane.planning,
    priority: 'P0',
    owner: 'architect',
    proofState: ProofState.complete,
    linkedSkills: ['design'],
    linkedWorkflows: ['planning-wf'],
    created: DateTime(2026, 6, 1),
    updated: DateTime(2026, 6, 5),
  ),
  TaskProjection(
    id: 'T002',
    title: 'Implement Auth',
    lane: TaskLane.open,
    priority: 'P1',
    owner: 'builder',
    proofState: ProofState.none,
    linkedSkills: ['auth', 'security'],
    linkedWorkflows: ['dev-wf'],
    dependsOn: ['T001'],
    created: DateTime(2026, 6, 2),
    updated: DateTime(2026, 6, 6),
  ),
  TaskProjection(
    id: 'T003',
    title: 'Build Dashboard',
    lane: TaskLane.doing,
    priority: 'P1',
    owner: 'builder',
    proofState: ProofState.partial,
    linkedSkills: ['ui'],
    linkedWorkflows: ['dev-wf'],
    created: DateTime(2026, 6, 3),
    updated: DateTime(2026, 6, 7),
  ),
  TaskProjection(
    id: 'T004',
    title: 'Review Security',
    lane: TaskLane.review,
    priority: 'P0',
    owner: 'reviewer',
    proofState: ProofState.verified,
    linkedSkills: ['security'],
    linkedWorkflows: ['review-wf'],
    created: DateTime(2026, 6, 4),
    updated: DateTime(2026, 6, 7),
  ),
  TaskProjection(
    id: 'T005',
    title: 'Deploy to Prod',
    lane: TaskLane.completed,
    priority: 'P2',
    owner: 'ops',
    proofState: ProofState.verified,
    linkedSkills: ['deploy'],
    linkedWorkflows: ['deploy-wf'],
    created: DateTime(2026, 6, 1),
    updated: DateTime(2026, 6, 6),
  ),
];

/// Build a test projection from the task list.
OperateProjection _buildTestProjection() {
  final lanes = TaskLane.values.map((lane) {
    final tasks = _testTasks.where((t) => t.lane == lane).toList();
    return TaskLaneProjection(lane: lane, tasks: tasks);
  }).toList();
  return OperateProjection(lanes: lanes, totalTasks: _testTasks.length);
}

void main() {
  Widget wrapInApp(Widget child) {
    return MaterialApp(
      home: Scaffold(body: SizedBox(width: 1920, height: 1200, child: child)),
    );
  }

  Future<void> setDesktopSurface(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1920, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  /// Empty-lane compact layout can overflow PrismStateSurface in narrow
  /// lane columns; ignore that known DS empty-state overflow in filter tests.
  void ignoreLaneEmptyOverflows() {
    final previous = FlutterError.onError;
    FlutterError.onError = (details) {
      final text = details.toString();
      if (text.contains('A RenderFlex overflowed') &&
          text.contains('DSStateSurface')) {
        return;
      }
      previous?.call(details);
    };
    addTearDown(() => FlutterError.onError = previous);
  }

  // ===========================================================================
  // OperateFilters contract
  // ===========================================================================
  group('OperateFilters', () {
    test('none has no active filters', () {
      const filters = OperateFilters();
      expect(filters.isActive, isFalse);
      expect(filters.activeCount, 0);
    });

    test('lane filter activates', () {
      const filters = OperateFilters(lane: TaskLane.doing);
      expect(filters.isActive, isTrue);
      expect(filters.activeCount, 1);
    });

    test('owner filter activates', () {
      const filters = OperateFilters(owner: 'builder');
      expect(filters.isActive, isTrue);
      expect(filters.activeCount, 1);
    });

    test('multiple filters combine', () {
      const filters = OperateFilters(
        owner: 'builder',
        proofState: ProofState.partial,
        query: 'dashboard',
      );
      expect(filters.isActive, isTrue);
      expect(filters.activeCount, 3);
    });

    test('copyWith clears individual filters', () {
      const original = OperateFilters(lane: TaskLane.doing, owner: 'builder');
      final cleared = original.copyWith(clearOwner: true);
      expect(cleared.lane, TaskLane.doing);
      expect(cleared.owner, isNull);
      expect(cleared.activeCount, 1);
    });

    test('equality', () {
      const a = OperateFilters(owner: 'builder', lane: TaskLane.open);
      const b = OperateFilters(owner: 'builder', lane: TaskLane.open);
      const c = OperateFilters(owner: 'reviewer');
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });

  // ===========================================================================
  // OperateWorkspaceViewModel - lane grouping
  // ===========================================================================
  group('OperateWorkspaceViewModel - lanes', () {
    late OperateWorkspaceViewModel viewModel;

    setUp(() {
      viewModel = OperateWorkspaceViewModel();
      viewModel.loadProjection(_buildTestProjection());
    });

    tearDown(() {
      viewModel.dispose();
    });

    test('loads all tasks from projection', () {
      expect(viewModel.state.allTasks.length, 5);
    });

    test('creates five lanes in canonical order', () {
      expect(viewModel.state.lanes.length, 5);
      expect(viewModel.state.lanes[0].lane, TaskLane.planning);
      expect(viewModel.state.lanes[1].lane, TaskLane.open);
      expect(viewModel.state.lanes[2].lane, TaskLane.doing);
      expect(viewModel.state.lanes[3].lane, TaskLane.review);
      expect(viewModel.state.lanes[4].lane, TaskLane.completed);
    });

    test('each lane has correct task count', () {
      expect(viewModel.state.lanes[0].tasks.length, 1); // planning: T001
      expect(viewModel.state.lanes[1].tasks.length, 1); // open: T002
      expect(viewModel.state.lanes[2].tasks.length, 1); // doing: T003
      expect(viewModel.state.lanes[3].tasks.length, 1); // review: T004
      expect(viewModel.state.lanes[4].tasks.length, 1); // completed: T005
    });

    test('lane totalCount reflects unfiltered count', () {
      expect(viewModel.state.lanes[0].totalCount, 1);
      expect(viewModel.state.lanes[1].totalCount, 1);
    });

    test('totalTaskCount equals all tasks', () {
      expect(viewModel.state.totalTaskCount, 5);
    });
  });

  // ===========================================================================
  // OperateWorkspaceViewModel - filters
  // ===========================================================================
  group('OperateWorkspaceViewModel - filters', () {
    late OperateWorkspaceViewModel viewModel;

    setUp(() {
      viewModel = OperateWorkspaceViewModel();
      viewModel.loadProjection(_buildTestProjection());
    });

    tearDown(() {
      viewModel.dispose();
    });

    test('filterByLane shows only tasks in that lane', () {
      viewModel.filterByLane(TaskLane.doing);
      expect(viewModel.state.filters.lane, TaskLane.doing);
      expect(viewModel.state.filteredTaskCount, 1);
      // Doing lane has 1 task
      final doingLane = viewModel.state.lanes.firstWhere(
        (l) => l.lane == TaskLane.doing,
      );
      expect(doingLane.tasks.length, 1);
      // Other lanes should have 0 filtered tasks
      final openLane = viewModel.state.lanes.firstWhere(
        (l) => l.lane == TaskLane.open,
      );
      expect(openLane.tasks.length, 0);
    });

    test('filterByOwner shows only tasks owned by that owner', () {
      viewModel.filterByOwner('builder');
      expect(viewModel.state.filteredTaskCount, 2); // T002, T003
    });

    test('filterBySkill shows only tasks with that skill', () {
      viewModel.filterBySkill('security');
      expect(viewModel.state.filteredTaskCount, 2); // T002, T004
    });

    test('filterByWorkflow shows only tasks with that workflow', () {
      viewModel.filterByWorkflow('dev-wf');
      expect(viewModel.state.filteredTaskCount, 2); // T002, T003
    });

    test('filterByProofState shows only tasks with that proof state', () {
      viewModel.filterByProofState(ProofState.verified);
      expect(viewModel.state.filteredTaskCount, 2); // T004, T005
    });

    test('updateQuery matches title, id, and owner', () {
      viewModel.updateQuery('dashboard');
      expect(viewModel.state.filteredTaskCount, 1); // T003

      viewModel.updateQuery('T004');
      expect(viewModel.state.filteredTaskCount, 1); // T004

      viewModel.updateQuery('reviewer');
      expect(viewModel.state.filteredTaskCount, 1); // T004
    });

    test('filters combine (AND semantics)', () {
      viewModel.filterByOwner('builder');
      viewModel.filterBySkill('security');
      // T002 has owner=builder AND skill=security
      // T003 has owner=builder but NOT security
      expect(viewModel.state.filteredTaskCount, 1);
    });

    test('clearFilters resets all filters', () {
      viewModel.filterByOwner('builder');
      viewModel.filterBySkill('security');
      viewModel.updateQuery('test');
      viewModel.clearFilters();

      expect(viewModel.state.filters, OperateFilters.none);
      expect(viewModel.state.filteredTaskCount, 5);
    });

    test('lane filter preserves totalCount per lane', () {
      viewModel.filterByOwner('builder');
      // Total count per lane is still the unfiltered count
      final planningLane = viewModel.state.lanes.firstWhere(
        (l) => l.lane == TaskLane.planning,
      );
      expect(planningLane.totalCount, 1); // unfiltered
      expect(
        planningLane.tasks.length,
        0,
      ); // filtered: builder has no planning tasks
    });
  });

  // ===========================================================================
  // OperateWorkspaceViewModel - filter options
  // ===========================================================================
  group('OperateWorkspaceViewModel - filter options', () {
    late OperateWorkspaceViewModel viewModel;

    setUp(() {
      viewModel = OperateWorkspaceViewModel();
      viewModel.loadProjection(_buildTestProjection());
    });

    tearDown(() {
      viewModel.dispose();
    });

    test('filterOptions contains unique owners', () {
      final options = viewModel.state.filterOptions;
      expect(
        options.owners,
        containsAll(['architect', 'builder', 'reviewer', 'ops']),
      );
    });

    test('filterOptions contains unique skills', () {
      final options = viewModel.state.filterOptions;
      expect(
        options.skills,
        containsAll(['design', 'auth', 'security', 'ui', 'deploy']),
      );
    });

    test('filterOptions contains unique workflows', () {
      final options = viewModel.state.filterOptions;
      expect(
        options.workflows,
        containsAll(['planning-wf', 'dev-wf', 'review-wf', 'deploy-wf']),
      );
    });

    test('filterOptions contains unique proof states', () {
      final options = viewModel.state.filterOptions;
      expect(
        options.proofStates,
        containsAll([
          ProofState.complete,
          ProofState.none,
          ProofState.partial,
          ProofState.verified,
        ]),
      );
    });
  });

  // ===========================================================================
  // OperateWorkspaceViewModel - selection
  // ===========================================================================
  group('OperateWorkspaceViewModel - selection', () {
    late OperateWorkspaceViewModel viewModel;

    setUp(() {
      viewModel = OperateWorkspaceViewModel();
      viewModel.loadProjection(_buildTestProjection());
    });

    tearDown(() {
      viewModel.dispose();
    });

    test('selectTask sets selectedTaskId', () {
      viewModel.selectTask('T002');
      expect(viewModel.selectedTaskId, 'T002');
      expect(viewModel.state.selectedTaskId, 'T002');
    });

    test('deselectTask clears selection', () {
      viewModel.selectTask('T002');
      viewModel.deselectTask();
      expect(viewModel.selectedTaskId, isNull);
    });
  });

  // ===========================================================================
  // OperateWorkspaceViewModel - loading/error
  // ===========================================================================
  group('OperateWorkspaceViewModel - loading/error', () {
    late OperateWorkspaceViewModel viewModel;

    setUp(() {
      viewModel = OperateWorkspaceViewModel();
    });

    tearDown(() {
      viewModel.dispose();
    });

    test('setLoading updates loading state', () {
      viewModel.setLoading(true);
      expect(viewModel.state.isLoading, isTrue);
    });

    test('setError sets error and clears loading', () {
      viewModel.setLoading(true);
      viewModel.setError('parse failed');
      expect(viewModel.state.error, 'parse failed');
      expect(viewModel.state.isLoading, isFalse);
    });

    test('clearError removes error', () {
      viewModel.setError('oops');
      viewModel.clearError();
      expect(viewModel.state.error, isNull);
    });
  });

  // ===========================================================================
  // OperateWorkspaceViewModel - empty dataset
  // ===========================================================================
  group('OperateWorkspaceViewModel - empty dataset', () {
    test('five lanes render even when all are empty', () {
      final viewModel = OperateWorkspaceViewModel();
      viewModel.loadProjection(
        const OperateProjection(lanes: [], totalTasks: 0),
      );

      // Should still create 5 lane states (one per TaskLane value)
      expect(viewModel.state.lanes.length, 5);
      expect(viewModel.state.lanes.every((l) => l.isEmpty), isTrue);
      expect(viewModel.state.totalTaskCount, 0);

      viewModel.dispose();
    });
  });

  // ===========================================================================
  // PrismLaneBoard integration
  // ===========================================================================
  group('PrismLaneBoard integration', () {
    testWidgets('renders five lanes from PrismLane objects', (tester) async {
      final lanes = TaskLane.values.map((lane) {
        return PrismLane(
          id: lane.directoryPrefix,
          label: lane.name,
          tasks: lane == TaskLane.doing
              ? [
                  const PrismLaneTask(
                    id: 3,
                    title: 'Build Dashboard',
                    priority: 'P1',
                    owner: 'builder',
                    proofState: 'partial',
                  ),
                ]
              : const [],
        );
      }).toList();

      await tester.pumpWidget(wrapInApp(PrismLaneBoard(lanes: lanes)));

      // Should render 5 lane headers
      expect(find.text('planning'), findsOneWidget);
      expect(find.text('open'), findsOneWidget);
      expect(find.text('doing'), findsOneWidget);
      expect(find.text('review'), findsOneWidget);
      expect(find.text('completed'), findsOneWidget);
    });

    testWidgets('renders task cards in populated lanes', (tester) async {
      final lanes = [
        PrismLane(
          id: '02-doing',
          label: 'Doing',
          tasks: [
            const PrismLaneTask(
              id: 3,
              title: 'Build Dashboard',
              priority: 'P1',
              owner: 'builder',
              proofState: 'partial',
            ),
          ],
        ),
        PrismLane(id: '01-open', label: 'Open', tasks: const []),
      ];

      await tester.pumpWidget(wrapInApp(PrismLaneBoard(lanes: lanes)));

      expect(find.text('Build Dashboard'), findsOneWidget);
    });

    testWidgets('empty lanes show no-tasks state', (tester) async {
      final lanes = [const PrismLane(id: '01-open', label: 'Open', tasks: [])];

      await tester.pumpWidget(wrapInApp(PrismLaneBoard(lanes: lanes)));

      expect(find.text('No tasks'), findsOneWidget);
    });
  });

  // ===========================================================================
  // OperateWorkspaceView integration
  // ===========================================================================
  group('OperateWorkspaceView integration', () {
    testWidgets('renders five lane labels from projection', (tester) async {
      await setDesktopSurface(tester);
      await tester.pumpWidget(
        wrapInApp(
          OperateWorkspaceView(initialProjection: _buildTestProjection()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Planning'), findsOneWidget);
      expect(find.text('Open'), findsOneWidget);
      expect(find.text('Doing'), findsOneWidget);
      expect(find.text('Review'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
      expect(find.text('Plan Architecture'), findsOneWidget);
      expect(find.text('5 tasks'), findsOneWidget);
    });

    testWidgets('owner filter updates visible board subset', (tester) async {
      await setDesktopSurface(tester);
      ignoreLaneEmptyOverflows();
      await tester.pumpWidget(
        wrapInApp(
          OperateWorkspaceView(initialProjection: _buildTestProjection()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Open Owner filter and pick builder (2 tasks).
      await tester.tap(find.byTooltip('Owner filter'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text('builder').last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('2 of 5 tasks'), findsOneWidget);
      expect(find.text('Implement Auth'), findsOneWidget);
      expect(find.text('Build Dashboard'), findsOneWidget);
      expect(find.text('Plan Architecture'), findsNothing);
      expect(find.text('Clear filters'), findsOneWidget);
    });

    testWidgets('search and clear filters restore full board', (tester) async {
      await setDesktopSurface(tester);
      ignoreLaneEmptyOverflows();
      await tester.pumpWidget(
        wrapInApp(
          OperateWorkspaceView(initialProjection: _buildTestProjection()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.enterText(find.byType(TextField), 'dashboard');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('1 of 5 tasks'), findsOneWidget);
      expect(find.text('Build Dashboard'), findsOneWidget);

      await tester.tap(find.text('Clear filters'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('5 tasks'), findsOneWidget);
      expect(find.text('Plan Architecture'), findsOneWidget);
    });

    testWidgets('exposes semantic labels for search and filters', (
      tester,
    ) async {
      await setDesktopSurface(tester);
      ignoreLaneEmptyOverflows();
      await tester.pumpWidget(
        wrapInApp(
          OperateWorkspaceView(initialProjection: _buildTestProjection()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.bySemanticsLabel('Search tasks'), findsOneWidget);
      expect(find.byTooltip('Lane filter'), findsOneWidget);
      expect(find.byTooltip('Owner filter'), findsOneWidget);
      expect(find.byTooltip('Skill filter'), findsOneWidget);
      expect(find.byTooltip('Workflow filter'), findsOneWidget);
      expect(find.byTooltip('Proof filter'), findsOneWidget);
      expect(find.bySemanticsLabel('Clear filters'), findsNothing);

      // Activate a filter so clear action is present with semantics.
      await tester.enterText(find.byType(TextField), 'dashboard');
      await tester.pump();
      expect(find.bySemanticsLabel('Clear filters'), findsOneWidget);
      expect(find.text('Clear filters'), findsOneWidget);
    });
  });

  // ===========================================================================
  // OperatePage route shell wiring
  // ===========================================================================
  group('OperatePage shell wiring', () {
    Widget wrapPage(Widget child) {
      return ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox(width: 1920, height: 1200, child: child),
          ),
        ),
      );
    }

    testWidgets('forced projection populates lanes without initialProjection', (
      tester,
    ) async {
      await setDesktopSurface(tester);
      await tester.pumpWidget(
        wrapPage(OperatePage(forcedProjection: _buildTestProjection())),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(OperateWorkspaceView), findsOneWidget);
      expect(find.text('Planning'), findsOneWidget);
      expect(find.text('Plan Architecture'), findsOneWidget);
      expect(find.text('5 tasks'), findsOneWidget);
    });

    testWidgets('forced loading state is distinct from empty board', (
      tester,
    ) async {
      await setDesktopSurface(tester);
      await tester.pumpWidget(wrapPage(const OperatePage(forceLoading: true)));
      await tester.pump();

      expect(find.text('Loading tasks...'), findsOneWidget);
      expect(find.byType(OperateWorkspaceView), findsNothing);
    });

    testWidgets('forced error state surfaces message', (tester) async {
      await setDesktopSurface(tester);
      await tester.pumpWidget(
        wrapPage(const OperatePage(forcedError: 'mock operate load failure')),
      );
      await tester.pump();

      expect(find.text('Failed to load tasks'), findsOneWidget);
      expect(find.textContaining('mock operate load failure'), findsOneWidget);
    });
  });

  // ===========================================================================
  // Projection builder from WorkspaceAsset
  // ===========================================================================
  group('buildOperateProjection', () {
    test('maps TaskMetadata assets into five canonical lanes', () {
      final assets = [
        WorkspaceAsset(
          id: 'task:T001',
          kind: AssetKind.task,
          name: 'Plan Architecture',
          path: 'docs/tasks/00-planning/T001-plan.md',
          frontmatter: {
            '_taskMetadata': TaskMetadata(
              id: 'T001',
              title: 'Plan Architecture',
              lane: TaskLane.planning,
              owner: 'architect',
              proofState: ProofState.complete,
              skills: const ['design'],
              workflows: const ['planning-wf'],
              created: DateTime(2026, 6, 1),
              updated: DateTime(2026, 6, 5),
            ),
          },
        ),
        WorkspaceAsset(
          id: 'task:T003',
          kind: AssetKind.task,
          name: 'Build Dashboard',
          path: 'docs/tasks/02-doing/T003-build.md',
          frontmatter: {
            '_taskMetadata': TaskMetadata(
              id: 'T003',
              title: 'Build Dashboard',
              lane: TaskLane.doing,
              owner: 'builder',
              proofState: ProofState.partial,
              skills: const ['ui'],
              workflows: const ['dev-wf'],
              created: DateTime(2026, 6, 3),
              updated: DateTime(2026, 6, 7),
            ),
          },
        ),
      ];

      final projection = buildOperateProjection(assets);
      expect(projection.lanes.length, 5);
      expect(projection.totalTasks, 2);
      expect(projection.laneFor(TaskLane.planning).tasks.single.id, 'T001');
      expect(projection.laneFor(TaskLane.doing).tasks.single.owner, 'builder');
      expect(projection.laneFor(TaskLane.open).isEmpty, isTrue);
      expect(projection.laneFor(TaskLane.review).isEmpty, isTrue);
      expect(projection.laneFor(TaskLane.completed).isEmpty, isTrue);
    });
  });
}
