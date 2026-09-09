import 'dart:async';
import 'package:meta/meta.dart';
import 'health_source_models.dart';

/// Backend-agnostic health observation contract.
///
/// Exposes on-demand point-in-time [HealthSnapshot] evaluations and reactive
/// [watch] streams for operational state changes.
///
/// **PURGE LAW**: This contract contains strictly zero polling mechanisms,
/// repetition policies, or UI focus refresh triggers.
///
/// Lifecycle: EXPERIMENTAL (see `docs/architecture/layer-contracts-v2.md`).
@experimental
abstract interface class HealthSource {
  /// Evaluates and returns an immediate point-in-time [HealthSnapshot].
  Future<HealthSnapshot> getSnapshot();

  /// Reactive stream emitting updated [HealthSnapshot]s when provider health changes.
  Stream<HealthSnapshot> watch();

  /// Whether this health source has been closed.
  bool get isClosed;

  /// Closes this health source and terminates any active watchers.
  Future<void> close();
}
