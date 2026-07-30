import 'package:flutter/material.dart';
import '../../tokens/tokens.dart';
import '../ds_icon.dart';
import '../ds_text.dart';

/// ASW Observatory Atom - Text Field
///
/// Obsidian-glass styled standalone text input component matching the ADS visual language.
/// Supports label, hint, helper text, error state, prefix/suffix icons, multiline/obscure text,
/// and disabled state.
class DSTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final String? suffixSemanticsLabel;
  final bool obscureText;
  final bool enabled;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool autofocus;
  final String? semanticsLabel;
  final String? prefixSemanticsLabel;

  /// When non-null AND [maxLength] is set, renders a custom character counter
  /// (`n / maxLength`) below the field. Replaces the suppressed default counter.
  final bool showCounter;

  const DSTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.suffixSemanticsLabel,
    this.obscureText = false,
    this.enabled = true,
    this.focusNode,
    this.keyboardType,
    this.onChanged,
    this.onSubmitted,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.autofocus = false,
    this.semanticsLabel,
    this.prefixSemanticsLabel,
    this.showCounter = true,
  });

  @override
  State<DSTextField> createState() => _DSTextFieldState();
}

class _DSTextFieldState extends State<DSTextField> {
  late TextEditingController _effectiveController;
  FocusNode? _internalFocusNode;

