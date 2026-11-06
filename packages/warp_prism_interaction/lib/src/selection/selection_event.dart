import 'package:meta/meta.dart';
import 'selection_mode.dart';
import 'selection_state.dart';

/// Event payload emitted whenever a selection changes.
///
/// Lifecycle: PROVEN (see `.project/architecture/layer-contracts.md`).
@immutable
class SelectionChangeEvent<T extends Object> {
  /// The selection state prior to the change.
  final SelectionState<T> previous;

  /// The new selection state.
  final SelectionState<T> current;

  /// Items that were added to the selection in this change.
  final Set<T> added;

  /// Items that were removed from the selection in this change.
  final Set<T> removed;

  /// Origin of the selection change.
  final SelectionSource source;

  /// Timestamp when the change occurred.
  final DateTime timestamp;

  SelectionChangeEvent({
    required this.previous,
    required this.current,
    Set<T>? added,
    Set<T>? removed,
    this.source = SelectionSource.user,
    DateTime? timestamp,
  }) : added = added != null
           ? Set.unmodifiable(added)
           : Set.unmodifiable(
               current.selectedItems.difference(previous.selectedItems),
             ),
       removed = removed != null
           ? Set.unmodifiable(removed)
           : Set.unmodifiable(
               previous.selectedItems.difference(current.selectedItems),
             ),
       timestamp = timestamp ?? DateTime.now();

  /// True if any items were added or removed, or if primary selection changed.
  bool get hasStructuralChanges => added.isNotEmpty || removed.isNotEmpty;

  /// True if the selection state changed at all.
  bool get hasChanges => previous != current;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SelectionChangeEvent<T>) return false;
    return other.previous == previous &&
        other.current == current &&
        other.source == source;
  }

  @override
  int get hashCode => Object.hash(previous, current, source);

  @override
  String toString() =>
      'SelectionChangeEvent<$T>(added: $added, removed: $removed, source: $source, current: $current)';
}
