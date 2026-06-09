/// Changelog list panel for the workspace snapshot page.
///
/// Displays discovered changelog entries using DS primitives.
/// Cards are tappable to open the detail inspector.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/workspace_graph.dart';
import '../../../../data/models/changelog_contracts.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';
import '../workspace_snapshot_provider.dart';

/// Renders a scrollable list of changelog entries.
class ChangelogListPanel extends ConsumerWidget {
  final List<WorkspaceAsset> changelogEntries;

  const ChangelogListPanel({super.key, required this.changelogEntries});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (changelogEntries.isEmpty) {
      return const DSStateSurface.empty(
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
        final clMeta = entry.frontmatter['_changelogMetadata']
            as ChangelogMetadata?;

        return Padding(
          padding: const EdgeInsets.only(bottom: DSSpacing.sm),
          child: GestureDetector(
            onTap: () => selectAsset(ref, entry.id),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: DSGlassPanelSimple(
                padding: const EdgeInsets.all(DSSpacing.insetCard),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row
                    Row(
                      children: [
                        DSIcon.small(
                          DSIcons.changelog,
                          color: DSColors.accentViolet,
                        ),
                        const SizedBox(width: DSSpacing.sm),
                        Expanded(
                          child: DSText.labelMedium(
                            clMeta?.id ?? entry.name,
                            color: DSColors.textPrimary,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (clMeta?.type != null)
                          DSChip(
                            label: clMeta!.type.name,
                            size: DSChipSize.small,
                          ),
                      ],
                    ),

                    // Description
                    if (entry.description.isNotEmpty) ...[
                      const SizedBox(height: DSSpacing.xs),
                      DSText.bodySmall(
                        entry.description,
                        color: DSColors.textSecondary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    // Footer: project, task, date
                    if (clMeta != null) ...[
                      const SizedBox(height: DSSpacing.sm),
                      Row(
                        children: [
                          if (clMeta.project.isNotEmpty) ...[
                            DSText.labelSmall(
                              clMeta.project,
                              color: DSColors.textTertiary,
                            ),
                            const SizedBox(width: DSSpacing.sm),
                          ],
                          if (clMeta.task.isNotEmpty) ...[
                            DSIcon.small(
                              DSIcons.task,
                              color: DSColors.textTertiary,
                            ),
                            const SizedBox(width: 4),
                            DSText.labelSmall(
                              clMeta.task,
                              color: DSColors.textTertiary,
                            ),
                            const SizedBox(width: DSSpacing.sm),
                          ],
                          const Spacer(),
                          DSText.labelSmall(
                            _formatDate(clMeta.date),
                            color: DSColors.textTertiary,
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
