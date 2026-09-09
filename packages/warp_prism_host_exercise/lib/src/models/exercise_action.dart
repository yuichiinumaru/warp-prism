import 'package:meta/meta.dart';

/// Safety classification for a discovered UI action.
///
/// The test environment must not become dangerous because "monkey testing"
/// was requested. Classification is intentionally conservative: unknown or
/// ambiguous actions default to [externalOrDestructive] (skipped).
enum ActionSafety {
  /// Navigation, tabs, expansion, selection, local UI controls, dialogs,
  /// theme switching, filters, non-destructive fixture actions.
  safe,

  /// Permitted only with a deterministic reset (e.g. text input that mutates
  /// local fixture state). v1 discovers taps only, so most candidates are
  /// [safe]; adapters may mark specific ids as [statefulLocal].
  statefulLocal,

  /// Actual delete/destructive operations, external service mutation,
  /// credentials/auth actions, VCS, file deletion, payment/commercial
  /// actions, URL launching. Disabled by default — never tapped.
  externalOrDestructive,
}

/// Kind of interaction the harness can perform in v1.
enum ExerciseActionKind {
  /// Single tap (or keyboard-equivalent activation) on a tappable.
  tap,

  /// Focus the node then dispatch Enter (keyboard activation path).
  ///
  /// v1 implements this as a tap fallback when focus activation is not
  /// resolvable; the kind is recorded so future versions can drive the
  /// true keyboard path without changing the trace schema.
  focusActivate,
}

/// A single discovered interactable with a stable semantic identity.
///
/// Identity preference (strongest first):
/// 1. Semantics label (+ value when present).
/// 2. Stable widget/test key string.
/// 3. `runtimeType#index` fallback (unstable — recorded but deprioritized).
@immutable
class ExerciseCandidate {
  /// Stable identity used for deterministic ordering and replay matching.
  final String id;

  /// Human-readable label for logs and traces.
  final String label;

  /// What the runner should do.
  final ExerciseActionKind kind;

  /// Safety gate. Non-[ActionSafety.safe] candidates are skipped unless the
  /// active mode explicitly permits them.
  final ActionSafety safety;

  /// Optional route hint supplied by the host adapter.
  final String? routeHint;

  const ExerciseCandidate({
    required this.id,
    required this.label,
    this.kind = ExerciseActionKind.tap,
    this.safety = ActionSafety.safe,
    this.routeHint,
  });

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'label': label,
    'kind': kind.name,
    'safety': safety.name,
    if (routeHint != null) 'route_hint': routeHint,
  };

  factory ExerciseCandidate.fromJson(Map<String, Object?> json) {
    return ExerciseCandidate(
      id: json['id']! as String,
      label: (json['label'] ?? json['id']!) as String,
      kind: ExerciseActionKind.values.byName((json['kind'] ?? 'tap') as String),
      safety: ActionSafety.values.byName((json['safety'] ?? 'safe') as String),
      routeHint: json['route_hint'] as String?,
    );
  }
}
