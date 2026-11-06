import 'package:flutter/material.dart';
import '../atoms/atoms.dart';
import '../tokens/tokens.dart';
import 'ds_state_surface.dart';

/// Staged job banner molecule (Task 1858, F-10 — EXPERIMENTAL).
///
/// A persistent, deterministic job-presentation surface converged from
/// Warpblade export banners, the Tempest `ProgressCard` (multi-stage +
/// cancel + elapsed label), and the Command-center loading trio
/// (macro-review C6; the trio's non-animated determinism rationale in
/// `integration/loading.dart:3-11` is reused here: no spinner, no timers,
/// no wall-clock — elapsed time arrives as an injected caller string).
///
/// What this molecule owns: staged progress display, the cancel affordance
/// with its reason, and the deterministic terminal receipt **slot**.
/// Receipt *content* stays consumer-side — Prism owns the slot, never the
/// bytes. Receipt widgets render verbatim, only in terminal phases.
///
/// What this molecule never does: it never executes jobs (no
/// `AsyncJobExecutor` — Task 1859), never renders toasts (a toast is not a
/// job; toast policy is Task 1867), and never forks the F-02
/// honest-indeterminate vocabulary — the withheld-determination case reuses
/// [DSStateType.unknown], [DSColors.statusUnknown], and
/// [DSStateTypeHonestUnknown.isIndeterminate] read-only.
///
/// Fail-closed law: the [DSJobBannerPhase.unknown] case renders with the
/// neutral indeterminate token, the help icon, and an announcement that
/// claims nothing. Withheld determination is excluded from golden capture
/// and carries no progress animation.
///
/// Lifecycle: EXPERIMENTAL. Intentionally **not** exported from any barrel
/// and without a `Prism*` alias until the promotion task wires the public
/// surface (layer-contracts §9).
enum DSJobBannerPhase {
  /// Ordered before execution begins. Determinate, non-terminal.
  queued,

  /// Execution in flight. Determinate when staged progress is present.
  running,

  /// Terminal success. The receipt slot may be filled by the consumer.
  succeeded,

  /// Terminal failure. Carries an optional caller-provided reason.
  failed,

  /// Terminal operator cancellation. Carries the propagated cancel reason.
  cancelled,

  /// Determination withheld. Fail-closed: neutral chrome, no affirmation.
  unknown,
}

/// Ordered lifecycle position of one banner stage.
enum DSJobStageState {
  /// Not yet started.
  pending,

  /// Currently executing.
  active,

  /// Finished at full progress.
  done,

  /// Bypassed without execution (caller-determined, never inferred here).
  skipped,
}

/// One named banner stage with deterministic fractional progress.
///
/// [progress] is clamped to `0.0..1.0` at construction; `null` overall
/// progress on the banner means indeterminate display (static chrome, no
/// animation) and is excluded from golden capture.
class DSJobStage {
  /// Human-readable stage label (caller-provided).
  final String label;

  /// Fractional completion, clamped to `0.0..1.0`.
  final double progress;

  /// Lifecycle position of this stage.
  final DSJobStageState state;

  /// Creates a stage. [progress] is clamped to `0.0..1.0`.
  const DSJobStage({
    required this.label,
    double progress = 0.0,
    this.state = DSJobStageState.pending,
  }) : progress = progress < 0.0 ? 0.0 : (progress > 1.0 ? 1.0 : progress);
}

/// Extension describing terminal and indeterminate banner phases.
extension DSJobBannerPhaseInfo on DSJobBannerPhase {
  /// True for succeeded, failed, and cancelled. Only terminal phases may
  /// show the receipt slot; only non-terminal phases may offer cancel.
  bool get isTerminal => switch (this) {
    DSJobBannerPhase.succeeded ||
    DSJobBannerPhase.failed ||
    DSJobBannerPhase.cancelled => true,
    DSJobBannerPhase.queued ||
    DSJobBannerPhase.running ||
    DSJobBannerPhase.unknown => false,
  };

