import 'package:flutter/material.dart';

/// ASW Observatory Design Tokens - Typography
///
/// Clean, precise typography for dense information architecture.
///
/// Typography Role Allocation (per Black Obsidian Visual Contract §3.1):
/// - UI Display & Body (Rajdhani): Headings, page titles, navigation labels,
///   button text, body paragraphs, tab titles, dialog headers.
/// - Technical & Data (JetBrains Mono): Source code, entity IDs, timestamps,
///   log streams, terminal output, performance metrics, hashes, telemetry.
///
/// Fallback Contract:
/// - UI/Sans role: Rajdhani -> ['Roboto', 'Helvetica Neue', 'Arial', 'sans-serif']
/// - Technical/Mono role: JetBrainsMono -> ['Courier New', 'monospace']
abstract class DSTypography {
  // === FONT FAMILIES ===
  static const String fontFamilyMono = 'JetBrainsMono';
  static const String fontFamilySans = 'Rajdhani';

  // === FALLBACK CHAINS ===
  /// Deterministic system fallback chain for UI/Sans typography role.
  /// Rajdhani is a condensed display face; legibility at bodySmall/labelSmall
  /// relies on this explicit system sans fallback contract.
  static const List<String> fontFamilySansFallback = [
    'Roboto',
    'Helvetica Neue',
    'Arial',
    'sans-serif',
  ];

  /// Deterministic system fallback chain for Technical/Mono typography role.
  static const List<String> fontFamilyMonoFallback = [
    'Courier New',
    'monospace',
  ];

  // === FONT WEIGHTS ===
  static const FontWeight weightLight = FontWeight.w300;
  static const FontWeight weightRegular = FontWeight.w400;
  static const FontWeight weightMedium = FontWeight.w500;
  static const FontWeight weightSemibold = FontWeight.w600;
  static const FontWeight weightBold = FontWeight.w700;

  // === DISPLAY STYLES ===
  /// Large display - hero headings
  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamilySans,
    fontFamilyFallback: fontFamilySansFallback,
    fontSize: 48,
    fontWeight: weightBold,
    letterSpacing: -0.5,
    height: 1.1,
  );

  /// Medium display - section headings
  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamilySans,
    fontFamilyFallback: fontFamilySansFallback,
    fontSize: 36,
    fontWeight: weightBold,
    letterSpacing: -0.25,
    height: 1.2,
  );

  /// Small display - page titles
  static const TextStyle displaySmall = TextStyle(
    fontFamily: fontFamilySans,
    fontFamilyFallback: fontFamilySansFallback,
    fontSize: 28,
    fontWeight: weightSemibold,
    letterSpacing: -0.25,
    height: 1.25,
  );

  // === HEADING STYLES ===
  /// Heading large
  static const TextStyle headingLarge = TextStyle(
    fontFamily: fontFamilySans,
    fontFamilyFallback: fontFamilySansFallback,
    fontSize: 24,
    fontWeight: weightSemibold,
    letterSpacing: -0.25,
    height: 1.3,
  );

  /// Heading medium
  static const TextStyle headingMedium = TextStyle(
    fontFamily: fontFamilySans,
    fontFamilyFallback: fontFamilySansFallback,
    fontSize: 20,
    fontWeight: weightSemibold,
    letterSpacing: -0.15,
    height: 1.35,
  );

  /// Heading small
  static const TextStyle headingSmall = TextStyle(
    fontFamily: fontFamilySans,
    fontFamilyFallback: fontFamilySansFallback,
    fontSize: 16,
    fontWeight: weightSemibold,
    letterSpacing: 0,
    height: 1.4,
  );

  // === BODY STYLES ===
  /// Body large - primary content
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamilySans,
    fontFamilyFallback: fontFamilySansFallback,
    fontSize: 16,
    fontWeight: weightRegular,
    letterSpacing: 0,
    height: 1.5,
  );

  /// Body medium - secondary content
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamilySans,
    fontFamilyFallback: fontFamilySansFallback,
    fontSize: 14,
    fontWeight: weightRegular,
    letterSpacing: 0,
    height: 1.5,
  );

  /// Body small - captions, metadata
  /// Employs explicit fallback chain for small-surface legibility.
  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamilySans,
    fontFamilyFallback: fontFamilySansFallback,
    fontSize: 12,
    fontWeight: weightRegular,
    letterSpacing: 0.1,
    height: 1.5,
  );

  // === LABEL STYLES ===
  /// Label large - buttons, prominent labels
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamilySans,
    fontFamilyFallback: fontFamilySansFallback,
    fontSize: 14,
    fontWeight: weightMedium,
    letterSpacing: 0.1,
    height: 1.4,
  );

  /// Label medium - chips, tags
  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamilySans,
    fontFamilyFallback: fontFamilySansFallback,
    fontSize: 12,
    fontWeight: weightMedium,
    letterSpacing: 0.25,
    height: 1.4,
  );

  /// Label small - micro labels
  /// Employs explicit fallback chain for micro-surface legibility.
  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamilySans,
    fontFamilyFallback: fontFamilySansFallback,
    fontSize: 10,
    fontWeight: weightMedium,
    letterSpacing: 0.5,
    height: 1.4,
  );

  // === CODE/MONO STYLES ===
  /// Code large - code blocks, terminal
  static const TextStyle codeLarge = TextStyle(
    fontFamily: fontFamilyMono,
    fontFamilyFallback: fontFamilyMonoFallback,
    fontSize: 14,
    fontWeight: weightRegular,
    letterSpacing: 0,
    height: 1.6,
  );

  /// Code medium - inline code
  static const TextStyle codeMedium = TextStyle(
    fontFamily: fontFamilyMono,
    fontFamilyFallback: fontFamilyMonoFallback,
    fontSize: 13,
    fontWeight: weightRegular,
    letterSpacing: 0,
    height: 1.5,
  );

  /// Code small - compact code
  static const TextStyle codeSmall = TextStyle(
    fontFamily: fontFamilyMono,
    fontFamilyFallback: fontFamilyMonoFallback,
    fontSize: 11,
    fontWeight: weightRegular,
    letterSpacing: 0,
    height: 1.5,
  );

  // === NUMERIC STYLES ===
  // Decision: Numeric/metrics styles use JetBrains Mono (fontFamilyMono) for
  // tabular digit alignment and visual coherence with code and IDs per Visual Contract §3.1.

  /// Numeric large - big numbers, metrics
  static const TextStyle numericLarge = TextStyle(
    fontFamily: fontFamilyMono,
    fontFamilyFallback: fontFamilyMonoFallback,
    fontSize: 32,
    fontWeight: weightBold,
    letterSpacing: -0.5,
    height: 1.1,
  );

  /// Numeric medium - medium metrics
  static const TextStyle numericMedium = TextStyle(
    fontFamily: fontFamilyMono,
    fontFamilyFallback: fontFamilyMonoFallback,
    fontSize: 24,
    fontWeight: weightSemibold,
    letterSpacing: -0.25,
    height: 1.2,
  );

  /// Numeric small - small metrics, IDs
  static const TextStyle numericSmall = TextStyle(
    fontFamily: fontFamilyMono,
    fontFamilyFallback: fontFamilyMonoFallback,
    fontSize: 14,
    fontWeight: weightMedium,
    letterSpacing: 0,
    height: 1.3,
  );
}
