import 'package:flutter/material.dart';

import '../../tokens/ds_action_authority.dart';
import '../../tokens/tokens.dart';

/// Time ruler — injected-formatter tick strip with seek/scrub gestures.
///
/// Renders caller-computed [ticks] (opaque positions) through the injected
/// [formatTick] (the Task 1875 formatter seam: per-tick strings rendered
/// verbatim). The caller owns all temporal semantics — seconds spacing,
/// bar/beat grouping, tick density — this strip only lays out what it
/// receives.
///
/// Donor shape (INHERITED-REPORT via `docs/bridge/warpblade/ads-debt.md` §3.3
/// `TimelineRuler` — graduated strip with click/drag seek — and
/// `docs/bridge/tempest/ads-debt.md` §1.2 `MusicalRulerBar` — zoom control,
/// position readout, click/drag scrub area): the graduated strip plus the
/// click/drag gesture discipline are promoted here; zoom controls, tempo
/// evaluation, and painters stay product-local.
///
/// Gestures emit opaque positions only: tap ⇒ [onSeek], horizontal drag ⇒
/// [onScrubStart]/[onScrubUpdate]/[onScrubEnd] (one gesture ⇒ the product
/// commits once at [onScrubEnd]). The product turns those callbacks into IDS
/// `TimelineIntent` verbs; this widget never imports interaction semantics.
///
/// Eligibility follows Task 1868's frozen token-side interface
/// ([DSActionAuthority]) — outcomes are consumed, never re-invented. A denied
/// strip stays visible with its reason and routes touches to [onRefused]
/// instead of dispatching.
///
/// Pixel mapping mirrors the IDS `timeForPixel` proportional rule
/// (fixed geometry ⇒ fixed mapping); the arithmetic is duplicated here
/// deliberately so this layer keeps its dev-only interaction boundary.
///
/// Lifecycle: EXPERIMENTAL (Task 1874). Intentionally **not** exported from
/// any barrel and without a `Prism*` alias until the promotion task wires
/// the public surface.
class DSTimeRuler extends StatefulWidget {
  /// Caller-computed tick positions (opaque numbers, ascending by convention).
  final List<double> ticks;

  /// Caller-supplied tick formatter, rendered verbatim per tick.
  final String Function(double tick) formatTick;

  /// Opaque visible-window start (seconds by convention, never interpreted).
  final double visibleStart;

  /// Opaque visible-window end (seconds by convention, never interpreted).
  final double visibleEnd;

  /// Task 1868 outcome governing seek/scrub on this strip.
  final DSActionAuthority seekAuthority;

  /// Reason accompanying a non-allow [seekAuthority]. Shown, never hidden.
  final String? seekReason;

  /// Discrete seek callback with the tapped opaque position. Null disables.
  final ValueChanged<double>? onSeek;

  /// Scrub-gesture callbacks with opaque positions. Null disables scrubbing
  /// (taps still seek when [onSeek] is set).
  final ValueChanged<double>? onScrubStart;
  final ValueChanged<double>? onScrubUpdate;
  final ValueChanged<double>? onScrubEnd;

  /// Terminal-for-dispatch refusal path: receives the reason when a denied
  /// strip is touched.
  final ValueChanged<String>? onRefused;

  /// Semantic label for the ruler region.
  final String semanticLabel;

  const DSTimeRuler({
    super.key,
    required this.ticks,
    required this.formatTick,
    required this.visibleStart,
    required this.visibleEnd,
    this.seekAuthority = DSActionAuthority.allow,
    this.seekReason,
    this.onSeek,
    this.onScrubStart,
    this.onScrubUpdate,
    this.onScrubEnd,
    this.onRefused,
    this.semanticLabel = 'Time ruler',
  });

  static const Key rulerRegionKey = Key('ds-time-ruler');
  static const Key refusalLineKey = Key('ds-time-ruler-refusal');

  /// Proportional pixel→position rule (mirrors IDS `timeForPixel`).
  static double positionForPixel({
    required double dx,
    required double viewportWidth,
    required double start,
    required double end,
  }) {
    assert(viewportWidth > 0, 'DSTimeRuler: viewportWidth must be positive');
    assert(end > start, 'DSTimeRuler: end must exceed start');
    final clamped = dx.clamp(0.0, viewportWidth);
    return start + (clamped / viewportWidth) * (end - start);
  }

  /// Proportional position→pixel rule (mirrors IDS `pixelForTime`).
  static double pixelForPosition({
    required double position,
    required double viewportWidth,
    required double start,
    required double end,
  }) {
    assert(viewportWidth > 0, 'DSTimeRuler: viewportWidth must be positive');
    assert(end > start, 'DSTimeRuler: end must exceed start');
    final clamped = position.clamp(start, end);
    return ((clamped - start) / (end - start)) * viewportWidth;
  }

  @override
  State<DSTimeRuler> createState() => _DSTimeRulerState();
}

class _DSTimeRulerState extends State<DSTimeRuler> {
  /// Last drag position in local pixels, so gesture close can commit it.
  double? _lastDragDx;
  double _lastWidth = 1.0;

