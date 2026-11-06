import 'package:flutter/material.dart';
import '../organisms/ds_error_boundary.dart';
import 'ds_state_surface.dart';

/// Startup-failure molecule (Task 1876, F-09) — EXPERIMENTAL.
///
/// Fail-closed bootstrap failure view: a bootstrap failure must inform
/// without leaking internals. The underlying [cause] object is accepted so
/// callers can forward whatever was caught, but it is **never rendered** —
/// not its message, not a trace, not Daemon/socket/transport internals, not
/// even in debug builds. Only the sanitized [title]/[guidance] copy reaches
/// the tree. The trace object itself is dropped at the boundary (see
/// [guard]): it is not retained in memory beyond the opaque [cause].
///
/// Convergence: renders through [DSStateSurface] modes — [DSStateSurface]
/// error for determinate failure, [DSStateSurface.unknown] for the
/// indeterminate case ([DSStartupFailureView.indeterminate]). Consumes Task
/// 1869's frozen unknown vocabulary through its interface
/// ([DSStateType.unknown], [DSStateTypeHonestUnknown.isIndeterminate]); it
/// never re-invents indeterminacy.
///
/// Determinism (GOLD non-animated rationale): no progress indicator, no
/// shimmer, no timers, no wall-clock. Startup and loading states are
/// excluded from golden capture by contract.
///
/// Presentation-only retry: [onRetry] is an affordance, not a policy. Retry
/// policy (backoff, budgets, orchestration) lives product-side per the
/// runtime purge law; this widget never retries on its own.
///
/// Lifecycle: EXPERIMENTAL. Intentionally **not** exported from any barrel
/// and without a `Prism*` alias until the promotion task wires the public
/// surface. Import by `src` path only:
/// `package:warp_prism_ui/src/molecules/ds_startup_failure_view.dart`.
class DSStartupFailureView extends StatelessWidget {
  /// Default determinate-failure title (sanitized, fixed copy).
  static const defaultTitle = 'Startup failed';

  /// Default indeterminate (unknown) title (sanitized, fixed copy).
  static const defaultIndeterminateTitle = 'Startup state unclear';

  /// Default guidance (sanitized, fixed copy — no diagnostics reference).
  static const defaultGuidance =
      'The workspace could not start. Check the connection and try again.';

  /// Visible title. Sanitized product copy — never an exception message.
  final String title;

  /// Visible guidance. Sanitized product copy — never internals.
  final String? guidance;

  /// Presentation-only retry affordance. Null hides the retry button.
  final VoidCallback? onRetry;

  /// Compact layout for inline/constrained bootstrap chrome.
  final bool compact;

  /// Optional focus node for keyboard navigation continuity.
  final FocusNode? focusNode;

  /// Opaque caught failure. Accepted for forwarding convenience; **never
  /// rendered** under any build mode.
  final Object? cause;

  /// True when the bootstrap outcome is withheld (unclear), not failed.
  final bool _indeterminate;

  /// Determinate bootstrap failure with sanitized copy.
  const DSStartupFailureView({
    super.key,
    this.title = defaultTitle,
    this.guidance,
    this.onRetry,
    this.compact = false,
    this.focusNode,
    this.cause,
  }) : _indeterminate = false;

  /// Indeterminate bootstrap state — neither success nor failure is honest.
  ///
  /// Renders through [DSStateSurface.unknown] (Task 1869 frozen vocabulary):
  /// neutral token, no animation, no affirmative action, live announcement.
  const DSStartupFailureView.indeterminate({
    super.key,
    this.title = defaultIndeterminateTitle,
    this.guidance,
    this.compact = false,
    this.focusNode,
    this.cause,
  }) : _indeterminate = true,
       onRetry = null;

  /// Boundary composition: guards [child] so any build failure becomes a
  /// sanitized [DSStartupFailureView] instead of a framework error surface.
  ///
  /// The caught failure and its trace are forwarded as the opaque [cause]
  /// (never rendered). Extends [DSErrorBoundary] behavior; presentation
  /// extends [DSStateSurface] modes.
  static DSErrorBoundary guard({
    required Widget child,
    String title = defaultTitle,
    String? guidance,
    VoidCallback? onRetry,
    bool compact = false,
    Key? key,
  }) {
    return DSErrorBoundary(
      key: key,
      fallbackBuilder: (context, failure, _) => DSStartupFailureView(
        title: title,
        guidance: guidance,
        onRetry: onRetry,
        compact: compact,
        cause: failure,
      ),
      child: child,
    );
  }

  /// Screen-reader announcement: title plus guidance.
  String get announcement {
    final detail = (guidance ?? defaultGuidance).trim();
    return '$title. $detail';
  }

  @override
  Widget build(BuildContext context) {
    // Frozen-vocabulary tie (Task 1869): unknown stays indeterminate, so the
    // indeterminate constructor can never resolve to a determinate surface.
    assert(
      DSStateType.unknown.isIndeterminate,
      'DSStartupFailureView: Task 1869 frozen vocabulary violated',
    );

    final Widget surface = _indeterminate
        ? DSStateSurface.unknown(
            title: title,
            subtitle: guidance ?? defaultGuidance,
            compact: compact,
          )
        : DSStateSurface.error(
            title: title,
            subtitle: guidance ?? defaultGuidance,
            actionLabel: 'Retry',
            onAction: onRetry,
            compact: compact,
          );

    return Semantics(
      container: true,
      label: announcement,
      // Bootstrap outcome changes announce on appearance.
      liveRegion: true,
      child: Focus(focusNode: focusNode, child: surface),
    );
  }
}
