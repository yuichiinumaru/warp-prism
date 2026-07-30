/// Project Story view for the History workspace.
///
/// Groups changelog entries by project and renders narrative panels
/// explaining why changes matter, using [PrismStoryPanel] as the
/// presentation primitive. Narratives are computed from metadata only
/// (no freeform prose).
library;

import 'package:flutter/material.dart';
import 'package:warp_prism_observatory/features/history/presentation/history_controller.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// Renders project-story groups as narrative panels.
///
/// Each group becomes a [PrismStoryPanel] with insights derived from
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
      return const PrismStateSurface.empty(
        icon: Icons.auto_stories_outlined,
        title: 'No project stories',
        subtitle:
            'Project story groups will appear once changelog entries exist',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(PrismSpacing.lg),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        return Padding(
          padding: EdgeInsets.only(
            bottom: index < groups.length - 1 ? PrismSpacing.lg : 0,
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
    final hasSelected = group.entries.any((e) => e.id == selectedEntryId);

    return Container(
      decoration: hasSelected
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(PrismRadii.md),
              border: Border.all(
                color: PrismColors.accentCyan.withValues(alpha: 0.5),
                width: 2,
              ),
            )
          : null,
      child: PrismStoryPanel(
        title: group.project,
        subtitle: group.summary,
        icon: Icons.folder_outlined,
        accentColor: PrismColors.accentCyan,
        insights: insights,
        footer: _buildEntryList(group),
      ),
    );
  }

  List<PrismStoryInsight> _buildInsights(ProjectStoryGroup group) {
    final insights = <PrismStoryInsight>[];

    insights.add(
      PrismStoryInsight(
        text:
            '${group.entries.length} changelog entr${group.entries.length == 1 ? 'y' : 'ies'} recorded',
        detail: 'Grouped by project to show cumulative progress',
      ),
    );

    final typeCounts = <String, int>{};
    for (final entry in group.entries) {
      typeCounts[entry.type.name] = (typeCounts[entry.type.name] ?? 0) + 1;
    }
    for (final tc in typeCounts.entries) {
      insights.add(
        PrismStoryInsight(
          text: '${tc.value} ${tc.key} change${tc.value == 1 ? '' : 's'}',
          value: tc.value.toString(),
        ),
      );
    }

    final allTags = group.entries.expand((e) => e.impactTags).toSet();
    if (allTags.isNotEmpty) {
      insights.add(
        PrismStoryInsight(
          text: 'Impact areas: ${allTags.join(', ')}',
          detail: 'Tags from frontmatter impact field',
        ),
      );
    }

    return insights;
  }

  Widget _buildEntryList(ProjectStoryGroup group) {
    if (group.entries.isEmpty) {
      return const PrismText.bodySmall(
        'No linked tasks',
        color: PrismColors.textTertiary,
      );
    }

    return Wrap(
      spacing: PrismSpacing.xs,
      runSpacing: PrismSpacing.xs,
      children: group.entries.map((entry) {
        final label = entry.task.isNotEmpty ? 'Task ${entry.task}' : entry.id;
        final isSelected = entry.id == selectedEntryId;
        return Semantics(
          button: true,
          label: 'Select $label',
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onEntryTap != null ? () => onEntryTap!(entry.id) : null,
              borderRadius: BorderRadius.circular(PrismRadii.sm),
              child: Container(
                key: ValueKey('story-entry-${entry.id}'),
                padding: const EdgeInsets.symmetric(
                  horizontal: PrismSpacing.sm,
                  vertical: PrismSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? PrismColors.accentCyan.withValues(alpha: 0.15)
                      : PrismColors.obsidianElevated,
                  borderRadius: BorderRadius.circular(PrismRadii.sm),
                  border: Border.all(
                    color: isSelected
                        ? PrismColors.accentCyan.withValues(alpha: 0.5)
                        : PrismColors.borderSubtle,
                  ),
                ),
                child: PrismText.labelSmall(
                  label,
                  color: isSelected
                      ? PrismColors.accentCyan
                      : PrismColors.textSecondary,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
