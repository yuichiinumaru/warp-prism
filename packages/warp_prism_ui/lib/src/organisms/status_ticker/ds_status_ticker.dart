import 'dart:async';

import 'package:flutter/material.dart';

import '../../atoms/ds_glass_panel.dart';
import '../../atoms/ds_status_dot.dart';
import '../../atoms/ds_text.dart';
import '../../tokens/tokens.dart';

// =============================================================================
// Models
// =============================================================================

/// Presentation mode for [DSStatusTicker].
///
/// - [rotate]: show one item at a time; advance on a timer.
/// - [marquee]: continuous horizontal track of all items.
///
/// ## Reduced motion
///
/// When [MediaQuery.disableAnimationsOf] is true (or [DSStatusTicker.animate]
/// is false), both modes fall back to a **static** strip: items are listed
/// without auto-advance or marquee motion so screen-reader / keyboard users
/// are never limited to infinite-only content.
enum DSStatusTickerMode {
  /// One status item visible; advances through the feed on an interval.
  rotate,

  /// All items laid out on a continuous horizontal marquee track.
  marquee,
}

/// One fixture status line for [DSStatusTicker].
///
/// Domain-agnostic feed chip: primary [text], optional [detail] (value / delta),
/// and optional [state] for severity coloring via operational-state tokens.
@immutable
class DSStatusTickerItem {
  /// Stable identity within a feed (used for keys / semantics).
  final String id;

  /// Primary status message (e.g. `"Feed latency"`).
  final String text;

  /// Optional secondary value or delta (e.g. `"42ms"`, `"+3"`).
  final String? detail;

  /// Optional operational state for severity styling (dot + accent color).
  ///
  /// Uses the existing [DSOperationalState] vocabulary — no parallel severity
  /// enum is introduced for this organism.
  final DSOperationalState? state;

  /// Optional leading label / source tag (e.g. `"MAP"`, `"OPS"`).
  final String? source;

  const DSStatusTickerItem({
    required this.id,
    required this.text,
    this.detail,
    this.state,
    this.source,
  });

  /// Human-readable summary for a11y and static reduced-motion alternatives.
  String get accessibilitySummary {
    final parts = <String>[
      if (source != null && source!.isNotEmpty) source!,
      text,
      if (detail != null && detail!.isNotEmpty) detail!,
      if (state != null) state!.label,
    ];
    return parts.join(', ');
  }

  /// Accent color derived from [state], or cyan default when unset.
  Color get accentColor => state?.color ?? DSColors.accentCyan;

  DSStatusTickerItem copyWith({
    String? id,
    String? text,
    String? detail,
    DSOperationalState? state,
    String? source,
    bool clearDetail = false,
    bool clearState = false,
    bool clearSource = false,
  }) {
    return DSStatusTickerItem(
      id: id ?? this.id,
      text: text ?? this.text,
      detail: clearDetail ? null : (detail ?? this.detail),
      state: clearState ? null : (state ?? this.state),
      source: clearSource ? null : (source ?? this.source),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DSStatusTickerItem &&
        other.id == id &&
        other.text == text &&
        other.detail == detail &&
        other.state == state &&
        other.source == source;
  }

  @override
  int get hashCode => Object.hash(id, text, detail, state, source);
}

// =============================================================================
// Controller (testable rotation)
// =============================================================================

/// Imperative handle for [DSStatusTicker] rotation / pause state.
///
/// Tests inject a controller and call [advance] / [pause] / [resume] without
/// waiting on real timers. When attached, the widget still owns timers for
/// auto-rotate unless [autoRotate] is false on the ticker.
class DSStatusTickerController extends ChangeNotifier {
  int _index = 0;
  bool _paused = false;

  /// Current zero-based item index.
  int get index => _index;

  /// Whether auto-rotation / marquee motion is paused.
  bool get isPaused => _paused;

  /// Jump to [index] (clamped by the attached ticker when items are known).
  void goTo(int index) {
    if (_index == index) return;
    _index = index < 0 ? 0 : index;
    notifyListeners();
  }

  /// Advance to the next item. [itemCount] wraps the index.
  void advance({required int itemCount}) {
    if (itemCount <= 0) return;
    _index = (_index + 1) % itemCount;
    notifyListeners();
  }

