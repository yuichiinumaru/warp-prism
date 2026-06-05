import 'package:flutter/material.dart';
import '../tokens/tokens.dart';
import '../atoms/atoms.dart';

/// ASW Observatory Molecule - Filter Chip Group
/// 
/// Horizontal scrollable group of filter chips
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (int i = 0; i < options.length; i++) ...[
            if (i > 0) const SizedBox(width: DSSpacing.xs),
            _FilterChip(
              option: options[i],
              isSelected: selected.contains(options[i].value),
              showCount: showCount,
              onTap: () => onToggle?.call(options[i].value),
            ),
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final color = option.color ?? DSColors.accentCyan;
    final bgColor = isSelected
        ? color.withOpacity(0.2)
        : DSColors.obsidianElevated;
    final borderColor = isSelected
        ? color.withOpacity(0.5)
        : DSColors.borderSubtle;
    final textColor = isSelected ? color : DSColors.textSecondary;
    final iconColor = isSelected ? color : DSColors.textTertiary;

    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: DSMotion.fast,
          height: 28,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(DSRadii.chip),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (option.icon != null) ...[
                Icon(option.icon, size: 14, color: iconColor),
                const SizedBox(width: 6),
              ],
              Text(
                option.label,
                style: DSTypography.labelMedium.copyWith(color: textColor),
              ),
              if (showCount && option.count != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? color.withOpacity(0.3) 
                        : DSColors.obsidianHover,
                    borderRadius: BorderRadius.circular(DSRadii.full),
                  ),
                  child: Text(
                    option.count.toString(),
                    style: DSTypography.labelSmall.copyWith(
                      color: isSelected ? color : DSColors.textTertiary,
                    ),
                  ),
                ),
              ],
            ],
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
