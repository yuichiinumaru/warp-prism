import 'package:flutter/material.dart';
import '../tokens/ds_colors.dart';
import '../tokens/ds_radii.dart';
import '../tokens/ds_taldarim_red_skin.dart';
import '../tokens/ds_talon_purple_skin.dart';
import '../tokens/ds_typography.dart';

/// Internal canonical ThemeData factory for Black Obsidian design contract.
abstract final class DSTheme {
  /// Emits a complete canonical M3 [ThemeData] for Black Obsidian interface.
  ///
  /// Every M3 [ColorScheme] slot is explicitly mapped to obsidian and accent
  /// tokens so framework default blue-grey chrome never leaks into inputs,
  /// menus, dialogs, cards, or tooltips.
  static ThemeData dark({
    List<ThemeExtension<dynamic>>? extensions,
  }) {
    final colorScheme = ColorScheme.dark(
      primary: DSColors.accentBlue,
      onPrimary: DSColors.white,
      primaryContainer: DSColors.accentBlueDim,
      onPrimaryContainer: DSColors.white,

      secondary: DSColors.accentViolet,
      onSecondary: DSColors.white,
      secondaryContainer: DSColors.accentVioletDim,
      onSecondaryContainer: DSColors.white,

      tertiary: DSColors.accentCyan,
      onTertiary: DSColors.white,
      tertiaryContainer: DSColors.accentCyanDim,
      onTertiaryContainer: DSColors.white,

      error: DSColors.statusError,
      onError: DSColors.white,
      errorContainer: DSColors.statusErrorDim,
      onErrorContainer: DSColors.white,

      surface: DSColors.obsidianBase,
      onSurface: DSColors.textPrimary,
      surfaceDim: DSColors.obsidianDeep,
      surfaceBright: DSColors.obsidianElevated,

      surfaceContainerLowest: DSColors.obsidianDeep,
      surfaceContainerLow: DSColors.obsidianDeep,
      surfaceContainer: DSColors.obsidianBase,
      surfaceContainerHigh: DSColors.obsidianElevated,
      surfaceContainerHighest: DSColors.obsidianHover,

      onSurfaceVariant: DSColors.textSecondary,
      outline: DSColors.borderDefault,
      outlineVariant: DSColors.borderSubtle,

      shadow: DSColors.obsidianDeep,
      scrim: DSColors.black,
      inverseSurface: DSColors.textPrimary,
      onInverseSurface: DSColors.obsidianBase,
      inversePrimary: DSColors.accentBlueMuted,
      surfaceTint: Colors.transparent,
    );

    final textTheme = TextTheme(
      displayLarge: DSTypography.displayLarge.copyWith(color: DSColors.textPrimary),
      displayMedium: DSTypography.displayMedium.copyWith(color: DSColors.textPrimary),
      displaySmall: DSTypography.displaySmall.copyWith(color: DSColors.textPrimary),
      headlineLarge: DSTypography.headingLarge.copyWith(color: DSColors.textPrimary),
      headlineMedium: DSTypography.headingMedium.copyWith(color: DSColors.textPrimary),
      headlineSmall: DSTypography.headingSmall.copyWith(color: DSColors.textPrimary),
      titleLarge: DSTypography.headingMedium.copyWith(color: DSColors.textPrimary),
      titleMedium: DSTypography.headingSmall.copyWith(color: DSColors.textPrimary),
      titleSmall: DSTypography.labelLarge.copyWith(color: DSColors.textPrimary),
      bodyLarge: DSTypography.bodyLarge.copyWith(color: DSColors.textPrimary),
      bodyMedium: DSTypography.bodyMedium.copyWith(color: DSColors.textPrimary),
      bodySmall: DSTypography.bodySmall.copyWith(color: DSColors.textSecondary),
      labelLarge: DSTypography.labelLarge.copyWith(color: DSColors.textPrimary),
      labelMedium: DSTypography.labelMedium.copyWith(color: DSColors.textSecondary),
      labelSmall: DSTypography.labelSmall.copyWith(color: DSColors.textSecondary),
    );

    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: DSColors.obsidianDeep,
      colorScheme: colorScheme,
      textTheme: textTheme,
      fontFamily: DSTypography.fontFamilySans,
      fontFamilyFallback: DSTypography.fontFamilySansFallback,
      extensions: extensions,
      dialogTheme: DialogThemeData(
        backgroundColor: DSColors.obsidianElevated,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DSRadii.lg),
          side: BorderSide(color: DSColors.borderDefault),
        ),
        titleTextStyle: DSTypography.headingMedium.copyWith(color: DSColors.textPrimary),
        contentTextStyle: DSTypography.bodyMedium.copyWith(color: DSColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: DSColors.obsidianElevated,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DSRadii.md),
          side: BorderSide(color: DSColors.borderDefault),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: DSColors.obsidianElevated,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DSRadii.md),
          side: BorderSide(color: DSColors.borderDefault),
        ),
        textStyle: DSTypography.bodyMedium.copyWith(color: DSColors.textPrimary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DSColors.obsidianElevated,
        hintStyle: DSTypography.bodyMedium.copyWith(color: DSColors.textSecondary),
        labelStyle: DSTypography.bodyMedium.copyWith(color: DSColors.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DSRadii.md),
          borderSide: BorderSide(color: DSColors.borderDefault),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DSRadii.md),
          borderSide: BorderSide(color: DSColors.borderDefault),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DSRadii.md),
          borderSide: BorderSide(color: DSColors.accentBlue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DSRadii.md),
          borderSide: const BorderSide(color: DSColors.statusError),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: DSColors.obsidianHover,
        selectedColor: DSColors.accentBlueDim,
        disabledColor: DSColors.obsidianElevated,
        surfaceTintColor: Colors.transparent,
        side: BorderSide(color: DSColors.borderDefault),
        labelStyle: DSTypography.labelMedium.copyWith(color: DSColors.textPrimary),
        secondaryLabelStyle: DSTypography.labelMedium.copyWith(color: DSColors.textSecondary),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DSRadii.sm),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: DSColors.borderDefault,
        thickness: 1,
        space: 1,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: DSColors.obsidianElevated,
          borderRadius: BorderRadius.circular(DSRadii.sm),
          border: Border.all(color: DSColors.borderDefault),
        ),
        textStyle: DSTypography.bodySmall.copyWith(color: DSColors.textPrimary),
      ),
      appBarTheme: AppBarThemeData(
        backgroundColor: DSColors.obsidianDeep,
        surfaceTintColor: Colors.transparent,
        foregroundColor: DSColors.textPrimary,
        titleTextStyle: DSTypography.headingMedium.copyWith(color: DSColors.textPrimary),
      ),
    );
  }

  /// Emits a canonical M3 [ThemeData] with Taldarim Red accent skin installed.
  ///
  /// Reuses the Black Obsidian background structure (#030506 family) and remaps
  /// primary action accent slots to Taldarim Red crimson energy (#E51A4C family).
  /// Protoss brand label: Taldarim Red (counterpart to Khalai Blue default).
  static ThemeData taldarimRed({
    List<ThemeExtension<dynamic>>? extensions,
  }) {
    const skin = DSTaldarimRedSkin.taldarimRed();
    return skin.applyToTheme(dark(extensions: extensions));
  }

  /// Emits a canonical M3 [ThemeData] with Talon Purple accent skin installed.
  ///
  /// Reuses the Black Obsidian background structure (#030506 family) and remaps
  /// primary action accent slots to Talon Purple violet/crimson-purple energy (#9911E5 family).
  /// Protoss brand label: Talon Purple (counterpart to Khalai Blue default).
  static ThemeData talonPurple({
    List<ThemeExtension<dynamic>>? extensions,
  }) {
    const skin = DSTalonPurpleSkin.talonPurple();
    return skin.applyToTheme(dark(extensions: extensions));
  }
}
