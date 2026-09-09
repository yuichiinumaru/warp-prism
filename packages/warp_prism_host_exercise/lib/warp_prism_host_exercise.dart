/// Warp Prism Real-Host UI Exercise Harness.
///
/// Detects classes of UI/integration defects that package/widget tests miss,
/// using reproducible real-host interaction exploration.
///
/// Three execution modes: SMOKE (cheap deterministic canonical paths),
/// CRAWL (deterministic bounded sequential exploration), FUZZ (seeded
/// reproducible random walk over the same SAFE action model).
///
/// This package is intentionally dependency-light: it depends only on the
/// Flutter SDK + meta. It does NOT depend on warp_prism_ui, interaction,
/// runtime, or any host app, so a parallel product mission can evolve those
/// surfaces without colliding with this evidence mechanism. Host adapters
/// (bootstrap, routes, safe-action policy, reset) live in each app's
/// `integration_test/host_exercise/` folder and supply callbacks.
library warp_prism_host_exercise;

export 'src/artifacts/trace_writer.dart';
export 'src/discovery/action_discovery.dart';
export 'src/models/exercise_action.dart';
export 'src/models/exercise_trace.dart';
export 'src/models/host_config.dart';
export 'src/models/theme_matrix.dart';
export 'src/models/viewport_matrix.dart';
export 'src/oracle/error_oracle.dart';
export 'src/runner/exercise_runner.dart';
export 'src/safety/action_policy.dart';