  /// Screen-reader phase description. The withheld case claims nothing.
  String get semanticLabel => switch (this) {
    DSJobBannerPhase.queued => 'Queued: waiting to start',
    DSJobBannerPhase.running => 'Running: execution in flight',
    DSJobBannerPhase.succeeded => 'Succeeded: terminal receipt available',
    DSJobBannerPhase.failed => 'Failed: execution ended with an error',
    DSJobBannerPhase.cancelled => 'Cancelled: stopped by operator request',
    DSJobBannerPhase.unknown =>
      'Job indeterminate: state not yet determined, no action taken',
  };
}

class DSJobBanner extends StatelessWidget {
  /// Job title (required — always present, always meaningful).
  final String title;

  /// Optional secondary explanation or host route hint.
  final String? subtitle;

  /// Ordered stages. Rendered in order; never reordered here.
  final List<DSJobStage> stages;

  /// Lifecycle phase of the job.
  final DSJobBannerPhase phase;

  /// Overall fractional progress, or `null` for indeterminate display.
  ///
  /// Indeterminate display is static chrome (no animation) and is excluded
  /// from golden capture.
  final double? progress;

  /// Whether the consumer offers cancellation for this job.
  ///
  /// Cancel is rendered only when [cancellable] is true, the phase is
  /// non-terminal, and [onCancel] is set. A banner that cannot be cancelled
  /// shows no cancel control at all.
  final bool cancellable;

  /// Reason the job may be cancelled. Required (non-empty) whenever cancel
  /// is offered; announced to assistive technology, never colour-only.
  final String? cancelReason;

  /// Dispatch callback for the cancel control. Invoked on tap.
  final VoidCallback? onCancel;

  /// Consumer-owned receipt content. Rendered verbatim inside the
  /// deterministic receipt slot, only in terminal phases.
  ///
  /// Prism owns the slot chrome; the bytes stay consumer-side.
  final Widget? receipt;

  /// Caller-formatted elapsed text (e.g. `00:42`). Time arrives injected;
  /// the banner never runs timers or reads the wall-clock.
  final String? elapsedLabel;

  /// Optional failure detail supplied by the caller (sanitized copy only —
  /// callers must never pass exception strings or daemon internals).
  final String? failureDetail;

  /// Optional focus node for the cancel control (keyboard navigation).
  final FocusNode? cancelFocusNode;

  /// Whether to compact the banner into a smaller layout.
  final bool compact;

  const DSJobBanner({
    super.key,
    required this.title,
    this.subtitle,
    this.stages = const [],
    this.phase = DSJobBannerPhase.queued,
    this.progress,
    this.cancellable = false,
    this.cancelReason,
    this.onCancel,
    this.receipt,
    this.elapsedLabel,
    this.failureDetail,
    this.cancelFocusNode,
    this.compact = false,
  });

  /// Whether the cancel control is rendered.
  bool get cancelOffered =>
      cancellable && !phase.isTerminal && onCancel != null;

  /// Whether the receipt slot is rendered.
  bool get receiptShown => phase.isTerminal && receipt != null;

  /// Screen-reader announcement: title, phase, stage position, percent,
  /// cancel reason, and receipt presence. Progress and cancel state are
  /// never colour-only.
  String get announcement {
    final buffer = StringBuffer('Job banner: $title. ${phase.semanticLabel}.');
    if (stages.isNotEmpty) {
      final activeIndex = _activeStageIndex;
      final activeLabel = stages[activeIndex].label;
      buffer.write(
        ' Stage ${activeIndex + 1} of ${stages.length}: $activeLabel.',
      );
    }
    final value = progress;
    if (value != null && phase != DSJobBannerPhase.unknown) {
      buffer.write(' ${(value.clamp(0.0, 1.0) * 100).round()} percent.');
    }
    if (cancelOffered) {
      buffer.write(' Cancel available: ${cancelReason!.trim()}.');
    }
    if (receiptShown) {
      buffer.write(' Terminal receipt shown.');
    }
    return buffer.toString();
  }

  int get _activeStageIndex {
    for (var i = 0; i < stages.length; i++) {
      if (stages[i].state == DSJobStageState.active) return i;
    }
    for (var i = 0; i < stages.length; i++) {
      if (stages[i].state == DSJobStageState.pending) return i;
    }
    return stages.isEmpty ? 0 : stages.length - 1;
  }

