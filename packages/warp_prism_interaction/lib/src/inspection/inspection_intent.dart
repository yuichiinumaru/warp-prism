import 'package:meta/meta.dart';

/// Intent descriptor requesting the inspection of a target entity.
///
/// Encapsulates the target identifier, domain category, trigger reason,
/// and contextual metadata without binding to concrete UI rendering.
///
/// Lifecycle: PROVEN (see `docs/architecture/layer-contracts-v2.md`).
@immutable
class InspectionIntent<T extends Object> {
  /// The target object or identifier to inspect.
  final T target;

  /// Optional type or category identifier of the target.
  final String? targetType;

  /// Reason or user action triggering this inspection.
  final String? reason;

  /// Arbitrary context data associated with the inspection request.
  final Map<String, Object?> context;

  /// Timestamp when the inspection was initiated.
  final DateTime timestamp;

  InspectionIntent({
    required this.target,
    this.targetType,
    this.reason,
    Map<String, Object?> context = const {},
    DateTime? timestamp,
  }) : context = Map.unmodifiable(context),
       timestamp = timestamp ?? DateTime.now();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! InspectionIntent<T>) return false;
    return other.target == target &&
        other.targetType == targetType &&
        other.reason == reason;
  }

  @override
  int get hashCode => Object.hash(target, targetType, reason);

  @override
  String toString() =>
      'InspectionIntent<$T>(target: $target, type: $targetType, reason: $reason)';
}
