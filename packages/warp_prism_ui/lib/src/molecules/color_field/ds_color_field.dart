import 'package:flutter/material.dart';
import '../../atoms/atoms.dart';
import '../../tokens/tokens.dart';
import '../ds_interactive_surface.dart';
import 'hex_color_parser.dart';

/// ASW Observatory Molecule — Color Field
///
/// A validated hex color text field with inline preset swatches, eyedropper API hook,
/// clear button, and accessible state matrix coverage (default, hover, focus, disabled, error).
/// Composes [DSTextField] for atom-consistent text input behavior and styling.
class DSColorField extends StatefulWidget {
  /// Currently selected color value.
  final Color? value;

  /// Label displayed above the input field.
  final String? label;

  /// Placeholder text when field is empty (defaults to '#RRGGBB').
  final String? hint;

  /// Helper text displayed below the field when no error is present.
  final String? helperText;

  /// Custom error message. If provided or if typed input is invalid hex,
  /// the molecule enters the error state.
  final String? errorText;

  /// Callback fired when the valid color value changes.
  final ValueChanged<Color?>? onChanged;

  /// Callback fired when user submits the field.
  final ValueChanged<Color?>? onSubmitted;

  /// Eyedropper callback hook. API surface placeholder for platform-native eyedropper.
  final VoidCallback? onEyedropperTap;

  /// Preset swatch colors displayed below the text input.
  /// Defaults to [DSColorField.defaultPresets].
  final List<Color>? presetSwatches;

  /// Whether the preset swatch row is visible. Defaults to `true`.
  final bool showSwatches;

  /// Whether the clear button is shown when input is non-empty. Defaults to `true`.
  final bool showClear;

  /// Whether user interaction is enabled. Defaults to `true`.
  final bool enabled;

  /// Focus node for external focus management.
  final FocusNode? focusNode;

  /// Controller for external text management.
  final TextEditingController? controller;

  /// Semantic label for screen readers.
  final String? semanticsLabel;

  /// Default preset swatches provided by the design system.
  static List<Color> get defaultPresets => [
    DSColors.accentBlue,
    DSColors.accentCyan,
    DSColors.accentViolet,
    DSColors.accentGold,
    DSColors.statusSuccess,
    DSColors.statusWarning,
    DSColors.statusError,
    DSColors.textPrimary,
    DSColors.obsidianElevated,
    DSColors.obsidianBase,
  ];

  const DSColorField({
    super.key,
    this.value,
    this.label,
    this.hint = '#RRGGBB',
    this.helperText,
    this.errorText,
    this.onChanged,
    this.onSubmitted,
    this.onEyedropperTap,
    this.presetSwatches,
    this.showSwatches = true,
    this.showClear = true,
    this.enabled = true,
    this.focusNode,
    this.controller,
    this.semanticsLabel,
  });

  @override
  State<DSColorField> createState() => _DSColorFieldState();
}

class _DSColorFieldState extends State<DSColorField> {
  late TextEditingController _textController;
  FocusNode? _internalFocusNode;

  FocusNode get _effectiveFocusNode =>
      widget.focusNode ?? (_internalFocusNode ??= FocusNode());

  bool _invalidHexTyped = false;

  @override
  void initState() {
    super.initState();
    _textController =
        widget.controller ??
        TextEditingController(
          text: widget.value != null
              ? HexColorParser.formatHexColor(widget.value!)
              : '',
        );
  }

  @override
  void didUpdateWidget(DSColorField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      if (oldWidget.controller == null) {
        _textController.dispose();
      }
      _textController = widget.controller ?? TextEditingController();
    }

