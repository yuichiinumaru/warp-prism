/// Fan-in hotspots panel for Governance analytics.
///
/// Renders ranked incoming-link hotspots from the diagnostics service.
/// Each hotspot shows the asset name, incoming edge count, and an
/// explanation of why high fan-in is operationally risky.
library;

import 'package:flutter/material.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';
import 'package:warp_prism_observatory/data/models/governance_diagnostics.dart';
import 'governance_drilldown_controller.dart';

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
  ///
  /// Threshold and counts come from diagnostics context (service contract);
  /// this getter only formats narrative copy from those values.
  String get riskExplanation {
    final safeThreshold = threshold <= 0 ? 1 : threshold;
    final ratio = incomingEdgeCount / safeThreshold;
    if (ratio >= 2) {
      return '$assetName has $incomingEdgeCount incoming references '
          '(${ratio.toStringAsFixed(1)}× threshold $threshold). '
          'This asset is a critical hub — changes to it will cascade widely '
          'across dependent assets.';
    }
    return '$assetName has $incomingEdgeCount incoming references '
        '(threshold: $threshold). High fan-in means many assets depend on '
        'this, making it a structural hotspot.';
  }

  /// Extract fan-in hotspots from diagnostics.
  ///
  /// Uses the dedicated [DiagnosticCategory.highFanIn] category emitted by
  /// [WorkspaceDiagnosticsService] (Task 0314). Threshold is read from
  /// diagnostic context rather than hard-coded in the widget layer.
  static List<FanInHotspot> fromDiagnostics(
    List<GovernanceDiagnostic> diagnostics,
  ) {
    final hotspots =
        diagnostics
            .where((d) => d.category == DiagnosticCategory.highFanIn)
            .map((d) {
              final ctx = d.context;
              return FanInHotspot(
                assetId: d.assetId,
                assetName: ctx['assetName']?.toString() ?? d.assetId,
                assetKind: ctx['assetKind']?.toString() ?? 'unknown',
                incomingEdgeCount:
                    (ctx['incomingEdgeCount'] as num?)?.toInt() ?? 0,
                threshold:
                    (ctx['threshold'] as num?)?.toInt() ??
                    WorkspaceDiagnosticsServiceFanInDefaults.threshold,
                severity: d.severity,
              );
            })
            .toList()
          ..sort((a, b) => b.incomingEdgeCount.compareTo(a.incomingEdgeCount));
    return hotspots;
  }
}

/// Defensive fallback when a diagnostic omits threshold context.
///
/// Mirrors [WorkspaceDiagnosticsService.defaultFanInThreshold] without
/// importing the service into the presentation layer.
abstract final class WorkspaceDiagnosticsServiceFanInDefaults {
  static const int threshold = 3;
}

/// Renders ranked fan-in hotspots as a panel.
///
/// Shows the most depended-on assets with explanatory copy.
/// Includes a healthy empty state when no hotspots exceed threshold.
class FanInHotspotsPanel extends StatelessWidget {
  final List<FanInHotspot> hotspots;

  /// Optional drill-down handler for hotspot asset IDs.
  final void Function(GovernanceDrilldownTarget target)? onDrilldown;

