/// Governance drilldown controller.
///
/// Translates governance findings (diagnostics, hotspots, issue groups)
/// into navigation state for the universal asset detail route or
/// inspector. This is the bridge between governance warnings and the
/// detail surface — warnings are no longer dead text.
library;

import 'package:flutter/foundation.dart';
import 'package:warp_prism_observatory/app/asset_selection_controller.dart';
import 'package:warp_prism_observatory/data/models/governance_diagnostics.dart';
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

  /// Whether this target can be navigated (false for unresolved IDs).
  final bool isNavigable;

  const GovernanceDrilldownTarget({
    required this.assetId,
    required this.routePath,
    required this.sourceLabel,
    this.category,
    this.isNavigable = true,
  });

  /// Fallback target when an asset ID cannot be resolved.
  ///
  /// Preserves the attempted ID for inspector display without claiming
  /// a navigable detail route.
  factory GovernanceDrilldownTarget.unresolved({
    required String attemptedId,
    required String sourceLabel,
    DiagnosticCategory? category,
  }) {
    return GovernanceDrilldownTarget(
      assetId: attemptedId,
      routePath: AssetSelectionController.detailRoute(
        attemptedId.isEmpty ? 'unknown' : attemptedId,
      ),
      sourceLabel: sourceLabel,
      category: category,
      isNavigable: false,
    );
  }

  @override
  String toString() =>
      'GovernanceDrilldownTarget($assetId, from: $sourceLabel, '
      'navigable: $isNavigable)';
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
  if (assetId.isEmpty || assetId == 'unknown') return null;

  return GovernanceDrilldownTarget(
    assetId: assetId,
    routePath: AssetSelectionController.detailRoute(assetId),
    sourceLabel: '${diagnostic.category.name}: ${diagnostic.message}',
    category: diagnostic.category,
  );
}

/// Resolves a [FanInHotspot] into a [GovernanceDrilldownTarget].
///
/// Returns an unresolved fallback when the hotspot asset ID is empty so
/// callers can degrade gracefully without crashing the panel.
GovernanceDrilldownTarget resolveHotspotDrilldown(FanInHotspot hotspot) {
  if (hotspot.assetId.isEmpty || hotspot.assetId == 'unknown') {
    return GovernanceDrilldownTarget.unresolved(
      attemptedId: hotspot.assetId,
      sourceLabel:
          'Fan-in hotspot: ${hotspot.assetName} '
          '(${hotspot.incomingEdgeCount} incoming)',
    );
  }

  return GovernanceDrilldownTarget(
    assetId: hotspot.assetId,
    routePath: AssetSelectionController.detailRoute(hotspot.assetId),
    sourceLabel:
        'Fan-in hotspot: ${hotspot.assetName} '
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
    routePath: AssetSelectionController.detailRoute(assetId),
    sourceLabel: 'Direct navigation to $assetId',
  );
}