    if (widget.value != oldWidget.value) {
      final currentParsed = HexColorParser.tryParseHexColor(
        _textController.text,
      );
      if (currentParsed != widget.value) {
        final newText = widget.value != null
            ? HexColorParser.formatHexColor(widget.value!)
            : '';
        _textController.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: newText.length),
        );
        _invalidHexTyped = false;
      }
    }

    if (widget.focusNode != oldWidget.focusNode) {
      if (oldWidget.focusNode == null) {
        _internalFocusNode?.dispose();
        _internalFocusNode = null;
      }
    }
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _internalFocusNode?.dispose();
    }
    if (widget.controller == null) {
      _textController.dispose();
    }
    super.dispose();
  }

  void _handleTextChanged(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      setState(() {
        _invalidHexTyped = false;
      });
      widget.onChanged?.call(null);
      return;
    }

    final parsed = HexColorParser.tryParseHexColor(trimmed);
    if (parsed != null) {
      setState(() {
        _invalidHexTyped = false;
      });
      widget.onChanged?.call(parsed);
    } else {
      setState(() {
        _invalidHexTyped = true;
      });
    }
  }

  void _handleTextSubmitted(String raw) {
    final parsed = HexColorParser.tryParseHexColor(raw);
    widget.onSubmitted?.call(parsed);
  }

  void _handleSwatchSelected(Color color) {
    if (!widget.enabled) return;
    final formatted = HexColorParser.formatHexColor(color);
    setState(() {
      _textController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
      _invalidHexTyped = false;
    });
    widget.onChanged?.call(color);
  }

  void _handleClear() {
    if (!widget.enabled) return;
    setState(() {
      _textController.clear();
      _invalidHexTyped = false;
    });
    widget.onChanged?.call(null);
  }

  @override
  Widget build(BuildContext context) {
    final parsedColor =
        HexColorParser.tryParseHexColor(_textController.text) ?? widget.value;

    final effectiveErrorText =
        widget.errorText ??
        (_invalidHexTyped
            ? 'Invalid hex color (#RGB, #RRGGBB, #AARRGGBB)'
            : null);

    final swatches = widget.presetSwatches ?? DSColorField.defaultPresets;

    final hasSuffixActions =
        (widget.onEyedropperTap != null) ||
        (widget.showClear && _textController.text.isNotEmpty);

    Widget textFieldWidget = DSTextField(
      controller: _textController,
      focusNode: _effectiveFocusNode,
      enabled: widget.enabled,
      label: widget.label,
      hint: widget.hint,
      helperText: widget.helperText,
      errorText: effectiveErrorText,
      semanticsLabel:
          widget.semanticsLabel ?? widget.label ?? 'Color hex field',
      onChanged: _handleTextChanged,
      onSubmitted: _handleTextSubmitted,
      prefix: _ColorPreviewSquare(color: parsedColor),
      suffix: hasSuffixActions
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.onEyedropperTap != null)
                  _FieldActionButton(
                    icon: Icons.colorize,
                    semanticLabel: 'Activate color eyedropper',
                    enabled: widget.enabled,
                    onTap: widget.onEyedropperTap,
                  ),
                if (widget.showClear && _textController.text.isNotEmpty)
                  _FieldActionButton(
                    icon: Icons.close,
                    semanticLabel: 'Clear color field',
                    enabled: widget.enabled,
                    onTap: _handleClear,
                  ),
              ],
            )
          : null,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        textFieldWidget,
        if (widget.showSwatches && swatches.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.sm),
          Wrap(
            spacing: DSSpacing.xs,
            runSpacing: DSSpacing.xs,
            children: swatches.map((color) {
              final isSelected =
                  parsedColor != null &&
                  color.r == parsedColor.r &&
                  color.g == parsedColor.g &&
                  color.b == parsedColor.b &&
                  color.a == parsedColor.a;
              return _SwatchItem(
                color: color,
                isSelected: isSelected,
                enabled: widget.enabled,
                onTap: () => _handleSwatchSelected(color),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}

class _ColorPreviewSquare extends StatelessWidget {
  final Color? color;

  const _ColorPreviewSquare({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: color ?? DSColors.transparent,
        borderRadius: BorderRadius.circular(DSRadii.xs),
        border: Border.all(color: DSColors.borderSubtle, width: 1),
      ),
      child: color == null
          ? const Center(
              child: Icon(Icons.block, size: 14, color: DSColors.textTertiary),
            )
          : null,
    );
  }
}

class _FieldActionButton extends StatelessWidget {
  final IconData icon;
  final String semanticLabel;
  final bool enabled;
  final VoidCallback? onTap;

  const _FieldActionButton({
    required this.icon,
    required this.semanticLabel,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled && onTap != null,
      label: semanticLabel,
      child: SizedBox.square(
        dimension: 48,
        child: Material(
          color: DSColors.transparent,
          child: InkWell(
            onTap: enabled ? onTap : null,
            borderRadius: BorderRadius.circular(DSRadii.sm),
            child: Center(
              child: DSIcon.small(
                icon,
                color: enabled ? DSColors.textSecondary : DSColors.textDisabled,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SwatchItem extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final bool enabled;
  final VoidCallback onTap;

  const _SwatchItem({
    required this.color,
    required this.isSelected,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hexString = HexColorParser.formatHexColor(color);

    return SizedBox.square(
      dimension: 48,
      child: DSInteractiveSurface(
        semanticLabel: 'Color swatch $hexString',
        selected: isSelected,
        onTap: enabled ? onTap : null,
        child: Center(
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(DSRadii.sm),
              border: Border.all(
                color: isSelected ? DSColors.accentBlue : DSColors.borderSubtle,
                width: isSelected ? 2.0 : 1.0,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: DSColors.focusRing,
                        blurRadius: 6,
                        spreadRadius: 0,
                      ),
                    ]
                  : null,
            ),
            child: isSelected
                ? Center(
                    child: Icon(
                      Icons.check,
                      size: 16,
                      color: color.computeLuminance() > 0.5
                          ? DSColors.obsidianDeep
                          : DSColors.textPrimary,
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}
