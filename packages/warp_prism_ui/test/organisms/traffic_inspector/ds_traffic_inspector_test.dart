import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// Task 1609: PrismTrafficInspector / DSTrafficInspector widget tests.
///
/// Covers: list fixture requests; select shows detail; empty list safe;
/// detail tabs; optional embedded timing waterfall; list a11y semantics.
/// Fixture-only — no live MITM / network capture.
void main() {
  Widget harness({
    required Widget child,
    double width = 900,
    double height = 480,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(width: width, height: height, child: child),
      ),
    );
  }

  group('PrismTrafficRequest', () {
    test('status helpers and semanticLabel', () {
      const ok = PrismTrafficRequest(
        id: 'r1',
        method: 'GET',
        url: '/ok',
        statusCode: 200,
        durationMs: 50,
      );
      expect(ok.isSuccess, isTrue);
      expect(ok.durationLabel, '50ms');
      expect(ok.semanticLabel, contains('GET'));
      expect(ok.semanticLabel, contains('/ok'));
      expect(ok.semanticLabel, contains('200'));
      expect(ok.semanticLabel, contains('50ms'));

      const err = PrismTrafficRequest(
        id: 'r2',
        method: 'POST',
        url: '/x',
        statusCode: 500,
        durationMs: 1200,
      );
      expect(err.isServerError, isTrue);
      expect(err.durationLabel, '1.2s');
    });
  });

  group('PrismTrafficInspector', () {
    testWidgets('renders fixture list with method and url', (tester) async {
      final requests = prismTrafficInspectorMinimalFixture();

      await tester.pumpWidget(
        harness(
          child: PrismTrafficInspector(
            requests: requests,
            initialSelectedId: 'req-a',
          ),
        ),
      );

      expect(find.byType(PrismTrafficInspector), findsOneWidget);
      // Method badges appear in list (and method field may repeat in overview).
      expect(find.text('GET'), findsWidgets);
      expect(find.text('POST'), findsWidgets);
      expect(find.text('/v1/ping'), findsWidgets);
      expect(find.text('/v1/echo'), findsOneWidget);
      // Overview detail for initial selection
      expect(find.text('Request ID'), findsOneWidget);
      expect(find.text('req-a'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('empty list shows empty surface and does not crash', (
      tester,
    ) async {
      await tester.pumpWidget(
        harness(
          child: const PrismTrafficInspector(
            requests: [],
            emptyTitle: 'No traffic',
            emptySubtitle: 'Fixture empty',
          ),
        ),
      );

      expect(find.text('No traffic'), findsOneWidget);
      expect(find.text('Fixture empty'), findsOneWidget);
      expect(find.byKey(PrismTrafficInspector.emptyKey), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('selecting a row updates detail overview', (tester) async {
      PrismTrafficRequest? selected;

      await tester.pumpWidget(
        harness(
          child: PrismTrafficInspector(
            requests: prismTrafficInspectorMinimalFixture(),
            initialSelectedId: 'req-a',
            onSelectionChanged: (r) => selected = r,
          ),
        ),
      );

      expect(find.text('req-a'), findsWidgets);

      await tester.tap(find.byKey(PrismTrafficInspector.rowKey('req-b')));
      await tester.pumpAndSettle();

      expect(selected, isNotNull);
      expect(selected!.id, 'req-b');
      expect(find.text('req-b'), findsWidgets);
      expect(find.text('/v1/echo'), findsWidgets);
    });

    testWidgets('headers tab shows request headers fixture text', (
      tester,
    ) async {
      await tester.pumpWidget(
        harness(
          child: PrismTrafficInspector(
            requests: prismTrafficInspectorMinimalFixture(),
            initialSelectedId: 'req-a',
          ),
        ),
      );

      await tester.tap(
        find.byKey(PrismTrafficInspector.tabKey(PrismTrafficDetailTab.headers)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Request headers'), findsOneWidget);
      expect(find.text('Response headers'), findsOneWidget);
      // Header/body content is rendered via PrismCodeBlock (RichText spans).
      expect(find.byType(PrismCodeBlock), findsNWidgets(2));
      expect(find.text('Plain Text'), findsWidgets);
    });

    testWidgets('body tab shows response body fixture', (tester) async {
      await tester.pumpWidget(
        harness(
          child: PrismTrafficInspector(
            requests: prismTrafficInspectorMinimalFixture(),
            initialSelectedId: 'req-a',
          ),
        ),
      );

      await tester.tap(
        find.byKey(PrismTrafficInspector.tabKey(PrismTrafficDetailTab.body)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Request body'), findsOneWidget);
      expect(find.text('Response body'), findsOneWidget);
      // Body fixtures use JSON language → PrismCodeBlock chrome.
      expect(find.byType(PrismCodeBlock), findsNWidgets(2));
      expect(find.text('JSON'), findsWidgets);
    });

    testWidgets('timing tab embeds PrismTimingWaterfall when spans present', (
      tester,
    ) async {
      await tester.pumpWidget(
        harness(
          child: PrismTrafficInspector(
            requests: prismTrafficInspectorMinimalFixture(),
            initialSelectedId: 'req-a',
            showTimingTab: true,
          ),
        ),
      );

      await tester.tap(
        find.byKey(PrismTrafficInspector.tabKey(PrismTrafficDetailTab.timing)),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PrismTimingWaterfall), findsOneWidget);
      expect(find.text('DNS'), findsOneWidget);
      expect(find.text('TTFB'), findsOneWidget);
    });

    testWidgets('timing tab empty spans shows empty surface', (tester) async {
      await tester.pumpWidget(
        harness(
          child: PrismTrafficInspector(
            requests: prismTrafficInspectorMinimalFixture(),
            initialSelectedId: 'req-b',
            showTimingTab: true,
          ),
        ),
      );

      await tester.tap(
        find.byKey(PrismTrafficInspector.tabKey(PrismTrafficDetailTab.timing)),
      );
      await tester.pumpAndSettle();

      expect(find.text('No timing spans'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('controlled selectedId drives detail', (tester) async {
      await tester.pumpWidget(
        harness(
          child: PrismTrafficInspector(
            requests: prismTrafficInspectorMinimalFixture(),
            selectedId: 'req-b',
          ),
        ),
      );

      expect(find.text('req-b'), findsWidgets);
      expect(find.text('400'), findsWidgets);
    });

    testWidgets('gallery fixture pack renders without exception', (
      tester,
    ) async {
      await tester.pumpWidget(
        harness(
          width: 1000,
          height: 520,
          child: PrismTrafficInspector(
            title: 'Traffic',
            initialSelectedId: 'req-chat-001',
            requests: prismTrafficInspectorFixtureRequests(),
          ),
        ),
      );

      expect(find.byType(PrismTrafficInspector), findsOneWidget);
      expect(find.textContaining('/v1/chat/completions'), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  });
}
