/// Asset Detail page — universal detail view for any workspace asset.
///
/// Handles deep-link fallback when the requested asset ID cannot be
/// resolved. Renders a shell-level unresolved-asset state instead of
/// a blank or crash surface.
///
/// To be replaced by the real Asset Detail screen in EPIC-09.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';
import '../../features/shell/shell_state_handler.dart';

/// Asset detail page with deep-link fallback handling.
///
/// When [assetId] is empty or matches a known-unresolvable pattern,
/// the page renders [ShellStateHandler.buildUnresolvedAssetFallback]
/// instead of pretending the asset exists.
class AssetDetailPage extends StatelessWidget {
  /// The asset ID from the route parameter.
  final String assetId;

  /// Whether the asset was resolved from the workspace data.
  ///
  /// In a real implementation, this would come from the data layer.
  /// For now, we treat any non-empty, well-formatted ID as "possibly valid"
  /// and empty/garbage IDs as unresolved.
  final bool resolved;

  const AssetDetailPage({
    super.key,
    required this.assetId,
    this.resolved = true,
  });

  @override
  Widget build(BuildContext context) {
    // Deep-link fallback: asset ID is empty or explicitly unresolved.
    if (assetId.isEmpty || assetId == 'unknown' || !resolved) {
      return _buildFallback(context);
    }

    // Normal asset detail rendering (placeholder for EPIC-09).
    return _buildDetail(context);
  }

  Widget _buildFallback(BuildContext context) {
    return Scaffold(
      backgroundColor: DSColors.obsidianDeep,
      appBar: AppBar(
        backgroundColor: DSColors.obsidianBase,
        foregroundColor: DSColors.textPrimary,
        elevation: 0,
        title: DSText.headingMedium('Asset Detail'),
        leading: IconButton(
          icon: const DSIcon(Icons.arrow_back),
          onPressed: () => context.go('/overview'),
          tooltip: 'Back to Overview',
        ),
      ),
      body: ShellStateHandler.buildUnresolvedAssetFallback(
        assetId: assetId.isEmpty ? '(empty)' : assetId,
        onNavigateHome: () => context.go('/overview'),
      ),
    );
  }

  Widget _buildDetail(BuildContext context) {
    return Scaffold(
      backgroundColor: DSColors.obsidianDeep,
      appBar: AppBar(
        backgroundColor: DSColors.obsidianBase,
        foregroundColor: DSColors.textPrimary,
        elevation: 0,
        title: DSText.headingMedium('Asset Detail'),
        leading: IconButton(
          icon: const DSIcon(Icons.arrow_back),
          onPressed: () => context.go('/overview'),
          tooltip: 'Back to Overview',
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DSIcon(
              Icons.article_outlined,
              color: DSColors.accentCyan,
              size: 48,
            ),
            const SizedBox(height: DSSpacing.lg),
            DSText.headingMedium('Asset Detail', color: DSColors.textPrimary),
            const SizedBox(height: DSSpacing.sm),
            DSText.bodyMedium('Asset: $assetId', color: DSColors.textSecondary),
            const SizedBox(height: DSSpacing.xs),
            DSText.bodyMedium(
              'Detail view — coming soon',
              color: DSColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
