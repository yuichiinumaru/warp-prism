import 'package:flutter/material.dart';
import '../tokens/tokens.dart';
import '../atoms/atoms.dart';

/// ASW Observatory Molecule — Uptime Bar
///
/// Horizontal bar visualizing uptime percentage with threshold coloring.
///
/// Contract:
/// - Accepts [uptimePercent] as 0.0–1.0.
/// - Threshold coloring: green (>0.99), amber (>0.95), red (≤0.95).
/// - Displays the uptime percentage as a text label.
/// - Renders a semantic label for screen readers.
/// - Height defaults to 6px for the bar track.
class DSUptimeBar extends StatelessWidget {
  /// Uptime percentage as a fraction 0.0–1.0.
  final double uptimePercent;

  /// Optional color override. If null, uses threshold-based coloring.
  final Color? color;

  /// Height of the bar track. Default 6.
  final double height;

  /// Whether to show the percentage text label. Default true.
  final bool showLabel;

  /// Minimum width for the fill to be visible even at 0%. Default 2.
  final double minFillWidth;

  const DSUptimeBar({
    super.key,
    required this.uptimePercent,
    this.color,
    this.height = 6,
    this.showLabel = true,
    this.minFillWidth = 2,
  });

  /// Color derived from uptime thresholds.
  ///
  /// - >0.99 → statusSuccess (green)
  /// - >0.95 → statusWarning (amber)
  /// - ≤0.95 → statusError (red)
  Color get _thresholdColor {
    if (uptimePercent > 0.99) return DSColors.statusSuccess;
    if (uptimePercent > 0.95) return DSColors.statusWarning;
    return DSColors.statusError;
  }

  /// Human-readable uptime percentage string.
  String get _percentLabel {
    final pct = (uptimePercent * 100).clamp(0, 100);
    if (pct == pct.roundToDouble()) {
      return '${pct.toStringAsFixed(0)}%';
    }
    return '${pct.toStringAsFixed(1)}%';
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? _thresholdColor;
    final clampedPercent = uptimePercent.clamp(0.0, 1.0);

    return Semantics(
      label: 'Uptime $_percentLabel',
      value: _percentLabel,
      child: Row(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final trackWidth = constraints.maxWidth;
                final fillWidth = (trackWidth * clampedPercent).clamp(
                  minFillWidth,
                  trackWidth,
                );

                return Container(
                  height: height,
                  decoration: BoxDecoration(
                    color: DSColors.obsidianHover,
                    borderRadius: BorderRadius.circular(height / 2),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: AnimatedContainer(
                      duration: DSMotion.normal,
                      curve: DSMotion.standard,
                      width: fillWidth,
                      height: height,
                      decoration: BoxDecoration(
                        color: effectiveColor,
                        borderRadius: BorderRadius.circular(height / 2),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (showLabel) ...[
            const SizedBox(width: DSSpacing.sm),
            DSText.labelSmall(_percentLabel, color: effectiveColor),
          ],
        ],
      ),
    );
  }
}
