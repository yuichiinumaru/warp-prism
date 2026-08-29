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
      theme: PrismTheme.dark(),
      routerConfig: appRouter,
    );
  }
}
