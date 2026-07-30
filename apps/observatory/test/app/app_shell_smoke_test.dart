import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:warp_prism_observatory/app/app_shell.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// Minimal bootstrap router for Task 0011 shell smoke coverage.
///
/// Intentionally does not import product feature modules. Those surfaces
/// still contain residual DS* consumer usage outside this task's scope and
/// would prevent the bootstrap shell from being loadable under the public
/// Prism* barrel contract.
GoRouter _buildBootstrapRouter() {
  return GoRouter(
    initialLocation: '/overview',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          for (final path in const [
            '/overview',
            '/map',
            '/operate',
            '/history',
            '/governance',
          ])
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: path,
                  builder: (context, state) => Center(child: Text(path)),
                ),
              ],
            ),
        ],
      ),
      GoRoute(path: '/', redirect: (context, state) => '/overview'),
    ],
  );
}

void main() {
  group('App shell smoke test', () {
    testWidgets('app boots and renders the shell with default route', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final router = _buildBootstrapRouter();
      await tester.pumpWidget(
        MaterialApp.router(
          theme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: PrismColors.obsidianDeep,
          ),
          routerConfig: router,
        ),
      );
      await tester.pumpAndSettle();

      // Public Prism* aliases only — consumer apps must not depend on DS*.
      expect(find.byType(PrismShellResponsive), findsOneWidget);
      expect(find.byType(PrismSidebar), findsWidgets);
      expect(find.byType(PrismTopbar), findsWidgets);
      expect(find.text('Overview'), findsWidgets);
    });

    testWidgets('default route lands on Overview', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final router = _buildBootstrapRouter();
      await tester.pumpWidget(
        MaterialApp.router(
          theme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: PrismColors.obsidianDeep,
          ),
          routerConfig: router,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('/overview'), findsOneWidget);
      expect(find.text('Overview'), findsWidgets);
    });

    test('AppShell defines required product navigation items', () {
      expect(AppShell.navItems.length, 5);
      expect(AppShell.navItems.map((i) => i.id).toList(), [
        'overview',
        'map',
        'operate',
        'history',
        'governance',
      ]);
    });
  });
}
