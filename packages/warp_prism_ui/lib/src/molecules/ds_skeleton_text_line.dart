import 'package:flutter/material.dart';
import '../tokens/tokens.dart';
import 'ds_shimmer.dart';

/// ASW Observatory Molecule - Skeleton Text Line
///
/// Single shimmer placeholder line for text content.
///
/// Contract:
/// - Uses [DSShimmer] internally.
/// - Default height matches [DSTypography] body line height.
/// - Default width factor is 0.7 (70% of parent width).
/// - All colors from [DSColors], radii from [DSRadii].
///
/// Usage:
/// ```dart
/// DSSkeletonTextLine() // 70% width
/// DSSkeletonTextLine(widthFactor: 0.5) // 50% width
/// ```
class DSSkeletonTextLine extends StatelessWidget {
  /// Fraction of parent width to fill (0.0 to 1.0). Defaults to 0.7.
  final double widthFactor;

  /// Height of the text line. Defaults to 14.
  final double height;

  const DSSkeletonTextLine({
    super.key,
    this.widthFactor = 0.7,
    this.height = 14,
  });

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      alignment: Alignment.centerLeft,
      child: DSShimmer(
        height: height,
        borderRadius: DSRadii.xs,
      ),
    );
  }
}
