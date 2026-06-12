// Golden tests for DSText — renders text atom with default bodyMedium variant.
//
// Run from packages/warp_prism_ui/:
//   flutter test --update-goldens test/goldens/ds_text_golden_test.dart
//   flutter test test/goldens/ds_text_golden_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/src/atoms/atoms.dart';
import 'package:warp_prism_ui/src/tokens/tokens.dart';

Widget _inApp(Widget child) {
  return MaterialApp(
    theme: ThemeData.dark(),
    home: Scaffold(
      backgroundColor: DSColors.obsidianBase,
      body: Center(child: child),
    ),
  );
}

void main() {
  group('DSText golden — default state', () {
    testWidgets('renders default DSText.bodyMedium', (tester) async {
      await tester.pumpWidget(
        _inApp(const DSText.bodyMedium('Hello, Warp Prism')),
      );
      await expectLater(
        find.byType(DSText),
        matchesGoldenFile('goldens/text_default.png'),
      );
    });
  });
}
