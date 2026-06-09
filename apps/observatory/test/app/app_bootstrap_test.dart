import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:warp_prism_observatory/app/app.dart';

/// Task 0017: Design System Gallery Route Bootstrap
///
/// Widget test proving that the app initializes correctly and the
/// gallery route is reachable.
void main() {
  group('App Bootstrap', () {
    testWidgets('WarpPrismApp renders MaterialApp.router', (tester) async {
      await tester.pumpWidget(const WarpPrismApp());

      // MaterialApp is created
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('app uses dark theme with obsidian background', (
      tester,
    ) async {
      await tester.pumpWidget(const WarpPrismApp());

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      final theme = materialApp.theme;

      expect(theme, isNotNull);
      expect(theme!.brightness, Brightness.dark);
      expect(theme.scaffoldBackgroundColor, const Color(0xFF050508)); // obsidianDeep
    });

    testWidgets('app initial location is /design-system', (tester) async {
      await tester.pumpWidget(const WarpPrismApp());
      await tester.pumpAndSettle();

      // The gallery page should be the initial route
      expect(find.text('Design System Gallery'), findsOneWidget);
    });
  });
}
