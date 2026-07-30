import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// Task 1605: PrismToolCallCard / DSToolCallCard widget tests.
///
/// Covers: name + args + result render, collapsed vs expanded, error state,
/// pending/running, controlled expand, a11y expand label, model helpers.
/// Fixture-only — no network / no tool execution.
void main() {
  Widget harness({
    required Widget child,
    double width = 480,
    double height = 640,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: width,
          height: height,
          child: SingleChildScrollView(child: child),
        ),
      ),
    );
  }

  group('PrismToolCallCard', () {
    testWidgets('renders tool name, args summary, and status', (tester) async {
      const data = PrismToolCallData(
        id: 't1',
        toolName: 'provider.health_check',
        argsSummary: 'provider=openai',
        argsBody: '{"provider":"openai"}',
        resultBody: '{"status":"healthy"}',
        status: PrismToolCallStatus.success,
        duration: Duration(milliseconds: 420),
      );

      await tester.pumpWidget(
        harness(child: const PrismToolCallCard(data: data)),
      );

      expect(find.byType(PrismToolCallCard), findsOneWidget);
      expect(find.byKey(const Key('tool-call-card-t1')), findsOneWidget);
      expect(find.text('provider.health_check'), findsOneWidget);
      expect(find.text('provider=openai'), findsOneWidget);
      expect(find.text('Success'), findsOneWidget);
      expect(find.text('420ms'), findsOneWidget);
      // Collapsed by default — body hidden
      expect(find.text('Arguments'), findsNothing);
      expect(find.text('Result'), findsNothing);
    });

    testWidgets('expanded shows args and result bodies', (tester) async {
      const data = PrismToolCallData(
        id: 't2',
        toolName: 'workspace.search',
        argsSummary: 'q=health',
        argsBody: '{\n  "query": "health"\n}',
        resultBody: '{\n  "hits": 3\n}',
        status: PrismToolCallStatus.success,
      );

      await tester.pumpWidget(
        harness(
          child: const PrismToolCallCard(data: data, initiallyExpanded: true),
        ),
      );

      expect(find.text('Arguments'), findsOneWidget);
      expect(find.text('Result'), findsOneWidget);
      expect(find.textContaining('query'), findsWidgets);
      expect(find.textContaining('hits'), findsWidgets);
    });

    testWidgets('error state fixture shows error body when expanded', (
      tester,
    ) async {
      const data = PrismToolCallData(
        id: 't-err',
        toolName: 'mcp.list_tools',
        argsSummary: 'server=filesystem',
        argsBody: '{"server":"filesystem"}',
        errorBody: 'connection refused (fixture)',
        status: PrismToolCallStatus.error,
      );

      await tester.pumpWidget(
        harness(
          child: const PrismToolCallCard(data: data, initiallyExpanded: true),
        ),
      );

      expect(find.text('Error'), findsWidgets);
      expect(find.text('connection refused (fixture)'), findsOneWidget);
      expect(find.text('mcp.list_tools'), findsOneWidget);
    });

    testWidgets('toggle expand / collapse via header', (tester) async {
      const data = PrismToolCallData(
        id: 't-toggle',
        toolName: 'artifact.export',
        argsBody: '{"format":"md"}',
        resultBody: 'ok',
        status: PrismToolCallStatus.success,
      );

      await tester.pumpWidget(
        harness(child: const PrismToolCallCard(data: data)),
      );

      expect(find.text('Arguments'), findsNothing);

      await tester.tap(find.text('artifact.export'));
      await tester.pumpAndSettle();

      expect(find.text('Arguments'), findsOneWidget);
      expect(find.text('Result'), findsOneWidget);

      await tester.tap(find.text('artifact.export'));
      await tester.pumpAndSettle();

      expect(find.text('Arguments'), findsNothing);
    });

    testWidgets('controlled expanded state honors host', (tester) async {
      var expanded = false;

      await tester.pumpWidget(
        harness(
          child: StatefulBuilder(
            builder: (context, setState) {
              return PrismToolCallCard(
                data: const PrismToolCallData(
                  id: 't-ctrl',
                  toolName: 'ctrl.tool',
                  argsBody: 'a=1',
                  resultBody: 'done',
                  status: PrismToolCallStatus.success,
                ),
                expanded: expanded,
                onExpandedChanged: (v) => setState(() => expanded = v),
              );
            },
          ),
        ),
      );

      expect(find.text('Arguments'), findsNothing);

      await tester.tap(find.text('ctrl.tool'));
      await tester.pumpAndSettle();

      expect(find.text('Arguments'), findsOneWidget);
      expect(expanded, isTrue);
    });

    testWidgets('no expandable body keeps header static', (tester) async {
      await tester.pumpWidget(
        harness(
          child: const PrismToolCallCard(
            data: PrismToolCallData(
              id: 't-pending',
              toolName: 'pending.tool',
              status: PrismToolCallStatus.pending,
            ),
          ),
        ),
      );

      expect(find.text('pending.tool'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
      // Tapping should not throw or expand empty body
      await tester.tap(find.text('pending.tool'));
      await tester.pumpAndSettle();
      expect(find.text('Arguments'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('running status badge renders', (tester) async {
      await tester.pumpWidget(
        harness(
          child: const PrismToolCallCard(
            data: PrismToolCallData(
              id: 't-run',
              toolName: 'run.tool',
              argsBody: '{}',
              status: PrismToolCallStatus.running,
            ),
          ),
        ),
      );

      expect(find.text('Running'), findsOneWidget);
    });

    testWidgets('expand control is labeled for a11y', (tester) async {
      const data = PrismToolCallData(
        id: 't-a11y',
        toolName: 'search.docs',
        argsBody: '{}',
        resultBody: '[]',
        status: PrismToolCallStatus.success,
      );

      await tester.pumpWidget(
        harness(child: const PrismToolCallCard(data: data)),
      );

      final expand = find.bySemanticsLabel('Expand tool call search.docs');
      expect(expand, findsOneWidget);

      await tester.tap(expand);
      await tester.pumpAndSettle();

      expect(
        find.bySemanticsLabel('Collapse tool call search.docs'),
        findsOneWidget,
      );
    });

    testWidgets('card region semantic label includes tool name', (
      tester,
    ) async {
      await tester.pumpWidget(
        harness(
          child: const PrismToolCallCard(
            data: PrismToolCallData(
              id: 't-sem',
              toolName: 'sem.tool',
              status: PrismToolCallStatus.success,
              resultBody: 'x',
            ),
          ),
        ),
      );

      expect(
        find.bySemanticsLabel(RegExp(r'Tool call sem\.tool')),
        findsWidgets,
      );
    });
  });

  group('PrismToolCallData model', () {
    test('statusLabel and statusColor map correctly', () {
      expect(
        const PrismToolCallData(
          id: 'a',
          toolName: 't',
          status: PrismToolCallStatus.pending,
        ).statusLabel,
        'Pending',
      );
      expect(
        const PrismToolCallData(
          id: 'a',
          toolName: 't',
          status: PrismToolCallStatus.error,
        ).statusLabel,
        'Error',
      );
      expect(
        const PrismToolCallData(
          id: 'a',
          toolName: 't',
          status: PrismToolCallStatus.success,
        ).statusColor,
        PrismColors.statusSuccess,
      );
    });

    test('hasExpandableBody and durationLabel', () {
      const empty = PrismToolCallData(id: 'e', toolName: 't');
      expect(empty.hasExpandableBody, isFalse);
      expect(empty.durationLabel, isNull);

      const withMs = PrismToolCallData(
        id: 'e',
        toolName: 't',
        argsBody: '{}',
        duration: Duration(milliseconds: 250),
      );
      expect(withMs.hasExpandableBody, isTrue);
      expect(withMs.durationLabel, '250ms');

      const withSec = PrismToolCallData(
        id: 'e',
        toolName: 't',
        resultBody: 'ok',
        duration: Duration(milliseconds: 1500),
      );
      expect(withSec.durationLabel, '1.5s');
    });

    test('copyWith and equality', () {
      const a = PrismToolCallData(
        id: '1',
        toolName: 't',
        status: PrismToolCallStatus.pending,
      );
      final b = a.copyWith(status: PrismToolCallStatus.success);
      expect(a == b, isFalse);
      expect(b.status, PrismToolCallStatus.success);
      expect(a.copyWith(), a);
    });
  });
}
