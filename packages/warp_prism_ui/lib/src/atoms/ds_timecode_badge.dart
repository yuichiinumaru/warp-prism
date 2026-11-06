import 'package:flutter/material.dart';

import '../tokens/tokens.dart';

/// Caller-supplied formatter for a position/duration readout.
///
/// Prism owns no time ontology: seconds are opaque caller numbers and the
/// returned string is rendered verbatim. Same input must yield the same
/// string (formatter determinism is proven by the conformance suite).
typedef DSTransportFormatTime =
    String Function(double positionSeconds, double durationSeconds);

/// Timecode badge — injected-formatter position readout atom.
///
/// Renders `formatTime(positionSeconds, durationSeconds)` verbatim in a
/// monospace badge. The caller owns all temporal semantics (rational time,
/// timecode frames, wall-clock mapping); this atom never parses, computes,
/// or advances time — it only displays the injected string.
///
/// Donor shape (INHERITED-REPORT via `docs/bridge/warpblade/ads-debt.md` §3.3
/// `TimecodeDisplayBadge` and `docs/bridge/tempest/ads-debt.md` §1.1
/// `TimecodeCounter`): a high-contrast monospace badge showing a formatted
/// position. Unlike the donors, formatting arrives injected, never local.
///
/// Lifecycle: EXPERIMENTAL (Task 1875). Intentionally **not** exported from
/// any barrel and without a `Prism*` alias until the promotion task wires
/// the public surface.
class DSTimecodeBadge extends StatelessWidget {
  /// Opaque caller position value (seconds by convention, never interpreted).
  final double positionSeconds;

  /// Opaque caller duration value (seconds by convention, never interpreted).
  final double durationSeconds;

  /// Caller-supplied formatter. Called during build with the raw values.
  final DSTransportFormatTime formatTime;

  /// Screen-reader label prefix. The rendered string is appended.
  final String semanticLabel;

  const DSTimecodeBadge({
    super.key,
    required this.positionSeconds,
    required this.durationSeconds,
    required this.formatTime,
    this.semanticLabel = 'Timecode',
  });

  static const Key badgeKey = Key('ds-timecode-badge');

  @override
  Widget build(BuildContext context) {
    final text = formatTime(positionSeconds, durationSeconds);
    return Semantics(
      label: '$semanticLabel: $text',
      readOnly: true,
      child: KeyedSubtree(
        key: badgeKey,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DSSpacing.sm,
            vertical: DSSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: DSColors.obsidianElevated,
            borderRadius: BorderRadius.circular(DSRadii.sm),
            border: Border.all(color: DSColors.borderSubtle, width: 1),
          ),
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: DSTypography.labelMedium.copyWith(
              fontFamily: 'monospace',
              color: DSColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
