import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// Task 0017 origin + Task 1407 rewrite.
///
/// Historical suite imported [WarpPrismApp] and asserted
/// `initialLocation == /design-system`. That is obsolete:
/// - Live router contract: `initialLocation: '/overview'`
///   (`lib/app/router.dart`).
/// - F-1407-03 resolved: `workspace_snapshot` now uses public `Prism*` APIs,
///   so the product router graph compiles again.
///
/// This suite keeps a focused bootstrap signal without re-importing the full
/// product router (full shell boot is covered by `app_shell_smoke_test.dart`):
/// 1. Dark / obsidian theme contract (matches `lib/app/app.dart`).
/// 2. Design System Gallery page still boots as a proof surface
///    (route `/design-system` remains registered; home is not gallery).
void main() {
  group('App Bootstrap', () {
    testWidgets('obsidian dark theme contract matches WarpPrismApp tokens', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(theme: PrismTheme.dark(), home: const SizedBox.shrink()),
      );

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      final theme = materialApp.theme;

      expect(theme, isNotNull);
      expect(theme!.brightness, Brightness.dark);
      expect(theme.textTheme.bodyMedium?.fontFamily, equals('Rajdhani'));
      expect(theme.scaffoldBackgroundColor, PrismColors.obsidianDeep);
    });

    testWidgets('Design System Gallery proof surface still renders', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: DesignSystemGalleryPage())),
      );
      await tester.pumpAndSettle();

      expect(find.text('Design System Gallery'), findsOneWidget);
    });

    testWidgets('MaterialApp.router can host shell-less proof routes', (
      tester,
    ) async {
      // Documents that gallery is a secondary route, not app home.
      // Product home remains /overview once WarpPrismApp boot is re-enabled.
      await tester.pumpWidget(
        MaterialApp.router(
          theme: PrismTheme.dark(),
          routerDelegate: _StaticRouterDelegate(
            child: const Scaffold(body: DesignSystemGalleryPage()),
          ),
          routeInformationParser: _StaticRouteInformationParser(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.text('Design System Gallery'), findsOneWidget);
    });
  });
}

/// Minimal router plumbing so MaterialApp.router can be pumped without
/// importing the product GoRouter graph (which pulls workspace_snapshot).
class _StaticRouterDelegate extends RouterDelegate<Object>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<Object> {
  _StaticRouterDelegate({required this.child});

  final Widget child;

  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: [MaterialPage<void>(child: child)],
      onDidRemovePage: (page) {},
    );
  }

  @override
  Future<void> setNewRoutePath(Object configuration) async {}
}

class _StaticRouteInformationParser extends RouteInformationParser<Object> {
  @override
  Future<Object> parseRouteInformation(
    RouteInformation routeInformation,
  ) async {
    return Object();
  }
}
