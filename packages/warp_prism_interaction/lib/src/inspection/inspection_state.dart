import 'package:meta/meta.dart';
import '../state_machine/interaction_state.dart';
import 'inspection_intent.dart';

/// Lifecycle phases of an inspection session.
///
/// Lifecycle: PROVEN (see `.project/architecture/layer-contracts.md`).
enum InspectionLifecycle {
  /// Inspection intent has been proposed or hovered, not yet committed.
  proposed,

  /// Inspection is actively committed and presenting detail.
  active,

  /// Inspection has been dismissed or closed.
  dismissed,

  /// Inspection session exists but its lifecycle position cannot yet be
  /// determined (Task 1869, EXPERIMENTAL).
  ///
  /// Fail-closed: never counts as active, proposed, or dismissed.
  /// Reachable only by direct construction (e.g. restored persistence
  /// without status); no trigger manufactures it from a settled position.
  unknown,
}

/// Triggers that advance an inspection session through its lifecycle.
///
/// Lifecycle: PROVEN (see `.project/architecture/layer-contracts.md`).
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
/// Lifecycle: PROVEN (see `.project/architecture/layer-contracts.md`).
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
        // Unknown holds no position: it may resolve outward through the
        // normal triggers, but nothing transitions into it.
        InspectionLifecycle.unknown: {
          InspectionTrigger.propose,
          InspectionTrigger.activate,
          InspectionTrigger.dismiss,
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
        (InspectionLifecycle.unknown, InspectionTrigger.propose):
            InspectionLifecycle.proposed,
        (InspectionLifecycle.unknown, InspectionTrigger.activate):
            InspectionLifecycle.active,
        (InspectionLifecycle.unknown, InspectionTrigger.dismiss):
            InspectionLifecycle.dismissed,
      },
    );

/// Immutable payload describing an inspection session at a point in time.
///
/// Lifecycle: PROVEN (see `.project/architecture/layer-contracts.md`).
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

  /// True if the inspection lifecycle position is withheld (Task 1869).
  ///
  /// Fail-closed: an unknown payload is never active, proposed, or
  /// dismissed, so observers must not treat it as enabled or settled.
  bool get isUnknown => status == InspectionLifecycle.unknown;

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