  const FanInHotspotsPanel({
    super.key,
    required this.hotspots,
    this.onDrilldown,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: PrismColors.obsidianElevated,
        borderRadius: BorderRadius.circular(PrismRadii.lg),
        border: Border.all(color: PrismColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(PrismSpacing.lg),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: PrismColors.statusWarning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(PrismRadii.md),
                  ),
                  child: const PrismIcon(
                    Icons.hub_outlined,
                    color: PrismColors.statusWarning,
                  ),
                ),
                const SizedBox(width: PrismSpacing.md),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PrismText.headingSmall('Fan-In Hotspots'),
                      SizedBox(height: 2),
                      PrismText.bodySmall(
                        'Assets with the highest incoming reference load',
                        color: PrismColors.textSecondary,
                      ),
                    ],
                  ),
                ),
                if (hotspots.isNotEmpty)
                  _SeverityBadge(
                    count: hotspots.length,
                    color: PrismColors.statusWarning,
                  ),
              ],
            ),
          ),
          const PrismDivider.subtle(),
          if (hotspots.isEmpty)
            _buildHealthyState()
          else
            ...hotspots.asMap().entries.map((entry) {
              return _HotspotRow(
                rank: entry.key + 1,
                hotspot: entry.value,
                onDrilldown: onDrilldown,
              );
            }),
          const SizedBox(height: PrismSpacing.sm),
        ],
      ),
    );
  }

  Widget _buildHealthyState() {
    return const Padding(
      padding: EdgeInsets.all(PrismSpacing.lg),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 16,
            color: PrismColors.statusSuccess,
          ),
          SizedBox(width: PrismSpacing.sm),
          Expanded(
            child: PrismText.bodySmall(
              'No fan-in hotspots detected. All assets are within normal '
              'incoming-reference thresholds.',
              color: PrismColors.statusSuccess,
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
  final void Function(GovernanceDrilldownTarget target)? onDrilldown;

  const _HotspotRow({
    required this.rank,
    required this.hotspot,
    this.onDrilldown,
  });

  @override
  Widget build(BuildContext context) {
    final severityColor = hotspot.severity == DiagnosticSeverity.error
        ? PrismColors.statusError
        : PrismColors.statusWarning;

    final target = resolveHotspotDrilldown(hotspot);
    final canDrill = target.isNavigable && onDrilldown != null;

    final row = Container(
      padding: const EdgeInsets.all(PrismSpacing.sm),
      decoration: BoxDecoration(
        color: PrismColors.obsidianBase,
        borderRadius: BorderRadius.circular(PrismRadii.sm),
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
              color: severityColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(PrismRadii.sm),
            ),
            child: PrismText.labelSmall(rank.toString(), color: severityColor),
          ),
          const SizedBox(width: PrismSpacing.sm),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    PrismText.labelMedium(hotspot.assetName),
                    const SizedBox(width: PrismSpacing.xs),
                    PrismChip(label: hotspot.assetKind),
                  ],
                ),
                const SizedBox(height: 4),
                PrismText.bodySmall(
                  hotspot.riskExplanation,
                  color: PrismColors.textSecondary,
                ),
                if (canDrill) ...[
                  const SizedBox(height: 4),
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PrismIcon.small(
                        Icons.open_in_new,
                        color: PrismColors.accentCyan,
                      ),
                      SizedBox(width: PrismSpacing.xs),
                      PrismText.labelSmall(
                        'Open detail',
                        color: PrismColors.accentCyan,
                      ),
                    ],
                  ),
                ] else if (!target.isNavigable) ...[
                  const SizedBox(height: 4),
                  const PrismText.labelSmall(
                    'Detail unavailable',
                    color: PrismColors.textTertiary,
                  ),
                ],
              ],
            ),
          ),

          // Edge count
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              PrismText(
                hotspot.incomingEdgeCount.toString(),
                variant: PrismTextVariant.numericMedium,
                color: severityColor,
              ),
              const PrismText.labelSmall(
                'incoming',
                color: PrismColors.textTertiary,
              ),
            ],
          ),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PrismSpacing.lg,
        vertical: PrismSpacing.xs,
      ),
      child: canDrill
          ? Semantics(
              button: true,
              label: 'Open asset detail for ${hotspot.assetId}',
              child: InkWell(
                onTap: () => onDrilldown!(target),
                borderRadius: BorderRadius.circular(PrismRadii.sm),
                child: row,
              ),
            )
          : row,
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
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(PrismRadii.sm),
      ),
      child: PrismText.labelSmall(
        '$count hotspot${count == 1 ? '' : 's'}',
        color: color,
      ),
    );
  }
}
