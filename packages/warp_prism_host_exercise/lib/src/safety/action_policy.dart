import '../models/exercise_action.dart';

/// Conservative safety policy for discovered actions.
///
/// Default posture: everything tappable is [ActionSafety.safe] unless its
/// stable identity matches a destructive/external pattern (then
/// [ActionSafety.externalOrDestructive]) or a stateful pattern (then
/// [ActionSafety.statefulLocal]).
///
/// Host adapters extend (never weaken) this policy with
/// `excludedIdSubstrings` for app-specific destructive surfaces.
class ExerciseActionPolicy {
  static final List<RegExp> _destructivePatterns = <RegExp>[
    RegExp(r'delet', caseSensitive: false),
    RegExp(r'destroy', caseSensitive: false),
    RegExp(r'remove.+account', caseSensitive: false),
    RegExp(r'pay', caseSensitive: false),
    RegExp(r'purchase', caseSensitive: false),
    RegExp(r'checkout', caseSensitive: false),
    RegExp(r'credential', caseSensitive: false),
    RegExp(r'password', caseSensitive: false),
    RegExp(r'secret', caseSensitive: false),
    RegExp(r'sign.?in', caseSensitive: false),
    RegExp(r'sign.?out', caseSensitive: false),
    RegExp(r'log.?out', caseSensitive: false),
    RegExp(r'\bauth\b', caseSensitive: false),
    RegExp(r'\bvcs\b', caseSensitive: false),
    RegExp(r'commit', caseSensitive: false),
    RegExp(r'\bpush\b', caseSensitive: false),
    RegExp(r'launch.+url', caseSensitive: false),
    RegExp(r'open.+external', caseSensitive: false),
    RegExp(r'file.+delet', caseSensitive: false),
  ];

  static final List<RegExp> _statefulPatterns = <RegExp>[
    RegExp(r'text.?field', caseSensitive: false),
    RegExp(r'editable', caseSensitive: false),
    RegExp(r'search.?input', caseSensitive: false),
    RegExp(r'type.?here', caseSensitive: false),
  ];

  /// Classifies a stable candidate identity without touching the widget tree.
  static ActionSafety classify(String stableId) {
    for (final pattern in _destructivePatterns) {
      if (pattern.hasMatch(stableId)) {
        return ActionSafety.externalOrDestructive;
      }
    }
    for (final pattern in _statefulPatterns) {
      if (pattern.hasMatch(stableId)) return ActionSafety.statefulLocal;
    }
    return ActionSafety.safe;
  }

  /// Applies the policy to a candidate, returning a copy with resolved safety.
  static ExerciseCandidate resolve(ExerciseCandidate candidate) {
    if (candidate.safety != ActionSafety.safe) return candidate;
    return ExerciseCandidate(
      id: candidate.id,
      label: candidate.label,
      kind: candidate.kind,
      safety: classify(candidate.id),
      routeHint: candidate.routeHint,
    );
  }
}
