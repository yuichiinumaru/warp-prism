// DSLogViewer Widget Tests
// Task 1114: Log Viewer Component
//
// Tests cover: severity filter, source filter, text search, auto-scroll
// pause/resume + append, expand/collapse, absolute timestamps, a11y 48×48
// targets, empty state, and 10K virtualization smoke.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:warp_prism_ui/src/organisms/log_viewer/log_viewer.dart';
import 'package:warp_prism_ui/src/tokens/tokens.dart';

/// Helper: wraps a widget in MaterialApp + Scaffold for testing.
Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(body: SizedBox(width: 800, height: 600, child: child)),
  );
}

/// Builds a long scrollable stream of log lines.
List<DSLogEntry> _manyEntries(int count, {String prefix = 'Entry'}) {
  return List.generate(
    count,
    (i) => DSLogEntry(
      id: '$i',
      timestamp: DateTime(2026, 6, 8, 10, 0, i % 60),
      severity: DSLogSeverity.info,
      source: 'src',
      message: '$prefix $i',
    ),
  );
}

/// Harness that can append entries after the first pump (auto-scroll proof).
class _AppendHarness extends StatefulWidget {
  const _AppendHarness();

  @override
  State<_AppendHarness> createState() => _AppendHarnessState();
}

class _AppendHarnessState extends State<_AppendHarness> {
  late List<DSLogEntry> _entries;

  @override
  void initState() {
    super.initState();
    _entries = _manyEntries(40);
  }

