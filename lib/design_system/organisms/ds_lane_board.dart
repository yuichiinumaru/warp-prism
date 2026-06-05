import 'package:flutter/material.dart';
import '../tokens/tokens.dart';
import '../atoms/atoms.dart';
import '../molecules/molecules.dart';

/// ASW Observatory Organism - Lane Board
/// 
/// Kanban-style board for task lanes
class DSLaneBoard extends StatelessWidget {
  final List<DSLane> lanes;
  final String? selectedTaskId;
  final ValueChanged<String>? onTaskTap;

  const DSLaneBoard({
    super.key,
    required this.lanes,
    this.selectedTaskId,
    this.onTaskTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate lane width based on available space
        final minLaneWidth = 280.0;
        final maxLaneWidth = 320.0;
        final totalLanes = lanes.length;
        final availableWidth = constraints.maxWidth - (DSSpacing.lg * 2);
        final gapWidth = DSSpacing.md * (totalLanes - 1);
        final laneWidth = ((availableWidth - gapWidth) / totalLanes)
            .clamp(minLaneWidth, maxLaneWidth);

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
                    selectedTaskId: selectedTaskId,
                    onTaskTap: onTaskTap,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _LaneColumn extends StatelessWidget {
  final DSLane lane;
  final String? selectedTaskId;
  final ValueChanged<String>? onTaskTap;

  const _LaneColumn({
    required this.lane,
    this.selectedTaskId,
    this.onTaskTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Lane header
        _LaneHeader(lane: lane),
        
        const SizedBox(height: DSSpacing.sm),
        
        // Tasks
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: DSColors.obsidianElevated.withOpacity(0.3),
              borderRadius: BorderRadius.circular(DSRadii.lg),
              border: Border.all(
                color: DSColors.borderSubtle.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: lane.tasks.isEmpty
                ? _EmptyLane()
                : ListView.builder(
                    padding: const EdgeInsets.all(DSSpacing.sm),
                    itemCount: lane.tasks.length,
                    itemBuilder: (context, index) {
                      final task = lane.tasks[index];
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index < lane.tasks.length - 1 ? DSSpacing.sm : 0,
                        ),
                        child: DSTaskCard(
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
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}

class _LaneHeader extends StatelessWidget {
  final DSLane lane;

  const _LaneHeader({required this.lane});

  @override
  Widget build(BuildContext context) {
    final color = DSColors.forLane(lane.id);
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(DSRadii.md),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          DSIcon.small(DSIcons.forLane(lane.id), color: color),
          const SizedBox(width: DSSpacing.sm),
          Expanded(
            child: DSText.labelLarge(lane.label, color: color),
          ),
          DSBadge.count(lane.tasks.length, color: color),
        ],
      ),
    );
  }
}

class _EmptyLane extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DSSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DSIcon(
              Icons.inbox_outlined,
              color: DSColors.textTertiary,
              size: 32,
            ),
            const SizedBox(height: DSSpacing.sm),
            DSText.bodySmall(
              'No tasks',
              color: DSColors.textTertiary,
            ),
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

  const DSLane({
    required this.id,
    required this.label,
    required this.tasks,
  });
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
