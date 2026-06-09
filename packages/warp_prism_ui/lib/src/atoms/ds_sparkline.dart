import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../tokens/tokens.dart';

/// ASW Observatory Atom — Sparkline
///
/// Inline mini-chart for metric trend visualization.
/// Uses [CustomPainter] directly — no external charting dependency.
///
/// Contract:
/// - Accepts a list of numeric data points (minimum meaningful: 1).
/// - Renders a polyline that fills available width.
/// - Empty data renders a flat placeholder line.
/// - Supports color override; defaults to accentCyan.
/// - Supports optional [lineWidth] (default 1.5).
/// - Supports optional [showDots] to render data-point circles.
/// - Wraps in [Semantics] with a descriptive label.
class DSSparkline extends StatelessWidget {
  /// Numeric data points to chart. Empty list renders a flat line.
  final List<double> data;

  /// Line color override. Defaults to [DSColors.accentCyan].
  final Color? color;

  /// Stroke width of the polyline. Default 1.5.
  final double lineWidth;

  /// Whether to draw small dots at each data point. Default false.
  final bool showDots;

  /// Optional fill opacity (0.0–1.0). Default 0.1 for subtle area fill.
  final double fillOpacity;

  /// Semantic label for screen readers.
  final String? semanticLabel;

  const DSSparkline({
    super.key,
    required this.data,
    this.color,
    this.lineWidth = 1.5,
    this.showDots = false,
    this.fillOpacity = 0.1,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? DSColors.accentCyan;

    return Semantics(
      label: semanticLabel ?? _defaultSemanticLabel(),
      excludeSemantics: semanticLabel != null,
      child: CustomPaint(
        size: Size.infinite,
        painter: _SparklinePainter(
          data: data,
          color: effectiveColor,
          lineWidth: lineWidth,
          showDots: showDots,
          fillOpacity: fillOpacity,
        ),
      ),
    );
  }

  String _defaultSemanticLabel() {
    if (data.isEmpty) return 'Trend chart: no data';
    if (data.length == 1) return 'Trend chart: value ${data.first.toStringAsFixed(1)}';
    final min = data.reduce(math.min);
    final max = data.reduce(math.max);
    return 'Trend chart: ${data.length} points, '
        'range ${min.toStringAsFixed(1)} to ${max.toStringAsFixed(1)}';
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color color;
  final double lineWidth;
  final bool showDots;
  final double fillOpacity;

  _SparklinePainter({
    required this.data,
    required this.color,
    required this.lineWidth,
    required this.showDots,
    required this.fillOpacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = lineWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Empty or single-point data: draw flat line at vertical center
    if (data.isEmpty || data.length == 1) {
      final y = size.height / 2;
      final path = Path()
        ..moveTo(0, y)
        ..lineTo(size.width, y);
      canvas.drawPath(path, paint);
      return;
    }

    final minVal = data.reduce(math.min);
    final maxVal = data.reduce(math.max);
    final range = maxVal - minVal;
    // Avoid division by zero when all values are equal
    final effectiveRange = range == 0 ? 1.0 : range;
    // Add a tiny vertical padding so lines don't clip at edges
    final verticalPadding = size.height * 0.05;
    final drawableHeight = size.height - 2 * verticalPadding;
    final stepX = size.width / (data.length - 1);

    // Build polyline path
    final path = Path();
    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final normalizedY = (data[i] - minVal) / effectiveRange;
      final y = verticalPadding + drawableHeight * (1 - normalizedY);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // Draw area fill
    if (fillOpacity > 0) {
      final fillPath = Path.from(path)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
      final fillPaint = Paint()
        ..color = color.withValues(alpha: fillOpacity)
        ..style = PaintingStyle.fill;
      canvas.drawPath(fillPath, fillPaint);
    }

    // Draw the line
    canvas.drawPath(path, paint);

    // Draw dots if requested
    if (showDots) {
      final dotPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      for (int i = 0; i < data.length; i++) {
        final x = i * stepX;
        final normalizedY = (data[i] - minVal) / effectiveRange;
        final y = verticalPadding + drawableHeight * (1 - normalizedY);
        canvas.drawCircle(Offset(x, y), 2, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_SparklinePainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.color != color ||
        oldDelegate.lineWidth != lineWidth ||
        oldDelegate.showDots != showDots ||
        oldDelegate.fillOpacity != fillOpacity;
  }
}
