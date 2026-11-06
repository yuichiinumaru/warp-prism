import 'ds_colors.dart';

/// Generic authority outcome for capability-gated actions.
///
/// Token-side projection of the IDS `ActionAvailability` outcome
/// (`packages/warp_prism_interaction/lib/src/input/action_availability.dart`):
/// IDS owns the outcome semantics and reason propagation; this enum owns only
/// the generic allow / constrain / deny vocabulary so ADS surfaces can render
/// it without importing interaction semantics or product domain types.
///
/// Capability *evaluation* is product-local and never lives here.
///
/// Lifecycle: EXPERIMENTAL (Task 1868). Intentionally **not** exported from
/// the tokens barrel and without a `Prism*` alias until the promotion task
/// wires the public surface — this keeps the mechanical alias-completeness
/// gate green while the unit is EXPERIMENTAL. No palette additions: colors
/// reuse existing [DSColors] semantic aliases.
enum DSActionAuthority {
  /// The action may dispatch without limitation.
  allow,

  /// The action may dispatch with a stated limitation (reason required).
  constrain,

  /// The action must not dispatch; the reason is shown, never hidden.
  deny,
}

/// Extension providing UI metadata for [DSActionAuthority].
extension DSActionAuthorityUI on DSActionAuthority {
  /// Human-readable label for screen display.
  String get label {
    switch (this) {
      case DSActionAuthority.allow:
        return 'Allowed';
      case DSActionAuthority.constrain:
        return 'Constrained';
      case DSActionAuthority.deny:
        return 'Denied';
    }
  }

  /// Screen reader label for accessibility announcements.
  String get semanticLabel {
    switch (this) {
      case DSActionAuthority.allow:
        return 'Allowed: action available';
      case DSActionAuthority.constrain:
        return 'Constrained: action available with limitation';
      case DSActionAuthority.deny:
        return 'Denied: action unavailable';
    }
  }

  /// Whether the gated action may dispatch in this outcome.
  bool get mayDispatch {
    switch (this) {
      case DSActionAuthority.allow:
      case DSActionAuthority.constrain:
        return true;
      case DSActionAuthority.deny:
        return false;
    }
  }

  /// Whether a reason is required alongside this outcome.
  bool get requiresReason {
    switch (this) {
      case DSActionAuthority.allow:
        return false;
      case DSActionAuthority.constrain:
      case DSActionAuthority.deny:
        return true;
    }
  }
}
