import 'package:flutter/material.dart';
import '../tokens/tokens.dart';

/// Lineage Strip — SAME | DIFFER / derived-from marker (Task 1872,
/// EXPERIMENTAL).
///
/// Passive display of a consumer-computed relation between two provenance
/// records (consumer compare-strip SAME|DIFFER donor, re-verified live
/// against the sibling consumer checkout). The relation arrives as [DSLineageRelation] data —
/// Prism performs no causation computation and no field comparison.
///
/// Display only: never routing input, never a mutation surface, zero
/// interactive affordances in every relation.
///
/// EXPERIMENTAL: no layer-barrel export, no `Prism` alias (promotion defers
/// to the STABLE task, which must update the boundary harness).
class DSLineageStrip extends StatelessWidget {
  /// Consumer-computed relation between two records.
  final DSLineageRelation relation;

  /// Opaque endpoint labels for the derived-from form. Ignored by SAME and
  /// DIFFER, which compare nothing and name no endpoint.
  final String? sourceLabel;
  final String? targetLabel;

  const DSLineageStrip({
    super.key,
    required this.relation,
    this.sourceLabel,
    this.targetLabel,
  });

  /// Token color per relation. All three are mutually distinct.
  Color colorFor(DSLineageRelation value) {
    switch (value) {
      case DSLineageRelation.same:
        return DSColors.statusSuccess;
      case DSLineageRelation.differ:
        return DSColors.statusError;
      case DSLineageRelation.derivedFrom:
        return DSColors.statusInfo;
    }
  }

  /// Marker text per relation.
  String markerFor(DSLineageRelation value) {
    switch (value) {
      case DSLineageRelation.same:
        return 'SAME';
      case DSLineageRelation.differ:
        return 'DIFFER';
      case DSLineageRelation.derivedFrom:
        return 'DERIVED FROM';
    }
  }

  /// Screen-reader label per relation. Never claims verification.
  String semanticFor(DSLineageRelation value) {
    switch (value) {
      case DSLineageRelation.same:
        return 'Lineage: records match';
      case DSLineageRelation.differ:
        return 'Lineage: records differ';
      case DSLineageRelation.derivedFrom:
        return 'Lineage: derived from ${sourceLabel ?? 'unknown source'}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = colorFor(relation);
    return Semantics(
      label: semanticFor(relation),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(DSRadii.sm),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_iconFor(relation), size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              markerFor(relation),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                fontFamily: 'monospace',
                color: color,
                height: 1,
              ),
            ),
            if (relation == DSLineageRelation.derivedFrom &&
                sourceLabel != null &&
                targetLabel != null) ...[
              const SizedBox(width: 4),
              // Flexible (not layout-computed content): endpoint labels yield
              // first under narrow viewports so the relation marker never
              // overflows. Relation semantics stay pure data.
              Flexible(
                child: Text(
                  '$sourceLabel → $targetLabel',
                  style: TextStyle(
                    fontSize: 11,
                    fontFamily: 'monospace',
                    color: color,
                    height: 1,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _iconFor(DSLineageRelation value) {
    switch (value) {
      case DSLineageRelation.same:
        return Icons.link;
      case DSLineageRelation.differ:
        return Icons.link_off;
      case DSLineageRelation.derivedFrom:
        return Icons.account_tree_outlined;
    }
  }
}

/// Consumer-computed lineage relation between two records.
///
/// Values arrive as data from the host (e.g. consumer compare rows);
/// Prism never derives them.
enum DSLineageRelation {
  /// The compared records agree.
  same,

  /// The compared records disagree.
  differ,

  /// The target derives from the source.
  derivedFrom,
}
