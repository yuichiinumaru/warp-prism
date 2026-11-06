// CyberCore host adapter for the real-host UI exercise harness.
//
// Supplies ONLY host-specific deltas: bootstrap, route entrypoints,
// safe-action policy, fixture/reset mechanism, and excluded surfaces.
// CyberCore exposes `createAppRouter()` (test-safe factory) unlike the
// Observatory singleton, so reset constructs a fresh router each time —
// the cheapest fully deterministic reset of the three hosts.
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:warp_prism_cybercore/app/router.dart' as cybercore;
import 'package:warp_prism_cybercore/main.dart' as cybercore_app;
import 'package:warp_prism_host_exercise/warp_prism_host_exercise.dart';

/// Canonical CyberCore smoke path: four pilot branches via sidebar.
const cybercoreSmokeTargets = <String>[
  'sem:MCP Servers',
  'sem:MCP Inspector',
  'sem:Live Logs',
  'sem:Providers',
];

/// Builds the default CyberCore exercise config for [mode].
HostExerciseConfig cybercoreExerciseConfig({
  String mode = 'smoke',
  int seed = 0,
  int actionBudget = 12,
  ExerciseViewport viewport = ExerciseViewport.desktop1280x800,
  String themeRecipeId = 'nerazim-teal',
}) {
  return HostExerciseConfig(
    host: 'cybercore',
    initialRoute: '/providers',
    smokeTargets: cybercoreSmokeTargets,
    viewport: viewport,
    themeRecipeId: themeRecipeId,
    actionBudget: mode == 'smoke' ? cybercoreSmokeTargets.length : actionBudget,
    seed: seed,
  );
}

/// Router created by the most recent reset — route reads go through it.
GoRouter? _activeRouter;

/// Deterministic reset: fresh GoRouter factory + fresh KeyedSubtree app
/// shell (UniqueKey forces full element teardown so no state survives).
///
/// CyberCore applies its teal skin inside `WarpPrismCyberCoreApp.build`,
/// so a fresh pump keeps token-registry state deterministic (Task 1833).
Future<void> resetAndPumpCybercore(WidgetTester tester) async {
  final router = cybercore.createAppRouter();
  _activeRouter = router;
  await tester.pumpWidget(
    KeyedSubtree(
      key: UniqueKey(),
      child: TickerMode(
        enabled: false,
        child: cybercore_app.WarpPrismCyberCoreApp(router: router),
      ),
    ),
  );
  await tester.pump();
}

/// Reads the current CyberCore route from the active router.
String currentCybercoreRoute() {
  return _activeRouter?.routeInformationProvider.value.uri.path ?? '/providers';
}

/// Bundles the CyberCore callbacks for [ExerciseRunner].
///
/// Theme recipe switching is NOT supported for this adapter: the teal
/// skin is a product-scoped opt-in applied at app construction (Task
/// 1833 scoped-opt-in contract), not a runtime-switchable recipe. Recipe
/// propagation is exercised on the Catalog host instead.
ExerciseRunCallbacks cybercoreCallbacks(WidgetTester tester) {
  return ExerciseRunCallbacks(
    resetAndPump: () => resetAndPumpCybercore(tester),
    currentRoute: currentCybercoreRoute,
  );
}
