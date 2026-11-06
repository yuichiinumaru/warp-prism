import 'package:flutter/material.dart';
import '../atoms/button/ds_button.dart';
import '../tokens/ds_action_authority.dart';
import '../tokens/tokens.dart';

/// Action Gate — capability-gated action molecule.
///
/// Renders an IDS authority outcome ([DSActionAuthority]) as an always-visible
/// action: enabled when allowed, enabled-with-limitation when constrained,
/// and disabled-with-reason when denied. A denied action is **never hidden**:
/// the control stays on screen with its reason visible and announced to
/// assistive technology.
///
/// Token-side projection of the IDS `ActionAvailability` outcome
/// (`packages/warp_prism_interaction/lib/src/input/action_availability.dart`):
/// IDS owns outcome semantics and reason propagation; this molecule owns only
/// presentation. Capability *evaluation* is product-local and never lives
/// here.
///
/// Terminal-for-dispatch: tapping a denied gate cannot dispatch (the inner
/// button is non-interactive), but the refusal reason is surfaced to the
/// caller through [onRefused].
///
/// Lifecycle: EXPERIMENTAL (Task 1868). Intentionally **not** exported from
/// any barrel and without a `Prism*` alias until the promotion task wires
/// the public surface.
class DSActionGate extends StatelessWidget {
  /// Authority outcome governing this action.
  final DSActionAuthority authority;

  /// Visible label of the gated action.
  final String actionLabel;

  /// Reason for [DSActionAuthority.constrain] or [DSActionAuthority.deny].
  ///
  /// Required (non-empty) unless [authority] is [DSActionAuthority.allow].
  final String? reason;

  /// Dispatch callback. Invoked only when [authority] permits dispatch.
  final VoidCallback? onPressed;

  /// Refusal callback. Invoked with [reason] when a denied gate is tapped,
  /// so terminal-for-dispatch refusals carry their reason to the caller.
  final ValueChanged<String>? onRefused;

  /// Optional leading icon for the action button.
  final IconData? icon;

  /// Optional focus node for keyboard navigation.
  final FocusNode? focusNode;

  const DSActionGate({
    super.key,
    required this.authority,
    required this.actionLabel,
    this.reason,
    this.onPressed,
    this.onRefused,
    this.icon,
    this.focusNode,
  });

  /// Convenience constructor for the allowed outcome.
  const DSActionGate.allowed({
    super.key,
    required this.actionLabel,
    this.onPressed,
    this.icon,
    this.focusNode,
  }) : authority = DSActionAuthority.allow,
       reason = null,
       onRefused = null;

  /// Convenience constructor for the constrained outcome.
  const DSActionGate.constrained({
    super.key,
    required this.actionLabel,
    required String this.reason,
    this.onPressed,
    this.icon,
    this.focusNode,
  }) : authority = DSActionAuthority.constrain,
       onRefused = null;

  /// Convenience constructor for the denied outcome.
  const DSActionGate.denied({
    super.key,
    required this.actionLabel,
    required String this.reason,
    this.onRefused,
    this.icon,
    this.focusNode,
  }) : authority = DSActionAuthority.deny,
       onPressed = null;

  /// Screen-reader announcement: label plus outcome plus reason.
  String get announcement {
    final outcome = authority.semanticLabel;
    final detail = reason?.trim();
    if (detail != null && detail.isNotEmpty) {
      return '$actionLabel. $outcome: $detail';
    }
    return '$actionLabel. $outcome';
  }

  @override
  Widget build(BuildContext context) {
    assert(
      !authority.requiresReason || (reason?.trim().isNotEmpty ?? false),
      'DSActionGate: $authority requires a non-empty reason',
    );

    final mayDispatch = authority.mayDispatch;
    final detail = reason?.trim();

    return Semantics(
      container: true,
      button: true,
      enabled: mayDispatch,
      label: announcement,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: mayDispatch
            ? null
            : () {
                final refusal = detail ?? 'Unavailable';
                onRefused?.call(refusal);
              },
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DSButton(
                label: actionLabel,
                onPressed: mayDispatch ? onPressed : null,
                enabled: mayDispatch,
                icon: icon,
                focusNode: focusNode,
                semanticLabel: announcement,
              ),
              if (detail != null && detail.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: DSSpacing.xs),
                  child: ExcludeSemantics(
                    // Reason is already inside the outer announcement.
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          authority == DSActionAuthority.deny
                              ? Icons.block
                              : Icons.info_outline,
                          size: 14,
                          color: _reasonColor,
                        ),
                        const SizedBox(width: DSSpacing.xs),
                        Flexible(
                          child: Text(
                            detail,
                            style: DSTypography.bodySmall.copyWith(
                              color: _reasonColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color get _reasonColor {
    switch (authority) {
      case DSActionAuthority.allow:
        return DSColors.textSecondary;
      case DSActionAuthority.constrain:
        return DSColors.statusWarning;
      case DSActionAuthority.deny:
        return DSColors.textSecondary;
    }
  }
}
