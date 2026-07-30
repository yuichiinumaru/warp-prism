import 'package:flutter/material.dart';
import '../../molecules/ds_interactive_surface.dart';
import '../../tokens/tokens.dart';
import '../ds_glow_border.dart';
import '../ds_icon.dart';
import '../ds_text.dart';

/// ASW Observatory Atom - Checkbox
///
/// An obsidian dark glass checkbox widget with cyan checked fill (`DSColors.accentCyan`),
/// checkmark icon, tristate/indeterminate support, label placement, disabled state,
/// and 48x48 min touch target.
class DSCheckbox extends StatelessWidget {
  /// The current state of the checkbox (true = checked, false = unchecked, null = indeterminate).
  final bool? value;

  /// Callback when state changes. If null, the checkbox is disabled.
  final ValueChanged<bool?>? onChanged;

  /// Optional text label displayed next to the checkbox.
  final String? label;

  /// Whether the checkbox is enabled. Defaults to true.
  final bool enabled;

  /// Whether tristate mode is enabled (cycling false -> true -> null -> false).
  final bool tristate;

  /// Optional focus node for keyboard interaction.
  final FocusNode? focusNode;

  /// Optional custom semantic label for accessibility.
  final String? semanticLabel;

  const DSCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.enabled = true,
    this.tristate = false,
    this.focusNode,
    this.semanticLabel,
  });

  bool get _isInteractive => enabled && onChanged != null;

  void _handleTap() {
    if (!_isInteractive) return;

    final bool? newValue;
    if (tristate) {
      if (value == false) {
        newValue = true;
      } else if (value == true) {
        newValue = null;
      } else {
        newValue = false;
      }
    } else {
      if (value == true) {
        newValue = false;
      } else {
        newValue = true;
      }
    }

    onChanged?.call(newValue);
  }

  @override
  Widget build(BuildContext context) {
    final String semanticValueStr;
    if (value == true) {
      semanticValueStr = 'checked';
    } else if (value == false) {
      semanticValueStr = 'unchecked';
    } else {
      semanticValueStr = 'indeterminate';
    }

    final effectiveLabel = semanticLabel ?? label ?? 'Checkbox';

    Widget boxContent;
    if (value == true) {
      // Checked state: 20x20 outer box, DSGlowBorder cyan glow, filled cyan background, obsidian checkmark icon
      boxContent = DSGlowBorder(
        color: DSColors.accentCyan,
        radius: DSRadii.button,
        width: 1,
        glowBlur: 6,
        child: Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: DSColors.accentCyan,
            borderRadius: BorderRadius.circular(DSRadii.button - 1),
          ),
          child: const Center(
            child: DSIcon(
              Icons.check,
              size: 14,
              color: DSColors.obsidianDeep,
            ),
          ),
        ),
      );
    } else if (value == null) {
      // Indeterminate state: 20x20 box, subtle glass bg, cyan border, centered horizontal 10x2 bar
      boxContent = Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: DSColors.glassOverlay.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(DSRadii.button),
          border: Border.all(color: DSColors.accentCyan, width: 1),
        ),
        child: Center(
          child: Container(
            width: 10,
            height: 2,
            decoration: BoxDecoration(
              color: DSColors.accentCyan,
              borderRadius: BorderRadius.circular(DSRadii.xs),
            ),
          ),
        ),
      );
    } else {
      // Unchecked state: 20x20 box, subtle glass bg, borderSubtle
      boxContent = Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: DSColors.glassOverlay.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(DSRadii.button),
          border: Border.all(color: DSColors.borderSubtle, width: 1),
        ),
      );
    }

    return DSInteractiveSurface(
      semanticLabel: effectiveLabel,
      semanticValue: semanticValueStr,
      selected: value == true,
      onTap: _isInteractive ? _handleTap : null,
      focusNode: focusNode,
      padding: const EdgeInsets.all(DSSpacing.xs),
      alignment: Alignment.centerLeft,
      child: Opacity(
        opacity: _isInteractive ? 1.0 : 0.5,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            boxContent,
            if (label != null) ...[
              const SizedBox(width: DSSpacing.sm),
              DSText.labelMedium(
                label!,
                color: _isInteractive
                    ? DSColors.textPrimary
                    : DSColors.textSecondary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
