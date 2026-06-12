import 'package:flutter/material.dart';
import '../tokens/tokens.dart';
import '../atoms/atoms.dart';
import 'ds_uptime_bar.dart';

/// ASW Observatory Molecule — Health Card
///
/// Compound health indicator combining service name, operational state,
/// latency, uptime percentage, and trend sparkline in a single glanceable
/// glass-panel card.
///
/// Contract:
/// - Displays [DSStatusDot] for the current [DSOperationalState].
/// - Shows [serviceName] as title.
/// - Shows [latency] as subtitle with ms unit (when provided).
/// - Shows [DSUptimeBar] if [uptimePercent] is provided.
/// - Shows [DSSparkline] if [trendData] is provided.
/// - Shows [lastCheck] timestamp in footer (when provided).
/// - All null/optional fields are gracefully omitted.
/// - Wraps in [Semantics] for screen reader accessibility.
class DSHealthCard extends StatelessWidget {
  /// Name of the service or entity being monitored.
  final String serviceName;

  /// Current operational state.
  final DSOperationalState operationalState;

  /// Response latency (optional).
  final Duration? latency;

  /// Uptime percentage as 0.0–1.0 (optional).
  final double? uptimePercent;

  /// Trend data points for the sparkline (optional).
  final List<double>? trendData;

  /// Timestamp of the last health check (optional).
  final DateTime? lastCheck;

  /// Optional tap handler.
  final VoidCallback? onTap;

  const DSHealthCard({
    super.key,
    required this.serviceName,
    required this.operationalState,
    this.latency,
    this.uptimePercent,
    this.trendData,
    this.lastCheck,
    this.onTap,
  });

  String _formatLatency(Duration duration) {
    if (duration.inMilliseconds < 1000) {
      return '${duration.inMilliseconds}ms';
    }
    return '${(duration.inMilliseconds / 1000).toStringAsFixed(1)}s';
  }

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final stateColor = operationalState.color;

    return Semantics(
      label: '${operationalState.label} $serviceName',
      button: onTap != null,
      child: GestureDetector(
        onTap: onTap,
        child: MouseRegion(
          cursor: onTap != null
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
          child: DSGlassPanelSimple(
            padding: const EdgeInsets.all(DSSpacing.insetCard),
            borderColor: stateColor.withValues(alpha: 0.3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header row: status dot + service name + latency
                Row(
                  children: [
                    DSStatusDot(
                      color: stateColor,
                      size: 10,
                      animated: operationalState == DSOperationalState.running,
                      tooltip: operationalState.semanticLabel,
                    ),
                    const SizedBox(width: DSSpacing.sm),
                    Expanded(
                      child: DSText.labelLarge(
                        serviceName,
                        color: DSColors.textPrimary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (latency != null)
                      DSText.labelSmall(
                        _formatLatency(latency!),
                        color: DSColors.textTertiary,
                      ),
                  ],
                ),

                // State label
                const SizedBox(height: DSSpacing.xs),
                DSText.labelSmall(operationalState.label, color: stateColor),

                // Uptime bar
                if (uptimePercent != null) ...[
                  const SizedBox(height: DSSpacing.sm),
                  DSUptimeBar(uptimePercent: uptimePercent!),
                ],

                // Sparkline
                if (trendData != null && trendData!.isNotEmpty) ...[
                  const SizedBox(height: DSSpacing.sm),
                  SizedBox(
                    height: 32,
                    child: DSSparkline(
                      data: trendData!,
                      color: stateColor,
                      semanticLabel:
                          '$serviceName trend: ${trendData!.length} data points',
                    ),
                  ),
                ],

                // Last check footer
                if (lastCheck != null) ...[
                  const SizedBox(height: DSSpacing.xs),
                  DSText.labelSmall(
                    'Last check: ${_formatTimestamp(lastCheck!)}',
                    color: DSColors.textTertiary,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
