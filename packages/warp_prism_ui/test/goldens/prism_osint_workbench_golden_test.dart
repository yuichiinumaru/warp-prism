@Tags(['golden'])
library;

// Golden tests for PrismOsintWorkbench — EPIC-15 CyberCore recon default.
//
// Task 1520. Fixed surface size + public fixture tools; idle default state
// (no submit) for deterministic chrome. No live OSINT APIs / network.
//
// Run from packages/warp_prism_ui/:
//   flutter test --update-goldens test/goldens/prism_osint_workbench_golden_test.dart
//   flutter test test/goldens/prism_osint_workbench_golden_test.dart

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
  group('PrismOsintWorkbench golden — default state', () {
    testWidgets('renders default idle PrismOsintWorkbench fixture tools', (
      tester,
    ) async {
      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });

      await tester.binding.setSurfaceSize(const Size(800, 600));

      final tools = PrismOsintFixtures.minimalTools();

      await tester.pumpWidget(
        _inApp(
          SizedBox(
            width: 720,
            height: 560,
            child: PrismOsintWorkbench(
              tools: tools,
              initialToolId: 'dns',
              isLoading: false,
              showHistory: true,
            ),
          ),
        ),
      );

      await tester.pump();

      await expectLater(
        find.byType(PrismOsintWorkbench),
        matchesGoldenFile('goldens/prism_osint_workbench_default.png'),
      );
    });
  });
}
