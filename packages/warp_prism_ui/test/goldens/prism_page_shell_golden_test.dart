// Golden tests for PrismPageShell — EPIC-16 content chrome default state.
//
// Task 1614. Fixed surface size + deterministic fixture only.
//
// Run from packages/warp_prism_ui/:
//   flutter test --update-goldens test/goldens/prism_page_shell_golden_test.dart
//   flutter test test/goldens/prism_page_shell_golden_test.dart

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
  group('PrismPageShell golden — default state', () {
    testWidgets('renders default PrismPageShell content chrome', (
      tester,
    ) async {
      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });

      await tester.binding.setSurfaceSize(const Size(800, 480));

      await tester.pumpWidget(
        _inApp(
          PrismPageShell.icon(
            title: 'Providers',
            subtitle: 'Fixture demo — LLM accounts and model health',
            icon: Icons.cloud_outlined,
            accentColor: PrismColors.accentCyan,
            actions: const [
              PrismBadge(label: '12 active', color: PrismColors.statusSuccess),
            ],
            toolbar: const Row(
              children: [
                Expanded(
                  child: PrismText.bodySmall(
                    'Filter · All regions · Healthy only',
                    color: PrismColors.textTertiary,
                  ),
                ),
                PrismChip(label: 'Refresh'),
              ],
            ),
            child: const PrismGlassPanelSimple(
              padding: EdgeInsets.all(PrismSpacing.md),
              child: PrismText.bodyMedium(
                'Page body slot — compose tables, inspectors, or ops matrices here.',
                color: PrismColors.textSecondary,
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      await expectLater(
        find.byType(PrismPageShell),
        matchesGoldenFile('goldens/prism_page_shell_default.png'),
      );
    });
  });
}
