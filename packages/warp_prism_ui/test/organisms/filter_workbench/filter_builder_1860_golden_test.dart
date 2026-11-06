@Tags(['golden'])
library;

// Fixed-viewport goldens for the filter-builder seam (Task 1860, F-12).
//
// Determinism: fixed 800x600 / 600x420 hosts, `disableAnimations`, settled
// pumps. The `_elapsed` twins elapse 10s of fake time before capture and
// verify the SAME baseline — proving capture does not depend on animation
// or wall-clock state.
//
// EXPERIMENTAL: imports via src paths; no barrel export yet.
// Mint: flutter test --update-goldens <this file>
// Verify: flutter test <this file>

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/src/atoms/ds_text.dart';
import 'package:warp_prism_ui/src/organisms/filter_workbench/ds_filter_builder.dart';
import 'package:warp_prism_ui/src/organisms/filter_workbench/ds_filter_builder_model.dart';
import 'package:warp_prism_ui/src/organisms/filter_workbench/ds_toolbar_panel.dart';
import 'package:warp_prism_ui/src/theme/ds_theme.dart';
import 'package:warp_prism_ui/src/tokens/tokens.dart';

Widget _inApp(Widget child, {Size size = const Size(800, 600)}) {
  return MaterialApp(
    theme: DSTheme.dark(),
    home: Scaffold(
      backgroundColor: DSColors.obsidianDeep,
      body: MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: SizedBox.fromSize(size: size, child: child),
      ),
    ),
  );
}

Widget _builder({DSFilterGroup? tree}) => DSFilterBuilder(
  fields: DSFilterBuilderFake.fixtureFields(),
  initialTree: tree ?? DSFilterBuilderFake.fixtureTree(),
  commitDelay: const Duration(minutes: 5),
);

Widget _toolbar() => DSToolbarPanel(
  buttonLabel: 'Panels',
  options: const [
    DSToolbarPanelOption(id: 'filters', label: 'Filters'),
    DSToolbarPanelOption(id: 'views', label: 'Views'),
  ],
  panelBuilder: (context, panelId, close) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      DSText.labelLarge('Typed panel: $panelId', color: DSColors.textPrimary),
      const SizedBox(height: DSSpacing.sm),
      DSText.labelSmall(
        'Deterministic fixture body',
        color: DSColors.textSecondary,
      ),
    ],
  ),
);

void main() {
  group('filter_1860 builder golden', () {
    testWidgets('fixture tree at fixed viewport', (tester) async {
      await tester.pumpWidget(_inApp(_builder()));
      await tester.pumpAndSettle();

      await expectLater(
        find.byKey(DSFilterBuilder.panelKey),
        matchesGoldenFile('goldens/filter_1860_builder.png'),
      );
    });

    testWidgets('elapsed twin matches the same baseline', (tester) async {
      await tester.pumpWidget(_inApp(_builder()));
      await tester.pumpAndSettle();
      // Elapse far past any micro-animation budget, then settle again.
      await tester.pump(const Duration(seconds: 10));
      await tester.pumpAndSettle();

      await expectLater(
        find.byKey(DSFilterBuilder.panelKey),
        matchesGoldenFile('goldens/filter_1860_builder.png'),
      );
    });

    testWidgets('empty tree at fixed viewport', (tester) async {
      await tester.pumpWidget(
        _inApp(_builder(tree: DSFilterBuilderFake.emptyTree())),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byKey(DSFilterBuilder.panelKey),
        matchesGoldenFile('goldens/filter_1860_builder_empty.png'),
      );
    });
  });

  group('filter_1860 toolbar panel golden', () {
    testWidgets('closed anchor at fixed viewport', (tester) async {
      await tester.pumpWidget(
        _inApp(Center(child: _toolbar()), size: const Size(600, 200)),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byKey(DSToolbarPanel.buttonKey),
        matchesGoldenFile('goldens/filter_1860_toolbar_closed.png'),
      );
    });

    testWidgets('open popover at fixed viewport', (tester) async {
      await tester.pumpWidget(
        _inApp(Center(child: _toolbar()), size: const Size(600, 420)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(DSToolbarPanel.buttonKey));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/filter_1860_toolbar_popover.png'),
      );
    });

    testWidgets('open popover elapsed twin matches baseline', (tester) async {
      await tester.pumpWidget(
        _inApp(Center(child: _toolbar()), size: const Size(600, 420)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(DSToolbarPanel.buttonKey));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 10));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/filter_1860_toolbar_popover.png'),
      );
    });
  });
}
