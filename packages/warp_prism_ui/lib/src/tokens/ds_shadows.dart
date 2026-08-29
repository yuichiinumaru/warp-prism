import 'package:flutter/material.dart';
import 'ds_colors.dart';

/// ASW Observatory Design Tokens - Shadows
///
/// Subtle shadows and glows for depth in ultradark theme.
/// Glow effects dynamically reference [DSColors] tokens (`DSColors.accentBlue`,
/// `DSColors.accentCyan`, etc.), ensuring auto-shift behavior whenever underlying
/// accent token definitions or ThemeExtensions are updated.
abstract class DSShadows {
  // === ELEVATION SHADOWS ===
  /// Subtle elevation - barely lifted
  static const List<BoxShadow> elevation1 = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, 1)),
  ];

  /// Medium elevation - cards, panels
  static const List<BoxShadow> elevation2 = [
    BoxShadow(color: Color(0x26000000), blurRadius: 8, offset: Offset(0, 2)),
    BoxShadow(color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1)),
  ];

  /// High elevation - modals, dropdowns
  static const List<BoxShadow> elevation3 = [
    BoxShadow(color: Color(0x33000000), blurRadius: 16, offset: Offset(0, 4)),
    BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, 2)),
  ];

  /// Highest elevation - floating elements
  static const List<BoxShadow> elevation4 = [
    BoxShadow(color: Color(0x40000000), blurRadius: 24, offset: Offset(0, 8)),
    BoxShadow(color: Color(0x26000000), blurRadius: 8, offset: Offset(0, 4)),
  ];

  // === GLOW EFFECTS ===
  /// Blue glow - primary action accent (Black Obsidian contract)
  static List<BoxShadow> glowBlue({double intensity = 1.0}) => [
    BoxShadow(
      color: DSColors.accentBlue.withValues(alpha: 0.3 * intensity),
      blurRadius: 12,
      spreadRadius: -2,
    ),
    BoxShadow(
      color: DSColors.accentBlue.withValues(alpha: 0.1 * intensity),
      blurRadius: 24,
      spreadRadius: -4,
    ),
  ];

  /// Cyan glow - data accent
  static List<BoxShadow> glowCyan({double intensity = 1.0}) => [
    BoxShadow(
      color: DSColors.accentCyan.withValues(alpha: 0.3 * intensity),
      blurRadius: 12,
      spreadRadius: -2,
    ),
    BoxShadow(
      color: DSColors.accentCyan.withValues(alpha: 0.1 * intensity),
      blurRadius: 24,
      spreadRadius: -4,
    ),
  ];

  /// Violet glow - secondary accent
  static List<BoxShadow> glowViolet({double intensity = 1.0}) => [
    BoxShadow(
      color: DSColors.accentViolet.withValues(alpha: 0.3 * intensity),
      blurRadius: 12,
      spreadRadius: -2,
    ),
    BoxShadow(
      color: DSColors.accentViolet.withValues(alpha: 0.1 * intensity),
      blurRadius: 24,
      spreadRadius: -4,
    ),
  ];

  /// Gold glow - tertiary accent
  static List<BoxShadow> glowGold({double intensity = 1.0}) => [
    BoxShadow(
      color: DSColors.accentGold.withValues(alpha: 0.3 * intensity),
      blurRadius: 12,
      spreadRadius: -2,
    ),
    BoxShadow(
      color: DSColors.accentGold.withValues(alpha: 0.1 * intensity),
      blurRadius: 24,
      spreadRadius: -4,
    ),
  ];

  /// Success glow
  static List<BoxShadow> glowSuccess({double intensity = 1.0}) => [
    BoxShadow(
      color: DSColors.statusSuccess.withValues(alpha: 0.3 * intensity),
      blurRadius: 12,
      spreadRadius: -2,
    ),
  ];

  /// Error glow
  static List<BoxShadow> glowError({double intensity = 1.0}) => [
    BoxShadow(
      color: DSColors.statusError.withValues(alpha: 0.3 * intensity),
      blurRadius: 12,
      spreadRadius: -2,
    ),
  ];

  /// Warning glow
  static List<BoxShadow> glowWarning({double intensity = 1.0}) => [
    BoxShadow(
      color: DSColors.statusWarning.withValues(alpha: 0.3 * intensity),
      blurRadius: 12,
      spreadRadius: -2,
    ),
  ];

  // === INNER SHADOWS (simulated with gradients) ===
  /// Inner shadow decoration for recessed elements
  static BoxDecoration innerShadow = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        DSColors.black.withValues(alpha: 0.15),
        DSColors.transparent,
        DSColors.white.withValues(alpha: 0.02),
      ],
      stops: const [0, 0.1, 1],
    ),
  );
}
