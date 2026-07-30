import 'package:flutter/material.dart';
import '../tokens/tokens.dart';
import '../atoms/atoms.dart';
import '../molecules/molecules.dart';

/// ASW Observatory Organism - Lane Board
///
/// Kanban-style board for task lanes.
/// Each lane column and the board itself are Semantically labeled.
///
/// Supports drag-and-drop via [DSDraggableCard] and [DSDropTarget]:
/// - [onReorder] fires when a task is reordered within the same lane.
/// - [onMove] fires when a task is moved between different lanes.
/// - Keyboard: Alt+Up/Down reorders; Alt+Left/Right moves across lanes
///   when the corresponding callbacks are provided.
class DSLaneBoard extends StatelessWidget {
  final List<DSLane> lanes;
  final String? selectedTaskId;
  final ValueChanged<String>? onTaskTap;

  /// Called when a task is reordered within the same lane.
  final ValueChanged<DSDragReorderEvent>? onReorder;

  /// Called when a task is moved from one lane to another.
  final ValueChanged<DSDragMoveEvent>? onMove;

  const DSLaneBoard({
    super.key,
    required this.lanes,
    this.selectedTaskId,
    this.onTaskTap,
    this.onReorder,
    this.onMove,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Task board with ${lanes.length} lanes',
      explicitChildNodes: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate lane width based on available space
          const minLaneWidth = 280.0;
          const maxLaneWidth = 320.0;
          final totalLanes = lanes.length;
          final availableWidth = constraints.maxWidth - (DSSpacing.lg * 2);
          final gapWidth = DSSpacing.md * (totalLanes - 1);
          final laneWidth = ((availableWidth - gapWidth) / totalLanes).clamp(
            minLaneWidth,
            maxLaneWidth,
          );

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(DSSpacing.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < lanes.length; i++) ...[
                  if (i > 0) const SizedBox(width: DSSpacing.md),
                  SizedBox(
                    width: laneWidth,
                    child: _LaneColumn(
                      lane: lanes[i],
                      laneIndex: i,
                      previousLaneId: i > 0 ? lanes[i - 1].id : null,
                      nextLaneId:
                          i < lanes.length - 1 ? lanes[i + 1].id : null,
                      selectedTaskId: selectedTaskId,
                      onTaskTap: onTaskTap,
                      onReorder: onReorder,
                      onMove: onMove,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LaneColumn extends StatelessWidget {
  final DSLane lane;
  final int laneIndex;
  final String? previousLaneId;
  final String? nextLaneId;
  final String? selectedTaskId;
  final ValueChanged<String>? onTaskTap;
  final ValueChanged<DSDragReorderEvent>? onReorder;
  final ValueChanged<DSDragMoveEvent>? onMove;

  const _LaneColumn({
    required this.lane,
    required this.laneIndex,
    this.previousLaneId,
    this.nextLaneId,
    this.selectedTaskId,
    this.onTaskTap,
    this.onReorder,
    this.onMove,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${lane.label} lane, ${lane.tasks.length} tasks',
      explicitChildNodes: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Lane header
          _LaneHeader(lane: lane),

          const SizedBox(height: DSSpacing.sm),

          // Tasks with drop target
          Expanded(
            child: DSDropTarget(
              laneId: lane.id,
              taskCount: lane.tasks.length,
              onAcceptWithIndex: (payload, targetIndex) {
                if (payload.sourceLaneId == lane.id) {
                  // Same lane reorder
                  if (payload.sourceIndex != targetIndex) {
                    onReorder?.call(
                      DSDragReorderEvent(
                        laneId: lane.id,
                        oldIndex: payload.sourceIndex,
                        newIndex: targetIndex,
                      ),
                    );
                  }
                } else {
                  // Cross-lane move
                  onMove?.call(
                    DSDragMoveEvent(
                      sourceLaneId: payload.sourceLaneId,
                      targetLaneId: lane.id,
                      taskId: payload.taskId,
                      targetIndex: targetIndex,
                    ),
                  );
                }
              },
              child: lane.tasks.isEmpty
                  ? const DSStateSurface.empty(
                      icon: Icons.inbox_outlined,
                      title: 'No tasks',
                      subtitle:
                          'Tasks will appear here when assigned to this lane',
                      compact: true,
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(DSSpacing.sm),
                      itemCount: lane.tasks.length,
                      itemBuilder: (context, index) {
                        final task = lane.tasks[index];
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: index < lane.tasks.length - 1
                                ? DSSpacing.sm
                                : 0,
                          ),
                          child: DSDraggableCard(
                            laneId: lane.id,
                            index: index,
                            onKeyboardReorderDelta: onReorder == null
                                ? null
                                : (delta) {
                                    final newIndex = (index + delta).clamp(
                                      0,
                                      lane.tasks.length - 1,
                                    );
                                    if (newIndex == index) return;
                                    onReorder!(
                                      DSDragReorderEvent(
                                        laneId: lane.id,
                                        oldIndex: index,
                                        newIndex: newIndex,
                                      ),
                                    );
                                  },
                            onKeyboardMoveLaneDelta: onMove == null
                                ? null
                                : (delta) {
                                    final targetLaneId = delta < 0
                                        ? previousLaneId
                                        : nextLaneId;
                                    if (targetLaneId == null) return;
                                    onMove!(
                                      DSDragMoveEvent(
                                        sourceLaneId: lane.id,
                                        targetLaneId: targetLaneId,
                                        taskId: task.id,
                                        targetIndex: 0,
                                      ),
                                    );
                                  },
                            card: DSTaskCard(
                              id: task.id,
                              title: task.title,
                              lane: lane.id,
                              priority: task.priority,
                              owner: task.owner,
                              proofState: task.proofState,
                              reviewScore: task.reviewScore,
                              linkedSkills: task.linkedSkills,
                              dependencyCount: task.dependencyCount,
                              selected: task.id.toString() == selectedTaskId,
                              onTap: () => onTaskTap?.call(task.id.toString()),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LaneHeader extends StatelessWidget {
  final DSLane lane;

  const _LaneHeader({required this.lane});

  @override
  Widget build(BuildContext context) {
    final color = DSColors.forLane(lane.id);

    return Semantics(
      header: true,
      label: '${lane.label}: ${lane.tasks.length} tasks',
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.md,
          vertical: DSSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(DSRadii.md),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          children: [
            DSIcon.small(DSIcons.forLane(lane.id), color: color),
            const SizedBox(width: DSSpacing.sm),
            Expanded(child: DSText.labelLarge(lane.label, color: color)),
            DSBadge.count(lane.tasks.length, color: color),
          ],
        ),
      ),
    );
  }
}

class DSLane {
  final String id;
  final String label;
  final List<DSLaneTask> tasks;

  const DSLane({required this.id, required this.label, required this.tasks});
}

class DSLaneTask {
  final int id;
  final String title;
  final String? priority;
  final String? owner;
  final String? proofState;
  final int? reviewScore;
  final List<String>? linkedSkills;
  final int? dependencyCount;

  const DSLaneTask({
    required this.id,
    required this.title,
    this.priority,
    this.owner,
    this.proofState,
    this.reviewScore,
    this.linkedSkills,
    this.dependencyCount,
  });
}
