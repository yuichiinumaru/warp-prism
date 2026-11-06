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
    // CyberCore opt-in Nerazim Teal skin (Task 1616) installed on
    // ThemeData only via applyToTheme, preserving the tooling-only
    // registry boundary.
    final theme = const PrismNerazimTealSkin.nerazimTeal().applyToTheme(
      PrismTheme.dark(),
    );
    return MaterialApp.router(
      title: 'Warp Prism — CyberCore',
      theme: theme,
      routerConfig: router,
    );
  }
}