  @override
  Widget build(BuildContext context) {
    assert(
      !cancelOffered || (cancelReason?.trim().isNotEmpty ?? false),
      'DSJobBanner: an offered cancel requires a non-empty cancelReason',
    );
    // Share the frozen honest-indeterminate contract (Task 1869, F-02):
    // the withheld case reuses the surface vocabulary read-only.
    assert(DSStateType.unknown.isIndeterminate);

    final color = _phaseColor;
    final icon = _phaseIcon;

    return Semantics(
      container: true,
      label: announcement,
      // Withheld determination and terminal receipts announce on appearance
      // so assistive technology surfaces the lack of determination and the
      // arrival of the receipt without relying on colour.
      liveRegion: phase == DSJobBannerPhase.unknown || phase.isTerminal,
      child: Container(
        padding: EdgeInsets.all(compact ? DSSpacing.sm : DSSpacing.md),
        decoration: BoxDecoration(
          color: DSColors.obsidianElevated,
          borderRadius: BorderRadius.circular(DSRadii.md),
          border: Border.all(color: color.withValues(alpha: 0.35), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(color, icon),
            if (subtitle != null) ...[
              const SizedBox(height: DSSpacing.xs),
              Text(
                subtitle!,
                style: DSTypography.bodySmall.copyWith(
                  color: DSColors.textTertiary,
                ),
              ),
            ],
            if (stages.isNotEmpty) ...[
              SizedBox(height: compact ? DSSpacing.sm : DSSpacing.md),
              _buildStages(color),
            ],
            SizedBox(height: compact ? DSSpacing.sm : DSSpacing.md),
            _buildProgress(color),
            if (elapsedLabel != null) ...[
              const SizedBox(height: DSSpacing.xs),
              _buildElapsed(),
            ],
            if (phase == DSJobBannerPhase.failed && failureDetail != null) ...[
              const SizedBox(height: DSSpacing.xs),
              Text(
                failureDetail!,
                style: DSTypography.bodySmall.copyWith(
                  color: DSColors.statusError,
                ),
              ),
            ],
            if (cancelOffered) ...[
              SizedBox(height: compact ? DSSpacing.sm : DSSpacing.md),
              _buildCancel(color),
            ],
            if (receiptShown) ...[
              SizedBox(height: compact ? DSSpacing.sm : DSSpacing.md),
              _buildReceiptSlot(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Color color, IconData icon) {
    final value = progress;
    final showPercent = value != null && phase != DSJobBannerPhase.unknown;
    return Row(
      children: [
        DSIcon(icon, color: color, size: 20),
        const SizedBox(width: DSSpacing.sm),
        Expanded(
          child: Text(
            title,
            style: DSTypography.labelLarge.copyWith(
              color: DSColors.textPrimary,
            ),
          ),
        ),
        if (showPercent)
          Text(
            '${(value.clamp(0.0, 1.0) * 100).round()}%',
            style: DSTypography.labelMedium.copyWith(color: color),
          ),
      ],
    );
  }

  Widget _buildStages(Color color) {
    final withheld = phase == DSJobBannerPhase.unknown;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < stages.length; i++)
          Padding(
            padding: EdgeInsets.only(top: i == 0 ? 0 : DSSpacing.xs),
            child: Row(
              children: [
                Icon(
                  _stageIcon(stages[i].state, withheld),
                  size: 14,
                  color: withheld ? DSColors.statusUnknown : color,
                ),
                const SizedBox(width: DSSpacing.xs),
                Flexible(
                  child: Text(
                    stages[i].label,
                    style: DSTypography.bodySmall.copyWith(
                      color: withheld
                          ? DSColors.statusUnknown
                          : DSColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildProgress(Color color) {
    final value = progress;
    // Indeterminate display is static chrome (Command-center GOLD
    // rationale): no spinner, no animation, deterministic layout.
    if (value == null || phase == DSJobBannerPhase.unknown) {
      return Text(
        _staticStatusText,
        style: DSTypography.labelSmall.copyWith(
          color: phase == DSJobBannerPhase.unknown
              ? DSColors.statusUnknown
              : DSColors.textTertiary,
        ),
      );
    }
    return Semantics(
      // Progress value is exposed as text, never colour-only.
      label: '${(value.clamp(0.0, 1.0) * 100).round()} percent complete',
      child: ExcludeSemantics(
        child: LinearProgressIndicator(
          value: value.clamp(0.0, 1.0),
          minHeight: 6,
          backgroundColor: DSColors.borderSubtle,
          valueColor: AlwaysStoppedAnimation<Color>(color),
          borderRadius: BorderRadius.circular(DSRadii.xs),
        ),
      ),
    );
  }

  String get _staticStatusText {
    switch (phase) {
      case DSJobBannerPhase.queued:
        return 'Queued — waiting to start';
      case DSJobBannerPhase.running:
        return 'Working…';
      case DSJobBannerPhase.succeeded:
        return 'Complete';
      case DSJobBannerPhase.failed:
        return 'Failed';
      case DSJobBannerPhase.cancelled:
        return 'Cancelled';
      case DSJobBannerPhase.unknown:
        return 'State not yet determined — no action taken';
    }
  }

  Widget _buildElapsed() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.timer_outlined,
          size: 14,
          color: DSColors.textTertiary,
        ),
        const SizedBox(width: DSSpacing.xs),
        Flexible(
          child: Text(
            elapsedLabel!,
            style: DSTypography.bodySmall.copyWith(
              color: DSColors.textTertiary,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildCancel(Color color) {
    final reason = cancelReason!.trim();
    return Semantics(
      button: true,
      enabled: true,
      label: 'Cancel $title. $reason',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OutlinedButton.icon(
            onPressed: onCancel,
            focusNode: cancelFocusNode,
            icon: const Icon(Icons.stop, size: 16),
            label: const Text('Cancel'),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: color.withValues(alpha: 0.5)),
              foregroundColor: color,
              minimumSize: const Size(48, 48),
              padding: const EdgeInsets.symmetric(
                horizontal: DSSpacing.md,
                vertical: DSSpacing.sm,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DSRadii.md),
              ),
            ),
          ),
          const SizedBox(height: DSSpacing.xs),
          ExcludeSemantics(
            // The reason is already inside the button announcement above.
            child: Text(
              reason,
              style: DSTypography.bodySmall.copyWith(
                color: DSColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptSlot() {
    return Container(
      padding: const EdgeInsets.all(DSSpacing.sm),
      decoration: BoxDecoration(
        color: DSColors.obsidianBase,
        borderRadius: BorderRadius.circular(DSRadii.sm),
        border: Border.all(color: _phaseColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RECEIPT',
            style: DSTypography.labelSmall.copyWith(
              color: DSColors.textTertiary,
            ),
          ),
          const SizedBox(height: DSSpacing.xs),
          // Slot chrome is Prism-owned; the bytes are consumer-owned and
          // render verbatim. Never parsed, hashed, or verified here.
          receipt!,
        ],
      ),
    );
  }

  Color get _phaseColor {
    switch (phase) {
      case DSJobBannerPhase.queued:
        return DSColors.textTertiary;
      case DSJobBannerPhase.running:
        return DSColors.accentBlue;
      case DSJobBannerPhase.succeeded:
        return DSColors.statusSuccess;
      case DSJobBannerPhase.failed:
        return DSColors.statusError;
      case DSJobBannerPhase.cancelled:
        return DSColors.textSecondary;
      case DSJobBannerPhase.unknown:
        return DSColors.statusUnknown;
    }
  }

  IconData get _phaseIcon {
    return _phaseIconFor(phase);
  }

  IconData _phaseIconFor(DSJobBannerPhase value) {
    switch (value) {
      case DSJobBannerPhase.queued:
        return Icons.schedule;
      case DSJobBannerPhase.running:
        return Icons.play_circle_outline;
      case DSJobBannerPhase.succeeded:
        return Icons.check_circle;
      case DSJobBannerPhase.failed:
        return Icons.error_outline;
      case DSJobBannerPhase.cancelled:
        return Icons.stop_circle_outlined;
      case DSJobBannerPhase.unknown:
        return Icons.help_outline;
    }
  }

  IconData _stageIcon(DSJobStageState state, bool withheld) {
    if (withheld) return Icons.help_outline;
    switch (state) {
      case DSJobStageState.pending:
        return Icons.circle_outlined;
      case DSJobStageState.active:
        return Icons.play_arrow;
      case DSJobStageState.done:
        return Icons.check_circle_outline;
      case DSJobStageState.skipped:
        return Icons.skip_next_outlined;
    }
  }
}
