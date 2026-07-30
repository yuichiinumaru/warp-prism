import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// Task 1611: PrismExecutionConsole / DSExecutionConsole widget tests.
///
/// Covers: empty, multi-group fixtures, append stream controller, output
/// panel slot, a11y console region, custom output panel. Fixture-only —
/// no PTY / shell / real workflow execution.
void main() {
  Widget harness({
    required Widget child,
    double width = 960,
    double height = 480,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(width: width, height: height, child: child),
      ),
    );
  }

  group('PrismExecutionLine', () {
    test('semanticLabel includes level and message', () {
      const line = PrismExecutionLine(
        id: 'x',
        message: 'hello fixture',
        level: PrismExecutionLineLevel.warning,
        source: 'step-1',
      );
      expect(line.semanticLabel, contains('WARN'));
      expect(line.semanticLabel, contains('step-1'));
      expect(line.semanticLabel, contains('hello fixture'));
    });

    test('copyWith and equality', () {
      const a = PrismExecutionLine(id: '1', message: 'a');
      final b = a.copyWith(message: 'b', level: PrismExecutionLineLevel.error);
      expect(a == b, isFalse);
      expect(b.message, 'b');
      expect(b.level, PrismExecutionLineLevel.error);
      expect(a, equals(const PrismExecutionLine(id: '1', message: 'a')));
    });
  });

  group('PrismExecutionConsoleController', () {
    test('appendLine grows the buffer and notifies', () {
      final controller = PrismExecutionConsoleController();
      var ticks = 0;
      controller.addListener(() => ticks++);

      expect(controller.isEmpty, isTrue);
      controller.appendLine(
        const PrismExecutionLine(id: 'l1', message: 'first'),
      );
      expect(controller.lineCount, 1);
      expect(controller.lines.single.message, 'first');
      expect(ticks, 1);

      controller.appendLines(const [
        PrismExecutionLine(id: 'l2', message: 'second'),
        PrismExecutionLine(id: 'l3', message: 'third'),
      ]);
      expect(controller.lineCount, 3);
      expect(ticks, 2);

      controller.clearLines();
      expect(controller.isEmpty, isTrue);
      expect(ticks, 3);
      controller.dispose();
    });

    test('effectiveStructuredOutput prefers override then selected group', () {
      final controller = PrismExecutionConsoleController(
        runGroups: const [
          PrismExecutionRunGroup(
            id: 'g1',
            label: 'G1',
            structuredOutput: '{"from":"group"}',
          ),
        ],
        selectedRunGroupId: 'g1',
      );
      expect(controller.effectiveStructuredOutput, '{"from":"group"}');

      controller.setStructuredOutputOverride('{"from":"override"}');
      expect(controller.effectiveStructuredOutput, '{"from":"override"}');
      controller.dispose();
    });
  });

  group('PrismExecutionConsole', () {
    testWidgets('empty list shows empty surface and does not crash', (
      tester,
    ) async {
      await tester.pumpWidget(
        harness(
          child: const PrismExecutionConsole(
            lines: [],
            emptyTitle: 'No execution lines',
            emptySubtitle: 'Fixture empty',
            showOutputPanel: false,
          ),
        ),
      );

      expect(find.text('No execution lines'), findsOneWidget);
      expect(find.text('Fixture empty'), findsOneWidget);
      expect(find.byKey(PrismExecutionConsole.emptyKey), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders multi-group fixture lines and headers', (
      tester,
    ) async {
      final fixture = prismExecutionConsoleMinimalFixture();

      await tester.pumpWidget(
        harness(
          child: PrismExecutionConsole(
            lines: fixture.lines,
            runGroups: fixture.groups,
            initialSelectedRunGroupId: 'g1',
            showOutputPanel: true,
          ),
        ),
      );

      expect(find.byType(PrismExecutionConsole), findsOneWidget);
      expect(find.text('Run A'), findsOneWidget);
      expect(find.text('Run B'), findsOneWidget);
      expect(find.text('step-a complete'), findsOneWidget);
      expect(find.text('metrics flushed'), findsOneWidget);
      expect(find.text('step-b failed (fixture)'), findsOneWidget);
      expect(
        find.byKey(PrismExecutionConsole.groupHeaderKey('g1')),
        findsOneWidget,
      );
      expect(find.byKey(PrismExecutionConsole.lineKey('l1')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('append via controller updates the line list', (tester) async {
      final controller = PrismExecutionConsoleController(
        initialLines: const [
          PrismExecutionLine(id: 'seed', message: 'seed line'),
        ],
      );

      await tester.pumpWidget(
        harness(
          child: PrismExecutionConsole(
            controller: controller,
            showOutputPanel: false,
          ),
        ),
      );

      expect(find.text('seed line'), findsOneWidget);

      controller.appendLine(
        const PrismExecutionLine(
          id: 'appended',
          message: 'streamed fixture line',
          level: PrismExecutionLineLevel.stdout,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('streamed fixture line'), findsOneWidget);
      expect(
        find.byKey(PrismExecutionConsole.lineKey('appended')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      controller.dispose();
    });

    testWidgets('selecting a run group updates structured output panel', (
      tester,
    ) async {
      final fixture = prismExecutionConsoleMinimalFixture();

      await tester.pumpWidget(
        harness(
          child: PrismExecutionConsole(
            lines: fixture.lines,
            runGroups: fixture.groups,
            initialSelectedRunGroupId: 'g1',
            showOutputPanel: true,
          ),
        ),
      );

      // Default selection g1 → group structured output in code block.
      expect(find.byType(PrismCodeBlock), findsOneWidget);
      expect(find.textContaining('Output · Run A'), findsOneWidget);

      await tester.tap(find.byKey(PrismExecutionConsole.groupHeaderKey('g2')));
      await tester.pumpAndSettle();

      expect(find.textContaining('Output · Run B'), findsOneWidget);
      expect(find.byType(PrismCodeBlock), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('custom outputPanel slot is honored', (tester) async {
      await tester.pumpWidget(
        harness(
          child: const PrismExecutionConsole(
            lines: [PrismExecutionLine(id: '1', message: 'only line')],
            showOutputPanel: true,
            outputPanel: Center(
              key: Key('custom-output-slot'),
              child: Text('HOST OUTPUT SLOT'),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('custom-output-slot')), findsOneWidget);
      expect(find.text('HOST OUTPUT SLOT'), findsOneWidget);
      expect(find.byType(PrismCodeBlock), findsNothing);
    });

    testWidgets('console region is labeled for a11y', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        harness(
          child: const PrismExecutionConsole(
            semanticLabel: 'Workflow execution console',
            lines: [PrismExecutionLine(id: '1', message: 'a11y line')],
            showOutputPanel: false,
          ),
        ),
      );

      expect(
        tester.getSemantics(find.byType(PrismExecutionConsole)).label,
        'Workflow execution console',
      );
      // Dispose before end-of-test verification (Flutter 3.44 checks handles
      // before tearDowns run; match timing_waterfall / other organism tests).
      handle.dispose();
    });

    testWidgets('gallery fixture pack renders without exception', (
      tester,
    ) async {
      await tester.pumpWidget(
        harness(
          width: 1000,
          height: 520,
          child: PrismExecutionConsole(
            title: 'Execution',
            initialSelectedRunGroupId: 'run-transform',
            lines: prismExecutionConsoleFixtureLines(),
            runGroups: prismExecutionConsoleFixtureRunGroups(),
            showOutputPanel: true,
            useSplitPane: true,
          ),
        ),
      );

      expect(find.byType(PrismExecutionConsole), findsOneWidget);
      expect(find.textContaining('load-fixtures'), findsWidgets);
      expect(find.textContaining('transform'), findsWidgets);
      expect(find.textContaining('Built DAG'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('autoScroll scrolls after append when enabled', (tester) async {
      final controller = PrismExecutionConsoleController();
      // Seed enough lines so the list is scrollable.
      controller.setLines([
        for (var i = 0; i < 40; i++)
          PrismExecutionLine(id: 'seed-$i', message: 'seed line $i'),
      ]);

      await tester.pumpWidget(
        harness(
          height: 320,
          child: PrismExecutionConsole(
            controller: controller,
            showOutputPanel: false,
            autoScroll: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      controller.appendLine(
        const PrismExecutionLine(
          id: 'tail',
          message: 'TAIL_STREAM_LINE',
          level: PrismExecutionLineLevel.info,
        ),
      );
      await tester.pumpAndSettle();

      // Appended line is present; autoscroll path executed without error.
      expect(find.text('TAIL_STREAM_LINE'), findsOneWidget);
      expect(tester.takeException(), isNull);
      controller.dispose();
    });
  });
}
