import 'package:meta/meta.dart';
import 'selection_mode.dart';

/// Immutable representation of selection state.
///
/// Subsumes single-selection, multi-selection, anchor tracking,
/// and primary selection semantics across Warp Prism components.
///
/// Lifecycle: PROVEN (see `docs/architecture/layer-contracts-v2.md`).
@immutable
class SelectionState<T extends Object> {
  /// The set of currently selected items.
  final Set<T> selectedItems;

  /// The primary (active or most recently focused) item in the selection, if any.
  final T? primarySelection;

  /// The range selection anchor point, if set.
  final T? anchor;

  /// Creates an empty selection state.
  const SelectionState.empty({this.anchor})
    : selectedItems = const {},
      primarySelection = null;

  /// Creates a single-item selection state.
  SelectionState.single(T item, {this.anchor})
    : selectedItems = Set.unmodifiable({item}),
      primarySelection = item;

  /// Creates a multi-item selection state.
  SelectionState.multi(Set<T> items, {this.primarySelection, this.anchor})
    : selectedItems = Set.unmodifiable(items);

  /// Private constructor for copying/deriving.
  const SelectionState._({
    required this.selectedItems,
    this.primarySelection,
    this.anchor,
  });

  /// True if no items are selected.
  bool get isEmpty => selectedItems.isEmpty;

  /// True if at least one item is selected.
  bool get isNotEmpty => selectedItems.isNotEmpty;

  /// True if a primary selection is designated.
  bool get hasPrimary => primarySelection != null;

  /// True if an anchor point is set.
  bool get hasAnchor => anchor != null;

  /// Number of selected items.
  int get count => selectedItems.length;

  /// Returns true if [item] is in the selection set.
  bool contains(T item) => selectedItems.contains(item);

  /// Returns a new [SelectionState] with [item] selected according to [mode].
  SelectionState<T> select(
    T item, {
    SelectionMode mode = SelectionMode.single,
  }) {
    if (mode == SelectionMode.none) {
      return this;
    }
    if (mode == SelectionMode.single) {
      if (selectedItems.length == 1 && selectedItems.contains(item)) {
        return this;
      }
      return SelectionState.single(item, anchor: anchor ?? item);
    }

    // SelectionMode.multiple
    if (selectedItems.contains(item) && primarySelection == item) {
      return this;
    }
    final next = Set<T>.of(selectedItems)..add(item);
    return SelectionState._(
      selectedItems: Set.unmodifiable(next),
      primarySelection: item,
      anchor: anchor ?? item,
    );
  }

  /// Returns a new [SelectionState] with [item] deselected.
  SelectionState<T> deselect(T item) {
    if (!selectedItems.contains(item)) {
      return this;
    }
    final next = Set<T>.of(selectedItems)..remove(item);
    if (next.isEmpty) {
      return SelectionState<T>.empty(anchor: anchor == item ? null : anchor);
    }
    final nextPrimary = primarySelection == item ? next.last : primarySelection;
    final nextAnchor = anchor == item ? null : anchor;
    return SelectionState._(
      selectedItems: Set.unmodifiable(next),
      primarySelection: nextPrimary,
      anchor: nextAnchor,
    );
  }

  /// Returns a new [SelectionState] with [item]'s selection state toggled.
  SelectionState<T> toggle(
    T item, {
    SelectionMode mode = SelectionMode.multiple,
  }) {
    if (mode == SelectionMode.none) {
      return this;
    }
    if (contains(item)) {
      return deselect(item);
    } else {
      return select(item, mode: mode);
    }
  }

  /// Selects all [items] in multiple-selection mode.
  SelectionState<T> selectAll(Iterable<T> items) {
    final next = Set<T>.of(selectedItems)..addAll(items);
    final nextPrimary = items.isNotEmpty ? items.last : primarySelection;
    return SelectionState._(
      selectedItems: Set.unmodifiable(next),
      primarySelection: nextPrimary,
      anchor: anchor,
    );
  }

  /// Clears the selection.
  SelectionState<T> clear({bool preserveAnchor = false}) {
    if (isEmpty && (!preserveAnchor || anchor == null)) {
      return this;
    }
    return SelectionState<T>.empty(anchor: preserveAnchor ? anchor : null);
  }

  /// Returns a copy with updated [anchor].
  SelectionState<T> withAnchor(T? newAnchor) {
    if (anchor == newAnchor) return this;
    return SelectionState._(
      selectedItems: selectedItems,
      primarySelection: primarySelection,
      anchor: newAnchor,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SelectionState<T>) return false;
    if (other.primarySelection != primarySelection || other.anchor != anchor) {
      return false;
    }
    if (other.selectedItems.length != selectedItems.length) return false;
    return other.selectedItems.containsAll(selectedItems);
  }

  @override
  int get hashCode => Object.hash(
    Object.hashAllUnordered(selectedItems),
    primarySelection,
    anchor,
  );

  @override
  String toString() =>
      'SelectionState<$T>(count: $count, primary: $primarySelection, anchor: $anchor, items: $selectedItems)';
}
