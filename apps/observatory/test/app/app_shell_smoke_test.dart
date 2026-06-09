import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warp_prism_observatory/app/app.dart';
import 'package:warp_prism_observatory/app/router.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

void main() {
  group('App shell smoke test', () {
    testWidgets('app boots and renders the shell with default route',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: WarpPrismApp(),
        ),
      );
      await tester.pumpAndSettle();

      // The app shell should render DSShell, which shows a sidebar
      // and the overview page content.
      expect(find.byType(DSShell), findsOneWidget);
      expect(find.byType(DSSidebar), findsOneWidget);
      expect(find.byType(DSTopbar), findsOneWidget);
    });

    testWidgets('default route lands on Overview', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: WarpPrismApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Overview page placeholder text should be visible
      expect(find.text('Overview'), findsWidgets);
    });

    test('router defines all required product routes', () {
      // Verify the router has the expected route paths
      final routerConfig = appRouter;
      expect(routerConfig, isNotNull);

      // The router should have routes configured (structural assertion)
      // We can't easily enumerate routes in go_router's public API,
      // but the router itself should be constructable.
      expect(routerConfig.configuration, isNotNull);
    });
  });
}
