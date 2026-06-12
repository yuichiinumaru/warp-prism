/// Shell-level state handler for loading, empty, and error conditions.
///
/// Provides reusable widget builders that route surfaces use to render
/// truthful state explanations instead of blank panels. These are
/// shell-level concerns — they sit between the data layer and the
/// feature-local content, so every routed surface inherits consistent
/// fallback behavior.
///
/// The three states are deliberately distinct:
/// - **loading**: a load/parsing operation is in progress.
/// - **empty**: data loaded successfully but the dataset is empty.
/// - **error**: a load/parse operation failed.
///
/// Deep-link fallback is handled by [buildUnresolvedAssetFallback].
library;

import 'package:flutter/material.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// Shell-level state handler.
///
/// All methods are static and return [Widget] so they can be used
/// inline in any routed surface without requiring a stateful wrapper.
abstract class ShellStateHandler {
  // ---------------------------------------------------------------------------
  // Loading state
  // ---------------------------------------------------------------------------

  /// Renders a full-surface loading indicator with an explanatory message.
  ///
  /// This is distinct from empty data — the user knows data is coming.
  static Widget buildLoading({
    String title = 'Loading workspace...',
    String? subtitle,
  }) {
    return Center(
      child: DSStateSurface.loading(
        icon: Icons.hourglass_empty,
        title: title,
        subtitle: subtitle,
      ),
    );
  }

  /// Compact loading indicator for inline use (e.g., inside panels).
  static Widget buildLoadingCompact({String title = 'Loading...'}) {
    return Center(child: DSStateSurface.loading(title: title, compact: true));
  }

  // ---------------------------------------------------------------------------
  // Empty state
  // ---------------------------------------------------------------------------

  /// Renders a full-surface empty state explaining that no data is available.
  ///
  /// The [surfaceName] parameter identifies which surface is empty
  /// (e.g., "Overview", "Agent Catalog") so the message is contextual.
  static Widget buildEmpty({
    required String surfaceName,
    IconData icon = Icons.inbox_outlined,
    String? subtitle,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: DSStateSurface.empty(
          icon: icon,
          title: 'No $surfaceName data',
          subtitle:
              subtitle ??
              'The workspace is loaded but contains no assets to display here.',
          actionLabel: actionLabel,
          onAction: onAction,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Error state
  // ---------------------------------------------------------------------------

  /// Renders a full-surface error state with retry affordance.
  ///
  /// The [errorMessage] is shown as subtitle guidance. The [onRetry]
  /// callback is exposed as a "Retry" button when provided.
  static Widget buildError({
    required String title,
    String? errorMessage,
    VoidCallback? onRetry,
  }) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: DSStateSurface.error(
          icon: DSIcons.error,
          title: title,
          subtitle: errorMessage,
          actionLabel: onRetry != null ? 'Retry' : null,
          onAction: onRetry,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Deep-link / unresolved asset fallback
  // ---------------------------------------------------------------------------

  /// Renders a fallback for when a deep-linked asset cannot be resolved.
  ///
  /// This covers:
  /// - Unknown asset IDs (e.g., `/asset/nonexistent-id`)
  /// - Unsupported narrow-layout inspector states
  /// - Assets that were deleted or renamed
  ///
  /// The [assetId] is displayed to the user so they can verify typos.
  /// The [onNavigateHome] callback returns the user to a safe surface.
  static Widget buildUnresolvedAssetFallback({
    required String assetId,
    VoidCallback? onNavigateHome,
    VoidCallback? onRetry,
  }) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DSIcon(Icons.link_off, color: DSColors.statusWarning, size: 48),
            const SizedBox(height: DSSpacing.lg),
            DSText.headingSmall('Asset not found', color: DSColors.textPrimary),
            const SizedBox(height: DSSpacing.sm),
            DSText.bodyMedium(
              'Could not resolve asset:',
              color: DSColors.textSecondary,
            ),
            const SizedBox(height: DSSpacing.xs),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DSSpacing.md,
                vertical: DSSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: DSColors.obsidianElevated,
                borderRadius: BorderRadius.circular(DSRadii.sm),
                border: Border.all(color: DSColors.borderSubtle),
              ),
              child: DSText.labelMedium(assetId, color: DSColors.accentCyan),
            ),
            const SizedBox(height: DSSpacing.xs),
            DSText.bodySmall(
              'The asset may have been removed, renamed, '
              'or the link may be incorrect.',
              color: DSColors.textTertiary,
            ),
            const SizedBox(height: DSSpacing.lg),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onRetry != null)
                  OutlinedButton.icon(
                    onPressed: onRetry,
                    icon: const DSIcon.small(DSIcons.refresh),
                    label: const Text('Retry'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: DSColors.accentCyan,
                      side: BorderSide(
                        color: DSColors.accentCyan.withOpacity(0.5),
                      ),
                    ),
                  ),
                if (onRetry != null && onNavigateHome != null)
                  const SizedBox(width: DSSpacing.md),
                if (onNavigateHome != null)
                  OutlinedButton.icon(
                    onPressed: onNavigateHome,
                    icon: const DSIcon.small(Icons.home_outlined),
                    label: const Text('Go to Overview'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: DSColors.textSecondary,
                      side: BorderSide(color: DSColors.borderDefault),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Renders a narrow-layout inspector fallback.
  ///
  /// When the viewport is too narrow for the inspector panel, this
  /// explains that detail view requires a wider layout.
  static Widget buildNarrowLayoutInspectorFallback() {
    return Center(
      child: DSStateSurface.empty(
        icon: Icons.view_sidebar_outlined,
        title: 'Detail panel unavailable',
        subtitle:
            'Resize the window to at least ${DSBreakpoints.masterDetailSideBySide}px '
            'wide to view asset details.',
        compact: true,
      ),
    );
  }
}
