import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../atoms/atoms.dart';
import '../../tokens/tokens.dart';
import '../ds_interactive_surface.dart';
import '../ds_state_surface.dart';

/// An option item within a [DSSelect] dropdown.
class DSSelectItem<T> {
  /// Unique identifier or typed value for the option.
  final T value;

  /// Human-readable label displayed in the dropdown.
  final String label;

  /// Optional icon displayed beside the label.
  final IconData? icon;

  /// Whether this option is disabled and non-selectable.
  final bool disabled;

  /// Optional subtitle or helper text for the option.
  final String? subtitle;

  const DSSelectItem({
    required this.value,
    required this.label,
    this.icon,
    this.disabled = false,
    this.subtitle,
  });
}

/// Convenience alias matching [DSSelectItem].
typedef DSSelectOption<T> = DSSelectItem<T>;

/// ASW Observatory Molecule - Select / Dropdown
///
/// Obsidian dark glass styled dropdown widget supporting options, placeholder,
/// label, clear button, disabled state, error state, and optional searchable mode.
class DSSelect<T> extends StatefulWidget {
  /// Currently selected value.
  final T? value;

  /// List of available dropdown options.
  final List<DSSelectItem<T>> options;

  /// Callback when a new option is selected (or cleared).
  final ValueChanged<T?>? onChanged;

  /// Optional label text rendered above the select trigger.
  final String? label;

  /// Placeholder text displayed when [value] is null.
  final String? placeholder;

  /// Error text displayed below the select trigger.
  final String? errorText;

  /// Helper text displayed below the trigger when there is no error.
  final String? helperText;

  /// Whether the select trigger is enabled.
  final bool enabled;

  /// Whether the dropdown popup includes a search filter field.
  final bool searchable;

  /// Icon rendered at the start of the trigger box.
  final IconData? prefixIcon;

  /// Placeholder text for the search input in searchable mode.
  final String? searchPlaceholder;

  /// Whether a clear button appears when a value is selected.
  final bool clearable;

  /// Callback when clear button is pressed.
  final VoidCallback? onClear;

  /// Custom focus node for the select trigger.
  final FocusNode? focusNode;

  /// Semantics label for accessibility.
  final String? semanticsLabel;

  const DSSelect({
    super.key,
    this.value,
    required this.options,
    this.onChanged,
    this.label,
    this.placeholder = 'Select an option...',
    this.errorText,
    this.helperText,
    this.enabled = true,
    this.searchable = false,
    this.prefixIcon,
    this.searchPlaceholder = 'Search options...',
    this.clearable = false,
    this.onClear,
    this.focusNode,
    this.semanticsLabel,
  });

  @override
  State<DSSelect<T>> createState() => _DSSelectState<T>();
}

class _DSSelectState<T> extends State<DSSelect<T>> {
  late FocusNode _effectiveFocusNode;
  FocusNode? _internalFocusNode;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  bool _isFocused = false;

