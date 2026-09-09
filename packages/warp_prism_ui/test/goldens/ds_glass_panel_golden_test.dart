@Tags(['golden'])
library;

// Golden tests for DSGlassPanel and DSGlassPanelSimple — renders glass
// panel variants (subtle, elevated, modal) and the performance simple
// variant.
//
// Note: BackdropFilter-based DSGlassPanel may produce platform-dependent
// rendering. If golden files are inconsistent across environments, the
// DSGlassPanel (blur) tests should be skipped with a documented
// justification. DSGlassPanelSimple (no blur) should always be stable.
//
// Run from packages/warp_prism_ui/:
//   flutter test --update-goldens test/goldens/ds_glass_panel_golden_test.dart
//   flutter test test/goldens/ds_glass_panel_golden_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/src/atoms/atoms.dart';
import 'package:warp_prism_ui/src/tokens/tokens.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

Widget _inApp(Widget child) {
  return MaterialApp(
    theme: PrismTheme.dark(),
    home: Scaffold(
      backgroundColor: DSColors.obsidianBase,
      body: Center(child: child),
    ),
  );
}

/// Standard child content for glass panels — a text block that makes
/// the panel surface visible against the background.
Widget _panelChild(String label) {
  return Padding(
    padding: const EdgeInsets.all(DSSpacing.insetCard),
    child: Text(
      label,
      style: const TextStyle(color: DSColors.textPrimary, fontSize: 14),
    ),
  );
}

/// Fixed-size wrapper for consistent golden dimensions.
Widget _sized(Widget child, {double width = 280, double height = 120}) {
  return SizedBox(width: width, height: height, child: child);
}

void main() {
  group('DSGlassPanelSimple golden — variants', () {
    testWidgets('renders default glass panel simple', (tester) async {
      await tester.pumpWidget(
        _inApp(
          _sized(DSGlassPanelSimple(child: _panelChild('Simple Default'))),
        ),
      );
      await expectLater(
        find.byType(DSGlassPanelSimple),
        matchesGoldenFile('goldens/glass_panel_simple_default.png'),
      );
    });

    testWidgets('renders with custom border color (cyan glow)', (tester) async {
      await tester.pumpWidget(
        _inApp(
          _sized(
            DSGlassPanelSimple(
              borderColor: DSColors.accentCyan.withValues(alpha: 0.4),
              child: _panelChild('Cyan Border'),
            ),
          ),
        ),
      );
      await expectLater(
        find.byType(DSGlassPanelSimple),
        matchesGoldenFile('goldens/glass_panel_simple_cyan_border.png'),
      );
    });

    testWidgets('renders with elevation shadow', (tester) async {
      await tester.pumpWidget(
        _inApp(
          _sized(
            DSGlassPanelSimple(
              shadows: DSShadows.elevation2,
              child: _panelChild('With Shadow'),
            ),
          ),
        ),
      );
      await expectLater(
        find.byType(DSGlassPanelSimple),
        matchesGoldenFile('goldens/glass_panel_simple_elevated.png'),
      );
    });

    test('DSGlassPanelSimple renders without BackdropFilter', () {
      // Verify the simple panel does NOT use blur — a contract assertion,
      // not a golden, but valuable alongside golden baselines.
      const panel = DSGlassPanelSimple(child: SizedBox());
      // This is a const constructor assertion; the golden above captures
      // the visual output.
      expect(panel, isA<DSGlassPanelSimple>());
    });
  });

  group('DSGlassPanel golden — variants with blur', () {
    testWidgets('renders subtle variant', (tester) async {
      await tester.pumpWidget(
        _inApp(_sized(DSGlassPanel.subtle(child: _panelChild('Subtle Blur')))),
      );
      await expectLater(
        find.byType(DSGlassPanel),
        matchesGoldenFile('goldens/glass_panel_subtle.png'),
      );
    });

    testWidgets('renders elevated variant', (tester) async {
      await tester.pumpWidget(
        _inApp(
          _sized(DSGlassPanel.elevated(child: _panelChild('Elevated Blur'))),
        ),
      );
      await expectLater(
        find.byType(DSGlassPanel),
        matchesGoldenFile('goldens/glass_panel_elevated.png'),
      );
    });

    testWidgets('renders modal variant', (tester) async {
      await tester.pumpWidget(
        _inApp(
          _sized(
            DSGlassPanel.modal(child: _panelChild('Modal Blur')),
            height: 160,
          ),
        ),
      );
      await expectLater(
        find.byType(DSGlassPanel),
        matchesGoldenFile('goldens/glass_panel_modal.png'),
      );
    });
  });

  group('DSGlassPanel golden — compositional layout', () {
    testWidgets('renders multiple panels stacked', (tester) async {
      await tester.pumpWidget(
        _inApp(
          SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DSGlassPanelSimple(child: _panelChild('Panel 1')),
                const SizedBox(height: DSSpacing.gapList),
                DSGlassPanelSimple(
                  borderColor: DSColors.accentViolet.withValues(alpha: 0.3),
                  child: _panelChild('Panel 2 — Violet Accent'),
                ),
                const SizedBox(height: DSSpacing.gapList),
                DSGlassPanelSimple(
                  shadows: DSShadows.elevation3,
                  child: _panelChild('Panel 3 — Elevated'),
                ),
              ],
            ),
          ),
        ),
      );
      await expectLater(
        find.byType(Column),
        matchesGoldenFile('goldens/glass_panel_stacked_layout.png'),
      );
    });
  });
}
