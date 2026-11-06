import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'gallery_test_oracle.dart';

/// Task 1843 — regression proof for the narrowed gallery suppressor.
///
/// The prior suppressor masked anything containing `overflow` / `RenderFlex`,
/// so the gallery suite could not fail on a layout error. These tests pin the
/// opposite contract, and the load-bearing one is deliberately able to fail: it
/// asserts that a real `RenderFlex` overflow reaches the handler the gallery
/// tests would have failed on.
///
/// Since the 2026-10-04 review (F1) the oracle is fail-closed with an empty
/// allow-list: the former benign-hint classes must now also propagate.
void main() {
  group('gallery suppressor allow-list (Task 1843)', () {
    test(
      'former benign Material debug hints are NO LONGER masked (fail-closed)',
      () {
        // Review finding F1 (2026-10-04): the live census proved zero
        // occurrences of either hint class across every exercised gallery
        // surface/viewport, so the masks were deleted. These strings must now
        // be NOT-masked — they propagate like any other framework message.
        for (final formerHint in <String>[
          'ListTile background color set to an opaque color.\n'
              'This is not allowed in debug mode.',
          'The ink splashes may be invisible under a translucent ink.\n'
              'Consider using an opaque background.',
        ]) {
          expect(
            isBenignGalleryFrameworkHint(formerHint),
            isFalse,
            reason: 'fail-closed oracle must not mask: $formerHint',
          );
        }
      },
    );

    test('does NOT mask layout-error classes', () {
      // These are the classes the old broad filter swallowed.
      for (final layoutError in <String>[
        'A RenderFlex overflowed by 200 pixels on the right.',
        'A RenderFlex overflowed by 12.00 pixels on the bottom.',
        'RenderFlex children have non-zero flex but incoming height constraints are unbounded.',
        'overflowed while laying out a dense fixture demo',
        'OVERFLOWING: RenderFlex#31ef5',
      ]) {
        expect(
          isBenignGalleryFrameworkHint(layoutError),
          isFalse,
          reason: 'layout errors must never be masked: $layoutError',
        );
      }
    });

    test('does not mask unrelated framework or assertion errors', () {
      for (final other in <String>[
        'Bad state: No element',
        'Null check operator used on a null value',
        'A Key was used in a Widget with the same GlobalKey',
        'setState() called after dispose()',
      ]) {
        expect(
          isBenignGalleryFrameworkHint(other),
          isFalse,
          reason: 'unrelated errors must never be masked: $other',
        );
      }
    });

    test('allow-list is empty (fail-closed oracle)', () {
      expect(
        kBenignGalleryFrameworkHints,
        isEmpty,
        reason:
            'F1 deleted the two former hint masks after the census proved zero '
            'occurrences. Any re-addition needs a stated reason plus live '
            'census evidence — never a widened substring pattern.',
      );
    });
  });

  group('suppressor pass-through is observable (the load-bearing test)', () {
    // These use `tester.takeException()` — flutter_test's own mechanism for
    // "did an error get reported" — rather than replacing `FlutterError.onError`
    // with a private collector. Overriding it directly would suppress the
    // binding's own pending-exception bookkeeping and make the binding assert
    // in teardown, so `takeException()` is both the correct and the only sound
    // observable here.
    //
    // Non-vacuity: `takeException()` returns non-null only if the error was
    // actually reported. Under the old broad `contains('overflow')` filter the
    // error was swallowed, `takeException()` returned null, and the
    // `isNotNull` expectation below would FAIL. That is the point.

    testWidgets(
      'a deliberately introduced RenderFlex overflow REACHES the handler, '
      'so the calling gallery test would fail',
      (tester) async {
        // Capture the outer handler so the suppressor scope can be ended
        // BEFORE asserting (review finding F2): if the oracle ever re-opens
        // the gap, the assertion below must fail as a single clean
        // TestFailure — not as a binding teardown cascade plus multi-minute
        // hang with the custom onError still installed.
        final outerOnError = FlutterError.onError;
        // The real suppressor the gallery suite installs.
        installGalleryBenignHintSuppressor();

        // Deliberate layout defect: 500 + 500 px children in an 800 px viewport.
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Row(
                children: <Widget>[
                  SizedBox(width: 500, child: Text('AAAAAAAAAA')),
                  SizedBox(width: 500, child: Text('BBBBBBBBBB')),
                ],
              ),
            ),
          ),
        );
        await tester.pump();

        final Object? reported = tester.takeException();

        // End the suppressor scope before asserting.
        FlutterError.onError = outerOnError;

        expect(
          reported,
          isNotNull,
          reason:
              'A real RenderFlex overflow must propagate to the calling test. '
              'If this fails, the suppressor has re-opened the oracle gap that '
              'Task 1843 closed.',
        );
        expect(
          reported.toString(),
          contains('A RenderFlex overflowed'),
          reason: 'the propagated error must be the layout defect itself',
        );
      },
    );

    testWidgets('former benign hints are NO LONGER swallowed (fail-closed)', (
      tester,
    ) async {
      final outerOnError = FlutterError.onError;
      installGalleryBenignHintSuppressor();

      FlutterError.reportError(
        FlutterErrorDetails(
          exception: StateError(
            'ListTile background color set to an opaque color.',
          ),
        ),
      );
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: StateError('The ink splashes may be invisible.'),
        ),
      );

      final Object? first = tester.takeException();
      // Drain any additional pending error so teardown stays clean.
      while (tester.takeException() != null) {}

      // End the suppressor scope before asserting (same F2 discipline as the
      // load-bearing test above).
      FlutterError.onError = outerOnError;

      expect(
        first,
        isNotNull,
        reason:
            'The fail-closed oracle must forward the former benign-hint '
            'classes to the calling test. If this fails, a mask has been '
            're-added without the census evidence the review delta requires.',
      );
    });
  });
}
