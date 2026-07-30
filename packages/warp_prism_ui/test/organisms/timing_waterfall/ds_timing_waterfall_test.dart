import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// Task 1609: PrismTimingWaterfall / DSTimingWaterfall widget tests.
///
/// Covers: fixture spans render; empty list safe; zero-duration safe;
/// bar widths scale with duration; a11y labels include name + duration.
/// Fixture-only — no Recharts / network.
void main() {
  Widget harness({
    required Widget child,
    double width = 640,
    double height = 320,
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

  group('PrismTimingWaterfallLayout', () {
    test('resolveMaxEndMs uses max end offset', () {
      final spans = prismTimingWaterfallMinimalFixture();
      expect(PrismTimingWaterfallLayout.resolveMaxEndMs(spans), 120);
    });

    test('resolveMaxEndMs is 1 for empty or all-zero', () {
      expect(PrismTimingWaterfallLayout.resolveMaxEndMs(const []), 1);
      expect(
        PrismTimingWaterfallLayout.resolveMaxEndMs(const [
          PrismTimingSpan(id: 'z', name: 'Z', startMs: 0, durationMs: 0),
        ]),
        1,
      );
    });

    test('widthFraction scales with duration; zero gets minBarFraction', () {
      const long = PrismTimingSpan(
        id: 'l',
        name: 'Long',
        startMs: 0,
        durationMs: 100,
      );
      const short = PrismTimingSpan(
        id: 's',
        name: 'Short',
        startMs: 0,
        durationMs: 10,
      );
      const zero = PrismTimingSpan(
        id: 'z',
        name: 'Zero',
        startMs: 50,
        durationMs: 0,
      );

      expect(PrismTimingWaterfallLayout.widthFraction(long, 100), 1.0);
      expect(
        PrismTimingWaterfallLayout.widthFraction(short, 100),
        closeTo(0.1, 0.001),
      );
      expect(
        PrismTimingWaterfallLayout.widthFraction(zero, 100),
        PrismTimingWaterfallLayout.minBarFraction,
      );
      expect(
        PrismTimingWaterfallLayout.widthFraction(long, 100) >
            PrismTimingWaterfallLayout.widthFraction(short, 100),
        isTrue,
      );
    });

    test('leftFraction positions by startMs', () {
      const span = PrismTimingSpan(
        id: 'm',
        name: 'Mid',
        startMs: 50,
        durationMs: 10,
      );
      expect(PrismTimingWaterfallLayout.leftFraction(span, 100), 0.5);
    });
  });

  group('PrismTimingSpan', () {
    test('durationLabel and semanticLabel include name + duration', () {
      const span = PrismTimingSpan(
        id: 't',
        name: 'TTFB',
        startMs: 0,
        durationMs: 320,
      );
      expect(span.durationLabel, '320ms');
      expect(span.semanticLabel, contains('TTFB'));
      expect(span.semanticLabel, contains('320ms'));

      const long = PrismTimingSpan(
        id: 'l',
        name: 'Slow',
        startMs: 0,
        durationMs: 1500,
        meta: 'origin',
      );
      expect(long.durationLabel, '1.5s');
      expect(long.semanticLabel, contains('origin'));
    });
  });

  group('PrismTimingWaterfall', () {
    testWidgets('renders fixture spans with name and duration labels', (
      tester,
    ) async {
      final spans = prismTimingWaterfallMinimalFixture();

      await tester.pumpWidget(
        harness(child: PrismTimingWaterfall(spans: spans)),
      );

      expect(find.byType(PrismTimingWaterfall), findsOneWidget);
      expect(find.text('DNS'), findsOneWidget);
      expect(find.text('TTFB'), findsOneWidget);
      expect(find.text('Mark'), findsOneWidget);
      expect(find.text('20ms'), findsOneWidget);
      expect(find.text('100ms'), findsOneWidget);
      expect(find.text('0ms'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('empty list shows empty surface and does not crash', (
      tester,
    ) async {
      await tester.pumpWidget(
        harness(
          child: const PrismTimingWaterfall(
            spans: [],
            emptyTitle: 'No timing spans',
            emptySubtitle: 'Fixture empty',
          ),
        ),
      );

      expect(find.text('No timing spans'), findsOneWidget);
      expect(find.text('Fixture empty'), findsOneWidget);
      expect(find.byKey(PrismTimingWaterfall.emptyKey), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('empty list can hide placeholder', (tester) async {
      await tester.pumpWidget(
        harness(
          child: const PrismTimingWaterfall(
            spans: [],
            showEmptyPlaceholder: false,
          ),
        ),
      );

      expect(find.text('No timing spans'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('zero-duration span still paints a bar marker', (tester) async {
      await tester.pumpWidget(
        harness(
          child: PrismTimingWaterfall(
            spans: prismTimingWaterfallMinimalFixture(),
          ),
        ),
      );

      expect(find.byKey(PrismTimingWaterfall.barKey('t-mark')), findsOneWidget);
      final bar = tester.renderObject<RenderBox>(
        find.byKey(PrismTimingWaterfall.barKey('t-mark')),
      );
      expect(bar.size.width, greaterThanOrEqualTo(2.0));
    });

    testWidgets('longer span bar is wider than shorter span bar', (
      tester,
    ) async {
      await tester.pumpWidget(
        harness(
          width: 720,
          child: const PrismTimingWaterfall(
            spans: [
              PrismTimingSpan(
                id: 'short',
                name: 'Short',
                startMs: 0,
                durationMs: 10,
              ),
              PrismTimingSpan(
                id: 'long',
                name: 'Long',
                startMs: 0,
                durationMs: 100,
              ),
            ],
          ),
        ),
      );

      final shortBar = tester.renderObject<RenderBox>(
        find.byKey(PrismTimingWaterfall.barKey('short')),
      );
      final longBar = tester.renderObject<RenderBox>(
        find.byKey(PrismTimingWaterfall.barKey('long')),
      );
      expect(longBar.size.width, greaterThan(shortBar.size.width));
    });

    testWidgets('span tap fires onSpanSelected', (tester) async {
      PrismTimingSpan? selected;

      await tester.pumpWidget(
        harness(
          child: PrismTimingWaterfall(
            spans: prismTimingWaterfallMinimalFixture(),
            onSpanSelected: (s) => selected = s,
          ),
        ),
      );

      await tester.tap(find.byKey(PrismTimingWaterfall.rowKey('t-ttfb')));
      await tester.pump();

      expect(selected, isNotNull);
      expect(selected!.id, 't-ttfb');
      expect(selected!.name, 'TTFB');
    });

    testWidgets('a11y semantics include name and duration', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        harness(
          child: PrismTimingWaterfall(
            spans: prismTimingWaterfallMinimalFixture(),
          ),
        ),
      );

      // Span rows expose a single label with name + duration (no child concat).
      final semantics = tester.getSemantics(
        find.byKey(PrismTimingWaterfall.rowKey('t-dns')),
      );
      expect(semantics.label, 'DNS, 20ms');
      handle.dispose();
    });

    testWidgets('gallery fixture set renders without overflow', (tester) async {
      await tester.pumpWidget(
        harness(
          height: 400,
          child: PrismTimingWaterfall(
            spans: prismTimingWaterfallFixtureSpans(),
            selectedSpanId: 'span-ttfb',
          ),
        ),
      );

      expect(find.text('DNS'), findsOneWidget);
      expect(find.text('Download'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
