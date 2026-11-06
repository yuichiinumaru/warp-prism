import 'package:flutter/material.dart';

import '../tokens/tokens.dart';

/// Injected meter zone threshold (Task 1861, F-13 — EXPERIMENTAL).
///
/// A zone marks the value at which the meter surface changes tone: rendering
/// at or above [threshold] uses [color] with the human-readable [label].
/// Zones are caller-supplied calibration — Prism owns only the geometry of
/// painting them as horizontal bands; full-scale floors, loudness targets,
/// and windowing math stay caller-side and never appear in this file.
class DSMeterZone {
  /// Caller-unit value at which this zone takes over (same units as
  /// [DSMeterScale.floor] / [DSMeterScale.ceiling]).
  final double threshold;

  /// Tone used for fill and band content at or above [threshold].
  final Color color;

  /// Human-readable zone name for the a11y announcement (e.g. `warm`).
  final String label;

  const DSMeterZone({
    required this.threshold,
    required this.color,
    required this.label,
  });
}

/// Injected meter scale descriptor (Task 1861, F-13 — EXPERIMENTAL).
///
/// The scale is fully caller-owned: [floor] and [ceiling] bound the caller
/// units, [zones] carry the colour thresholds, and [formatValue] renders the
/// numeric readout verbatim. Prism never parses, calibrates, or converts —
/// it maps the clamped fraction to vertical geometry only.
class DSMeterScale {
  /// Lower bound of the caller range (e.g. a dB floor). Must be < [ceiling].
  final double floor;

  /// Upper bound of the caller range (e.g. full scale). Must be > [floor].
  final double ceiling;

  /// Zone thresholds in caller units. Sorted ascending at construction.
  /// Bounded: at most 8 zones (canvas-host bounded-data posture).
  final List<DSMeterZone> zones;

  /// Caller-supplied formatter; the returned string renders verbatim in the
  /// readout and the a11y announcement. Same input must yield same output.
  final String Function(double value) formatValue;

  DSMeterScale({
    required this.floor,
    required this.ceiling,
    List<DSMeterZone> zones = const [],
    required this.formatValue,
  }) : assert(floor < ceiling, 'DSMeterScale: floor must be < ceiling'),
       assert(zones.length <= 8, 'DSMeterScale: at most 8 zones'),
       zones = List<DSMeterZone>.unmodifiable(
         List<DSMeterZone>.of(zones)
           ..sort((a, b) => a.threshold.compareTo(b.threshold)),
       );

  /// Clamped fill fraction for [value]: 0.0 at [floor], 1.0 at [ceiling].
  double fractionFor(double value) {
    final clamped = value.clamp(floor, ceiling);
    return (clamped - floor) / (ceiling - floor);
  }

  /// Zone governing [value]: the highest zone with `threshold <= value`,
  /// or null when below every threshold.
  DSMeterZone? zoneFor(double value) {
    DSMeterZone? current;
    for (final zone in zones) {
      if (value >= zone.threshold) {
        current = zone;
      } else {
        break;
      }
    }
    return current;
  }
}

/// Reference/fake scale for tests, gallery, and host proofs.
///
/// Fixed floor/ceiling with two injected thresholds mirroring the Tempest
/// donor zones (INHERITED REPORT via `docs/bridge/tempest/ads-debt.md` §1.1:
/// green below −6, amber −6…−1, saturation at −1 and above). Units stay
/// opaque caller numbers; only the formatter renders them as text.
DSMeterScale dsMeterReferenceScale() {
  return DSMeterScale(
    floor: -60.0,
    ceiling: 0.0,
    zones: const [
      DSMeterZone(
        threshold: -6.0,
        color: DSColors.statusWarning,
        label: 'warm',
      ),
      DSMeterZone(threshold: -1.0, color: DSColors.statusError, label: 'hot'),
    ],
    formatValue: (value) => '${value.toStringAsFixed(1)} dB',
  );
}

/// Reusable vertical meter atom (Task 1861, F-13 — EXPERIMENTAL).
///
/// Geometry only: vertical fill, zone bands, and an injected peak-hold
/// marker. The peak value arrives injected — Prism never runs timers,
/// wall-clocks, or decay logic; hold/decay stay caller-side.
///
/// Donor shape (INHERITED REPORT via `docs/bridge/tempest/ads-debt.md`
/// §1.1 rows 1–2: vertical peak bar + integrated loudness bar):
/// a vertical bar mapping caller levels to fill height. Unlike the donors,
/// scale and thresholds arrive injected, never hard-coded.
///
/// Lifecycle: EXPERIMENTAL. Intentionally **not** exported from any barrel
/// and without a `Prism*` alias until the promotion task wires the public
/// surface (layer-contracts §9).
class DSMeter extends StatelessWidget {
  /// Injected scale: bounds, zone thresholds, and readout formatter.
  final DSMeterScale scale;

