// Provenance + witness conformance suite (Task 1872, F-05).
//
// EXPERIMENTAL atoms: DSProvenanceBadge (canonicity) + DSWitnessBadge
// (opaque hash + verified/unverified/mismatched/unknown + sealed mode).
// No hashing, fingerprinting, or verification logic in Prism — hashes
// arrive opaque from the consumer and are display-truncated by a fixed rule.
//
// Failing-first provenance: written before the atoms exist (Red), turned
// green by the implementation.
//
// Trust invariants (suite-proven):
//  1. unverified-never-verified — every non-verified witness state is
//     visually distinct (color AND icon AND semantics) from verified.
//  2. sealed-absence-of-affordance — sealed mode renders zero interactive
//     affordances even when callbacks are supplied.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/src/atoms/ds_provenance_badge.dart';
import 'package:warp_prism_ui/src/atoms/ds_witness_badge.dart';
import 'package:warp_prism_ui/src/molecules/ds_state_surface.dart';
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
  group('provenance badge vocabulary (canonicity atom)', () {
    test(
      'all six canonicalities resolve to distinct pill-consistent colors',
      () {
        const cases = <String, Color>{
          'parentcanonical': DSColors.governanceCanonical,
          'childlocal': DSColors.governanceLocal,
          'generated': DSColors.governanceGenerated,
          'appendonly': DSColors.governanceAppendOnly,
          'archive': DSColors.governanceArchive,
          'mock': DSColors.governanceMock,
        };
        for (final entry in cases.entries) {
          const badge = DSProvenanceBadge(canonicality: 'parentcanonical');
          expect(badge.colorFor(entry.key), equals(entry.value));
        }
      },
    );

    testWidgets('canonical badge renders icon plus label', (tester) async {
      await tester.pumpWidget(
        wrapInApp(const DSProvenanceBadge(canonicality: 'parentcanonical')),
      );
      expect(find.text('Canonical'), findsOneWidget);
      expect(find.byType(DSProvenanceBadge), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('unknown canonicality falls back without crashing', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapInApp(const DSProvenanceBadge(canonicality: 'someday')),
      );
      expect(find.text('someday'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('witness vocabulary exists', () {
    test('four witness states declared', () {
      expect(
        DSWitnessState.values,
        containsAll([
          DSWitnessState.verified,
          DSWitnessState.unverified,
          DSWitnessState.mismatched,
          DSWitnessState.unknown,
        ]),
      );
      expect(DSWitnessState.values.length, equals(4));
    });

    test('render modes are open and sealed', () {
      expect(
        DSWitnessRenderMode.values,
        equals([DSWitnessRenderMode.open, DSWitnessRenderMode.sealed]),
      );
    });

    test('unknown is the only indeterminate witness state', () {
      expect(DSWitnessState.unknown.isIndeterminate, isTrue);
      for (final state in DSWitnessState.values) {
        if (state == DSWitnessState.unknown) continue;
        expect(state.isIndeterminate, isFalse);
      }
    });

    test('unknown consumes the frozen 1869 interface (still fail-closed)', () {
      // Task 1869 frozen contract: unknown withholds determination.
      expect(DSStateType.unknown.isIndeterminate, isTrue);
      expect(DSColors.statusUnknown, equals(DSColors.textTertiary));
    });
  });

  group('INVARIANT 1: unverified-never-verified', () {
    test('every non-verified state color differs from verified color', () {
      const witness = DSWitnessBadge(
        hashDisplay: 'abc123',
        state: DSWitnessState.verified,
      );
      final verifiedColor = witness.colorFor(DSWitnessState.verified);
      expect(verifiedColor, equals(DSColors.statusSuccess));
      for (final state in [
        DSWitnessState.unverified,
        DSWitnessState.mismatched,
        DSWitnessState.unknown,
      ]) {
        expect(
          witness.colorFor(state),
          isNot(equals(verifiedColor)),
          reason: '$state must be visually distinct from verified',
        );
      }
    });

    test('every non-verified state icon differs from the verified icon', () {
      const witness = DSWitnessBadge(
        hashDisplay: 'abc123',
        state: DSWitnessState.verified,
      );
      final verifiedIcon = witness.iconFor(DSWitnessState.verified);
      for (final state in [
        DSWitnessState.unverified,
        DSWitnessState.mismatched,
        DSWitnessState.unknown,
      ]) {
        expect(
          witness.iconFor(state),
          isNot(equals(verifiedIcon)),
          reason: '$state icon must differ from the verified check',
        );
      }
    });

    testWidgets('non-verified semantics never claim Verified', (tester) async {
      final handle = tester.ensureSemantics();
      for (final state in DSWitnessState.values) {
        await tester.pumpWidget(
          wrapInApp(DSWitnessBadge(hashDisplay: 'abc123', state: state)),
        );
        final semantics = tester.getSemantics(find.byType(DSWitnessBadge));
        if (state == DSWitnessState.verified) {
          expect(semantics.label, contains('Verified'));
        } else {
          expect(
            semantics.label,
            isNot(contains('Verified')),
            reason: '$state semantics must never claim Verified',
          );
        }
      }
      handle.dispose();
    });

    testWidgets('verified renders the verified check; others never do', (
      tester,
    ) async {
      for (final state in DSWitnessState.values) {
        await tester.pumpWidget(
          wrapInApp(DSWitnessBadge(hashDisplay: 'abc123', state: state)),
        );
        expect(
          find.byIcon(Icons.verified),
          state == DSWitnessState.verified ? findsOneWidget : findsNothing,
          reason: '$state verified-icon presence',
        );
      }
    });

    testWidgets('unknown witness announces indeterminacy via live region', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        wrapInApp(
          const DSWitnessBadge(
            hashDisplay: 'abc123',
            state: DSWitnessState.unknown,
          ),
        ),
      );
      final semantics = tester.getSemantics(find.byType(DSWitnessBadge));
      expect(semantics.label, contains('not yet determined'));
      expect(
        semantics.flagsCollection.isLiveRegion,
        isTrue,
        reason: 'unknown witness must raise an announcement when it appears',
      );
      handle.dispose();
    });
  });

  group('INVARIANT 2: sealed-absence-of-affordance', () {
    testWidgets('sealed renders zero interactive affordances', (tester) async {
      var tapped = 0;
      void bump() => tapped++;
      await tester.pumpWidget(
        wrapInApp(
          DSWitnessBadge(
            hashDisplay: 'abc123def456',
            state: DSWitnessState.verified,
            renderMode: DSWitnessRenderMode.sealed,
            onCopy: bump,
            onReverify: bump,
            onReresolve: bump,
          ),
        ),
      );
      expect(find.byType(IconButton), findsNothing);
      expect(find.byType(TextButton), findsNothing);
      expect(find.byType(ElevatedButton), findsNothing);
      expect(find.byType(OutlinedButton), findsNothing);
      expect(find.byType(InkWell), findsNothing);
      expect(find.byType(GestureDetector), findsNothing);
      expect(tapped, equals(0));
      expect(tester.takeException(), isNull);
    });

    testWidgets('sealed hides affordances for every witness state', (
      tester,
    ) async {
      for (final state in DSWitnessState.values) {
        await tester.pumpWidget(
          wrapInApp(
            DSWitnessBadge(
              hashDisplay: 'abc123def456',
              state: state,
              renderMode: DSWitnessRenderMode.sealed,
              onCopy: () {},
              onReverify: () {},
              onReresolve: () {},
            ),
          ),
        );
        expect(find.byType(IconButton), findsNothing, reason: '$state sealed');
        expect(
          find.byType(GestureDetector),
          findsNothing,
          reason: '$state sealed',
        );
      }
    });

    testWidgets('open mode renders exactly the supplied affordances', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapInApp(
          DSWitnessBadge(
            hashDisplay: 'abc123',
            state: DSWitnessState.unverified,
            onCopy: () {},
            onReverify: () {},
          ),
        ),
      );
      expect(find.byTooltip('Copy hash'), findsOneWidget);
      expect(find.byTooltip('Re-verify'), findsOneWidget);
      expect(find.byTooltip('Re-resolve'), findsNothing);
    });

    testWidgets('open affordances invoke their callbacks', (tester) async {
      var copied = 0;
      await tester.pumpWidget(
        wrapInApp(
          DSWitnessBadge(
            hashDisplay: 'abc123',
            state: DSWitnessState.unverified,
            onCopy: () => copied++,
          ),
        ),
      );
      await tester.tap(find.byTooltip('Copy hash'));
      expect(copied, equals(1));
    });
  });

  group('determinism: fixed opaque-hash truncation, no layout dependence', () {
    test('short hashes render in full', () {
      expect(DSWitnessBadge.displayFor('abc123'), equals('abc123'));
    });

    test('long hashes truncate by the fixed 8…4 rule', () {
      expect(
        DSWitnessBadge.displayFor('0123456789abcdef'),
        equals('01234567…cdef'),
      );
    });

    test('truncation is a pure function of input (deterministic)', () {
      const input = 'deadbeefcafe0123feed';
      expect(
        DSWitnessBadge.displayFor(input),
        equals(DSWitnessBadge.displayFor(input)),
      );
    });

    testWidgets('identical input renders identically across viewports', (
      tester,
    ) async {
      for (final size in [
        const Size(320, 568),
        const Size(768, 1024),
        const Size(1440, 900),
      ]) {
        await tester.binding.setSurfaceSize(size);
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.pumpWidget(
          wrapInApp(
            const DSWitnessBadge(
              hashDisplay: '0123456789abcdef',
              state: DSWitnessState.verified,
            ),
          ),
        );
        expect(find.text('01234567…cdef'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });
  });

  group('host sweep: witnessed plus sealed states render without errors', () {
    for (final size in [
      const Size(320, 568),
      const Size(768, 1024),
      const Size(1440, 900),
    ]) {
      for (final state in DSWitnessState.values) {
        for (final mode in DSWitnessRenderMode.values) {
          testWidgets(
            '${state.name} ${mode.name} at ${size.width.toInt()}x${size.height.toInt()}',
            (tester) async {
              await tester.binding.setSurfaceSize(size);
              addTearDown(() => tester.binding.setSurfaceSize(null));
              await tester.pumpWidget(
                wrapInApp(
                  DSWitnessBadge(
                    hashDisplay: '0123456789abcdef',
                    state: state,
                    renderMode: mode,
                    onCopy: () {},
                    onReverify: () {},
                    onReresolve: () {},
                  ),
                ),
              );
              expect(find.byType(DSWitnessBadge), findsOneWidget);
              expect(tester.takeException(), isNull);
            },
          );
        }
      }
    }
  });
}
