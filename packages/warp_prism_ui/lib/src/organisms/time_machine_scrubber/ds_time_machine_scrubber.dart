import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../atoms/ds_glass_panel.dart';
import '../../atoms/ds_icon.dart';
import '../../atoms/ds_text.dart';
import '../../tokens/tokens.dart';

// =============================================================================
// Models
// =============================================================================

/// Severity band for density coloring on a [DSTimeDensityBucket].
///
/// Fixture-friendly risk/activity hint — not a live threat score.
enum DSTimeDensitySeverity {
  /// Neutral activity (default cyan-tinted bars).
  none,

  /// Elevated activity (gold/warning).
  low,

  /// Significant activity (warning-muted / amber).
  medium,

  /// Critical activity (error red).
  high,
}

/// One density histogram bucket for [DSTimeMachineScrubber].
///
/// Domain-agnostic fixture model: event counts over a closed time interval.
/// Pair with [DSTimeline] event lists for narrative detail — this organism is
/// the temporal **control surface**, not the event list.
@immutable
class DSTimeDensityBucket {
  /// Inclusive start of this bucket's interval.
  final DateTime start;

  /// Exclusive end of this bucket's interval (or inclusive if equal to [start]
  /// for zero-width fixture markers — prefer non-zero width).
  final DateTime end;

  /// Activity count for the histogram height (non-negative).
  final int count;

  /// Optional risk/activity severity for bar coloring.
  final DSTimeDensitySeverity severity;

  /// Optional stable id (defaults to ISO start when omitted).
  final String? id;

  /// Optional tooltip / a11y label.
  final String? label;

  const DSTimeDensityBucket({
    required this.start,
    required this.end,
    required this.count,
    this.severity = DSTimeDensitySeverity.none,
    this.id,
    this.label,
  }) : assert(count >= 0, 'count must be non-negative');

  /// Resolved identity for keys / semantics.
  String get resolvedId => id ?? start.toIso8601String();

  Duration get duration {
    final d = end.difference(start);
    return d.isNegative ? Duration.zero : d;
  }

  DSTimeDensityBucket copyWith({
    DateTime? start,
    DateTime? end,
    int? count,
    DSTimeDensitySeverity? severity,
    String? id,
    String? label,
    bool clearId = false,
    bool clearLabel = false,
  }) {
    return DSTimeDensityBucket(
      start: start ?? this.start,
      end: end ?? this.end,
      count: count ?? this.count,
      severity: severity ?? this.severity,
      id: clearId ? null : (id ?? this.id),
      label: clearLabel ? null : (label ?? this.label),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DSTimeDensityBucket &&
        other.start == start &&
        other.end == end &&
        other.count == count &&
        other.severity == severity &&
        other.id == id &&
        other.label == label;
  }

  @override
  int get hashCode => Object.hash(start, end, count, severity, id, label);
}

// =============================================================================
// Organism
// =============================================================================

/// ASW Observatory Organism — Time Machine Scrubber
///
/// Density histogram + playhead scrubber + basic playback transport over a
/// fixture time series. This is **not** an event list: pair with [DSTimeline]
/// (public: `PrismTimeline`) for chronological changelog / narrative entries.
///
/// | Surface | Role |
/// | --- | --- |
/// | **This scrubber** | Temporal control: density, playhead, play/pause, as-of range |
/// | **[DSTimeline]** | Event list / story of workspace evolution |
///
/// ## Domain + playhead
///
/// - Domain is derived from bucket min/max, or from explicit [minTime]/[maxTime].
/// - Playhead is clamped to `[domainStart, domainEnd]`.
/// - **Controlled**: pass [playhead]; parent owns position.
/// - **Uncontrolled** (default): seed from [initialPlayhead] or domain end.
///
/// ## Range callback (as-of projection)
///
/// [onRangeChanged] emits `DateTimeRange(start: domainStart, end: playhead)`
/// on every playhead move — the common History / Map “as-of” filter window.
/// Full domain is available via [domainOf] static helper.
///
/// ## Playback
///
/// Timer-based fixture playback: advances playhead by [playbackStep] every
/// [playbackTickInterval]. Stops at domain end (does not auto-loop).
///
/// Fixture/read-only ADS surface — no product-route coupling, no live feeds.
class DSTimeMachineScrubber extends StatefulWidget {
  /// Density buckets (order does not matter; painted by time).
  final List<DSTimeDensityBucket> buckets;

