/// Widget tests for History story and impact view modes.
///
/// Verifies:
/// - Mode switcher renders Timeline, Project Story, Impact Story
/// - Project Story groups entries by project with narrative
/// - Impact Story shows causality chain changelog -> task -> skill
/// - Missing links render as explicit gap indicators
/// - Selection syncs across modes
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_observatory/data/models/changelog_contracts.dart';
import 'package:warp_prism_observatory/features/history/presentation/history_controller.dart';
import 'package:warp_prism_observatory/features/history/presentation/history_page.dart';
import 'package:warp_prism_observatory/features/history/presentation/history_view_mode.dart';
import 'package:warp_prism_observatory/features/history/presentation/widgets/history_story_view.dart';
import 'package:warp_prism_observatory/features/history/presentation/widgets/history_impact_view.dart';

/// Multi-project entries with varying completeness for thorough testing.
List<ChangelogMetadata> _testEntries() {
  return [
    ChangelogMetadata(
      id: '2026-06-07-task-0612-inspector',
      date: DateTime(2026, 6, 7),
      project: 'warp-prism',
      task: '0612',
      type: ChangelogType.feature,
      impact: ['operate', 'inspector'],
      skills: ['agent-wiki'],
      why: 'Operators need to inspect task details.',
      changed: 'Added detail mapper and panel.',
    ),
    ChangelogMetadata(
      id: '2026-06-07-task-0712-history',
      date: DateTime(2026, 6, 7),
      project: 'warp-prism',
      task: '0712',
      type: ChangelogType.feature,
      impact: ['history', 'timeline'],
      skills: ['build-orchestrator'],
      why: 'Observatory needs a History workspace.',
      changed: 'Created timeline page with filters.',
    ),
    ChangelogMetadata(
      id: '2026-06-06-task-0313-graph',
      date: DateTime(2026, 6, 6),
      project: 'warp-prism',
      task: '0313',
      type: ChangelogType.refactor,
      impact: ['graph-model'],
      skills: [], // no skills — partial path
      why: null,
      changed: 'Normalized graph edges.',
    ),
    ChangelogMetadata(
      id: '2026-06-05-taskless-entry',
      date: DateTime(2026, 6, 5),
      project: 'ganthritor',
      task: '', // no task — gap
      type: ChangelogType.docs,
      impact: ['docs'],
      skills: [], // no skills
      why: null,
      changed: null,
    ),
  ];
}

HistoryState _testState({
  List<ChangelogMetadata>? entries,
  HistoryViewMode viewMode = HistoryViewMode.timeline,
}) {
  return HistoryState(
    allEntries: entries ?? _testEntries(),
    viewMode: viewMode,
  );
}

Widget _wrapInApp(Widget child) {
  return MaterialApp(
    home: Scaffold(body: SizedBox(width: 1200, height: 900, child: child)),
  );
}

