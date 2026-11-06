// Host-composition proof for the meter/fader seam (Task 1861, F-13,
// AGENTS.md §7.1).
//
// Exercises DSFaderStrip on two host-shaped routes in one composition: a
// Tempest-like studio route (channel strips with meter + fader + readout,
// mirroring `StemMixerChannelStrip` / `MasterBusStrip` in
// docs/bridge/tempest/ads-debt.md §1.2 rows 4/9) and a mixer route with a
// second strip plus a canvas-host placeholder. Covers: real named-route
// entry, at least one meaningful interaction per route (keyboard fader
// adjust, route push), zero framework errors, no ErrorWidget, no RenderFlex overflow,
// representative viewport/text-scale conditions, and theme/focus
// propagation via the shared Prism theme.
//
// LIMITATION (recorded): the real Tempest product host lives outside this
// workspace boundary (`/home/sephiroth/working/ganthritor/tempest`, sibling
// repo — read-only donor evidence here) and no display host was available
// in this environment, so this is a flutter_tester headless composition
// sweep against host-shaped routes with real named-route navigation — not
// execution inside the real Tempest host. Donor shapes are INHERITED
// REPORT: docs/bridge/tempest/ads-debt.md §1.1 rows 1–3 (meter/fader) and
// §1.2 rows 4/9 (channel strip / master bus).
// Run: flutter test packages/warp_prism_ui/test/molecules/meter_fader_host_composition_test.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/src/atoms/ds_canvas_host.dart';
import 'package:warp_prism_ui/src/atoms/ds_meter.dart';
import 'package:warp_prism_ui/src/molecules/ds_fader_strip.dart';
import 'package:warp_prism_ui/src/theme/ds_theme.dart';
import 'package:warp_prism_ui/src/tokens/tokens.dart';

/// Caller-side gain map: normalized fader to dB text (Tempest DbFader donor
/// posture — mapping stays caller-side, Prism renders it verbatim).
String _faderDb(double normalized) =>
    '${(normalized.clamp(0.0, 1.0) * 3.5).toStringAsFixed(1)} dB';

/// Tempest-like studio route: two channel strips sharing one injected scale.
///
/// Mirrors the StemMixerChannelStrip donor: channel name + peak meter +
/// volume control + numeric readout in one strip.
class StudioRoute extends StatelessWidget {
  final List<String> events;
  final FocusNode voxFaderFocus;
  final ValueChanged<double> onVoxFader;

  const StudioRoute({
    super.key,
    required this.events,
    required this.voxFaderFocus,
    required this.onVoxFader,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Studio')),
      body: SingleChildScrollView(
        // Horizontal scroll degrades to a scrollbar on narrow panes instead
        // of a RenderFlex overflow stripe (loading-trio GOLD rationale).
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DSFaderStrip(
                scale: dsMeterReferenceScale(),
                meterValue: -12.0,
                peakValue: -9.0,
                faderValue: 0.75,
                label: 'Vox',
                onFaderChanged: onVoxFader,
                formatFader: _faderDb,
                faderFocusNode: voxFaderFocus,
                dbReadout: const Text('-12.0 dB'),
              ),
              const SizedBox(width: DSSpacing.md),
              DSFaderStrip(
                scale: dsMeterReferenceScale(),
                meterValue: -3.0,
                peakValue: -1.0,
                faderValue: 0.9,
                label: 'Master',
                onFaderChanged: (value) =>
                    events.add('fader:master:${value.toStringAsFixed(2)}'),
                formatFader: _faderDb,
                dbReadout: const Text('-3.0 dB'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Mixer route: a canvas-host placeholder plus a strip without readout.
///
/// Mirrors the MasterBusStrip donor: master fader + stereo-adjacent meter
/// readout in a compact bus strip. The bus fader is keyboard-driven in
/// tests (focus + arrow key) so the interaction never depends on pointer
/// hit-testing through rotation and scroll ancestors.
class MixerRoute extends StatelessWidget {
  final List<String> events;
  final FocusNode busFaderFocus;
  const MixerRoute({
    super.key,
    required this.events,
    required this.busFaderFocus,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mixer')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            DSCanvasHost(
              spec: const DSCanvasHostSpec(viewportSize: Size(320, 48)),
              painter: _BusPainter(),
              semanticLabel: 'Master bus canvas',
              semanticValue: '-3.0 dB',
              placeholder: true,
            ),
            const SizedBox(height: DSSpacing.md),
            DSFaderStrip(
              scale: dsMeterReferenceScale(),
              meterValue: -6.0,
              faderValue: 0.8,
              label: 'Bus',
              onFaderChanged: (value) =>
                  events.add('fader:bus:${value.toStringAsFixed(2)}'),
              formatFader: _faderDb,
              faderFocusNode: busFaderFocus,
            ),
          ],
        ),
      ),
    );
  }
}

class _BusPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = DSColors.obsidianElevated,
    );
  }

  @override
  bool shouldRepaint(_BusPainter oldDelegate) => false;
}

