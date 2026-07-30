/// Operate task detail panel — wraps [PrismDetailInspector] with
/// task-specific sections produced by [buildTaskDetailSections].
///
/// Shows a forensic case file for the selected task: metadata, dependencies,
/// verification commands, evidence, related links, and body summary.
library;

import 'package:flutter/material.dart';
import 'package:warp_prism_observatory/features/operate/operate_task_detail_mapper.dart';
import 'package:warp_prism_observatory/features/operate/task_projection.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// Panel that renders a [TaskProjection] as a [PrismDetailInspector].
class OperateTaskDetailPanel extends StatelessWidget {
  /// The selected task to inspect.
  final TaskProjection task;

  /// Called when the user closes the inspector.
  final VoidCallback? onClose;

  const OperateTaskDetailPanel({super.key, required this.task, this.onClose});

  @override
  Widget build(BuildContext context) {
    return PrismDetailInspector(
      title: '${task.id} — ${task.title}',
      kind: 'task',
      subtitle: 'Lane: ${task.lane.name}  •  Priority: ${task.priority}',
      onClose: onClose,
      sections: buildTaskDetailSections(task),
    );
  }
}

/// Empty state when no task is selected in the Operate board.
class OperateTaskDetailEmpty extends StatelessWidget {
  const OperateTaskDetailEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: PrismColors.obsidianBase,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PrismIcon(
              Icons.task_outlined,
              color: PrismColors.textTertiary,
              size: 48,
            ),
            const SizedBox(height: PrismSpacing.lg),
            PrismText.headingMedium(
              'No task selected',
              color: PrismColors.textSecondary,
            ),
            const SizedBox(height: PrismSpacing.sm),
            PrismText.bodyMedium(
              'Select a task card from the board to inspect its details',
              color: PrismColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
