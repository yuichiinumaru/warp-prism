import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../tokens/tokens.dart';

/// ASW Observatory Molecule - Filter Chip Group
///
/// Horizontal scrollable group of filter chips.
/// Each chip supports keyboard focus and activation.
class DSFilterChipGroup extends StatelessWidget {
  final List<DSFilterOption> options;
  final Set<String> selected;
  final ValueChanged<String>? onToggle;
  final bool allowMultiple;
  final bool showCount;

  const DSFilterChipGroup({
    super.key,
    required this.options,
    required this.selected,
    this.onToggle,
    this.allowMultiple = true,
    this.showCount = true,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Filter options',
      explicitChildNodes: true,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (int i = 0; i < options.length; i++) ...[
              if (i > 0) const SizedBox(width: DSSpacing.xs),
              _FilterChip(
                option: options[i],
                isSelected: selected.contains(options[i].value),
                showCount: showCount,
                // Null onToggle = non-interactive: no onTap, not a button.
                onTap: onToggle == null
                    ? null
                    : () => onToggle!(options[i].value),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatefulWidget {
  final DSFilterOption option;
  final bool isSelected;
  final bool showCount;
  final VoidCallback? onTap;

  const _FilterChip({
    required this.option,
    required this.isSelected,
    required this.showCount,
    this.onTap,
  });

  @override
  State<_FilterChip> createState() => _FilterChipState();
}

class _FilterChipState extends State<_FilterChip> {
  bool _isFocused = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.option.color ?? DSColors.accentBlue;
    final bgColor = widget.isSelected
        ? color.withValues(alpha: 0.2)
        : DSColors.obsidianElevated;
    final borderColor = widget.isSelected
        ? color.withValues(alpha: 0.5)
        : DSColors.borderSubtle;
    final textColor = widget.isSelected ? color : DSColors.textSecondary;
    final iconColor = widget.isSelected ? color : DSColors.textTertiary;

    final interactive = widget.onTap != null;

    return Semantics(
      label: widget.option.label,
      button: interactive,
      selected: widget.isSelected,
      explicitChildNodes: true,
      child: Focus(
        focusNode: _focusNode,
        canRequestFocus: interactive,
        onFocusChange: (focused) => setState(() => _isFocused = focused),
        onKeyEvent: (node, event) {
          if (!interactive) return KeyEventResult.ignored;
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.enter ||
                event.logicalKey == LogicalKeyboardKey.space) {
              widget.onTap?.call();
              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        child: GestureDetector(
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            alignment: Alignment.center,
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            child: MouseRegion(
              cursor: interactive
                  ? SystemMouseCursors.click
                  : SystemMouseCursors.basic,
              child: ExcludeSemantics(
                child: AnimatedContainer(
                  duration: DSMotion.fast,
                  height: 28,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(DSRadii.chip),
                    border: Border.all(
                      color: _isFocused ? DSColors.focusRing : borderColor,
                      width: _isFocused ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.option.icon != null) ...[
                        Icon(widget.option.icon, size: 14, color: iconColor),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        widget.option.label,
                        style: DSTypography.labelMedium.copyWith(
                          color: textColor,
                        ),
                      ),
                      if (widget.showCount && widget.option.count != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: widget.isSelected
                                ? color.withValues(alpha: 0.3)
                                : DSColors.obsidianHover,
                            borderRadius: BorderRadius.circular(DSRadii.full),
                          ),
                          child: Text(
                            widget.option.count.toString(),
                            style: DSTypography.labelSmall.copyWith(
                              color: widget.isSelected
                                  ? color
                                  : DSColors.textTertiary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DSFilterOption {
  final String value;
  final String label;
  final IconData? icon;
  final Color? color;
  final int? count;

  const DSFilterOption({
    required this.value,
    required this.label,
    this.icon,
    this.color,
    this.count,
  });
}