  FocusNode? _popupFocusNode;
  FocusNode? _searchFocusNode;
  TextEditingController? _searchController;

  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _initFocusNode();
  }

  void _initFocusNode() {
    _effectiveFocusNode = widget.focusNode ?? (_internalFocusNode = FocusNode());
    _effectiveFocusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(DSSelect<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      _effectiveFocusNode.removeListener(_handleFocusChange);
      if (oldWidget.focusNode == null) {
        _internalFocusNode?.dispose();
        _internalFocusNode = null;
      }
      _initFocusNode();
    }
  }

  void _handleFocusChange() {
    if (!mounted || _isDisposed) return;
    setState(() {
      _isFocused = _effectiveFocusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _closePopup();
    _effectiveFocusNode.removeListener(_handleFocusChange);
    _internalFocusNode?.dispose();
    super.dispose();
  }

  DSSelectItem<T>? get _selectedItem {
    if (widget.value == null) return null;
    for (final opt in widget.options) {
      if (opt.value == widget.value) return opt;
    }
    return null;
  }

  void _togglePopup() {
    if (!widget.enabled) return;
    if (_isOpen) {
      _closePopup();
    } else {
      _openPopup();
    }
  }

  void _openPopup() {
    if (_isOpen || !widget.enabled) return;

    final renderBox = context.findRenderObject() as RenderBox?;
    final size = renderBox?.size ?? Size.zero;

    _popupFocusNode = FocusNode();
    if (widget.searchable) {
      _searchFocusNode = FocusNode();
      _searchController = TextEditingController();
    }

    List<DSSelectItem<T>> filteredOptions = List.from(widget.options);

    int highlightedIndex = 0;
    if (widget.value != null) {
      final initialIdx = filteredOptions.indexWhere(
        (opt) => opt.value == widget.value && !opt.disabled,
      );
      if (initialIdx >= 0) {
        highlightedIndex = initialIdx;
      } else {
        final firstValid = filteredOptions.indexWhere((opt) => !opt.disabled);
        highlightedIndex = firstValid >= 0 ? firstValid : 0;
      }
    } else {
      final firstValid = filteredOptions.indexWhere((opt) => !opt.disabled);
      highlightedIndex = firstValid >= 0 ? firstValid : 0;
    }

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            // Tap outside barrier
            Positioned.fill(
              child: Semantics(
                label: 'Dismiss dropdown',
                button: true,
                onTap: _closePopup,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _closePopup,
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              targetAnchor: Alignment.bottomLeft,
              followerAnchor: Alignment.topLeft,
              offset: const Offset(0, 4),
              child: StatefulBuilder(
                builder: (context, setPopupState) {
                  void moveHighlight(int delta) {
                    if (filteredOptions.isEmpty) return;
                    int next = highlightedIndex;
                    for (int step = 0; step < filteredOptions.length; step++) {
                      next = (next + delta + filteredOptions.length) %
                          filteredOptions.length;
                      if (!filteredOptions[next].disabled) {
                        setPopupState(() {
                          highlightedIndex = next;
                        });
                        break;
                      }
                    }
                  }

                  void selectCurrent() {
                    if (highlightedIndex >= 0 &&
                        highlightedIndex < filteredOptions.length) {
                      final item = filteredOptions[highlightedIndex];
                      if (!item.disabled) {
                        widget.onChanged?.call(item.value);
                        _closePopup();
                      }
                    }
                  }

                  return FocusScope(
                    autofocus: true,
                    child: Focus(
                      focusNode: _popupFocusNode,
                      autofocus: true,
                      onKeyEvent: (node, event) {
                        if (event is KeyDownEvent) {
                          if (event.logicalKey == LogicalKeyboardKey.escape) {
                            _closePopup();
                            return KeyEventResult.handled;
                          } else if (event.logicalKey ==
                              LogicalKeyboardKey.arrowDown) {
                            moveHighlight(1);
                            return KeyEventResult.handled;
                          } else if (event.logicalKey ==
                              LogicalKeyboardKey.arrowUp) {
                            moveHighlight(-1);
                            return KeyEventResult.handled;
                          } else if (event.logicalKey ==
                                  LogicalKeyboardKey.enter ||
                              event.logicalKey == LogicalKeyboardKey.space ||
                              event.logicalKey ==
                                  LogicalKeyboardKey.numpadEnter) {
                            selectCurrent();
                            return KeyEventResult.handled;
                          }
                        }
                        return KeyEventResult.ignored;
                      },
                      child: Material(
                        type: MaterialType.transparency,
                        child: SizedBox(
                          width: size.width > 0 ? size.width : 280,
                          child: DSGlassPanel.modal(
                            padding: const EdgeInsets.symmetric(
                              vertical: DSSpacing.xs,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (widget.searchable) ...[
                                  Padding(
                                    padding: const EdgeInsets.all(DSSpacing.xs),
                                    child: DSTextField(
                                      controller: _searchController,
                                      focusNode: _searchFocusNode,
                                      hint: widget.searchPlaceholder,
                                      prefixIcon: Icons.search,
                                      autofocus: true,
                                      onChanged: (query) {
                                        setPopupState(() {
                                          filteredOptions = widget.options
                                              .where(
                                                (opt) => opt.label
                                                    .toLowerCase()
                                                    .contains(
                                                      query.toLowerCase(),
                                                    ),
                                              )
                                              .toList();
                                          final firstValid = filteredOptions
                                              .indexWhere((opt) => !opt.disabled);
                                          highlightedIndex =
                                              firstValid >= 0 ? firstValid : 0;
                                        });
                                      },
                                    ),
                                  ),
                                  const DSDivider(),
                                ],
                                if (filteredOptions.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.all(DSSpacing.md),
                                    child: DSStateSurface.empty(
                                      title: 'No options match',
                                      compact: true,
                                    ),
                                  )
                                else
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxHeight: 280,
                                    ),
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      padding: EdgeInsets.zero,
                                      itemCount: filteredOptions.length,
                                      itemBuilder: (context, index) {
                                        final option = filteredOptions[index];
                                        final isSelected =
                                            option.value == widget.value;
                                        final isHighlighted =
                                            index == highlightedIndex;

                                        return _SelectOptionRow<T>(
                                          option: option,
                                          isSelected: isSelected,
                                          isHighlighted: isHighlighted,
                                          onTap: option.disabled
                                              ? null
                                              : () {
                                                  widget.onChanged
                                                      ?.call(option.value);
                                                  _closePopup();
                                                },
                                        );
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isOpen = true;
    });
  }

  void _closePopup() {
    if (_overlayEntry != null) {
      if (_overlayEntry!.mounted) {
        _overlayEntry!.remove();
      }
      _overlayEntry = null;
    }
    _popupFocusNode?.dispose();
    _popupFocusNode = null;
    _searchFocusNode?.dispose();
    _searchFocusNode = null;
    _searchController?.dispose();
    _searchController = null;

    if (_isOpen) {
      _isOpen = false;
      if (mounted && !_isDisposed) {
        setState(() {});
      }
    }
  }

  void _handleClear() {
    if (!widget.enabled) return;
    if (widget.onClear != null) {
      widget.onClear!();
    } else {
      widget.onChanged?.call(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    final selected = _selectedItem;

    final Color borderColor;
    final double borderWidth;
    if (hasError) {
      borderColor = DSColors.statusError;
      borderWidth = 1.0;
    } else if (_isOpen || _isFocused) {
      borderColor = DSColors.accentCyan;
      borderWidth = 2.0;
    } else {
      borderColor = DSColors.borderSubtle;
      borderWidth = 1.0;
    }

    final Color labelColor;
    if (hasError) {
      labelColor = DSColors.statusError;
    } else if (_isOpen || _isFocused) {
      labelColor = DSColors.accentCyan;
    } else {
      labelColor = DSColors.textSecondary;
    }

    final Color iconColor;
    if (hasError) {
      iconColor = DSColors.statusError;
    } else if (_isOpen || _isFocused) {
      iconColor = DSColors.accentCyan;
    } else {
      iconColor = DSColors.textTertiary;
    }

    final List<BoxShadow>? glowShadows;
    if (hasError) {
      glowShadows = [
        BoxShadow(
          color: DSColors.statusError.withValues(alpha: 0.3),
          blurRadius: 8,
          spreadRadius: 0,
        ),
      ];
    } else if (_isOpen || _isFocused) {
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

    final effectivePrefixIcon = widget.prefixIcon ?? selected?.icon;

    Widget triggerContainer = CompositedTransformTarget(
      link: _layerLink,
      child: Focus(
        focusNode: _effectiveFocusNode,
        canRequestFocus: widget.enabled,
        onKeyEvent: (node, event) {
          if (!widget.enabled) return KeyEventResult.ignored;
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.enter ||
                event.logicalKey == LogicalKeyboardKey.space ||
                event.logicalKey == LogicalKeyboardKey.arrowDown ||
                event.logicalKey == LogicalKeyboardKey.arrowUp) {
              _togglePopup();
              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        child: GestureDetector(
          onTap: _togglePopup,
          behavior: HitTestBehavior.opaque,
          child: MouseRegion(
            cursor: widget.enabled
                ? SystemMouseCursors.click
                : SystemMouseCursors.basic,
            child: AnimatedContainer(
              duration: DSMotion.fast,
              constraints: const BoxConstraints(minHeight: 48),
              padding: const EdgeInsets.symmetric(
                horizontal: DSSpacing.lg,
                vertical: DSSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: DSColors.obsidianElevated,
                borderRadius: BorderRadius.circular(DSRadii.input),
                border: Border.all(color: borderColor, width: borderWidth),
                boxShadow: glowShadows,
              ),
              child: Row(
                children: [
                  if (effectivePrefixIcon != null) ...[
                    DSIcon.small(
                      effectivePrefixIcon,
                      color: iconColor,
                    ),
                    const SizedBox(width: DSSpacing.sm),
                  ],
                  Expanded(
                    child: Text(
                      selected?.label ??
                          widget.placeholder ??
                          'Select an option...',
                      style: DSTypography.bodyMedium.copyWith(
                        color: !widget.enabled
                            ? DSColors.textDisabled
                            : (selected != null
                                ? DSColors.textPrimary
                                : DSColors.textTertiary),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (widget.clearable &&
                      widget.value != null &&
                      widget.enabled) ...[
                    Semantics(
                      button: true,
                      enabled: true,
                      label: 'Clear selection',
                      onTap: _handleClear,
                      child: GestureDetector(
                        onTap: _handleClear,
                        behavior: HitTestBehavior.opaque,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            minWidth: 48,
                            minHeight: 48,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(DSSpacing.xs),
                            child: DSIcon.small(
                              Icons.close,
                              color: iconColor,
                              semanticLabel: 'Clear selection',
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: DSSpacing.xs),
                  ],
                  DSIcon.small(
                    _isOpen
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: iconColor,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (!widget.enabled) {
      triggerContainer = Opacity(
        opacity: 0.5,
        child: triggerContainer,
      );
    }

    final semanticText = selected?.label ?? widget.placeholder ?? 'Select';

    return Semantics(
      button: true,
      enabled: widget.enabled,
      label: widget.semanticsLabel ?? widget.label ?? semanticText,
      value: selected?.label,
      child: Column(
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
          triggerContainer,
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
        ],
      ),
    );
  }
}

class _SelectOptionRow<T> extends StatelessWidget {
  final DSSelectItem<T> option;
  final bool isSelected;
  final bool isHighlighted;
  final VoidCallback? onTap;

  const _SelectOptionRow({
    required this.option,
    required this.isSelected,
    required this.isHighlighted,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor;
    if (isSelected) {
      bgColor = DSColors.accentCyan.withValues(alpha: 0.15);
    } else if (isHighlighted) {
      bgColor = DSColors.obsidianHover;
    } else {
      bgColor = DSColors.transparent;
    }

    final Color textColor;
    if (option.disabled) {
      textColor = DSColors.textDisabled;
    } else if (isSelected) {
      textColor = DSColors.accentCyan;
    } else {
      textColor = DSColors.textPrimary;
    }

    final Color iconColor = isSelected ? DSColors.accentCyan : textColor;

    return DSInteractiveSurface(
      semanticLabel: option.label,
      selected: isSelected,
      onTap: option.disabled ? null : onTap,
      child: Opacity(
        opacity: option.disabled ? 0.5 : 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DSSpacing.md,
            vertical: DSSpacing.sm,
          ),
          color: bgColor,
          child: Row(
            children: [
              if (option.icon != null) ...[
                DSIcon.small(
                  option.icon!,
                  color: iconColor,
                ),
                const SizedBox(width: DSSpacing.sm),
              ],
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.label,
                      style: DSTypography.bodyMedium.copyWith(color: textColor),
                    ),
                    if (option.subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        option.subtitle!,
                        style: DSTypography.bodySmall.copyWith(
                          color: DSColors.textTertiary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: DSSpacing.sm),
                const DSIcon.small(
                  Icons.check,
                  color: DSColors.accentCyan,
                  semanticLabel: 'Selected',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
