import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// Task 1607: PrismProviderHealthMatrix / DSProviderHealthMatrix widget tests.
///
/// Covers: default fixture matrix (≥2 providers × ≥2 cells), empty providers,
/// degraded/error cell styling, selection callback, operational state mapping,
/// a11y cell labels (provider + state). Fixture-only — no network.
void main() {
  Widget harness({
    required Widget child,
    double width = 720,
    double height = 400,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: width,
          height: height,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(width: width, child: child),
          ),
        ),
      ),
    );
  }

  group('PrismProviderHealthMatrix', () {
    testWidgets('renders fixture matrix with ≥2 providers and ≥2 cells each', (
      tester,
    ) async {
      final providers = prismProviderHealthMatrixMinimalFixture();
      expect(providers.length, greaterThanOrEqualTo(2));
      for (final p in providers) {
        expect(p.cells.length, greaterThanOrEqualTo(2));
      }

      await tester.pumpWidget(
        harness(child: PrismProviderHealthMatrix(providers: providers)),
      );

      expect(find.byType(PrismProviderHealthMatrix), findsOneWidget);
      expect(find.text('OpenAI'), findsOneWidget);
      expect(find.text('Anthropic'), findsOneWidget);
      expect(find.text('acct-a'), findsOneWidget);
      expect(find.text('acct-b'), findsOneWidget);
      // Cell operational labels present
      expect(find.text('Healthy'), findsWidgets);
      expect(find.text('Degraded'), findsOneWidget);
      expect(find.text('Error'), findsOneWidget);
      // Latency labels
      expect(find.text('100ms'), findsOneWidget);
      expect(find.text('500ms'), findsOneWidget);
      expect(find.text('3.0s'), findsOneWidget);
    });

    testWidgets('maps operational states via PrismOperationalState', (
      tester,
    ) async {
      await tester.pumpWidget(
        harness(
          child: PrismProviderHealthMatrix(
            providers: prismProviderHealthMatrixMinimalFixture(),
          ),
        ),
      );

      // State labels come from DSOperationalState.label
      expect(find.text(PrismOperationalState.healthy.label), findsWidgets);
      expect(find.text(PrismOperationalState.degraded.label), findsOneWidget);
      expect(find.text(PrismOperationalState.error.label), findsOneWidget);
    });

    testWidgets('empty providers shows empty surface', (tester) async {
      await tester.pumpWidget(
        harness(
          child: const PrismProviderHealthMatrix(
            providers: [],
            emptyTitle: 'No providers',
            emptySubtitle: 'Fixture empty',
          ),
        ),
      );

      expect(find.text('No providers'), findsOneWidget);
      expect(find.text('Fixture empty'), findsOneWidget);
      expect(find.byType(PrismProviderHealthMatrix), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('empty providers can hide placeholder', (tester) async {
      await tester.pumpWidget(
        harness(
          child: const PrismProviderHealthMatrix(
            providers: [],
            showEmptyPlaceholder: false,
          ),
        ),
      );

      expect(find.text('No providers'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('cell tap fires onCellSelected with cell id', (tester) async {
      PrismProviderHealthCell? selected;

      await tester.pumpWidget(
        harness(
          child: PrismProviderHealthMatrix(
            providers: prismProviderHealthMatrixMinimalFixture(),
            onCellSelected: (cell) => selected = cell,
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('provider-health-cell-o-b')));
      await tester.pump();

      expect(selected, isNotNull);
      expect(selected!.id, 'o-b');
      expect(selected!.providerId, 'openai');
      expect(selected!.operationalState, PrismOperationalState.degraded);
    });

    testWidgets('selectedCellId highlights matching cell', (tester) async {
      await tester.pumpWidget(
        harness(
          child: PrismProviderHealthMatrix(
            providers: prismProviderHealthMatrixMinimalFixture(),
            selectedCellId: 'a-a',
            onCellSelected: (_) {},
          ),
        ),
      );

      // Key is on PrismInteractiveSurface itself.
      final surface = tester.widget<PrismInteractiveSurface>(
        find.byKey(const Key('provider-health-cell-a-a')),
      );
      expect(surface.selected, isTrue);

      final other = tester.widget<PrismInteractiveSurface>(
        find.byKey(const Key('provider-health-cell-o-a')),
      );
      expect(other.selected, isFalse);
    });

    testWidgets('degraded and error cells use operational state colors', (
      tester,
    ) async {
      await tester.pumpWidget(
        harness(
          child: PrismProviderHealthMatrix(
            providers: prismProviderHealthMatrixMinimalFixture(),
          ),
        ),
      );

      // Status dots inherit operational colors — presence of labeled cells
      // with non-healthy states is the styling contract for MVP.
      final degradedText = tester.widgetList<Text>(find.text('Degraded'));
      expect(degradedText, isNotEmpty);
      final errorText = tester.widgetList<Text>(find.text('Error'));
      expect(errorText, isNotEmpty);

      // Colors on label text match operational vocabulary.
      final degradedStyle = degradedText.first.style;
      expect(degradedStyle?.color, PrismOperationalState.degraded.color);

      final errorStyle = errorText.first.style;
      expect(errorStyle?.color, PrismOperationalState.error.color);
    });

    testWidgets('a11y: cell semantics include provider + state', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          harness(
            child: PrismProviderHealthMatrix(
              providers: prismProviderHealthMatrixMinimalFixture(),
              onCellSelected: (_) {},
            ),
          ),
        );

        // Interactive surface exposes cell.semanticLabel (provider + state).
        final healthyNode = tester.getSemantics(
          find.byKey(const Key('provider-health-cell-o-a')),
        );
        expect(healthyNode.label, 'OpenAI acct-a: Healthy, 100ms');
        expect(healthyNode.flagsCollection.isButton, isTrue);

        final errorNode = tester.getSemantics(
          find.byKey(const Key('provider-health-cell-a-a')),
        );
        expect(errorNode.label, 'Anthropic acct-a: Error, 3.0s');
        expect(errorNode.flagsCollection.isButton, isTrue);
      } finally {
        handle.dispose();
      }
    });

    testWidgets('a11y: matrix container reports provider/dimension counts', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          harness(
            child: PrismProviderHealthMatrix(
              semanticLabel: 'Provider health matrix',
              providers: prismProviderHealthMatrixMinimalFixture(),
            ),
          ),
        );

        expect(
          find.bySemanticsLabel(
            RegExp(
              r'Provider health matrix: 2 providers, 2 dimensions, 4 cells',
            ),
          ),
          findsOneWidget,
        );
      } finally {
        handle.dispose();
      }
    });

    testWidgets('full gallery fixture providers render without crash', (
      tester,
    ) async {
      await tester.pumpWidget(
        harness(
          width: 900,
          child: PrismProviderHealthMatrix(
            providers: prismProviderHealthMatrixFixtureProviders(),
            selectedCellId: 'openai-dev-sandbox',
          ),
        ),
      );

      expect(find.text('OpenAI'), findsOneWidget);
      expect(find.text('Anthropic'), findsOneWidget);
      expect(find.text('Local Mock'), findsOneWidget);
      expect(find.text('main-prod'), findsOneWidget);
      expect(find.text('dev-sandbox'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    test('cell semanticLabel and latencyLabel helpers', () {
      const cell = PrismProviderHealthCell(
        id: 'c1',
        providerId: 'openai',
        providerLabel: 'OpenAI',
        dimensionId: 'gpt-4o',
        dimensionLabel: 'gpt-4o',
        operationalState: PrismOperationalState.healthy,
        latency: Duration(milliseconds: 42),
        meta: 'us-east',
      );

      expect(cell.latencyLabel, '42ms');
      expect(cell.semanticLabel, 'OpenAI gpt-4o: Healthy, 42ms, us-east');

      const slow = PrismProviderHealthCell(
        id: 'c2',
        providerId: 'x',
        providerLabel: 'X',
        dimensionId: 'd',
        dimensionLabel: 'D',
        operationalState: PrismOperationalState.error,
        latency: Duration(milliseconds: 2500),
      );
      expect(slow.latencyLabel, '2.5s');
    });

    test('provider effectiveAggregate prefers explicit aggregateState', () {
      const provider = PrismProviderHealthProvider(
        id: 'p',
        label: 'P',
        aggregateState: PrismOperationalState.stale,
        cells: [
          PrismProviderHealthCell(
            id: 'c',
            providerId: 'p',
            providerLabel: 'P',
            dimensionId: 'd',
            dimensionLabel: 'D',
            operationalState: PrismOperationalState.healthy,
          ),
        ],
      );
      expect(provider.effectiveAggregate, PrismOperationalState.stale);
    });

    test('provider effectiveAggregate rolls up worst cell state', () {
      const provider = PrismProviderHealthProvider(
        id: 'p',
        label: 'P',
        cells: [
          PrismProviderHealthCell(
            id: 'c1',
            providerId: 'p',
            providerLabel: 'P',
            dimensionId: 'a',
            dimensionLabel: 'A',
            operationalState: PrismOperationalState.healthy,
          ),
          PrismProviderHealthCell(
            id: 'c2',
            providerId: 'p',
            providerLabel: 'P',
            dimensionId: 'b',
            dimensionLabel: 'B',
            operationalState: PrismOperationalState.degraded,
          ),
          PrismProviderHealthCell(
            id: 'c3',
            providerId: 'p',
            providerLabel: 'P',
            dimensionId: 'c',
            dimensionLabel: 'C',
            operationalState: PrismOperationalState.error,
          ),
        ],
      );
      expect(provider.effectiveAggregate, PrismOperationalState.error);
    });
  });
}
