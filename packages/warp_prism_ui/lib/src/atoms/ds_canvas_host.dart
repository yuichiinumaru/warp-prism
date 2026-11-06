import 'package:flutter/material.dart';

import '../tokens/tokens.dart';

/// Narrow generic canvas-host contract (Task 1861, F-13 — EXPERIMENTAL).
///
/// A canvas host pins a **fixed viewport** ([DSCanvasHostSpec.viewportSize]),
/// bounds the data it will paint ([DSCanvasHostSpec.maxDataPoints]), and
/// always carries an **a11y numeric fallback** ([DSCanvasHost.semanticValue])
/// so content is never colour-only.
///
/// Calibration, domain units, and data semantics stay caller-side: Prism owns
/// only the fixed-size box, the clipping, the placeholder chrome, and the
/// announcement contract. No audio types, no consumer domain types, no
/// calibration types appear here.
///
/// Lifecycle: EXPERIMENTAL. Intentionally **not** exported from any barrel
/// and without a `Prism*` alias until the promotion task wires the public
/// surface (layer-contracts §9).
class DSCanvasHostSpec {
  /// Fixed paint viewport. Identical input must paint identical output.
  final Size viewportSize;

  /// Upper bound on data points the host will carry into paint.
  ///
  /// [clampData] truncates older entries first, keeping the newest
  /// [maxDataPoints] values. Must be positive.
  final int maxDataPoints;

  /// Placeholder label rendered when [DSCanvasHost.placeholder] is true.
  final String placeholderLabel;

  const DSCanvasHostSpec({
    required this.viewportSize,
    this.maxDataPoints = 512,
    this.placeholderLabel = 'Canvas placeholder',
  }) : assert(maxDataPoints > 0, 'maxDataPoints must be positive');

  /// Returns at most the newest [maxDataPoints] entries of [data].
  List<double> clampData(List<double> data) {
    if (data.length <= maxDataPoints) return List<double>.of(data);
    return data.sublist(data.length - maxDataPoints);
  }

  /// Whether [data] fits without truncation.
  bool fits(List<double> data) => data.length <= maxDataPoints;
}

/// Fixed-viewport canvas host with placeholder determinism and a11y fallback.
///
/// - Paints [painter] at exactly [spec].[DSCanvasHostSpec.viewportSize].
/// - When [placeholder] is true, renders static placeholder chrome instead
///   of the painter (deterministic layout, no animation).
/// - Always announces [semanticLabel] plus the caller-formatted numeric
///   [semanticValue] to assistive technology; content is never colour-only.
class DSCanvasHost extends StatelessWidget {
  /// Fixed-viewport + bounded-data contract for this host.
  final DSCanvasHostSpec spec;

  /// Painter for the live surface. Unused when [placeholder] is true.
  final CustomPainter painter;

  /// Screen-reader label prefix. [semanticValue] is appended verbatim.
  final String semanticLabel;

  /// Caller-formatted numeric value (e.g. `-12.0 dB`). Required: the
  /// numeric fallback that keeps the surface off colour-only semantics.
  final String semanticValue;

  /// Whether to render the deterministic placeholder instead of [painter].
  final bool placeholder;

  const DSCanvasHost({
    super.key,
    required this.spec,
    required this.painter,
    required this.semanticLabel,
    required this.semanticValue,
    this.placeholder = false,
  });

  /// Full screen-reader announcement: label plus numeric value.
  String get announcement => '$semanticLabel: $semanticValue';

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: announcement,
      readOnly: true,
      child: SizedBox.fromSize(
        size: spec.viewportSize,
        child: placeholder ? _buildPlaceholder() : _buildLive(),
      ),
    );
  }

  Widget _buildLive() {
    return ClipRect(
      child: CustomPaint(size: spec.viewportSize, painter: painter),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: spec.viewportSize.width,
      height: spec.viewportSize.height,
      decoration: BoxDecoration(
        color: DSColors.obsidianElevated,
        borderRadius: BorderRadius.circular(DSRadii.sm),
        border: Border.all(color: DSColors.borderSubtle, width: 1),
      ),
      child: Center(
        child: ExcludeSemantics(
          // The numeric value is already announced by the outer Semantics.
          child: Text(
            spec.placeholderLabel,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: DSTypography.labelSmall.copyWith(
              color: DSColors.textTertiary,
            ),
          ),
        ),
      ),
    );
  }
}
