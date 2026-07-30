import 'package:flutter/material.dart';
import '../tokens/tokens.dart';
import '../atoms/atoms.dart';

/// State Surface — shared component for loading, empty, error, and
/// operational states.
///
/// Use this instead of ad-hoc empty/error blocks in organisms
/// to keep state rendering consistent across consumer apps.
///
/// Supports both data-loading states (empty, loading, error) and
/// operational states (disabled, stale, degraded, excluded) that
/// map to the 15-state operational vocabulary.
///
/// Usage:
/// ```dart
/// DSStateSurface.empty(
///   icon: Icons.inbox_outlined,
///   title: 'No tasks',
///   subtitle: 'Tasks will appear here as they are created',
/// )
/// DSStateSurface.loading(title: 'Loading workspace...')
/// DSStateSurface.error(
///   title: 'Failed to load',
///   subtitle: 'Parser returned an unexpected format',
///   onRetry: () => reload(),
/// )
/// DSStateSurface.disabled(title: 'Feature not available')
/// DSStateSurface.stale(title: 'Data outdated', subtitle: 'Refresh to see latest')
/// ```
class DSStateSurface extends StatelessWidget {
  /// The type of state being rendered.
  final DSStateType stateType;

  /// Icon displayed at the top of the state surface.
  final IconData? icon;

  /// Primary message (required — must be informative, not decorative).
  final String title;

  /// Optional secondary explanation or guidance.
  final String? subtitle;

  /// Optional action button (e.g., retry, create, open).
  final String? actionLabel;

  /// Callback when the action button is pressed.
  final VoidCallback? onAction;

  /// Accent color override. Defaults are derived from [stateType].
  final Color? accentColor;

  /// Whether to compact the surface into a smaller layout.
  /// Useful for inline lane columns or small panels.
  final bool compact;

  const DSStateSurface({
    super.key,
    required this.stateType,
    this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.accentColor,
    this.compact = false,
  });

  /// Convenience constructor for the empty state.
  const DSStateSurface.empty({
    super.key,
    this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.accentColor,
    this.compact = false,
  }) : stateType = DSStateType.empty;

  /// Convenience constructor for the loading state.
  const DSStateSurface.loading({
    super.key,
    this.icon,
    this.title = 'Loading...',
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.accentColor,
    this.compact = false,
  }) : stateType = DSStateType.loading;

  /// Convenience constructor for the error state.
  const DSStateSurface.error({
    super.key,
    this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel = 'Retry',
    this.onAction,
    this.accentColor,
    this.compact = false,
  }) : stateType = DSStateType.error;

  /// Convenience constructor for the disabled state.
  ///
  /// Use when a feature or content area is intentionally inactive.
  const DSStateSurface.disabled({
    super.key,
    this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.accentColor,
    this.compact = false,
  }) : stateType = DSStateType.disabled;

  /// Convenience constructor for the stale state.
  ///
  /// Use when data exists but is outdated and needs refresh.
  const DSStateSurface.stale({
    super.key,
    this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel = 'Refresh',
    this.onAction,
    this.accentColor,
    this.compact = false,
  }) : stateType = DSStateType.stale;

  /// Convenience constructor for the degraded state.
  ///
  /// Use when content is partially available but impaired.
  const DSStateSurface.degraded({
    super.key,
    this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.accentColor,
    this.compact = false,
  }) : stateType = DSStateType.degraded;

  /// Convenience constructor for the excluded state.
  ///
  /// Use when content was filtered out or excluded by governance rules.
  const DSStateSurface.excluded({
    super.key,
    this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.accentColor,
    this.compact = false,
  }) : stateType = DSStateType.excluded;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = accentColor ?? _defaultColor;
    final effectiveIcon = icon ?? _defaultIcon;
    final iconSize = compact ? 24.0 : 40.0;
    final titleStyle = compact
        ? DSTypography.bodyMedium
        : DSTypography.headingSmall;

    return Semantics(
      container: true,
      label: _semanticLabel,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(compact ? DSSpacing.md : DSSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon or loading indicator
              if (stateType == DSStateType.loading)
                SizedBox(
                  width: iconSize,
                  height: iconSize,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(effectiveColor),
                  ),
                )
              else
                DSIcon(effectiveIcon, color: effectiveColor, size: iconSize),

              SizedBox(height: compact ? DSSpacing.sm : DSSpacing.md),

              // Title — always present, always meaningful
              Text(
                title,
                style: titleStyle.copyWith(
                  color: stateType == DSStateType.loading
                      ? DSColors.textSecondary
                      : DSColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),

              // Subtitle — optional guidance
              if (subtitle != null) ...[
                const SizedBox(height: DSSpacing.xs),
                Text(
                  subtitle!,
                  style: DSTypography.bodySmall.copyWith(
                    color: DSColors.textTertiary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              // Action button — optional
              if (actionLabel != null && onAction != null) ...[
                SizedBox(height: compact ? DSSpacing.sm : DSSpacing.md),
                _StateActionButton(
                  label: actionLabel!,
                  color: effectiveColor,
                  onPressed: onAction!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Semantic label for screen readers.
  /// Maps each state type to an accessible description.
  String get _semanticLabel {
    switch (stateType) {
      case DSStateType.empty:
        return 'Empty: no data available';
      case DSStateType.loading:
        return 'Loading: fetching data';
      case DSStateType.error:
        return 'Error: operation failed';
      case DSStateType.disabled:
        return 'Disabled: intentionally off';
      case DSStateType.stale:
        return 'Stale: needs refresh';
      case DSStateType.degraded:
        return 'Degraded: reduced quality';
      case DSStateType.excluded:
        return 'Excluded: outside scope';
    }
  }

  Color get _defaultColor {
    switch (stateType) {
      case DSStateType.empty:
        return DSColors.textTertiary;
      case DSStateType.loading:
        return DSColors.accentCyan;
      case DSStateType.error:
        return DSColors.statusError;
      case DSStateType.disabled:
        return DSColors.textDisabled;
      case DSStateType.stale:
        return DSColors.statusStale;
      case DSStateType.degraded:
        return DSColors.statusDegraded;
      case DSStateType.excluded:
        return DSColors.statusExcluded;
    }
  }

  IconData get _defaultIcon {
    switch (stateType) {
      case DSStateType.empty:
        return Icons.inbox_outlined;
      case DSStateType.loading:
        return Icons.hourglass_empty; // fallback; usually indicator is used
      case DSStateType.error:
        return DSIcons.error;
      case DSStateType.disabled:
        return Icons.block;
      case DSStateType.stale:
        return Icons.update;
      case DSStateType.degraded:
        return Icons.warning_amber;
      case DSStateType.excluded:
        return Icons.remove_circle_outline;
    }
  }
}

/// Content and operational state types.
enum DSStateType {
  /// No data available — the dataset is empty.
  empty,

  /// Data is being fetched or parsed.
  loading,

  /// A fetch or parse operation failed.
  error,

  /// Feature or content is intentionally disabled.
  disabled,

  /// Data exists but is outdated and needs refresh.
  stale,

  /// Content is partially available but impaired.
  degraded,

  /// Content was filtered out or excluded by governance rules.
  excluded,
}

class _StateActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _StateActionButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      hint: 'Tap to $label',
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color.withValues(alpha: 0.5)),
          foregroundColor: color,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(
            horizontal: DSSpacing.md,
            vertical: DSSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DSRadii.md),
          ),
        ),
        child: Text(
          label,
          style: DSTypography.labelMedium.copyWith(color: color),
        ),
      ),
    );
  }
}
