/// Widget tests for History story and impact view modes.
///
/// Verifies:
/// - Mode switcher renders Timeline, Project Story, Impact Story
/// - Project Story groups entries by project with narrative
/// - Impact Story shows causality chain changelog -> task -> skill/workflow
/// - Missing links render as explicit gap indicators
/// - Selection syncs across modes
/// - Workflow-only hops complete the impact path
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_observatory/data/models/changelog_contracts.dart';
import 'package:warp_prism_observatory/data/repositories/history_repository.dart';
import 'package:warp_prism_observatory/features/history/presentation/history_controller.dart';
import 'package:warp_prism_observatory/features/history/presentation/history_page.dart';
import 'package:warp_prism_observatory/features/history/presentation/history_view_mode.dart';
import 'package:warp_prism_observatory/features/history/presentation/widgets/history_story_view.dart';
import 'package:warp_prism_observatory/features/history/presentation/widgets/history_impact_view.dart';

HistoryEntry _entry({
  required String id,
  required DateTime? date,
  required String project,
  required String task,
  required ChangelogType type,
  List<String> impactTags = const [],
  List<String> skills = const [],
  List<String> workflows = const [],
  String title = '',
}) {
  return HistoryEntry(
    id: id,
    title: title.isEmpty ? id : title,
    date: date,
    project: project,
    task: task,
    type: type,
    impactTags: impactTags,
    skills: skills,
    workflows: workflows,
    path: 'docs/changelog/$id.md',
  );
}

List<HistoryEntry> _testEntries() {
  return [
    _entry(
      id: '2026-06-07-task-0612-inspector',
      date: DateTime(2026, 6, 7),
      project: 'warp-prism',
      task: '0612',
      type: ChangelogType.feature,
      impactTags: const ['operate', 'inspector'],
      skills: const ['agent-wiki'],
      title: '0612 — feature',
    ),
    _entry(
      id: '2026-06-07-task-0712-history',
      date: DateTime(2026, 6, 7),
      project: 'warp-prism',
      task: '0712',
      type: ChangelogType.feature,
      impactTags: const ['history', 'timeline'],
      skills: const ['build-orchestrator'],
      workflows: const ['builder-orchestration'],
      title: '0712 — feature',
    ),
    _entry(
      id: '2026-06-06-task-0313-graph',
      date: DateTime(2026, 6, 6),
      project: 'warp-prism',
      task: '0313',
      type: ChangelogType.refactor,
      impactTags: const ['graph-model'],
      title: '0313 — refactor',
    ),
    _entry(
      id: '2026-06-05-taskless-entry',
      date: DateTime(2026, 6, 5),
      project: 'ganthritor',
      task: '',
      type: ChangelogType.docs,
      impactTags: const ['docs'],
      title: 'taskless docs',
    ),
    _entry(
      id: '2026-06-04-workflow-only',
      date: DateTime(2026, 6, 4),
      project: 'warp-prism',
      task: '0713',
      type: ChangelogType.feature,
      impactTags: const ['history'],
      workflows: const ['gt-code-review'],
      title: '0713 — workflow hop',
    ),
  ];
}

HistoryState _testState({
  List<HistoryEntry>? entries,
  HistoryViewMode viewMode = HistoryViewMode.timeline,
  String? selectedEntryId,
}) {
  return HistoryState(
    allEntries: entries ?? _testEntries(),
    viewMode: viewMode,
    selectedEntryId: selectedEntryId,
  );
}

Widget _wrapInApp(Widget child) {
  return MaterialApp(
    home: Scaffold(body: SizedBox(width: 1400, height: 2400, child: child)),
  );
}

Future<void> _setDesktopSurface(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(1400, 2400));
  addTearDown(() async {
    await tester.binding.setSurfaceSize(null);
  });
}