  /// Pause auto motion (hover, reduced-motion, or test).
  void pause() {
    if (_paused) return;
    _paused = true;
    notifyListeners();
  }

  /// Resume auto motion.
  void resume() {
    if (!_paused) return;
    _paused = false;
    notifyListeners();
  }

  /// Reset index and pause flag (does not dispose).
  void reset() {
    _index = 0;
    _paused = false;
    notifyListeners();
  }
}

// =============================================================================
// Fixtures
// =============================================================================

/// Mock status feed items for gallery and tests (no live network).
abstract final class DSStatusTickerFixtures {
  /// Deterministic multi-severity mock feed for gallery demos.
  static List<DSStatusTickerItem> mockFeed() => const [
    DSStatusTickerItem(
      id: 'feed-health',
      source: 'MAP',
      text: 'Tile feed healthy',
      detail: '12 providers',
      state: DSOperationalState.healthy,
    ),
    DSStatusTickerItem(
      id: 'latency',
      source: 'OPS',
      text: 'P95 latency',
      detail: '84 ms',
      state: DSOperationalState.running,
    ),
    DSStatusTickerItem(
      id: 'stale-agents',
      source: 'GOV',
      text: 'Stale agent proofs',
      detail: '3',
      state: DSOperationalState.stale,
    ),
    DSStatusTickerItem(
      id: 'degraded-mesh',
      source: 'MESH',
      text: 'Mesh peer lag',
      detail: 'degraded',
      state: DSOperationalState.degraded,
    ),
    DSStatusTickerItem(
      id: 'error-pipeline',
      source: 'RUN',
      text: 'Pipeline failure',
      detail: 'task-1407',
      state: DSOperationalState.error,
    ),
    DSStatusTickerItem(
      id: 'pending-review',
      source: 'REV',
      text: 'Awaiting review',
      detail: '2 packets',
      state: DSOperationalState.pending,
    ),
  ];
}

// =============================================================================
// Organism
// =============================================================================

/// ASW Observatory Organism — Status Ticker
///
/// Full-width bottom marquee / rotating status strip for fixture feed items.
/// Severity accents use existing [DSOperationalState] tokens (dot + color).
///
/// | Surface | Role |
/// | --- | --- |
/// | **This ticker** | Continuous chrome: rotating or marquee status chips |
/// | **[DSStatusGrid]** | Service health **grid** of cards |
/// | **Toast system** | Discrete notifications — not a continuous strip |
///
/// ## Motion contract
///
/// - Rotate interval defaults to 3s (fixture-friendly, not live clock).
/// - Optional [pauseOnHover] freezes auto motion under pointer.
/// - Honors [MediaQuery.disableAnimationsOf] and [animate]: reduced motion
///   disables auto-rotate / marquee and shows a **static** item strip so
///   content is never infinite-animation-only (a11y).
/// - Durations/curves reference [DSMotion] where transitions apply.
///
/// Fixture/read-only ADS surface — no product-route coupling, no live feeds.
class DSStatusTicker extends StatefulWidget {
  /// Status feed items (order is display order).
  final List<DSStatusTickerItem> items;

  /// Rotate one-at-a-time or marquee track. Defaults to [DSStatusTickerMode.rotate].
  final DSStatusTickerMode mode;

  /// Interval between rotate advances. Ignored in marquee / reduced motion.
  final Duration rotateInterval;

  /// Marquee scroll period for one full track width (approximate).
  final Duration marqueePeriod;

  /// When true, pointer enter pauses motion; leave resumes.
  final bool pauseOnHover;

  /// When false, force static presentation (also forced by reduced motion).
  final bool animate;

  /// When false, never start the auto-rotate timer (controller-driven only).
  final bool autoRotate;

  /// Optional external controller for index / pause (testable).
  final DSStatusTickerController? controller;

  /// Fired when the visible rotate index changes.
  final ValueChanged<int>? onIndexChanged;

  /// Fired when an item chip is activated (tap / enter).
  final ValueChanged<DSStatusTickerItem>? onItemTap;

  /// Whether to wrap content in [DSGlassPanel.subtle].
  final bool wrapInGlass;

  /// Strip height (content + padding). Defaults to 48 (WCAG min target).
  final double height;

