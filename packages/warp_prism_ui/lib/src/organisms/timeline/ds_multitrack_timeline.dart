import 'package:flutter/material.dart';

import '../../tokens/ds_action_authority.dart';
import '../../tokens/tokens.dart';
import 'ds_time_ruler.dart';
import 'ds_track_lane.dart';

/// Multitrack timeline — ruler + track lanes + playhead over an injected model.
///
/// Composes [DSTimeRuler], one [DSTrackLane] per track, and a continuous
/// 2px playhead spanning ruler and lanes. All state arrives injected: tick
/// positions, formatters, track/clip view models, and the display position.
/// This organism owns **no** position state, **no** history, and **no** time
/// ontology — it renders what the caller supplies and emits opaque positions
/// through its callbacks.
///
/// Donor shape (INHERITED-REPORT via `docs/bridge/warpblade/ads-debt.md` §3.2
/// `TimelineStrip` — proportional ruler, vertical V1/A1 lanes, continuous
/// playhead with scrubbing and edit action bar — and
/// `docs/bridge/tempest/ads-debt.md` §1.3 `StudioTimelineWorkspace` —
/// multitrack stacking with spatial clip rendering and synchronized
/// ruler/lane layout): ruler + lanes + playhead composition is promoted here;
/// clip painters, waveforms, edit overlays, and DAW orchestration stay
/// product-local.
///
/// Live-vs-committed display is resolved by the caller: [displayPosition] is
/// typically the live position during a scrub and the committed position at
/// rest. The commit invariant (one gesture ⇒ one history step) is enforced
/// product-side through the IDS verbs; the suite proves the fake obeys it.
///
/// Two-ontology conformance: the same organism renders a seconds ruler and a
/// bar/beat ruler because ticks and labels arrive caller-computed through
/// [formatTick]. Prism never converts between ontologies.
///
/// Eligibility follows Task 1868's frozen token-side interface
/// ([DSActionAuthority]) — outcomes are consumed, never re-invented. Denied
/// surfaces stay visible with their reason and route touches to [onRefused].
///
/// Lifecycle: EXPERIMENTAL (Task 1874). Intentionally **not** exported from
/// any barrel and without a `Prism*` alias until the promotion task wires
/// the public surface.
class DSMultitrackTimeline extends StatelessWidget {
  /// Caller-supplied tracks rendered top-to-bottom in order.
  final List<DSTimelineTrack> tracks;

  /// Caller-computed ruler tick positions (opaque numbers).
  final List<double> ticks;

  /// Caller-supplied tick formatter, rendered verbatim per tick.
  final String Function(double tick) formatTick;

  /// Opaque visible-window start (seconds by convention, never interpreted).
  final double visibleStart;

  /// Opaque visible-window end (seconds by convention, never interpreted).
  final double visibleEnd;

  /// Caller-resolved display position for the playhead (live during scrub,
  /// committed at rest — the caller decides).
  final double displayPosition;

  /// Task 1868 outcome governing ruler seek/scrub.
  final DSActionAuthority rulerAuthority;

  /// Reason accompanying a non-allow [rulerAuthority]. Shown, never hidden.
  final String? rulerReason;

  /// Task 1868 outcome governing lane seek/clip taps.
  final DSActionAuthority laneAuthority;

  /// Reason accompanying a non-allow [laneAuthority]. Shown, never hidden.
  final String? laneReason;

  /// Discrete seek callback with the tapped opaque position.
  final ValueChanged<double>? onSeek;

  /// Scrub-gesture callbacks with opaque positions (one gesture ⇒ the
  /// product commits once at [onScrubEnd]).
  final ValueChanged<double>? onScrubStart;
  final ValueChanged<double>? onScrubUpdate;
  final ValueChanged<double>? onScrubEnd;

  /// Clip-tap callback with the tapped clip id.
  final ValueChanged<String>? onClipTap;

  /// Terminal-for-dispatch refusal path: receives the reason when a denied
  /// surface is touched.
  final ValueChanged<String>? onRefused;

  /// Semantic label for the timeline region.
  final String semanticLabel;

  const DSMultitrackTimeline({
    super.key,
    required this.tracks,
    required this.ticks,
    required this.formatTick,
    required this.visibleStart,
    required this.visibleEnd,
    required this.displayPosition,
    this.rulerAuthority = DSActionAuthority.allow,
    this.rulerReason,
    this.laneAuthority = DSActionAuthority.allow,
    this.laneReason,
    this.onSeek,
    this.onScrubStart,
    this.onScrubUpdate,
    this.onScrubEnd,
    this.onClipTap,
    this.onRefused,
    this.semanticLabel = 'Multitrack timeline',
  });

  static const Key timelineRegionKey = Key('ds-multitrack-timeline');
  static const Key playheadKey = Key('ds-multitrack-playhead');

  @override
  Widget build(BuildContext context) {
    assert(
      !rulerAuthority.requiresReason ||
          (rulerReason?.trim().isNotEmpty ?? false),
      'DSMultitrackTimeline: $rulerAuthority rulerAuthority requires a non-empty rulerReason',
    );
    assert(
      !laneAuthority.requiresReason || (laneReason?.trim().isNotEmpty ?? false),
      'DSMultitrackTimeline: $laneAuthority laneAuthority requires a non-empty laneReason',
    );

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: semanticLabel,
      child: KeyedSubtree(
        key: timelineRegionKey,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : 0.0;
            final playheadPx = DSTimeRuler.pixelForPosition(
              position: displayPosition,
              viewportWidth: width <= 0 ? 1.0 : width,
              start: visibleStart,
              end: visibleEnd,
            );

            return Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DSTimeRuler(
                      ticks: ticks,
                      formatTick: formatTick,
                      visibleStart: visibleStart,
                      visibleEnd: visibleEnd,
                      seekAuthority: rulerAuthority,
                      seekReason: rulerReason,
                      onSeek: onSeek,
                      onScrubStart: onScrubStart,
                      onScrubUpdate: onScrubUpdate,
                      onScrubEnd: onScrubEnd,
                      onRefused: onRefused,
                    ),
                    const SizedBox(height: DSSpacing.xs),
                    ...tracks.map(
                      (track) => Padding(
                        padding: const EdgeInsets.only(bottom: DSSpacing.xs),
                        child: DSTrackLane(
                          track: track,
                          visibleStart: visibleStart,
                          visibleEnd: visibleEnd,
                          seekAuthority: laneAuthority,
                          seekReason: laneReason,
                          onSeek: onSeek,
                          onClipTap: onClipTap,
                          onRefused: onRefused,
                        ),
                      ),
                    ),
                  ],
                ),
                // Continuous playhead needle spanning ruler and lanes
                // (donor `TimelinePlayheadNeedle`: 2px luminous line).
                Positioned(
                  left: playheadPx - 1,
                  top: 0,
                  bottom: 0,
                  width: 2,
                  child: IgnorePointer(
                    child: KeyedSubtree(
                      key: playheadKey,
                      child: Container(color: DSColors.accentCyan),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
