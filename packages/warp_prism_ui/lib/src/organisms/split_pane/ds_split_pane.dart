import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../tokens/tokens.dart';

/// ASW Observatory Organism — Split Pane
///
/// A resizable split pane with a draggable divider between two child panes.
///
/// Features:
/// - Draggable divider with visible drag handle
/// - Configurable axis (horizontal or vertical)
/// - Min/max constraints for each pane (in logical pixels or fraction)
/// - Collapse/expand gesture (double-click divider)
/// - Glass-panel styled divider matching the obsidian aesthetic
/// - Keyboard accessible: arrow keys to resize when divider is focused
///
/// Contract:
/// - The first child is the "leading" pane; the second is the "trailing" pane.
/// - [initialRatio] controls the initial split (0.0–1.0, fraction of total).
/// - [dividerThickness] defaults to 6px (thin line + drag handle).
///
/// Usage:
/// ```dart
/// DSSplitPane(
///   axis: Axis.horizontal,
///   initialRatio: 0.6,
///   leading: AgentTable(),
///   trailing: AgentDetail(),
/// )
/// ```
class DSSplitPane extends StatefulWidget {
  /// The axis along which the panes are laid out.
  /// [Axis.horizontal] places panes side-by-side (left/right).
  /// [Axis.vertical] places panes top-to-bottom.
  final Axis axis;

  /// Initial split ratio (0.0–1.0) for the leading pane.
  /// Defaults to 0.5 (equal split).
  final double initialRatio;

  /// The first (leading/start) pane.
  final Widget leading;

  /// The second (trailing/end) pane.
  final Widget trailing;

  /// Minimum extent (width for horizontal, height for vertical) of the
  /// leading pane in logical pixels. Defaults to 100.
  final double leadingMinExtent;

  /// Maximum extent of the leading pane in logical pixels.
  /// `null` means no maximum (constrained only by total size minus trailing min).
  final double? leadingMaxExtent;

  /// Minimum extent of the trailing pane in logical pixels. Defaults to 100.
  final double trailingMinExtent;

  /// Maximum extent of the trailing pane in logical pixels.
  /// `null` means no maximum.
  final double? trailingMaxExtent;

  /// Divider thickness in logical pixels. Defaults to 6.
  final double dividerThickness;

  /// Whether the divider is draggable. Defaults to true.
  final bool resizable;

  /// Background color for the divider. Defaults to borderSubtle.
  final Color? dividerColor;

  /// Color for the drag handle grip. Defaults to textTertiary.
  final Color? handleColor;

  const DSSplitPane({
    super.key,
    this.axis = Axis.horizontal,
    this.initialRatio = 0.5,
    required this.leading,
    required this.trailing,
    this.leadingMinExtent = 100,
    this.leadingMaxExtent,
    this.trailingMinExtent = 100,
    this.trailingMaxExtent,
    this.dividerThickness = 6,
    this.resizable = true,
    this.dividerColor,
    this.handleColor,
  });

  @override
  State<DSSplitPane> createState() => _DSSplitPaneState();
}

