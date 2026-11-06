import 'package:flutter/material.dart';
import '../tokens/tokens.dart';

/// Witness Badge — opaque-hash witness marker (Task 1872, EXPERIMENTAL).
///
/// Renders a caller-supplied opaque hash string alongside a witness state:
/// [DSWitnessState.verified], [DSWitnessState.unverified],
/// [DSWitnessState.mismatched], or [DSWitnessState.unknown].
///
/// The hash is **opaque**: Prism never hashes, fingerprints, verifies, or
/// signs. [hashDisplay] arrives fully formed from the consumer and is shown
/// through the fixed [displayFor] truncation rule only.
///
/// The `unknown` state consumes Task 1869's honest-unknown vocabulary
/// through its frozen interface: the neutral [DSColors.statusUnknown] token,
/// a question-mark icon (never a check), and a live-region announcement —
/// and it is the only [isIndeterminate] witness state.
///
/// [DSWitnessRenderMode.sealed] renders **absent affordances**: no copy,
/// re-verify, or re-resolve actions render even when callbacks are supplied.
/// Open mode renders exactly the affordances whose callbacks are non-null.
///
/// EXPERIMENTAL: no layer-barrel export, no `Prism` alias (promotion defers
/// to the STABLE task, which must update the boundary harness).
class DSWitnessBadge extends StatelessWidget {
  /// Opaque hash string supplied by the consumer. Never computed in Prism.
  final String hashDisplay;

  /// Witness determination for the presented hash.
  final DSWitnessState state;

  /// Open renders supplied affordances; sealed renders none.
  final DSWitnessRenderMode renderMode;

  /// Optional affordances (open mode only; ignored when sealed).
  final VoidCallback? onCopy;
  final VoidCallback? onReverify;
  final VoidCallback? onReresolve;

  const DSWitnessBadge({
    super.key,
    required this.hashDisplay,
    required this.state,
    this.renderMode = DSWitnessRenderMode.open,
    this.onCopy,
    this.onReverify,
    this.onReresolve,
  });

  /// Fixed, layout-independent truncation for opaque hashes.
  ///
  /// Strings longer than 12 characters render as the first 8 characters,
  /// an ellipsis, and the last 4. Shorter strings render in full. Pure
  /// function of input: same input always yields same output.
  static String displayFor(String opaque) {
    if (opaque.length > 12) {
      return '${opaque.substring(0, 8)}…${opaque.substring(opaque.length - 4)}';
    }
    return opaque;
  }

  /// Token color for a witness state. Only verified claims success green;
  /// every non-verified state is visually distinct from it.
  Color colorFor(DSWitnessState value) {
    switch (value) {
      case DSWitnessState.verified:
        return DSColors.statusSuccess;
      case DSWitnessState.unverified:
        return DSColors.statusUnverified;
      case DSWitnessState.mismatched:
        return DSColors.statusError;
      case DSWitnessState.unknown:
        return DSColors.statusUnknown;
    }
  }

  /// Icon for a witness state. Only verified renders the verified check.
  IconData iconFor(DSWitnessState value) {
    switch (value) {
      case DSWitnessState.verified:
        return Icons.verified;
      case DSWitnessState.unverified:
        return Icons.schedule;
      case DSWitnessState.mismatched:
        return Icons.error_outline;
      case DSWitnessState.unknown:
        return Icons.help_outline;
    }
  }

  /// Short label for a witness state.
  String labelFor(DSWitnessState value) {
    switch (value) {
      case DSWitnessState.verified:
        return 'Verified';
      case DSWitnessState.unverified:
        return 'Unverified';
      case DSWitnessState.mismatched:
        return 'Mismatch';
      case DSWitnessState.unknown:
        return 'Unknown';
    }
  }

  /// Screen-reader label. Non-verified states never claim `Verified`.
  String semanticFor(DSWitnessState value) {
    switch (value) {
      case DSWitnessState.verified:
        return 'Witness Verified: presented value matches the recorded one';
      case DSWitnessState.unverified:
        return 'Witness Unverified: no proof yet — not verified';
      case DSWitnessState.mismatched:
        return 'Witness mismatch: presented value differs — not verified';
      case DSWitnessState.unknown:
        return 'Witness unknown: not yet determined — not verified';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = colorFor(state);
    final sealed = renderMode == DSWitnessRenderMode.sealed;
    return Semantics(
      label: semanticFor(state),
      // Indeterminate witness states announce on appearance (Task 1869
      // frozen interface: unknown withholds determination).
      liveRegion: state.isIndeterminate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(DSRadii.full),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(iconFor(state), size: 14, color: color),
            const SizedBox(width: 4),
            // Flexible (not layout-computed content): the hash text yields
            // first under narrow viewports so the 48dp affordance targets
            // and the state label never overflow. Truncation itself stays
            // the fixed character-count rule in [displayFor].
            Flexible(
              child: Text(
                displayFor(hashDisplay),
                style: TextStyle(
                  fontSize: 11,
                  fontFamily: 'monospace',
                  color: color,
                  height: 1,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              labelFor(state),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
                height: 1,
              ),
            ),
            if (!sealed) ...[
              if (onCopy != null)
                _Affordance(
                  tooltip: 'Copy hash',
                  icon: Icons.copy_outlined,
                  color: color,
                  onPressed: onCopy!,
                ),
              if (onReverify != null)
                _Affordance(
                  tooltip: 'Re-verify',
                  icon: Icons.refresh,
                  color: color,
                  onPressed: onReverify!,
                ),
              if (onReresolve != null)
                _Affordance(
                  tooltip: 'Re-resolve',
                  icon: Icons.link,
                  color: color,
                  onPressed: onReresolve!,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Witness determination for an opaque hash (Task 1872, EXPERIMENTAL).
///
/// The determination is computed consumer-side and projected here as data.
/// `unknown` withholds determination (Task 1869 frozen interface).
enum DSWitnessState {
  /// Consumer proof confirms the presented value.
  verified,

  /// No proof attempted yet — never renders as verified.
  unverified,

  /// Presented value differs from the recorded one — never verified.
  mismatched,

  /// Determination withheld — fail-closed, never verified.
  unknown,
}

/// Honest-unknown helpers for [DSWitnessState] (Task 1872, consumes 1869).
///
/// Parallels the frozen `DSStateTypeHonestUnknown` interface: exactly one
/// indeterminate value, excluded from golden capture by contract.
extension DSWitnessStateHonestUnknown on DSWitnessState {
  /// States whose determination is withheld (currently only [unknown]).
  static const indeterminateValues = <DSWitnessState>{DSWitnessState.unknown};

  /// True when this state withholds determination.
  bool get isIndeterminate => this == DSWitnessState.unknown;

  /// True when this state carries a determination.
  bool get isDeterminate => !isIndeterminate;
}

/// Rendering contract for [DSWitnessBadge] affordances.
///
/// Sealed means absent affordances: no copy, re-verify, or re-resolve
/// actions render, so sealed surfaces can never offer proof mutation.
enum DSWitnessRenderMode {
  /// Renders exactly the affordances whose callbacks are non-null.
  open,

  /// Renders zero interactive affordances, ignoring supplied callbacks.
  sealed,
}

class _Affordance extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _Affordance({
    required this.tooltip,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // IconButton's `tooltip` parameter owns the single tooltip affordance;
    // no outer Tooltip wrapper (avoids duplicate tooltip nodes).
    return IconButton(
      tooltip: tooltip,
      icon: Icon(icon, size: 14, color: color),
      onPressed: onPressed,
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      padding: EdgeInsets.zero,
      splashRadius: 16,
    );
  }
}
