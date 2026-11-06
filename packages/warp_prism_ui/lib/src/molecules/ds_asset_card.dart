import 'package:flutter/material.dart';
import '../tokens/tokens.dart';
import '../atoms/atoms.dart';
import 'ds_interactive_surface.dart';

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
  final FocusNode? focusNode;

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
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final kindColor = DSColors.forAssetKind(kind);
    final bgColor = selected
        ? kindColor.withValues(alpha: 0.1)
        : DSColors.obsidianElevated;
    final borderColor = selected
        ? kindColor.withValues(alpha: 0.5)
        : DSColors.borderSubtle;

    return DSInteractiveSurface(
      semanticLabel: '$kind asset: $name',
      selected: selected,
      onTap: onTap,
      focusNode: focusNode,
      excludeChildSemantics: true,
      animationDuration: DSMotion.fast,
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
                  color: kindColor.withValues(alpha: 0.15),
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
                    DSText.labelMedium(kind.toUpperCase(), color: kindColor),
                    const SizedBox(height: 2),
                    DSText.headingSmall(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (canonicality != null) DSChip.governance(canonicality!),
            ],
          ),

          // Description (compact gap: fixed grid cells such as 212x119.8
          // have no spare vertical budget; see Task 1889).
          if (description != null) ...[
            const SizedBox(height: DSSpacing.xs),
            DSText.bodySmall(
              description!,
              color: DSColors.textSecondary,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          // Footer (compact gap matches description gap above).
          if ((tags != null && tags!.isNotEmpty) || edgeCount != null) ...[
            const SizedBox(height: DSSpacing.xs),
            Row(
              children: [
                if (tags != null && tags!.isNotEmpty)
                  Expanded(
                    child: Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: tags!
                          .take(3)
                          .map(
                            (tag) => DSChip(label: tag, size: DSChipSize.small),
                          )
                          .toList(),
                    ),
                  ),
                if (edgeCount != null) ...[
                  const DSIcon.small(
                    DSIcons.link,
                    color: DSColors.textTertiary,
                  ),
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
    );
  }
}
