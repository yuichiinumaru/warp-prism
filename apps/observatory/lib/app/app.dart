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
      scaffoldBackgroundColor: DSColors.obsidianDeep,
      colorScheme: ColorScheme.dark(
        primary: DSColors.accentCyan,
        secondary: DSColors.accentViolet,
        surface: DSColors.obsidianBase,
        onPrimary: DSColors.white,
        onSecondary: DSColors.white,
        onSurface: DSColors.textPrimary,
      ),
      fontFamily: DSTypography.fontFamilyMono,
    );
  }
}
