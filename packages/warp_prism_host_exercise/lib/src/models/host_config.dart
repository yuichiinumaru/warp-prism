import 'package:meta/meta.dart';

import 'exercise_action.dart';
import 'viewport_matrix.dart';

/// Host-specific configuration supplied by each app adapter.
///
/// The shared crawler implementation is host-agnostic. Each host supplies
/// only what is genuinely host-specific: bootstrap description, route
/// entrypoints, safe-action policy overrides, fixture/reset description,
/// and excluded external/destructive surfaces.
@immutable
class HostExerciseConfig {
  /// Stable host id: `catalog`, `observatory`, or `cybercore`.
  final String host;

  /// Route/entrypoint where the run starts (app-specific semantics:
  /// section id, go_router location, or logical surface name).
  final String initialRoute;

  /// Canonical smoke paths for [ExerciseMode.smoke]: ordered stable
  /// candidate ids the adapter knows exist.
  final List<String> smokeTargets;

  /// Viewport for this run.
  final ExerciseViewport viewport;

  /// Theme recipe id for this run.
  final String themeRecipeId;

  /// Maximum number of actions to perform (SMOKE: targets length;
  /// CRAWL/FUZZ: exploration budget).
  final int actionBudget;

  /// Seed for FUZZ (ignored by SMOKE/CRAWL ordering, still recorded).
  final int seed;

  /// Explicit extra blocklist: stable candidate-id substrings that must
  /// never be tapped on this host (external/destructive surfaces).
  final List<String> excludedIdSubstrings;

  /// Explicit extra allowlist: when non-empty, only candidates whose id
  /// contains one of these substrings are eligible (useful for narrow
  /// affected-host smoke).
  final List<String> allowlistIdSubstrings;

  const HostExerciseConfig({
    required this.host,
    required this.initialRoute,
    this.smokeTargets = const <String>[],
    this.viewport = ExerciseViewport.desktop1280x800,
    this.themeRecipeId = 'khalai-blue',
    this.actionBudget = 12,
    this.seed = 0,
    this.excludedIdSubstrings = const <String>[],
    this.allowlistIdSubstrings = const <String>[],
  });

  /// Returns true when [candidate] is eligible under host allow/block lists.
  bool isEligible(ExerciseCandidate candidate) {
    final id = candidate.id.toLowerCase();
    for (final blocked in excludedIdSubstrings) {
      if (id.contains(blocked.toLowerCase())) return false;
    }
    if (allowlistIdSubstrings.isEmpty) return true;
    for (final allowed in allowlistIdSubstrings) {
      if (id.contains(allowed.toLowerCase())) return true;
    }
    return false;
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'host': host,
    'initial_route': initialRoute,
    'viewport': viewport.toJson(),
    'theme_recipe': themeRecipeId,
    'action_budget': actionBudget,
    'seed': seed,
  };
}
