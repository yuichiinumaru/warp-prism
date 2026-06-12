/// Fan-in hotspots panel for Governance analytics.
///
/// Renders ranked incoming-link hotspots from the diagnostics service.
/// Each hotspot shows the asset name, incoming edge count, and an
/// explanation of why high fan-in is operationally risky.
library;

import 'package:flutter/material.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';
import 'package:warp_prism_observatory/data/models/governance_diagnostics.dart';

/// A ranked fan-in hotspot entry.
@immutable
class FanInHotspot {
  final String assetId;
  final String assetName;
  final String assetKind;
  final int incomingEdgeCount;
  final int threshold;
  final DiagnosticSeverity severity;

  const FanInHotspot({
    required this.assetId,
    required this.assetName,
    required this.assetKind,
    required this.incomingEdgeCount,
    required this.threshold,
    required this.severity,
  });

  /// Risk explanation based on the hotspot's characteristics.
  String get riskExplanation {
    final ratio = incomingEdgeCount / threshold;
    if (ratio >= 2) {
      return '$assetName has ${incomingEdgeCount}× the threshold ($threshold). '
          'This asset is a critical hub — changes to it will cascade widely '
          'across dependent assets.';
    }
    return '$assetName has $incomingEdgeCount incoming references '
        '(threshold: $threshold). High fan-in means many assets depend on '
        'this, making it a structural hotspot.';
  }

  /// Extract fan-in hotspots from diagnostics.
  static List<FanInHotspot> fromDiagnostics(
    List<GovernanceDiagnostic> diagnostics,
  ) {
    final hotspots =
        diagnostics
            .where((d) => d.category == DiagnosticCategory.brokenEdge)
            .map((d) {
              final ctx = d.context;
              return FanInHotspot(
                assetId: d.assetId,
                assetName: ctx['assetName']?.toString() ?? d.assetId,
                assetKind: ctx['assetKind']?.toString() ?? 'unknown',
                incomingEdgeCount:
                    (ctx['incomingEdgeCount'] as num?)?.toInt() ?? 0,
                threshold: (ctx['threshold'] as num?)?.toInt() ?? 3,
                severity: d.severity,
              );
            })
            .toList()
          ..sort((a, b) => b.incomingEdgeCount.compareTo(a.incomingEdgeCount));
    return hotspots;
  }
}

/// Renders ranked fan-in hotspots as a panel.
///
/// Shows the most depended-on assets with explanatory copy.
/// Includes a healthy empty state when no hotspots exceed threshold.
class FanInHotspotsPanel extends StatelessWidget {
  final List<FanInHotspot> hotspots;

  const FanInHotspotsPanel({super.key, required this.hotspots});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DSColors.obsidianElevated,
        borderRadius: BorderRadius.circular(DSRadii.lg),
        border: Border.all(color: DSColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(DSSpacing.lg),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: DSColors.statusWarning.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(DSRadii.md),
                  ),
                  child: DSIcon(
                    Icons.hub_outlined,
                    color: DSColors.statusWarning,
                  ),
                ),
                const SizedBox(width: DSSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DSText.headingSmall('Fan-In Hotspots'),
                      const SizedBox(height: 2),
                      DSText.bodySmall(
                        'Assets with the highest incoming reference load',
                        color: DSColors.textSecondary,
                      ),
                    ],
                  ),
                ),
                if (hotspots.isNotEmpty)
                  _SeverityBadge(
                    count: hotspots.length,
                    color: DSColors.statusWarning,
                  ),
              ],
            ),
          ),

          const DSDivider.subtle(),

          // Content
          if (hotspots.isEmpty)
            _buildHealthyState()
          else
            ...hotspots.asMap().entries.map((entry) {
              return _HotspotRow(rank: entry.key + 1, hotspot: entry.value);
            }),

          const SizedBox(height: DSSpacing.sm),
        ],
      ),
    );
  }

  Widget _buildHealthyState() {
    return Padding(
      padding: const EdgeInsets.all(DSSpacing.lg),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 16,
            color: DSColors.statusSuccess,
          ),
          const SizedBox(width: DSSpacing.sm),
          Expanded(
            child: DSText.bodySmall(
              'No fan-in hotspots detected. All assets are within normal '
              'incoming-reference thresholds.',
              color: DSColors.statusSuccess,
            ),
          ),
        ],
      ),
    );
  }
}

class _HotspotRow extends StatelessWidget {
  final int rank;
  final FanInHotspot hotspot;

  const _HotspotRow({required this.rank, required this.hotspot});

  @override
  Widget build(BuildContext context) {
    final severityColor = hotspot.severity == DiagnosticSeverity.error
        ? DSColors.statusError
        : DSColors.statusWarning;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.lg,
        vertical: DSSpacing.xs,
      ),
      child: Container(
        padding: const EdgeInsets.all(DSSpacing.sm),
        decoration: BoxDecoration(
          color: DSColors.obsidianBase,
          borderRadius: BorderRadius.circular(DSRadii.sm),
          border: Border(left: BorderSide(color: severityColor, width: 3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rank
            Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: severityColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(DSRadii.sm),
              ),
              child: DSText.labelSmall(rank.toString(), color: severityColor),
            ),
            const SizedBox(width: DSSpacing.sm),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      DSText.labelMedium(hotspot.assetName),
                      const SizedBox(width: DSSpacing.xs),
                      DSChip(label: hotspot.assetKind),
                    ],
                  ),
                  const SizedBox(height: 4),
                  DSText.bodySmall(
                    hotspot.riskExplanation,
                    color: DSColors.textSecondary,
                  ),
                ],
              ),
            ),

            // Edge count
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                DSText(
                  hotspot.incomingEdgeCount.toString(),
                  variant: DSTextVariant.numericMedium,
                  color: severityColor,
                ),
                DSText.labelSmall('incoming', color: DSColors.textTertiary),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SeverityBadge extends StatelessWidget {
  final int count;
  final Color color;

  const _SeverityBadge({required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(DSRadii.sm),
      ),
      child: DSText.labelSmall(
        '$count hotspot${count == 1 ? '' : 's'}',
        color: color,
      ),
    );
  }
}
