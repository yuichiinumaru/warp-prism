import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../tokens/tokens.dart';

/// ASW Observatory Atom - Chip
///
/// Interactive tag/filter element with keyboard focus support.
class DSChip extends StatefulWidget {
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

  @override
  State<DSChip> createState() => _DSChipState();
}

class _DSChipState extends State<DSChip> {
  bool _isFocused = false;
  final FocusNode _focusNode = FocusNode();

  double get _height {
    switch (widget.size) {
      case DSChipSize.small: return 24;
      case DSChipSize.medium: return 28;
      case DSChipSize.large: return 32;
    }
  }

  double get _fontSize {
    switch (widget.size) {
      case DSChipSize.small: return 11;
      case DSChipSize.medium: return 12;
      case DSChipSize.large: return 13;
    }
  }

  double get _iconSize {
    switch (widget.size) {
      case DSChipSize.small: return 14;
      case DSChipSize.medium: return 16;
      case DSChipSize.large: return 18;
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = widget.color ?? DSColors.accentCyan;
    final isInteractive = widget.enabled && widget.onTap != null;
    
    final bgColor = widget.selected
        ? effectiveColor.withOpacity(0.2)
        : DSColors.obsidianElevated;
    
    final borderColor = widget.selected
        ? effectiveColor.withOpacity(0.5)
        : DSColors.borderSubtle;
    
    final textColor = widget.selected
        ? effectiveColor
        : (widget.enabled ? DSColors.textSecondary : DSColors.textDisabled);
    
    final iconColor = widget.selected
        ? effectiveColor
        : (widget.enabled ? DSColors.textTertiary : DSColors.textDisabled);

    return Semantics(
      label: widget.label,
      button: isInteractive,
      selected: widget.selected,
      enabled: widget.enabled,
      child: Focus(
        focusNode: _focusNode,
        onFocusChange: (focused) => setState(() => _isFocused = focused),
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent && isInteractive) {
            if (event.logicalKey == LogicalKeyboardKey.enter ||
                event.logicalKey == LogicalKeyboardKey.space) {
              widget.onTap?.call();
              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        child: GestureDetector(
          onTap: widget.enabled ? widget.onTap : null,
          child: MouseRegion(
            cursor: isInteractive ? SystemMouseCursors.click : SystemMouseCursors.basic,
            child: AnimatedContainer(
              duration: DSMotion.fast,
              height: _height,
              padding: EdgeInsets.symmetric(
                horizontal: widget.size == DSChipSize.small ? 8 : 10,
              ),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(DSRadii.chip),
                border: Border.all(
                  color: _isFocused
                      ? DSColors.accentCyan.withOpacity(0.5)
                      : borderColor,
                  width: _isFocused ? 2 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.leadingIcon != null) ...[
                    Icon(widget.leadingIcon, size: _iconSize, color: iconColor),
                    SizedBox(width: widget.size == DSChipSize.small ? 4 : 6),
                  ],
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: _fontSize,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                      height: 1,
                    ),
                  ),
                  if (widget.trailingIcon != null) ...[
                    SizedBox(width: widget.size == DSChipSize.small ? 4 : 6),
                    GestureDetector(
                      onTap: widget.onTrailingTap,
                      child: Icon(widget.trailingIcon, size: _iconSize - 2, color: iconColor),
                    ),
                  ],
                ],
              ),
            ),
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
