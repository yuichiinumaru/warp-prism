// Tests for AppShell responsive layout behavior.
//
// Verifies production AppShell (not a reimplementation):
// 1. Wide layouts render expanded sidebar + topbar (no bottom nav)
// 2. Narrow layouts render bottom navigation + AppBar (no sidebar)
// 3. Medium layouts render sidebar + topbar (no bottom nav)
// 4. Navigation items are present and route-derived
// 5. Inspector is not permanently visible on narrow layouts
//
// Run: flutter test test/app/shell_responsive_layout_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:warp_prism_observatory/app/app_shell.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// Minimal bootstrap router that mounts production [AppShell] without
/// importing product feature modules (keeps the suite loadable and OOM-safe).
GoRouter _buildShellRouter({String initialLocation = '/overview'}) {
  return GoRouter(
    initialLocation: initialLocation,
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

Widget _pumpShellApp(GoRouter router) {
  return MaterialApp.router(
    theme: ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: PrismColors.obsidianDeep,
    ),
    routerConfig: router,
  );
}

void main() {
  group('AppShell responsive layout', () {
    testWidgets('wide layout (1400px) renders expanded sidebar and topbar', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_pumpShellApp(_buildShellRouter()));
      await tester.pumpAndSettle();

      expect(find.byType(PrismShellResponsive), findsOneWidget);
      expect(find.byType(PrismSidebar), findsWidgets);
      expect(find.byType(PrismTopbar), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsNothing);
      expect(find.text('/overview'), findsOneWidget);
    });

    testWidgets(
      'narrow layout (400px) renders bottom navigation and no sidebar',
      (tester) async {
        tester.view.physicalSize = const Size(400, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(_pumpShellApp(_buildShellRouter()));
        await tester.pumpAndSettle();

        expect(find.byType(BottomNavigationBar), findsOneWidget);
        expect(find.byType(PrismSidebar), findsNothing);
        expect(find.byType(PrismShellResponsive), findsNothing);
        // Inspector must not stay permanently visible on compact layouts.
        expect(find.byType(PrismDetailInspector), findsNothing);
        expect(find.text('/overview'), findsOneWidget);
      },
    );

    testWidgets('medium layout (900px) renders sidebar and topbar', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(900, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_pumpShellApp(_buildShellRouter()));
      await tester.pumpAndSettle();

      expect(find.byType(PrismShellResponsive), findsOneWidget);
      expect(find.byType(PrismSidebar), findsWidgets);
      expect(find.byType(PrismTopbar), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsNothing);
    });

    testWidgets('route-driven selection lands on Map branch', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _pumpShellApp(_buildShellRouter(initialLocation: '/map')),
      );
      await tester.pumpAndSettle();

      expect(find.text('/map'), findsOneWidget);
      expect(find.byType(PrismTopbar), findsOneWidget);
      expect(find.text('Map'), findsWidgets);
    });

    test('AppShell defines exactly 5 navigation items', () {
      expect(AppShell.navItems.length, 5);
      expect(AppShell.navItems.map((i) => i.id), [
        'overview',
        'map',
        'operate',
        'history',
        'governance',
      ]);
    });

    test('navigation items have required labels', () {
      for (final item in AppShell.navItems) {
        expect(item.label, isNotNull);
        expect(item.label, isNotEmpty);
      }
    });

    test('navigation items have unique ids', () {
      final ids = AppShell.navItems.map((i) => i.id).toSet();
      expect(ids.length, AppShell.navItems.length);
    });

    test('navigation items have distinct icons', () {
      final icons = AppShell.navItems.map((i) => i.icon).toSet();
      expect(icons.length, AppShell.navItems.length);
    });
  });

  group('AppShell responsive breakpoint contract', () {
    testWidgets('sidebar hidden below 600px', (tester) async {
      tester.view.physicalSize = const Size(599, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_pumpShellApp(_buildShellRouter()));
      await tester.pumpAndSettle();

      expect(find.byType(PrismSidebar), findsNothing);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('sidebar visible at exactly 600px', (tester) async {
      tester.view.physicalSize = const Size(600, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_pumpShellApp(_buildShellRouter()));
      await tester.pumpAndSettle();

      // At exactly 600px (narrow breakpoint), sidebar should be visible
      expect(find.byType(PrismSidebar), findsWidgets);
      expect(find.byType(BottomNavigationBar), findsNothing);
    });

    testWidgets('sidebar present at sidebarCollapse threshold (800px)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_pumpShellApp(_buildShellRouter()));
      await tester.pumpAndSettle();

      expect(find.byType(PrismSidebar), findsWidgets);
      expect(find.byType(PrismShellResponsive), findsOneWidget);
    });
  });
}
