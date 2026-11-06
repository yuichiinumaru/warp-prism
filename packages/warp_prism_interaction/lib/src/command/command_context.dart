import 'package:meta/meta.dart';

/// Generic, product-agnostic evaluation context for command resolution.
///
/// Pure Dart map wrapper — deliberately free of domain types (no product
/// domain models, no provider types) per the domain leakage rule.
/// Products project their local state onto string keys before routing.
///
/// Lifecycle: EXPERIMENTAL (Task 1870, F-03). No barrel export.
@immutable
final class CommandContext {
  /// Context values keyed by product-chosen names (e.g. `'route'`,
  /// `'selectionCount'`, `'role'`).
  final Map<String, Object?> values;

  const CommandContext([this.values = const {}]);

  /// Empty context (no product state projected).
  static const empty = CommandContext();

  /// Reads [key] as [T], or null when absent or of another type.
  T? value<T>(String key) {
    final raw = values[key];
    return raw is T ? raw : null;
  }

  /// Reads [key] as a boolean flag; missing or non-bool ⇒ false.
  bool flag(String key) => values[key] == true;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CommandContext && _mapsEqual(other.values, values));

  @override
  int get hashCode =>
      Object.hashAll(values.entries.map((e) => Object.hash(e.key, e.value)));

  @override
  String toString() => 'CommandContext($values)';
}

bool _mapsEqual(Map<String, Object?> a, Map<String, Object?> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (final entry in a.entries) {
    if (!b.containsKey(entry.key) || b[entry.key] != entry.value) {
      return false;
    }
  }
  return true;
}
