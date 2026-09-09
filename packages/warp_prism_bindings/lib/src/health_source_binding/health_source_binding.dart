import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:warp_prism_runtime/warp_prism_runtime.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

import 'health_source_view_model.dart';

/// Projection binding connecting a runtime [HealthSource] to reactive UI health view models.
///
/// Manages:
/// - Initial point-in-time [HealthSnapshot] query evaluation and projection.
/// - Reactive subscription to [HealthSource.watch] stream updates.
/// - Incremental view model updates and change notifications via [notifyListeners].
/// - Freshness tracking derived from snapshot TTL.
/// - Watch-error resilience ensuring error surfacing without corrupting source state.
/// - Deterministic subscription cancellation and stream disposal.
///
/// **PURGE LAW**: This binding contains strictly zero polling mechanisms,
/// ticker loops, or auto-repetition policies.
///
/// Lifecycle: EXPERIMENTAL (see `docs/architecture/layer-contracts-v2.md`).
@experimental
class HealthSourceBinding extends ChangeNotifier {
  /// The underlying runtime health source.
  final HealthSource source;

  HealthSourceBindingStatus _status = HealthSourceBindingStatus.uninitialized;
  HealthSourceViewModel _viewModel = HealthSourceViewModel.empty();
  HealthSnapshot? _lastSnapshot;
  StreamSubscription<HealthSnapshot>? _subscription;
  Object? _error;
  StackTrace? _stackTrace;
  bool _isDisposed = false;
  bool _isInitialized = false;

  final StreamController<HealthSourceViewModel> _modelStreamController =
      StreamController<HealthSourceViewModel>.broadcast();
  final StreamController<HealthSnapshot> _snapshotStreamController =
      StreamController<HealthSnapshot>.broadcast();

  /// Creates a [HealthSourceBinding] for the given [source].
  HealthSourceBinding({required this.source, bool autoInitialize = true}) {
    if (autoInitialize) {
      initialize();
    }
  }

  /// Initializes the binding by fetching current snapshot and subscribing to watch updates.
  Future<void> initialize({DateTime? asOf}) async {
    if (_isDisposed || _isInitialized) return;
    _isInitialized = true;

    try {
      final snapshot = await source.getSnapshot();
      if (!_isDisposed) {
        _applySnapshot(snapshot, asOf: asOf);
        _status = HealthSourceBindingStatus.active;
        _error = null;
        _stackTrace = null;
        _notifyAndDispatch();
      }
    } catch (e, st) {
      if (!_isDisposed) {
        _status = HealthSourceBindingStatus.error;
        _error = e;
        _stackTrace = st;
        _modelStreamController.addError(e, st);
        _snapshotStreamController.addError(e, st);
        notifyListeners();
      }
    }

    if (!_isDisposed && !source.isClosed) {
      _subscription = source.watch().listen(
        _handleWatchSnapshot,
        onError: (Object error, StackTrace stackTrace) {
          if (!_isDisposed) {
            _status = HealthSourceBindingStatus.error;
            _error = error;
            _stackTrace = stackTrace;
            _modelStreamController.addError(error, stackTrace);
            _snapshotStreamController.addError(error, stackTrace);
            notifyListeners();
          }
        },
        onDone: () {
          if (!_isDisposed) {
            _status = HealthSourceBindingStatus.completed;
            notifyListeners();
          }
        },
      );
    }
  }

  void _handleWatchSnapshot(HealthSnapshot snapshot) {
    if (_isDisposed) return;
    _applySnapshot(snapshot);
    _status = HealthSourceBindingStatus.active;
    _error = null;
    _stackTrace = null;
    _notifyAndDispatch();
  }

  void _applySnapshot(HealthSnapshot snapshot, {DateTime? asOf}) {
    _lastSnapshot = snapshot;
    _viewModel = HealthSourceViewModel.fromSnapshot(snapshot, asOf: asOf);
  }

