@Tags(['golden'])
library;

// Golden tests for the meter/fader seam (Task 1861, F-13 — EXPERIMENTAL).
//
// Deterministic capture only: every case pins a fixed injected scale
// (dsMeterReferenceScale), fixed caller values, and a fixed viewport.
// No animation, no timers, no wall-clock: meters are the classic
// animation-capture trap, so peak-hold arrives injected and static.
//
// Run from packages/warp_prism_ui/:
//   flutter test --update-goldens test/goldens/ds_meter_golden_test.dart
//   flutter test test/goldens/ds_meter_golden_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/src/atoms/ds_meter.dart';
import 'package:warp_prism_ui/src/molecules/ds_fader_strip.dart';
import 'package:warp_prism_ui/src/tokens/tokens.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

Widget _inApp(Widget child) {
  return MaterialApp(
    theme: PrismTheme.dark(),
    home: Scaffold(
      backgroundColor: DSColors.obsidianBase,
      body: Center(child: child),
    ),
  );
}

void main() {
  group('DSMeter golden — fixed scale, fixed values, fixed viewport', () {
    testWidgets('renders nominal fill at fixed value', (tester) async {
      await tester.pumpWidget(
        _inApp(DSMeter(scale: dsMeterReferenceScale(), value: -12.0)),
      );
      await expectLater(
        find.byType(DSMeter),
        matchesGoldenFile('goldens/meter_1861_nominal.png'),
      );
    });

    testWidgets('renders warm zone fill with injected peak marker', (
      tester,
    ) async {
      await tester.pumpWidget(
        _inApp(
          DSMeter(scale: dsMeterReferenceScale(), value: -3.0, peakValue: -1.5),
        ),
      );
      await expectLater(
        find.byType(DSMeter),
        matchesGoldenFile('goldens/meter_1861_warm_peak.png'),
      );
    });

    testWidgets('renders hot zone fill at ceiling', (tester) async {
      await tester.pumpWidget(
        _inApp(DSMeter(scale: dsMeterReferenceScale(), value: 0.0)),
      );
      await expectLater(
        find.byType(DSMeter),
        matchesGoldenFile('goldens/meter_1861_hot.png'),
      );
    });
  });

  group('DSFaderStrip golden — fixed strip composition', () {
    testWidgets('renders strip with meter, fader, and readout slot', (
      tester,
    ) async {
      await tester.pumpWidget(
        _inApp(
          DSFaderStrip(
            scale: dsMeterReferenceScale(),
            meterValue: -12.0,
            peakValue: -9.0,
            faderValue: 0.75,
            label: 'Vox',
            onFaderChanged: (_) {},
            formatFader: (normalized) =>
                '${(normalized * 3.5).toStringAsFixed(1)} dB',
            dbReadout: const Text('-12.0 dB'),
          ),
        ),
      );
      await expectLater(
        find.byType(DSFaderStrip),
        matchesGoldenFile('goldens/meter_1861_fader_strip.png'),
      );
    });
  });
}