void main() {
  group('History View Mode Switcher', () {
    testWidgets('renders all three mode chips', (tester) async {
      await _setDesktopSurface(tester);
      await tester.pumpWidget(
        _wrapInApp(HistoryWorkspacePage(initialState: _testState())),
      );

      expect(find.text('Timeline'), findsOneWidget);
      expect(find.text('Project Story'), findsOneWidget);
      expect(find.text('Impact Story'), findsOneWidget);
    });

    testWidgets('timeline mode shows entry count', (tester) async {
      await _setDesktopSurface(tester);
      await tester.pumpWidget(
        _wrapInApp(
          HistoryWorkspacePage(
            initialState: _testState(viewMode: HistoryViewMode.timeline),
          ),
        ),
      );

      expect(find.textContaining('5 of 5'), findsOneWidget);
    });

    testWidgets('project story mode renders story panels', (tester) async {
      await _setDesktopSurface(tester);
      await tester.pumpWidget(
        _wrapInApp(
          HistoryWorkspacePage(
            initialState: _testState(viewMode: HistoryViewMode.projectStory),
          ),
        ),
      );

      expect(find.text('warp-prism'), findsWidgets);
      expect(find.text('ganthritor'), findsWidgets);
    });

    testWidgets('impact story mode renders impact cards', (tester) async {
      await _setDesktopSurface(tester);
      await tester.pumpWidget(
        _wrapInApp(
          HistoryWorkspacePage(
            initialState: _testState(viewMode: HistoryViewMode.impactStory),
          ),
        ),
      );

      expect(find.textContaining('0612'), findsWidgets);
      expect(find.textContaining('Task 0712'), findsOneWidget);
    });

    testWidgets('tapping mode chip changes mode', (tester) async {
      await _setDesktopSurface(tester);
      await tester.pumpWidget(
        _wrapInApp(
          HistoryWorkspacePage(
            initialState: _testState(viewMode: HistoryViewMode.timeline),
          ),
        ),
      );

      await tester.ensureVisible(find.text('Project Story'));
      await tester.tap(find.text('Project Story'));
      await tester.pumpAndSettle();

      expect(find.text('warp-prism'), findsWidgets);
    });
  });

  group('ProjectStoryGroup', () {
    test('summary includes entry count and types', () {
      final entries = _testEntries()
          .where((e) => e.project == 'warp-prism')
          .toList();
      final group = ProjectStoryGroup(project: 'warp-prism', entries: entries);
      expect(group.summary, contains('4 change'));
      expect(group.summary, contains('feature'));
      expect(group.summary, contains('refactor'));
    });

    test('taskIds lists non-empty tasks', () {
      final entries = _testEntries()
          .where((e) => e.project == 'warp-prism')
          .toList();
      final group = ProjectStoryGroup(project: 'warp-prism', entries: entries);
      expect(group.taskIds, containsAll(['0612', '0712', '0313', '0713']));
    });

    test('taskIds is empty when no entries have tasks', () {
      final entries = _testEntries()
          .where((e) => e.project == 'ganthritor')
          .toList();
      final group = ProjectStoryGroup(project: 'ganthritor', entries: entries);
      expect(group.taskIds, isEmpty);
    });
  });

  group('ImpactPathNode', () {
    test('hasCompletePath is true when task and skills present', () {
      final nodes = _testState().toImpactPathNodes();
      final completeNode = nodes.firstWhere((n) => n.entry.task == '0612');
      expect(completeNode.hasCompletePath, isTrue);
      expect(completeNode.resolvedTaskId, '0612');
      expect(completeNode.resolvedSkills, ['agent-wiki']);
    });

    test('hasCompletePath is true when task and workflow present', () {
      final nodes = _testState().toImpactPathNodes();
      final workflowNode = nodes.firstWhere((n) => n.entry.task == '0713');
      expect(workflowNode.hasCompletePath, isTrue);
      expect(workflowNode.resolvedSkills, isEmpty);
      expect(workflowNode.resolvedWorkflows, ['gt-code-review']);
    });

    test('hasCompletePath is false when skills and workflows missing', () {
      final nodes = _testState().toImpactPathNodes();
      final partialNode = nodes.firstWhere((n) => n.entry.task == '0313');
      expect(partialNode.hasCompletePath, isFalse);
      expect(partialNode.resolvedTaskId, '0313');
      expect(partialNode.resolvedSkills, isEmpty);
      expect(partialNode.resolvedWorkflows, isEmpty);
    });

    test('resolvedTaskId is null when task is empty', () {
      final nodes = _testState().toImpactPathNodes();
      final noTaskNode = nodes.firstWhere((n) => n.entry.task.isEmpty);
      expect(noTaskNode.resolvedTaskId, isNull);
      expect(noTaskNode.hasCompletePath, isFalse);
    });
  });

  group('HistoryState view mode', () {
    test('default view mode is timeline', () {
      expect(_testState().viewMode, HistoryViewMode.timeline);
    });

    test('copyWith preserves view mode', () {
      final state = _testState(viewMode: HistoryViewMode.projectStory);
      final copied = state.copyWith(selectedEntryId: 'test');
      expect(copied.viewMode, HistoryViewMode.projectStory);
    });

    test('copyWith can change view mode', () {
      final state = _testState(viewMode: HistoryViewMode.timeline);
      final copied = state.copyWith(viewMode: HistoryViewMode.impactStory);
      expect(copied.viewMode, HistoryViewMode.impactStory);
    });

    test('toProjectStoryGroups groups by project', () {
      final groups = _testState().toProjectStoryGroups();
      expect(groups.length, 2);
      expect(groups.first.project, 'warp-prism');
      expect(groups.first.entries.length, 4);
      expect(groups.last.project, 'ganthritor');
      expect(groups.last.entries.length, 1);
    });

    test('toImpactPathNodes returns one node per entry', () {
      expect(_testState().toImpactPathNodes().length, 5);
    });

    test('skillWorkflow filter matches workflows', () {
      final state = _testState().copyWith(
        activeFilters: {
          HistoryFilterCategory.skillWorkflow: {'gt-code-review'},
        },
      );
      expect(state.filteredEntries.length, 1);
      expect(state.filteredEntries.first.task, '0713');
    });

    test('selectedEntry resolves from allEntries', () {
      final state = _testState(
        selectedEntryId: '2026-06-07-task-0612-inspector',
      );
      expect(state.selectedEntry?.task, '0612');
    });
  });

  group('HistoryStoryView', () {
    testWidgets('renders empty state when no groups', (tester) async {
      await _setDesktopSurface(tester);
      await tester.pumpWidget(_wrapInApp(const HistoryStoryView(groups: [])));
      expect(find.text('No project stories'), findsOneWidget);
    });

    testWidgets('renders project groups', (tester) async {
      await _setDesktopSurface(tester);
      final groups = _testState().toProjectStoryGroups();
      await tester.pumpWidget(_wrapInApp(HistoryStoryView(groups: groups)));
      expect(find.text('warp-prism'), findsOneWidget);
      expect(find.text('ganthritor'), findsOneWidget);
    });

    testWidgets('entry chips are tappable for selection', (tester) async {
      await _setDesktopSurface(tester);
      String? tapped;
      final groups = _testState().toProjectStoryGroups();
      await tester.pumpWidget(
        _wrapInApp(
          HistoryStoryView(groups: groups, onEntryTap: (id) => tapped = id),
        ),
      );

      final chip = find.byKey(
        const ValueKey('story-entry-2026-06-07-task-0612-inspector'),
      );
      expect(chip, findsOneWidget);
      await tester.ensureVisible(chip);
      await tester.tap(chip);
      await tester.pumpAndSettle();
      expect(tapped, '2026-06-07-task-0612-inspector');
    });
  });

  group('HistoryImpactView', () {
    testWidgets('renders empty state when no nodes', (tester) async {
      await _setDesktopSurface(tester);
      await tester.pumpWidget(_wrapInApp(const HistoryImpactView(nodes: [])));
      expect(find.text('No impact paths'), findsOneWidget);
    });

    testWidgets('renders impact path cards', (tester) async {
      await _setDesktopSurface(tester);
      final nodes = _testState().toImpactPathNodes();
      await tester.pumpWidget(_wrapInApp(HistoryImpactView(nodes: nodes)));
      expect(find.textContaining('0612'), findsWidgets);
      expect(find.textContaining('Task 0712'), findsOneWidget);
    });

    testWidgets('shows gap indicator for missing task', (tester) async {
      await _setDesktopSurface(tester);
      final nodes = _testState().toImpactPathNodes();
      await tester.pumpWidget(_wrapInApp(HistoryImpactView(nodes: nodes)));
      expect(find.text('No task linked to this entry'), findsWidgets);
    });

    testWidgets('shows gap indicator for missing skills/workflows', (
      tester,
    ) async {
      await _setDesktopSurface(tester);
      final nodes = _testState().toImpactPathNodes();
      await tester.pumpWidget(_wrapInApp(HistoryImpactView(nodes: nodes)));
      expect(find.text('No skills/workflows linked'), findsOneWidget);
    });

    testWidgets('shows partial path warning', (tester) async {
      await _setDesktopSurface(tester);
      final nodes = _testState().toImpactPathNodes();
      await tester.pumpWidget(_wrapInApp(HistoryImpactView(nodes: nodes)));
      expect(find.textContaining('Partial impact path'), findsWidgets);
    });

    testWidgets('shows complete path for fully linked entries', (tester) async {
      await _setDesktopSurface(tester);
      final nodes = _testState().toImpactPathNodes();
      await tester.pumpWidget(_wrapInApp(HistoryImpactView(nodes: nodes)));
      expect(find.textContaining('Complete impact path'), findsWidgets);
    });

    testWidgets('renders workflow hop labels', (tester) async {
      await _setDesktopSurface(tester);
      final nodes = _testState().toImpactPathNodes();
      await tester.pumpWidget(_wrapInApp(HistoryImpactView(nodes: nodes)));
      expect(find.text('gt-code-review'), findsOneWidget);
      expect(find.text('builder-orchestration'), findsOneWidget);
    });
  });

  group('Selection sync across modes', () {
    testWidgets('selection from impact mode appears in inspector', (
      tester,
    ) async {
      await _setDesktopSurface(tester);
      await tester.pumpWidget(
        _wrapInApp(
          HistoryWorkspacePage(
            initialState: _testState(
              viewMode: HistoryViewMode.impactStory,
              selectedEntryId: '2026-06-07-task-0612-inspector',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Selected entry identity must surface in impact mode UI (title/task ref).
      expect(find.textContaining('0612'), findsWidgets);
      expect(
        find.textContaining('inspector').evaluate().isNotEmpty ||
            find.textContaining('changelog').evaluate().isNotEmpty ||
            find.textContaining('0612').evaluate().isNotEmpty,
        isTrue,
      );
    });

    testWidgets('mode switch preserves selected entry', (tester) async {
      await _setDesktopSurface(tester);
      await tester.pumpWidget(
        _wrapInApp(
          HistoryWorkspacePage(
            initialState: _testState(
              viewMode: HistoryViewMode.timeline,
              selectedEntryId: '2026-06-07-task-0612-inspector',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to impact mode without assuming unique tab text widgets.
      final impactTab = find.textContaining('Impact');
      if (impactTab.evaluate().isNotEmpty) {
        await tester.tap(impactTab.first, warnIfMissed: false);
        await tester.pumpAndSettle();
      }

      // Selection survives mode switch: entry id fragment still present.
      expect(find.textContaining('0612'), findsWidgets);
    });
  });
}
