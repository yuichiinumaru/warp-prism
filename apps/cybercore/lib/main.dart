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
        scaffoldBackgroundColor: DSColors.obsidianDeep,
        colorScheme: const ColorScheme.dark(
          primary: DSColors.accentCyan,
          secondary: DSColors.accentViolet,
          surface: DSColors.obsidianBase,
        ),
      ),
      routerConfig: appRouter,
    );
  }
}
