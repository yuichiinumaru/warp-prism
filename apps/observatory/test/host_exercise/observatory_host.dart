// Observatory host adapter for the real-host UI exercise harness.
//
// Supplies ONLY host-specific deltas: bootstrap, route entrypoints,
// safe-action policy, fixture/reset mechanism, and excluded surfaces.
// The shared crawler, oracle, and trace machinery live in
// `warp_prism_host_exercise` (no duplication).
//
// NOTE: runs headless in `flutter_tester`. The Observatory owns a global
// `appRouter` GoRouter singleton; each reset pumps a fresh KeyedSubtree
// shell and resets the router location to `/overview` — the canonical
// cheapest valid reset for this host without app process restart.
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_host_exercise/warp_prism_host_exercise.dart';
import 'package:warp_prism_observatory/app/app.dart';
import 'package:warp_prism_observatory/app/router.dart' as observatory;

/// Canonical Observatory smoke path: the five shell branches.
const observatorySmokeTargets = <String>[
  'sem:Map',
  'sem:Operate',
  'sem:History',
  'sem:Governance',
  'sem:Overview',
];

/// Builds the default Observatory exercise config for [mode].
HostExerciseConfig observatoryExerciseConfig({
  String mode = 'smoke',
  int seed = 0,
  int actionBudget = 12,
  ExerciseViewport viewport = ExerciseViewport.desktop1280x800,
  String themeRecipeId = 'khalai-blue',
}) {
  return HostExerciseConfig(
    host: 'observatory',
    initialRoute: '/overview',
    smokeTargets: observatorySmokeTargets,
    viewport: viewport,
    themeRecipeId: themeRecipeId,
    actionBudget: mode == 'smoke'
        ? observatorySmokeTargets.length
        : actionBudget,
    seed: seed,
    // Observatory owns live workspace scanners behind the /workspace-snapshot
    // route; exercise stays within the deterministic fixture-backed shell
    // branches and the DS gallery route.
    excludedIdSubstrings: const <String>[
      'workspace-snapshot',
      'workspace snapshot',
    ],
  );
}

/// Deterministic reset: fresh ProviderScope + app shell with UniqueKey,
/// router returned to `/overview`.
Future<void> resetAndPumpObservatory(WidgetTester tester) async {
  final router = observatory.appRouter;
  router.go('/overview');
  await tester.pumpWidget(
    KeyedSubtree(
      key: UniqueKey(),
      child: const TickerMode(
        enabled: false,
        child: ProviderScope(child: WarpPrismApp()),
      ),
    ),
  );
  await tester.pump();
}

/// Reads the current Observatory route from the live GoRouter.
String currentObservatoryRoute() {
  return observatory.appRouter.routeInformationProvider.value.uri.path;
}

/// Bundles the Observatory callbacks for [ExerciseRunner].
///
/// Theme recipe switching is NOT supported for this host adapter: the
/// Observatory hardwires `PrismTheme.dark()` (Khalai Blue) by product
/// decision (Task 1833: "unaffected; continues using Black Obsidian +
/// Khalai Blue contract defaults"). Recipe propagation is exercised on
/// the Catalog host instead.
ExerciseRunCallbacks observatoryCallbacks(WidgetTester tester) {
  return ExerciseRunCallbacks(
    resetAndPump: () => resetAndPumpObservatory(tester),
    currentRoute: currentObservatoryRoute,
  );
}
