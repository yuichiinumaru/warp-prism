import 'package:flutter/material.dart';
import '../tokens/tokens.dart';

/// ASW Observatory Atom - Divider
///
/// Visual separator for content sections
class DSDivider extends StatelessWidget {
  final Color? color;
  final double thickness;
  final double? indent;
  final double? endIndent;
  final bool vertical;

  const DSDivider({
    super.key,
    this.color,
    this.thickness = 1,
    this.indent,
    this.endIndent,
    this.vertical = false,
  });

  // === NAMED CONSTRUCTORS ===
  const DSDivider.subtle({
    super.key,
    this.indent,
    this.endIndent,
    this.vertical = false,
  }) : color = DSColors.borderSubtle,
       thickness = 1;

  const DSDivider.strong({
    super.key,
    this.indent,
    this.endIndent,
    this.vertical = false,
  }) : color = DSColors.borderDefault,
       thickness = 1;

  const DSDivider.glow({
    super.key,
    this.indent,
    this.endIndent,
    this.vertical = false,
  }) : color = DSColors.accentCyan,
       thickness = 1;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? DSColors.borderSubtle;

    if (vertical) {
      return Container(
        width: thickness,
        margin: EdgeInsets.only(top: indent ?? 0, bottom: endIndent ?? 0),
        color: effectiveColor,
      );
    }

    return Divider(
      color: effectiveColor,
      thickness: thickness,
      indent: indent,
      endIndent: endIndent,
      height: thickness,
    );
  }
}

/// Luminous divider with glow effect
class DSGlowDivider extends StatelessWidget {
  final Color color;
  final double thickness;
  final bool vertical;

  const DSGlowDivider({
    super.key,
    this.color = DSColors.accentCyan,
    this.thickness = 1,
    this.vertical = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: vertical ? thickness : double.infinity,
      height: vertical ? double.infinity : thickness,
      decoration: BoxDecoration(
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 4,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
    );
  }
}
