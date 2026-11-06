// Catalog host adapter for the real-host UI exercise harness.
//
// Supplies ONLY host-specific deltas: bootstrap, route entrypoints,
// safe-action policy extras, fixture/reset mechanism, and excluded
// external/destructive surfaces. The shared crawler, oracle, and trace
// machinery live in `warp_prism_host_exercise` (no duplication).
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_catalog/main.dart';
import 'package:warp_prism_host_exercise/warp_prism_host_exercise.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// Canonical Catalog smoke path: gallery ⇄ connected lab round trip.
const catalogSmokeTargets = <String>[
  'key:catalog-nav-connected-lab',
  'key:catalog-nav-gallery',
];

/// Builds the default Catalog exercise config for [mode].
HostExerciseConfig catalogExerciseConfig({
  String mode = 'smoke',
  int seed = 0,
  int actionBudget = 12,
  ExerciseViewport viewport = ExerciseViewport.desktop1280x800,
  String themeRecipeId = 'khalai-blue',
}) {
  return HostExerciseConfig(
    host: 'catalog',
    initialRoute: 'gallery',
    smokeTargets: catalogSmokeTargets,
    viewport: viewport,
    themeRecipeId: themeRecipeId,
    actionBudget: mode == 'smoke' ? catalogSmokeTargets.length : actionBudget,
    seed: seed,
  );
}

/// Deterministic reset: fresh app shell + default theme recipe + clean
/// token registry.
///
/// Uses [KeyedSubtree] with [UniqueKey] to force full element tree
/// teardown/rebuild. Without this, Flutter's reconciler reuses the
/// existing app element and scroll/expansion state from a prior run
/// survives, making below-fold targets unreachable during replay.
Future<void> resetAndPumpCatalog(WidgetTester tester) async {
  catalogThemeVariant.value = CatalogThemeVariant.khalaiBlue;
  PrismTokenRegistry.instance.reset();
  // Physics disabled: the connected-lab graph simulation owns perpetual
  // animations that never settle; static layout is the deterministic
  // exercise surface (interaction coverage is unchanged).
  // UniqueKey forces full element rebuild on reset within a single
  // testWidgets scope (critical for fuzz → replay determinism).
  await tester.pumpWidget(
    KeyedSubtree(
      key: UniqueKey(),
      child: const WarpPrismCatalogApp(enablePhysics: false),
    ),
  );
}

/// Reads the logical Catalog route from the live tree (no private state).
String currentCatalogRoute() {
  final connected = find.byType(ConnectedBridgeLabPage).evaluate().isNotEmpty;
  return connected ? 'connected-lab' : 'gallery';
}

/// Applies a theme recipe without reconstructing the route (mirrors the
/// Catalog header dropdown wiring in `apps/catalog/lib/main.dart`).
Future<void> applyCatalogThemeRecipe(
  WidgetTester tester,
  String recipeId,
) async {
  switch (recipeId) {
    case 'taldarim-red':
      catalogThemeVariant.value = CatalogThemeVariant.taldarimRed;
      PrismTokenRegistry.instance.applySkin(
        const PrismTaldarimRedSkin.taldarimRed(),
      );
    case 'talon-purple':
      catalogThemeVariant.value = CatalogThemeVariant.talonPurple;
      PrismTokenRegistry.instance.applySkin(
        const PrismTalonPurpleSkin.talonPurple(),
      );
    case 'nerazim-teal':
      catalogThemeVariant.value = CatalogThemeVariant.nerazimTeal;
      PrismTokenRegistry.instance.applySkin(
        const PrismNerazimTealSkin.nerazimTeal(),
      );
    default:
      catalogThemeVariant.value = CatalogThemeVariant.khalaiBlue;
      PrismTokenRegistry.instance.reset();
  }
  await tester.pump();
}

/// Bundles the Catalog callbacks for [ExerciseRunner].
ExerciseRunCallbacks catalogCallbacks(WidgetTester tester) {
  return ExerciseRunCallbacks(
    resetAndPump: () => resetAndPumpCatalog(tester),
    currentRoute: currentCatalogRoute,
    applyThemeRecipe: (recipeId) => applyCatalogThemeRecipe(tester, recipeId),
  );
}
