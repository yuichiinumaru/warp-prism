import 'package:meta/meta.dart';

/// One performed step in a trace.
@immutable
class ExerciseStep {
  final int index;
  final String target;
  final String action;
  final String routeBefore;
  final String routeAfter;
  final String stateMarker;

  const ExerciseStep({
    required this.index,
    required this.target,
    required this.action,
    required this.routeBefore,
    required this.routeAfter,
    required this.stateMarker,
  });

  Map<String, Object?> toJson() => <String, Object?>{
    'index': index,
    'target': target,
    'action': action,
    'route_before': routeBefore,
    'route_after': routeAfter,
    'state_marker': stateMarker,
  };

  factory ExerciseStep.fromJson(Map<String, Object?> json) {
    return ExerciseStep(
      index: (json['index']! as num).toInt(),
      target: json['target']! as String,
      action: (json['action'] ?? 'tap') as String,
      routeBefore: (json['route_before'] ?? '') as String,
      routeAfter: (json['route_after'] ?? '') as String,
      stateMarker: (json['state_marker'] ?? '') as String,
    );
  }
}

/// Reproducible trace for one harness run.
///
/// A random failure without a replayable seed/action trace is not acceptable
/// evidence — every FUZZ run records the seed plus the ordered action list
/// so the exact sequence replays deterministically.
@immutable
class ExerciseTrace {
  final int seed;
  final String host;
  final String mode;
  final String initialRoute;
  final Map<String, Object?> viewport;
  final String themeRecipe;
  final int actionBudget;
  final List<ExerciseStep> actions;
  final List<String> errors;
  final String? replayCommand;

  const ExerciseTrace({
    required this.seed,
    required this.host,
    required this.mode,
    required this.initialRoute,
    required this.viewport,
    required this.themeRecipe,
    required this.actionBudget,
    this.actions = const <ExerciseStep>[],
    this.errors = const <String>[],
    this.replayCommand,
  });

  Map<String, Object?> toJson() => <String, Object?>{
    'seed': seed,
    'host': host,
    'mode': mode,
    'initial_route': initialRoute,
    'viewport': viewport,
    'theme_recipe': themeRecipe,
    'action_budget': actionBudget,
    'actions': <Object?>[for (final a in actions) a.toJson()],
    'errors': <Object?>[...errors],
    if (replayCommand != null) 'replay_command': replayCommand,
  };

  factory ExerciseTrace.fromJson(Map<String, Object?> json) {
    final rawActions = (json['actions'] as List?) ?? const [];
    return ExerciseTrace(
      seed: (json['seed'] as num?)?.toInt() ?? 0,
      host: (json['host'] ?? '') as String,
      mode: (json['mode'] ?? '') as String,
      initialRoute: (json['initial_route'] ?? '') as String,
      viewport: Map<String, Object?>.from(
        (json['viewport'] as Map?) ?? const {},
      ),
      themeRecipe: (json['theme_recipe'] ?? '') as String,
      actionBudget: (json['action_budget'] as num?)?.toInt() ?? 0,
      actions: [
        for (final raw in rawActions)
          ExerciseStep.fromJson(Map<String, Object?>.from(raw as Map)),
      ],
      errors: [
        for (final raw in ((json['errors'] as List?) ?? const []))
          raw.toString(),
      ],
      replayCommand: json['replay_command'] as String?,
    );
  }
}
