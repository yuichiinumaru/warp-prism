import 'package:meta/meta.dart';
import 'dart:async';
import 'package:warp_prism_runtime/warp_prism_runtime.dart';
import 'rust/api.dart' as frb_api;

/// FRB native-backed implementation of [HealthSource].
/// Lifecycle: EXPERIMENTAL (see `docs/architecture/layer-contracts-v2.md`).
@experimental
class FrbHealthSource implements HealthSource {
  final int? defaultSampleCount;
  final StreamController<HealthSnapshot> _controller;
  StreamSubscription<frb_api.FrbHealthSnapshot>? _watchSub;
  HealthSnapshot? _cachedSnapshot;
  bool _isClosed = false;

  FrbHealthSource({this.defaultSampleCount})
      : _controller = StreamController<HealthSnapshot>.broadcast();

  void _ensureNativeStream() {
    _watchSub ??= frb_api
        .watchHealth(sampleCount: defaultSampleCount)
        .listen(
          (snap) {
            if (!_isClosed) {
              final converted = _convertFromNative(snap);
              _cachedSnapshot = converted;
              _controller.add(converted);
            }
          },
          onError: (Object err, StackTrace st) {
            if (!_isClosed) {
              _controller.addError(err, st);
            }
          },
        );
  }

  @override
  bool get isClosed => _isClosed;

  @override
  Future<HealthSnapshot> getSnapshot() async {
    if (_isClosed) {
      throw StateError('Cannot getSnapshot on closed FrbHealthSource');
    }
    if (_cachedSnapshot != null) return _cachedSnapshot!;
    final nativeSnap = await frb_api.getSampleHealthSnapshot();
    _cachedSnapshot = _convertFromNative(nativeSnap);
    return _cachedSnapshot!;
  }

  @override
  Stream<HealthSnapshot> watch() {
    if (_isClosed) {
      throw StateError('Cannot watch closed FrbHealthSource');
    }
    _ensureNativeStream();
    return _controller.stream;
  }

  /// Sets or updates a single [HealthCell] in the Rust native substrate.
  ///
  /// The native substrate recalculates aggregate state and broadcasts the snapshot to watchers.
  Future<void> updateCell(HealthCell cell) async {
    if (_isClosed) {
      throw StateError('Cannot updateCell on closed FrbHealthSource');
    }
    final nativeState = switch (cell.state) {
      HealthState.healthy => frb_api.FrbHealthState.healthy,
      HealthState.degraded => frb_api.FrbHealthState.degraded,
      HealthState.unreachable => frb_api.FrbHealthState.unreachable,
      HealthState.unknown => frb_api.FrbHealthState.unknown,
    };
    final nativeCell = frb_api.FrbHealthCell(
      id: cell.id,
      providerId: cell.providerId,
      providerLabel: cell.providerLabel,
      dimensionId: cell.dimensionId,
      dimensionLabel: cell.dimensionLabel,
      state: nativeState,
      latencyMs: cell.latency != null
          ? BigInt.from(cell.latency!.inMilliseconds)
          : null,
    );
    final updated = await frb_api.setHealthCell(cell: nativeCell);
    _cachedSnapshot = _convertFromNative(updated);
  }

  /// Sets multiple [HealthCell]s in the Rust native substrate.
  Future<void> setCells(List<HealthCell> cells) async {
    if (_isClosed) {
      throw StateError('Cannot setCells on closed FrbHealthSource');
    }
    final nativeCells = cells.map((cell) {
      final nativeState = switch (cell.state) {
        HealthState.healthy => frb_api.FrbHealthState.healthy,
        HealthState.degraded => frb_api.FrbHealthState.degraded,
        HealthState.unreachable => frb_api.FrbHealthState.unreachable,
        HealthState.unknown => frb_api.FrbHealthState.unknown,
      };
      return frb_api.FrbHealthCell(
        id: cell.id,
        providerId: cell.providerId,
        providerLabel: cell.providerLabel,
        dimensionId: cell.dimensionId,
        dimensionLabel: cell.dimensionLabel,
        state: nativeState,
        latencyMs: cell.latency != null
            ? BigInt.from(cell.latency!.inMilliseconds)
            : null,
      );
    }).toList(growable: false);

    final updated = await frb_api.setHealthCells(cells: nativeCells);
    _cachedSnapshot = _convertFromNative(updated);
  }

