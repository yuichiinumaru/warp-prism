// Conformance tests for the meter/fader/canvas-host seam
// (Task 1861, F-13 — EXPERIMENTAL).
//
// Covers: injected scale mapping (fraction/zone/clamp), fake scale
// determinism, atom a11y numeric announcement, fader drag semantics +
// readout slot, canvas-host fixed viewport + bounded data + placeholder.
//
// Run: flutter test packages/warp_prism_ui/test/atoms/ds_meter_conformance_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/src/atoms/ds_canvas_host.dart';
import 'package:warp_prism_ui/src/atoms/ds_meter.dart';
import 'package:warp_prism_ui/src/molecules/ds_fader_strip.dart';
import 'package:warp_prism_ui/src/tokens/tokens.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('DSMeterScale injected mapping', () {
    test('fraction maps floor to 0 and ceiling to 1', () {
      final scale = dsMeterReferenceScale();
      expect(scale.fractionFor(-60.0), equals(0.0));
      expect(scale.fractionFor(0.0), equals(1.0));
      expect(scale.fractionFor(-30.0), closeTo(0.5, 1e-9));
    });

    test('fraction clamps outside the range', () {
      final scale = dsMeterReferenceScale();
      expect(scale.fractionFor(-120.0), equals(0.0));
      expect(scale.fractionFor(12.0), equals(1.0));
    });

    test('zones select by highest threshold at or below value', () {
      final scale = dsMeterReferenceScale();
      expect(scale.zoneFor(-60.0), isNull);
      expect(scale.zoneFor(-12.0), isNull);
      expect(scale.zoneFor(-6.0)?.label, equals('warm'));
      expect(scale.zoneFor(-3.0)?.label, equals('warm'));
      expect(scale.zoneFor(-1.0)?.label, equals('hot'));
      expect(scale.zoneFor(0.0)?.label, equals('hot'));
    });

    test('fake scale is deterministic: same input, same string', () {
      final scale = dsMeterReferenceScale();
      expect(scale.formatValue(-12.0), equals(scale.formatValue(-12.0)));
      expect(scale.formatValue(-12.0), equals('-12.0 dB'));
    });

    test('fake scale carries exactly the two donor zones, sorted', () {
      final scale = dsMeterReferenceScale();
      expect(scale.zones.length, equals(2));
      expect(scale.zones[0].threshold, lessThan(scale.zones[1].threshold));
    });
  });

  group('DSMeter a11y numeric contract', () {
    testWidgets('announcement carries the formatted numeric value', (
      tester,
    ) async {
      final scale = dsMeterReferenceScale();
      await tester.pumpWidget(_wrap(DSMeter(scale: scale, value: -12.0)));

      expect(find.bySemanticsLabel('Level meter: -12.0 dB'), findsOneWidget);
    });

    testWidgets('announcement names the governing zone and peak', (
      tester,
    ) async {
      final scale = dsMeterReferenceScale();
      await tester.pumpWidget(
        _wrap(DSMeter(scale: scale, value: -3.0, peakValue: -1.0)),
      );

      expect(
        find.bySemanticsLabel('Level meter: -3.0 dB, warm zone, peak -1.0 dB'),
        findsOneWidget,
      );
    });

    testWidgets('null peak hides the marker text from the announcement', (
      tester,
    ) async {
      final scale = dsMeterReferenceScale();
      await tester.pumpWidget(_wrap(DSMeter(scale: scale, value: -30.0)));

      expect(find.bySemanticsLabel('Level meter: -30.0 dB'), findsOneWidget);
    });

    testWidgets('paints at the fixed viewport size', (tester) async {
      final scale = dsMeterReferenceScale();
      await tester.pumpWidget(_wrap(DSMeter(scale: scale, value: -12.0)));

      final box = tester.getSize(find.byType(DSMeter).first);
      expect(box, equals(const Size(56, 180)));
    });
  });

  group('DSFaderStrip composition', () {
    testWidgets('renders label, meter, fader, and verbatim readout slot', (
      tester,
    ) async {
      final scale = dsMeterReferenceScale();
      await tester.pumpWidget(
        _wrap(
          DSFaderStrip(
            scale: scale,
            meterValue: -12.0,
            faderValue: 0.75,
            label: 'Vox',
            onFaderChanged: (_) {},
            dbReadout: const Text('-12.0 dB'),
          ),
        ),
      );

      expect(find.text('Vox'), findsOneWidget);
      expect(find.byType(DSMeter), findsOneWidget);
      expect(find.byType(Slider), findsOneWidget);
      // Readout slot renders caller bytes verbatim.
      expect(find.text('-12.0 dB'), findsWidgets);
    });

    testWidgets('fader drag dispatches the new normalized value', (
      tester,
    ) async {
      final scale = dsMeterReferenceScale();
      var current = 0.75;
      double? dispatched;
      await tester.pumpWidget(
        _wrap(
          StatefulBuilder(
            builder: (context, setState) => DSFaderStrip(
              scale: scale,
              meterValue: -12.0,
              faderValue: current,
              label: 'Vox',
              onFaderChanged: (value) {
                dispatched = value;
                setState(() => current = value);
              },
            ),
          ),
        ),
      );

      // Drag the slider thumb toward minimum: value must move.
      await tester.drag(find.byType(Slider), const Offset(-40, 0));
      await tester.pump();
      expect(dispatched, isNotNull);
      expect(dispatched, isNot(equals(0.75)));
    });

    testWidgets('announcement carries label plus numeric meter and fader', (
      tester,
    ) async {
      final scale = dsMeterReferenceScale();
      await tester.pumpWidget(
        _wrap(
          DSFaderStrip(
            scale: scale,
            meterValue: -12.0,
            faderValue: 0.75,
            label: 'Vox',
            onFaderChanged: (_) {},
          ),
        ),
      );

      expect(
        find.bySemanticsLabel('Vox. -12.0 dB. Fader 75%.'),
        findsOneWidget,
      );
    });

    testWidgets('null callback renders the fader disabled, never hidden', (
      tester,
    ) async {
      final scale = dsMeterReferenceScale();
      await tester.pumpWidget(
        _wrap(
          DSFaderStrip(
            scale: scale,
            meterValue: -12.0,
            faderValue: 0.75,
            label: 'Vox',
          ),
        ),
      );

      expect(find.byType(Slider), findsOneWidget);
      final slider = tester.widget<Slider>(find.byType(Slider));
      expect(slider.onChanged, isNull);
    });
  });

  group('DSCanvasHost contract', () {
    test('clampData keeps the newest maxDataPoints entries', () {
      const spec = DSCanvasHostSpec(viewportSize: Size(56, 180));
      expect(spec.maxDataPoints, equals(512));
      final data = List<double>.generate(600, (i) => i.toDouble());
      final clamped = spec.clampData(data);
      expect(clamped.length, equals(512));
      expect(clamped.first, equals(88.0));
      expect(clamped.last, equals(599.0));
    });

    test('fits reports truncation honestly', () {
      const spec = DSCanvasHostSpec(
        viewportSize: Size(56, 180),
        maxDataPoints: 4,
      );
      expect(spec.fits([1, 2, 3]), isTrue);
      expect(spec.fits([1, 2, 3, 4, 5]), isFalse);
    });

    testWidgets('placeholder renders label plus numeric fallback', (
      tester,
    ) async {
      const spec = DSCanvasHostSpec(viewportSize: Size(56, 180));
      await tester.pumpWidget(
        _wrap(
          DSCanvasHost(
            spec: spec,
            painter: _NopPainter(),
            semanticLabel: 'Meter canvas',
            semanticValue: '-12.0 dB',
            placeholder: true,
          ),
        ),
      );

      expect(find.text('Canvas placeholder'), findsOneWidget);
      expect(find.bySemanticsLabel('Meter canvas: -12.0 dB'), findsOneWidget);
      final box = tester.getSize(find.byType(DSCanvasHost));
      expect(box, equals(const Size(56, 180)));
    });

    testWidgets('live surface pins the fixed viewport and announces value', (
      tester,
    ) async {
      const spec = DSCanvasHostSpec(viewportSize: Size(56, 180));
      await tester.pumpWidget(
        _wrap(
          DSCanvasHost(
            spec: spec,
            painter: _NopPainter(),
            semanticLabel: 'Meter canvas',
            semanticValue: '-3.0 dB',
          ),
        ),
      );

      final box = tester.getSize(find.byType(DSCanvasHost));
      expect(box, equals(const Size(56, 180)));
      expect(find.bySemanticsLabel('Meter canvas: -3.0 dB'), findsOneWidget);
    });
  });
}

class _NopPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = DSColors.obsidianElevated,
    );
  }

  @override
  bool shouldRepaint(_NopPainter oldDelegate) => false;
}
