@Tags(['golden'])
library;

// Golden tests for PrismMapHudWorkspace — EPIC-15 HUD workspace default.
//
// Task 1520. Fixed surface size + deterministic fixture chrome only.
// No MapLibre / network.
//
// Run from packages/warp_prism_ui/:
//   flutter test --update-goldens test/goldens/prism_map_hud_workspace_golden_test.dart
//   flutter test test/goldens/prism_map_hud_workspace_golden_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

Widget _inApp(Widget child) {
  return MaterialApp(
    theme: PrismTheme.dark(),
    home: Scaffold(backgroundColor: PrismColors.obsidianBase, body: child),
  );
}

Widget _slotLabel(String text) {
  return Padding(
    padding: const EdgeInsets.all(PrismSpacing.sm),
    child: PrismText.labelMedium(text, color: PrismColors.textSecondary),
  );
}

void main() {
  group('PrismMapHudWorkspace golden — default state', () {
    testWidgets('renders default PrismMapHudWorkspace with HUD regions', (
      tester,
    ) async {
      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });

      await tester.binding.setSurfaceSize(const Size(1200, 800));

      await tester.pumpWidget(
        _inApp(
          SizedBox(
            width: 1200,
            height: 800,
            child: PrismMapHudWorkspace(
              stage: ColoredBox(
                color: PrismColors.obsidianElevated,
                child: const Center(
                  child: PrismText.bodyMedium(
                    'Fixture stage — no MapLibre',
                    color: PrismColors.textTertiary,
                  ),
                ),
              ),
              leftHud: _slotLabel('Left HUD'),
              rightHud: _slotLabel('Right HUD'),
              bottomChrome: _slotLabel('Bottom chrome'),
              topChrome: _slotLabel('Top chrome'),
              // Controlled visible so toggle focus/hover cannot drift the frame.
              hudVisible: true,
              showHudToggle: true,
            ),
          ),
        ),
      );

      // Single frame only — no pumpAndSettle (avoid animation settle flakiness).
      await tester.pump();

      await expectLater(
        find.byType(PrismMapHudWorkspace),
        matchesGoldenFile('goldens/prism_map_hud_workspace_default.png'),
      );
    });
  });
}
