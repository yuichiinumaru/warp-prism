import 'package:flutter/material.dart';

import '../atoms/ds_meter.dart';
import '../tokens/tokens.dart';

/// Channel fader strip molecule (Task 1861, F-13 — EXPERIMENTAL).
///
/// Composes a [DSMeter] (injected scale + zone thresholds + peak-hold
/// marker), a vertical fader (drag semantics via [Slider]), a channel
/// [label], and a caller-owned dB readout slot ([dbReadout] renders
/// verbatim — Prism owns the slot chrome, never the bytes).
///
/// Donor shape (INHERITED REPORT via `docs/bridge/tempest/ads-debt.md`
/// §1.2 rows 4 and 9: channel strip and master bus strip): channel name +
/// volume control + peak meter + readout in one strip. Unlike the donors,
/// gain mapping and calibration arrive injected: the fader is a
/// normalized 0.0…1.0 control and [formatFader] renders it as text.
///
/// Lifecycle: EXPERIMENTAL. Intentionally **not** exported from any barrel
/// and without a `Prism*` alias until the promotion task wires the public
/// surface (layer-contracts §9).
class DSFaderStrip extends StatelessWidget {
  /// Injected meter scale shared with the [DSMeter] gauge.
  final DSMeterScale scale;

  /// Current meter value in caller units.
  final double meterValue;

  /// Injected peak-hold position in caller units. Null hides the marker.
  final double? peakValue;

  /// Normalized fader position (0.0…1.0, clamped). Caller maps to gain.
  final double faderValue;

  /// Fader dispatch. Null renders the fader disabled (still announced).
  final ValueChanged<double>? onFaderChanged;

  /// Channel label (e.g. `Vox`). Required — always present, always announced.
  final String label;

  /// Caller-supplied fader formatter (e.g. dB text). Same input must yield
  /// same output. Defaults to percent text.
  final String Function(double normalized) formatFader;

  /// Caller-owned readout content rendered verbatim in the readout slot.
  /// Prism owns the slot chrome; the bytes stay caller-side.
  final Widget? dbReadout;

  /// Semantic label for the meter gauge.
  final String meterSemanticLabel;

  /// Optional focus node for the fader control (keyboard navigation).
  final FocusNode? faderFocusNode;

  /// Fixed meter paint width.
  final double meterWidth;

  /// Fixed meter paint height; the fader track matches it.
  final double meterHeight;

  const DSFaderStrip({
    super.key,
    required this.scale,
    required this.meterValue,
    this.peakValue,
    required this.faderValue,
    this.onFaderChanged,
    required this.label,
    String Function(double normalized)? formatFader,
    this.dbReadout,
    this.meterSemanticLabel = 'Level meter',
    this.faderFocusNode,
    this.meterWidth = 56.0,
    this.meterHeight = 180.0,
  }) : assert(
         faderValue >= 0.0 && faderValue <= 1.0,
         'DSFaderStrip: faderValue must be 0.0…1.0',
       ),
       formatFader = formatFader ?? _defaultFormatFader;

  static String _defaultFormatFader(double normalized) =>
      '${(normalized.clamp(0.0, 1.0) * 100).round()}%';

  /// Screen-reader announcement: label plus meter value plus fader value.
  /// Position is never colour-only.
  String get announcement =>
      '$label. ${scale.formatValue(meterValue)}. '
      'Fader ${formatFader(faderValue.clamp(0.0, 1.0))}.';

  @override
  Widget build(BuildContext context) {
    final readout = dbReadout;
    return Semantics(
      container: true,
      label: announcement,
      child: Container(
        padding: const EdgeInsets.all(DSSpacing.sm),
        decoration: BoxDecoration(
          color: DSColors.obsidianElevated,
          borderRadius: BorderRadius.circular(DSRadii.md),
          border: Border.all(color: DSColors.borderSubtle, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ExcludeSemantics(
              // The label heads the outer announcement verbatim; excluding
              // the raw text keeps the announcement exact (no trailing dup).
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: DSTypography.labelMedium.copyWith(
                  color: DSColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: DSSpacing.sm),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ExcludeSemantics(
                  // The gauge value is already inside the outer announcement
                  // (value + zone + peak); the live control below is the
                  // Slider, which keeps its own semantics.
                  child: DSMeter(
                    scale: scale,
                    value: meterValue,
                    peakValue: peakValue,
                    width: meterWidth,
                    height: meterHeight,
                    semanticLabel: meterSemanticLabel,
                  ),
                ),
                const SizedBox(width: DSSpacing.sm),
                // Vertical fader: fixed-height track matching the meter.
                // RotatedBox keeps Slider drag + a11y semantics intact while
                // painting vertically (donor fader-slider posture).
                SizedBox(
                  width: 48,
                  height: meterHeight,
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 4,
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 12,
                        ),
                      ),
                      child: Slider(
                        value: faderValue.clamp(0.0, 1.0),
                        onChanged: onFaderChanged,
                        focusNode: faderFocusNode,
                        semanticFormatterCallback: (value) =>
                            formatFader(value),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (readout != null) ...[
              const SizedBox(height: DSSpacing.xs),
              // Slot chrome is Prism-owned; the bytes are caller-owned and
              // render verbatim. Never parsed or converted here.
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DSSpacing.sm,
                  vertical: DSSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: DSColors.obsidianBase,
                  borderRadius: BorderRadius.circular(DSRadii.sm),
                  border: Border.all(color: DSColors.borderSubtle, width: 1),
                ),
                child: readout,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
