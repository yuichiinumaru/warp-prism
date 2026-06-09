/// Operate task detail panel — wraps [DSDetailInspector] with
/// task-specific sections produced by [buildTaskDetailSections].
///
/// Shows a forensic case file for the selected task: metadata, dependencies,
/// verification commands, evidence, related links, and body summary.
library;

import 'package:flutter/material.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';
import 'task_projection.dart';
import 'operate_task_detail_mapper.dart';

/// Panel that renders a [TaskProjection] as a [DSDetailInspector].
class OperateTaskDetailPanel extends StatelessWidget {
  /// The selected task to inspect.
  final TaskProjection task;

  /// Called when the user closes the inspector.
  final VoidCallback? onClose;

  const OperateTaskDetailPanel({
    super.key,
    required this.task,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return DSDetailInspector(
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
      color: DSColors.obsidianBase,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DSIcon(Icons.task_outlined, color: DSColors.textTertiary, size: 48),
            const SizedBox(height: DSSpacing.lg),
            DSText.headingMedium(
              'No task selected',
              color: DSColors.textSecondary,
            ),
            const SizedBox(height: DSSpacing.sm),
            DSText.bodyMedium(
              'Select a task card from the board to inspect its details',
              color: DSColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
