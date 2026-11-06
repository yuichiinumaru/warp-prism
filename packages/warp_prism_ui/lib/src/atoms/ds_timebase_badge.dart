import 'package:flutter/material.dart';

import '../tokens/tokens.dart';

/// Timebase badge — caller-formatted tempo/timebase readout atom.
///
/// Renders the string returned by [formatTimebase] verbatim. The caller owns
/// all rhythmic semantics (tempo, meter, fractional timebases such as
/// `30/1`); this atom never parses fractions, never computes tempo, and
/// never taps along — it only displays the injected string.
///
/// Donor shape (INHERITED-REPORT via `docs/bridge/warpblade/ads-debt.md` §3.3
/// `FPSBadge` and `docs/bridge/tempest/ads-debt.md` §1.1 musical-position and
/// tempo-tap controls): a secondary chip showing the session timebase. Unlike the donors, every character arrives
/// caller-formatted; no tempo ontology lives in Prism.
///
/// Lifecycle: EXPERIMENTAL (Task 1875). Intentionally **not** exported from
/// any barrel and without a `Prism*` alias until the promotion task wires
/// the public surface.
class DSTimebaseBadge extends StatelessWidget {
  /// Caller-supplied formatter producing the display string (e.g. a
  /// fractional timebase or tempo readout formatted by the product).
  final String Function() formatTimebase;

  /// Screen-reader label prefix. The rendered string is appended.
  final String semanticLabel;

  const DSTimebaseBadge({
    super.key,
    required this.formatTimebase,
    this.semanticLabel = 'Timebase',
  });

  static const Key badgeKey = Key('ds-timebase-badge');

  @override
  Widget build(BuildContext context) {
    final text = formatTimebase();
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
            color: DSColors.transparent,
            borderRadius: BorderRadius.circular(DSRadii.full),
            border: Border.all(
              color: DSColors.accentCyan.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: DSTypography.labelSmall.copyWith(
              fontFamily: 'monospace',
              color: DSColors.accentCyan,
            ),
          ),
        ),
      ),
    );
  }
}
