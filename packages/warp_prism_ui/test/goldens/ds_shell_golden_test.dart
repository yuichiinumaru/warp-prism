// Golden tests for DSShell — renders shell organism with fixed viewport
// and deterministic children.
//
// Run from packages/warp_prism_ui/:
//   flutter test --update-goldens test/goldens/ds_shell_golden_test.dart
//   flutter test test/goldens/ds_shell_golden_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/src/organisms/ds_shell.dart';
import 'package:warp_prism_ui/src/tokens/tokens.dart';
import 'package:warp_prism_ui/src/atoms/atoms.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

Widget _inApp(Widget child) {
  return MaterialApp(
    theme: PrismTheme.dark(),
    home: Scaffold(backgroundColor: DSColors.obsidianBase, body: child),
  );
}

/// Deterministic sidebar for golden testing — fixed width with simple content.
Widget _testSidebar() {
  return Container(
    width: 200,
    color: DSColors.obsidianElevated,
    child: const Column(
      children: [
        Padding(
          padding: EdgeInsets.all(DSSpacing.md),
          child: DSText.labelMedium('Sidebar', color: DSColors.textSecondary),
        ),
      ],
    ),
  );
}

/// Deterministic topbar for golden testing — fixed height with simple content.
Widget _testTopbar() {
  return Container(
    height: 48,
    color: DSColors.obsidianElevated,
    padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md),
    child: const Row(
      children: [DSText.labelMedium('Topbar', color: DSColors.textSecondary)],
    ),
  );
}

/// Deterministic content for golden testing.
Widget _testContent() {
  return Container(
    color: DSColors.obsidianBase,
    child: const Center(child: DSText.bodyMedium('Main Content')),
  );
}

void main() {
  group('DSShell golden — default state', () {
    testWidgets('renders default DSShell with fixed viewport', (tester) async {
      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });

      // Fixed viewport size for deterministic golden baseline.
      await tester.binding.setSurfaceSize(const Size(1024, 768));

      await tester.pumpWidget(
        _inApp(
          DSShell(
            sidebar: _testSidebar(),
            topbar: _testTopbar(),
            content: _testContent(),
            showInspector: false,
          ),
        ),
      );

      await expectLater(
        find.byType(DSShell),
        matchesGoldenFile('goldens/shell_default.png'),
      );
    });
  });
}
