import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// Task 1510: PrismOsintWorkbench widget tests
///
/// Covers: ≥2 tool tabs, submit query → structured results, history select,
/// empty results, map handoff when geo present, a11y labels, fixture-only policy.
void main() {
  List<PrismOsintTool> fixtureTools() => PrismOsintFixtures.minimalTools();

  Widget harness({
    List<PrismOsintTool>? tools,
    PrismOsintFixtureResolver? resolver,
    ValueChanged<PrismOsintMapHandoff>? onMapHandoff,
    void Function(String toolId, String query, List<PrismOsintResult> results)?
    onQuerySubmitted,
    ValueChanged<String>? onToolChanged,
    ValueChanged<PrismOsintHistoryEntry>? onHistorySelected,
    String initialToolId = '',
    String initialQuery = '',
    bool isLoading = false,
    bool showHistory = true,
    bool wrapInGlass = true,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 720,
          height: 560,
          child: PrismOsintWorkbench(
            tools: tools ?? fixtureTools(),
            resolver: resolver,
            onMapHandoff: onMapHandoff,
            onQuerySubmitted: onQuerySubmitted,
            onToolChanged: onToolChanged,
            onHistorySelected: onHistorySelected,
            initialToolId: initialToolId,
            initialQuery: initialQuery,
            isLoading: isLoading,
            showHistory: showHistory,
            wrapInGlass: wrapInGlass,
          ),
        ),
      ),
    );
  }

  Future<void> submitQuery(WidgetTester tester, String query) async {
    await tester.enterText(find.byType(TextField), query);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(PrismOsintWorkbench.submitButtonKey));
    await tester.pumpAndSettle();
  }

  group('PrismOsintWorkbench', () {
    test('fixture resolver returns structured DNS + IP (geo) results', () {
      final dns = PrismOsintFixtures.resolve('dns', 'example.com');
      expect(dns, isNotEmpty);
      expect(dns.first.resultType, 'dns');
      expect(dns.first.fields, isNotEmpty);
      expect(dns.first.hasGeo, isFalse);

      final ip = PrismOsintFixtures.resolve('ip', '8.8.8.8');
      expect(ip, isNotEmpty);
      expect(ip.first.hasGeo, isTrue);
      expect(ip.first.latitude, isNotNull);
      expect(ip.first.longitude, isNotNull);

      expect(PrismOsintFixtures.resolve('dns', 'empty'), isEmpty);
      expect(PrismOsintFixtures.resolve('ip', ''), isEmpty);
    });

    test('minimal tools registry has ≥2 tabs', () {
      final tools = PrismOsintFixtures.minimalTools();
      expect(tools.length, greaterThanOrEqualTo(2));
      expect(tools.map((t) => t.id).toSet(), containsAll(['dns', 'ip']));
    });

    testWidgets('constructor rejects fewer than two tool tabs', (tester) async {
      expect(
        () => PrismOsintWorkbench(
          tools: const [PrismOsintTool(id: 'only', label: 'Only')],
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    testWidgets('renders idle empty state and ≥2 tool tabs', (tester) async {
      await tester.pumpWidget(harness());

      expect(find.byType(PrismOsintWorkbench), findsOneWidget);
      expect(find.byKey(PrismOsintWorkbench.panelKey), findsOneWidget);
      expect(find.byKey(PrismOsintWorkbench.toolTabsKey), findsOneWidget);
      expect(find.byKey(PrismOsintWorkbench.queryFieldKey), findsOneWidget);
      expect(find.byKey(PrismOsintWorkbench.submitButtonKey), findsOneWidget);
      expect(find.byKey(PrismOsintWorkbench.emptyStateKey), findsOneWidget);
      expect(find.text('Submit a recon query'), findsOneWidget);

      expect(find.byKey(PrismOsintWorkbench.toolTabKey('dns')), findsOneWidget);
      expect(find.byKey(PrismOsintWorkbench.toolTabKey('ip')), findsOneWidget);
      expect(find.text('DNS'), findsWidgets);
      expect(find.text('IP'), findsWidgets);
    });

    testWidgets('tab switch changes active tool', (tester) async {
      String? active;
      await tester.pumpWidget(harness(onToolChanged: (id) => active = id));

      await tester.tap(find.byKey(PrismOsintWorkbench.toolTabKey('ip')));
      await tester.pumpAndSettle();

      expect(active, 'ip');
      // IP placeholder becomes visible
      expect(find.text('IP address…'), findsOneWidget);
    });

    testWidgets('submit query shows structured results', (tester) async {
      String? submittedTool;
      String? submittedQuery;
      List<PrismOsintResult>? submittedResults;

      await tester.pumpWidget(
        harness(
          onQuerySubmitted: (toolId, query, results) {
            submittedTool = toolId;
            submittedQuery = query;
            submittedResults = results;
          },
        ),
      );

      await submitQuery(tester, 'example.com');

      expect(submittedTool, 'dns');
      expect(submittedQuery, 'example.com');
      expect(submittedResults, isNotEmpty);
      expect(find.byKey(PrismOsintWorkbench.resultsListKey), findsOneWidget);
      expect(find.text('example.com'), findsWidgets);
      expect(find.textContaining('A'), findsWidgets);
      expect(
        find.byKey(PrismOsintWorkbench.resultCardKey('dns-example.com-a')),
        findsOneWidget,
      );
    });

    testWidgets('empty results after submit with empty probe', (tester) async {
      await tester.pumpWidget(harness());

      await submitQuery(tester, 'empty');

      expect(find.byKey(PrismOsintWorkbench.emptyStateKey), findsOneWidget);
      expect(find.text('No results'), findsOneWidget);
      expect(find.byKey(PrismOsintWorkbench.resultsListKey), findsNothing);
    });

    testWidgets('history retains entries and re-runs on select', (
      tester,
    ) async {
      PrismOsintHistoryEntry? selected;
      final submitted = <String>[];

      await tester.pumpWidget(
        harness(
          onHistorySelected: (e) => selected = e,
          onQuerySubmitted: (toolId, query, _) {
            submitted.add('$toolId:$query');
          },
        ),
      );

      await submitQuery(tester, 'example.com');
      expect(find.byKey(PrismOsintWorkbench.historyListKey), findsOneWidget);
      expect(
        find.byKey(PrismOsintWorkbench.historyRowKey('hist-1')),
        findsOneWidget,
      );

      // Switch tool and submit another query
      await tester.tap(find.byKey(PrismOsintWorkbench.toolTabKey('ip')));
      await tester.pumpAndSettle();
      await submitQuery(tester, '1.1.1.1');

      expect(
        find.byKey(PrismOsintWorkbench.historyRowKey('hist-2')),
        findsOneWidget,
      );
      expect(submitted, containsAll(['dns:example.com', 'ip:1.1.1.1']));

      // Select first history entry (dns) — re-runs DNS for example.com
      await tester.tap(find.byKey(PrismOsintWorkbench.historyRowKey('hist-1')));
      await tester.pumpAndSettle();

      expect(selected, isNotNull);
      expect(selected!.toolId, 'dns');
      expect(selected!.query, 'example.com');
      expect(submitted.last, 'dns:example.com');
      expect(
        find.byKey(PrismOsintWorkbench.resultCardKey('dns-example.com-a')),
        findsOneWidget,
      );
    });

    testWidgets('map handoff fires only when geo + callback present', (
      tester,
    ) async {
      PrismOsintMapHandoff? handoff;

      await tester.pumpWidget(
        harness(initialToolId: 'ip', onMapHandoff: (h) => handoff = h),
      );

      await submitQuery(tester, '8.8.8.8');

      const resultId = 'ip-8.8.8.8';
      expect(
        find.byKey(PrismOsintWorkbench.resultCardKey(resultId)),
        findsOneWidget,
      );
      expect(
        find.byKey(PrismOsintWorkbench.mapHandoffKey(resultId)),
        findsOneWidget,
      );

      await tester.tap(find.byKey(PrismOsintWorkbench.mapHandoffKey(resultId)));
      await tester.pumpAndSettle();

      expect(handoff, isNotNull);
      expect(handoff!.resultId, resultId);
      expect(handoff!.toolId, 'ip');
      expect(handoff!.query, '8.8.8.8');
      expect(handoff!.latitude, 37.3861);
      expect(handoff!.longitude, -122.0839);
      expect(handoff!.resultType, 'ip');
    });

    testWidgets('map handoff control absent for non-geo DNS results', (
      tester,
    ) async {
      await tester.pumpWidget(harness(onMapHandoff: (_) {}));

      await submitQuery(tester, 'example.com');

      expect(
        find.byKey(PrismOsintWorkbench.mapHandoffKey('dns-example.com-a')),
        findsNothing,
      );
    });

    testWidgets('loading state surfaces when isLoading', (tester) async {
      await tester.pumpWidget(harness(isLoading: true));

      expect(find.byKey(PrismOsintWorkbench.loadingStateKey), findsOneWidget);
      expect(find.text('Running fixture recon…'), findsOneWidget);
      expect(find.byKey(PrismOsintWorkbench.resultsListKey), findsNothing);
    });

    testWidgets('a11y labels on panel, tabs, submit, history', (tester) async {
      await tester.pumpWidget(harness());

      await submitQuery(tester, 'example.com');

      final panel = tester.getSemantics(
        find.byKey(PrismOsintWorkbench.panelKey),
      );
      expect(panel.label, contains(PrismOsintWorkbench.panelSemanticLabel));

      final dnsTab = tester.getSemantics(
        find.byKey(PrismOsintWorkbench.toolTabKey('dns')),
      );
      expect(dnsTab.label, contains('DNS'));
      expect(dnsTab.flagsCollection.isButton, isTrue);

      final submit = tester.getSemantics(
        find.byKey(PrismOsintWorkbench.submitButtonKey),
      );
      expect(submit.label, PrismOsintWorkbench.submitSemanticLabel);
      expect(submit.flagsCollection.isButton, isTrue);

      final hist = tester.getSemantics(
        find.byKey(PrismOsintWorkbench.historyRowKey('hist-1')),
      );
      expect(hist.label, contains('example.com'));
      expect(hist.flagsCollection.isButton, isTrue);
    });

    testWidgets('history row touch target is at least 48dp tall', (
      tester,
    ) async {
      await tester.pumpWidget(harness());
      await submitQuery(tester, 'example.com');

      final histSize = tester.getSize(
        find.byKey(PrismOsintWorkbench.historyRowKey('hist-1')),
      );
      expect(histSize.height, greaterThanOrEqualTo(48));
    });

    testWidgets('tool tabs enforce >=48dp interactive targets', (tester) async {
      await tester.pumpWidget(harness());

      final dnsSize = tester.getSize(
        find.byKey(PrismOsintWorkbench.toolTabKey('dns')),
      );
      expect(dnsSize.width, greaterThanOrEqualTo(48));
      expect(dnsSize.height, greaterThanOrEqualTo(48));

      final ipSize = tester.getSize(
        find.byKey(PrismOsintWorkbench.toolTabKey('ip')),
      );
      expect(ipSize.width, greaterThanOrEqualTo(48));
      expect(ipSize.height, greaterThanOrEqualTo(48));
    });

    test('Prism* public models expose geo + handoff factory', () {
      const result = PrismOsintResult(
        id: 'r1',
        title: 'Node',
        resultType: 'ip',
        latitude: 1.0,
        longitude: 2.0,
        zoom: 8,
        fields: [PrismOsintResultField(label: 'ASN', value: 'AS1')],
      );
      expect(result.hasGeo, isTrue);

      final handoff = PrismOsintMapHandoff.fromResult(
        result: result,
        toolId: 'ip',
        query: '1.2.3.4',
      );
      expect(handoff.latitude, 1.0);
      expect(handoff.longitude, 2.0);
      expect(handoff.toolId, 'ip');
      expect(handoff.query, '1.2.3.4');
      expect(handoff, isA<PrismOsintMapHandoff>());
    });
  });
}
