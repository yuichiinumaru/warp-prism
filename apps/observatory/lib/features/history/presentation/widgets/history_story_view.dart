/// Project Story view for the History workspace.
///
/// Groups changelog entries by project and renders narrative panels
/// explaining why changes matter, using [DSStoryPanel] as the
/// presentation primitive.
library;

import 'package:flutter/material.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';
import '../history_controller.dart';

/// Renders project-story groups as narrative panels.
///
/// Each group becomes a [DSStoryPanel] with insights derived from
/// the entry metadata — no freeform prose, only computed narratives.
class HistoryStoryView extends StatelessWidget {
  /// Project-story groups derived from the History read model.
  final List<ProjectStoryGroup> groups;

  /// Callback when a group's entry is tapped (for selection sync).
  final ValueChanged<String>? onEntryTap;

  /// Currently selected entry ID.
  final String? selectedEntryId;

  const HistoryStoryView({
    super.key,
    required this.groups,
    this.onEntryTap,
    this.selectedEntryId,
  });

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty) {
      return DSStateSurface.empty(
        icon: Icons.auto_stories_outlined,
        title: 'No project stories',
        subtitle:
            'Project story groups will appear once changelog entries exist',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(DSSpacing.lg),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        return Padding(
          padding: EdgeInsets.only(
            bottom: index < groups.length - 1 ? DSSpacing.lg : 0,
          ),
          child: _ProjectStoryCard(
            group: group,
            onEntryTap: onEntryTap,
            selectedEntryId: selectedEntryId,
          ),
        );
      },
    );
  }
}

class _ProjectStoryCard extends StatelessWidget {
  final ProjectStoryGroup group;
  final ValueChanged<String>? onEntryTap;
  final String? selectedEntryId;

  const _ProjectStoryCard({
    required this.group,
    this.onEntryTap,
    this.selectedEntryId,
  });

  @override
  Widget build(BuildContext context) {
    final insights = _buildInsights(group);

    return DSStoryPanel(
      title: group.project,
      subtitle: group.summary,
      icon: Icons.folder_outlined,
      accentColor: DSColors.accentCyan,
      insights: insights,
      footer: _buildTaskList(group),
    );
  }

  List<DSStoryInsight> _buildInsights(ProjectStoryGroup group) {
    final insights = <DSStoryInsight>[];

    // Entry count insight
    insights.add(
      DSStoryInsight(
        text:
            '${group.entries.length} changelog entr${group.entries.length == 1 ? 'y' : 'ies'} recorded',
        detail: 'Grouped by project to show cumulative progress',
      ),
    );

    // Type breakdown
    final typeCounts = <String, int>{};
    for (final entry in group.entries) {
      typeCounts[entry.type.name] = (typeCounts[entry.type.name] ?? 0) + 1;
    }
    for (final tc in typeCounts.entries) {
      insights.add(
        DSStoryInsight(
          text: '${tc.value} ${tc.key} change${tc.value == 1 ? '' : 's'}',
          value: tc.value.toString(),
        ),
      );
    }

    // Impact tags
    final allTags = group.entries.expand((e) => e.impact).toSet();
    if (allTags.isNotEmpty) {
      insights.add(
        DSStoryInsight(
          text: 'Impact areas: ${allTags.join(', ')}',
          detail: 'Tags from frontmatter impact field',
        ),
      );
    }

    return insights;
  }

  Widget _buildTaskList(ProjectStoryGroup group) {
    final taskIds = group.taskIds;
    if (taskIds.isEmpty) {
      return DSText.bodySmall('No linked tasks', color: DSColors.textTertiary);
    }

    return Wrap(
      spacing: DSSpacing.xs,
      runSpacing: DSSpacing.xs,
      children: taskIds.map((taskId) {
        return DSChip(label: 'Task $taskId');
      }).toList(),
    );
  }
}
