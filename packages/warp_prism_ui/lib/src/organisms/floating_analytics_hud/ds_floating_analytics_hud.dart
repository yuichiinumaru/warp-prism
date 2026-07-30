import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../atoms/ds_glass_panel.dart';
import '../../tokens/tokens.dart';
import 'ds_floating_analytics_hud_chrome.dart';
import 'ds_floating_analytics_hud_controller.dart';
import 'ds_floating_analytics_models.dart';

export 'ds_floating_analytics_fixtures.dart';
export 'ds_floating_analytics_hud_controller.dart';
export 'ds_floating_analytics_models.dart';

// =============================================================================
// Organism
// =============================================================================

/// ASW Observatory Organism — Floating Analytics HUD
///
/// Draggable, minimizable multi-section analytics overlay for stage hosts
/// (Map / CyberCore). Compose [DSMetricTile] cells inside glass chrome with a
/// drag handle, minimize control, and optional close.
///
/// Place inside a bounded [Stack] / [SizedBox] stage. The HUD fills the host
/// with a non-blocking [Stack] and positions the panel; pointer events outside
/// the panel pass through to underlying stage content.
///
/// EPIC-15 O-09 / Task 1514. Harvests shell affordances from ShadowBroker
/// `GtAnalyticsHud` — not GT domain math. Fixture metrics only.
class DSFloatingAnalyticsHud extends StatefulWidget {
  /// Analytics sections (order preserved).
  final List<DSFloatingAnalyticsSection> sections;

  /// Panel title in the chrome header.
  final String title;

  /// Seed offset when no [controller] is provided.
  final Offset initialOffset;

  /// Fixed panel width. Height grows with content when expanded.
  final double panelWidth;

  /// Max expanded body height before the section list scrolls.
  final double maxBodyHeight;

  /// Controlled minimize. When non-null, parent owns minimize state.
  final bool? minimized;

  /// Seed minimize for uncontrolled mode (ignored when [controller] attached).
  final bool initiallyMinimized;

  /// Optional imperative controller (position + minimize + visibility).
  final DSFloatingAnalyticsHudController? controller;

  /// Called when minimize / expand changes.
  final ValueChanged<bool>? onMinimizedChanged;

  /// Called when drag or [controller.moveTo] commits a new offset.
  final ValueChanged<Offset>? onOffsetChanged;

  /// Called when close is activated (button or [controller.close]).
  final VoidCallback? onClose;

  /// Whether to show the close control.
  final bool showClose;

  /// Whether to wrap the panel in [DSGlassPanel].
  final bool wrapInGlass;

  /// Optional semantic label for the panel region.
  final String semanticLabel;

  /// When false, renders nothing (also driven by [controller.isVisible]).
  final bool visible;

  /// Compact metric tiles in dense dashboards (default true for overlay density).
  final bool compactMetrics;

  /// Minimum interactive dimension for header controls (default 48dp).
  static const double minInteractiveSize = kMinInteractiveDimension;

  const DSFloatingAnalyticsHud({
    super.key,
    required this.sections,
    this.title = 'Analytics',
    this.initialOffset = const Offset(16, 16),
    this.panelWidth = 320,
    this.maxBodyHeight = 360,
    this.minimized,
    this.initiallyMinimized = false,
    this.controller,
    this.onMinimizedChanged,
    this.onOffsetChanged,
    this.onClose,
    this.showClose = true,
    this.wrapInGlass = true,
    this.semanticLabel = 'Floating analytics HUD',
    this.visible = true,
    this.compactMetrics = true,
  });

  bool get isMinimizeControlled => minimized != null || controller != null;

  // --- Stable keys ---

  static const Key panelRegionKey = Key('ds-floating-analytics-hud');
  static const Key dragHandleKey = Key('ds-floating-analytics-drag');
  static const Key titleDragKey = Key('ds-floating-analytics-title-drag');
  static const Key minimizeToggleKey = Key('ds-floating-analytics-minimize');
  static const Key closeButtonKey = Key('ds-floating-analytics-close');
  static const Key bodyKey = Key('ds-floating-analytics-body');
  static const Key sectionsListKey = Key('ds-floating-analytics-sections');

  static Key sectionKey(String id) => Key('ds-floating-analytics-section-$id');

  static Key metricKey(String sectionId, String metricId) =>
      Key('ds-floating-analytics-metric-$sectionId-$metricId');

  static String minimizeSemanticLabel({required bool minimized}) =>
      minimized ? 'Expand analytics HUD' : 'Minimize analytics HUD';

  static String closeSemanticLabel() => 'Close analytics HUD';

  static String dragSemanticLabel() => 'Drag analytics HUD';

  @override
  State<DSFloatingAnalyticsHud> createState() => _DSFloatingAnalyticsHudState();
}

class _DSFloatingAnalyticsHudState extends State<DSFloatingAnalyticsHud> {
  late Offset _uncontrolledOffset;
  late bool _uncontrolledMinimized;
  late bool _uncontrolledVisible;

  /// Last known host size from layout (updated post-frame only — never during
  /// build — so pan/clamp never depends on a mid-build side effect).
  Size _hostSize = Size.zero;