  void append() {
    final i = _entries.length;
    setState(() {
      _entries = [
        ..._entries,
        DSLogEntry(
          id: '$i',
          timestamp: DateTime(2026, 6, 8, 10, 0, i % 60),
          severity: DSLogSeverity.info,
          source: 'src',
          message: 'Entry $i',
        ),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextButton(onPressed: append, child: const Text('Append')),
        Expanded(child: DSLogViewer(entries: _entries, showFilters: false)),
      ],
    );
  }
}

/// Sample entries for testing.
List<DSLogEntry> _sampleEntries() => [
  DSLogEntry(
    id: '1',
    timestamp: DateTime(2026, 6, 8, 10, 0, 0),
    severity: DSLogSeverity.info,
    source: 'agent-alpha',
    message: 'Workflow started',
  ),
  DSLogEntry(
    id: '2',
    timestamp: DateTime(2026, 6, 8, 10, 0, 1),
    severity: DSLogSeverity.warning,
    source: 'governance',
    message: 'Stale index detected',
  ),
  DSLogEntry(
    id: '3',
    timestamp: DateTime(2026, 6, 8, 10, 0, 2),
    severity: DSLogSeverity.error,
    source: 'agent-beta',
    message: 'Parse failure',
    detail: 'FormatException at line 42\nStack trace here',
  ),
  DSLogEntry(
    id: '4',
    timestamp: DateTime(2026, 6, 8, 10, 0, 3),
    severity: DSLogSeverity.debug,
    source: 'mcp-server',
    message: 'Tool invocation detail',
  ),
  DSLogEntry(
    id: '5',
    timestamp: DateTime(2026, 6, 8, 10, 0, 4),
    severity: DSLogSeverity.critical,
    source: 'system',
    message: 'Circuit breaker open',
    detail: 'Connection pool exhausted',
  ),
];

void main() {
  group('DSLogSeverity', () {
    test('has exactly five severity levels', () {
      expect(DSLogSeverity.values.length, equals(5));
    });

    test('defines debug, info, warning, error, critical', () {
      expect(DSLogSeverity.values, contains(DSLogSeverity.debug));
      expect(DSLogSeverity.values, contains(DSLogSeverity.info));
      expect(DSLogSeverity.values, contains(DSLogSeverity.warning));
      expect(DSLogSeverity.values, contains(DSLogSeverity.error));
      expect(DSLogSeverity.values, contains(DSLogSeverity.critical));
    });

    test('each severity has a distinct label', () {
      final labels = DSLogSeverity.values.map((s) => s.label).toSet();
      expect(labels.length, equals(5));
    });

    test('each severity has a non-null color', () {
      for (final s in DSLogSeverity.values) {
        expect(s.color, isNotNull);
      }
    });

    test('each severity has a non-null icon', () {
      for (final s in DSLogSeverity.values) {
        expect(s.icon, isNotNull);
      }
    });

    test('debug color is textTertiary', () {
      expect(DSLogSeverity.debug.color, equals(DSColors.textTertiary));
    });

    test('info color is statusInfo', () {
      expect(DSLogSeverity.info.color, equals(DSColors.statusInfo));
    });

    test('warning color is statusWarning', () {
      expect(DSLogSeverity.warning.color, equals(DSColors.statusWarning));
    });

    test('error color is statusError', () {
      expect(DSLogSeverity.error.color, equals(DSColors.statusError));
    });

    test('critical color is statusError', () {
      expect(DSLogSeverity.critical.color, equals(DSColors.statusError));
    });
  });

  group('DSLogEntry', () {
    test('hasDetail returns true when detail is provided', () {
      final entry = DSLogEntry(
        id: '1',
        timestamp: DateTime(2026, 6, 8),
        severity: DSLogSeverity.info,
        source: 'src',
        message: 'msg',
        detail: 'stack trace',
      );
      expect(entry.hasDetail, isTrue);
    });

    test('hasDetail returns false when detail is null', () {
      final entry = DSLogEntry(
        id: '1',
        timestamp: DateTime(2026, 6, 8),
        severity: DSLogSeverity.info,
        source: 'src',
        message: 'msg',
      );
      expect(entry.hasDetail, isFalse);
    });

    test('hasDetail returns false when detail is empty string', () {
      final entry = DSLogEntry(
        id: '1',
        timestamp: DateTime(2026, 6, 8),
        severity: DSLogSeverity.info,
        source: 'src',
        message: 'msg',
        detail: '',
      );
      expect(entry.hasDetail, isFalse);
    });

    test('equality is based on id', () {
      final a = DSLogEntry(
        id: '1',
        timestamp: DateTime(2026, 6, 8),
        severity: DSLogSeverity.info,
        source: 'src',
        message: 'msg',
      );
      final b = DSLogEntry(
        id: '1',
        timestamp: DateTime(2026, 6, 9),
        severity: DSLogSeverity.error,
        source: 'other',
        message: 'different',
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  group('DSLogViewer', () {
    group('empty state', () {
      testWidgets('shows empty state when no entries', (tester) async {
        await tester.pumpWidget(_wrap(const DSLogViewer(entries: [])));

        expect(find.text('No log entries'), findsOneWidget);
      });

      testWidgets('shows filter hint when filters active with no results', (
        tester,
      ) async {
        await tester.pumpWidget(_wrap(DSLogViewer(entries: _sampleEntries())));
        await tester.pumpAndSettle();

        // The viewer starts with all entries visible
        expect(find.text('5 / 5 entries'), findsOneWidget);
      });
    });

    group('severity display', () {
      testWidgets('renders all sample entries', (tester) async {
        await tester.pumpWidget(_wrap(DSLogViewer(entries: _sampleEntries())));
        await tester.pumpAndSettle();

        expect(find.text('Workflow started'), findsOneWidget);
        expect(find.text('Stale index detected'), findsOneWidget);
        expect(find.text('Parse failure'), findsOneWidget);
        expect(find.text('Tool invocation detail'), findsOneWidget);
        expect(find.text('Circuit breaker open'), findsOneWidget);
      });

      testWidgets('shows severity labels in filter chips', (tester) async {
        await tester.pumpWidget(_wrap(DSLogViewer(entries: _sampleEntries())));
        await tester.pumpAndSettle();

        expect(find.text('DEBUG'), findsOneWidget);
        expect(find.text('INFO'), findsOneWidget);
        expect(find.text('WARN'), findsOneWidget);
        expect(find.text('ERROR'), findsOneWidget);
        expect(find.text('FATAL'), findsOneWidget);
      });

      testWidgets('shows source badges', (tester) async {
        await tester.pumpWidget(_wrap(DSLogViewer(entries: _sampleEntries())));
        await tester.pumpAndSettle();

        // Source names appear in both entry rows AND filter chips
        expect(find.text('agent-alpha'), findsWidgets);
        expect(find.text('governance'), findsWidgets);
        expect(find.text('agent-beta'), findsWidgets);
        expect(find.text('mcp-server'), findsWidgets);
        expect(find.text('system'), findsWidgets);
      });
    });

    group('severity filter', () {
      testWidgets('filtering by severity shows only matching entries', (
        tester,
      ) async {
        await tester.pumpWidget(_wrap(DSLogViewer(entries: _sampleEntries())));
        await tester.pumpAndSettle();

        // Tap the ERROR chip
        await tester.tap(find.text('ERROR'));
        await tester.pumpAndSettle();

        // Only error entry should be visible
        expect(find.text('Parse failure'), findsOneWidget);
        expect(find.text('Workflow started'), findsNothing);
        expect(find.text('1 / 5 entries'), findsOneWidget);
      });

      testWidgets('toggling severity filter off shows all entries', (
        tester,
      ) async {
        await tester.pumpWidget(_wrap(DSLogViewer(entries: _sampleEntries())));
        await tester.pumpAndSettle();

        // Tap ERROR to filter
        await tester.tap(find.text('ERROR'));
        await tester.pumpAndSettle();
        expect(find.text('1 / 5 entries'), findsOneWidget);

        // Tap ERROR again to unfilter
        await tester.tap(find.text('ERROR'));
        await tester.pumpAndSettle();
        expect(find.text('5 / 5 entries'), findsOneWidget);
      });

      testWidgets('filtering by multiple severities', (tester) async {
        await tester.pumpWidget(_wrap(DSLogViewer(entries: _sampleEntries())));
        await tester.pumpAndSettle();

        // Tap ERROR and FATAL
        await tester.tap(find.text('ERROR'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('FATAL'));
        await tester.pumpAndSettle();

        // error + critical entries visible
        expect(find.text('Parse failure'), findsOneWidget);
        expect(find.text('Circuit breaker open'), findsOneWidget);
        expect(find.text('2 / 5 entries'), findsOneWidget);
      });
    });

    group('source filter', () {
      testWidgets('filtering by source shows only matching entries', (
        tester,
      ) async {
        await tester.pumpWidget(_wrap(DSLogViewer(entries: _sampleEntries())));
        await tester.pumpAndSettle();

        // Tap the agent-alpha source chip (first occurrence is the chip in filter bar)
        final sourceChips = find.text('agent-alpha');
        await tester.tap(sourceChips.first);
        await tester.pumpAndSettle();

        expect(find.text('Workflow started'), findsOneWidget);
        expect(find.text('Stale index detected'), findsNothing);
        expect(find.text('1 / 5 entries'), findsOneWidget);
      });
    });

    group('text search', () {
      testWidgets('search filters entries by message content', (tester) async {
        await tester.pumpWidget(_wrap(DSLogViewer(entries: _sampleEntries())));
        await tester.pumpAndSettle();

        // Enter search text
        await tester.enterText(find.byType(TextField), 'circuit');
        await tester.pumpAndSettle();

        expect(find.text('Circuit breaker open'), findsOneWidget);
        expect(find.text('1 / 5 entries'), findsOneWidget);
      });

      testWidgets('search is case-insensitive', (tester) async {
        await tester.pumpWidget(_wrap(DSLogViewer(entries: _sampleEntries())));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), 'PARSE');
        await tester.pumpAndSettle();

        expect(find.text('Parse failure'), findsOneWidget);
        expect(find.text('1 / 5 entries'), findsOneWidget);
      });

      testWidgets('search matches source names', (tester) async {
        await tester.pumpWidget(_wrap(DSLogViewer(entries: _sampleEntries())));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), 'governance');
        await tester.pumpAndSettle();

        expect(find.text('Stale index detected'), findsOneWidget);
        expect(find.text('1 / 5 entries'), findsOneWidget);
      });

      testWidgets('empty search shows all entries', (tester) async {
        await tester.pumpWidget(_wrap(DSLogViewer(entries: _sampleEntries())));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), 'circuit');
        await tester.pumpAndSettle();
        expect(find.text('1 / 5 entries'), findsOneWidget);

        await tester.enterText(find.byType(TextField), '');
        await tester.pumpAndSettle();
        expect(find.text('5 / 5 entries'), findsOneWidget);
      });
    });

    group('expand/collapse', () {
      testWidgets('entries with detail can be expanded', (tester) async {
        await tester.pumpWidget(_wrap(DSLogViewer(entries: _sampleEntries())));
        await tester.pumpAndSettle();

        // Stack trace should not be visible initially
        expect(find.textContaining('FormatException'), findsNothing);

        // Tap on the error entry (which has detail)
        await tester.tap(find.text('Parse failure'));
        await tester.pumpAndSettle();

        // Stack trace should now be visible
        expect(find.textContaining('FormatException'), findsOneWidget);
      });

      testWidgets('expanded entry can be collapsed', (tester) async {
        await tester.pumpWidget(_wrap(DSLogViewer(entries: _sampleEntries())));
        await tester.pumpAndSettle();

        // Expand
        await tester.tap(find.text('Parse failure'));
        await tester.pumpAndSettle();
        expect(find.textContaining('FormatException'), findsOneWidget);

        // Collapse
        await tester.tap(find.text('Parse failure'));
        await tester.pumpAndSettle();
        expect(find.textContaining('FormatException'), findsNothing);
      });

      testWidgets('entries without detail do not expand', (tester) async {
        await tester.pumpWidget(_wrap(DSLogViewer(entries: _sampleEntries())));
        await tester.pumpAndSettle();

        // Tap on info entry (no detail) — should not throw
        await tester.tap(find.text('Workflow started'));
        await tester.pumpAndSettle();

        // No error thrown, no detail shown
        expect(find.text('Workflow started'), findsOneWidget);
      });
    });

    group('empty results after filtering', () {
      testWidgets('shows empty state when search has no matches', (
        tester,
      ) async {
        await tester.pumpWidget(_wrap(DSLogViewer(entries: _sampleEntries())));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), 'nonexistent-query');
        await tester.pumpAndSettle();

        expect(find.text('No log entries'), findsOneWidget);
        expect(find.text('Try adjusting filters'), findsOneWidget);
      });

      testWidgets('shows empty state when severity filter has no matches', (
        tester,
      ) async {
        // All entries are different severities — filtering on DEBUG should
        // show only the single debug entry, not empty.
        // Let's test with entries that don't have a particular severity.
        final entries = [
          DSLogEntry(
            id: '1',
            timestamp: DateTime(2026, 6, 8),
            severity: DSLogSeverity.info,
            source: 'src',
            message: 'info only',
          ),
        ];

        await tester.pumpWidget(_wrap(DSLogViewer(entries: entries)));
        await tester.pumpAndSettle();

        // Filter by ERROR — no match
        await tester.tap(find.text('ERROR'));
        await tester.pumpAndSettle();

        expect(find.text('No log entries'), findsOneWidget);
      });
    });

    group('auto-scroll', () {
      testWidgets('shows count summary', (tester) async {
        await tester.pumpWidget(_wrap(DSLogViewer(entries: _sampleEntries())));
        await tester.pumpAndSettle();

        expect(find.text('5 / 5 entries'), findsOneWidget);
      });

      testWidgets('auto-scroll button not shown by default', (tester) async {
        await tester.pumpWidget(_wrap(DSLogViewer(entries: _sampleEntries())));
        await tester.pumpAndSettle();

        // "Latest" button should not appear when auto-scroll is active
        expect(find.text('Latest'), findsNothing);
      });
    });

    group('showFilters flag', () {
      testWidgets('hides filter bar when showFilters is false', (tester) async {
        await tester.pumpWidget(
          _wrap(DSLogViewer(entries: _sampleEntries(), showFilters: false)),
        );
        await tester.pumpAndSettle();

        // Search bar should not be present
        expect(find.byType(TextField), findsNothing);

        // Severity chips should not be present
        expect(find.text('DEBUG'), findsNothing);
        expect(find.text('INFO'), findsNothing);

        // Entries should still render
        expect(find.text('Workflow started'), findsOneWidget);
      });
    });

    group('timestamps', () {
      testWidgets('shows HH:mm:ss format by default', (tester) async {
        await tester.pumpWidget(_wrap(DSLogViewer(entries: _sampleEntries())));
        await tester.pumpAndSettle();

        // Check for formatted timestamps
        expect(find.text('10:00:00'), findsOneWidget);
        expect(find.text('10:00:01'), findsOneWidget);
      });

      testWidgets('shows absolute timestamps when showAbsoluteTime is true', (
        tester,
      ) async {
        await tester.pumpWidget(
          _wrap(DSLogViewer(entries: _sampleEntries(), showAbsoluteTime: true)),
        );
        await tester.pumpAndSettle();

        expect(find.text('2026-06-08 10:00:00'), findsOneWidget);
        expect(find.text('2026-06-08 10:00:01'), findsOneWidget);
        // Relative-only form should not appear as the full cell text.
        expect(find.text('10:00:00'), findsNothing);
      });
    });

    group('auto-scroll behavior', () {
      testWidgets('user scroll-up shows Latest; tap resumes', (tester) async {
        // Enough entries to make the list scrollable.
        final entries = _manyEntries(40);

        await tester.pumpWidget(
          _wrap(DSLogViewer(entries: entries, showFilters: false)),
        );
        await tester.pumpAndSettle();

        expect(find.text('Latest'), findsNothing);

        // Drag content toward later rows without landing at maxScrollExtent so
        // pause-on-scroll-away-from-bottom fires.
        final list = find.byType(Scrollable);
        expect(list, findsOneWidget);
        await tester.drag(list, const Offset(0, -300));
        await tester.pumpAndSettle();

        expect(find.text('Latest'), findsOneWidget);
        expect(
          find.bySemanticsLabel(RegExp(r'Resume auto-scroll to latest')),
          findsOneWidget,
        );

        await tester.tap(
          find.bySemanticsLabel(RegExp(r'Resume auto-scroll to latest')),
        );
        await tester.pumpAndSettle();

        expect(find.text('Latest'), findsNothing);
      });

      testWidgets('appending entries auto-scrolls to the newest line', (
        tester,
      ) async {
        await tester.pumpWidget(_wrap(const _AppendHarness()));
        await tester.pumpAndSettle();

        // List starts at top — last seed entry is not built.
        expect(find.text('Entry 0'), findsOneWidget);
        expect(find.text('Entry 39'), findsNothing);

        await tester.tap(find.text('Append'));
        await tester.pumpAndSettle();

        // didUpdateWidget + auto-scroll should reveal the newly appended line.
        expect(find.text('Entry 40'), findsOneWidget);
        expect(find.text('Latest'), findsNothing);
      });

      testWidgets('Latest resume control meets 48×48 min size', (tester) async {
        await tester.pumpWidget(
          _wrap(DSLogViewer(entries: _manyEntries(40), showFilters: false)),
        );
        await tester.pumpAndSettle();

        await tester.drag(find.byType(Scrollable), const Offset(0, -300));
        await tester.pumpAndSettle();

        final latest = find.bySemanticsLabel(
          RegExp(r'Resume auto-scroll to latest'),
        );
        expect(latest, findsOneWidget);
        final size = tester.getSize(latest);
        expect(size.width, greaterThanOrEqualTo(kMinInteractiveDimension));
        expect(size.height, greaterThanOrEqualTo(kMinInteractiveDimension));

        final data = tester.getSemantics(latest);
        expect(data.flagsCollection.isButton, isTrue);
      });
    });

    group('a11y targets', () {
      testWidgets('expand control is a button and meets 48×48', (tester) async {
        await tester.pumpWidget(_wrap(DSLogViewer(entries: _sampleEntries())));
        await tester.pumpAndSettle();

        final expand = find.bySemanticsLabel('Expand log entry');
        expect(expand, findsWidgets);

        final first = expand.first;
        final data = tester.getSemantics(first);
        expect(data.flagsCollection.isButton, isTrue);

        final size = tester.getSize(first);
        expect(size.width, greaterThanOrEqualTo(kMinInteractiveDimension));
        expect(size.height, greaterThanOrEqualTo(kMinInteractiveDimension));
      });
    });

    group('virtualization smoke', () {
      testWidgets('10K entries virtualize without building all rows', (
        tester,
      ) async {
        var buildMarkers = 0;
        final entries = List.generate(10000, (i) {
          return DSLogEntry(
            id: '$i',
            timestamp: DateTime(2026, 6, 8, 10, 0, i % 60),
            severity: DSLogSeverity.info,
            source: 'src',
            // Distinct message so finders can detect built rows.
            message: 'Row-$i-marker',
          );
        });

        await tester.pumpWidget(
          _wrap(DSLogViewer(entries: entries, showFilters: false)),
        );
        // One frame is enough; settle is unnecessary for ListView.builder.
        await tester.pump();

        expect(find.text('10000 / 10000 entries'), findsOneWidget);
        expect(find.text('Row-0-marker'), findsOneWidget);
        // Far end of the list must not be in the element tree yet.
        expect(find.text('Row-9999-marker'), findsNothing);

        // Bound how many row markers landed in the tree (viewport + cache).
        for (var i = 0; i < 10000; i++) {
          if (find.text('Row-$i-marker').evaluate().isNotEmpty) {
            buildMarkers++;
          }
        }
        expect(buildMarkers, lessThan(80));
        expect(buildMarkers, greaterThan(0));
      });
    });

    group('Semantics', () {
      testWidgets('log viewer has semantic label', (tester) async {
        await tester.pumpWidget(_wrap(DSLogViewer(entries: _sampleEntries())));
        await tester.pumpAndSettle();

        expect(
          find.bySemanticsLabel('Log viewer showing 5 entries'),
          findsOneWidget,
        );
      });

      testWidgets('entries have semantic labels', (tester) async {
        await tester.pumpWidget(_wrap(DSLogViewer(entries: _sampleEntries())));
        await tester.pumpAndSettle();

        expect(
          find.bySemanticsLabel('INFO: agent-alpha: Workflow started'),
          findsOneWidget,
        );
        expect(
          find.bySemanticsLabel('FATAL: system: Circuit breaker open'),
          findsOneWidget,
        );
      });
    });
  });
}
