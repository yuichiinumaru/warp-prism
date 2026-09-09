import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_cybercore/data/fixtures/fixtures.dart';
import 'package:warp_prism_cybercore/features/providers/providers_page.dart';
import 'package:warp_prism_cybercore/main.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

void main() {
  setUp(() {
    PrismTokenRegistry.instance.reset();
  });

  tearDown(() {
    PrismTokenRegistry.instance.reset();
  });

  group('CyberCore shell chrome teal propagation tests (no-registry mutation)', () {
    testWidgets('Header gradient resolves teal (#00FFCC) from theme in wide mode', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(WarpPrismCyberCoreApp());
      await tester.pump();
      await tester.pump();

      // Verify that the global token registry was NOT mutated to teal
      expect(
        PrismTokenRegistry.instance.accentBlue,
        const Color(0xFF2F81FF),
        reason: 'Registry must stay pristine (Khalai Blue) without production mutation',
      );

      // Find the header logo container with gradient
      final containers = tester.widgetList<Container>(find.byType(Container));
      bool foundTealHeaderGradient = false;

      for (final container in containers) {
        final decoration = container.decoration;
        if (decoration is BoxDecoration && decoration.gradient is LinearGradient) {
          final gradient = decoration.gradient! as LinearGradient;
          if (gradient.colors.length == 2 &&
              gradient.colors[0] == const Color(0xFF00FFCC) &&
              gradient.colors[1] == const Color(0xFF00B894)) {
            foundTealHeaderGradient = true;
            break;
          }
        }
      }

      expect(
        foundTealHeaderGradient,
        isTrue,
        reason: 'CyberCore header gradient must resolve teal and muted teal from theme context',
      );
    });

    testWidgets('Compact shell bottom-nav selectedItemColor resolves teal (#00FFCC)', (tester) async {
      // Set compact viewport < 600px
      tester.view.physicalSize = const Size(500, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(WarpPrismCyberCoreApp());
      await tester.pump();
      await tester.pump();

      final bottomNavFinder = find.byType(BottomNavigationBar);
      expect(bottomNavFinder, findsOneWidget);

      final bottomNav = tester.widget<BottomNavigationBar>(bottomNavFinder);
      expect(
        bottomNav.selectedItemColor,
        const Color(0xFF00FFCC),
        reason: 'Compact bottom navigation selected item color must resolve teal from theme context',
      );

      // Verify registry was not mutated
      expect(
        PrismTokenRegistry.instance.accentBlue,
        const Color(0xFF2F81FF),
        reason: 'Registry must not be mutated by compact shell rendering',
      );
    });

    testWidgets('Feature story panels resolve teal (#00FFCC) from theme', (tester) async {
      final theme = const PrismCyberCoreTealSkin.omniRoute().applyToTheme(
        PrismTheme.dark(),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: ProvidersPage(
              loader: () async => const [
                ProviderConnection(
                  id: 'prov-openai-prod',
                  provider: 'openai',
                  name: 'OpenAI Production',
                  authType: 'apikey',
                  priority: 1,
                  defaultModel: 'gpt-4o',
                  isActive: true,
                  testStatus: 'success',
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      final storyPanels = tester.widgetList<PrismStoryPanel>(find.byType(PrismStoryPanel));
      expect(storyPanels, isNotEmpty);

      for (final panel in storyPanels) {
        expect(
          panel.accentColor,
          const Color(0xFF00FFCC),
          reason: 'Story panel accentColor must resolve teal from theme',
        );
      }
    });
  });
}

