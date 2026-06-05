import 'dart:ui';
import 'package:flutter/material.dart';
import '../tokens/tokens.dart';

/// ASW Observatory Atom - Glass Panel
/// 
/// Frosted glass effect panel for the obsidian theme
/// Use sparingly for major cards, selected inspector, modal/story panels
class DSGlassPanel extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final double radius;
  final double blur;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final List<BoxShadow>? shadows;

  const DSGlassPanel({
    super.key,
    required this.child,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1,
    this.radius = DSRadii.card,
    this.blur = 10,
    this.padding,
    this.margin,
    this.shadows,
  });

  // === NAMED CONSTRUCTORS ===
  const DSGlassPanel.subtle({
    super.key,
    required this.child,
    this.radius = DSRadii.card,
    this.padding,
    this.margin,
  })  : backgroundColor = null,
        borderColor = null,
        borderWidth = 1,
        blur = 5,
        shadows = null;

  const DSGlassPanel.elevated({
    super.key,
    required this.child,
    this.radius = DSRadii.card,
    this.padding,
    this.margin,
  })  : backgroundColor = null,
        borderColor = null,
        borderWidth = 1,
        blur = 15,
        shadows = DSShadows.elevation2;

  const DSGlassPanel.modal({
    super.key,
    required this.child,
    this.padding,
    this.margin,
  })  : backgroundColor = null,
        borderColor = null,
        borderWidth = 1,
        radius = DSRadii.modal,
        blur = 20,
        shadows = DSShadows.elevation4;

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? DSColors.glassOverlay.withOpacity(0.6);
    final border = borderColor ?? DSColors.borderSubtle;

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: shadows,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: border, width: borderWidth),
            ),
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Simpler glass panel without blur for performance-critical areas
class DSGlassPanelSimple extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final double radius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final List<BoxShadow>? shadows;

  const DSGlassPanelSimple({
    super.key,
    required this.child,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1,
    this.radius = DSRadii.card,
    this.padding,
    this.margin,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? DSColors.obsidianElevated;
    final border = borderColor ?? DSColors.borderSubtle;

    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: border, width: borderWidth),
        boxShadow: shadows,
      ),
      child: child,
    );
  }
}
