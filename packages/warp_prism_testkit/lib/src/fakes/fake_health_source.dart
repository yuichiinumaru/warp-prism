import 'dart:async';
import 'package:meta/meta.dart';
import 'package:warp_prism_runtime/warp_prism_runtime.dart';

/// In-memory fake implementation of [HealthSource] for deterministic testing.
///
/// Enables manual snapshot configuration, cell mutations, state simulation,
/// and reactive change broadcasting.
///
/// Lifecycle: EXPERIMENTAL (see `.project/architecture/layer-contracts.md`).
@experimental
class FakeHealthSource implements HealthSource {
  HealthSnapshot _snapshot;
  final StreamController<HealthSnapshot> _controller;
  int _snapshotQueryCount = 0;
  bool _isClosed = false;

  /// Creates a [FakeHealthSource] with an optional initial snapshot.
  FakeHealthSource({HealthSnapshot? initialSnapshot, bool sync = true})
    : _snapshot =
          initialSnapshot ??
          HealthSnapshot(
            timestamp: DateTime.now(),
            cells: const [],
            aggregateState: HealthState.healthy,
          ),
      _controller = StreamController<HealthSnapshot>.broadcast(sync: sync);

  @override
  bool get isClosed => _isClosed;

  /// Current point-in-time snapshot.
  HealthSnapshot get currentSnapshot => _snapshot;

  /// Total number of times [getSnapshot] was invoked.
  int get snapshotQueryCount => _snapshotQueryCount;

  @override
  Future<HealthSnapshot> getSnapshot() async {
    if (_isClosed) {
      throw StateError('Cannot query snapshot on closed FakeHealthSource');
    }
    _snapshotQueryCount++;
    return _snapshot;
  }

  @override
  Stream<HealthSnapshot> watch() => _controller.stream;

  /// Replaces the current snapshot and emits the update to watchers.
  void setSnapshot(HealthSnapshot snapshot) {
    if (_isClosed) {
      throw StateError('Cannot set snapshot on closed FakeHealthSource');
    }
    _snapshot = snapshot;
    _controller.add(snapshot);
  }

  /// Adds or updates a single [HealthCell] and re-derives aggregate state.
  void updateCell(HealthCell cell) {
    if (_isClosed) {
      throw StateError('Cannot update cell on closed FakeHealthSource');
    }

    final updatedCells = <HealthCell>[];
    var matched = false;

    for (final existing in _snapshot.cells) {
      if (existing.id == cell.id) {
        updatedCells.add(cell);
        matched = true;
      } else {
        updatedCells.add(existing);
      }
    }

    if (!matched) {
      updatedCells.add(cell);
    }

    final newAggregate = HealthSnapshot.deriveAggregateState(updatedCells);
    final updatedSnapshot = HealthSnapshot(
      timestamp: DateTime.now(),
      cells: updatedCells,
      aggregateState: newAggregate,
      freshnessTtl: _snapshot.freshnessTtl,
      metadata: _snapshot.metadata,
    );

    setSnapshot(updatedSnapshot);
  }

  /// Simulates degraded operational status on cell with [cellId].
  void simulateDegradation(
    String cellId, {
    Duration latency = const Duration(milliseconds: 500),
  }) {
    final existing = _snapshot.getCell(cellId);
    if (existing != null) {
      updateCell(
        existing.copyWith(state: HealthState.degraded, latency: latency),
      );
    }
  }

  /// Simulates an aggregate state change.
  void simulateState(HealthState state) {
    final updatedSnapshot = HealthSnapshot(
      timestamp: DateTime.now(),
      cells: _snapshot.cells.map((c) => c.copyWith(state: state)).toList(),
      aggregateState: state,
      freshnessTtl: _snapshot.freshnessTtl,
      metadata: _snapshot.metadata,
    );
    setSnapshot(updatedSnapshot);
  }

  /// Emits an error across the reactive [watch] stream.
  void emitWatchError(Object error, [StackTrace? stackTrace]) {
    if (_isClosed) {
      throw StateError('Cannot emit watch error on closed FakeHealthSource');
    }
    _controller.addError(error, stackTrace);
  }

  @override
  Future<void> close() async {
    _isClosed = true;
    if (!_controller.isClosed) {
      await _controller.close();
    }
  }
}