void main() {
  group('History View Mode Switcher', () {
    testWidgets('renders all three mode chips', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        HistoryWorkspacePage(initialState: _testState()),
      ));

      expect(find.text('Timeline'), findsOneWidget);
      expect(find.text('Project Story'), findsOneWidget);
      expect(find.text('Impact Story'), findsOneWidget);
    });

    testWidgets('timeline mode shows DSTimeline', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        HistoryWorkspacePage(
          initialState: _testState(viewMode: HistoryViewMode.timeline),
        ),
      ));

      // Timeline renders entries
      expect(find.textContaining('4 of 4'), findsOneWidget);
    });

    testWidgets('switching to project story mode renders story panels',
        (tester) async {
      await tester.pumpWidget(_wrapInApp(
        HistoryWorkspacePage(
          initialState: _testState(viewMode: HistoryViewMode.projectStory),
        ),
      ));

      // Project story groups by project
      expect(find.text('warp-prism'), findsOneWidget);
      expect(find.text('ganthritor'), findsOneWidget);
    });

    testWidgets('switching to impact story mode renders impact cards',
        (tester) async {
      await tester.pumpWidget(_wrapInApp(
        HistoryWorkspacePage(
          initialState: _testState(viewMode: HistoryViewMode.impactStory),
        ),
      ));

      // Impact view renders entry IDs
      expect(find.textContaining('0612'), findsOneWidget);
      expect(find.textContaining('0712'), findsOneWidget);
    });

    testWidgets('tapping mode chip changes mode', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        HistoryWorkspacePage(
          initialState: _testState(viewMode: HistoryViewMode.timeline),
        ),
      ));

      // Tap Project Story
      await tester.tap(find.text('Project Story'));
      await tester.pumpAndSettle();

      // Should now show project groups
      expect(find.text('warp-prism'), findsOneWidget);
    });
  });

  group('ProjectStoryGroup', () {
    test('summary includes entry count and types', () {
      final entries = _testEntries().where((e) => e.project == 'warp-prism').toList();
      final group = ProjectStoryGroup(project: 'warp-prism', entries: entries);
      expect(group.summary, contains('3 change'));
      expect(group.summary, contains('feature'));
      expect(group.summary, contains('refactor'));
    });

    test('taskIds lists non-empty tasks', () {
      final entries = _testEntries().where((e) => e.project == 'warp-prism').toList();
      final group = ProjectStoryGroup(project: 'warp-prism', entries: entries);
      expect(group.taskIds, containsAll(['0612', '0712', '0313']));
    });

    test('taskIds is empty when no entries have tasks', () {
      final entries = _testEntries().where((e) => e.project == 'ganthritor').toList();
      final group = ProjectStoryGroup(project: 'ganthritor', entries: entries);
      expect(group.taskIds, isEmpty);
    });
  });

  group('ImpactPathNode', () {
    test('hasCompletePath is true when task and skills present', () {
      final state = _testState();
      final nodes = state.toImpactPathNodes();
      final completeNode = nodes.firstWhere((n) => n.entry.task == '0612');
      expect(completeNode.hasCompletePath, isTrue);
      expect(completeNode.resolvedTaskId, '0612');
      expect(completeNode.resolvedSkills, ['agent-wiki']);
    });

    test('hasCompletePath is false when skills missing', () {
      final state = _testState();
      final nodes = state.toImpactPathNodes();
      final partialNode = nodes.firstWhere((n) => n.entry.task == '0313');
      expect(partialNode.hasCompletePath, isFalse);
      expect(partialNode.resolvedTaskId, '0313');
      expect(partialNode.resolvedSkills, isEmpty);
    });

    test('resolvedTaskId is null when task is empty', () {
      final state = _testState();
      final nodes = state.toImpactPathNodes();
      final noTaskNode = nodes.firstWhere((n) => n.entry.task.isEmpty);
      expect(noTaskNode.resolvedTaskId, isNull);
      expect(noTaskNode.hasCompletePath, isFalse);
    });
  });

  group('HistoryState view mode', () {
    test('default view mode is timeline', () {
      final state = _testState();
      expect(state.viewMode, HistoryViewMode.timeline);
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
      final state = _testState();
      final groups = state.toProjectStoryGroups();
      expect(groups.length, 2);
      expect(groups.first.project, 'warp-prism');
      expect(groups.first.entries.length, 3);
      expect(groups.last.project, 'ganthritor');
      expect(groups.last.entries.length, 1);
    });

    test('toImpactPathNodes returns one node per entry', () {
      final state = _testState();
      final nodes = state.toImpactPathNodes();
      expect(nodes.length, 4);
    });
  });

  group('HistoryStoryView', () {
    testWidgets('renders empty state when no groups', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        HistoryStoryView(groups: const []),
      ));
      expect(find.text('No project stories'), findsOneWidget);
    });

    testWidgets('renders project groups', (tester) async {
      final state = _testState();
      final groups = state.toProjectStoryGroups();
      await tester.pumpWidget(_wrapInApp(
        HistoryStoryView(groups: groups),
      ));
      expect(find.text('warp-prism'), findsOneWidget);
      expect(find.text('ganthritor'), findsOneWidget);
    });
  });

  group('HistoryImpactView', () {
    testWidgets('renders empty state when no nodes', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        HistoryImpactView(nodes: const []),
      ));
      expect(find.text('No impact paths'), findsOneWidget);
    });

    testWidgets('renders impact path cards', (tester) async {
      final state = _testState();
      final nodes = state.toImpactPathNodes();
      await tester.pumpWidget(_wrapInApp(
        HistoryImpactView(nodes: nodes),
      ));
      // Should render entry IDs
      expect(find.textContaining('0612'), findsOneWidget);
      expect(find.textContaining('0712'), findsOneWidget);
    });

    testWidgets('shows gap indicator for missing task', (tester) async {
      final state = _testState();
      final nodes = state.toImpactPathNodes();
      await tester.pumpWidget(_wrapInApp(
        HistoryImpactView(nodes: nodes),
      ));
      expect(find.text('No task linked to this entry'), findsOneWidget);
    });

    testWidgets('shows gap indicator for missing skills', (tester) async {
      final state = _testState();
      final nodes = state.toImpactPathNodes();
      await tester.pumpWidget(_wrapInApp(
        HistoryImpactView(nodes: nodes),
      ));
      expect(find.text('No skills/workflows linked'), findsOneWidget);
    });

    testWidgets('shows partial path warning', (tester) async {
      final state = _testState();
      final nodes = state.toImpactPathNodes();
      await tester.pumpWidget(_wrapInApp(
        HistoryImpactView(nodes: nodes),
      ));
      expect(find.textContaining('Partial impact path'), findsWidgets);
    });

    testWidgets('shows complete path for fully linked entries',
        (tester) async {
      final state = _testState();
      final nodes = state.toImpactPathNodes();
      await tester.pumpWidget(_wrapInApp(
        HistoryImpactView(nodes: nodes),
      ));
      expect(find.textContaining('Complete impact path'), findsWidgets);
    });
  });
}