  FocusNode get _effectiveFocusNode =>
      widget.focusNode ?? (_internalFocusNode ??= FocusNode());

  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _effectiveController = widget.controller ?? TextEditingController();
    _effectiveFocusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(DSTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      if (oldWidget.controller == null) {
        _effectiveController.dispose();
      }
      _effectiveController = widget.controller ?? TextEditingController();
    }
    if (widget.focusNode != oldWidget.focusNode) {
      if (oldWidget.focusNode == null) {
        _internalFocusNode?.removeListener(_handleFocusChange);
        _internalFocusNode?.dispose();
        _internalFocusNode = null;
      } else {
        oldWidget.focusNode?.removeListener(_handleFocusChange);
      }
      _effectiveFocusNode.addListener(_handleFocusChange);
    }
  }

  void _handleFocusChange() {
    if (!mounted) return;
    setState(() {
      _isFocused = _effectiveFocusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    _effectiveFocusNode.removeListener(_handleFocusChange);
    if (widget.focusNode == null) {
      _internalFocusNode?.dispose();
    }
    if (widget.controller == null) {
      _effectiveController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    final isMultiline = !widget.obscureText &&
        (widget.maxLines == null || widget.maxLines! > 1);

    final Color borderColor;
    final double borderWidth;
    if (hasError) {
      borderColor = DSColors.statusError;
      borderWidth = 1.0;
    } else if (_isFocused) {
      borderColor = DSColors.accentCyan;
      borderWidth = 2.0;
    } else {
      borderColor = DSColors.borderSubtle;
      borderWidth = 1.0;
    }

    final Color labelColor;
    if (hasError) {
      labelColor = DSColors.statusError;
    } else if (_isFocused) {
      labelColor = DSColors.accentCyan;
    } else {
      labelColor = DSColors.textSecondary;
    }

    final Color iconColor;
    if (hasError) {
      iconColor = DSColors.statusError;
    } else if (_isFocused) {
      iconColor = DSColors.accentCyan;
    } else {
      iconColor = DSColors.textTertiary;
    }

    // Glow shadow for emphasis (focus + error) — luminous energy aesthetic.
    // Mirrors DSGlowBorder BoxShadow behavior (spread 0, blur 8/16).
    final List<BoxShadow>? glowShadows;
    if (hasError) {
      glowShadows = [
        BoxShadow(
          color: DSColors.statusError.withValues(alpha: 0.3),
          blurRadius: 8,
          spreadRadius: 0,
        ),
      ];
    } else if (_isFocused) {
      glowShadows = [
        BoxShadow(
          color: DSColors.accentCyan.withValues(alpha: 0.3),
          blurRadius: 8,
          spreadRadius: 0,
        ),
      ];
    } else {
      glowShadows = null;
    }

    Widget inputContainer = Container(
      constraints: BoxConstraints(
        minHeight: isMultiline ? 80 : 48,
      ),
      decoration: BoxDecoration(
        color: DSColors.obsidianElevated,
        borderRadius: BorderRadius.circular(DSRadii.input),
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: glowShadows,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: DSSpacing.lg,
        vertical: isMultiline ? DSSpacing.lg : DSSpacing.xs,
      ),
      child: Row(
        crossAxisAlignment:
            isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          if (widget.prefixIcon != null) ...[
            Padding(
              padding: EdgeInsets.only(top: isMultiline ? 2.0 : 0.0),
              child: DSIcon.small(
                widget.prefixIcon!,
                color: iconColor,
                semanticLabel: widget.prefixSemanticsLabel,
              ),
            ),
            const SizedBox(width: DSSpacing.sm),
          ],
          Expanded(
            child: Semantics(
              textField: true,
              enabled: widget.enabled,
              label: widget.semanticsLabel ??
                  widget.label ??
                  widget.hint ??
                  'Text field',
              hint: widget.hint,
              child: TextField(
                controller: _effectiveController,
                focusNode: _effectiveFocusNode,
                enabled: widget.enabled,
                obscureText: widget.obscureText,
                keyboardType: widget.keyboardType,
                autofocus: widget.autofocus,
                onChanged: widget.onChanged,
                onSubmitted: widget.onSubmitted,
                maxLines: widget.obscureText ? 1 : widget.maxLines,
                minLines: widget.minLines,
                maxLength: widget.maxLength,
                cursorColor: DSColors.accentCyan,
                style: DSTypography.bodyMedium.copyWith(
                  color: widget.enabled
                      ? DSColors.textPrimary
                      : DSColors.textDisabled,
                ),
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: DSTypography.bodyMedium.copyWith(
                    color: DSColors.textTertiary,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  counterText: '',
                ),
              ),
            ),
          ),
          if (widget.suffixIcon != null) ...[
            const SizedBox(width: DSSpacing.sm),
            Padding(
              padding: EdgeInsets.only(top: isMultiline ? 2.0 : 0.0),
              child: widget.onSuffixTap != null
                  ? _InteractiveSuffixIcon(
                      icon: widget.suffixIcon!,
                      color: iconColor,
                      onTap: widget.enabled ? widget.onSuffixTap : null,
                      semanticsLabel:
                          widget.suffixSemanticsLabel ?? 'Suffix action',
                    )
                  : DSIcon.small(
                      widget.suffixIcon!,
                      color: iconColor,
                      semanticLabel: widget.suffixSemanticsLabel,
                    ),
            ),
          ],
        ],
      ),
    );

    if (!widget.enabled) {
      inputContainer = Opacity(
        opacity: 0.5,
        child: inputContainer,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          DSText.labelSmall(
            widget.label!,
            color: labelColor,
          ),
          const SizedBox(height: DSSpacing.xs),
        ],
        inputContainer,
        if (hasError) ...[
          const SizedBox(height: DSSpacing.xs),
          DSText.bodySmall(
            widget.errorText!,
            color: DSColors.statusError,
          ),
        ] else if (widget.helperText != null &&
            widget.helperText!.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.xs),
          DSText.bodySmall(
            widget.helperText!,
            color: DSColors.textTertiary,
          ),
        ],
        if (widget.maxLength != null &&
            widget.showCounter &&
            !hasError) ...[
          const SizedBox(height: DSSpacing.xs),
          DSText.bodySmall(
            '${_effectiveController.text.length} / ${widget.maxLength}',
            color: DSColors.textTertiary,
          ),
        ],
      ],
    );
  }
}

class _InteractiveSuffixIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final String semanticsLabel;

  const _InteractiveSuffixIcon({
    required this.icon,
    required this.color,
    required this.onTap,
    required this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: semanticsLabel,
      child: SizedBox.square(
        dimension: 48,
        child: Material(
          color: DSColors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(DSRadii.sm),
            child: Center(
              child: DSIcon.small(icon, color: color),
            ),
          ),
        ),
      ),
    );
  }
}
