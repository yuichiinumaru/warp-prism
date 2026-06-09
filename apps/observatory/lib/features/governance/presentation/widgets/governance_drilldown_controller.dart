/// Governance drilldown controller.
///
/// Translates governance findings (diagnostics, hotspots, issue groups)
/// into navigation state for the universal asset detail route or
/// inspector. This is the bridge between governance warnings and the
/// detail surface — warnings are no longer dead text.
library;

import 'package:flutter/foundation.dart';
import '../../../../data/models/governance_diagnostics.dart';
import 'fan_in_hotspots_panel.dart';

// ---------------------------------------------------------------------------
// Drilldown Target
// ---------------------------------------------------------------------------

/// The resolved navigation target for a governance finding.
@immutable
class GovernanceDrilldownTarget {
  /// The stable asset ID to navigate to.
  final String assetId;

  /// The canonical detail route path (/assets/:assetId).
  final String routePath;

  /// Human-readable label for the finding that triggered this drilldown.
  final String sourceLabel;

  /// Category of the diagnostic that triggered this drilldown.
  final DiagnosticCategory? category;

  const GovernanceDrilldownTarget({
    required this.assetId,
    required this.routePath,
    required this.sourceLabel,
    this.category,
  });

  @override
  String toString() =>
      'GovernanceDrilldownTarget($assetId, from: $sourceLabel)';
}

// ---------------------------------------------------------------------------
// Controller
// ---------------------------------------------------------------------------

/// Resolves a [GovernanceDiagnostic] into a [GovernanceDrilldownTarget]
/// for navigation to the asset detail route.
///
/// Returns null if the diagnostic lacks a valid asset ID (graceful
/// degradation for diagnostics that reference non-navigable entities).
GovernanceDrilldownTarget? resolveDiagnosticDrilldown(
  GovernanceDiagnostic diagnostic,
) {
  final assetId = diagnostic.assetId;
  if (assetId.isEmpty) return null;

  return GovernanceDrilldownTarget(
    assetId: assetId,
    routePath: '/assets/$assetId',
    sourceLabel:
        '${diagnostic.category.name}: ${diagnostic.message}',
    category: diagnostic.category,
  );
}

/// Resolves a [FanInHotspot] into a [GovernanceDrilldownTarget].
GovernanceDrilldownTarget resolveHotspotDrilldown(FanInHotspot hotspot) {
  return GovernanceDrilldownTarget(
    assetId: hotspot.assetId,
    routePath: '/assets/${hotspot.assetId}',
    sourceLabel: 'Fan-in hotspot: ${hotspot.assetName} '
        '(${hotspot.incomingEdgeCount} incoming)',
  );
}

/// Resolves a raw asset ID string into a drilldown target.
///
/// Returns null for empty or clearly invalid IDs.
GovernanceDrilldownTarget? resolveAssetIdDrilldown(String assetId) {
  if (assetId.isEmpty || assetId == 'unknown') return null;

  return GovernanceDrilldownTarget(
    assetId: assetId,
    routePath: '/assets/$assetId',
    sourceLabel: 'Direct navigation to $assetId',
  );
}
