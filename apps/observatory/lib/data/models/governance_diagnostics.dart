/// Typed governance diagnostic primitives for the ASW Observatory.
///
/// These types provide a structured surface for diagnostic payloads that
/// downstream services (graph analyzer, governance panel, health dashboard)
/// can compute and the UI can render without re-deriving severity or
/// category from raw strings.
library;

import 'package:flutter/foundation.dart';

/// Severity level for governance diagnostics.
enum DiagnosticSeverity {
  /// Informational — no action required, just visibility.
  info,

  /// Warning — potential issue that should be reviewed.
  warning,

  /// Error — definite issue requiring attention.
  error,

  /// Critical — blocking issue requiring immediate action.
  critical,
}

/// Category of governance diagnostic.
///
/// ## Implemented emitters ([WorkspaceDiagnosticsService])
/// - [orphanAsset], [staleReference], [proofGap], [missingDependency],
///   [reviewPressure], [highFanIn]
///
/// ## Reserved / deferred (enum surface for UI filters + future rules)
/// - [brokenEdge] — structural invalid edge (distinct from high fan-in)
/// - [canonicalityDrift], [staleIndex], [childParentDrift]
///
/// Deferred values may appear as zero-count keys in
/// [DiagnosticsReport.countsByCategory] until a rule is shipped.
enum DiagnosticCategory {
  /// An asset with no incoming or outgoing edges (isolated node).
  orphanAsset,

  /// An edge pointing to an asset that no longer exists or moved.
  staleReference,

  /// A task claiming completion but lacking required proof/evidence.
  proofGap,

  /// A task in the review lane under elevated priority pressure.
  reviewPressure,

  /// An asset whose canonicality doesn't match its expected provenance.
  canonicalityDrift,

  /// A declared dependency that cannot be resolved to a known asset.
  missingDependency,

  /// An edge with invalid source or target (not fan-in overload).
  brokenEdge,

  /// High incoming-edge concentration (structural hotspot).
  ///
  /// Distinct from [brokenEdge]: fan-in is about dependency centrality,
  /// not edge validity. Governance hotspot panels key off this category.
  highFanIn,

  /// A generated index that is out of date relative to its source assets.
  staleIndex,

  /// A child asset diverged from its parent canonical definition.
  childParentDrift,
}

/// Categories currently produced by [WorkspaceDiagnosticsService.analyze].
const Set<DiagnosticCategory> kImplementedDiagnosticCategories = {
  DiagnosticCategory.orphanAsset,
  DiagnosticCategory.staleReference,
  DiagnosticCategory.proofGap,
  DiagnosticCategory.reviewPressure,
  DiagnosticCategory.missingDependency,
  DiagnosticCategory.highFanIn,
};

/// Categories reserved for future rules (never silent — documented deferred).
const Set<DiagnosticCategory> kDeferredDiagnosticCategories = {
  DiagnosticCategory.brokenEdge,
  DiagnosticCategory.canonicalityDrift,
  DiagnosticCategory.staleIndex,
  DiagnosticCategory.childParentDrift,
};

/// A single governance diagnostic entry.
///
/// Produced by analysis services and consumed by the UI governance panel.
@immutable
class GovernanceDiagnostic {
  /// The asset id this diagnostic relates to.
  final String assetId;

  /// Severity level.
  final DiagnosticSeverity severity;

  /// Diagnostic category.
  final DiagnosticCategory category;

  /// Human-readable message describing the issue.
  final String message;

  /// Additional context for the diagnostic (e.g., expected vs actual values).
  final Map<String, dynamic> context;

  /// When this diagnostic was computed.
  final DateTime computedAt;

  const GovernanceDiagnostic({
    required this.assetId,
    required this.severity,
    required this.category,
    required this.message,
    this.context = const {},
    required this.computedAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GovernanceDiagnostic &&
          runtimeType == other.runtimeType &&
          assetId == other.assetId &&
          severity == other.severity &&
          category == other.category &&
          message == other.message;

  @override
  int get hashCode => Object.hash(assetId, severity, category, message);

  @override
  String toString() =>
      'GovernanceDiagnostic($assetId, ${severity.name}/${category.name}: $message)';
}

/// Extension to parse [DiagnosticSeverity] from numeric or string values.
extension DiagnosticSeverityParsing on DiagnosticSeverity {
  static DiagnosticSeverity fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'info':
        return DiagnosticSeverity.info;
      case 'warning':
        return DiagnosticSeverity.warning;
      case 'error':
        return DiagnosticSeverity.error;
      case 'critical':
        return DiagnosticSeverity.critical;
      default:
        return DiagnosticSeverity.info;
    }
  }

  /// Numeric weight for sorting (higher = more severe).
  int get weight {
    switch (this) {
      case DiagnosticSeverity.info:
        return 0;
      case DiagnosticSeverity.warning:
        return 1;
      case DiagnosticSeverity.error:
        return 2;
      case DiagnosticSeverity.critical:
        return 3;
    }
  }
}
