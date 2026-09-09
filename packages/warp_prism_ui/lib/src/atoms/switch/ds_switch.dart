import 'package:flutter/material.dart';
import '../../molecules/ds_interactive_surface.dart';
import '../../theme/ds_theme.dart';
import '../../tokens/tokens.dart';
import '../ds_text.dart';

/// ASW Observatory Atom - Switch / Toggle
///
/// Obsidian dark glass track, blue active fill (`DSColors.accentBlue`), smooth thumb transition,
/// optional label, disabled state, and 48×48 minimum touch target.
class DSSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;
  final bool enabled;
  final FocusNode? focusNode;
  final String? semanticLabel;

  const DSSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.label,
    this.enabled = true,
    this.focusNode,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final isInteractive = enabled && onChanged != null;
    final activeAccent = DSTheme.accentOf(context);

    final trackColor = value ? activeAccent : DSColors.obsidianBase;
    final borderColor = value
        ? activeAccent.withValues(alpha: 0.5)
        : DSColors.borderDefault;
    final thumbColor = value ? DSColors.obsidianDeep : DSColors.textPrimary;

    final trackWidget = AnimatedContainer(
      duration: DSMotion.normal,
      curve: DSMotion.standard,
      width: 44,
      height: 24,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: trackColor,
        borderRadius: BorderRadius.circular(DSRadii.full),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: AnimatedAlign(
        duration: DSMotion.normal,
        curve: DSMotion.standard,
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(color: thumbColor, shape: BoxShape.circle),
        ),
      ),
    );

    Widget content;
    if (label != null) {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          trackWidget,
          const SizedBox(width: DSSpacing.sm),
          DSText.labelMedium(
            label!,
            color: isInteractive ? DSColors.textPrimary : DSColors.textDisabled,
          ),
        ],
      );
    } else {
      content = trackWidget;
    }

    if (!isInteractive) {
      content = Opacity(opacity: 0.5, child: content);
    }

    return DSInteractiveSurface(
      semanticLabel: semanticLabel ?? label ?? 'Switch',
      semanticValue: value ? 'on' : 'off',
      selected: value,
      onTap: isInteractive ? () => onChanged!(!value) : null,
      focusNode: focusNode,
      child: Center(widthFactor: 1.0, heightFactor: 1.0, child: content),
    );
  }
}
