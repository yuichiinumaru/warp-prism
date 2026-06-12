/// Graph mode contract for the Map surface.
///
/// Each mode selects a subset of [EdgeKind] values from the normalized
/// workspace backbone, producing a different projection of the same
/// asset graph for the [DSGraphCanvas] consumer.
library;

import 'package:warp_prism_observatory/data/models/workspace_graph.dart';

/// The three graph projection modes available in the Map Graph subview.
enum MapGraphMode {
  /// Hierarchical containment: parent → child relationships.
  /// Uses edges: [EdgeKind.contains], [EdgeKind.routesTo].
  containment,

  /// Operational flow: runtime usage and dependency routing.
  /// Uses edges: [EdgeKind.uses], [EdgeKind.dependsOn], [EdgeKind.routesTo].
  operational,

  /// Evidence chain: proof, change history, and cross-references.
  /// Uses edges: [EdgeKind.proves], [EdgeKind.changedBy], [EdgeKind.references].
  evidence,
}

/// Returns the [EdgeKind] values that are eligible for a given [MapGraphMode].
///
/// This is the single source of truth for mode → edge selection rules.
/// Projection code and tests both use this function so the rules cannot
/// drift apart.
Set<EdgeKind> edgeKindsForMode(MapGraphMode mode) {
  switch (mode) {
    case MapGraphMode.containment:
      return const {EdgeKind.contains, EdgeKind.routesTo};
    case MapGraphMode.operational:
      return const {EdgeKind.uses, EdgeKind.dependsOn, EdgeKind.routesTo};
    case MapGraphMode.evidence:
      return const {EdgeKind.proves, EdgeKind.changedBy, EdgeKind.references};
  }
}

/// Human-readable label for a mode, suitable for UI display.
String labelForMode(MapGraphMode mode) {
  switch (mode) {
    case MapGraphMode.containment:
      return 'Containment';
    case MapGraphMode.operational:
      return 'Operational';
    case MapGraphMode.evidence:
      return 'Evidence';
  }
}
