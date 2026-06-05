import 'package:flutter/material.dart';
import '../tokens/tokens.dart';

/// ASW Observatory Atom - Chip
/// 
/// Interactive tag/filter element
class DSChip extends StatelessWidget {
  final String label;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final Color? color;
  final bool selected;
  final bool enabled;
  final VoidCallback? onTap;
  final VoidCallback? onTrailingTap;
  final DSChipSize size;

  const DSChip({
    super.key,
    required this.label,
    this.leadingIcon,
    this.trailingIcon,
    this.color,
    this.selected = false,
    this.enabled = true,
    this.onTap,
    this.onTrailingTap,
    this.size = DSChipSize.medium,
  });

  // === NAMED CONSTRUCTORS ===
  factory DSChip.assetKind(String kind, {bool selected = false, VoidCallback? onTap}) {
    return DSChip(
      label: kind,
      leadingIcon: _iconForAssetKind(kind),
      color: DSColors.forAssetKind(kind),
      selected: selected,
      onTap: onTap,
    );
  }
  
  factory DSChip.lane(String lane, {bool selected = false, VoidCallback? onTap}) {
    return DSChip(
      label: _labelForLane(lane),
      color: DSColors.forLane(lane),
      selected: selected,
      onTap: onTap,
    );
  }
  
  factory DSChip.governance(String canonicity, {bool selected = false, VoidCallback? onTap}) {
    return DSChip(
      label: _labelForCanonicity(canonicity),
      color: DSColors.forCanonicity(canonicity),
      selected: selected,
      onTap: onTap,
    );
  }
  
  factory DSChip.removable(String label, {Color? color, required VoidCallback onRemove}) {
    return DSChip(
      label: label,
      color: color,
      trailingIcon: Icons.close,
      onTrailingTap: onRemove,
    );
  }

  static IconData _iconForAssetKind(String kind) {
    switch (kind.toLowerCase()) {
      case 'agent': return Icons.smart_toy_outlined;
      case 'skill': return Icons.psychology_outlined;
      case 'workflow': return Icons.account_tree_outlined;
      case 'task': return Icons.task_outlined;
      case 'changelog': return Icons.article_outlined;
      default: return Icons.tag;
    }
  }

  static String _labelForLane(String lane) {
    switch (lane.toLowerCase()) {
      case '00-planning': return 'Planning';
      case '01-open': return 'Open';
      case '02-doing': return 'Doing';
      case '03-review': return 'Review';
      case '04-completed': return 'Completed';
      default: return lane;
    }
  }

  static String _labelForCanonicity(String canonicity) {
    switch (canonicity.toLowerCase()) {
      case 'parentcanonical': return 'Canonical';
      case 'childlocal': return 'Local';
      case 'generated': return 'Generated';
      case 'appendonly': return 'Append-Only';
      case 'archive': return 'Archive';
      case 'mock': return 'Mock';
      default: return canonicity;
    }
  }

  double get _height {
    switch (size) {
      case DSChipSize.small: return 24;
      case DSChipSize.medium: return 28;
      case DSChipSize.large: return 32;
    }
  }

  double get _fontSize {
    switch (size) {
      case DSChipSize.small: return 11;
      case DSChipSize.medium: return 12;
      case DSChipSize.large: return 13;
    }
  }

  double get _iconSize {
    switch (size) {
      case DSChipSize.small: return 14;
      case DSChipSize.medium: return 16;
      case DSChipSize.large: return 18;
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? DSColors.accentCyan;
    final isInteractive = enabled && onTap != null;
    
    final bgColor = selected
        ? effectiveColor.withOpacity(0.2)
        : DSColors.obsidianElevated;
    
    final borderColor = selected
        ? effectiveColor.withOpacity(0.5)
        : DSColors.borderSubtle;
    
    final textColor = selected
        ? effectiveColor
        : (enabled ? DSColors.textSecondary : DSColors.textDisabled);
    
    final iconColor = selected
        ? effectiveColor
        : (enabled ? DSColors.textTertiary : DSColors.textDisabled);

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: MouseRegion(
        cursor: isInteractive ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: AnimatedContainer(
          duration: DSMotion.fast,
          height: _height,
          padding: EdgeInsets.symmetric(
            horizontal: size == DSChipSize.small ? 8 : 10,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(DSRadii.chip),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leadingIcon != null) ...[
                Icon(leadingIcon, size: _iconSize, color: iconColor),
                SizedBox(width: size == DSChipSize.small ? 4 : 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: _fontSize,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                  height: 1,
                ),
              ),
              if (trailingIcon != null) ...[
                SizedBox(width: size == DSChipSize.small ? 4 : 6),
                GestureDetector(
                  onTap: onTrailingTap,
                  child: Icon(trailingIcon, size: _iconSize - 2, color: iconColor),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

enum DSChipSize {
  small,
  medium,
  large,
}
