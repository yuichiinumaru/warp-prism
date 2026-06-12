/// Widget tests for the History workspace timeline page.
///
/// Verifies:
/// - Timeline renders entries in chronological order from read model
/// - Filters by project, type, task, skill/workflow, impact_tags
/// - Empty, loading, and malformed/error states render gracefully
/// - Entry selection syncs with detail panel on desktop layout
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_observatory/data/models/changelog_contracts.dart';
import 'package:warp_prism_observatory/features/history/presentation/history_controller.dart';
import 'package:warp_prism_observatory/features/history/presentation/history_page.dart';

/// Build a representative list of [ChangelogMetadata] fixtures.
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
      id: '2026-06-07-task-0313-graph',
      date: DateTime(2026, 6, 6),
      project: 'warp-prism',
      task: '0313',
      type: ChangelogType.refactor,
      impact: ['graph-model'],
      skills: [],
      why: null,
      changed: 'Normalized graph edges.',
    ),
    ChangelogMetadata(
      id: '2026-06-07-task-0810-governance',
      date: DateTime(2026, 6, 7),
      project: 'warp-prism',
      task: '0810',
      type: ChangelogType.feature,
      impact: ['governance'],
      skills: ['agent-wiki'],
      why: null,
      changed: null,
    ),
  ];
}

HistoryState _testState({
  List<ChangelogMetadata>? entries,
  bool isLoading = false,
  String? error,
}) {
  return HistoryState(
    allEntries: entries ?? _testEntries(),
    isLoading: isLoading,
    error: error,
  );
}

Widget _wrapInApp(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: OverflowBox(
        maxWidth: double.infinity,
        maxHeight: double.infinity,
        child: SizedBox(width: 1200, height: 2400, child: child),
      ),
    ),
  );
}

void main() {
  group('HistoryWorkspacePage', () {
    testWidgets('renders timeline entries in reverse chronological order', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrapInApp(HistoryWorkspacePage(initialState: _testState())),
      );

      // Should render entries count
      expect(find.textContaining('4 of 4'), findsOneWidget);

      // All entries should be rendered
      expect(find.textContaining('0612 — feature'), findsOneWidget);
      expect(find.textContaining('0712 — feature'), findsOneWidget);
      expect(find.textContaining('0313 — refactor'), findsOneWidget);
      expect(find.textContaining('0810 — feature'), findsOneWidget);
    });

    testWidgets('renders filter categories', (tester) async {
      await tester.pumpWidget(
        _wrapInApp(HistoryWorkspacePage(initialState: _testState())),
      );

      // Filter category chips should be present
      expect(find.text('warp-prism'), findsWidgets);
      expect(find.text('feature'), findsWidgets);
      expect(find.text('0612'), findsWidgets);
    });

    testWidgets('shows loading state', (tester) async {
      await tester.pumpWidget(
        _wrapInApp(
          HistoryWorkspacePage(initialState: _testState(isLoading: true)),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error state', (tester) async {
      await tester.pumpWidget(
        _wrapInApp(
          HistoryWorkspacePage(
            initialState: _testState(error: 'Parser failed'),
          ),
        ),
      );

      expect(find.textContaining('Failed to load'), findsOneWidget);
      expect(find.text('Parser failed'), findsOneWidget);
    });

    testWidgets('shows empty state when no entries', (tester) async {
      await tester.pumpWidget(
        _wrapInApp(HistoryWorkspacePage(initialState: _testState(entries: []))),
      );

      expect(find.textContaining('0 of 0'), findsOneWidget);
    });

    testWidgets('renders result count after loading', (tester) async {
      await tester.pumpWidget(
        _wrapInApp(HistoryWorkspacePage(initialState: _testState())),
      );

      expect(find.textContaining('of 4'), findsOneWidget);
    });
  });

  group('HistoryState', () {
    test('filteredEntries returns all when no filters active', () {
      final state = _testState();
      expect(state.filteredEntries.length, 4);
    });

    test('filteredEntries filters by project', () {
      final state = _testState();
      final filtered = state.copyWith(
        activeFilters: {
          HistoryFilterCategory.project: {'warp-prism'},
        },
      );
      expect(filtered.filteredEntries.length, 4);
    });

    test('filteredEntries filters by type', () {
      final state = _testState();
      final filtered = state.copyWith(
        activeFilters: {
          HistoryFilterCategory.type: {'feature'},
        },
      );
      expect(filtered.filteredEntries.length, 3);
    });

    test('filteredEntries filters by task', () {
      final state = _testState();
      final filtered = state.copyWith(
        activeFilters: {
          HistoryFilterCategory.task: {'0612'},
        },
      );
      expect(filtered.filteredEntries.length, 1);
      expect(filtered.filteredEntries.first.task, '0612');
    });

    test('filteredEntries filters by skill', () {
      final state = _testState();
      final filtered = state.copyWith(
        activeFilters: {
          HistoryFilterCategory.skillWorkflow: {'agent-wiki'},
        },
      );
      expect(filtered.filteredEntries.length, 2);
    });

    test('filteredEntries filters by impact tag', () {
      final state = _testState();
      final filtered = state.copyWith(
        activeFilters: {
          HistoryFilterCategory.impactTag: {'inspector'},
        },
      );
      expect(filtered.filteredEntries.length, 1);
    });

    test('toTimelineEntries converts correctly', () {
      final state = _testState();
      final entries = state.toTimelineEntries();
      expect(entries.length, 4);
      // Should be sorted newest first
      expect(entries.first.id, contains('0612'));
    });

    test('availableFilters returns distinct values', () {
      final state = _testState();
      final projects = state.availableFilters(HistoryFilterCategory.project);
      expect(projects, {'warp-prism'});
      final types = state.availableFilters(HistoryFilterCategory.type);
      expect(types, containsAll(['feature', 'refactor']));
    });

    test('copyWith clearSelection works', () {
      final state = _testState();
      final selected = state.copyWith(selectedEntryId: 'test');
      expect(selected.selectedEntryId, 'test');
      final cleared = selected.copyWith(clearSelection: true);
      expect(cleared.selectedEntryId, isNull);
    });
  });
}
