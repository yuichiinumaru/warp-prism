import 'package:flutter/material.dart';
import '../tokens/tokens.dart';
import 'ds_draggable_card.dart';

/// Molecule that wraps lane content in a [DragTarget] accepting
/// [DSDragPayload] drops.
///
/// - Highlights the lane border when a valid drag hovers.
/// - Shows an insertion indicator line at the calculated drop index.
/// - Fires [onAcceptWithIndex] when a card is dropped, providing the
///   payload and the computed target index.
class DSDropTarget extends StatefulWidget {
  /// Lane id this drop target represents.
  final String laneId;

  /// Number of tasks currently in this lane (for index calculation).
  final int taskCount;

  /// Estimated height of each task card including padding.
  /// Used to compute the insertion index from the pointer Y offset.
  final double itemHeight;

  /// The child widget (typically the lane's task list).
  final Widget child;

  /// Whether this lane is currently empty (shows empty state).
  final bool isEmpty;

  /// Callback when a draggable is dropped on this target.
  /// Provides the drag payload and the computed target index.
  final void Function(DSDragPayload payload, int targetIndex)? onAcceptWithIndex;

  const DSDropTarget({
    super.key,
    required this.laneId,
    required this.taskCount,
    required this.child,
    this.itemHeight = 100.0,
    this.isEmpty = false,
    this.onAcceptWithIndex,
  });

  @override
  State<DSDropTarget> createState() => _DSDropTargetState();
}

class _DSDropTargetState extends State<DSDropTarget> {
  bool _isHovering = false;
  int _insertionIndex = -1;

  @override
  Widget build(BuildContext context) {
    return DragTarget<DSDragPayload>(
      onWillAcceptWithDetails: (details) {
        setState(() {
          _isHovering = true;
          _insertionIndex = _calculateIndex(details.offset);
        });
        return true;
      },
      onLeave: (_) {
        setState(() {
          _isHovering = false;
          _insertionIndex = -1;
        });
      },
      onAcceptWithDetails: (details) {
        final targetIndex = _insertionIndex.clamp(0, widget.taskCount);
        setState(() {
          _isHovering = false;
          _insertionIndex = -1;
        });
        widget.onAcceptWithIndex?.call(details.data, targetIndex);
      },
      builder: (context, candidateData, rejectedData) {
        final highlightColor = _isHovering
            ? DSColors.accentCyan.withOpacity(0.3)
            : DSColors.borderSubtle.withOpacity(0.5);
        final borderWidth = _isHovering ? 2.0 : 1.0;

        return AnimatedContainer(
          duration: DSMotion.fast,
          curve: DSMotion.hoverCurve,
          decoration: BoxDecoration(
            color: DSColors.obsidianElevated.withOpacity(
              _isHovering ? 0.5 : 0.3,
            ),
            borderRadius: BorderRadius.circular(DSRadii.lg),
            border: Border.all(
              color: highlightColor,
              width: borderWidth,
            ),
          ),
          child: Stack(
            children: [
              widget.child,
              // Insertion indicator line
              if (_isHovering && _insertionIndex >= 0)
                Positioned(
                  top: _indicatorTop,
                  left: DSSpacing.sm,
                  right: DSSpacing.sm,
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      color: DSColors.accentCyan,
                      borderRadius: BorderRadius.circular(1),
                      boxShadow: [
                        BoxShadow(
                          color: DSColors.accentCyan.withOpacity(0.5),
                          blurRadius: 4,
                        ),
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

  /// Calculate the insertion index based on the pointer's Y offset
  /// relative to the drop target.
  int _calculateIndex(Offset globalOffset) {
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box == null) return widget.taskCount;
    final localOffset = box.globalToLocal(globalOffset);
    // Account for the ListView padding (DSSpacing.sm = 8)
    final adjustedY = localOffset.dy - DSSpacing.sm;
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