  /// Empty-state label when [items] is empty.
  final String emptyLabel;

  /// Semantic label for the ticker region.
  final String semanticLabel;

  /// Optional leading live indicator label (e.g. `"LIVE"`). Null hides badge.
  final String? liveBadge;

  /// When true and reduced motion / static, show all items in a row rather
  /// than only the current rotate index.
  final bool showAllWhenStatic;

  const DSStatusTicker({
    super.key,
    required this.items,
    this.mode = DSStatusTickerMode.rotate,
    this.rotateInterval = const Duration(seconds: 3),
    this.marqueePeriod = const Duration(seconds: 24),
    this.pauseOnHover = true,
    this.animate = true,
    this.autoRotate = true,
    this.controller,
    this.onIndexChanged,
    this.onItemTap,
    this.wrapInGlass = true,
    this.height = 48,
    this.emptyLabel = 'No status items',
    this.semanticLabel = 'Status ticker',
    this.liveBadge = 'LIVE',
    this.showAllWhenStatic = true,
  });

  // Test keys
  static const Key regionKey = Key('ds-status-ticker');
  static const Key emptyKey = Key('ds-status-ticker-empty');
  static const Key itemPrefixKey = Key('ds-status-ticker-item');
  static const Key liveBadgeKey = Key('ds-status-ticker-live');
  static const Key trackKey = Key('ds-status-ticker-track');
  static const Key staticListKey = Key('ds-status-ticker-static');
  static const Key indexLabelKey = Key('ds-status-ticker-index');

  /// Key for a specific item by id.
  static Key itemKey(String id) => Key('ds-status-ticker-item-$id');

