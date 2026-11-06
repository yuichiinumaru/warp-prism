import 'package:flutter/material.dart';

import '../../tokens/ds_action_authority.dart';
import '../../tokens/tokens.dart';
import 'ds_time_ruler.dart';

/// Opaque clip view model for a track lane.
///
/// Positions are caller numbers in the same opaque scale as the lane's
/// visible window. The caller owns clip semantics (takes, regions, MIDI
/// notes); the lane only positions, selects, and announces.
@immutable
class DSTimelineClip {
  final String id;
  final double start;
  final double end;
  final String label;
  final bool selected;

  const DSTimelineClip({
    required this.id,
    required this.start,
    required this.end,
    required this.label,
    this.selected = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DSTimelineClip &&
          other.id == id &&
          other.start == start &&
          other.end == end &&
          other.label == label &&
          other.selected == selected);

  @override
  int get hashCode => Object.hash(id, start, end, label, selected);
}

/// Opaque track view model for the multitrack organism.
@immutable
class DSTimelineTrack {
  final String trackId;
  final String label;
  final IconData icon;
  final List<DSTimelineClip> clips;

  const DSTimelineTrack({
    required this.trackId,
    required this.label,
    this.icon = Icons.audio_file_outlined,
    this.clips = const [],
  });
}

/// Track lane — fixed-height channel strip with header, seek surface, clips.
///
/// Donor shape (INHERITED-REPORT via `docs/bridge/warpblade/ads-debt.md` §3.3
/// `TimelineTrackLane` — fixed header, typed icon, clickable seek surface,
/// clip stack — and `docs/bridge/tempest/ads-debt.md` §1.3
/// `StudioTimelineWorkspace` — dynamic track stacking with spatial
/// audio/MIDI clip rendering): the fixed header + seek surface + positioned
/// clip stack are promoted here at the donor's 52px lane height; waveforms,
/// envelopes, and track controls stay product-local.
///
/// Lane taps seek (opaque position via the shared proportional rule); clip
/// taps report the clip id. Eligibility follows Task 1868's frozen
/// token-side interface ([DSActionAuthority]) — outcomes are consumed, never
/// re-invented; denied touches route to [onRefused] with the reason.
///
/// Lifecycle: EXPERIMENTAL (Task 1874). Intentionally **not** exported from
/// any barrel and without a `Prism*` alias until the promotion task wires
/// the public surface.
class DSTrackLane extends StatelessWidget {
  /// Caller-supplied track (id, label, icon, clips).
  final DSTimelineTrack track;

  /// Opaque visible-window start (seconds by convention, never interpreted).
  final double visibleStart;

  /// Opaque visible-window end (seconds by convention, never interpreted).
  final double visibleEnd;

  /// Task 1868 outcome governing seek/clip taps on this lane.
  final DSActionAuthority seekAuthority;

  /// Reason accompanying a non-allow [seekAuthority]. Shown, never hidden.
  final String? seekReason;

  /// Discrete seek callback with the tapped opaque position. Null disables.
  final ValueChanged<double>? onSeek;

  /// Clip-tap callback with the tapped clip id. Null disables clip taps.
  final ValueChanged<String>? onClipTap;

  /// Terminal-for-dispatch refusal path: receives the reason when a denied
  /// lane is touched.
  final ValueChanged<String>? onRefused;

  /// Fixed lane height (donor geometry: 52px lanes).
  final double laneHeight;

  /// Fixed header width carrying the track label.
  final double headerWidth;

  const DSTrackLane({
    super.key,
    required this.track,
    required this.visibleStart,
    required this.visibleEnd,
    this.seekAuthority = DSActionAuthority.allow,
    this.seekReason,
    this.onSeek,
    this.onClipTap,
    this.onRefused,
    this.laneHeight = 52,
    this.headerWidth = 120,
  });

  static Key laneRegionKey(String trackId) => Key('ds-track-lane-$trackId');
  static Key clipKey(String clipId) => Key('ds-track-clip-$clipId');
  static const Key refusalLineKey = Key('ds-track-lane-refusal');

