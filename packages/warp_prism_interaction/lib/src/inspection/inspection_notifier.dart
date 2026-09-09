import 'inspection_intent.dart';
import 'inspection_state.dart';

/// Callback signature for inspection session changes.
///
/// Lifecycle: PROVEN (see `docs/architecture/layer-contracts-v2.md`).
typedef InspectionListener<T extends Object> =
    void Function(InspectionPayload<T>? currentSession);

/// Observable controller for managing inspection lifecycle sessions.
///
/// Lifecycle: PROVEN (see `docs/architecture/layer-contracts-v2.md`).
class InspectionNotifier<T extends Object> {
  InspectionPayload<T>? _session;
  final List<InspectionListener<T>> _listeners = [];
  bool _isDisposed = false;

  /// Creates an [InspectionNotifier] with an optional initial session.
  InspectionNotifier({InspectionPayload<T>? initialSession})
    : _session = initialSession;

  /// Current inspection payload / session, if any.
  InspectionPayload<T>? get session => _session;

  /// True if there is an actively committed inspection session.
  bool get hasActiveInspection => _session?.isActive == true;

  /// True if this notifier has been disposed.
  bool get isDisposed => _isDisposed;

  /// Adds a listener callback.
  void addListener(InspectionListener<T> listener) {
    if (_isDisposed) return;
    _listeners.add(listener);
  }

  /// Removes a listener callback.
  void removeListener(InspectionListener<T> listener) {
    _listeners.remove(listener);
  }

  void _notify() {
    final listenersCopy = List<InspectionListener<T>>.from(_listeners);
    for (final listener in listenersCopy) {
      listener(_session);
    }
  }

  /// Proposes a new inspection target (e.g. for preview or pre-activation).
  void propose(InspectionIntent<T> intent) {
    if (_isDisposed) {
      throw StateError('Cannot propose inspection after disposal');
    }
    if (_session != null) {
      inspectionTransitionTable.validateTransition(
        _session!.status,
        InspectionTrigger.propose,
      );
    }
    _session = InspectionPayload<T>(
      intent: intent,
      status: InspectionLifecycle.proposed,
    );
    _notify();
  }

  /// Commits and activates an inspection session.
  ///
  /// If [intent] is provided, creates a new active session; otherwise activates
  /// the currently proposed session.
  void activate([InspectionIntent<T>? intent]) {
    if (_isDisposed) {
      throw StateError('Cannot activate inspection after disposal');
    }
    if (intent != null) {
      if (_session != null) {
        inspectionTransitionTable.validateTransition(
          _session!.status,
          InspectionTrigger.activate,
        );
      }
      _session = InspectionPayload<T>(
        intent: intent,
        status: InspectionLifecycle.active,
      );
      _notify();
      return;
    }

    if (_session == null) {
      throw StateError(
        'Cannot activate inspection without an intent or an existing proposed session',
      );
    }

    inspectionTransitionTable.validateTransition(
      _session!.status,
      InspectionTrigger.activate,
    );
    _session = _session!.transitionTo(InspectionLifecycle.active);
    _notify();
  }

  /// Dismisses the active inspection session.
  void dismiss() {
    if (_isDisposed) {
      throw StateError('Cannot dismiss inspection after disposal');
    }
    if (_session == null) {
      throw StateError('Cannot dismiss when no inspection session exists');
    }

    inspectionTransitionTable.validateTransition(
      _session!.status,
      InspectionTrigger.dismiss,
    );
    _session = _session!.transitionTo(InspectionLifecycle.dismissed);
    _notify();
  }

  /// Clears / resets the inspection session to null.
  void reset() {
    if (_isDisposed) {
      throw StateError('Cannot reset inspection after disposal');
    }
    if (_session == null) return;
    _session = null;
    _notify();
  }

  /// Disposes this notifier and clears all listeners.
  void dispose() {
    _isDisposed = true;
    _listeners.clear();
  }
}
