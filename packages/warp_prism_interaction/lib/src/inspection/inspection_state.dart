import 'package:meta/meta.dart';
import '../state_machine/interaction_state.dart';
import 'inspection_intent.dart';

/// Lifecycle phases of an inspection session.
///
/// Lifecycle: PROVEN (see `docs/architecture/layer-contracts-v2.md`).
enum InspectionLifecycle {
  /// Inspection intent has been proposed or hovered, not yet committed.
  proposed,

  /// Inspection is actively committed and presenting detail.
  active,

  /// Inspection has been dismissed or closed.
  dismissed,
}

/// Triggers that advance an inspection session through its lifecycle.
///
/// Lifecycle: PROVEN (see `docs/architecture/layer-contracts-v2.md`).
enum InspectionTrigger {
  /// Propose an inspection target (e.g. hover preview).
  propose,

  /// Commit and activate inspection (e.g. click/enter).
  activate,

  /// Dismiss the active inspection.
  dismiss,

  /// Reset/clear the inspection state to null/idle.
  reset,
}

/// Canonical transition table for inspection lifecycles.
///
/// Lifecycle: PROVEN (see `docs/architecture/layer-contracts-v2.md`).
const inspectionTransitionTable =
    InteractionTransitionTable<InspectionLifecycle, InspectionTrigger>(
      allowedTriggers: {
        InspectionLifecycle.proposed: {
          InspectionTrigger.activate,
          InspectionTrigger.dismiss,
          InspectionTrigger.propose,
        },
        InspectionLifecycle.active: {
          InspectionTrigger.dismiss,
          InspectionTrigger.propose,
          InspectionTrigger.activate,
        },
        InspectionLifecycle.dismissed: {
          InspectionTrigger.propose,
          InspectionTrigger.activate,
        },
      },
      targetStates: {
        (InspectionLifecycle.proposed, InspectionTrigger.activate):
            InspectionLifecycle.active,
        (InspectionLifecycle.proposed, InspectionTrigger.dismiss):
            InspectionLifecycle.dismissed,
        (InspectionLifecycle.proposed, InspectionTrigger.propose):
            InspectionLifecycle.proposed,
        (InspectionLifecycle.active, InspectionTrigger.dismiss):
            InspectionLifecycle.dismissed,
        (InspectionLifecycle.active, InspectionTrigger.propose):
            InspectionLifecycle.proposed,
        (InspectionLifecycle.active, InspectionTrigger.activate):
            InspectionLifecycle.active,
        (InspectionLifecycle.dismissed, InspectionTrigger.propose):
            InspectionLifecycle.proposed,
        (InspectionLifecycle.dismissed, InspectionTrigger.activate):
            InspectionLifecycle.active,
      },
    );

/// Immutable payload describing an inspection session at a point in time.
///
/// Lifecycle: PROVEN (see `docs/architecture/layer-contracts-v2.md`).
@immutable
class InspectionPayload<T extends Object> {
  /// The underlying inspection intent.
  final InspectionIntent<T> intent;

  /// The current lifecycle status of this inspection.
  final InspectionLifecycle status;

  /// Timestamp when the session opened.
  final DateTime openedAt;

  /// Timestamp when the session was dismissed, if applicable.
  final DateTime? dismissedAt;

  InspectionPayload({
    required this.intent,
    required this.status,
    DateTime? openedAt,
    this.dismissedAt,
  }) : openedAt = openedAt ?? DateTime.now();

  /// True if inspection is currently active and presenting.
  bool get isActive => status == InspectionLifecycle.active;

  /// True if inspection is in preview/proposed stage.
  bool get isProposed => status == InspectionLifecycle.proposed;

  /// True if inspection has been dismissed.
  bool get isDismissed => status == InspectionLifecycle.dismissed;

  /// The target being inspected.
  T get target => intent.target;

  /// Returns a new payload transitioning to [newStatus].
  InspectionPayload<T> transitionTo(InspectionLifecycle newStatus) {
    return InspectionPayload<T>(
      intent: intent,
      status: newStatus,
      openedAt: openedAt,
      dismissedAt: newStatus == InspectionLifecycle.dismissed
          ? DateTime.now()
          : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! InspectionPayload<T>) return false;
    return other.intent == intent &&
        other.status == status &&
        other.openedAt == openedAt &&
        other.dismissedAt == dismissedAt;
  }

  @override
  int get hashCode => Object.hash(intent, status, openedAt, dismissedAt);

  @override
  String toString() =>
      'InspectionPayload<$T>(target: $target, status: $status, openedAt: $openedAt)';
}
