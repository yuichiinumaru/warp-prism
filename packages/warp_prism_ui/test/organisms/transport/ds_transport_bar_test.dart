// Conformance + widget suite for the transport seam (Task 1875, F-08).
//
// Proves: organism + badges render from injected models/formatters; step
// behavior emits the caller-supplied signed step size; disabled states flow
// through Task 1868's frozen token-side interface (DSActionAuthority —
// consumed, never duplicated); formatter determinism (same input yields the
// same string, no wall-clock in rendering); slots render caller widgets
// verbatim; a11y labels + 48dp targets; headless viewport/text-scale sweep.
//
// EXPERIMENTAL: imports via src paths; no barrel export yet.
// Run: flutter test packages/warp_prism_ui/test/organisms/transport/ds_transport_bar_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/src/atoms/ds_timebase_badge.dart';
import 'package:warp_prism_ui/src/atoms/ds_timecode_badge.dart';
import 'package:warp_prism_ui/src/organisms/transport_bar/ds_transport_bar.dart';
import 'package:warp_prism_ui/src/tokens/ds_action_authority.dart';

// --- Reference (caller-side) formatters: the fake for this seam. ---------
//
// Prism ships no formatter; these live in the test to prove the widgets
// render whatever the caller injects, deterministically.

String referenceFormatTime(double position, double duration) =>
    '${position.toStringAsFixed(2)} / ${duration.toStringAsFixed(2)}';

String referenceFormatRange(double start, double end) =>
    '[${start.toStringAsFixed(2)}, ${end.toStringAsFixed(2)})';

String referenceFormatTimebase() => '30/1 fps';

