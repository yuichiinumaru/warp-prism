import 'timeline_intent.dart';

/// Injected timeline model + reference fake (pure Dart).
///
/// Products own position state and history. This module owns only the
/// interface the verbs apply to and the reference fake the conformance suite
/// runs against — the MISSION §6 gate-2 evidence that the contract holds
/// before any product wires it.
///
/// All positions are opaque caller numbers (seconds, bar/beat units, or any
/// caller scale): the model never converts, formats, or advances them.
///
/// Lifecycle: EXPERIMENTAL (Task 1874). No barrel export, no STABLE
/// promotion in this task.

/// Minimal position + history surface a timeline product injects.
///
/// - [committedPosition]: last history-stepped position (undo boundary).
/// - [livePosition]: current preview position (moves freely during a scrub).
/// - [historySteps]: number of committed steps so far (commit accounting).
/// - [preview]: apply a [TimelineScrub] — live only, history untouched.
/// - [commit]: apply a [TimelineSet] — live + committed, exactly one step.
abstract interface class TimelineModel {
  double get committedPosition;
  double get livePosition;
  int get historySteps;

  void preview(double position);
  void commit(double position);
}

/// Reference/fake implementation of [TimelineModel] for the conformance suite.
///
/// In-memory, deterministic, no IO: [preview] moves only the live position;
/// [commit] moves live + committed and adds exactly one history step. The
/// suite proves the fake and the contract agree, including the cross-cluster
/// commit invariant: one gesture ⇒ one history step.
final class ReferenceTimelineModel implements TimelineModel {
  double _committed;
  double _live;
  int _steps;

  ReferenceTimelineModel({double initialPosition = 0.0})
    : _committed = initialPosition,
      _live = initialPosition,
      _steps = 0;

  @override
  double get committedPosition => _committed;

  @override
  double get livePosition => _live;

  @override
  int get historySteps => _steps;

  @override
  void preview(double position) {
    _live = position;
  }

  @override
  void commit(double position) {
    _live = position;
    _committed = position;
    _steps++;
  }

  /// Applies one resolved [TimelineDispatch] to this model.
  ///
  /// Scrubs preview; sets commit. Refusals never reach this method — a denied
  /// verb carries its reason to the caller instead of touching state.
  void applyDispatch(TimelineDispatch dispatch) {
    final edit = dispatch.edit;
    switch (edit) {
      case TimelineScrub(:final position):
        preview(position);
      case TimelineSet(:final position):
        commit(position);
    }
  }

  /// Applies a full scrub gesture: any number of live [updates] closed by a
  /// single commit at [end].
  ///
  /// Returns the history steps added — always exactly 1, however long [updates]
  /// is. This is the executable form of the one-gesture-one-history-step
  /// invariant.
  int applyGesture({required List<double> updates, required double end}) {
    final before = _steps;
    final session = TimelineScrubSession();
    for (final position in updates) {
      applyDispatch(TimelineDispatch(session.addUpdate(position)));
    }
    applyDispatch(TimelineDispatch(session.finish(end)));
    return _steps - before;
  }
}