  DSFloatingAnalyticsHudController? get _controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _uncontrolledOffset = _controller?.offset ?? widget.initialOffset;
    _uncontrolledMinimized =
        _controller?.isMinimized ?? widget.initiallyMinimized;
    _uncontrolledVisible = _controller?.isVisible ?? widget.visible;
    _controller?.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(covariant DSFloatingAnalyticsHud oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onControllerChanged);
      widget.controller?.addListener(_onControllerChanged);
      if (widget.controller != null) {
        _uncontrolledOffset = widget.controller!.offset;
        _uncontrolledMinimized = widget.controller!.isMinimized;
        _uncontrolledVisible = widget.controller!.isVisible;
      }
    }
    if (oldWidget.visible != widget.visible && widget.controller == null) {
      _uncontrolledVisible = widget.visible;
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    if (!mounted) return;
    setState(() {
      _uncontrolledOffset = _controller!.offset;
      _uncontrolledMinimized = _controller!.isMinimized;
      _uncontrolledVisible = _controller!.isVisible;
    });
  }

  bool get _minimized {
    if (widget.minimized != null) return widget.minimized!;
    if (_controller != null) return _controller!.isMinimized;
    return _uncontrolledMinimized;
  }

  Offset get _offset {
    if (_controller != null) return _controller!.offset;
    return _uncontrolledOffset;
  }

  bool get _visible {
    if (_controller != null) return _controller!.isVisible;
    return widget.visible && _uncontrolledVisible;
  }

  /// Capture host size after layout without mutating state during [build].
  void _scheduleHostSizeCapture(Size next) {
    if (next == _hostSize) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_hostSize == next) return;
      _hostSize = next;
    });
  }

  Offset _clampOffset(Offset raw, {required Size host, required Size panel}) {
    if (host.width <= 0 || host.height <= 0) return raw;
    final maxX = math.max(0.0, host.width - panel.width);
    final maxY = math.max(0.0, host.height - panel.height);
    return Offset(raw.dx.clamp(0.0, maxX), raw.dy.clamp(0.0, maxY));
  }

  Size get _panelSizeEstimate {
    final double panelH = _minimized
        ? DSFloatingAnalyticsHud.minInteractiveSize
        : math.min(widget.maxBodyHeight + 56.0, 420.0);
    return Size(widget.panelWidth, panelH);
  }

  void _commitOffset(Offset next, {Size? hostOverride}) {
    final host = hostOverride ?? _hostSize;
    final clamped = _clampOffset(next, host: host, panel: _panelSizeEstimate);
    if (_controller != null) {
      if (_controller!.offset != clamped) {
        _controller!.moveTo(clamped);
      }
    } else if (_uncontrolledOffset != clamped) {
      setState(() => _uncontrolledOffset = clamped);
    }
    widget.onOffsetChanged?.call(clamped);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    // Prefer live layout size when available so first drag after mount clamps.
    final box = context.findRenderObject() as RenderBox?;
    final liveHost = box != null && box.hasSize ? box.size : _hostSize;
    _commitOffset(_offset + details.delta, hostOverride: liveHost);
  }

  void _toggleMinimized() {
    HapticFeedback.selectionClick();
    final next = !_minimized;
    if (widget.minimized == null) {
      if (_controller != null) {
        if (next) {
          _controller!.minimize();
        } else {
          _controller!.expand();
        }
      } else {
        setState(() => _uncontrolledMinimized = next);
      }
    }
    widget.onMinimizedChanged?.call(next);
  }

  void _handleClose() {
    HapticFeedback.lightImpact();
    if (_controller != null) {
      _controller!.close();
    } else {
      setState(() => _uncontrolledVisible = false);
    }
    widget.onClose?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: widget.semanticLabel,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final host = Size(constraints.maxWidth, constraints.maxHeight);
          _scheduleHostSizeCapture(host);
          final clamped = _clampOffset(
            _offset,
            host: host,
            panel: _panelSizeEstimate,
          );

          return Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned(
                left: clamped.dx,
                top: clamped.dy,
                width: widget.panelWidth,
                child: _buildPanel(minimized: _minimized),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPanel({required bool minimized}) {
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingAnalyticsHudHeader(
          title: widget.title,
          sectionCount: widget.sections.length,
          minimized: minimized,
          showClose: widget.showClose,
          onPanUpdate: _onPanUpdate,
          onToggleMinimized: _toggleMinimized,
          onClose: _handleClose,
        ),
        if (!minimized) ...[
          const SizedBox(height: DSSpacing.xs),
          KeyedSubtree(
            key: DSFloatingAnalyticsHud.bodyKey,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: widget.maxBodyHeight),
              child: FloatingAnalyticsHudSections(
                sections: widget.sections,
                compactMetrics: widget.compactMetrics,
              ),
            ),
          ),
        ],
      ],
    );

    final content = widget.wrapInGlass
        ? DSGlassPanel(padding: const EdgeInsets.all(DSSpacing.sm), child: body)
        : Material(
            color: DSColors.obsidianElevated,
            borderRadius: BorderRadius.circular(DSRadii.card),
            child: Padding(
              padding: const EdgeInsets.all(DSSpacing.sm),
              child: body,
            ),
          );

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: widget.semanticLabel,
      child: KeyedSubtree(
        key: DSFloatingAnalyticsHud.panelRegionKey,
        child: content,
      ),
    );
  }
}
