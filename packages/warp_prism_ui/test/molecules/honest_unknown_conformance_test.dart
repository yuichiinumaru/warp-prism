// Honest-unknown + abstention conformance suite (Task 1869, F-02).
//
// EXPERIMENTAL vocabulary: proves the fail-closed rule — an indeterminate
// ADS state must NEVER render as success, enabled, or verified — plus
// determinism (indeterminate states excluded from golden capture) and
// accessibility announcements for unknown surfaces.
//
// Failing-first provenance: written before the `DSStateType.unknown`
// extension existed (Red), turned green by the implementation.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/src/atoms/atoms.dart';
import 'package:warp_prism_ui/src/molecules/molecules.dart';
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
  group('honest unknown vocabulary exists (ADS)', () {
    test('DSStateType declares unknown alongside the seven proven states', () {
      expect(DSStateType.values, contains(DSStateType.unknown));
      expect(DSStateType.values.length, equals(8));
    });

    test('unknown is the only indeterminate ADS state', () {
      expect(DSStateType.unknown.isIndeterminate, isTrue);
      for (final state in DSStateType.values) {
        if (state == DSStateType.unknown) continue;
        expect(
          state.isIndeterminate,
          isFalse,
          reason: '$state must stay determinate',
        );
      }
      expect(
        DSStateTypeHonestUnknown.indeterminateValues,
        equals({DSStateType.unknown}),
      );
    });

    test('DSStateSurface.unknown constructor exists with safe defaults', () {
      const surface = DSStateSurface.unknown(title: 'Sync status unclear');
      expect(surface.stateType, equals(DSStateType.unknown));
      // Fail-closed default: no affirmative action label.
      expect(surface.actionLabel, isNull);
    });
  });

  group('fail-closed: unknown never renders as success', () {
    testWidgets('unknown icon color is neutral, never success green', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapInApp(const DSStateSurface.unknown(title: 'Unclear')),
      );

      final icon = tester.widget<DSIcon>(find.byType(DSIcon));
      expect(
        icon.color,
        equals(DSColors.statusUnknown),
        reason: 'unknown must use the neutral unknown token',
      );
      expect(icon.color, isNot(equals(DSColors.statusSuccess)));
      expect(icon.color, isNot(equals(DSColors.statusApproved)));
      expect(icon.color, isNot(equals(DSColors.statusHealthy)));
    });

    testWidgets('unknown renders a question mark, never a success check', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapInApp(const DSStateSurface.unknown(title: 'Unclear')),
      );

      expect(find.byIcon(Icons.help_outline), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsNothing);
      expect(find.byIcon(Icons.verified), findsNothing);
    });
  });

  group('fail-closed: unknown never renders as enabled', () {
    testWidgets('unknown uses no action accent and no progress affordance', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapInApp(const DSStateSurface.unknown(title: 'Unclear')),
      );

      final icon = tester.widget<DSIcon>(find.byType(DSIcon));
      // Enabled/actionable surfaces use the action accent; unknown must not.
      expect(icon.color, isNot(equals(DSColors.accentBlue)));
      // Unknown is indeterminate, not in-flight: no spinner, no animation.
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('unknown carries no affirmative action by default', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapInApp(const DSStateSurface.unknown(title: 'Unclear')),
      );

      expect(find.byType(OutlinedButton), findsNothing);
      expect(find.text('Retry'), findsNothing);
      expect(find.text('Refresh'), findsNothing);
    });
  });

  group('fail-closed: unknown never renders as verified', () {
    testWidgets('unknown semantics announce indeterminacy, never verified', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        wrapInApp(const DSStateSurface.unknown(title: 'Sync status unclear')),
      );

      final semantics = tester.getSemantics(find.byType(DSStateSurface));
      expect(semantics.label, contains('Unknown'));
      expect(semantics.label, contains('not yet determined'));
      expect(semantics.label, isNot(contains('Success')));
      expect(semantics.label, isNot(contains('Verified')));
      expect(semantics.label, isNot(contains('Enabled')));
      handle.dispose();
    });

    testWidgets('unknown is announced via live region; determinate is not', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        wrapInApp(const DSStateSurface.unknown(title: 'Unclear')),
      );
      expect(
        tester
            .getSemantics(find.byType(DSStateSurface))
            .flagsCollection
            .isLiveRegion,
        isTrue,
        reason: 'unknown must raise an announcement when it appears',
      );

      await tester.pumpWidget(
        wrapInApp(const DSStateSurface.error(title: 'Failed')),
      );
      expect(
        tester
            .getSemantics(find.byType(DSStateSurface))
            .flagsCollection
            .isLiveRegion,
        isFalse,
      );
      handle.dispose();
    });
  });

  group('determinism: indeterminate states excluded from goldens', () {
    test('no golden test captures an indeterminate state', () {
      final candidates = [
        Directory('test/goldens'),
        Directory('packages/warp_prism_ui/test/goldens'),
      ];
      final goldensDir = candidates.firstWhere(
        (d) => d.existsSync(),
        orElse: () => candidates.first,
      );
      expect(
        goldensDir.existsSync(),
        isTrue,
        reason: 'run from warp-prism root or packages/warp_prism_ui',
      );
      final offenders = <String>[];
      final indeterminate = RegExp(r'\bunknown\b', caseSensitive: false);
      for (final file
          in goldensDir
              .listSync(recursive: false)
              .whereType<File>()
              .where((f) => f.path.endsWith('_test.dart'))) {
        if (indeterminate.hasMatch(file.readAsStringSync())) {
          offenders.add(file.path);
        }
      }
      expect(
        offenders,
        isEmpty,
        reason:
            'indeterminate states must stay out of golden capture: $offenders',
      );
    });
  });

  group('host sweep: unknown renders across sections without errors', () {
    for (final size in [
      const Size(320, 568),
      const Size(768, 1024),
      const Size(1440, 900),
    ]) {
      for (final compact in [false, true]) {
        testWidgets(
          'unknown ${compact ? 'compact' : 'regular'} at ${size.width.toInt()}x${size.height.toInt()}',
          (tester) async {
            await tester.binding.setSurfaceSize(size);
            addTearDown(() => tester.binding.setSurfaceSize(null));
            await tester.pumpWidget(
              wrapInApp(
                DSStateSurface.unknown(
                  title: 'Sync status unclear',
                  compact: compact,
                ),
              ),
            );
            expect(find.text('Sync status unclear'), findsOneWidget);
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  });
}