Widget wrapTest(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('transport_1875 readout renders injected formatters', () {
    testWidgets('position/duration readout uses formatTime verbatim', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapTest(
          const DSTransportBar(
            positionSeconds: 1.5,
            durationSeconds: 4.0,
            formatTime: referenceFormatTime,
            formatRange: referenceFormatRange,
          ),
        ),
      );

      expect(find.text('1.50 / 4.00'), findsOneWidget);
    });

    testWidgets('visible range renders through formatRange', (tester) async {
      await tester.pumpWidget(
        wrapTest(
          const DSTransportBar(
            positionSeconds: 1.5,
            durationSeconds: 4.0,
            formatTime: referenceFormatTime,
            formatRange: referenceFormatRange,
            visibleRange: DSTransportRange(startSeconds: 0.0, endSeconds: 4.0),
          ),
        ),
      );

      expect(find.text('[0.00, 4.00)'), findsOneWidget);
    });

    testWidgets('absent range hides the range readout', (tester) async {
      await tester.pumpWidget(
        wrapTest(
          const DSTransportBar(
            positionSeconds: 1.5,
            durationSeconds: 4.0,
            formatTime: referenceFormatTime,
            formatRange: referenceFormatRange,
          ),
        ),
      );

      expect(find.byKey(DSTransportBar.rangeKey), findsNothing);
    });

    testWidgets('same inputs rebuild to the same strings (determinism)', (
      tester,
    ) async {
      var position = 2.25;
      await tester.pumpWidget(
        wrapTest(
          DSTransportBar(
            positionSeconds: position,
            durationSeconds: 8.0,
            formatTime: referenceFormatTime,
            formatRange: referenceFormatRange,
            visibleRange: const DSTransportRange(
              startSeconds: 0.0,
              endSeconds: 8.0,
            ),
          ),
        ),
      );
      expect(find.text('2.25 / 8.00'), findsOneWidget);

      // Rebuild with identical inputs: identical strings, no clock involved.
      position = 2.25;
      await tester.pumpWidget(
        wrapTest(
          DSTransportBar(
            positionSeconds: position,
            durationSeconds: 8.0,
            formatTime: referenceFormatTime,
            formatRange: referenceFormatRange,
            visibleRange: const DSTransportRange(
              startSeconds: 0.0,
              endSeconds: 8.0,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('2.25 / 8.00'), findsOneWidget);
      expect(find.text('[0.00, 8.00)'), findsOneWidget);
    });
  });

  group('transport_1875 formatter determinism (pure functions)', () {
    test('same time input yields the same string', () {
      final first = referenceFormatTime(1.5, 4.0);
      final second = referenceFormatTime(1.5, 4.0);
      expect(first, '1.50 / 4.00');
      expect(second, first);
    });

    test('same range input yields the same string', () {
      expect(referenceFormatRange(0.0, 4.0), referenceFormatRange(0.0, 4.0));
    });

    test('distinct inputs yield distinct strings', () {
      expect(
        referenceFormatTime(1.5, 4.0),
        isNot(referenceFormatTime(2.5, 4.0)),
      );
    });
  });

  group('transport_1875 step behavior (caller step size)', () {
    testWidgets('step back emits the negative caller step size', (
      tester,
    ) async {
      final deltas = <double>[];
      await tester.pumpWidget(
        wrapTest(
          DSTransportBar(
            positionSeconds: 5.0,
            durationSeconds: 10.0,
            formatTime: referenceFormatTime,
            formatRange: referenceFormatRange,
            stepSizeSeconds: 0.25,
            onStep: deltas.add,
          ),
        ),
      );

      await tester.tap(find.byKey(DSTransportBar.stepBackKey));
      await tester.pump();
      expect(deltas, [-0.25]);
    });

    testWidgets('step forward emits the positive caller step size', (
      tester,
    ) async {
      final deltas = <double>[];
      await tester.pumpWidget(
        wrapTest(
          DSTransportBar(
            positionSeconds: 5.0,
            durationSeconds: 10.0,
            formatTime: referenceFormatTime,
            formatRange: referenceFormatRange,
            stepSizeSeconds: 2.0,
            onStep: deltas.add,
          ),
        ),
      );

      await tester.tap(find.byKey(DSTransportBar.stepForwardKey));
      await tester.pump();
      expect(deltas, [2.0]);
    });

    testWidgets('play toggles through onTogglePlay with caller labels', (
      tester,
    ) async {
      var toggles = 0;
      await tester.pumpWidget(
        wrapTest(
          DSTransportBar(
            positionSeconds: 0.0,
            durationSeconds: 10.0,
            formatTime: referenceFormatTime,
            formatRange: referenceFormatRange,
            isPlaying: false,
            playLabel: 'Reprozir',
            pauseLabel: 'Pausar',
            onTogglePlay: () => toggles++,
          ),
        ),
      );

      expect(find.byTooltip('Reprozir'), findsOneWidget);
      await tester.tap(find.byKey(DSTransportBar.playPauseKey));
      await tester.pump();
      expect(toggles, 1);
    });

    testWidgets('playing state selects the pause affordance', (tester) async {
      await tester.pumpWidget(
        wrapTest(
          DSTransportBar(
            positionSeconds: 0.0,
            durationSeconds: 10.0,
            formatTime: referenceFormatTime,
            formatRange: referenceFormatRange,
            isPlaying: true,
            onTogglePlay: () {},
          ),
        ),
      );

      expect(find.byTooltip('Pause'), findsOneWidget);
      expect(find.byIcon(Icons.pause), findsOneWidget);
    });
  });

  group(
    'transport_1875 disabled states via DSActionAuthority (1868 reuse)',
    () {
      testWidgets('denied step stays mounted with reason, never dispatches', (
        tester,
      ) async {
        final deltas = <double>[];
        String? refused;
        await tester.pumpWidget(
          wrapTest(
            DSTransportBar(
              positionSeconds: 5.0,
              durationSeconds: 10.0,
              formatTime: referenceFormatTime,
              formatRange: referenceFormatRange,
              onStep: deltas.add,
              onRefused: (reason) => refused = reason,
              stepBackAuthority: DSActionAuthority.deny,
              stepBackReason: 'At session start',
            ),
          ),
        );

        // Denied control is never hidden: button AND reason both visible.
        expect(find.byKey(DSTransportBar.stepBackKey), findsOneWidget);
        expect(find.textContaining('At session start'), findsWidgets);
        await tester.tap(find.byKey(DSTransportBar.stepBackKey));
        await tester.pump();
        expect(deltas, isEmpty);
        expect(refused, 'At session start');
      });

      testWidgets('denied play announces outcome plus reason', (tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          wrapTest(
            const DSTransportBar(
              positionSeconds: 0.0,
              durationSeconds: 10.0,
              formatTime: referenceFormatTime,
              formatRange: referenceFormatRange,
              playAuthority: DSActionAuthority.deny,
              playReason: 'No transport capability',
            ),
          ),
        );

        final semantics = tester.getSemantics(
          find.byKey(DSTransportBar.playPauseKey),
        );
        expect(semantics.label, contains('Play'));
        expect(semantics.label, contains('Denied'));
        expect(semantics.label, contains('No transport capability'));
        handle.dispose();
      });

      testWidgets('constrained step dispatches with its limitation visible', (
        tester,
      ) async {
        final deltas = <double>[];
        await tester.pumpWidget(
          wrapTest(
            DSTransportBar(
              positionSeconds: 5.0,
              durationSeconds: 10.0,
              formatTime: referenceFormatTime,
              formatRange: referenceFormatRange,
              onStep: deltas.add,
              stepForwardAuthority: DSActionAuthority.constrain,
              stepForwardReason: 'Near session end',
            ),
          ),
        );

        expect(find.textContaining('Near session end'), findsWidgets);
        await tester.tap(find.byKey(DSTransportBar.stepForwardKey));
        await tester.pump();
        expect(deltas, [0.25]);
      });

      testWidgets(
        'allowed controls dispatch and carry the allow announcement',
        (tester) async {
          final handle = tester.ensureSemantics();
          var toggles = 0;
          await tester.pumpWidget(
            wrapTest(
              DSTransportBar(
                positionSeconds: 0.0,
                durationSeconds: 10.0,
                formatTime: referenceFormatTime,
                formatRange: referenceFormatRange,
                onTogglePlay: () => toggles++,
              ),
            ),
          );

          final semantics = tester.getSemantics(
            find.byKey(DSTransportBar.playPauseKey),
          );
          expect(semantics.label, contains('Allowed'));
          await tester.tap(find.byKey(DSTransportBar.playPauseKey));
          await tester.pump();
          expect(toggles, 1);
          handle.dispose();
        },
      );
    },
  );

  group('transport_1875 caller slots render verbatim', () {
    testWidgets('record/loop/metronome/tempo slots compose', (tester) async {
      await tester.pumpWidget(
        wrapTest(
          const DSTransportBar(
            positionSeconds: 0.0,
            durationSeconds: 10.0,
            formatTime: referenceFormatTime,
            formatRange: referenceFormatRange,
            recordSlot: Text('REC-SLOT'),
            loopSlot: Text('LOOP-SLOT'),
            metronomeSlot: Text('MET-SLOT'),
            tempoSlot: Text('TEMPO-SLOT'),
          ),
        ),
      );

      expect(find.text('REC-SLOT'), findsOneWidget);
      expect(find.text('LOOP-SLOT'), findsOneWidget);
      expect(find.text('MET-SLOT'), findsOneWidget);
      expect(find.text('TEMPO-SLOT'), findsOneWidget);
    });
  });

  group('transport_1875 badges render injected strings only', () {
    testWidgets('timecode badge renders formatTime output', (tester) async {
      await tester.pumpWidget(
        wrapTest(
          const DSTimecodeBadge(
            positionSeconds: 1.5,
            durationSeconds: 4.0,
            formatTime: referenceFormatTime,
          ),
        ),
      );

      expect(find.text('1.50 / 4.00'), findsOneWidget);
    });

    testWidgets('timecode badge renders opaque strings without parsing', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapTest(
          DSTimecodeBadge(
            positionSeconds: 0.0,
            durationSeconds: 0.0,
            formatTime: (_, _) => 'not-a-time',
          ),
        ),
      );

      // No time ontology: even a non-temporal string renders verbatim.
      expect(find.text('not-a-time'), findsOneWidget);
    });

    testWidgets('timebase badge renders the caller timebase string', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapTest(
          const DSTimebaseBadge(formatTimebase: referenceFormatTimebase),
        ),
      );

      expect(find.text('30/1 fps'), findsOneWidget);
    });

    testWidgets('timebase badge announces its label', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        wrapTest(
          const DSTimebaseBadge(formatTimebase: referenceFormatTimebase),
        ),
      );

      final semantics = tester.getSemantics(find.byType(DSTimebaseBadge));
      expect(semantics.label, contains('Timebase'));
      expect(semantics.label, contains('30/1 fps'));
      handle.dispose();
    });
  });

  group('transport_1875 touch targets and region semantics', () {
    testWidgets('every control keeps a minimum 48x48 target', (tester) async {
      await tester.pumpWidget(
        wrapTest(
          const DSTransportBar(
            positionSeconds: 0.0,
            durationSeconds: 10.0,
            formatTime: referenceFormatTime,
            formatRange: referenceFormatRange,
            playAuthority: DSActionAuthority.deny,
            playReason: 'Locked',
          ),
        ),
      );

      for (final key in [
        DSTransportBar.playPauseKey,
        DSTransportBar.stepBackKey,
        DSTransportBar.stepForwardKey,
      ]) {
        final size = tester.getSize(find.byKey(key));
        expect(size.width, greaterThanOrEqualTo(48), reason: '$key width');
        expect(size.height, greaterThanOrEqualTo(48), reason: '$key height');
      }
    });

    testWidgets('bar region carries its semantic label', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        wrapTest(
          const DSTransportBar(
            positionSeconds: 0.0,
            durationSeconds: 10.0,
            formatTime: referenceFormatTime,
            formatRange: referenceFormatRange,
            semanticLabel: 'Studio transport',
          ),
        ),
      );

      final semantics = tester.getSemantics(
        find.byKey(DSTransportBar.barRegionKey),
      );
      expect(semantics.label, contains('Studio transport'));
      handle.dispose();
    });
  });

  group('transport_1875 headless host sweep (AGENTS 7.1 fallback)', () {
    // Real-host exercise (Warpblade + Tempest studio routes) is unavailable
    // from this workspace: sibling checkouts sit outside the authorized
    // filesystem boundary (read attempts return permission.rejected), and
    // launching real windows is forbidden on this operator session. This
    // sweep proves compositional robustness headlessly across representative
    // viewports and text scales instead, and records the limitation. See the
    // Worker Handoff Packet for the exact limitation.
    const viewports = [Size(360, 640), Size(800, 600), Size(1920, 1080)];
    const textScales = [1.0, 2.0];

    for (final viewport in viewports) {
      for (final textScale in textScales) {
        testWidgets('bar composes without framework errors '
            'at ${viewport.width}x${viewport.height} @${textScale}x', (
          tester,
        ) async {
          final errors = <FlutterErrorDetails>[];
          final previousOnError = FlutterError.onError;
          FlutterError.onError = errors.add;

          try {
            tester.view.physicalSize = viewport;
            tester.view.devicePixelRatio = 1.0;

            await tester.pumpWidget(
              MediaQuery(
                data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
                child: wrapTest(
                  const DSTransportBar(
                    positionSeconds: 65.5,
                    durationSeconds: 240.0,
                    formatTime: referenceFormatTime,
                    formatRange: referenceFormatRange,
                    visibleRange: DSTransportRange(
                      startSeconds: 0.0,
                      endSeconds: 240.0,
                    ),
                    stepForwardAuthority: DSActionAuthority.deny,
                    stepForwardReason: 'Sweep denial reason',
                    recordSlot: Text('REC'),
                    loopSlot: Text('LOOP'),
                    metronomeSlot: Text('MET'),
                    tempoSlot: DSTimebaseBadge(
                      formatTimebase: referenceFormatTimebase,
                    ),
                  ),
                ),
              ),
            );
            await tester.pump();
          } finally {
            FlutterError.onError = previousOnError;
            tester.view.reset();
          }

          expect(find.text('65.50 / 240.00'), findsOneWidget);
          expect(find.text('[0.00, 240.00)'), findsOneWidget);
          expect(find.text('30/1 fps'), findsOneWidget);
          expect(find.textContaining('Sweep denial reason'), findsWidgets);
          expect(
            errors,
            isEmpty,
            reason: 'framework errors during headless sweep: $errors',
          );
        });
      }
    }
  });
}