  @override
  Widget build(BuildContext context) {
    assert(
      !widget.seekAuthority.requiresReason ||
          (widget.seekReason?.trim().isNotEmpty ?? false),
      'DSTimeRuler: ${widget.seekAuthority} seekAuthority requires a non-empty seekReason',
    );

    final mayDispatch =
        widget.seekAuthority.mayDispatch &&
        (widget.onSeek != null || widget.onScrubEnd != null);
    final detail = widget.seekReason?.trim();
    final announcement = (detail != null && detail.isNotEmpty)
        ? '${widget.semanticLabel}. ${widget.seekAuthority.semanticLabel}: $detail'
        : '${widget.semanticLabel}. ${widget.seekAuthority.semanticLabel}';

    double positionAt(double dx) => DSTimeRuler.positionForPixel(
      dx: dx,
      viewportWidth: _lastWidth <= 0 ? 1.0 : _lastWidth,
      start: widget.visibleStart,
      end: widget.visibleEnd,
    );

    void refuse() {
      widget.onRefused?.call(
        (detail != null && detail.isNotEmpty) ? detail : 'Unavailable',
      );
    }

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: announcement,
      child: KeyedSubtree(
        key: DSTimeRuler.rulerRegionKey,
        child: Container(
          constraints: const BoxConstraints(
            minHeight: kMinInteractiveDimension,
          ),
          decoration: BoxDecoration(
            color: DSColors.obsidianElevated,
            borderRadius: BorderRadius.circular(DSRadii.sm),
            border: Border.all(color: DSColors.borderSubtle, width: 1),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth.isFinite && constraints.maxWidth > 0) {
                _lastWidth = constraints.maxWidth;
              }
              final width = _lastWidth <= 0 ? 1.0 : _lastWidth;

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (details) {
                  if (!widget.seekAuthority.mayDispatch) {
                    refuse();
                    return;
                  }
                  widget.onSeek?.call(positionAt(details.localPosition.dx));
                },
                onHorizontalDragStart: (details) {
                  if (!widget.seekAuthority.mayDispatch) {
                    refuse();
                    return;
                  }
                  _lastDragDx = details.localPosition.dx;
                  widget.onScrubStart?.call(positionAt(_lastDragDx!));
                },
                onHorizontalDragUpdate: (details) {
                  if (!widget.seekAuthority.mayDispatch) return;
                  _lastDragDx = details.localPosition.dx;
                  widget.onScrubUpdate?.call(positionAt(_lastDragDx!));
                },
                onHorizontalDragEnd: (_) {
                  if (!widget.seekAuthority.mayDispatch) return;
                  // Gesture close commits the last known position: the
                  // product turns this into exactly one history step.
                  final dx = _lastDragDx;
                  _lastDragDx = null;
                  if (dx != null) widget.onScrubEnd?.call(positionAt(dx));
                },
                onHorizontalDragCancel: () {
                  _lastDragDx = null;
                },
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: kMinInteractiveDimension,
                  ),
                  child: Stack(
                    children: [
                      CustomPaint(
                        painter: _DSTimeRulerTickPainter(
                          ticks: widget.ticks,
                          visibleStart: widget.visibleStart,
                          visibleEnd: widget.visibleEnd,
                          viewportWidth: width,
                          color: DSColors.borderSubtle,
                        ),
                        // Fixed-height child: this strip must stay bounded
                        // even inside unbounded parents (e.g. a Stack).
                        child: const SizedBox(
                          width: double.infinity,
                          height: kMinInteractiveDimension,
                        ),
                      ),
                      ...widget.ticks.map((tick) {
                        final px = DSTimeRuler.pixelForPosition(
                          position: tick,
                          viewportWidth: width,
                          start: widget.visibleStart,
                          end: widget.visibleEnd,
                        );
                        return Positioned(
                          left: px + 4,
                          top: 4,
                          child: Text(
                            widget.formatTick(tick),
                            maxLines: 1,
                            overflow: TextOverflow.clip,
                            style: DSTypography.labelSmall.copyWith(
                              fontFamily: 'monospace',
                              color: mayDispatch
                                  ? DSColors.textSecondary
                                  : DSColors.textDisabled,
                            ),
                          ),
                        );
                      }),
                      if (widget.seekAuthority.requiresReason)
                        Positioned(
                          right: 8,
                          bottom: 2,
                          child: KeyedSubtree(
                            key: DSTimeRuler.refusalLineKey,
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
      ),
    );
  }
}

/// Tick-mark painter: vertical marks at proportional positions.
///
/// Pure layout of caller-supplied ticks — no tick math, no labels, no time
/// semantics. Deterministic in its inputs.
class _DSTimeRulerTickPainter extends CustomPainter {
  final List<double> ticks;
  final double visibleStart;
  final double visibleEnd;
  final double viewportWidth;
  final Color color;

  const _DSTimeRulerTickPainter({
    required this.ticks,
    required this.visibleStart,
    required this.visibleEnd,
    required this.viewportWidth,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    final span = visibleEnd - visibleStart;
    if (span <= 0 || viewportWidth <= 0) return;
    for (final tick in ticks) {
      final clamped = tick.clamp(visibleStart, visibleEnd);
      final px = ((clamped - visibleStart) / span) * viewportWidth;
      canvas.drawLine(
        Offset(px, size.height - 14),
        Offset(px, size.height - 4),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DSTimeRulerTickPainter oldDelegate) =>
      oldDelegate.ticks != ticks ||
      oldDelegate.visibleStart != visibleStart ||
      oldDelegate.visibleEnd != visibleEnd ||
      oldDelegate.viewportWidth != viewportWidth ||
      oldDelegate.color != color;
}
