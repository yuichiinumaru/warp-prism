import 'selection_event.dart';
import 'selection_mode.dart';
import 'selection_state.dart';

/// Callback signature for selection event listeners.
///
/// Lifecycle: PROVEN (see `.project/architecture/layer-contracts.md`).
typedef SelectionListener<T extends Object> =
    void Function(SelectionChangeEvent<T> event);

/// Observable controller / bus for selection state management.
///
/// Pure Dart notifier that manages selection state transitions and
/// publishes [SelectionChangeEvent]s to registered listeners.
///
/// Lifecycle: PROVEN (see `.project/architecture/layer-contracts.md`).
class SelectionNotifier<T extends Object> {
  SelectionState<T> _state;

  /// Selection mode enforced by this notifier.
  final SelectionMode mode;
  final List<SelectionListener<T>> _listeners = [];
  bool _isDisposed = false;

  /// Creates a [SelectionNotifier] with an optional initial state and selection mode.
  SelectionNotifier({
    SelectionState<T>? initialState,
    this.mode = SelectionMode.single,
  }) : _state = initialState ?? SelectionState<T>.empty();

  /// Current immutable selection state.
  SelectionState<T> get value => _state;

  /// True if this notifier has been disposed.
  bool get isDisposed => _isDisposed;

  /// Adds a listener callback invoked when selection changes.
  void addListener(SelectionListener<T> listener) {
    if (_isDisposed) return;
    _listeners.add(listener);
  }

  /// Removes a registered listener callback.
  void removeListener(SelectionListener<T> listener) {
    _listeners.remove(listener);
  }

  /// Updates the selection state and notifies listeners if state changed.
  void _applyState(SelectionState<T> nextState, SelectionSource source) {
    if (_isDisposed) {
      throw StateError('Cannot modify SelectionNotifier after disposal');
    }
    if (_state == nextState) {
      return;
    }
    final previous = _state;
    _state = nextState;

    final event = SelectionChangeEvent<T>(
      previous: previous,
      current: nextState,
      source: source,
    );

    final listenersCopy = List<SelectionListener<T>>.from(_listeners);
    for (final listener in listenersCopy) {
      listener(event);
    }
  }

  /// Selects [item] according to current [mode].
  void select(T item, {SelectionSource source = SelectionSource.user}) {
    _applyState(_state.select(item, mode: mode), source);
  }

  /// Deselects [item].
  void deselect(T item, {SelectionSource source = SelectionSource.user}) {
    _applyState(_state.deselect(item), source);
  }

  /// Toggles [item]'s selection status.
  void toggle(T item, {SelectionSource source = SelectionSource.user}) {
    _applyState(_state.toggle(item, mode: mode), source);
  }

  /// Selects all [items] (only in multiple mode).
  void selectAll(
    Iterable<T> items, {
    SelectionSource source = SelectionSource.user,
  }) {
    if (mode != SelectionMode.multiple) {
      if (items.isNotEmpty) {
        select(items.last, source: source);
      }
      return;
    }
    _applyState(_state.selectAll(items), source);
  }

  /// Clears the selection.
  void clear({
    SelectionSource source = SelectionSource.user,
    bool preserveAnchor = false,
  }) {
    _applyState(_state.clear(preserveAnchor: preserveAnchor), source);
  }

  /// Replaces the selection state directly.
  void update(
    SelectionState<T> newState, {
    SelectionSource source = SelectionSource.programmatic,
  }) {
    _applyState(newState, source);
  }

  /// Disposes this notifier and clears all listeners.
  void dispose() {
    _isDisposed = true;
    _listeners.clear();
  }
}