class _DSSplitPaneState extends State<DSSplitPane> {
  late double _ratio;
  bool _isDragging = false;
  bool _isHovering = false;
  bool _isFocused = false;
  bool _isCollapsed = false;
  double _preCollapseRatio = 0.5;
  final FocusNode _dividerFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _ratio = widget.initialRatio.clamp(0.0, 1.0);
    _dividerFocusNode.addListener(() {
      setState(() {
        _isFocused = _dividerFocusNode.hasFocus;
      });
    });
  }

  @override
  void didUpdateWidget(DSSplitPane oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialRatio != widget.initialRatio && !_isDragging) {
      _ratio = widget.initialRatio.clamp(0.0, 1.0);
    }
  }

  @override
  void dispose() {
    _dividerFocusNode.dispose();
    super.dispose();
  }

  /// Clamps the ratio so both panes respect their min/max constraints.
  double _clampRatio(double ratio, double totalExtent) {
    final divider = widget.dividerThickness;
    final available = totalExtent - divider;

    // Leading constraints
    final leadingMin = widget.leadingMinExtent / available;
    final leadingMax = widget.leadingMaxExtent != null
        ? widget.leadingMaxExtent! / available
        : 1.0 - (widget.trailingMinExtent / available);

    // Trailing constraints (inverted for leading ratio)
    final trailingMin = widget.trailingMinExtent / available;
    final trailingMax = widget.trailingMaxExtent != null
        ? 1.0 - (widget.trailingMaxExtent! / available)
        : leadingMin;

    final lowerBound = leadingMin > trailingMax ? leadingMin : leadingMin;
    final upperBound = leadingMax < (1.0 - trailingMin)
        ? leadingMax
        : 1.0 - trailingMin;

    return ratio.clamp(lowerBound, upperBound);
  }

  void _handleDragUpdate(DragUpdateDetails details, double totalExtent) {
    if (!widget.resizable) return;
    final delta = widget.axis == Axis.horizontal
        ? details.delta.dx
        : details.delta.dy;
    final divider = widget.dividerThickness;
    final available = totalExtent - divider;
    final newRatio = _ratio + (delta / available);
    setState(() {
      _ratio = _clampRatio(newRatio, totalExtent);
      _isCollapsed = false;
    });
  }

  void _handleDoubleTap(double totalExtent) {
    if (!widget.resizable) return;
    setState(() {
      if (_isCollapsed) {
        // Expand back to previous ratio
        _ratio = _clampRatio(_preCollapseRatio, totalExtent);
        _isCollapsed = false;
      } else {
        // Collapse trailing pane (set ratio to max, effectively hiding trailing)
        _preCollapseRatio = _ratio;
        final divider = widget.dividerThickness;
        final available = totalExtent - divider;
        final maxRatio = 1.0 - (widget.trailingMinExtent / available);
        _ratio = maxRatio;
        _isCollapsed = true;
      }
    });
  }

  void _handleKeyEvent(KeyEvent event, double totalExtent) {
    if (event is! KeyDownEvent) return;
    final step = 0.02; // 2% per keypress
    if (widget.axis == Axis.horizontal) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        setState(() {
          _ratio = _clampRatio(_ratio - step, totalExtent);
        });
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        setState(() {
          _ratio = _clampRatio(_ratio + step, totalExtent);
        });
      }
    } else {
      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        setState(() {
          _ratio = _clampRatio(_ratio - step, totalExtent);
        });
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        setState(() {
          _ratio = _clampRatio(_ratio + step, totalExtent);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isHorizontal = widget.axis == Axis.horizontal;
        final totalExtent = isHorizontal
            ? constraints.maxWidth
            : constraints.maxHeight;
        final divider = widget.dividerThickness;
        final available = totalExtent - divider;
        final leadingExtent = available * _ratio;
        final trailingExtent = available * (1.0 - _ratio);

        final effectiveDividerColor =
            widget.dividerColor ?? DSColors.borderSubtle;
        final effectiveHandleColor =
            widget.handleColor ?? DSColors.textTertiary;

        // Build the divider widget
        final dividerWidget = GestureDetector(
          onDoubleTap: () => _handleDoubleTap(totalExtent),
          onHorizontalDragStart: isHorizontal && widget.resizable
              ? (_) => setState(() => _isDragging = true)
              : null,
          onHorizontalDragUpdate: isHorizontal && widget.resizable
              ? (d) => _handleDragUpdate(d, totalExtent)
              : null,
          onHorizontalDragEnd: isHorizontal
              ? (_) => setState(() => _isDragging = false)
              : null,
          onVerticalDragStart: !isHorizontal && widget.resizable
              ? (_) => setState(() => _isDragging = true)
              : null,
          onVerticalDragUpdate: !isHorizontal && widget.resizable
              ? (d) => _handleDragUpdate(d, totalExtent)
              : null,
          onVerticalDragEnd: !isHorizontal
              ? (_) => setState(() => _isDragging = false)
              : null,
          child: MouseRegion(
            onEnter: (_) => setState(() => _isHovering = true),
            onExit: (_) => setState(() => _isHovering = false),
            cursor: widget.resizable
                ? (isHorizontal
                    ? SystemMouseCursors.resizeColumn
                    : SystemMouseCursors.resizeRow)
                : SystemMouseCursors.basic,
            child: Focus(
              focusNode: _dividerFocusNode,
              onKeyEvent: (node, event) {
                _handleKeyEvent(event, totalExtent);
                return KeyEventResult.handled;
              },
              child: Semantics(
                label: 'Split pane divider. '
                    '${widget.resizable ? 'Drag to resize. Double-click to collapse.' : ''}',
                button: widget.resizable,
                child: AnimatedContainer(
                  duration: _isDragging ? DSMotion.instant : DSMotion.fast,
                  width: isHorizontal ? divider : double.infinity,
                  height: isHorizontal ? double.infinity : divider,
                  decoration: BoxDecoration(
                    color: _isHovering || _isDragging
                        ? DSColors.accentCyan.withOpacity(0.3)
                        : (_isFocused
                            ? DSColors.accentCyan.withOpacity(0.2)
                            : effectiveDividerColor),
                  ),
                  child: Center(
                    child: _buildDragHandle(
                      isHorizontal: isHorizontal,
                      color: (_isHovering || _isDragging)
                          ? DSColors.accentCyan
                          : (_isFocused
                              ? DSColors.accentCyan.withOpacity(0.7)
                              : effectiveHandleColor),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        // Assemble the split pane
        if (isHorizontal) {
          return Row(
            children: [
              SizedBox(width: leadingExtent, child: widget.leading),
              dividerWidget,
              Expanded(child: widget.trailing),
            ],
          );
        } else {
          return Column(
            children: [
              SizedBox(height: leadingExtent, child: widget.leading),
              dividerWidget,
              Expanded(child: widget.trailing),
            ],
          );
        }
      },
    );
  }

  /// Renders the drag handle (three dots / grip pattern).
  Widget _buildDragHandle({
    required bool isHorizontal,
    required Color color,
  }) {
    if (isHorizontal) {
      // Vertical grip: three vertical dots
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _handleDot(color),
          const SizedBox(height: 3),
          _handleDot(color),
          const SizedBox(height: 3),
          _handleDot(color),
        ],
      );
    } else {
      // Horizontal grip: three horizontal dots
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _handleDot(color),
          const SizedBox(width: 3),
          _handleDot(color),
          const SizedBox(width: 3),
          _handleDot(color),
        ],
      );
    }
  }

  Widget _handleDot(Color color) {
    return Container(
      width: 3,
      height: 3,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
