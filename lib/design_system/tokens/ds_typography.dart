import 'package:flutter/material.dart';

/// ASW Observatory Design Tokens - Typography
/// 
/// Clean, precise typography for dense information architecture
/// Using monospace for code/technical content, sans-serif for UI
abstract class DSTypography {
  // === FONT FAMILIES ===
  static const String fontFamilyMono = 'JetBrainsMono';
  static const String fontFamilySans = 'Inter';
  
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
    fontSize: 48,
    fontWeight: weightBold,
    letterSpacing: -0.5,
    height: 1.1,
  );
  
  /// Medium display - section headings
  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamilySans,
    fontSize: 36,
    fontWeight: weightBold,
    letterSpacing: -0.25,
    height: 1.2,
  );
  
  /// Small display - page titles
  static const TextStyle displaySmall = TextStyle(
    fontFamily: fontFamilySans,
    fontSize: 28,
    fontWeight: weightSemibold,
    letterSpacing: -0.25,
    height: 1.25,
  );
  
  // === HEADING STYLES ===
  /// Heading large
  static const TextStyle headingLarge = TextStyle(
    fontFamily: fontFamilySans,
    fontSize: 24,
    fontWeight: weightSemibold,
    letterSpacing: -0.25,
    height: 1.3,
  );
  
  /// Heading medium
  static const TextStyle headingMedium = TextStyle(
    fontFamily: fontFamilySans,
    fontSize: 20,
    fontWeight: weightSemibold,
    letterSpacing: -0.15,
    height: 1.35,
  );
  
  /// Heading small
  static const TextStyle headingSmall = TextStyle(
    fontFamily: fontFamilySans,
    fontSize: 16,
    fontWeight: weightSemibold,
    letterSpacing: 0,
    height: 1.4,
  );
  
  // === BODY STYLES ===
  /// Body large - primary content
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamilySans,
    fontSize: 16,
    fontWeight: weightRegular,
    letterSpacing: 0,
    height: 1.5,
  );
  
  /// Body medium - secondary content
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamilySans,
    fontSize: 14,
    fontWeight: weightRegular,
    letterSpacing: 0,
    height: 1.5,
  );
  
  /// Body small - captions, metadata
  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamilySans,
    fontSize: 12,
    fontWeight: weightRegular,
    letterSpacing: 0.1,
    height: 1.5,
  );
  
  // === LABEL STYLES ===
  /// Label large - buttons, prominent labels
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamilySans,
    fontSize: 14,
    fontWeight: weightMedium,
    letterSpacing: 0.1,
    height: 1.4,
  );
  
  /// Label medium - chips, tags
  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamilySans,
    fontSize: 12,
    fontWeight: weightMedium,
    letterSpacing: 0.25,
    height: 1.4,
  );
  
  /// Label small - micro labels
  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamilySans,
    fontSize: 10,
    fontWeight: weightMedium,
    letterSpacing: 0.5,
    height: 1.4,
  );
  
  // === CODE/MONO STYLES ===
  /// Code large - code blocks, terminal
  static const TextStyle codeLarge = TextStyle(
    fontFamily: fontFamilyMono,
    fontSize: 14,
    fontWeight: weightRegular,
    letterSpacing: 0,
    height: 1.6,
  );
  
  /// Code medium - inline code
  static const TextStyle codeMedium = TextStyle(
    fontFamily: fontFamilyMono,
    fontSize: 13,
    fontWeight: weightRegular,
    letterSpacing: 0,
    height: 1.5,
  );
  
  /// Code small - compact code
  static const TextStyle codeSmall = TextStyle(
    fontFamily: fontFamilyMono,
    fontSize: 11,
    fontWeight: weightRegular,
    letterSpacing: 0,
    height: 1.5,
  );
  
  // === NUMERIC STYLES ===
  /// Numeric large - big numbers, metrics
  static const TextStyle numericLarge = TextStyle(
    fontFamily: fontFamilyMono,
    fontSize: 32,
    fontWeight: weightBold,
    letterSpacing: -0.5,
    height: 1.1,
  );
  
  /// Numeric medium - medium metrics
  static const TextStyle numericMedium = TextStyle(
    fontFamily: fontFamilyMono,
    fontSize: 24,
    fontWeight: weightSemibold,
    letterSpacing: -0.25,
    height: 1.2,
  );
  
  /// Numeric small - small metrics, IDs
  static const TextStyle numericSmall = TextStyle(
    fontFamily: fontFamilyMono,
    fontSize: 14,
    fontWeight: weightMedium,
    letterSpacing: 0,
    height: 1.3,
  );
}
