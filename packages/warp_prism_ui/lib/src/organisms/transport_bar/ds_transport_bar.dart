import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../atoms/ds_timebase_badge.dart';
import '../../atoms/ds_timecode_badge.dart';
import '../../tokens/ds_action_authority.dart';
import '../../tokens/tokens.dart';

/// Caller-supplied formatter for an interval readout.
///
/// Prism owns no time ontology: both ends are opaque caller numbers and the
/// returned string is rendered verbatim.
typedef DSTransportFormatRange =
    String Function(double startSeconds, double endSeconds);

/// Opaque caller interval for the optional range readout.
///
/// Plain numbers only — no duration semantics, no frame math, no meter.
@immutable
class DSTransportRange {
  /// Opaque interval start (seconds by convention, never interpreted).
  final double startSeconds;

  /// Opaque interval end (seconds by convention, never interpreted).
  final double endSeconds;

  const DSTransportRange({
    required this.startSeconds,
    required this.endSeconds,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DSTransportRange &&
          other.startSeconds == startSeconds &&
          other.endSeconds == endSeconds);

  @override
  int get hashCode => Object.hash(startSeconds, endSeconds);
}

/// Transport bar — chrome-only playback control organism.
///
/// Renders play/pause, caller-sized step buttons, an injected-formatter
/// readout, and caller-supplied slots for record / loop / metronome / tempo
/// surfaces. This widget owns **no** transport behavior: it never advances
/// time, never runs a clock, and never interprets tempo or meter. Every
/// state change arrives as a callback (`onStep` carries the signed caller
/// step delta; `onTogglePlay` flips playback); the parent owns position,
/// playback, and orchestration.
///
/// Donor shape (INHERITED-REPORT via `docs/bridge/warpblade/ads-debt.md` §3.3
/// `TransportBar` — play/pause, 0.25s step seek, scrub slider, dual
/// position/duration timecode — and `docs/bridge/tempest/ads-debt.md` §1.3
/// `StudioTransportBar` — session ops, transport buttons,
/// metronome/loop, dual timecode/position displays, tempo control, meter):
/// the injected-formatter discipline trapped in local chrome is promoted
/// here to the shared organism, while session ops, scrub physics, and tempo
/// evaluation stay product-local.
///
/// Eligibility rendering follows Task 1868's frozen token-side interface
/// ([DSActionAuthority]) — outcomes are consumed, never re-invented. A
/// denied control renders disabled **with** its reason visible and announced
/// (never hidden); tapping it surfaces the reason via [onRefused] and never
/// dispatches.
///
/// Non-goals: time ontology, tempo/meter semantics, transport orchestration,
/// metering/faders (P1 F-13).
///
/// Lifecycle: EXPERIMENTAL (Task 1875). Intentionally **not** exported from
/// any barrel and without a `Prism*` alias until the promotion task wires
/// the public surface.
class DSTransportBar extends StatelessWidget {
  /// Opaque caller position value rendered through [formatTime].
  final double positionSeconds;

  /// Opaque caller duration value rendered through [formatTime].
  final double durationSeconds;

  /// Caller-supplied position/duration formatter (rendered verbatim).
  final DSTransportFormatTime formatTime;

  /// Caller-supplied interval formatter for [visibleRange] (verbatim).
  final DSTransportFormatRange formatRange;

  /// Optional interval rendered through [formatRange]. Null hides it.
  final DSTransportRange? visibleRange;

  /// Caller-supplied step magnitude in seconds. Emitted signed via [onStep].
  final double stepSizeSeconds;

  /// Caller-supplied accessible label for the step-backward control.
  final String stepBackwardLabel;

  /// Caller-supplied accessible label for the step-forward control.
  final String stepForwardLabel;

  /// Caller-supplied accessible label for the play control.
  final String playLabel;

  /// Caller-supplied accessible label for the pause control.
  final String pauseLabel;

  /// Caller-owned playback flag. Selects the play vs pause affordance only.
  final bool isPlaying;

  /// Chrome callback: the parent applies the signed step delta.
  ///
  /// Step-back emits `-stepSizeSeconds`; step-forward emits `+stepSizeSeconds`.
  final ValueChanged<double>? onStep;

  /// Chrome callback: the parent flips playback. Null disables the control.
  final VoidCallback? onTogglePlay;

