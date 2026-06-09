/// Abstract interface for graph layout algorithms.
///
/// Implementations compute 2D positions for each node given the graph
/// structure and available canvas size. Layout engines are stateless —
/// they accept a [GraphModel] and return a position map.
library;

import 'dart:ui';
import 'graph_model.dart';

/// Contract for graph layout algorithms.
///
/// Implementations must:
/// - Return a position for every node in the model.
/// - Keep positions within the bounds of [canvasSize] (with padding).
/// - Be deterministic for the same input (no internal randomness).
abstract class GraphLayoutEngine {
  /// Compute node positions for [model] within [canvasSize].
  ///
  /// Returns a map from [GraphNodeId] to the computed center [Offset]
  /// for each node. Positions should be relative to the canvas center
  /// (0,0 = canvas center) unless the implementation documents otherwise.
  Map<GraphNodeId, Offset> layout(GraphModel model, Size canvasSize);
}