  @override
  State<DSStatusTicker> createState() => _DSStatusTickerState();
}

class _DSStatusTickerState extends State<DSStatusTicker>
    with SingleTickerProviderStateMixin {
  DSStatusTickerController? _ownedController;
  Timer? _rotateTimer;
  AnimationController? _marqueeController;
  bool _hoverPaused = false;

  DSStatusTickerController get _ctrl => widget.controller ?? _ownedController!;

  bool _depsReady = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _ownedController = DSStatusTickerController();
    }
    _ctrl.addListener(_onControllerChanged);
    // Motion timers start in [didChangeDependencies] (needs MediaQuery).
  }

  @override
  void didUpdateWidget(covariant DSStatusTicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      final previous = oldWidget.controller ?? _ownedController;
      previous?.removeListener(_onControllerChanged);
      if (oldWidget.controller == null) {
        _ownedController?.dispose();
        _ownedController = null;
      }
      if (widget.controller == null) {
        final seed = previous?.index ?? 0;
        _ownedController = DSStatusTickerController()
          ..goTo(seed.clamp(0, _maxIndex));
      }
      _ctrl.addListener(_onControllerChanged);
    }
    if (widget.items.isNotEmpty && _ctrl.index >= widget.items.length) {
      _ctrl.goTo(widget.items.length - 1);
    }
    if (oldWidget.items.length != widget.items.length ||
        oldWidget.mode != widget.mode ||
        oldWidget.animate != widget.animate ||
        oldWidget.autoRotate != widget.autoRotate ||
        oldWidget.rotateInterval != widget.rotateInterval ||
        oldWidget.marqueePeriod != widget.marqueePeriod) {
      _syncMotion();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _depsReady = true;
    _syncMotion();
  }

  @override
  void dispose() {
    _rotateTimer?.cancel();
    _marqueeController?.dispose();
    _ctrl.removeListener(_onControllerChanged);
    _ownedController?.dispose();
    super.dispose();
  }

  int get _maxIndex => widget.items.isEmpty ? 0 : widget.items.length - 1;

  int get _safeIndex {
    if (widget.items.isEmpty) return 0;
    return _ctrl.index.clamp(0, widget.items.length - 1);
  }

  bool get _reduceMotion {
    if (!widget.animate) return true;
    return MediaQuery.disableAnimationsOf(context);
  }

  bool get _motionPaused => _ctrl.isPaused || _hoverPaused || _reduceMotion;

  void _onControllerChanged() {
    if (!mounted) return;
    setState(() {});
    widget.onIndexChanged?.call(_safeIndex);
    if (_depsReady) _syncMotion();
  }

  void _syncMotion() {
    if (!_depsReady || !mounted) return;

    _rotateTimer?.cancel();
    _rotateTimer = null;

    if (widget.items.isEmpty || _reduceMotion) {
      _marqueeController?.stop();
      return;
    }

    if (widget.mode == DSStatusTickerMode.marquee) {
      _ensureMarquee();
      if (_motionPaused) {
        _marqueeController?.stop();
      } else {
        _marqueeController?.repeat();
      }
      return;
    }

    // rotate mode
    _marqueeController?.stop();
    if (!widget.autoRotate || _motionPaused || widget.items.length <= 1) {
      return;
    }
    _rotateTimer = Timer.periodic(widget.rotateInterval, (_) {
      if (!mounted || _motionPaused) return;
      _ctrl.advance(itemCount: widget.items.length);
    });
  }

  void _ensureMarquee() {
    _marqueeController ??= AnimationController(
      vsync: this,
      duration: widget.marqueePeriod,
    );
    if (_marqueeController!.duration != widget.marqueePeriod) {
      _marqueeController!.duration = widget.marqueePeriod;
    }
  }

  void _onHover(bool hovering) {
    if (!widget.pauseOnHover) return;
    setState(() => _hoverPaused = hovering);
    _syncMotion();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return Semantics(
        container: true,
        label: '${widget.semanticLabel}, empty',
        child: _wrapChrome(
          key: DSStatusTicker.emptyKey,
          child: Center(
            child: DSText.labelSmall(
              widget.emptyLabel,
              color: DSColors.textTertiary,
            ),
          ),
        ),
      );
    }

    // Reduced motion: always show static multi-item strip so content is never
    // infinite-animation-only. Optional showAllWhenStatic also forces the
    // static strip when auto-rotate is off and no controller drives index.
    final useStatic =
        _reduceMotion ||
        (widget.showAllWhenStatic &&
            !widget.autoRotate &&
            widget.controller == null &&
            widget.mode == DSStatusTickerMode.rotate);

    final body = useStatic
        ? _buildStaticStrip()
        : switch (widget.mode) {
            DSStatusTickerMode.rotate => _buildRotate(),
            DSStatusTickerMode.marquee => _buildMarquee(),
          };

    final current = widget.items[_safeIndex];
    final regionLabel = useStatic
        ? '${widget.semanticLabel}. '
              '${widget.items.map((e) => e.accessibilitySummary).join('. ')}'
        : '${widget.semanticLabel}. '
              'Item ${_safeIndex + 1} of ${widget.items.length}. '
              '${current.accessibilitySummary}';

    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: Semantics(
        container: true,
        // Keep chip button nodes independent when items are tappable so
        // screen readers can activate individual status chips.
        explicitChildNodes: widget.onItemTap != null,
        liveRegion: !_reduceMotion && widget.mode == DSStatusTickerMode.rotate,
        label: regionLabel,
        child: _wrapChrome(key: DSStatusTicker.regionKey, child: body),
      ),
    );
  }

  Widget _wrapChrome({required Key key, required Widget child}) {
    final padded = SizedBox(
      key: key,
      height: widget.height,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: DSSpacing.sm),
        child: Row(
          children: [
            if (widget.liveBadge != null) ...[
              _LiveBadge(label: widget.liveBadge!),
              const SizedBox(width: DSSpacing.sm),
            ],
            Expanded(child: child),
            if (!_reduceMotion &&
                widget.mode == DSStatusTickerMode.rotate &&
                widget.items.length > 1) ...[
              const SizedBox(width: DSSpacing.sm),
              KeyedSubtree(
                key: DSStatusTicker.indexLabelKey,
                child: DSText.labelSmall(
                  '${_safeIndex + 1}/${widget.items.length}',
                  color: DSColors.textTertiary,
                ),
              ),
            ],
          ],
        ),
      ),
    );

    if (!widget.wrapInGlass) return padded;

    return DSGlassPanel.subtle(
      radius: DSRadii.sm,
      padding: EdgeInsets.zero,
      child: padded,
    );
  }

  Widget _buildRotate() {
    final item = widget.items[_safeIndex];
    return AnimatedSwitcher(
      duration: _reduceMotion ? Duration.zero : DSMotion.normal,
      switchInCurve: DSMotion.enter,
      switchOutCurve: DSMotion.exit,
      child: Align(
        key: ValueKey<String>('rotate-${item.id}-$_safeIndex'),
        alignment: Alignment.centerLeft,
        child: _StatusChip(item: item, onTap: widget.onItemTap),
      ),
    );
  }

  Widget _buildStaticStrip() {
    return SingleChildScrollView(
      key: DSStatusTicker.staticListKey,
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < widget.items.length; i++) ...[
            if (i > 0) const _Separator(),
            _StatusChip(item: widget.items[i], onTap: widget.onItemTap),
          ],
        ],
      ),
    );
  }

  Widget _buildMarquee() {
    _ensureMarquee();
    final controller = _marqueeController!;
    // Duplicate track for seamless loop.
    final track = Row(
      key: DSStatusTicker.trackKey,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var pass = 0; pass < 2; pass++)
          for (var i = 0; i < widget.items.length; i++) ...[
            if (!(pass == 0 && i == 0)) const _Separator(),
            _StatusChip(item: widget.items[i], onTap: widget.onItemTap),
          ],
      ],
    );

    return ClipRect(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return LayoutBuilder(
            builder: (context, constraints) {
              // Shift by half of intrinsic track (one full item set).
              return OverflowBox(
                alignment: Alignment.centerLeft,
                maxWidth: double.infinity,
                child: Transform.translate(
                  offset: Offset(-controller.value * _estimateTrackWidth(), 0),
                  child: child,
                ),
              );
            },
          );
        },
        child: track,
      ),
    );
  }

  /// Approximate half-track width for marquee offset (item chips + separators).
  double _estimateTrackWidth() {
    // Each chip ~ 160–220; use a stable estimate scaled by count.
    // Actual visual may clip slightly — fixture polish, not pixel-perfect.
    const perItem = 180.0;
    return widget.items.length * perItem;
  }
}

