// Catalog THEME MATRIX exercise: recipe switching without route
// reconstruction, proving functional theme propagation and role behavior
// (NOT human aesthetic approval — that gate stays with Task 1805).
//
// Recipe ladder: Khalai Blue → Taldarim Red → Talon Purple → CyberCore
// Teal → back to Khalai Blue, each followed by a canonical interaction
// under the strict error oracle (stale-propagation defects surface as
// FlutterError / ErrorWidget / exception events).
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_host_exercise/warp_prism_host_exercise.dart';

import 'catalog_host.dart';

void main() {
  testWidgets('theme matrix: A→B→C→D→A recipes survive live exercise', (
    tester,
  ) async {
    final oracle = ExerciseErrorCollector()..install();
    addTearDown(oracle.uninstall);

    final config = catalogExerciseConfig(mode: 'crawl', actionBudget: 4);
    ExerciseRunner.applyViewport(tester, config.viewport);
    await resetAndPumpCatalog(tester);
    await ExerciseRunner.pumpAndEnforce(tester, oracle, 'theme-reset');

    const recipeLadder = <String>[
      'khalai-blue',
      'taldarim-red',
      'talon-purple',
      'nerazim-teal',
      'khalai-blue',
    ];

    for (final recipe in recipeLadder) {
      await applyCatalogThemeRecipe(tester, recipe);
      await ExerciseRunner.pumpAndEnforce(
        tester,
        oracle,
        'theme-switch:$recipe',
      );

      // Exercise a canonical interaction under this recipe: nav to
      // connected-lab and back (theme must propagate to the rebuilt route).
      final navToLab = ExerciseActionDiscovery.resolveFinder(
        tester,
        'key:catalog-nav-connected-lab',
      );
      if (navToLab != null && navToLab.evaluate().isNotEmpty) {
        await tester.tap(navToLab.first);
        await ExerciseRunner.pumpAndEnforce(
          tester,
          oracle,
          'theme-exercise:$recipe:connected-lab',
        );
      }
      final navToGallery = ExerciseActionDiscovery.resolveFinder(
        tester,
        'key:catalog-nav-gallery',
      );
      if (navToGallery != null && navToGallery.evaluate().isNotEmpty) {
        await tester.tap(navToGallery.first);
        await ExerciseRunner.pumpAndEnforce(
          tester,
          oracle,
          'theme-exercise:$recipe:gallery',
        );
      }
    }

    expect(
      oracle.hasMaterialError,
      isFalse,
      reason:
          'THEME MATRIX must propagate all recipes without framework errors: '
          '${oracle.materialMessages.join('\n')}',
    );
  });

  testWidgets('theme matrix: viewport × recipe spot (wide + compact)', (
    tester,
  ) async {
    // Wide desktop: must be error-free.
    {
      final oracle = ExerciseErrorCollector()..install();
      addTearDown(oracle.uninstall);
      final config = catalogExerciseConfig(
        mode: 'smoke',
        viewport: ExerciseViewport.wide1920x1080,
      );
      final trace = await ExerciseRunner.runSmoke(
        tester: tester,
        config: config,
        callbacks: catalogCallbacks(tester),
        oracle: oracle,
      );
      expect(
        trace.errors,
        isEmpty,
        reason:
            'SMOKE @ wide-1920x1080 must be error-free: '
            '${trace.errors.join('\n')}',
      );
    }

    // Compact 390x844: KNOWN PRODUCT DEFECT calibration control.
    //
    // The gallery header Row (design_system_gallery_page.dart:136)
    // overflows horizontally under compact viewports. The harness MUST
    // detect this; when the product fix lands, this expectation flips
    // red — remove this calibration block and restore the error-free
    // assertion at that point.
    //
    // Finding: docs/reports/host-exercise/finding-catalog-compact-overflow.md
    {
      final oracle = ExerciseErrorCollector()..install();
      addTearDown(oracle.uninstall);
      final config = catalogExerciseConfig(
        mode: 'smoke',
        viewport: ExerciseViewport.compact390x844,
      );
      // softFail: collect the known defect into trace.errors instead of
      // throwing, so the calibration can assert detection (below).
      final trace = await ExerciseRunner.runSmoke(
        tester: tester,
        config: config,
        callbacks: catalogCallbacks(tester),
        oracle: oracle,
        softFail: true,
      );
      expect(
        trace.errors,
        isNotEmpty,
        reason:
            'KNOWN DEFECT CALIBRATION: compact viewport overflow must be '
            'detected (see finding-catalog-compact-overflow.md). If this '
            'assertion fails, the product fix landed — remove the '
            'calibration and require error-free.',
      );
      expect(
        trace.errors.any((e) => e.contains('RenderFlex overflowed')),
        isTrue,
        reason: 'calibration must catch the overflow defect class',
      );
    }
  });
}
