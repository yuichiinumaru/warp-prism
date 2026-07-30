import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../atoms/ds_glass_panel.dart';
import '../atoms/ds_text.dart';
import '../tokens/tokens.dart';

// =============================================================================
// Models
// =============================================================================

/// Segment descriptor for [DSScaleMeasureBar].
///
/// [fraction] is relative width within the bar (normalized at render time).
@immutable
class DSScaleSegment {
  /// Stable segment identity.
  final String id;

  /// Relative width weight (must be > 0).
  final double fraction;

  /// Optional fill override; defaults to bar accent.
  final Color? color;

  const DSScaleSegment({required this.id, required this.fraction, this.color})
    : assert(fraction > 0, 'segment fraction must be positive');

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DSScaleSegment &&
        other.id == id &&
        other.fraction == fraction &&
        other.color == color;
  }

  @override
  int get hashCode => Object.hash(id, fraction, color);
}

// =============================================================================
// Fixtures
// =============================================================================

/// Fixture catalog for gallery + tests (Task 1522 / O-26).
abstract final class DSScaleMeasureBarFixtures {
  /// Default map scale: 100 m across four equal ticks.
  static const String defaultLabel = '100 m';

  static const List<DSScaleSegment> defaultSegments = <DSScaleSegment>[
    DSScaleSegment(id: 'seg-0', fraction: 1),
    DSScaleSegment(id: 'seg-1', fraction: 1),
    DSScaleSegment(id: 'seg-2', fraction: 1),
    DSScaleSegment(id: 'seg-3', fraction: 1),
  ];

  /// Alternate fixture for kilometer scale demos.
  static const String kilometerLabel = '1 km';

  static const List<DSScaleSegment> kilometerSegments = <DSScaleSegment>[
    DSScaleSegment(id: 'km-0', fraction: 1),
    DSScaleSegment(id: 'km-1', fraction: 1),
  ];
}

// =============================================================================
// Widget
// =============================================================================

/// ASW Observatory Molecule — Scale Measure Bar
///
/// **Classification decision (Task 1522)**: **molecule**, not organism.
///
/// Rationale: compact read-only map chrome with a single label + segment row.
/// No multi-region composition, no exclusive tool state, and no overlay host
/// lifecycle — promoting to organism would over-weight a scale chrome strip.
/// Pair with stage chrome organisms ([DSCoordinateStatusBar], [DSMapLegend])
/// when composing map HUD layouts.
///
/// Contract (O-26):
/// - Fixture label + segments only — no zoom math or MapLibre coupling.
/// - Read-only display; no measure-mode mutation engine.
class DSScaleMeasureBar extends StatelessWidget {
  /// Semantics / test key for the bar region.
  static const Key barRegionKey = Key('ds-scale-measure-bar');

  /// Human-readable scale distance (e.g. `"100 m"`).
  final String label;

  /// Segment weights rendered left-to-right (alternating fill for ticks).
  final List<DSScaleSegment> segments;

  /// Total bar track width.
  final double barWidth;

  /// Track height.
  final double barHeight;

  /// Accent color for filled segments.
  final Color accentColor;

  /// Optional secondary caption (e.g. projection note).
  final String? caption;

  const DSScaleMeasureBar({
    super.key,
    required this.label,
    this.segments = DSScaleMeasureBarFixtures.defaultSegments,
    this.barWidth = 120,
    this.barHeight = 6,
    this.accentColor = DSColors.accentCyan,
    this.caption,
  });

  @override
  Widget build(BuildContext context) {
    final semantic = caption == null
        ? 'Map scale $label'
        : 'Map scale $label. $caption';

    return Semantics(
      container: true,
      label: semantic,
      child: DSGlassPanelSimple(
        key: barRegionKey,
        radius: DSRadii.sm,
        backgroundColor: DSColors.obsidianElevated.withValues(alpha: 0.92),
        borderColor: DSColors.borderDefault,
        padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.sm,
          vertical: DSSpacing.xs,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExcludeSemantics(
              child: DSText.labelSmall(label, color: DSColors.textPrimary),
            ),
            const SizedBox(height: DSSpacing.xxs),
            ExcludeSemantics(
              child: SizedBox(
                width: barWidth,
                height: barHeight + 4,
                child: CustomPaint(
                  painter: _ScaleBarPainter(
                    segments: segments,
                    accentColor: accentColor,
                    trackHeight: barHeight,
                  ),
                  size: Size(barWidth, barHeight + 4),
                ),
              ),
            ),
            if (caption != null) ...[
              const SizedBox(height: DSSpacing.xxs),
              ExcludeSemantics(
                child: DSText.labelSmall(
                  caption!,
                  color: DSColors.textTertiary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ScaleBarPainter extends CustomPainter {
  final List<DSScaleSegment> segments;
  final Color accentColor;
  final double trackHeight;

  const _ScaleBarPainter({
    required this.segments,
    required this.accentColor,
    required this.trackHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (segments.isEmpty || size.width <= 0) return;

    final total = segments.fold<double>(0, (sum, s) => sum + s.fraction);
    if (total <= 0) return;

    final top = (size.height - trackHeight) / 2;
    var x = 0.0;

    // Outer frame
    final framePaint = Paint()
      ..color = DSColors.borderStrong
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRect(Rect.fromLTWH(0, top, size.width, trackHeight), framePaint);

    for (var i = 0; i < segments.length; i++) {
      final seg = segments[i];
      final w = size.width * (seg.fraction / total);
      final fill =
          seg.color ??
          (i.isEven
              ? accentColor.withValues(alpha: 0.85)
              : accentColor.withValues(alpha: 0.35));
      final paint = Paint()
        ..color = fill
        ..style = PaintingStyle.fill;
      canvas.drawRect(Rect.fromLTWH(x, top, w, trackHeight), paint);

      // Tick marks at segment boundaries
      final tickPaint = Paint()
        ..color = DSColors.textPrimary
        ..strokeWidth = 1;
      canvas.drawLine(
        Offset(x, top - 2),
        Offset(x, top + trackHeight + 2),
        tickPaint,
      );
      x += w;
    }
    // Closing tick
    final tickPaint = Paint()
      ..color = DSColors.textPrimary
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(size.width, top - 2),
      Offset(size.width, top + trackHeight + 2),
      tickPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScaleBarPainter oldDelegate) {
    // Deep equality: List.== is identity; segment models implement value ==.
    return !listEquals(oldDelegate.segments, segments) ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.trackHeight != trackHeight;
  }
}