  /// Sets the full [HealthSnapshot] in the Rust native substrate.
  Future<void> setSnapshot(HealthSnapshot snapshot) async {
    if (_isClosed) {
      throw StateError('Cannot setSnapshot on closed FrbHealthSource');
    }

    final nativeCells = snapshot.cells.map((cell) {
      final nativeState = switch (cell.state) {
        HealthState.healthy => frb_api.FrbHealthState.healthy,
        HealthState.degraded => frb_api.FrbHealthState.degraded,
        HealthState.unreachable => frb_api.FrbHealthState.unreachable,
        HealthState.unknown => frb_api.FrbHealthState.unknown,
      };
      return frb_api.FrbHealthCell(
        id: cell.id,
        providerId: cell.providerId,
        providerLabel: cell.providerLabel,
        dimensionId: cell.dimensionId,
        dimensionLabel: cell.dimensionLabel,
        state: nativeState,
        latencyMs: cell.latency != null
            ? BigInt.from(cell.latency!.inMilliseconds)
            : null,
      );
    }).toList(growable: false);

    final nativeAgg = switch (snapshot.aggregateState) {
      HealthState.healthy => frb_api.FrbHealthState.healthy,
      HealthState.degraded => frb_api.FrbHealthState.degraded,
      HealthState.unreachable => frb_api.FrbHealthState.unreachable,
      HealthState.unknown => frb_api.FrbHealthState.unknown,
    };

    final nativeSnap = frb_api.FrbHealthSnapshot(
      timestampMillis: snapshot.timestamp.millisecondsSinceEpoch,
      cells: nativeCells,
      aggregateState: nativeAgg,
      freshnessTtlMs: snapshot.freshnessTtl != null
          ? BigInt.from(snapshot.freshnessTtl!.inMilliseconds)
          : null,
    );

    final updated = await frb_api.setHealthSnapshot(snapshot: nativeSnap);
    _cachedSnapshot = _convertFromNative(updated);
  }

  @override
  Future<void> close() async {
    if (_isClosed) return;
    _isClosed = true;
    final sub = _watchSub;
    _watchSub = null;
    unawaited(sub?.cancel());
    if (!_controller.isClosed) {
      await _controller.close();
    }
  }

  /// Converts an FRB generated health snapshot to a Warp Prism [HealthSnapshot].
  static HealthSnapshot _convertFromNative(frb_api.FrbHealthSnapshot s) {
    final millis = s.timestampMillis.toInt();

    final cells = s.cells.map((c) {
      final state = switch (c.state) {
        frb_api.FrbHealthState.healthy => HealthState.healthy,
        frb_api.FrbHealthState.degraded => HealthState.degraded,
        frb_api.FrbHealthState.unreachable => HealthState.unreachable,
        frb_api.FrbHealthState.unknown => HealthState.unknown,
      };

      final latency = c.latencyMs != null
          ? Duration(milliseconds: c.latencyMs!.toInt())
          : null;

      return HealthCell(
        id: c.id,
        providerId: c.providerId,
        providerLabel: c.providerLabel,
        dimensionId: c.dimensionId,
        dimensionLabel: c.dimensionLabel,
        state: state,
        latency: latency,
      );
    }).toList(growable: false);

    final aggState = switch (s.aggregateState) {
      frb_api.FrbHealthState.healthy => HealthState.healthy,
      frb_api.FrbHealthState.degraded => HealthState.degraded,
      frb_api.FrbHealthState.unreachable => HealthState.unreachable,
      frb_api.FrbHealthState.unknown => HealthState.unknown,
    };

    final ttl = s.freshnessTtlMs != null
        ? Duration(milliseconds: s.freshnessTtlMs!.toInt())
        : null;

    return HealthSnapshot(
      timestamp: DateTime.fromMillisecondsSinceEpoch(millis),
      cells: cells,
      aggregateState: aggState,
      freshnessTtl: ttl,
    );
  }
}
