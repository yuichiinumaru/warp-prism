import 'package:flutter/material.dart';
import '../tokens/tokens.dart';

/// ASW Observatory Atom - Badge
///
/// Small status indicators with count or icon.
///
/// Supports semantic named constructors (success, warning, error, info),
/// an operational state factory for all 15 [DSOperationalState] values,
/// and size/variant customization.
class DSBadge extends StatelessWidget {
  final String? label;
  final int? count;
  final Color? color;
  final Color? backgroundColor;
  final DSBadgeVariant variant;
  final DSBadgeSize size;

  const DSBadge({
    super.key,
    this.label,
    this.count,
    this.color,
    this.backgroundColor,
    this.variant = DSBadgeVariant.filled,
    this.size = DSBadgeSize.medium,
  });

  // === NAMED CONSTRUCTORS ===
  const DSBadge.count(int this.count, {super.key, this.color, this.backgroundColor, this.size = DSBadgeSize.small})
      : label = null, variant = DSBadgeVariant.filled;

  const DSBadge.dot({super.key, this.color})
      : label = null, count = null, backgroundColor = null, variant = DSBadgeVariant.dot, size = DSBadgeSize.small;

  const DSBadge.success({super.key, this.label, this.count})
      : color = DSColors.statusSuccess, backgroundColor = null, variant = DSBadgeVariant.filled, size = DSBadgeSize.medium;

  const DSBadge.warning({super.key, this.label, this.count})
      : color = DSColors.statusWarning, backgroundColor = null, variant = DSBadgeVariant.filled, size = DSBadgeSize.medium;

  const DSBadge.error({super.key, this.label, this.count})
      : color = DSColors.statusError, backgroundColor = null, variant = DSBadgeVariant.filled, size = DSBadgeSize.medium;

  const DSBadge.info({super.key, this.label, this.count})
      : color = DSColors.statusInfo, backgroundColor = null, variant = DSBadgeVariant.filled, size = DSBadgeSize.medium;

  // === OPERATIONAL STATE FACTORY ===
  /// Creates a badge from a [DSOperationalState].
  ///
  /// Displays the state's [label] text with its canonical color.
  /// If [label] is provided, it overrides the state's default label.
  /// If [count] is provided, it displays the count instead of the label.
  factory DSBadge.operational(
    DSOperationalState state, {
    Key? key,
    String? label,
    int? count,
    DSBadgeVariant variant = DSBadgeVariant.filled,
    DSBadgeSize size = DSBadgeSize.medium,
  }) {
    return DSBadge(
      key: key,
      label: label ?? state.label,
      count: count,
      color: state.color,
      variant: variant,
      size: size,
    );
  }

  double get _height {
    switch (size) {
      case DSBadgeSize.small: return 16;
      case DSBadgeSize.medium: return 20;
      case DSBadgeSize.large: return 24;
    }
  }

  double get _fontSize {
    switch (size) {
      case DSBadgeSize.small: return 10;
      case DSBadgeSize.medium: return 11;
      case DSBadgeSize.large: return 12;
    }
  }

  EdgeInsets get _padding {
    switch (size) {
      case DSBadgeSize.small: return const EdgeInsets.symmetric(horizontal: 4);
      case DSBadgeSize.medium: return const EdgeInsets.symmetric(horizontal: 6);
      case DSBadgeSize.large: return const EdgeInsets.symmetric(horizontal: 8);
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? DSColors.accentCyan;
    
    if (variant == DSBadgeVariant.dot) {
      return Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: effectiveColor,
          shape: BoxShape.circle,
        ),
      );
    }

    final content = count != null 
        ? (count! > 99 ? '99+' : count.toString())
        : label ?? '';

    final bgColor = variant == DSBadgeVariant.filled
        ? effectiveColor.withOpacity(0.15)
        : DSColors.transparent;
    
    final borderColor = variant == DSBadgeVariant.outlined
        ? effectiveColor.withOpacity(0.5)
        : DSColors.transparent;

    return Container(
      height: _height,
      constraints: BoxConstraints(minWidth: _height),
      padding: _padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? bgColor,
        borderRadius: BorderRadius.circular(DSRadii.full),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Center(
        child: Text(
          content,
          style: TextStyle(
            fontSize: _fontSize,
            fontWeight: FontWeight.w600,
            color: effectiveColor,
            height: 1,
          ),
        ),
      ),
    );
  }
}

enum DSBadgeVariant {
  filled,
  outlined,
  dot,
}

enum DSBadgeSize {
  small,
  medium,
  large,
}
