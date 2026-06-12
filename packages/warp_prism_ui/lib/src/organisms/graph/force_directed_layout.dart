/// Force-directed graph layout algorithm.
///
/// Extracted from the monolith `_updatePhysics`. Uses a simple spring-electron
/// model: repulsion between all node pairs, attraction along edges, center
/// gravity, and velocity damping.
///
/// This is a static (non-animated) layout — it runs the physics simulation
/// for a fixed number of iterations and returns final positions. The
/// orchestrator widget uses this for initial layout; ongoing animation is
/// handled by the widget's `AnimationController`.
library;

import 'dart:math' as math;
import 'dart:ui';
import 'graph_model.dart';
import 'graph_layout_engine.dart';

/// Force-directed layout configuration.
class ForceDirectedConfig {
  /// Repulsion force between all node pairs.
  final double repulsion;

  /// Attraction force along edges (spring constant).
  final double attraction;

  /// Velocity damping factor (0..1). Higher = less oscillation.
  final double damping;

  /// Minimum distance between nodes (prevents division by zero).
  final double minDistance;

  /// Center gravity pull (prevents nodes from drifting to infinity).
  final double centerGravity;

  /// Target spacing between connected nodes.
  final double nodeSpacing;

  /// Number of simulation iterations for static layout.
  final int iterations;

  const ForceDirectedConfig({
    this.repulsion = 5000.0,
    this.attraction = 0.01,
    this.damping = 0.9,
    this.minDistance = 50.0,
    this.centerGravity = 0.001,
    this.nodeSpacing = 150.0,
    this.iterations = 200,
  });
}

/// Force-directed layout engine.
///
/// Implements [GraphLayoutEngine] using a spring-electron model.
/// Deterministic when initial positions are deterministic (seeded from
/// node order).
class ForceDirectedLayout implements GraphLayoutEngine {
  final ForceDirectedConfig config;

  const ForceDirectedLayout({this.config = const ForceDirectedConfig()});

  @override
  Map<GraphNodeId, Offset> layout(GraphModel model, Size canvasSize) {
    if (model.nodes.isEmpty) return {};

    // Initialize positions — use existing node positions or spread randomly.
    final positions = <GraphNodeId, Offset>{};
    final velocities = <GraphNodeId, Offset>{};
    final random = math.Random(42);

    for (int i = 0; i < model.nodes.length; i++) {
      final node = model.nodes[i];
      if (node.position != Offset.zero) {
        positions[node.id] = node.position;
      } else {
        positions[node.id] = Offset(
          random.nextDouble() * canvasSize.width * 0.6 - canvasSize.width * 0.3,
          random.nextDouble() * canvasSize.height * 0.4 -
              canvasSize.height * 0.2,
        );
      }
      velocities[node.id] = Offset.zero;
    }

    // Build adjacency lookup for O(1) edge queries.
    final adjacency = <GraphNodeId, List<GraphNodeId>>{};
    for (final node in model.nodes) {
      adjacency[node.id] = [];
    }
    for (final edge in model.edges) {
      adjacency[edge.sourceId]?.add(edge.targetId);
      adjacency[edge.targetId]?.add(edge.sourceId);
    }

    // Run simulation for a fixed number of iterations.
    for (int iter = 0; iter < config.iterations; iter++) {
      _simulateStep(model, positions, velocities, adjacency);
    }

    // Center the layout on the canvas.
    return _centerOnCanvas(positions, canvasSize);
  }

  /// Run a single physics simulation step (public for animated use).
  ///
  /// The orchestrator widget calls this each frame for live physics,
  /// passing mutable position and velocity maps.
  void simulateStep(
    GraphModel model,
    Map<GraphNodeId, Offset> positions,
    Map<GraphNodeId, Offset> velocities,
    Set<GraphNodeId> draggingNodes,
  ) {
    // Build adjacency if not cached
    final adjacency = <GraphNodeId, List<GraphNodeId>>{};
    for (final node in model.nodes) {
      adjacency[node.id] = [];
    }
    for (final edge in model.edges) {
      adjacency[edge.sourceId]?.add(edge.targetId);
      adjacency[edge.targetId]?.add(edge.sourceId);
    }

    for (final node in model.nodes) {
      if (draggingNodes.contains(node.id)) continue;

      final pos = positions[node.id] ?? Offset.zero;
      Offset force = Offset.zero;

      // Repulsion from all other nodes
      for (final other in model.nodes) {
        if (other.id == node.id) continue;
        final otherPos = positions[other.id] ?? Offset.zero;
        final delta = pos - otherPos;
        final distance = math.max(delta.distance, config.minDistance);
        final direction = delta / distance;
        force += direction * (config.repulsion / (distance * distance));
      }

      // Attraction along edges
      for (final neighborId in adjacency[node.id] ?? []) {
        final neighborPos = positions[neighborId] ?? Offset.zero;
        final delta = neighborPos - pos;
        final distance = delta.distance;
        if (distance > config.nodeSpacing) {
          force += delta * config.attraction;
        }
      }

      // Center gravity
      force -= pos * config.centerGravity;

      // Update velocity and position
      final vel = velocities[node.id] ?? Offset.zero;
      final newVel = (vel + force) * config.damping;
      velocities[node.id] = newVel;
      positions[node.id] = pos + newVel;
    }
  }

  void _simulateStep(
    GraphModel model,
    Map<GraphNodeId, Offset> positions,
    Map<GraphNodeId, Offset> velocities,
    Map<GraphNodeId, List<GraphNodeId>> adjacency,
  ) {
    for (final node in model.nodes) {
      final pos = positions[node.id] ?? Offset.zero;
      Offset force = Offset.zero;

      // Repulsion from all other nodes
      for (final other in model.nodes) {
        if (other.id == node.id) continue;
        final otherPos = positions[other.id] ?? Offset.zero;
        final delta = pos - otherPos;
        final distance = math.max(delta.distance, config.minDistance);
        final direction = delta / distance;
        force += direction * (config.repulsion / (distance * distance));
      }

      // Attraction along edges
      for (final neighborId in adjacency[node.id] ?? []) {
        final neighborPos = positions[neighborId] ?? Offset.zero;
        final delta = neighborPos - pos;
        final distance = delta.distance;
        if (distance > config.nodeSpacing) {
          force += delta * config.attraction;
        }
      }

      // Center gravity
      force -= pos * config.centerGravity;

      // Update velocity and position
      final vel = velocities[node.id] ?? Offset.zero;
      final newVel = (vel + force) * config.damping;
      velocities[node.id] = newVel;
      positions[node.id] = pos + newVel;
    }
  }

  /// Shift all positions so the graph centroid is at canvas center.
  Map<GraphNodeId, Offset> _centerOnCanvas(
    Map<GraphNodeId, Offset> positions,
    Size canvasSize,
  ) {
    if (positions.isEmpty) return positions;

    // Compute centroid
    double sumX = 0, sumY = 0;
    for (final pos in positions.values) {
      sumX += pos.dx;
      sumY += pos.dy;
    }
    final centroid = Offset(sumX / positions.length, sumY / positions.length);
    final canvasCenter = Offset(canvasSize.width / 2, canvasSize.height / 2);
    final shift = canvasCenter - centroid;

    return {
      for (final entry in positions.entries) entry.key: entry.value + shift,
    };
  }
}
