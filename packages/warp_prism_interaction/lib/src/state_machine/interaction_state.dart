/// Standard interaction states across Warp Prism interactive primitives.
///
/// Lifecycle: PROVEN (see `docs/architecture/layer-contracts-v2.md`).
enum InteractionState {
  /// Surface is inactive and waiting for input.
  idle,

  /// Surface is currently active or focused (e.g. selection active, inspection active).
  active,

  /// Surface is processing an asynchronous operation (e.g. running query, loading details).
  busy,

  /// Surface is disabled and ignoring user interaction.
  disabled,

  /// An error occurred during the interaction.
  error,

  /// The interaction completed successfully.
  success,
}

/// Transition rule table enforcing permitted state transitions.
///
/// Lifecycle: PROVEN (see `docs/architecture/layer-contracts-v2.md`).
class InteractionTransitionTable<S, T> {
  /// Map of allowed triggers for each source state.
  final Map<S, Set<T>> allowedTriggers;

  /// Map of (source state, trigger) pairs to target destination states.
  final Map<(S, T), S> targetStates;

  const InteractionTransitionTable({
    required this.allowedTriggers,
    this.targetStates = const {},
  });

  /// Returns true if [trigger] is permitted from [from] state.
  bool canTransition(S from, T trigger) {
    final allowed = allowedTriggers[from];
    return allowed != null && allowed.contains(trigger);
  }

  /// Resolves the next state for [from] given [trigger].
  ///
  /// Throws [StateError] if the transition is not allowed.
  S resolveNextState(S from, T trigger) {
    validateTransition(from, trigger);
    final target = targetStates[(from, trigger)];
    if (target != null) {
      return target;
    }
    throw StateError(
      'Transition table has no defined target state for ($from, $trigger)',
    );
  }

  /// Validates that [trigger] is allowed from [from] state.
  ///
  /// Throws [StateError] with descriptive diagnostics if illegal.
  void validateTransition(S from, T trigger) {
    if (!canTransition(from, trigger)) {
      final allowed = allowedTriggers[from] ?? const {};
      throw StateError(
        'Illegal state transition from state "$from" via trigger "$trigger". '
        'Allowed triggers from "$from": [${allowed.map((t) => t.toString()).join(', ')}].',
      );
    }
  }
}

/// Finite state machine for interaction lifecycles with change notifications.
///
/// Lifecycle: PROVEN (see `docs/architecture/layer-contracts-v2.md`).
class InteractionStateMachine<S, T> {
  final InteractionTransitionTable<S, T> table;
  S _currentState;
  final List<void Function(S previousState, S nextState, T trigger)>
  _listeners = [];
  bool _isDisposed = false;

  InteractionStateMachine({required S initialState, required this.table})
    : _currentState = initialState;

  /// Current state of the machine.
  S get currentState => _currentState;

  /// True if the state machine has been disposed.
  bool get isDisposed => _isDisposed;

  /// Returns true if [trigger] can be accepted in current state.
  bool canTrigger(T trigger) {
    if (_isDisposed) return false;
    return table.canTransition(_currentState, trigger);
  }

  /// Transitions to the target state associated with [trigger].
  ///
  /// Throws [StateError] if disposed or if the transition is illegal.
  S trigger(T trigger) {
    if (_isDisposed) {
      throw StateError('Cannot trigger state machine after disposal');
    }
    final nextState = table.resolveNextState(_currentState, trigger);
    final previousState = _currentState;
    _currentState = nextState;

    final listenersCopy = List<void Function(S, S, T)>.from(_listeners);
    for (final listener in listenersCopy) {
      listener(previousState, nextState, trigger);
    }
    return _currentState;
  }

  /// Transitions directly to [targetState] if [trigger] permits it.
  ///
  /// Throws [StateError] if disposed or if the transition is illegal.
  S transitionTo(S targetState, {required T trigger}) {
    if (_isDisposed) {
      throw StateError('Cannot transition state machine after disposal');
    }
    table.validateTransition(_currentState, trigger);
    final expectedTarget = table.targetStates[(_currentState, trigger)];
    if (expectedTarget != null && expectedTarget != targetState) {
      throw StateError(
        'Illegal target state "$targetState" for transition from "$_currentState" via trigger "$trigger". '
        'Expected target state: "$expectedTarget".',
      );
    }
    final previousState = _currentState;
    _currentState = targetState;

    final listenersCopy = List<void Function(S, S, T)>.from(_listeners);
    for (final listener in listenersCopy) {
      listener(previousState, targetState, trigger);
    }
    return _currentState;
  }

  /// Adds a transition listener.
  void addListener(
    void Function(S previousState, S nextState, T trigger) listener,
  ) {
    if (_isDisposed) return;
    _listeners.add(listener);
  }

  /// Removes a transition listener.
  void removeListener(
    void Function(S previousState, S nextState, T trigger) listener,
  ) {
    _listeners.remove(listener);
  }

  /// Disposes the state machine and clears all listeners.
  void dispose() {
    _isDisposed = true;
    _listeners.clear();
  }
}
