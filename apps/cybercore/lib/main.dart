import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';
import 'app/router.dart';

void main() {
  runApp(WarpPrismCyberCoreApp());
}

class WarpPrismCyberCoreApp extends StatelessWidget {
  final GoRouter router;

  WarpPrismCyberCoreApp({super.key, GoRouter? router})
    : router = router ?? createAppRouter();

  @override
  Widget build(BuildContext context) {
    // CyberCore opt-in OmniRoute teal skin (Task 1616). Observatory keeps
    // PrismColors.accentCyan (#00D4FF) as the global static default.
    final theme = const PrismCyberCoreTealSkin.omniRoute().applyToTheme(
      ThemeData.dark().copyWith(
        scaffoldBackgroundColor: PrismColors.obsidianDeep,
        colorScheme: const ColorScheme.dark(
          // primary remapped by applyToTheme → core teal #00FFCC
          primary: PrismColors.accentCyan,
          secondary: PrismColors.accentViolet,
          surface: PrismColors.obsidianBase,
        ),
      ),
    );
    return MaterialApp.router(
      title: 'Warp Prism — CyberCore',
      theme: theme,
      routerConfig: router,
    );
  }
}
