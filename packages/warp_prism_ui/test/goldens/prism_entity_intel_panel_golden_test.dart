@Tags(['golden'])
library;

// Golden tests for PrismEntityIntelPanel — EPIC-15 intel organism default.
//
// Task 1520. Fixed surface size + public fixture selection/registry only.
//
// Run from packages/warp_prism_ui/:
//   flutter test --update-goldens test/goldens/prism_entity_intel_panel_golden_test.dart
//   flutter test test/goldens/prism_entity_intel_panel_golden_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

Widget _inApp(Widget child) {
  return MaterialApp(
    theme: PrismTheme.dark(),
    home: Scaffold(backgroundColor: PrismColors.obsidianBase, body: child),
  );
}

void main() {
  group('PrismEntityIntelPanel golden — default state', () {
    testWidgets('renders default agent dossier PrismEntityIntelPanel', (
      tester,
    ) async {
      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });

      await tester.binding.setSurfaceSize(const Size(400, 560));

      await tester.pumpWidget(
        _inApp(
          SizedBox(
            width: 360,
            height: 520,
            child: PrismEntityIntelPanel(
              selection: PrismEntityIntelFixtures.agent,
              bodyBuilders: PrismEntityIntelFixtures.sampleBodyBuilders(),
              onClose: () {},
              showPin: true,
              pinned: false,
            ),
          ),
        ),
      );

      await tester.pump();

      await expectLater(
        find.byType(PrismEntityIntelPanel),
        matchesGoldenFile('goldens/prism_entity_intel_panel_default.png'),
      );
    });
  });
}
