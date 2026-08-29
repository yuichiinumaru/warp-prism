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
    // CyberCore opt-in OmniRoute teal skin (Task 1616) applied over
    // canonical PrismTheme.dark() factory. Observatory keeps
    // PrismColors.accentBlue (#2F81FF) as the global static default.
    final theme = const PrismCyberCoreTealSkin.omniRoute().applyToTheme(
      PrismTheme.dark(),
    );
    return MaterialApp.router(
      title: 'Warp Prism — CyberCore',
      theme: theme,
      routerConfig: router,
    );
  }
}