  /// Terminal-for-dispatch refusal path: receives the reason when a denied
  /// control is tapped.
  final ValueChanged<String>? onRefused;

  /// Task 1868 outcome governing the play/pause control.
  final DSActionAuthority playAuthority;

  /// Reason accompanying a non-allow [playAuthority]. Shown, never hidden.
  final String? playReason;

  /// Task 1868 outcome governing the step-backward control.
  final DSActionAuthority stepBackAuthority;

  /// Reason accompanying a non-allow [stepBackAuthority]. Shown, never hidden.
  final String? stepBackReason;

  /// Task 1868 outcome governing the step-forward control.
  final DSActionAuthority stepForwardAuthority;

  /// Reason accompanying a non-allow [stepForwardAuthority].
  /// Shown, never hidden.
  final String? stepForwardReason;

  /// Caller-supplied record surface slot (any widget; Prism never inspects).
  final Widget? recordSlot;

  /// Caller-supplied loop surface slot (any widget; Prism never inspects).
  final Widget? loopSlot;

  /// Caller-supplied metronome surface slot (any widget; Prism never inspects).
  final Widget? metronomeSlot;

  /// Caller-supplied tempo surface slot (any widget, typically wrapping a
  /// [DSTimebaseBadge]; Prism never formats or parses tempo).
  final Widget? tempoSlot;

  /// Semantic label for the transport region.
  final String semanticLabel;

  const DSTransportBar({
    super.key,
    required this.positionSeconds,
    required this.durationSeconds,
    required this.formatTime,
    required this.formatRange,
    this.visibleRange,
    this.stepSizeSeconds = 0.25,
    this.stepBackwardLabel = 'Step backward',
    this.stepForwardLabel = 'Step forward',
    this.playLabel = 'Play',
    this.pauseLabel = 'Pause',
    this.isPlaying = false,
    this.onStep,
    this.onTogglePlay,
    this.onRefused,
    this.playAuthority = DSActionAuthority.allow,
    this.playReason,
    this.stepBackAuthority = DSActionAuthority.allow,
    this.stepBackReason,
    this.stepForwardAuthority = DSActionAuthority.allow,
    this.stepForwardReason,
    this.recordSlot,
    this.loopSlot,
    this.metronomeSlot,
    this.tempoSlot,
    this.semanticLabel = 'Transport bar',
  });

  static const Key barRegionKey = Key('ds-transport-bar');
  static const Key playPauseKey = Key('ds-transport-play-pause');
  static const Key stepBackKey = Key('ds-transport-step-back');
  static const Key stepForwardKey = Key('ds-transport-step-forward');
  static const Key readoutKey = Key('ds-transport-readout');
  static const Key rangeKey = Key('ds-transport-range');
  static const Key refusalLineKey = Key('ds-transport-refusals');

  /// Screen-reader announcement for a control under an authority outcome.
  static String announcementFor(
    String label,
    DSActionAuthority authority,
    String? reason,
  ) {
    final detail = reason?.trim();
    if (detail != null && detail.isNotEmpty) {
      return '$label. ${authority.semanticLabel}: $detail';
    }
    return '$label. ${authority.semanticLabel}';
  }

