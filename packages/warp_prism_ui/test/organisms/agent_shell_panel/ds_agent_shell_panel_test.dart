import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

void main() {
  Widget harness({
    required Widget child,
    double width = 720,
    double height = 480,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(width: width, height: height, child: child),
      ),
    );
  }

  group('PrismAgentShellPanel / DSAgentShellPanel', () {
    testWidgets('empty session shows empty placeholder state', (tester) async {
      final controller = PrismAgentShellPanelController();
      await tester.pumpWidget(
        harness(
          child: PrismAgentShellPanel(
            controller: controller,
            emptyLabel: 'Session is vacant',
            emptySubtitle: 'No output has been recorded yet',
          ),
        ),
      );

      expect(find.byType(PrismAgentShellPanel), findsOneWidget);
      expect(find.text('Session is vacant'), findsOneWidget);
      expect(find.text('No output has been recorded yet'), findsOneWidget);
    });

    testWidgets('initial lines render correctly with right styles/semantics', (
      tester,
    ) async {
      final t0 = DateTime.utc(2026, 7, 10, 12, 0, 0);
      final controller = PrismAgentShellPanelController(
        initialLines: [
          PrismAgentShellLine(
            id: 'l-sys',
            text: 'System booting...',
            type: PrismAgentShellLineType.system,
            timestamp: t0,
          ),
          PrismAgentShellLine(
            id: 'l-in',
            text: 'git commit -m "feat"',
            type: PrismAgentShellLineType.input,
            timestamp: t0.add(const Duration(seconds: 1)),
          ),
          PrismAgentShellLine(
            id: 'l-out',
            text: 'Files modified: 1',
            type: PrismAgentShellLineType.stdout,
            timestamp: t0.add(const Duration(seconds: 2)),
          ),
          PrismAgentShellLine(
            id: 'l-err',
            text: 'Fatal error occurred',
            type: PrismAgentShellLineType.stderr,
            timestamp: t0.add(const Duration(seconds: 3)),
          ),
        ],
      );

      await tester.pumpWidget(
        harness(
          child: PrismAgentShellPanel(
            controller: controller,
            title: 'Tactical Console',
            subtitle: 'builders-active',
          ),
        ),
      );

      expect(find.text('Tactical Console'), findsOneWidget);
      expect(find.text('builders-active'), findsOneWidget);

      expect(find.textContaining('System booting...'), findsOneWidget);
      expect(find.textContaining('git commit -m "feat"'), findsOneWidget);
      expect(find.textContaining('Files modified: 1'), findsOneWidget);
      expect(find.textContaining('Fatal error occurred'), findsOneWidget);

      // Verify timestamp is formatted and printed
      expect(find.textContaining('[12:00:00]'), findsOneWidget);
      expect(find.textContaining('[12:00:03]'), findsOneWidget);
    });

    testWidgets('clearing controller empty-states the panel', (tester) async {
      final controller = PrismAgentShellPanelController(
        initialLines: [
          const PrismAgentShellLine(
            id: '1',
            text: 'Output line',
            type: PrismAgentShellLineType.stdout,
          ),
        ],
      );

      bool cleared = false;
      await tester.pumpWidget(
        harness(
          child: PrismAgentShellPanel(
            controller: controller,
            onClear: () {
              controller.clear();
              cleared = true;
            },
          ),
        ),
      );

      expect(find.textContaining('Output line'), findsOneWidget);

      final clearBtn = find.bySemanticsLabel('Clear transcript');
      expect(clearBtn, findsOneWidget);
      await tester.tap(clearBtn);
      await tester.pump();

      expect(cleared, isTrue);
      expect(find.textContaining('Output line'), findsNothing);
      expect(find.text('Shell session vacant'), findsOneWidget);
    });

    testWidgets('appending lines via controller dynamically updates shell', (
      tester,
    ) async {
      final controller = PrismAgentShellPanelController();
      await tester.pumpWidget(
        harness(child: PrismAgentShellPanel(controller: controller)),
      );

      expect(find.textContaining('Dynamically appended line'), findsNothing);

      controller.appendLine(
        const PrismAgentShellLine(
          id: 'dyn-1',
          text: 'Dynamically appended line',
          type: PrismAgentShellLineType.stdout,
        ),
      );
      await tester.pump();

      expect(find.textContaining('Dynamically appended line'), findsOneWidget);
    });

    test('controller helper methods function correctly', () {
      final controller = PrismAgentShellPanelController();
      expect(controller.lines, isEmpty);

      controller.appendLine(
        const PrismAgentShellLine(id: 'one', text: 'one text'),
      );
      expect(controller.lines, hasLength(1));
      expect(controller.lines.first.text, 'one text');

      controller.appendLines([
        const PrismAgentShellLine(id: 'two', text: 'two text'),
        const PrismAgentShellLine(id: 'three', text: 'three text'),
      ]);
      expect(controller.lines, hasLength(3));

      controller.clear();
      expect(controller.lines, isEmpty);
    });

    test('model equality and hashcode check', () {
      final t = DateTime.utc(2026, 7, 10, 10, 0, 0);
      final lineA = PrismAgentShellLine(
        id: '1',
        text: 'hello',
        type: PrismAgentShellLineType.stdout,
        timestamp: t,
      );
      final lineB = PrismAgentShellLine(
        id: '1',
        text: 'hello',
        type: PrismAgentShellLineType.stdout,
        timestamp: t,
      );
      final lineC = PrismAgentShellLine(
        id: '2',
        text: 'hello',
        type: PrismAgentShellLineType.stdout,
        timestamp: t,
      );

      expect(lineA, equals(lineB));
      expect(lineA.hashCode, equals(lineB.hashCode));
      expect(lineA, isNot(equals(lineC)));
    });

    testWidgets('transcript region exposes semantic label', (tester) async {
      final controller = PrismAgentShellPanelController(
        initialLines: [
          const PrismAgentShellLine(
            id: 's-1',
            text: 'hello semantics',
            type: PrismAgentShellLineType.stdout,
          ),
        ],
      );

      await tester.pumpWidget(
        harness(
          child: PrismAgentShellPanel(
            controller: controller,
            semanticLabel: 'Agent Session Transcript',
          ),
        ),
      );

      expect(find.bySemanticsLabel('Agent Session Transcript'), findsOneWidget);
      expect(
        find.bySemanticsLabel('Standard output: hello semantics'),
        findsOneWidget,
      );
    });

    testWidgets(
      'controller swap via didUpdateWidget updates listener binding',
      (tester) async {
        final c1 = PrismAgentShellPanelController(
          initialLines: [
            const PrismAgentShellLine(id: 'c1-1', text: 'raw output c1'),
          ],
        );
        final c2 = PrismAgentShellPanelController(
          initialLines: [
            const PrismAgentShellLine(id: 'c2-1', text: 'raw output c2'),
          ],
        );

        // Build with controller c1
        await tester.pumpWidget(
          harness(child: PrismAgentShellPanel(controller: c1)),
        );

        expect(find.textContaining('raw output c1'), findsOneWidget);
        expect(find.textContaining('raw output c2'), findsNothing);

        // Pump/rebuild with controller c2
        await tester.pumpWidget(
          harness(child: PrismAgentShellPanel(controller: c2)),
        );

        // Assert it now shows c2 content and not c1
        expect(find.textContaining('raw output c2'), findsOneWidget);
        expect(find.textContaining('raw output c1'), findsNothing);

        // Assert c1 append does NOT update widget after swap
        c1.appendLine(
          const PrismAgentShellLine(id: 'c1-2', text: 'c1 appended post swap'),
        );
        await tester.pump();
        expect(find.textContaining('c1 appended post swap'), findsNothing);

        // Assert c2 append does update widget after swap
        c2.appendLine(
          const PrismAgentShellLine(id: 'c2-2', text: 'c2 appended post swap'),
        );
        await tester.pump();
        expect(find.textContaining('c2 appended post swap'), findsOneWidget);
      },
    );
  });
}
