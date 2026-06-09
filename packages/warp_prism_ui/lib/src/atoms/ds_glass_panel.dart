import 'dart:ui';
import 'package:flutter/material.dart';
import '../tokens/tokens.dart';

/// Glass panel visual variant.
///
/// Controls blur intensity and shadow presets:
/// - [subtle] — low blur, no shadow (lightweight containers)
/// - [elevated] — medium blur, elevation2 shadow (cards, panels)
/// - [modal] — high blur, elevation4 shadow (overlays, modals)
enum DSGlassPanelVariant {
  subtle,
  elevated,
  modal,
}

/// ASW Observatory Atom - Glass Panel
///
/// Frosted glass effect panel for the obsidian theme.
///
/// Contract:
/// - Default radius uses [DSRadii.card].
/// - Use [DSGlassPanel.subtle] for lightweight containers.
/// - Use [DSGlassPanel.elevated] for cards and panels.
/// - Use [DSGlassPanel.modal] for overlays and modals.
/// - For performance-critical areas, prefer [DSGlassPanelSimple].
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
  final DSGlassPanelVariant variant;

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
    this.variant = DSGlassPanelVariant.elevated,
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
        shadows = null,
        variant = DSGlassPanelVariant.subtle;

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
        shadows = DSShadows.elevation2,
        variant = DSGlassPanelVariant.elevated;

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
        shadows = DSShadows.elevation4,
        variant = DSGlassPanelVariant.modal;

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? DSColors.glassOverlay.withValues(alpha: 0.6);
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

/// Simpler glass panel without blur for performance-critical areas.
///
/// Use [DSGlassPanelSimple] when backdrop blur is too expensive
/// (e.g., long lists, graph canvas overlays) but the visual surface
/// should still match the obsidian elevated palette.
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