  /// Explicit domain start. When null, uses earliest bucket start (or now).
  final DateTime? minTime;

  /// Explicit domain end. When null, uses latest bucket end (or now).
  final DateTime? maxTime;

  /// Controlled playhead. When non-null, parent owns position.
  final DateTime? playhead;

  /// Seed for uncontrolled playhead (defaults to domain end / “live”).
  final DateTime? initialPlayhead;

  /// Fired whenever the playhead moves (scrub, transport, or playback tick).
  final ValueChanged<DateTime>? onPlayheadChanged;

  /// Fired with as-of range `[domainStart, playhead]` on playhead changes.
  final ValueChanged<DateTimeRange>? onRangeChanged;

  /// Fired when play/pause state flips (`true` = playing).
  final ValueChanged<bool>? onPlayingChanged;

  /// Start in playing state (uncontrolled only). Defaults to false.
  final bool initiallyPlaying;

  /// Step size for skip buttons and each playback tick.
  final Duration playbackStep;

  /// Interval between playback ticks while playing.
  final Duration playbackTickInterval;

  /// Whether to show skip / play-pause / live transport controls.
  final bool showTransport;

  /// Whether to show the playhead clock label.
  final bool showClock;

  /// Whether to wrap content in [DSGlassPanel].
  final bool wrapInGlass;

  /// Optional panel title (shown above histogram when non-null).
  final String? title;

  /// Empty-state label when [buckets] is empty and domain is degenerate.
  final String emptyLabel;

  /// Semantic label for the scrubber region.
  final String semanticLabel;

  /// Histogram track height (bars only; transport is extra).
  final double histogramHeight;

  const DSTimeMachineScrubber({
    super.key,
    required this.buckets,
    this.minTime,
    this.maxTime,
    this.playhead,
    this.initialPlayhead,
    this.onPlayheadChanged,
    this.onRangeChanged,
    this.onPlayingChanged,
    this.initiallyPlaying = false,
    this.playbackStep = const Duration(minutes: 15),
    this.playbackTickInterval = const Duration(milliseconds: 400),
    this.showTransport = true,
    this.showClock = true,
    this.wrapInGlass = true,
    this.title,
    this.emptyLabel = 'No time series',
    this.semanticLabel = 'Time machine scrubber',
    this.histogramHeight = 56,
  });

  /// Whether playhead is parent-controlled.
  bool get isPlayheadControlled => playhead != null;

  // --- Stable keys / semantics helpers ---

  static const Key panelRegionKey = Key('ds-time-machine-scrubber');
  static const Key histogramKey = Key('ds-time-machine-histogram');
  static const Key playPauseKey = Key('ds-time-machine-play-pause');
  static const Key skipBackKey = Key('ds-time-machine-skip-back');
  static const Key skipForwardKey = Key('ds-time-machine-skip-forward');
  static const Key liveKey = Key('ds-time-machine-live');
  static const Key clockKey = Key('ds-time-machine-clock');
  static const Key emptyPlaceholderKey = Key('ds-time-machine-empty');
  static const Key playheadHandleKey = Key('ds-time-machine-playhead');