Widget _hostApp({
  required List<String> events,
  required FocusNode voxFaderFocus,
  required FocusNode busFaderFocus,
  required ValueChanged<double> onVoxFader,
}) {
  return MaterialApp(
    theme: DSTheme.dark(),
    initialRoute: '/studio',
    routes: {
      '/studio': (context) => StudioRoute(
        events: events,
        voxFaderFocus: voxFaderFocus,
        onVoxFader: onVoxFader,
      ),
      '/mixer': (context) =>
          MixerRoute(events: events, busFaderFocus: busFaderFocus),
    },
  );
}

void main() {
  group('meter/fader host composition (Tempest studio + mixer sites)', () {
    testWidgets('named routes compose with interaction and no errors', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1400, 2400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final errors = <FlutterErrorDetails>[];
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        final message = details.exceptionAsString();
        if (message.contains('overflow') ||
            message.contains('RenderFlex') ||
            message.contains('ErrorWidget')) {
          errors.add(details);
          return;
        }
        originalOnError?.call(details);
      };
      addTearDown(() => FlutterError.onError = originalOnError);

      final events = <String>[];
      final voxFaderFocus = FocusNode();
      addTearDown(voxFaderFocus.dispose);
      final busFaderFocus = FocusNode();
      addTearDown(busFaderFocus.dispose);
      var voxFader = 0.75;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) => _hostApp(
            events: events,
            voxFaderFocus: voxFaderFocus,
            busFaderFocus: busFaderFocus,
            onVoxFader: (value) {
              events.add('fader:vox:${value.toStringAsFixed(2)}');
              setState(() => voxFader = value);
            },
          ),
        ),
      );
      await tester.pump();

      // Tempest-like site: strips render with meter, fader, readout.
      expect(find.text('Vox'), findsOneWidget);
      expect(find.text('Master'), findsOneWidget);
      expect(find.byType(DSMeter), findsNWidgets(2));
      expect(find.text('-12.0 dB'), findsWidgets);

      // Focus propagation: the Vox fader is keyboard-reachable.
      voxFaderFocus.requestFocus();
      await tester.pump();
      expect(voxFaderFocus.hasFocus, isTrue);

      // Meaningful interaction 1: keyboard fader adjust dispatches.
      // (Pointer drags through a RotatedBox inside scroll ancestors are
      // hit-test fragile; keyboard adjust is the deterministic,
      // accessibility-first interaction for a fader.)
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(
        events.any((event) => event.startsWith('fader:vox:')),
        isTrue,
        reason: 'keyboard adjust on the Vox fader must dispatch',
      );
      expect(voxFader, isNot(equals(0.75)));

      // Named-route entry 2: mixer route with canvas host + bus strip.
      Navigator.of(tester.element(find.text('Vox'))).pushNamed('/mixer');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Bus'), findsOneWidget);
      expect(find.text('Canvas placeholder'), findsOneWidget);

      // Meaningful interaction 2: bus fader keyboard adjust dispatches.
      busFaderFocus.requestFocus();
      await tester.pump();
      expect(busFaderFocus.hasFocus, isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(events.any((event) => event.startsWith('fader:bus:')), isTrue);

      expect(
        errors,
        isEmpty,
        reason: 'Host composition must not produce framework errors',
      );
    });

    testWidgets('compact viewport and high text scale stay overflow-free', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(400, 700));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      var overflows = 0;
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        final message = details.exceptionAsString();
        if (message.contains('overflow') || message.contains('RenderFlex')) {
          overflows++;
          return;
        }
        originalOnError?.call(details);
      };
      addTearDown(() => FlutterError.onError = originalOnError);

      final events = <String>[];
      final voxFaderFocus = FocusNode();
      addTearDown(voxFaderFocus.dispose);
      final busFaderFocus = FocusNode();
      addTearDown(busFaderFocus.dispose);

      await tester.pumpWidget(
        Builder(
          builder: (context) {
            final data = MediaQuery.of(context);
            return MediaQuery(
              data: data.copyWith(textScaler: const TextScaler.linear(2.0)),
              child: _hostApp(
                events: events,
                voxFaderFocus: voxFaderFocus,
                busFaderFocus: busFaderFocus,
                onVoxFader: (value) =>
                    events.add('fader:vox:${value.toStringAsFixed(2)}'),
              ),
            );
          },
        ),
      );
      await tester.pump();

      expect(find.text('Vox'), findsOneWidget);
      voxFaderFocus.requestFocus();
      await tester.pump();
      expect(voxFaderFocus.hasFocus, isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(events.any((event) => event.startsWith('fader:vox:')), isTrue);

      expect(overflows, 0, reason: 'Compact + 2x text must not overflow');
    });
  });
}
