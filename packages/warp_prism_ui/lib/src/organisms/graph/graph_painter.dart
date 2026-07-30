/// Graph edge and arrow painter — extracted from the monolith.
///
/// Renders curved edges with bezier arrows between graph nodes.
/// Public and testable with `PictureRecorder`.
library;

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../tokens/tokens.dart';
import 'graph_model.dart';

/// Configuration for graph painter styling.
class GraphPainterConfig {
  /// Edge color for normal (non-highlighted) edges.
  final Color edgeColor;

  /// Edge color for highlighted edges (connected to hovered/selected node).
  final Color edgeHighlightColor;

  /// Normal edge stroke width.
  final double edgeStrokeWidth;

  /// Highlighted edge stroke width.
  final double edgeHighlightStrokeWidth;

  /// Arrow size in logical pixels.
  final double arrowSize;

  /// Bezier curve offset (vertical control point displacement).
  final double curveOffset;

  const GraphPainterConfig({
    this.edgeColor = DSColors.borderSubtle,
    this.edgeHighlightColor = DSColors.accentCyan,
    this.edgeStrokeWidth = 1.0,
    this.edgeHighlightStrokeWidth = 2.0,
    this.arrowSize = 8.0,
    this.curveOffset = 20.0,
  });
}

/// Custom painter for graph edges and arrows.
///
/// Draws curved directed edges between nodes using quadratic bezier curves.
/// Accepts a [GraphModel], a position map, and viewport transform (pan/scale).
///
/// Usage:
/// ```dart
/// CustomPaint(
///   painter: GraphPainter(
///     model: graphModel,
///     positions: layoutPositions,
///     panOffset: panOffset,
///     scale: scale,
///     hoveredNodeId: hoveredId,
///     selectedNodeId: selectedId,
///   ),
/// )
/// ```
class GraphPainter extends CustomPainter {
  /// The graph model containing nodes and edges.
  final GraphModel model;

  /// Current computed positions for each node (from layout engine or
  /// interaction state). Keys are [GraphNodeId], values are logical
  /// positions (before pan/scale transform).
  final Map<GraphNodeId, Offset> positions;

  /// Pan offset applied to the entire canvas.
  final Offset panOffset;

  /// Zoom scale factor.
  final double scale;

  /// ID of the currently hovered node (for edge highlighting).
  final GraphNodeId? hoveredNodeId;

  /// ID of the currently selected node (for edge highlighting).
  final GraphNodeId? selectedNodeId;

  /// Style configuration.
  final GraphPainterConfig config;

  GraphPainter({
    required this.model,
    required this.positions,
    this.panOffset = Offset.zero,
    this.scale = 1.0,
    this.hoveredNodeId,
    this.selectedNodeId,
    this.config = const GraphPainterConfig(),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (final edge in model.edges) {
      final sourcePos = positions[edge.sourceId];
      final targetPos = positions[edge.targetId];

      if (sourcePos == null || targetPos == null) continue;
      if (edge.sourceId == edge.targetId) continue;

      // Transform to screen coordinates
      final screenSource = (sourcePos * scale) + panOffset + center;
      final screenTarget = (targetPos * scale) + panOffset + center;

      // Determine if this edge should be highlighted
      final isHighlighted =
          hoveredNodeId == edge.sourceId ||
          hoveredNodeId == edge.targetId ||
          selectedNodeId == edge.sourceId ||
          selectedNodeId == edge.targetId;

      final paint = Paint()
        ..color = isHighlighted
            ? config.edgeHighlightColor.withValues(alpha: 0.6)
            : config.edgeColor.withValues(alpha: 0.3)
        ..strokeWidth = isHighlighted
            ? config.edgeHighlightStrokeWidth
            : config.edgeStrokeWidth
        ..style = PaintingStyle.stroke;

      // Draw curved edge with quadratic bezier
      final controlPoint = Offset(
        (screenSource.dx + screenTarget.dx) / 2,
        (screenSource.dy + screenTarget.dy) / 2 - config.curveOffset,
      );

      final path = Path()
        ..moveTo(screenSource.dx, screenSource.dy)
        ..quadraticBezierTo(
          controlPoint.dx,
          controlPoint.dy,
          screenTarget.dx,
          screenTarget.dy,
        );

      canvas.drawPath(path, paint);

      // Draw arrow at target end
      _drawArrow(canvas, screenSource, screenTarget, paint);
    }
  }

  void _drawArrow(Canvas canvas, Offset from, Offset to, Paint paint) {
    final direction = (to - from).direction;
    final arrowPoint = to - Offset.fromDirection(direction, 35);

    final path = Path()
      ..moveTo(arrowPoint.dx, arrowPoint.dy)
      ..lineTo(
        arrowPoint.dx - config.arrowSize * math.cos(direction - math.pi / 6),
        arrowPoint.dy - config.arrowSize * math.sin(direction - math.pi / 6),
      )
      ..moveTo(arrowPoint.dx, arrowPoint.dy)
      ..lineTo(
        arrowPoint.dx - config.arrowSize * math.cos(direction + math.pi / 6),
        arrowPoint.dy - config.arrowSize * math.sin(direction + math.pi / 6),
      );

    canvas.drawPath(path, paint..style = PaintingStyle.stroke);
  }

  @override
  bool shouldRepaint(covariant GraphPainter oldDelegate) =>
      model != oldDelegate.model ||
      positions != oldDelegate.positions ||
      panOffset != oldDelegate.panOffset ||
      scale != oldDelegate.scale ||
      hoveredNodeId != oldDelegate.hoveredNodeId ||
      selectedNodeId != oldDelegate.selectedNodeId;
}
