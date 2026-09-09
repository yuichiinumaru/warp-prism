import 'package:flutter/material.dart';
import '../../molecules/ds_interactive_surface.dart';
import '../../theme/ds_theme.dart';
import '../../tokens/tokens.dart';
import '../ds_glass_panel.dart';
import '../ds_glow_border.dart';
import '../ds_icon.dart';
import '../ds_text.dart';

/// Button visual variants.
enum DSButtonVariant { primary, secondary, outline, ghost, danger }

/// Button size presets.
enum DSButtonSize { sm, md, lg }

/// ASW Observatory Atom - Prism / DS Button
///
/// Obsidian glass aesthetic button atom supporting 5 visual variants
/// (primary, secondary, outline, ghost, danger), 3 size presets (sm, md, lg),
/// loading state, disabled state, leading/trailing icons, and WCAG minimum 48x48
/// touch target via [DSInteractiveSurface].
class DSButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final DSButtonVariant variant;
  final DSButtonSize size;
  final IconData? icon;
  final IconData? trailingIcon;
  final bool enabled;
  final bool isLoading;
  final FocusNode? focusNode;
  final String? semanticLabel;

  const DSButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = DSButtonVariant.primary,
    this.size = DSButtonSize.md,
    this.icon,
    this.trailingIcon,
    this.enabled = true,
    this.isLoading = false,
    this.focusNode,
    this.semanticLabel,
  });

  /// Named constructor for primary variant.
  const DSButton.primary({
    super.key,
    required this.label,
    this.onPressed,
    this.size = DSButtonSize.md,
    this.icon,
    this.trailingIcon,
    this.enabled = true,
    this.isLoading = false,
    this.focusNode,
    this.semanticLabel,
  }) : variant = DSButtonVariant.primary;

  /// Named constructor for secondary variant.
  const DSButton.secondary({
    super.key,
    required this.label,
    this.onPressed,
    this.size = DSButtonSize.md,
    this.icon,
    this.trailingIcon,
    this.enabled = true,
    this.isLoading = false,
    this.focusNode,
    this.semanticLabel,
  }) : variant = DSButtonVariant.secondary;

  /// Named constructor for outline variant.
  const DSButton.outline({
    super.key,
    required this.label,
    this.onPressed,
    this.size = DSButtonSize.md,
    this.icon,
    this.trailingIcon,
    this.enabled = true,
    this.isLoading = false,
    this.focusNode,
    this.semanticLabel,
  }) : variant = DSButtonVariant.outline;

  /// Named constructor for ghost variant.
  const DSButton.ghost({
    super.key,
    required this.label,
    this.onPressed,
    this.size = DSButtonSize.md,
    this.icon,
    this.trailingIcon,
    this.enabled = true,
    this.isLoading = false,
    this.focusNode,
    this.semanticLabel,
  }) : variant = DSButtonVariant.ghost;

  /// Named constructor for danger variant.
  const DSButton.danger({
    super.key,
    required this.label,
    this.onPressed,
    this.size = DSButtonSize.md,
    this.icon,
    this.trailingIcon,
    this.enabled = true,
    this.isLoading = false,
    this.focusNode,
    this.semanticLabel,
  }) : variant = DSButtonVariant.danger;

  bool get _isInteractive => enabled && !isLoading && onPressed != null;

  @override
  Widget build(BuildContext context) {
    final activeAccent = DSTheme.accentOf(context);

    final Color foregroundColor;
    switch (variant) {
      case DSButtonVariant.primary:
        foregroundColor = activeAccent;
      case DSButtonVariant.secondary:
      case DSButtonVariant.outline:
      case DSButtonVariant.ghost:
        foregroundColor = DSColors.textPrimary;
      case DSButtonVariant.danger:
        foregroundColor = DSColors.statusError;
    }

    final EdgeInsetsGeometry padding;
    final double iconSize;
    final DSTextVariant textVariant;
    final double spinnerSize;

    switch (size) {
      case DSButtonSize.sm:
        padding = const EdgeInsets.symmetric(
          horizontal: DSSpacing.md,
          vertical: DSSpacing.xs,
        );
        iconSize = 14.0;
        textVariant = DSTextVariant.labelSmall;
        spinnerSize = 14.0;
      case DSButtonSize.md:
        padding = const EdgeInsets.symmetric(
          horizontal: DSSpacing.lg,
          vertical: DSSpacing.sm,
        );
        iconSize = 16.0;
        textVariant = DSTextVariant.labelMedium;
        spinnerSize = 16.0;
      case DSButtonSize.lg:
        padding = const EdgeInsets.symmetric(
          horizontal: DSSpacing.xl,
          vertical: DSSpacing.md,
        );
        iconSize = 20.0;
        textVariant = DSTextVariant.labelLarge;
        spinnerSize = 20.0;
    }

    Widget content;
    if (isLoading) {
      content = SizedBox(
        width: spinnerSize,
        height: spinnerSize,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
        ),
      );
    } else {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            DSIcon(icon!, color: foregroundColor, size: iconSize),
            if (label.isNotEmpty) const SizedBox(width: DSSpacing.xs),
          ],
          if (label.isNotEmpty)
            DSText(label, variant: textVariant, color: foregroundColor),
          if (trailingIcon != null) ...[
            if (label.isNotEmpty || icon != null)
              const SizedBox(width: DSSpacing.xs),
            DSIcon(trailingIcon!, color: foregroundColor, size: iconSize),
          ],
        ],
      );
    }

    Widget surface;
    switch (variant) {
      case DSButtonVariant.primary:
        surface = DSGlowBorder(
          color: activeAccent,
          radius: DSRadii.button,
          width: 1,
          glowBlur: 6,
          child: DSGlassPanel.elevated(
            radius: DSRadii.button,
            padding: padding,
            child: content,
          ),
        );
      case DSButtonVariant.secondary:
        surface = DSGlassPanel.subtle(
          radius: DSRadii.button,
          padding: padding,
          child: content,
        );
      case DSButtonVariant.outline:
        surface = Container(
          padding: padding,
          decoration: BoxDecoration(
            color: DSColors.transparent,
            borderRadius: BorderRadius.circular(DSRadii.button),
            border: Border.all(color: DSColors.borderStrong, width: 1),
          ),
          child: content,
        );
      case DSButtonVariant.ghost:
        surface = Container(
          padding: padding,
          decoration: BoxDecoration(
            color: DSColors.transparent,
            borderRadius: BorderRadius.circular(DSRadii.button),
          ),
          child: content,
        );
      case DSButtonVariant.danger:
        surface = DSGlowBorder(
          color: DSColors.statusError,
          radius: DSRadii.button,
          width: 1,
          glowBlur: 6,
          child: DSGlassPanel.elevated(
            radius: DSRadii.button,
            padding: padding,
            child: content,
          ),
        );
    }

    if (!enabled) {
      surface = Opacity(opacity: 0.5, child: surface);
    }

    return DSInteractiveSurface(
      semanticLabel: semanticLabel ?? label,
      onTap: _isInteractive ? onPressed : null,
      focusNode: focusNode,
      child: Center(widthFactor: 1.0, heightFactor: 1.0, child: surface),
    );
  }
}
