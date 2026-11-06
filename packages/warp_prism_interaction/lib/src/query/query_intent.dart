import 'package:meta/meta.dart';

/// Intent model encapsulating a search or filter query as pure data.
///
/// Encapsulates raw search text, structured filter attributes, sorting/pagination
/// parameters, and an optional query correlation token.
///
/// Lifecycle: PROVEN (see `.project/architecture/layer-contracts.md`).
@immutable
class QueryIntent {
  /// The raw text query string entered by the user or provided by a preset.
  final String rawQuery;

  /// Structured filter criteria (e.g. `{'severity': 'error', 'service': 'obs'}`).
  final Map<String, Object?> filters;

  /// Metadata associated with the query execution context.
  final Map<String, Object?> metadata;

  /// Opaque correlation token for this query intent (used for deduplication / out-of-order gating).
  final String? queryToken;

  /// Timestamp when the query was initiated.
  final DateTime timestamp;

  QueryIntent({
    this.rawQuery = '',
    Map<String, Object?> filters = const {},
    Map<String, Object?> metadata = const {},
    this.queryToken,
    DateTime? timestamp,
  }) : filters = Map.unmodifiable(filters),
       metadata = Map.unmodifiable(metadata),
       timestamp = timestamp ?? DateTime.now();

  /// True if both text query and filters are empty.
  bool get isEmpty => rawQuery.trim().isEmpty && filters.isEmpty;

  /// True if either text query or filters are present.
  bool get isNotEmpty => !isEmpty;

  /// Returns a copy with updated parameters.
  QueryIntent copyWith({
    String? rawQuery,
    Map<String, Object?>? filters,
    Map<String, Object?>? metadata,
    String? queryToken,
    DateTime? timestamp,
  }) {
    return QueryIntent(
      rawQuery: rawQuery ?? this.rawQuery,
      filters: filters ?? this.filters,
      metadata: metadata ?? this.metadata,
      queryToken: queryToken ?? this.queryToken,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! QueryIntent) return false;
    return other.rawQuery == rawQuery &&
        other.queryToken == queryToken &&
        _mapEquals(other.filters, filters) &&
        _mapEquals(other.metadata, metadata);
  }

  @override
  int get hashCode => Object.hash(
    rawQuery,
    queryToken,
    Object.hashAll(filters.keys),
    Object.hashAll(filters.values),
  );

  @override
  String toString() =>
      'QueryIntent(rawQuery: "$rawQuery", filters: $filters, token: $queryToken)';

  static bool _mapEquals(Map<String, Object?> a, Map<String, Object?> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || b[key] != a[key]) return false;
    }
    return true;
  }
}
