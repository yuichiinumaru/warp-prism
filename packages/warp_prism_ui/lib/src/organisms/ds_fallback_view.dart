import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../tokens/tokens.dart';
import '../atoms/atoms.dart';

/// ASW Observatory Organism - Fallback View
///
/// Error display widget with glass panel styling, error icon, title,
/// optional error details, and a retry button.
///
/// Contract:
/// - Uses [DSGlassPanelSimple] for container styling.
/// - Error icon uses [DSColors.statusError].
/// - In debug mode, shows [errorDetails]. In release mode, shows a friendly message.
/// - Retry button uses [DSColors.statusError] accent.
///
/// Usage:
/// ```dart
/// DSFallbackView(
///   error: caughtError,
///   stackTrace: caughtStack,
///   onRetry: () => rebuild(),
/// )
/// ```
class DSFallbackView extends StatelessWidget {
  /// The caught error object.
  final Object error;

  /// Optional stack trace for debug display.
  final StackTrace? stackTrace;

  /// Callback when the user taps the retry button. If null, no button is shown.
  final VoidCallback? onRetry;

  /// Custom title override. Defaults to 'Something went wrong'.
  final String? title;

  const DSFallbackView({
    super.key,
    required this.error,
    this.stackTrace,
    this.onRetry,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return DSGlassPanelSimple(
      padding: const EdgeInsets.all(DSSpacing.lg),
      borderColor: DSColors.statusError.withValues(alpha: 0.3),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Error icon
          const DSIcon(DSIcons.error, color: DSColors.statusError, size: 32),

          const SizedBox(height: DSSpacing.md),

          // Title
          DSText.headingSmall(
            title ?? 'Something went wrong',
            color: DSColors.textPrimary,
          ),

          const SizedBox(height: DSSpacing.sm),

          // Error details — debug shows real message, release shows friendly text
          DSText.bodySmall(
            kDebugMode ? error.toString() : 'An unexpected error occurred.',
            color: DSColors.textTertiary,
            maxLines: kDebugMode ? 5 : 2,
            overflow: TextOverflow.ellipsis,
          ),

          // Stack trace — only in debug mode
          if (kDebugMode && stackTrace != null) ...[
            const SizedBox(height: DSSpacing.sm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(DSSpacing.sm),
              decoration: BoxDecoration(
                color: DSColors.obsidianDeep,
                borderRadius: BorderRadius.circular(DSRadii.sm),
              ),
              child: DSText.labelSmall(
                stackTrace.toString(),
                color: DSColors.textDisabled,
                maxLines: 8,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],

          // Retry button
          if (onRetry != null) ...[
            const SizedBox(height: DSSpacing.md),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const DSIcon.small(
                DSIcons.refresh,
                color: DSColors.statusError,
              ),
              label: const DSText.labelMedium(
                'Retry',
                color: DSColors.statusError,
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: DSColors.statusError.withValues(alpha: 0.5),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: DSSpacing.md,
                  vertical: DSSpacing.sm,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DSRadii.md),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