  /// Resolve the scrubber domain from buckets and optional overrides.
  ///
  /// Explicit [minTime] / [maxTime] are hard bounds (not expanded by buckets).
  /// Missing ends are derived from the earliest bucket start / latest end.
  static DateTimeRange domainOf({
    required List<DSTimeDensityBucket> buckets,
    DateTime? minTime,
    DateTime? maxTime,
  }) {
    DateTime? derivedStart;
    DateTime? derivedEnd;
    for (final b in buckets) {
      if (derivedStart == null || b.start.isBefore(derivedStart)) {
        derivedStart = b.start;
      }
      if (derivedEnd == null || b.end.isAfter(derivedEnd)) {
        derivedEnd = b.end;
      }
    }
    final epoch = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    var start = minTime ?? derivedStart ?? epoch;
    var end = maxTime ?? derivedEnd ?? start;
    if (end.isBefore(start)) {
      final tmp = start;
      start = end;
      end = tmp;
    }
    if (end == start) {
      // Degenerate: expand by 1h so scrub math stays well-defined.
      end = start.add(const Duration(hours: 1));
    }
    return DateTimeRange(start: start, end: end);
  }

  /// Clamp [value] into [domain].
  static DateTime clampToDomain(DateTime value, DateTimeRange domain) {
    if (value.isBefore(domain.start)) return domain.start;
    if (value.isAfter(domain.end)) return domain.end;
    return value;
  }

  @override
  State<DSTimeMachineScrubber> createState() => _DSTimeMachineScrubberState();
}

class _DSTimeMachineScrubberState extends State<DSTimeMachineScrubber> {
  late DateTime _playhead;
  bool _playing = false;
  Timer? _playbackTimer;

  DateTimeRange get _domain => DSTimeMachineScrubber.domainOf(
    buckets: widget.buckets,
    minTime: widget.minTime,
    maxTime: widget.maxTime,
  );

  DateTime get _effectivePlayhead {
    if (widget.isPlayheadControlled) {
      return DSTimeMachineScrubber.clampToDomain(widget.playhead!, _domain);
    }
    return DSTimeMachineScrubber.clampToDomain(_playhead, _domain);
  }

  bool get _isEmpty => widget.buckets.isEmpty;