// =============================================================================
// Private chrome
// =============================================================================

class _LiveBadge extends StatelessWidget {
  final String label;

  const _LiveBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: DSStatusTicker.liveBadgeKey,
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.xs,
        vertical: DSSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: DSColors.accentCyan.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(DSRadii.xs),
        border: Border.all(color: DSColors.accentCyan.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: DSColors.accentCyan,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: DSSpacing.xs),
          DSText.labelSmall(label, color: DSColors.accentCyan),
        ],
      ),
    );
  }
}

class _Separator extends StatelessWidget {
  const _Separator();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: DSSpacing.sm),
      child: DSText.labelSmall('·', color: DSColors.textTertiary),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final DSStatusTickerItem item;
  final ValueChanged<DSStatusTickerItem>? onTap;

  const _StatusChip({required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final accent = item.accentColor;
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (item.state != null) ...[
          DSStatusDot(
            color: accent,
            size: 7,
            animated:
                item.state == DSOperationalState.running ||
                item.state == DSOperationalState.exposed,
          ),
          const SizedBox(width: DSSpacing.xs),
        ],
        if (item.source != null && item.source!.isNotEmpty) ...[
          DSText.labelSmall(item.source!, color: accent),
          const SizedBox(width: DSSpacing.xs),
        ],
        DSText.labelMedium(
          item.text,
          color: DSColors.textPrimary,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (item.detail != null && item.detail!.isNotEmpty) ...[
          const SizedBox(width: DSSpacing.xs),
          DSText.labelSmall(
            item.detail!,
            color: accent,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );

    final keyed = KeyedSubtree(
      key: DSStatusTicker.itemKey(item.id),
      child: child,
    );

    if (onTap == null) return keyed;

    // Interactive chips expose button semantics and a WCAG 48x48 target.
    return Semantics(
      container: true,
      button: true,
      label: item.accessibilitySummary,
      excludeSemantics: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: () => onTap!(item),
            borderRadius: BorderRadius.circular(DSRadii.xs),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: DSSpacing.xxs,
                vertical: DSSpacing.xxs,
              ),
              child: Align(alignment: Alignment.centerLeft, child: keyed),
            ),
          ),
        ),
      ),
    );
  }
}
