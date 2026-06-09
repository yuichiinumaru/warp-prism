/// Task lane panel for the workspace snapshot page.
///
/// Displays tasks grouped by lane using [DSTaskCard] primitives.
/// Cards are tappable to open the detail inspector.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/workspace_graph.dart';
import '../../../../data/models/task_contracts.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';
import '../workspace_snapshot_provider.dart';

/// Renders tasks grouped by lane with counts.
class TaskLanePanel extends ConsumerWidget {
  final List<WorkspaceAsset> tasks;

  const TaskLanePanel({super.key, required this.tasks});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (tasks.isEmpty) {
      return const DSStateSurface.empty(
        icon: Icons.task_outlined,
        title: 'No tasks found',
        subtitle: 'Place task .md files in docs/tasks/{lane}/',
      );
    }

    // Group tasks by lane
    final tasksByLane = <TaskLane, List<WorkspaceAsset>>{};
    for (final lane in TaskLane.values) {
      tasksByLane[lane] = [];
    }
    for (final task in tasks) {
      final taskMeta = task.frontmatter['_taskMetadata'] as TaskMetadata?;
      final lane = taskMeta?.lane ?? TaskLane.open;
      tasksByLane[lane]!.add(task);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: TaskLane.values
          .where((lane) => tasksByLane[lane]!.isNotEmpty)
          .map((lane) => _LaneSection(
                lane: lane,
                tasks: tasksByLane[lane]!,
              ))
          .toList(),
    );
  }
}

/// A section for one task lane.
class _LaneSection extends ConsumerWidget {
  final TaskLane lane;
  final List<WorkspaceAsset> tasks;

  const _LaneSection({required this.lane, required this.tasks});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 16,
              decoration: BoxDecoration(
                color: DSColors.forLane(lane.directoryPrefix),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: DSSpacing.sm),
            DSText.labelMedium(
              '${lane.directoryPrefix.toUpperCase()} (${tasks.length})',
              color: DSColors.textSecondary,
            ),
          ],
        ),
        const SizedBox(height: DSSpacing.sm),
        ...tasks.map((task) {
          final taskMeta =
              task.frontmatter['_taskMetadata'] as TaskMetadata?;
          // Parse task id for DSTaskCard (expects int)
          final taskId = int.tryParse(taskMeta?.id ?? '') ?? 0;
          return Padding(
            padding: const EdgeInsets.only(bottom: DSSpacing.sm),
            child: GestureDetector(
              onTap: () => selectAsset(ref, task.id),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: DSTaskCard(
                  id: taskId,
                  title: taskMeta?.title ?? task.name,
                  lane: lane.directoryPrefix,
                  priority: taskMeta?.priority,
                  owner: taskMeta?.owner,
                  proofState: taskMeta?.proofState.name,
                  linkedSkills: taskMeta?.skills,
                  dependencyCount: taskMeta?.dependsOn.length,
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: DSSpacing.md),
      ],
    );
  }
}
