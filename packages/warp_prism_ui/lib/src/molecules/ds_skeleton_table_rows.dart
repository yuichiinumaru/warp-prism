import 'package:flutter/material.dart';
import '../tokens/tokens.dart';
import 'ds_shimmer.dart';

/// ASW Observatory Molecule - Skeleton Table Rows
///
/// Renders N shimmer placeholder rows for table content.
/// Each row contains cells with configurable fractional widths.
///
/// Contract:
/// - Default [rowCount] is 3.
/// - Default [columnWidths] creates a 3-column proportional layout.
/// - All shimmer blocks use [DSShimmer] with [DSColors] tokens.
/// - Row height defaults to 40px.
/// - Row separator uses [DSSpacing.xs] gap.
///
/// Usage:
/// ```dart
/// DSSkeletonTableRows() // 3 rows, 3 columns
/// DSSkeletonTableRows(
///   rowCount: 5,
///   columnWidths: [0.3, 0.4, 0.2, 0.1],
/// )
/// ```
class DSSkeletonTableRows extends StatelessWidget {
  /// Number of skeleton rows to render. Defaults to 3.
  final int rowCount;

  /// Fractional widths for each column (must sum to <= 1.0).
  /// Defaults to [0.3, 0.4, 0.3] (3 equal-ish columns).
  final List<double> columnWidths;

  /// Height of each row. Defaults to 40.
  final double rowHeight;

  const DSSkeletonTableRows({
    super.key,
    this.rowCount = 3,
    this.columnWidths = const [0.3, 0.4, 0.3],
    this.rowHeight = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(rowCount, (rowIndex) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: rowIndex < rowCount - 1 ? DSSpacing.xs : 0,
          ),
          child: SizedBox(
            height: rowHeight,
            child: Row(
              children: List.generate(columnWidths.length, (colIndex) {
                return Expanded(
                  flex: (columnWidths[colIndex] * 1000).round(),
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: colIndex < columnWidths.length - 1
                          ? DSSpacing.sm
                          : 0,
                    ),
                    child: DSShimmer(
                      height: rowHeight * 0.5,
                      borderRadius: DSRadii.xs,
                    ),
                  ),
                );
              }),
            ),
          ),
        );
      }),
    );
  }
}