  /// Current caller-unit value. Clamped to the scale range for geometry.
  final double value;

  /// Injected peak-hold position in caller units. Null hides the marker.
  /// The caller owns hold timing; this atom paints the marker statically.
  final double? peakValue;

  /// Fixed paint width. Part of the fixed-viewport determinism contract.
  final double width;

  /// Fixed paint height. Part of the fixed-viewport determinism contract.
  final double height;

  /// Screen-reader label prefix. The formatted value is appended.
  final String semanticLabel;

  const DSMeter({
    super.key,
    required this.scale,
    required this.value,
    this.peakValue,
    this.width = 56.0,
    this.height = 180.0,
    this.semanticLabel = 'Level meter',
  });

  /// Screen-reader announcement: label plus formatted numeric value plus
  /// governing zone. Never colour-only.
  String get announcement {
    final zone = scale.zoneFor(value);
    final zoneSuffix = zone == null ? '' : ', ${zone.label} zone';
    final peak = peakValue;
    final peakSuffix = peak == null ? '' : ', peak ${scale.formatValue(peak)}';
    return '$semanticLabel: ${scale.formatValue(value)}$zoneSuffix$peakSuffix';
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: announcement,
      readOnly: true,
      child: SizedBox(
        width: width,
        height: height,
        child: CustomPaint(
          size: Size(width, height),
          painter: _DSMeterPainter(
            scale: scale,
            value: value,
            peakValue: peakValue,
          ),
        ),
      ),
    );
  }
}

class _DSMeterPainter extends CustomPainter {
  final DSMeterScale scale;
  final double value;
  final double? peakValue;

  _DSMeterPainter({
    required this.scale,
    required this.value,
    required this.peakValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    // Track chrome.
    final trackPaint = Paint()..color = DSColors.obsidianElevated;
    final trackRect = RRect.fromLTRBR(
      0,
      0,
      size.width,
      size.height,
      const Radius.circular(4),
    );
    canvas.drawRRect(trackRect, trackPaint);
    canvas.save();
    canvas.clipRRect(trackRect);

    // Zone bands: each region below a threshold paints the nominal tone at
    // wash alpha; thresholds render as 1px ticks in the zone color below.
    // Fill itself takes the governing zone tone, so state is never
    // colour-band-only: the a11y announcement always carries value + zone.
    const nominal = DSColors.statusSuccess;
    final sorted = scale.zones;
    var lowerFraction = 0.0;
    for (var i = 0; i < sorted.length; i++) {
      final upper = scale.fractionFor(sorted[i].threshold);
      _fillBand(
        canvas,
        size,
        lowerFraction,
        upper,
        nominal.withValues(alpha: 0.16),
      );
      lowerFraction = upper;
    }
    _fillBand(
      canvas,
      size,
      lowerFraction,
      1.0,
      nominal.withValues(alpha: 0.16),
    );

    // Fill: vertical, bottom-up, in the governing zone tone.
    final fraction = scale.fractionFor(value);
    final zone = scale.zoneFor(value);
    final fillColor = zone?.color ?? nominal;
    final fillTop = size.height * (1.0 - fraction);
    if (fraction > 0) {
      canvas.drawRect(
        Rect.fromLTWH(0, fillTop, size.width, size.height - fillTop),
        Paint()..color = fillColor,
      );
    }

    // Zone boundary ticks: 1px lines at each threshold fraction.
    for (final z in sorted) {
      final y = size.height * (1.0 - scale.fractionFor(z.threshold));
      canvas.drawRect(
        Rect.fromLTWH(0, y - 0.5, size.width, 1),
        Paint()..color = z.color.withValues(alpha: 0.8),
      );
    }

    // Peak-hold marker: 2px line at the injected peak fraction.
    final peak = peakValue;
    if (peak != null) {
      final peakFraction = scale.fractionFor(peak);
      final y = (size.height * (1.0 - peakFraction)).clamp(
        1.0,
        size.height - 1.0,
      );
      canvas.drawRect(
        Rect.fromLTWH(0, y - 1.0, size.width, 2),
        Paint()..color = DSColors.textPrimary,
      );
    }

    canvas.restore();

    // Border.
    canvas.drawRRect(
      trackRect,
      Paint()
        ..color = DSColors.borderSubtle
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  void _fillBand(
    Canvas canvas,
    Size size,
    double lower,
    double upper,
    Color color,
  ) {
    if (upper <= lower) return;
    final top = size.height * (1.0 - upper);
    final bottom = size.height * (1.0 - lower);
    canvas.drawRect(
      Rect.fromLTWH(0, top, size.width, bottom - top),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_DSMeterPainter oldDelegate) {
    return oldDelegate.scale != scale ||
        oldDelegate.value != value ||
        oldDelegate.peakValue != peakValue;
  }
}
