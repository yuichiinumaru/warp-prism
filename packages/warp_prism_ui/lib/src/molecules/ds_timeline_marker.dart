import 'package:flutter/material.dart';
import '../tokens/tokens.dart';
import '../atoms/atoms.dart';

/// ASW Observatory Molecule - Timeline Marker
///
/// Marker for timeline/changelog entries
class DSTimelineMarker extends StatelessWidget {
  final String date;
  final String title;
  final String? type;
  final String? project;
  final String? taskId;
  final List<String>? impacts;
  final bool isFirst;
  final bool isLast;
  final bool selected;
  final VoidCallback? onTap;

  const DSTimelineMarker({
    super.key,
    required this.date,
    required this.title,
    this.type,
    this.project,
    this.taskId,
    this.impacts,
    this.isFirst = false,
    this.isLast = false,
    this.selected = false,
    this.onTap,
  });

  Color get _typeColor {
    switch (type?.toLowerCase()) {
      case 'feature':
        return DSColors.statusSuccess;
      case 'fix':
        return DSColors.statusInfo;
      case 'refactor':
        return DSColors.accentViolet;
      case 'docs':
        return DSColors.accentGold;
      case 'chore':
        return DSColors.textTertiary;
      default:
        return DSColors.accentCyan;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = selected
        ? _typeColor.withOpacity(0.1)
        : DSColors.transparent;

    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          color: bgColor,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Timeline line and dot
                SizedBox(
                  width: 32,
                  child: Column(
                    children: [
                      // Top line
                      if (!isFirst)
                        Expanded(
                          child: Container(
                            width: 2,
                            color: DSColors.borderSubtle,
                          ),
                        )
                      else
                        const Expanded(child: SizedBox()),

                      // Dot
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _typeColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: DSColors.obsidianBase,
                            width: 2,
                          ),
                          boxShadow: selected
                              ? [
                                  BoxShadow(
                                    color: _typeColor.withOpacity(0.5),
                                    blurRadius: 8,
                                  ),
                                ]
                              : null,
                        ),
                      ),

                      // Bottom line
                      if (!isLast)
                        Expanded(
                          child: Container(
                            width: 2,
                            color: DSColors.borderSubtle,
                          ),
                        )
                      else
                        const Expanded(child: SizedBox()),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DSSpacing.sm,
                      vertical: DSSpacing.md,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header row
                        Row(
                          children: [
                            DSText.labelSmall(
                              date,
                              color: DSColors.textTertiary,
                            ),
                            if (type != null) ...[
                              const SizedBox(width: DSSpacing.sm),
                              _TypeBadge(type: type!, color: _typeColor),
                            ],
                            if (taskId != null) ...[
                              const SizedBox(width: DSSpacing.sm),
                              DSText.code(
                                '#$taskId',
                                color: DSColors.assetTask,
                              ),
                            ],
                          ],
                        ),

                        const SizedBox(height: DSSpacing.xs),

                        // Title
                        DSText.bodyMedium(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        // Project
                        if (project != null) ...[
                          const SizedBox(height: DSSpacing.xs),
                          Row(
                            children: [
                              DSIcon.small(
                                Icons.folder_outlined,
                                color: DSColors.textTertiary,
                              ),
                              const SizedBox(width: 4),
                              DSText.labelSmall(
                                project!,
                                color: DSColors.textSecondary,
                              ),
                            ],
                          ),
                        ],

                        // Impacts
                        if (impacts != null && impacts!.isNotEmpty) ...[
                          const SizedBox(height: DSSpacing.sm),
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: impacts!
                                .take(3)
                                .map(
                                  (impact) => DSChip(
                                    label: impact,
                                    size: DSChipSize.small,
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final String type;
  final Color color;

  const _TypeBadge({required this.type, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(DSRadii.xs),
      ),
      child: Text(
        type.toUpperCase(),
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