  @override
  Widget build(BuildContext context) {
    assert(
      !playAuthority.requiresReason || (playReason?.trim().isNotEmpty ?? false),
      'DSTransportBar: $playAuthority playAuthority requires a non-empty playReason',
    );
    assert(
      !stepBackAuthority.requiresReason ||
          (stepBackReason?.trim().isNotEmpty ?? false),
      'DSTransportBar: $stepBackAuthority stepBackAuthority requires a non-empty stepBackReason',
    );
    assert(
      !stepForwardAuthority.requiresReason ||
          (stepForwardReason?.trim().isNotEmpty ?? false),
      'DSTransportBar: $stepForwardAuthority stepForwardAuthority requires a non-empty stepForwardReason',
    );

    // Every non-allow outcome keeps its reason on screen: denials and
    // limitations alike are shown, never hidden (Task 1868 law).
    final notices = <String>[
      if (playAuthority.requiresReason) playReason!.trim(),
      if (stepBackAuthority.requiresReason) stepBackReason!.trim(),
      if (stepForwardAuthority.requiresReason) stepForwardReason!.trim(),
    ];

    final slots = <Widget>[
      if (recordSlot != null) recordSlot!,
      if (loopSlot != null) loopSlot!,
      if (metronomeSlot != null) metronomeSlot!,
      if (tempoSlot != null) tempoSlot!,
    ];

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: semanticLabel,
      child: KeyedSubtree(
        key: barRegionKey,
        child: Container(
          padding: const EdgeInsets.all(DSSpacing.sm),
          decoration: BoxDecoration(
            color: DSColors.obsidianElevated,
            borderRadius: BorderRadius.circular(DSRadii.sm),
            border: Border.all(color: DSColors.borderSubtle, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: DSSpacing.xs,
                runSpacing: DSSpacing.xs,
                children: [
                  _TransportControlButton(
                    key: stepBackKey,
                    icon: Icons.skip_previous,
                    label: stepBackwardLabel,
                    authority: stepBackAuthority,
                    reason: stepBackReason,
                    onRefused: onRefused,
                    onPressed: onStep == null
                        ? null
                        : () => onStep!(-stepSizeSeconds),
                  ),
                  _TransportControlButton(
                    key: playPauseKey,
                    icon: isPlaying ? Icons.pause : Icons.play_arrow,
                    label: isPlaying ? pauseLabel : playLabel,
                    authority: playAuthority,
                    reason: playReason,
                    onRefused: onRefused,
                    onPressed: onTogglePlay,
                  ),
                  _TransportControlButton(
                    key: stepForwardKey,
                    icon: Icons.skip_next,
                    label: stepForwardLabel,
                    authority: stepForwardAuthority,
                    reason: stepForwardReason,
                    onRefused: onRefused,
                    onPressed: onStep == null
                        ? null
                        : () => onStep!(stepSizeSeconds),
                  ),
                  KeyedSubtree(
                    key: readoutKey,
                    child: DSTimecodeBadge(
                      positionSeconds: positionSeconds,
                      durationSeconds: durationSeconds,
                      formatTime: formatTime,
                    ),
                  ),
                  if (visibleRange != null)
                    KeyedSubtree(
                      key: rangeKey,
                      child: DSTimebaseBadge(
                        formatTimebase: () => formatRange(
                          visibleRange!.startSeconds,
                          visibleRange!.endSeconds,
                        ),
                        semanticLabel: 'Range',
                      ),
                    ),
                  ...slots,
                ],
              ),
              if (notices.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: DSSpacing.xs),
                  child: KeyedSubtree(
                    key: refusalLineKey,
                    child: Text(
                      notices.join(' · '),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: DSTypography.bodySmall.copyWith(
                        color: DSColors.textSecondary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Single chrome control: never hidden, disabled-with-reason under deny.
///
/// Mirrors the private transport-button shape already proven in
/// `DSTimeMachineScrubber` (`_TransportButton` / `_buildTransportRow` with
/// the `showTransport` flag): minimum 48dp target, tooltip, semantics
/// announcement, haptic on dispatch. Denied taps cannot dispatch and carry
/// their reason to [onRefused].
class _TransportControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final DSActionAuthority authority;
  final String? reason;
  final ValueChanged<String>? onRefused;
  final VoidCallback? onPressed;

  const _TransportControlButton({
    super.key,
    required this.icon,
    required this.label,
    required this.authority,
    this.reason,
    this.onRefused,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final mayDispatch = authority.mayDispatch && onPressed != null;
    final detail = reason?.trim();
    final announcement = DSTransportBar.announcementFor(
      label,
      authority,
      reason,
    );
    final color = !authority.mayDispatch || onPressed == null
        ? DSColors.textDisabled
        : DSColors.textPrimary;

    return Semantics(
      button: true,
      enabled: mayDispatch,
      label: announcement,
      child: Tooltip(
        message: detail != null && detail.isNotEmpty
            ? '$label — $detail'
            : label,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: mayDispatch
              ? null
              : () {
                  if (!authority.mayDispatch) {
                    onRefused?.call(detail ?? 'Unavailable');
                  }
                },
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: kMinInteractiveDimension,
              minHeight: kMinInteractiveDimension,
            ),
            child: IconButton(
              onPressed: mayDispatch
                  ? () {
                      HapticFeedback.selectionClick();
                      onPressed!();
                    }
                  : null,
              icon: Icon(icon, color: color, size: 22),
              splashRadius: kMinInteractiveDimension / 2,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: kMinInteractiveDimension,
                minHeight: kMinInteractiveDimension,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
