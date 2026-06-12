import 'package:flutter/material.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';
import 'app/router.dart';

void main() {
  runApp(const WarpPrismCyberCoreApp());
}

class WarpPrismCyberCoreApp extends StatelessWidget {
  const WarpPrismCyberCoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Warp Prism — CyberCore',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: PrismColors.obsidianDeep,
        colorScheme: const ColorScheme.dark(
          primary: PrismColors.accentCyan,
          secondary: PrismColors.accentViolet,
          surface: PrismColors.obsidianBase,
        ),
      ),
      routerConfig: appRouter,
    );
  }
}
