// Golden tests for PrismProviderHealthMatrix — EPIC-16 CyberCore ops default.
//
// Task 1614. Fixed surface size + public minimal fixture only.
//
// Run from packages/warp_prism_ui/:
//   flutter test --update-goldens test/goldens/prism_provider_health_matrix_golden_test.dart
//   flutter test test/goldens/prism_provider_health_matrix_golden_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

Widget _inApp(Widget child) {
  return MaterialApp(
    theme: ThemeData.dark(),
    home: Scaffold(backgroundColor: PrismColors.obsidianBase, body: child),
  );
}

void main() {
  group('PrismProviderHealthMatrix golden — default state', () {
    testWidgets('renders default PrismProviderHealthMatrix fixture', (
      tester,
    ) async {
      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });

      await tester.binding.setSurfaceSize(const Size(800, 420));

      final providers = prismProviderHealthMatrixMinimalFixture();

      await tester.pumpWidget(
        _inApp(PrismProviderHealthMatrix(providers: providers)),
      );

      await tester.pump();

      await expectLater(
        find.byType(PrismProviderHealthMatrix),
        matchesGoldenFile('goldens/prism_provider_health_matrix_default.png'),
      );
    });
  });
}
