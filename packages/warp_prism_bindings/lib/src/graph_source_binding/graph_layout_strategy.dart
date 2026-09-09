import 'dart:math' as math;
import 'dart:ui';
import 'package:meta/meta.dart';

/// Strategy interface for deterministic graph node coordinate placement.
///
/// **PURGE LAW**: This is a simple deterministic coordinate calculator,
/// strictly avoiding physics engines, iterative force simulations, or ticker loops.
///
/// Lifecycle: EXPERIMENTAL (see `docs/architecture/layer-contracts-v2.md`).
@experimental
abstract interface class GraphLayoutStrategy {
  /// Computes deterministic [Offset] coordinates for nodes keyed by their string IDs.
  Map<String, Offset> computeLayout(
    List<String> nodeIds, {
    Map<String, Offset>? existingPositions,
  });

  /// Computes a deterministic placement for a single newly added node.
  Offset computeNodePosition({
    required String nodeId,
    required int index,
    required int totalNodes,
    Map<String, Offset>? existingPositions,
  });
}

/// Circular layout strategy placing nodes equidistant around a circle.
///
/// Lifecycle: EXPERIMENTAL (see `docs/architecture/layer-contracts-v2.md`).
@experimental
class CircleGraphLayoutStrategy implements GraphLayoutStrategy {
  /// Radius of the placement circle in logical pixels.
  final double radius;

  /// Center point of the circle.
  final Offset center;

  /// Starting angle offset in radians.
  final double startAngle;

  const CircleGraphLayoutStrategy({
    this.radius = 220.0,
    this.center = const Offset(300.0, 300.0),
    this.startAngle = -math.pi / 2,
  });

  @override
  Map<String, Offset> computeLayout(
    List<String> nodeIds, {
    Map<String, Offset>? existingPositions,
  }) {
    final positions = <String, Offset>{};
    final total = nodeIds.length;
    if (total == 0) return positions;

    for (int i = 0; i < total; i++) {
      final id = nodeIds[i];
      if (existingPositions != null && existingPositions.containsKey(id)) {
        positions[id] = existingPositions[id]!;
      } else {
        positions[id] = computeNodePosition(
          nodeId: id,
          index: i,
          totalNodes: total,
          existingPositions: existingPositions,
        );
      }
    }
    return positions;
  }

  @override
  Offset computeNodePosition({
    required String nodeId,
    required int index,
    required int totalNodes,
    Map<String, Offset>? existingPositions,
  }) {
    if (totalNodes <= 1) return center;
    final angle = startAngle + (2 * math.pi * index / totalNodes);
    return Offset(
      center.dx + radius * math.cos(angle),
      center.dy + radius * math.sin(angle),
    );
  }
}

/// Grid layout strategy placing nodes in regular columns and rows.
///
/// Lifecycle: EXPERIMENTAL (see `docs/architecture/layer-contracts-v2.md`).
@experimental
class GridGraphLayoutStrategy implements GraphLayoutStrategy {
  /// Number of columns in the grid.
  final int columns;

  /// Horizontal spacing between nodes in logical pixels.
  final double horizontalSpacing;

  /// Vertical spacing between rows in logical pixels.
  final double verticalSpacing;

  /// Top-left origin offset for grid placement.
  final Offset origin;

  const GridGraphLayoutStrategy({
    this.columns = 4,
    this.horizontalSpacing = 160.0,
    this.verticalSpacing = 120.0,
    this.origin = const Offset(80.0, 80.0),
  });

  @override
  Map<String, Offset> computeLayout(
    List<String> nodeIds, {
    Map<String, Offset>? existingPositions,
  }) {
    final positions = <String, Offset>{};
    final total = nodeIds.length;
    if (total == 0) return positions;

    for (int i = 0; i < total; i++) {
      final id = nodeIds[i];
      if (existingPositions != null && existingPositions.containsKey(id)) {
        positions[id] = existingPositions[id]!;
      } else {
        positions[id] = computeNodePosition(
          nodeId: id,
          index: i,
          totalNodes: total,
          existingPositions: existingPositions,
        );
      }
    }
    return positions;
  }

  @override
  Offset computeNodePosition({
    required String nodeId,
    required int index,
    required int totalNodes,
    Map<String, Offset>? existingPositions,
  }) {
    final col = index % columns;
    final row = index ~/ columns;
    return Offset(
      origin.dx + (col * horizontalSpacing),
      origin.dy + (row * verticalSpacing),
    );
  }
}
