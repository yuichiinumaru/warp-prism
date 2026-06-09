/// Governance boundary legend widget.
///
/// Explains the six canonicality classes (canonical, child-local,
/// generated, append-only, archive, mock) with colors, icons, and
/// descriptive tooltips sourced from existing DS tokens.
library;

import 'package:flutter/material.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// Canonicality class descriptors for the legend.
class CanonicalityClass {
  final String key;
  final String label;
  final String description;
  final Color color;
  final IconData icon;

  const CanonicalityClass({
    required this.key,
    required this.label,
    required this.description,
    required this.color,
    required this.icon,
  });
}

/// The six canonicality boundary classes the Observatory tracks.
const _canonicalityClasses = [
  CanonicalityClass(
    key: 'parentCanonical',
    label: 'Canonical',
    description: 'Authoritative source of truth. Parent-owned markdown that downstream consumers trust.',
    color: DSColors.governanceCanonical,
    icon: DSIcons.canonical,
  ),
  CanonicalityClass(
    key: 'childLocal',
    label: 'Child-Local',
    description: 'Local overlay that may diverge from its parent canonical definition.',
    color: DSColors.governanceLocal,
    icon: DSIcons.local,
  ),
  CanonicalityClass(
    key: 'generated',
    label: 'Generated',
    description: 'Computed or built from other sources. Not hand-authored; derived from canonical data.',
    color: DSColors.governanceGenerated,
    icon: DSIcons.generated,
  ),
  CanonicalityClass(
    key: 'appendOnly',
    label: 'Append-Only',
    description: 'Immutable ledger. New entries may be added, but existing records cannot be modified.',
    color: DSColors.governanceAppendOnly,
    icon: DSIcons.appendOnly,
  ),
  CanonicalityClass(
    key: 'archive',
    label: 'Archive',
    description: 'Historical record, no longer actively maintained or referenced by live workflows.',
    color: DSColors.governanceArchive,
    icon: DSIcons.archive,
  ),
  CanonicalityClass(
    key: 'mock',
    label: 'Mock',
    description: 'Test or demo data. Should not be treated as production content.',
    color: DSColors.governanceMock,
    icon: DSIcons.mock,
  ),
];

/// Legend widget showing canonicality boundary classes.
///
/// Optionally displays counts from diagnostics so the legend
/// becomes a quantitative overview rather than just a key.
class GovernanceBoundaryLegend extends StatelessWidget {
  /// Counts per canonicality class (key → count). Optional.
  final Map<String, int>? counts;

  const GovernanceBoundaryLegend({super.key, this.counts});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Canonicality boundary legend',
      explicitChildNodes: true,
      child: Container(
        padding: const EdgeInsets.all(DSSpacing.lg),
        decoration: BoxDecoration(
          color: DSColors.obsidianElevated,
          borderRadius: BorderRadius.circular(DSRadii.lg),
          border: Border.all(color: DSColors.borderSubtle),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DSText.labelLarge(
              'CANONICALITY BOUNDARIES',
              color: DSColors.textSecondary,
            ),
            const SizedBox(height: DSSpacing.md),
            ..._canonicalityClasses.map((cls) => _LegendRow(
                  cls: cls,
                  count: counts?[cls.key],
                )),
          ],
        ),
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  final CanonicalityClass cls;
  final int? count;

  const _LegendRow({required this.cls, this.count});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: cls.description,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: DSSpacing.xs),
        child: Row(
          children: [
            // Color indicator
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: cls.color,
                borderRadius: BorderRadius.circular(DSRadii.full),
              ),
            ),
            const SizedBox(width: DSSpacing.sm),

            // Icon
            DSIcon.small(cls.icon, color: cls.color),
            const SizedBox(width: DSSpacing.sm),

            // Label
            Expanded(
              child: DSText.bodyMedium(cls.label, color: cls.color),
            ),

            // Count
            if (count != null)
              DSText.numeric(
                count.toString(),
                color: cls.color,
              ),
          ],
        ),
      ),
    );
  }
}

/// Read-only disclaimer banner shown on the Governance page.
class GovernanceReadOnlyBanner extends StatelessWidget {
  const GovernanceReadOnlyBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.lg,
        vertical: DSSpacing.md,
      ),
      decoration: BoxDecoration(
        color: DSColors.accentCyan.withOpacity(0.08),
        border: Border(
          bottom: BorderSide(color: DSColors.accentCyan.withOpacity(0.2)),
        ),
      ),
      child: Row(
        children: [
          DSIcon(Icons.lock_outline, color: DSColors.accentCyan, size: 18),
          const SizedBox(width: DSSpacing.sm),
          Expanded(
            child: DSText.bodySmall(
              'This surface is read-only. Governance boundaries are derived from repository diagnostics — no mutation affordances are provided.',
              color: DSColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