  @override
  Widget build(BuildContext context) {
    assert(
      !seekAuthority.requiresReason || (seekReason?.trim().isNotEmpty ?? false),
      'DSTrackLane: $seekAuthority seekAuthority requires a non-empty seekReason',
    );

    final detail = seekReason?.trim();
    final announcement = (detail != null && detail.isNotEmpty)
        ? '${track.label}. ${seekAuthority.semanticLabel}: $detail'
        : '${track.label}. ${seekAuthority.semanticLabel}';

    void refuse() {
      onRefused?.call(
        (detail != null && detail.isNotEmpty) ? detail : 'Unavailable',
      );
    }

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: announcement,
      child: KeyedSubtree(
        key: laneRegionKey(track.trackId),
        child: Container(
          height: laneHeight,
          decoration: BoxDecoration(
            color: DSColors.obsidianElevated,
            borderRadius: BorderRadius.circular(DSRadii.sm),
            border: Border.all(color: DSColors.borderSubtle, width: 1),
          ),
          child: Row(
            children: [
              SizedBox(
                width: headerWidth,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: DSSpacing.sm),
                  child: Row(
                    children: [
                      DSIconSmall(icon: track.icon),
                      const SizedBox(width: DSSpacing.xs),
                      Expanded(
                        child: Text(
                          track.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: DSTypography.labelMedium.copyWith(
                            color: seekAuthority.mayDispatch
                                ? DSColors.textPrimary
                                : DSColors.textDisabled,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(width: 1, color: DSColors.borderSubtle),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width =
                        constraints.maxWidth.isFinite &&
                            constraints.maxWidth > 0
                        ? constraints.maxWidth
                        : 1.0;
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      // Child clip taps win the arena; this fires only for
                      // taps on empty lane surface.
                      onTapUp: (details) {
                        if (!seekAuthority.mayDispatch) {
                          refuse();
                          return;
                        }
                        onSeek?.call(
                          DSTimeRuler.positionForPixel(
                            dx: details.localPosition.dx,
                            viewportWidth: width,
                            start: visibleStart,
                            end: visibleEnd,
                          ),
                        );
                      },
                      child: ClipRect(
                        child: Stack(
                          children: [
                            for (final clip in track.clips)
                              _DSTrackClipBlock(
                                clip: clip,
                                visibleStart: visibleStart,
                                visibleEnd: visibleEnd,
                                viewportWidth: width,
                                enabled: seekAuthority.mayDispatch,
                                onTap: onClipTap == null
                                    ? null
                                    : () {
                                        if (!seekAuthority.mayDispatch) {
                                          refuse();
                                          return;
                                        }
                                        onClipTap!(clip.id);
                                      },
                              ),
                            if (seekAuthority.requiresReason)
                              Positioned(
                                right: 8,
                                bottom: 2,
                                child: KeyedSubtree(
                                  key: refusalLineKey,
                                  child: Text(
                                    detail ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: DSTypography.labelSmall.copyWith(
                                      color: DSColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Positioned clip block: proportional left/width, 48dp minimum touch width.
class _DSTrackClipBlock extends StatelessWidget {
  final DSTimelineClip clip;
  final double visibleStart;
  final double visibleEnd;
  final double viewportWidth;
  final bool enabled;
  final VoidCallback? onTap;

  const _DSTrackClipBlock({
    required this.clip,
    required this.visibleStart,
    required this.visibleEnd,
    required this.viewportWidth,
    required this.enabled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final left = DSTimeRuler.pixelForPosition(
      position: clip.start,
      viewportWidth: viewportWidth,
      start: visibleStart,
      end: visibleEnd,
    );
    final right = DSTimeRuler.pixelForPosition(
      position: clip.end,
      viewportWidth: viewportWidth,
      start: visibleStart,
      end: visibleEnd,
    );
    // Donor contract: 48dp minimum touch target, even for short clips.
    final width = (right - left).clamp(kMinInteractiveDimension, viewportWidth);

    return Positioned(
      left: left,
      top: 4,
      bottom: 4,
      child: Semantics(
        button: true,
        enabled: enabled && onTap != null,
        label: '${clip.label}${clip.selected ? '. Selected' : ''}',
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: enabled ? onTap : null,
          child: KeyedSubtree(
            key: DSTrackLane.clipKey(clip.id),
            child: Container(
              width: width,
              padding: const EdgeInsets.symmetric(horizontal: DSSpacing.xs),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: clip.selected
                    ? DSColors.accentCyan.withValues(alpha: 0.25)
                    : DSColors.glassOverlay,
                borderRadius: BorderRadius.circular(DSRadii.xs),
                border: Border.all(
                  color: clip.selected
                      ? DSColors.accentCyan
                      : DSColors.borderSubtle,
                  width: clip.selected ? 2 : 1,
                ),
              ),
              child: Text(
                clip.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: DSTypography.labelSmall.copyWith(
                  color: enabled ? DSColors.textPrimary : DSColors.textDisabled,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Minimal typed-icon helper local to this EXPERIMENTAL seam.
///
/// Uses the shared icon/color vocabulary without owning new icon semantics.
class DSIconSmall extends StatelessWidget {
  final IconData icon;

  const DSIconSmall({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Icon(icon, size: 18, color: DSColors.textSecondary);
  }
}
