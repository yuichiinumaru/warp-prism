/// Changelog list panel for the workspace snapshot page.
///
/// Displays discovered changelog entries using Prism primitives.
/// Cards are tappable to open the detail inspector.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warp_prism_observatory/data/models/workspace_graph.dart';
import 'package:warp_prism_observatory/data/models/changelog_contracts.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';
import '../workspace_snapshot_provider.dart';

/// Renders a scrollable list of changelog entries.
class ChangelogListPanel extends ConsumerWidget {
  final List<WorkspaceAsset> changelogEntries;

  const ChangelogListPanel({super.key, required this.changelogEntries});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (changelogEntries.isEmpty) {
      return const PrismStateSurface.empty(
        icon: Icons.history_outlined,
        title: 'No changelog entries found',
        subtitle: 'Place changelog .md files in docs/changelog/',
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: changelogEntries.length,
      itemBuilder: (context, index) {
        final entry = changelogEntries[index];
        final clMeta =
            entry.frontmatter['_changelogMetadata'] as ChangelogMetadata?;

        return Padding(
          padding: const EdgeInsets.only(bottom: PrismSpacing.sm),
          child: GestureDetector(
            onTap: () => selectAsset(ref, entry.id),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: PrismGlassPanelSimple(
                padding: const EdgeInsets.all(PrismSpacing.insetCard),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row
                    Row(
                      children: [
                        const PrismIcon.small(
                          PrismIcons.changelog,
                          color: PrismColors.accentViolet,
                        ),
                        const SizedBox(width: PrismSpacing.sm),
                        Expanded(
                          child: PrismText.labelMedium(
                            clMeta?.id ?? entry.name,
                            color: PrismColors.textPrimary,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (clMeta?.type != null)
                          PrismChip(
                            label: clMeta!.type.name,
                            size: PrismChipSize.small,
                          ),
                      ],
                    ),

                    // Description
                    if (entry.description.isNotEmpty) ...[
                      const SizedBox(height: PrismSpacing.xs),
                      PrismText.bodySmall(
                        entry.description,
                        color: PrismColors.textSecondary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    // Footer: project, task, date
                    if (clMeta != null) ...[
                      const SizedBox(height: PrismSpacing.sm),
                      Row(
                        children: [
                          if (clMeta.project.isNotEmpty) ...[
                            PrismText.labelSmall(
                              clMeta.project,
                              color: PrismColors.textTertiary,
                            ),
                            const SizedBox(width: PrismSpacing.sm),
                          ],
                          if (clMeta.task.isNotEmpty) ...[
                            const PrismIcon.small(
                              PrismIcons.task,
                              color: PrismColors.textTertiary,
                            ),
                            const SizedBox(width: 4),
                            PrismText.labelSmall(
                              clMeta.task,
                              color: PrismColors.textTertiary,
                            ),
                            const SizedBox(width: PrismSpacing.sm),
                          ],
                          const Spacer(),
                          PrismText.labelSmall(
                            _formatDate(clMeta.date),
                            color: PrismColors.textTertiary,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
