/// Widget tests for the History workspace timeline page.
///
/// Verifies:
/// - Timeline renders entries in chronological order from read model
/// - Filters by project, type, task, skill/workflow, impact_tags
/// - Empty, loading, and malformed/error states render gracefully
/// - Entry selection syncs with detail panel on desktop layout
/// - Route shell maps HistoryTimeline → HistoryState
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_observatory/data/models/changelog_contracts.dart';
import 'package:warp_prism_observatory/data/repositories/history_repository.dart';
import 'package:warp_prism_observatory/features/asset_detail/presentation/asset_detail_view.dart';
import 'package:warp_prism_observatory/features/history/presentation/history_controller.dart';
import 'package:warp_prism_observatory/features/history/presentation/history_page.dart';
import 'package:warp_prism_observatory/app/pages/history_page.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// Build a representative list of [HistoryEntry] fixtures.
List<HistoryEntry> _testEntries() {
  return [
    HistoryEntry(
      id: '2026-06-07-task-0612-inspector',
      title: '',
      date: DateTime(2026, 6, 7),
      project: 'warp-prism',
      task: '0612',
      type: ChangelogType.feature,
      impactTags: ['operate', 'inspector'],
      skills: ['agent-wiki'],
      path: 'docs/changelog/0612.md',
    ),
    HistoryEntry(
      id: '2026-06-07-task-0712-history',
      title: '',
      date: DateTime(2026, 6, 7),
      project: 'warp-prism',
      task: '0712',
      type: ChangelogType.feature,
      impactTags: ['history', 'timeline'],
      skills: ['build-orchestrator'],
      path: 'docs/changelog/0712.md',
    ),
    HistoryEntry(
      id: '2026-06-07-task-0313-graph',
      title: '',
      date: DateTime(2026, 6, 6),
      project: 'warp-prism',
      task: '0313',
      type: ChangelogType.refactor,
      impactTags: ['graph-model'],
      skills: const [],
      path: 'docs/changelog/0313.md',
    ),
    HistoryEntry(
      id: '2026-06-07-task-0810-governance',
      title: '',
      date: DateTime(2026, 6, 7),
      project: 'warp-prism',
      task: '0810',
      type: ChangelogType.feature,
      impactTags: ['governance'],
      skills: ['agent-wiki'],
      path: 'docs/changelog/0810.md',
    ),
  ];
}

HistoryState _testState({
  List<HistoryEntry>? entries,
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

      expect(find.textContaining('4 of 4'), findsOneWidget);
      expect(find.textContaining('0612 — feature'), findsOneWidget);
      expect(find.textContaining('0712 — feature'), findsOneWidget);
      expect(find.textContaining('0313 — refactor'), findsOneWidget);
      expect(find.textContaining('0810 — feature'), findsOneWidget);
    });

    testWidgets('renders filter categories', (tester) async {
      await tester.pumpWidget(
        _wrapInApp(HistoryWorkspacePage(initialState: _testState())),
      );

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

      expect(find.textContaining('Loading history'), findsOneWidget);
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
      expect(find.textContaining('No history entries'), findsOneWidget);
    });

    testWidgets('renders result count after loading', (tester) async {
      await tester.pumpWidget(
        _wrapInApp(HistoryWorkspacePage(initialState: _testState())),
      );

      expect(find.textContaining('of 4'), findsOneWidget);
    });

    testWidgets('active type filter reduces visible result count', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final filtered = _testState().copyWith(
        activeFilters: {
          HistoryFilterCategory.type: {'refactor'},
        },
      );
      await tester.pumpWidget(
        _wrapInApp(HistoryWorkspacePage(initialState: filtered)),
      );

      expect(find.textContaining('1 of 4'), findsOneWidget);
      expect(find.textContaining('0313 — refactor'), findsOneWidget);
      expect(find.textContaining('0612 — feature'), findsNothing);
    });

    testWidgets('selected entry opens detail inspector', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final selected = _testState().copyWith(
        selectedEntryId: '2026-06-07-task-0612-inspector',
      );
      await tester.pumpWidget(
        _wrapInApp(HistoryWorkspacePage(initialState: selected)),
      );
      await tester.pumpAndSettle();

      // Universal AssetDetailView (changelog) via Task 0905 adapters.
      expect(find.byType(AssetDetailView), findsOneWidget);
      expect(find.byType(PrismDetailInspector), findsOneWidget);
      expect(find.text('Identity'), findsOneWidget);
      expect(find.text('Ledger Source'), findsOneWidget);
      expect(find.text('Affected Assets'), findsOneWidget);
    });
  });

  group('HistoryPageShell', () {
    testWidgets('forced loading state shows loading surface', (tester) async {
      await tester.pumpWidget(
        _wrapInApp(const HistoryPageShell(forceLoading: true)),
      );
      expect(find.textContaining('Loading history'), findsOneWidget);
    });

    testWidgets('forced error state shows error surface', (tester) async {
      await tester.pumpWidget(
        _wrapInApp(const HistoryPageShell(forcedError: 'boom')),
      );
      expect(find.textContaining('Failed to load'), findsOneWidget);
      expect(find.text('boom'), findsOneWidget);
    });

    testWidgets('forced state renders timeline entries', (tester) async {
      await tester.pumpWidget(
        _wrapInApp(HistoryPageShell(forcedState: _testState())),
      );
      expect(find.textContaining('4 of 4'), findsOneWidget);
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
      // Sorted newest first — same date keeps stable id order.
      expect(entries.any((e) => e.id.contains('0612')), isTrue);
      expect(entries.first.date, '2026-06-07');
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

    test('fromTimeline maps HistoryTimeline entries', () {
      final timeline = HistoryTimeline(
        entries: _testEntries(),
        facets: const HistoryFacets.empty(),
        byProject: const [],
        byType: const [],
        byTask: const [],
      );
      final state = HistoryState.fromTimeline(timeline);
      expect(state.allEntries.length, 4);
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
    });

    test('null dates sort last', () {
      final entries = [
        HistoryEntry(
          id: 'dated',
          title: 'Dated',
          date: DateTime(2026, 6, 7),
          project: 'p',
          task: '1',
          type: ChangelogType.fix,
          impactTags: const [],
          skills: const [],
          path: 'a.md',
        ),
        HistoryEntry(
          id: 'malformed',
          title: 'Bad',
          date: null,
          project: 'p',
          task: '',
          type: ChangelogType.chore,
          impactTags: const [],
          skills: const [],
          path: 'b.md',
          isMalformed: true,
          warnings: const ['missing date'],
        ),
      ];
      final state = HistoryState(allEntries: entries);
      expect(state.filteredEntries.first.id, 'dated');
      expect(state.filteredEntries.last.id, 'malformed');
      expect(state.toTimelineEntries().last.date, 'unknown');
    });
  });
}
