import 'ds_log_severity.dart';

/// Immutable data model for a single log entry in [DSLogViewer].
///
/// Fields:
/// - [id]: unique identifier for selection/expand tracking.
/// - [timestamp]: when the log event occurred.
/// - [severity]: debug / info / warning / error / critical.
/// - [source]: originating component, agent, or server name.
/// - [message]: primary log line.
/// - [detail]: optional extended content (stack trace, metadata JSON).
class DSLogEntry {
  final String id;
  final DateTime timestamp;
  final DSLogSeverity severity;
  final String source;
  final String message;
  final String? detail;

  const DSLogEntry({
    required this.id,
    required this.timestamp,
    required this.severity,
    required this.source,
    required this.message,
    this.detail,
  });

  /// Whether this entry has expandable detail content.
  bool get hasDetail => detail != null && detail!.isNotEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DSLogEntry && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
