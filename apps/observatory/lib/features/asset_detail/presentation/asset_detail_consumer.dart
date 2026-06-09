/// Asset detail consumer — shared responsive detail wrapper for all
/// workspace surfaces.
///
/// Consumer surfaces (Map, Operate, History, Governance) wrap their
/// body content with this widget to get responsive detail behavior
/// without duplicating inspector layout logic per screen.
///
/// This widget reads from [AssetSelectionController] and delegates
/// to [ResponsiveDetailShell] for breakpoint-aware rendering:
///   >= 1200px: side-by-side split pane
///   800-1199px: overlay drawer with scrim
///   < 800px: full-screen detail with back navigation
///
/// Usage in a consumer surface:
/// ```dart
/// AssetDetailConsumer(
///   detailBuilder: (context, assetId) => _buildDetailPanel(assetId),
///   detailTitle: 'Asset Detail',
///   child: _buildMainContent(),
/// )
/// ```
library;

import 'package:flutter/material.dart';
import 'responsive_detail_shell.dart';

/// Wraps a workspace surface body with responsive asset detail rendering.
///
/// When no detail is active, renders only [child]. When detail is
/// triggered (by selection, deep-link, or navigation), renders the
/// detail using the appropriate breakpoint behavior.
///
/// This is a stateful bridge: it manages the show/hide state and
/// delegates close events to [onDetailClose].
class AssetDetailConsumer extends StatelessWidget {
  /// The main content of the workspace surface.
  final Widget child;

  /// Builder for the detail panel content, given an asset identifier.
  /// Called only when the detail is visible.
  final Widget Function(BuildContext context, String assetId) detailBuilder;

  /// The asset ID to display in the detail panel. Null means no detail.
  final String? selectedAssetId;

  /// Called when the user dismisses the detail (close, back, scrim).
  final VoidCallback? onDetailClose;

  /// Title shown in narrow-mode AppBar and detail header.
  final String? detailTitle;

  /// Kind label shown in narrow-mode AppBar subtitle.
  final String? detailKind;

  const AssetDetailConsumer({
    super.key,
    required this.child,
    required this.detailBuilder,
    this.selectedAssetId,
    this.onDetailClose,
    this.detailTitle,
    this.detailKind,
  });

  @override
  Widget build(BuildContext context) {
    final showDetail = selectedAssetId != null && selectedAssetId!.isNotEmpty;

    return ResponsiveDetailShell(
      showDetail: showDetail,
      onDetailClose: onDetailClose,
      detailTitle: detailTitle,
      detailKind: detailKind,
      masterContent: child,
      detailContent: showDetail
          ? detailBuilder(context, selectedAssetId!)
          : const SizedBox.shrink(),
    );
  }
}
