import 'package:meta/meta.dart';

/// Opaque reference and metadata for an executed query result set.
///
/// Encapsulates result identity, item count, data origin/provenance,
/// and optional in-memory item references without prescribing UI layout.
///
/// Lifecycle: PROVEN (see `docs/architecture/layer-contracts-v2.md`).
@immutable
class QueryResultReference<T extends Object> {
  /// Opaque correlation token identifying this result set.
  final String token;

  /// Total number of matching items in the result set (may exceed in-memory items).
  final int totalCount;

  /// Origin or system component producing this result set.
  final String? provenance;

  /// Optional in-memory items matching the query.
  final List<T>? items;

  /// Timestamp when the result was materialized.
  final DateTime timestamp;

  QueryResultReference({
    required this.token,
    required this.totalCount,
    this.provenance,
    List<T>? items,
    DateTime? timestamp,
  }) : items = items != null ? List.unmodifiable(items) : null,
       timestamp = timestamp ?? DateTime.now();

  /// True if the result set is empty.
  bool get isEmpty => totalCount == 0;

  /// True if the result set contains at least one item.
  bool get isNotEmpty => totalCount > 0;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! QueryResultReference<T>) return false;
    return other.token == token &&
        other.totalCount == totalCount &&
        other.provenance == provenance;
  }

  @override
  int get hashCode => Object.hash(token, totalCount, provenance);

  @override
  String toString() =>
      'QueryResultReference<$T>(token: $token, totalCount: $totalCount, provenance: $provenance)';
}
