import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

/// Intent: reorder within the current lane by [delta] steps (-1 / +1).
class DSDragReorderIntent extends Intent {
  final int delta;
  const DSDragReorderIntent(this.delta);
}

/// Intent: move the focused card to an adjacent lane by [delta] (-1 / +1).
class DSDragMoveLaneIntent extends Intent {
  final int delta;
  const DSDragMoveLaneIntent(this.delta);
}

/// Molecule that wraps a [DSTaskCard] in a [LongPressDraggable].
///
/// - Long-press initiates drag (avoids conflict with tap).
/// - During drag, the original card renders as a ghost at 0.2 opacity.
/// - The feedback card (under the pointer) renders at 0.8 opacity
///   with a blue/focus glow border matching the glass-panel aesthetic.
/// - Tap and keyboard activation remain intact on the non-dragged card.
/// - When keyboard callbacks are provided, Alt+Arrow keys reorder/move
///   via the focus ancestor chain (works when the task card is focused).
class DSDraggableCard extends StatelessWidget {
  /// The task card to wrap.
  final DSTaskCard card;

  /// Lane id this card belongs to (carried in the drag payload).
  final String laneId;

  /// Index of this card in its lane's task list.
  final int index;

  /// Keyboard same-lane reorder delta (-1 earlier, +1 later).
  /// When null, Alt+Up/Down are not handled.
  final ValueChanged<int>? onKeyboardReorderDelta;

  /// Keyboard cross-lane move delta (-1 previous lane, +1 next lane).
  /// When null, Alt+Left/Right are not handled.
  final ValueChanged<int>? onKeyboardMoveLaneDelta;

  const DSDraggableCard({
    super.key,
    required this.card,
    required this.laneId,
    required this.index,
    this.onKeyboardReorderDelta,
    this.onKeyboardMoveLaneDelta,
  });

  bool get _hasKeyboardActions =>
      onKeyboardReorderDelta != null || onKeyboardMoveLaneDelta != null;

  static bool _isAltPressed() {
    final pressed = HardwareKeyboard.instance.logicalKeysPressed;
    return pressed.contains(LogicalKeyboardKey.altLeft) ||
        pressed.contains(LogicalKeyboardKey.altRight) ||
        pressed.contains(LogicalKeyboardKey.alt);
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (!_isAltPressed()) return KeyEventResult.ignored;

    final key = event.logicalKey;
    if (onKeyboardReorderDelta != null) {
      if (key == LogicalKeyboardKey.arrowUp) {
        onKeyboardReorderDelta!(-1);
        return KeyEventResult.handled;
      }
      if (key == LogicalKeyboardKey.arrowDown) {
        onKeyboardReorderDelta!(1);
        return KeyEventResult.handled;
      }
    }
    if (onKeyboardMoveLaneDelta != null) {
      if (key == LogicalKeyboardKey.arrowLeft) {
        onKeyboardMoveLaneDelta!(-1);
        return KeyEventResult.handled;
      }
      if (key == LogicalKeyboardKey.arrowRight) {
        onKeyboardMoveLaneDelta!(1);
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final hint = _hasKeyboardActions
        ? 'Long press to drag. Alt+Up/Down reorders in lane. '
              'Alt+Left/Right moves across lanes. Tap to open task details.'
        : 'Long press to drag. Tap to open task details.';

    Widget child = LongPressDraggable<DSDragPayload>(
      data: DSDragPayload(
        taskId: card.id,
        sourceLaneId: laneId,
        sourceIndex: index,
      ),
      delay: DSMotion.normal,
      // Feedback: card under the pointer during drag.
      // Wrapped in SizedBox to give the overlay entry bounded constraints.
      // Keyed so tests can assert ghost/feedback presence during drag.
      feedback: SizedBox(
        key: ValueKey('ds-drag-feedback-${card.id}'),
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
                    color: DSColors.focusRing,
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
        key: ValueKey('ds-drag-ghost-${card.id}'),
        opacity: 0.2,
        child: card,
      ),
      child: card,
    );

    // Focus ancestor receives unhandled keys from the focused task card
    // (DSInteractiveSurface FocusableActionDetector) so Alt+Arrow works
    // without stealing focus traversal from the card itself.
    if (_hasKeyboardActions) {
      child = Focus(
        canRequestFocus: false,
        skipTraversal: true,
        onKeyEvent: _handleKeyEvent,
        child: child,
      );
    }

    return Semantics(
      // container isolates this label/hint from nested task-card semantics
      // so a11y scanners see an explicit drag affordance.
      container: true,
      label: 'Draggable task ${card.id}: ${card.title}',
      hint: hint,
      child: child,
    );
  }
}