  @override
  void initState() {
    super.initState();
    final domain = _domain;
    final seed = widget.initialPlayhead ?? domain.end;
    _playhead = DSTimeMachineScrubber.clampToDomain(seed, domain);
    _playing = widget.initiallyPlaying && !widget.isPlayheadControlled;
    if (_playing) {
      _startPlayback();
    }
    // Defer initial range notification until after first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _emitPlayhead(_effectivePlayhead);
    });
  }

  @override
  void didUpdateWidget(covariant DSTimeMachineScrubber oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlayheadControlled) {
      // Parent owns playhead; stop internal playback if it was running.
      if (_playing) {
        _stopPlayback(notify: true);
      }
    } else if (oldWidget.buckets != widget.buckets ||
        oldWidget.minTime != widget.minTime ||
        oldWidget.maxTime != widget.maxTime) {
      _playhead = DSTimeMachineScrubber.clampToDomain(_playhead, _domain);
    }
  }

  @override
  void dispose() {
    _playbackTimer?.cancel();
    super.dispose();
  }

  void _emitPlayhead(DateTime next) {
    final domain = _domain;
    final clamped = DSTimeMachineScrubber.clampToDomain(next, domain);
    if (!widget.isPlayheadControlled) {
      setState(() => _playhead = clamped);
    }
    widget.onPlayheadChanged?.call(clamped);
    widget.onRangeChanged?.call(
      DateTimeRange(start: domain.start, end: clamped),
    );
  }

  void _setPlaying(bool playing) {
    if (playing == _playing) return;
    setState(() => _playing = playing);
    widget.onPlayingChanged?.call(playing);
    if (playing) {
      _startPlayback();
    } else {
      _playbackTimer?.cancel();
      _playbackTimer = null;
    }
  }

  void _startPlayback() {
    _playbackTimer?.cancel();
    _playbackTimer = Timer.periodic(widget.playbackTickInterval, (_) {
      if (!mounted) return;
      final domain = _domain;
      final current = _effectivePlayhead;
      if (!current.isBefore(domain.end)) {
        _stopPlayback(notify: true);
        return;
      }
      final next = current.add(widget.playbackStep);
      final clamped = DSTimeMachineScrubber.clampToDomain(next, domain);
      _emitPlayhead(clamped);
      if (!clamped.isBefore(domain.end)) {
        _stopPlayback(notify: true);
      }
    });
  }

  void _stopPlayback({required bool notify}) {
    _playbackTimer?.cancel();
    _playbackTimer = null;
    if (_playing) {
      setState(() => _playing = false);
      if (notify) {
        widget.onPlayingChanged?.call(false);
      }
    }
  }

  void _skip(Duration delta) {
    final next = _effectivePlayhead.add(delta);
    _emitPlayhead(next);
  }

  void _jumpLive() {
    _emitPlayhead(_domain.end);
  }

  void _scrubAtLocalX(double localX, double width) {
    if (width <= 0) return;
    final domain = _domain;
    final t = (localX / width).clamp(0.0, 1.0);
    final ms =
        domain.start.millisecondsSinceEpoch +
        ((domain.end.millisecondsSinceEpoch -
                    domain.start.millisecondsSinceEpoch) *
                t)
            .round();
    _emitPlayhead(
      DateTime.fromMillisecondsSinceEpoch(ms, isUtc: domain.start.isUtc),
    );
  }

  @override
  Widget build(BuildContext context) {
    final domain = _domain;
    final playhead = _effectivePlayhead;
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.title != null) ...[
          DSText.labelLarge(widget.title!, color: DSColors.textPrimary),
          const SizedBox(height: DSSpacing.sm),
        ],
        if (_isEmpty && widget.minTime == null && widget.maxTime == null)
          _buildEmpty()
        else ...[
          _buildHistogram(domain, playhead),
          if (widget.showTransport || widget.showClock) ...[
            const SizedBox(height: DSSpacing.sm),
            _buildTransportRow(domain, playhead),
          ],
        ],
      ],
    );

    final body = widget.wrapInGlass
        ? DSGlassPanel.elevated(
            padding: const EdgeInsets.all(DSSpacing.md),
            child: content,
          )
        : Padding(padding: const EdgeInsets.all(DSSpacing.md), child: content);

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: widget.semanticLabel,
      child: KeyedSubtree(
        key: DSTimeMachineScrubber.panelRegionKey,
        child: body,
      ),
    );
  }

  Widget _buildEmpty() {
    return KeyedSubtree(
      key: DSTimeMachineScrubber.emptyPlaceholderKey,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: widget.histogramHeight),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: DSSpacing.sm),
          child: Row(
            children: [
              const DSIcon(
                Icons.timeline_outlined,
                color: DSColors.textTertiary,
                size: 20,
              ),
              const SizedBox(width: DSSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DSText.labelMedium(
                      widget.emptyLabel,
                      color: DSColors.textSecondary,
                    ),
                    const DSText.labelSmall(
                      'Empty fixture · pair with PrismTimeline for events',
                      color: DSColors.textTertiary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistogram(DateTimeRange domain, DateTime playhead) {
    final fraction = _playheadFraction(domain, playhead);
    return Semantics(
      label:
          'Density histogram. Playhead at ${_formatClock(playhead)}. '
          'Drag or tap to scrub.',
      slider: true,
      value: _formatClock(playhead),
      increasedValue: _formatClock(
        DSTimeMachineScrubber.clampToDomain(
          playhead.add(widget.playbackStep),
          domain,
        ),
      ),
      decreasedValue: _formatClock(
        DSTimeMachineScrubber.clampToDomain(
          playhead.subtract(widget.playbackStep),
          domain,
        ),
      ),
      onIncrease: () => _skip(widget.playbackStep),
      onDecrease: () => _skip(-widget.playbackStep),
      child: SizedBox(
        key: DSTimeMachineScrubber.histogramKey,
        height: widget.histogramHeight,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (d) {
                if (_playing) _setPlaying(false);
                _scrubAtLocalX(d.localPosition.dx, width);
              },
              onHorizontalDragStart: (_) {
                if (_playing) _setPlaying(false);
              },
              onHorizontalDragUpdate: (d) {
                _scrubAtLocalX(d.localPosition.dx, width);
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _DensityHistogramPainter(
                        buckets: widget.buckets,
                        domain: domain,
                      ),
                    ),
                  ),
                  // Playhead line + handle
                  Positioned(
                    left: (width * fraction) - 1,
                    top: 0,
                    bottom: 0,
                    child: IgnorePointer(
                      child: KeyedSubtree(
                        key: DSTimeMachineScrubber.playheadHandleKey,
                        child: Container(width: 2, color: DSColors.accentCyan),
                      ),
                    ),
                  ),
                  Positioned(
                    left: (width * fraction) - 6,
                    top: -2,
                    child: IgnorePointer(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: DSColors.accentCyan,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: DSColors.accentCyan.withValues(
                                alpha: 0.45,
                              ),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTransportRow(DateTimeRange domain, DateTime playhead) {
    final atStart = !playhead.isAfter(domain.start);
    final atEnd = !playhead.isBefore(domain.end);

    return Row(
      children: [
        if (widget.showTransport) ...[
          _TransportButton(
            key: DSTimeMachineScrubber.skipBackKey,
            icon: Icons.skip_previous,
            tooltip: 'Skip back',
            semanticLabel: 'Skip back',
            enabled: !atStart,
            onPressed: () {
              if (_playing) _setPlaying(false);
              _skip(-widget.playbackStep);
            },
          ),
          _TransportButton(
            key: DSTimeMachineScrubber.playPauseKey,
            icon: _playing ? Icons.pause : Icons.play_arrow,
            tooltip: _playing ? 'Pause' : 'Play',
            semanticLabel: _playing ? 'Pause playback' : 'Play',
            enabled: true,
            onPressed: () {
              if (_playing) {
                _setPlaying(false);
              } else if (!atEnd) {
                _setPlaying(true);
              } else {
                // At live end: restart from start then play.
                _emitPlayhead(domain.start);
                _setPlaying(true);
              }
            },
          ),
          _TransportButton(
            key: DSTimeMachineScrubber.skipForwardKey,
            icon: Icons.skip_next,
            tooltip: 'Skip forward',
            semanticLabel: 'Skip forward',
            enabled: !atEnd,
            onPressed: () {
              if (_playing) _setPlaying(false);
              _skip(widget.playbackStep);
            },
          ),
          _TransportButton(
            key: DSTimeMachineScrubber.liveKey,
            icon: Icons.fiber_manual_record,
            tooltip: 'Jump to live',
            semanticLabel: 'Jump to live',
            enabled: !atEnd,
            accent: true,
            onPressed: () {
              if (_playing) _setPlaying(false);
              _jumpLive();
            },
          ),
          const SizedBox(width: DSSpacing.sm),
        ],
        if (widget.showClock)
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: KeyedSubtree(
                key: DSTimeMachineScrubber.clockKey,
                child: DSText.labelSmall(
                  _formatClock(playhead),
                  color: DSColors.accentCyan,
                ),
              ),
            ),
          )
        else
          const Spacer(),
      ],
    );
  }

  double _playheadFraction(DateTimeRange domain, DateTime playhead) {
    final total = domain.end.difference(domain.start).inMilliseconds;
    if (total <= 0) return 0;
    final offset = playhead.difference(domain.start).inMilliseconds;
    return (offset / total).clamp(0.0, 1.0);
  }

  String _formatClock(DateTime t) {
    // Compact UTC-ish fixture clock: YYYY-MM-DD HH:mm
    final y = t.year.toString().padLeft(4, '0');
    final m = t.month.toString().padLeft(2, '0');
    final d = t.day.toString().padLeft(2, '0');
    final hh = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $hh:$mm';
  }
}

// =============================================================================
// Transport button
// =============================================================================

class _TransportButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final String semanticLabel;
  final bool enabled;
  final bool accent;
  final VoidCallback onPressed;

  const _TransportButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.semanticLabel,
    required this.enabled,
    required this.onPressed,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = !enabled
        ? DSColors.textDisabled
        : accent
        ? DSColors.statusError
        : DSColors.textPrimary;

    return Semantics(
      button: true,
      enabled: enabled,
      label: semanticLabel,
      child: Tooltip(
        message: tooltip,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: kMinInteractiveDimension,
            minHeight: kMinInteractiveDimension,
          ),
          child: IconButton(
            onPressed: enabled
                ? () {
                    HapticFeedback.selectionClick();
                    onPressed();
                  }
                : null,
            icon: DSIcon(icon, color: color, size: 22),
            splashRadius: kMinInteractiveDimension / 2,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: kMinInteractiveDimension,
              minHeight: kMinInteractiveDimension,
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Histogram painter
// =============================================================================

class _DensityHistogramPainter extends CustomPainter {
  final List<DSTimeDensityBucket> buckets;
  final DateTimeRange domain;

  _DensityHistogramPainter({required this.buckets, required this.domain});

  @override
  void paint(Canvas canvas, Size size) {
    // Track background
    final trackRRect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(DSRadii.sm),
    );
    canvas.drawRRect(trackRRect, Paint()..color = DSColors.obsidianElevated);
    canvas.drawRRect(
      trackRRect,
      Paint()
        ..color = DSColors.borderSubtle
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    if (buckets.isEmpty || size.width <= 0 || size.height <= 0) return;

    final totalMs = domain.end
        .difference(domain.start)
        .inMilliseconds
        .toDouble();
    if (totalMs <= 0) return;

    var maxCount = 1;
    for (final b in buckets) {
      if (b.count > maxCount) maxCount = b.count;
    }

    final barPaint = Paint()..style = PaintingStyle.fill;
    const gap = 1.0;

    for (final b in buckets) {
      final startFrac =
          b.start.difference(domain.start).inMilliseconds / totalMs;
      final endFrac = b.end.difference(domain.start).inMilliseconds / totalMs;
      final left = (startFrac.clamp(0.0, 1.0) * size.width);
      final right = (endFrac.clamp(0.0, 1.0) * size.width);
      var width = math.max(right - left - gap, 1.0);
      if (width + left > size.width) {
        width = size.width - left;
      }
      if (width <= 0) continue;

      final hFrac = b.count / maxCount;
      final barHeight = math.max(
        hFrac * (size.height - 4),
        b.count > 0 ? 2.0 : 0.0,
      );
      if (barHeight <= 0) continue;

      barPaint.color = _colorFor(b.severity).withValues(alpha: 0.75);
      final rect = Rect.fromLTWH(
        left,
        size.height - barHeight - 2,
        width,
        barHeight,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(1)),
        barPaint,
      );
    }
  }

  Color _colorFor(DSTimeDensitySeverity severity) {
    switch (severity) {
      case DSTimeDensitySeverity.none:
        return DSColors.accentCyan;
      case DSTimeDensitySeverity.low:
        return DSColors.accentGold;
      case DSTimeDensitySeverity.medium:
        return DSColors.statusWarning;
      case DSTimeDensitySeverity.high:
        return DSColors.statusError;
    }
  }

  @override
  bool shouldRepaint(covariant _DensityHistogramPainter oldDelegate) {
    return oldDelegate.buckets != buckets ||
        oldDelegate.domain.start != domain.start ||
        oldDelegate.domain.end != domain.end;
  }
}
