import 'package:flutter/material.dart';
import '../tokens/tokens.dart';
import 'ds_shimmer.dart';
import 'ds_skeleton_text_line.dart';

/// ASW Observatory Molecule - Skeleton Card
///
/// Card-shaped skeleton placeholder matching [DSAssetCard] proportions.
/// Displays shimmer blocks for an icon area, title line, and subtitle line.
///
/// Contract:
/// - Matches [DSAssetCard] padding ([DSSpacing.insetCard]) and radius ([DSRadii.card]).
/// - Background uses [DSColors.obsidianElevated].
/// - Border uses [DSColors.borderSubtle].
/// - All shimmer blocks use [DSShimmer].
///
/// Usage:
/// ```dart
/// DSSkeletonCard() // default 3-line card
/// ```
class DSSkeletonCard extends StatelessWidget {
  /// Whether to show the subtitle text line. Defaults to true.
  final bool showSubtitle;

  const DSSkeletonCard({
    super.key,
    this.showSubtitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DSSpacing.insetCard),
      decoration: BoxDecoration(
        color: DSColors.obsidianElevated,
        borderRadius: BorderRadius.circular(DSRadii.card),
        border: Border.all(color: DSColors.borderSubtle, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: icon placeholder + title placeholder
          const Row(
            children: [
              // Icon area
              DSShimmer(
                width: 32,
                height: 32,
                borderRadius: DSRadii.sm,
              ),
              SizedBox(width: DSSpacing.sm),
              // Kind label + title
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DSShimmer(
                      width: 60,
                      height: 10,
                      borderRadius: DSRadii.xs,
                    ),
                    SizedBox(height: 6),
                    DSSkeletonTextLine(widthFactor: 0.6),
                  ],
                ),
              ),
              // Governance chip placeholder
              DSShimmer(
                width: 56,
                height: 20,
                borderRadius: DSRadii.chip,
              ),
            ],
          ),

          // Description line
          const SizedBox(height: DSSpacing.sm),
          const DSSkeletonTextLine(widthFactor: 0.9),

          // Subtitle line
          if (showSubtitle) ...[
            const SizedBox(height: DSSpacing.xs),
            const DSSkeletonTextLine(widthFactor: 0.5),
          ],
        ],
      ),
    );
  }
}
