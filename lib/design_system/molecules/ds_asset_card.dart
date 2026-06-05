import 'package:flutter/material.dart';
import '../tokens/tokens.dart';
import '../atoms/atoms.dart';

/// ASW Observatory Molecule - Asset Card
/// 
/// Card representing any workspace asset (agent, skill, workflow, etc.)
class DSAssetCard extends StatelessWidget {
  final String name;
  final String kind;
  final String? description;
  final String? canonicality;
  final List<String>? tags;
  final int? edgeCount;
  final bool selected;
  final VoidCallback? onTap;

  const DSAssetCard({
    super.key,
    required this.name,
    required this.kind,
    this.description,
    this.canonicality,
    this.tags,
    this.edgeCount,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final kindColor = DSColors.forAssetKind(kind);
    final bgColor = selected
        ? kindColor.withOpacity(0.1)
        : DSColors.obsidianElevated;
    final borderColor = selected
        ? kindColor.withOpacity(0.5)
        : DSColors.borderSubtle;

    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: DSMotion.fast,
          padding: const EdgeInsets.all(DSSpacing.insetCard),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(DSRadii.card),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: kindColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(DSRadii.sm),
                    ),
                    child: DSIcon.small(
                      DSIcons.forAssetKind(kind),
                      color: kindColor,
                    ),
                  ),
                  const SizedBox(width: DSSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DSText.labelMedium(
                          kind.toUpperCase(),
                          color: kindColor,
                        ),
                        const SizedBox(height: 2),
                        DSText.headingSmall(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (canonicality != null)
                    DSChip.governance(canonicality!, size: DSChipSize.small),
                ],
              ),
              
              // Description
              if (description != null) ...[
                const SizedBox(height: DSSpacing.sm),
                DSText.bodySmall(
                  description!,
                  color: DSColors.textSecondary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              
              // Footer
              if ((tags != null && tags!.isNotEmpty) || edgeCount != null) ...[
                const SizedBox(height: DSSpacing.sm),
                Row(
                  children: [
                    if (tags != null && tags!.isNotEmpty)
                      Expanded(
                        child: Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: tags!.take(3).map((tag) => DSChip(
                            label: tag,
                            size: DSChipSize.small,
                          )).toList(),
                        ),
                      ),
                    if (edgeCount != null) ...[
                      DSIcon.small(DSIcons.link, color: DSColors.textTertiary),
                      const SizedBox(width: 4),
                      DSText.labelSmall(
                        edgeCount.toString(),
                        color: DSColors.textTertiary,
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
