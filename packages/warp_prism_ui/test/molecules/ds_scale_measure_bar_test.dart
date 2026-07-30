import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// Task 1522: PrismScaleMeasureBar molecule tests
///
/// Covers: fixture label/segments render, semantics, public aliases.
void main() {
  Widget harness({
    String label = PrismScaleMeasureBarFixtures.defaultLabel,
    List<PrismScaleSegment> segments =
        PrismScaleMeasureBarFixtures.defaultSegments,
    String? caption,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: PrismScaleMeasureBar(
            label: label,
            segments: segments,
            caption: caption,
          ),
        ),
      ),
    );
  }

  group('PrismScaleMeasureBar', () {
    testWidgets('renders fixture scale label', (tester) async {
      await tester.pumpWidget(harness());

      expect(find.byType(PrismScaleMeasureBar), findsOneWidget);
      expect(find.byKey(PrismScaleMeasureBar.barRegionKey), findsOneWidget);
      expect(find.text('100 m'), findsOneWidget);
    });

    testWidgets('renders caption when provided', (tester) async {
      await tester.pumpWidget(harness(caption: 'Fixture scale'));

      expect(find.text('Fixture scale'), findsOneWidget);
    });

    testWidgets('exposes map scale semantics', (tester) async {
      await tester.pumpWidget(harness(caption: 'WGS84 demo'));

      final semantics = tester.getSemantics(
        find.byKey(PrismScaleMeasureBar.barRegionKey),
      );
      expect(semantics.label, contains('Map scale 100 m'));
      expect(semantics.label, contains('WGS84 demo'));
    });

    testWidgets('kilometer fixture renders alternate label', (tester) async {
      await tester.pumpWidget(
        harness(
          label: PrismScaleMeasureBarFixtures.kilometerLabel,
          segments: PrismScaleMeasureBarFixtures.kilometerSegments,
        ),
      );

      expect(find.text('1 km'), findsOneWidget);
    });

    test('segment model equality', () {
      const a = PrismScaleSegment(id: 's', fraction: 1);
      const b = PrismScaleSegment(id: 's', fraction: 1);
      const c = PrismScaleSegment(id: 's', fraction: 2);
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    testWidgets('empty segments still render label safely', (tester) async {
      await tester.pumpWidget(
        harness(label: '0 m', segments: const <PrismScaleSegment>[]),
      );

      expect(find.text('0 m'), findsOneWidget);
      expect(find.byKey(PrismScaleMeasureBar.barRegionKey), findsOneWidget);
    });
  });
}
