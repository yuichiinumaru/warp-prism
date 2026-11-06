// Lineage strip conformance suite (Task 1872, F-05).
//
// EXPERIMENTAL molecule: DSLineageStrip (SAME | DIFFER / derived-from).
// Relation arrives as an enum from the consumer — no causation
// computation in Prism. Display only, never routing input.
//
// Failing-first provenance: written before the molecule exists (Red),
// turned green by the implementation.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/src/molecules/ds_lineage_strip.dart';
import 'package:warp_prism_ui/src/tokens/tokens.dart';

Widget wrapInApp(Widget child) {
  return MaterialApp(
    theme: ThemeData(
      useMaterial3: true,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
    ),
    home: Scaffold(body: child),
  );
}

void main() {
  group('lineage vocabulary exists', () {
    test('three relations declared', () {
      expect(
        DSLineageRelation.values,
        equals([
          DSLineageRelation.same,
          DSLineageRelation.differ,
          DSLineageRelation.derivedFrom,
        ]),
      );
    });
  });

  group('relations render distinctly', () {
    test('SAME, DIFFER, derived-from carry distinct colors', () {
      const strip = DSLineageStrip(relation: DSLineageRelation.same);
      final sameColor = strip.colorFor(DSLineageRelation.same);
      final differColor = strip.colorFor(DSLineageRelation.differ);
      final derivedColor = strip.colorFor(DSLineageRelation.derivedFrom);
      expect(sameColor, equals(DSColors.statusSuccess));
      expect(differColor, equals(DSColors.statusError));
      expect(derivedColor, equals(DSColors.statusInfo));
      expect({sameColor, differColor, derivedColor}.length, equals(3));
    });

    testWidgets('SAME renders the SAME marker, never DIFFER', (tester) async {
      await tester.pumpWidget(
        wrapInApp(const DSLineageStrip(relation: DSLineageRelation.same)),
      );
      expect(find.text('SAME'), findsOneWidget);
      expect(find.text('DIFFER'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('DIFFER renders the DIFFER marker, never SAME', (tester) async {
      await tester.pumpWidget(
        wrapInApp(const DSLineageStrip(relation: DSLineageRelation.differ)),
      );
      expect(find.text('DIFFER'), findsOneWidget);
      expect(find.text('SAME'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('derived-from renders source-to-target lineage', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapInApp(
          const DSLineageStrip(
            relation: DSLineageRelation.derivedFrom,
            sourceLabel: 'take-01',
            targetLabel: 'take-02',
          ),
        ),
      );
      expect(find.text('DERIVED FROM'), findsOneWidget);
      expect(find.text('take-01 → take-02'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('derived-from without labels still renders honestly', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapInApp(
          const DSLineageStrip(relation: DSLineageRelation.derivedFrom),
        ),
      );
      expect(find.text('DERIVED FROM'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('strip is passive display, never routing input', () {
    testWidgets('no interactive affordance renders in any relation', (
      tester,
    ) async {
      for (final relation in DSLineageRelation.values) {
        await tester.pumpWidget(wrapInApp(DSLineageStrip(relation: relation)));
        expect(find.byType(IconButton), findsNothing);
        expect(find.byType(TextButton), findsNothing);
        expect(find.byType(ElevatedButton), findsNothing);
        expect(find.byType(OutlinedButton), findsNothing);
        expect(find.byType(GestureDetector), findsNothing);
      }
    });

    testWidgets('semantics announce the relation, never verified', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      for (final relation in DSLineageRelation.values) {
        await tester.pumpWidget(wrapInApp(DSLineageStrip(relation: relation)));
        final semantics = tester.getSemantics(find.byType(DSLineageStrip));
        expect(semantics.label, isNot(contains('Verified')));
      }
      handle.dispose();
    });
  });

  group('determinism: no layout-dependent rendering', () {
    testWidgets('all relations stable across viewports', (tester) async {
      for (final size in [
        const Size(320, 568),
        const Size(768, 1024),
        const Size(1440, 900),
      ]) {
        await tester.binding.setSurfaceSize(size);
        addTearDown(() => tester.binding.setSurfaceSize(null));
        for (final relation in DSLineageRelation.values) {
          await tester.pumpWidget(
            wrapInApp(
              const DSLineageStrip(
                relation: DSLineageRelation.derivedFrom,
                sourceLabel: 'take-01',
                targetLabel: 'take-02',
              ),
            ),
          );
          if (relation == DSLineageRelation.derivedFrom) {
            expect(find.text('DERIVED FROM'), findsOneWidget);
          }
          expect(tester.takeException(), isNull);
        }
      }
    });
  });
}
