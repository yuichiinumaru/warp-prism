import 'package:flutter/material.dart';
import '../tokens/tokens.dart';
import 'ds_draggable_card.dart';

/// Molecule that wraps lane content in a [DragTarget] accepting
/// [DSDragPayload] drops.
///
/// - Highlights the lane border when a valid drag hovers.
/// - Shows an insertion indicator line at the calculated drop index.
/// - Recalculates insertion index on every [DragTarget.onMove] pointer update.
/// - Fires [onAcceptWithIndex] when a card is dropped, providing the
///   payload and the computed target index.
class DSDropTarget extends StatefulWidget {
  /// Lane id this drop target represents.
  final String laneId;

  /// Number of tasks currently in this lane (for index calculation).
  final int taskCount;

  /// Estimated height of each task card including padding.
  /// Used to compute the insertion index from the drag avatar position.
  final double itemHeight;

  /// The child widget (typically the lane's task list).
  final Widget child;

  /// Whether this lane is currently empty (shows empty state).
  final bool isEmpty;

  /// Callback when a draggable is dropped on this target.
  /// Provides the drag payload and the computed target index.
  final void Function(DSDragPayload payload, int targetIndex)?
  onAcceptWithIndex;

  /// Optional observer for insertion-index changes during hover.
  /// Intended for tests and host instrumentation — not required for drop.
  final ValueChanged<int>? onInsertionIndexChanged;

  const DSDropTarget({
    super.key,
    required this.laneId,
    required this.taskCount,
    required this.child,
    this.itemHeight = 100.0,
    this.isEmpty = false,
    this.onAcceptWithIndex,
    this.onInsertionIndexChanged,
  });

  @override
  State<DSDropTarget> createState() => _DSDropTargetState();
}

class _DSDropTargetState extends State<DSDropTarget> {
  bool _isHovering = false;
  int _insertionIndex = -1;

  void _setHoverIndex(int next) {
    final changed = next != _insertionIndex || !_isHovering;
    if (!changed) return;
    setState(() {
      _isHovering = true;
      _insertionIndex = next;
    });
    widget.onInsertionIndexChanged?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget<DSDragPayload>(
      onWillAcceptWithDetails: (details) {
        _setHoverIndex(_calculateIndex(details.offset));
        return true;
      },
      // Recalculate insertion index continuously as the pointer moves.
      onMove: (details) {
        _setHoverIndex(_calculateIndex(details.offset));
      },
      onLeave: (_) {
        setState(() {
          _isHovering = false;
          _insertionIndex = -1;
        });
      },
      onAcceptWithDetails: (details) {
        // Prefer live avatar position at drop time over a stale hover index.
        final targetIndex = _calculateIndex(
          details.offset,
        ).clamp(0, widget.taskCount);
        setState(() {
          _isHovering = false;
          _insertionIndex = -1;
        });
        widget.onAcceptWithIndex?.call(details.data, targetIndex);
      },
      builder: (context, candidateData, rejectedData) {
        final highlightColor = _isHovering
            ? DSColors.focusRing
            : DSColors.borderSubtle.withValues(alpha: 0.5);
        final borderWidth = _isHovering ? 2.0 : 1.0;

        return AnimatedContainer(
          key: ValueKey(
            'ds-drop-surface-${widget.laneId}-'
            '${_isHovering ? 'hover' : 'idle'}',
          ),
          duration: DSMotion.fast,
          curve: DSMotion.hoverCurve,
          decoration: BoxDecoration(
            color: DSColors.obsidianElevated.withValues(
              alpha: _isHovering ? 0.5 : 0.3,
            ),
            borderRadius: BorderRadius.circular(DSRadii.lg),
            border: Border.all(color: highlightColor, width: borderWidth),
          ),
          child: Stack(
            children: [
              widget.child,
              // Insertion indicator line — key encodes live index so
              // DragTarget.onMove tracking is observable in widget tests.
              if (_isHovering && _insertionIndex >= 0)
                Positioned(
                  key: ValueKey(
                    'ds-drop-insertion-${widget.laneId}-$_insertionIndex',
                  ),
                  top: _indicatorTop,
                  left: DSSpacing.sm,
                  right: DSSpacing.sm,
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      color: DSColors.accentBlue,
                      borderRadius: BorderRadius.circular(1),
                      boxShadow: [
                        BoxShadow(color: DSColors.focusRing, blurRadius: 4),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  /// Calculate the insertion index from [DragTargetDetails.offset].
  ///
  /// Flutter sets that offset to the **feedback top-left**
  /// (`pointer - dragStartPoint`), not the raw pointer. Probing at the
  /// vertical mid-point of the estimated card (`itemHeight / 2`) maps the
  /// floating card's center onto the list slot under it.
  int _calculateIndex(Offset globalOffset) {
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box == null) return widget.taskCount;
    final localOffset = box.globalToLocal(globalOffset);
    // Probe at the estimated vertical center of the drag feedback card.
    final probeY = localOffset.dy + (widget.itemHeight * 0.5);
    // Account for typical ListView padding (DSSpacing.sm = 8).
    final adjustedY = probeY - DSSpacing.sm;
    if (adjustedY <= 0) return 0;
    final index = (adjustedY / widget.itemHeight).floor();
    return index.clamp(0, widget.taskCount);
  }

  /// Y position for the insertion indicator line.
  double get _indicatorTop {
    // Position indicator at the top of the target slot
    return DSSpacing.sm + (_insertionIndex * widget.itemHeight);
  }
}
