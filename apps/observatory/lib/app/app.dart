import 'package:flutter/material.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';
import 'router.dart';

/// ASW Observatory application root.
///
/// Configures [MaterialApp.router] with the project's dark obsidian theme
/// and wires the canonical [GoRouter] instance.
class WarpPrismApp extends StatelessWidget {
  const WarpPrismApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ASW Observatory',
      debugShowCheckedModeBanner: false,
      theme: _buildDarkTheme(),
      routerConfig: appRouter,
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: PrismColors.obsidianDeep,
      colorScheme: const ColorScheme.dark(
        primary: PrismColors.accentCyan,
        secondary: PrismColors.accentViolet,
        surface: PrismColors.obsidianBase,
        onPrimary: PrismColors.white,
        onSecondary: PrismColors.white,
        onSurface: PrismColors.textPrimary,
      ),
      fontFamily: PrismTypography.fontFamilyMono,
    );
  }
}
