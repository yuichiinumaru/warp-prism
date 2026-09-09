import 'package:meta/meta.dart';
import 'package:warp_prism_runtime/warp_prism_runtime.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// Operational lifecycle status of an [EventStreamBinding].
///
/// Lifecycle: EXPERIMENTAL (see `docs/architecture/layer-contracts-v2.md`).
@experimental
enum EventStreamBindingStatus {
  /// Actively receiving and processing incoming stream events.
  active,

  /// Stream event processing is temporarily paused.
  paused,

  /// Source stream has terminated and completed event delivery.
  completed,

  /// Source stream encountered an unhandled error condition.
  error,

  /// Binding has been disposed and released all subscriptions.
  disposed,
}

/// Optional presentation-side follow/scroll tracking hook.
///
/// **PURGE LAW**: This is an advisory view-model state for widgets,
/// not an internal timer or scrolling engine.
///
/// Lifecycle: EXPERIMENTAL (see `docs/architecture/layer-contracts-v2.md`).
@experimental
enum EventStreamFollowState {
  /// Consumer UI is attached and following stream tail.
  following,

  /// User scrolled away or detached from tail.
  unlocked,

  /// Follow behavior is explicitly paused.
  paused,
}

/// Utility mappers projecting runtime events to UI presentation models.
///
/// Lifecycle: EXPERIMENTAL (see `docs/architecture/layer-contracts-v2.md`).
@experimental
class EventStreamMappers {
  const EventStreamMappers._();

  /// Maps a [RuntimeEvent] to a [PrismExecutionLine].
  static PrismExecutionLine runtimeEventToExecutionLine(
    RuntimeEvent<dynamic> event,
  ) {
    return PrismExecutionLine(
      id: event.id,
      message: event.payload.toString(),
      level: eventSeverityToExecutionLineLevel(event.severity),
      runGroupId: event.runGroupId,
      source: event.source,
      timestampLabel: _formatTimestamp(event.timestamp),
    );
  }

  /// Maps [EventSeverity] to [PrismExecutionLineLevel].
  static PrismExecutionLineLevel eventSeverityToExecutionLineLevel(
    EventSeverity severity,
  ) {
    switch (severity) {
      case EventSeverity.stdout:
        return PrismExecutionLineLevel.stdout;
      case EventSeverity.stderr:
        return PrismExecutionLineLevel.stderr;
      case EventSeverity.info:
        return PrismExecutionLineLevel.info;
      case EventSeverity.warning:
        return PrismExecutionLineLevel.warning;
      case EventSeverity.error:
        return PrismExecutionLineLevel.error;
      case EventSeverity.system:
        return PrismExecutionLineLevel.system;
    }
  }

  /// Maps a [RuntimeEvent] to a [PrismLogEntry].
  static PrismLogEntry runtimeEventToLogEntry(RuntimeEvent<dynamic> event) {
    return PrismLogEntry(
      id: event.id,
      timestamp: event.timestamp,
      severity: eventSeverityToLogSeverity(event.severity),
      source: event.source ?? 'runtime',
      message: event.payload.toString(),
      detail: event.metadata.isNotEmpty ? event.metadata.toString() : null,
    );
  }

  /// Maps [EventSeverity] to [PrismLogSeverity].
  static PrismLogSeverity eventSeverityToLogSeverity(EventSeverity severity) {
    switch (severity) {
      case EventSeverity.stdout:
      case EventSeverity.info:
        return PrismLogSeverity.info;
      case EventSeverity.stderr:
      case EventSeverity.error:
        return PrismLogSeverity.error;
      case EventSeverity.warning:
        return PrismLogSeverity.warning;
      case EventSeverity.system:
        return PrismLogSeverity.debug;
    }
  }

  static String _formatTimestamp(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}
