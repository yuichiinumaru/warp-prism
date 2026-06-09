import 'package:flutter/material.dart';
import '../tokens/tokens.dart';
import 'ds_task_card.dart';

/// Drag payload carried between [DSDraggableCard] source and
/// [DSDropTarget] destination.
class DSDragPayload {
  final int taskId;
  final String sourceLaneId;
  final int sourceIndex;

  const DSDragPayload({
    required this.taskId,
    required this.sourceLaneId,
    required this.sourceIndex,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DSDragPayload &&
          taskId == other.taskId &&
          sourceLaneId == other.sourceLaneId &&
          sourceIndex == other.sourceIndex;

  @override
  int get hashCode => Object.hash(taskId, sourceLaneId, sourceIndex);
}

/// Event fired when a task is reordered within the same lane.
class DSDragReorderEvent {
  final String laneId;
  final int oldIndex;
  final int newIndex;

  const DSDragReorderEvent({
    required this.laneId,
    required this.oldIndex,
    required this.newIndex,
  });
}

/// Event fired when a task is moved from one lane to another.
class DSDragMoveEvent {
  final String sourceLaneId;
  final String targetLaneId;
  final int taskId;
  final int targetIndex;

  const DSDragMoveEvent({
    required this.sourceLaneId,
    required this.targetLaneId,
    required this.taskId,
    required this.targetIndex,
  });
}

/// Molecule that wraps a [DSTaskCard] in a [LongPressDraggable].
///
/// - Long-press initiates drag (avoids conflict with tap).
/// - During drag, the original card renders as a ghost at 0.2 opacity.
/// - The feedback card (under the pointer) renders at 0.8 opacity
///   with a cyan glow border matching the glass-panel aesthetic.
/// - Tap and keyboard behavior remain intact on the non-dragged card.
class DSDraggableCard extends StatelessWidget {
  /// The task card to wrap.
  final DSTaskCard card;

  /// Lane id this card belongs to (carried in the drag payload).
  final String laneId;

  /// Index of this card in its lane's task list.
  final int index;

  const DSDraggableCard({
    super.key,
    required this.card,
    required this.laneId,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<DSDragPayload>(
      data: DSDragPayload(
        taskId: card.id,
        sourceLaneId: laneId,
        sourceIndex: index,
      ),
      delay: DSMotion.normal,
      // Feedback: card under the pointer during drag.
      // Wrapped in SizedBox to give the overlay entry bounded constraints.
      feedback: SizedBox(
        width: 280,
        child: Material(
          color: DSColors.transparent,
          elevation: 6,
          child: Opacity(
            opacity: 0.8,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(DSRadii.card),
                boxShadow: [
                  BoxShadow(
                    color: DSColors.accentCyan.withOpacity(0.4),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: card,
            ),
          ),
        ),
      ),
      // ChildWhenDragging: ghost card at the original position
      childWhenDragging: Opacity(
        opacity: 0.2,
        child: card,
      ),
      child: card,
    );
  }
}
