import 'package:flutter/material.dart';
import '../tokens/tokens.dart';

/// ASW Observatory Atom - Text
/// 
/// Semantic text component with pre-defined styles
class DSText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final DSTextVariant variant;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool selectable;

  const DSText(
    this.text, {
    super.key,
    this.style,
    this.variant = DSTextVariant.bodyMedium,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.selectable = false,
  });

  // === NAMED CONSTRUCTORS ===
  const DSText.displayLarge(this.text, {super.key, this.color, this.textAlign, this.maxLines, this.overflow, this.selectable = false})
      : variant = DSTextVariant.displayLarge, style = null;
  
  const DSText.displayMedium(this.text, {super.key, this.color, this.textAlign, this.maxLines, this.overflow, this.selectable = false})
      : variant = DSTextVariant.displayMedium, style = null;
  
  const DSText.displaySmall(this.text, {super.key, this.color, this.textAlign, this.maxLines, this.overflow, this.selectable = false})
      : variant = DSTextVariant.displaySmall, style = null;
  
  const DSText.headingLarge(this.text, {super.key, this.color, this.textAlign, this.maxLines, this.overflow, this.selectable = false})
      : variant = DSTextVariant.headingLarge, style = null;
  
  const DSText.headingMedium(this.text, {super.key, this.color, this.textAlign, this.maxLines, this.overflow, this.selectable = false})
      : variant = DSTextVariant.headingMedium, style = null;
  
  const DSText.headingSmall(this.text, {super.key, this.color, this.textAlign, this.maxLines, this.overflow, this.selectable = false})
      : variant = DSTextVariant.headingSmall, style = null;
  
  const DSText.bodyLarge(this.text, {super.key, this.color, this.textAlign, this.maxLines, this.overflow, this.selectable = false})
      : variant = DSTextVariant.bodyLarge, style = null;
  
  const DSText.bodyMedium(this.text, {super.key, this.color, this.textAlign, this.maxLines, this.overflow, this.selectable = false})
      : variant = DSTextVariant.bodyMedium, style = null;
  
  const DSText.bodySmall(this.text, {super.key, this.color, this.textAlign, this.maxLines, this.overflow, this.selectable = false})
      : variant = DSTextVariant.bodySmall, style = null;
  
  const DSText.labelLarge(this.text, {super.key, this.color, this.textAlign, this.maxLines, this.overflow, this.selectable = false})
      : variant = DSTextVariant.labelLarge, style = null;
  
  const DSText.labelMedium(this.text, {super.key, this.color, this.textAlign, this.maxLines, this.overflow, this.selectable = false})
      : variant = DSTextVariant.labelMedium, style = null;
  
  const DSText.labelSmall(this.text, {super.key, this.color, this.textAlign, this.maxLines, this.overflow, this.selectable = false})
      : variant = DSTextVariant.labelSmall, style = null;
  
  const DSText.code(this.text, {super.key, this.color, this.textAlign, this.maxLines, this.overflow, this.selectable = true})
      : variant = DSTextVariant.codeMedium, style = null;
  
  const DSText.numeric(this.text, {super.key, this.color, this.textAlign, this.maxLines, this.overflow, this.selectable = false})
      : variant = DSTextVariant.numericMedium, style = null;

  TextStyle get _baseStyle {
    switch (variant) {
      case DSTextVariant.displayLarge: return DSTypography.displayLarge;
      case DSTextVariant.displayMedium: return DSTypography.displayMedium;
      case DSTextVariant.displaySmall: return DSTypography.displaySmall;
      case DSTextVariant.headingLarge: return DSTypography.headingLarge;
      case DSTextVariant.headingMedium: return DSTypography.headingMedium;
      case DSTextVariant.headingSmall: return DSTypography.headingSmall;
      case DSTextVariant.bodyLarge: return DSTypography.bodyLarge;
      case DSTextVariant.bodyMedium: return DSTypography.bodyMedium;
      case DSTextVariant.bodySmall: return DSTypography.bodySmall;
      case DSTextVariant.labelLarge: return DSTypography.labelLarge;
      case DSTextVariant.labelMedium: return DSTypography.labelMedium;
      case DSTextVariant.labelSmall: return DSTypography.labelSmall;
      case DSTextVariant.codeLarge: return DSTypography.codeLarge;
      case DSTextVariant.codeMedium: return DSTypography.codeMedium;
      case DSTextVariant.codeSmall: return DSTypography.codeSmall;
      case DSTextVariant.numericLarge: return DSTypography.numericLarge;
      case DSTextVariant.numericMedium: return DSTypography.numericMedium;
      case DSTextVariant.numericSmall: return DSTypography.numericSmall;
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = (_baseStyle.merge(style)).copyWith(
      color: color ?? DSColors.textPrimary,
    );

    if (selectable) {
      return SelectableText(
        text,
        style: effectiveStyle,
        textAlign: textAlign,
        maxLines: maxLines,
      );
    }

    return Text(
      text,
      style: effectiveStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow ?? (maxLines != null ? TextOverflow.ellipsis : null),
    );
  }
}

enum DSTextVariant {
  displayLarge,
  displayMedium,
  displaySmall,
  headingLarge,
  headingMedium,
  headingSmall,
  bodyLarge,
  bodyMedium,
  bodySmall,
  labelLarge,
  labelMedium,
  labelSmall,
  codeLarge,
  codeMedium,
  codeSmall,
  numericLarge,
  numericMedium,
  numericSmall,
}