  void _notifyAndDispatch() {
    notifyListeners();
    if (_lastSnapshot != null) {
      _snapshotStreamController.add(_lastSnapshot!);
    }
    _modelStreamController.add(_viewModel);
  }

  /// Manually re-evaluates the health snapshot from the underlying source.
  Future<HealthSourceViewModel> refresh({DateTime? asOf}) async {
    if (_isDisposed) {
      throw StateError('Cannot refresh a disposed HealthSourceBinding.');
    }
    try {
      final snapshot = await source.getSnapshot();
      if (!_isDisposed) {
        _applySnapshot(snapshot, asOf: asOf);
        _status = HealthSourceBindingStatus.active;
        _error = null;
        _stackTrace = null;
        _notifyAndDispatch();
      }
      return _viewModel;
    } catch (e, st) {
      if (!_isDisposed) {
        _status = HealthSourceBindingStatus.error;
        _error = e;
        _stackTrace = st;
        _modelStreamController.addError(e, st);
        _snapshotStreamController.addError(e, st);
        notifyListeners();
      }
      rethrow;
    }
  }

  /// Re-evaluates freshness for the currently retained snapshot without fetching.
  ///
  /// Useful when an external timer or UI clock triggers a freshness check.
  void checkFreshness({DateTime? asOf}) {
    if (_isDisposed || _lastSnapshot == null) return;
    final isCurrentlyStale = !_lastSnapshot!.isFresh(asOf: asOf);
    if (_viewModel.isStale != isCurrentlyStale) {
      _viewModel = HealthSourceViewModel.fromSnapshot(
        _lastSnapshot!,
        asOf: asOf,
      );
      _notifyAndDispatch();
    }
  }

  /// Current immutable presentation view model snapshot.
  HealthSourceViewModel get viewModel => _viewModel;

  /// Most recently evaluated runtime snapshot, if available.
  HealthSnapshot? get lastSnapshot => _lastSnapshot;

  /// Current binding lifecycle status.
  HealthSourceBindingStatus get status => _status;

  /// Captured error object if status is [HealthSourceBindingStatus.error].
  Object? get error => _error;

  /// Captured stack trace if status is [HealthSourceBindingStatus.error].
  StackTrace? get stackTrace => _stackTrace;

  /// Whether the initial snapshot evaluation has occurred.
  bool get isInitialized => _isInitialized;

  /// Whether this binding instance has been disposed.
  bool get isDisposed => _isDisposed;

  /// Whether the current view model contains zero cells.
  bool get isEmpty => _viewModel.isEmpty;

  /// Total count of health cells in the current view model.
  int get cellCount => _viewModel.cellCount;

  /// Current aggregated operational health state.
  HealthState get aggregateState => _viewModel.aggregateState;

  /// Whether the current snapshot is considered stale.
  bool get isStale => _viewModel.isStale;

  /// Whether the current snapshot is fresh (not stale).
  bool get isFresh => _viewModel.isFresh;

  /// Health dimension cells included in the current projection.
  List<HealthCell> get cells => _viewModel.cells;

  /// Projected [PrismProviderHealthProvider] list for [PrismProviderHealthMatrix].
  List<PrismProviderHealthProvider> get providers =>
      _viewModel.toProviderHealthProviders();

  /// Reactive stream of updated [HealthSourceViewModel] snapshots.
  Stream<HealthSourceViewModel> get viewModelStream =>
      _modelStreamController.stream;

  /// Reactive stream alias for [viewModelStream] for consistency across bindings.
  Stream<HealthSourceViewModel> get modelStream =>
      _modelStreamController.stream;

  /// Reactive stream of raw [HealthSnapshot]s emitted by the source.
  Stream<HealthSnapshot> get snapshotStream =>
      _snapshotStreamController.stream;

  @override
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    _status = HealthSourceBindingStatus.disposed;
    _subscription?.cancel();
    _subscription = null;
    _modelStreamController.close();
    _snapshotStreamController.close();
    super.dispose();
  }
}
