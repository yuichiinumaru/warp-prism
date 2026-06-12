import 'package:flutter/material.dart';
import '../tokens/tokens.dart';
import '../atoms/atoms.dart';
import '../molecules/molecules.dart';

/// ASW Observatory Organism - Timeline
///
/// Chronological list of changelog entries
class DSTimeline extends StatelessWidget {
  final List<DSTimelineEntry> entries;
  final String? selectedId;
  final ValueChanged<String>? onEntryTap;
  final bool showFilters;
  final Widget? filterBar;

  const DSTimeline({
    super.key,
    required this.entries,
    this.selectedId,
    this.onEntryTap,
    this.showFilters = true,
    this.filterBar,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showFilters && filterBar != null) ...[
          filterBar!,
          const SizedBox(height: DSSpacing.md),
        ],

        Expanded(
          child: entries.isEmpty
              ? DSStateSurface.empty(
                  icon: DSIcons.history,
                  title: 'No changelog entries',
                  subtitle: 'Changes will appear here as they are recorded',
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DSSpacing.lg,
                    vertical: DSSpacing.md,
                  ),
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    return DSTimelineMarker(
                      date: entry.date,
                      title: entry.title,
                      type: entry.type,
                      project: entry.project,
                      taskId: entry.taskId,
                      impacts: entry.impacts,
                      isFirst: index == 0,
                      isLast: index == entries.length - 1,
                      selected: entry.id == selectedId,
                      onTap: () => onEntryTap?.call(entry.id),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class DSTimelineEntry {
  final String id;
  final String date;
  final String title;
  final String? type;
  final String? project;
  final String? taskId;
  final List<String>? impacts;

  const DSTimelineEntry({
    required this.id,
    required this.date,
    required this.title,
    this.type,
    this.project,
    this.taskId,
    this.impacts,
  });
}

/// Grouped timeline with story sections
class DSTimelineGrouped extends StatelessWidget {
  final List<DSTimelineGroup> groups;
  final String? selectedId;
  final ValueChanged<String>? onEntryTap;

  const DSTimelineGrouped({
    super.key,
    required this.groups,
    this.selectedId,
    this.onEntryTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(DSSpacing.lg),
      itemCount: groups.length,
      itemBuilder: (context, groupIndex) {
        final group = groups[groupIndex];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (groupIndex > 0) const SizedBox(height: DSSpacing.xxl),

            // Group header
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DSSpacing.md,
                vertical: DSSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: DSColors.obsidianElevated,
                borderRadius: BorderRadius.circular(DSRadii.md),
              ),
              child: Row(
                children: [
                  DSIcon.small(
                    group.icon ?? Icons.folder_outlined,
                    color: group.color ?? DSColors.accentCyan,
                  ),
                  const SizedBox(width: DSSpacing.sm),
                  DSText.labelLarge(
                    group.title,
                    color: group.color ?? DSColors.textPrimary,
                  ),
                  const Spacer(),
                  DSText.labelSmall(
                    '${group.entries.length} changes',
                    color: DSColors.textTertiary,
                  ),
                ],
              ),
            ),

            const SizedBox(height: DSSpacing.sm),

            // Group entries
            ...group.entries.asMap().entries.map((e) {
              final index = e.key;
              final entry = e.value;
              return DSTimelineMarker(
                date: entry.date,
                title: entry.title,
                type: entry.type,
                project: entry.project,
                taskId: entry.taskId,
                impacts: entry.impacts,
                isFirst: index == 0,
                isLast: index == group.entries.length - 1,
                selected: entry.id == selectedId,
                onTap: () => onEntryTap?.call(entry.id),
              );
            }),
          ],
        );
      },
    );
  }
}

class DSTimelineGroup {
  final String title;
  final IconData? icon;
  final Color? color;
  final List<DSTimelineEntry> entries;

  const DSTimelineGroup({
    required this.title,
    this.icon,
    this.color,
    required this.entries,
  });
}
