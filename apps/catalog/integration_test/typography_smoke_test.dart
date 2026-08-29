import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Typography Host Smoke', () {
    testWidgets(
      'renders explicit UI and technical typography fixtures and asserts Rajdhani and JetBrainsMono font families with fallback chains',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor: PrismColors.obsidianDeep,
              fontFamily: PrismTypography.fontFamilySans,
            ),
            home: const Scaffold(
              body: Column(
                children: [
                  Text(
                    'UI DISPLAY HEADER',
                    key: Key('typo-ui-text'),
                    style: PrismTypography.headingMedium,
                  ),
                  Text(
                    'ID: 1802-warp-prism-typography',
                    key: Key('typo-mono-text'),
                    style: PrismTypography.codeMedium,
                  ),
                  Text(
                    '42.8ms',
                    key: Key('typo-numeric-text'),
                    style: PrismTypography.numericSmall,
                  ),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // 1. Assert UI role fixture (Rajdhani)
        final uiTextFinder = find.byKey(const Key('typo-ui-text'));
        expect(uiTextFinder, findsOneWidget);
        final uiTextWidget = tester.widget<Text>(uiTextFinder);
        final uiStyle = uiTextWidget.style;
        expect(uiStyle, isNotNull);
        expect(uiStyle!.fontFamily, equals('Rajdhani'));
        expect(uiStyle.fontFamily, equals(PrismTypography.fontFamilySans));
        expect(
          uiStyle.fontFamilyFallback,
          equals(PrismTypography.fontFamilySansFallback),
        );
        expect(
          uiStyle.fontFamilyFallback,
          containsAll(['Roboto', 'Helvetica Neue', 'Arial', 'sans-serif']),
        );

        // 2. Assert Technical/Code role fixture (JetBrains Mono)
        final monoTextFinder = find.byKey(const Key('typo-mono-text'));
        expect(monoTextFinder, findsOneWidget);
        final monoTextWidget = tester.widget<Text>(monoTextFinder);
        final monoStyle = monoTextWidget.style;
        expect(monoStyle, isNotNull);
        expect(monoStyle!.fontFamily, equals('JetBrainsMono'));
        expect(monoStyle.fontFamily, equals(PrismTypography.fontFamilyMono));
        expect(
          monoStyle.fontFamilyFallback,
          equals(PrismTypography.fontFamilyMonoFallback),
        );
        expect(
          monoStyle.fontFamilyFallback,
          containsAll(['Courier New', 'monospace']),
        );

        // 3. Assert Numeric/Metrics role fixture (JetBrains Mono)
        final numTextFinder = find.byKey(const Key('typo-numeric-text'));
        expect(numTextFinder, findsOneWidget);
        final numTextWidget = tester.widget<Text>(numTextFinder);
        final numStyle = numTextWidget.style;
        expect(numStyle, isNotNull);
        expect(numStyle!.fontFamily, equals('JetBrainsMono'));
        expect(numStyle.fontFamily, equals(PrismTypography.fontFamilyMono));
        expect(
          numStyle.fontFamilyFallback,
          equals(PrismTypography.fontFamilyMonoFallback),
        );
      },
    );
  });
}
