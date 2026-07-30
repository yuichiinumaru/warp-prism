/// Live log entry fixture model.
///
/// Mirrors live `cyberneticscoreLogEntrySchema` (cybernetics-core
/// `packages/zod-types/src/logs.zod.ts`) for Pilot C `/live-logs`.
/// [redacted] is a pilot UI field for redaction storytelling.
class LiveLogEntry {
  final String id;
  final DateTime timestamp;
  final String serverName;
  final String level;
  final String message;
  final String? error;
  final bool redacted;

  const LiveLogEntry({
    required this.id,
    required this.timestamp,
    required this.serverName,
    required this.level,
    required this.message,
    this.error,
    this.redacted = false,
  });

  factory LiveLogEntry.fromJson(Map<String, dynamic> json) {
    return LiveLogEntry(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      serverName: json['serverName'] as String,
      level: json['level'] as String,
      message: json['message'] as String,
      error: json['error'] as String?,
      redacted: json['redacted'] as bool? ?? false,
    );
  }
}

/// Wrapper for `GetLogsResponseSchema`-shaped fixture payloads.
class LiveLogsFixture {
  final bool success;
  final int totalCount;
  final List<LiveLogEntry> data;

  const LiveLogsFixture({
    required this.success,
    required this.totalCount,
    required this.data,
  });

  factory LiveLogsFixture.fromJson(Map<String, dynamic> json) {
    final raw = json['data'] as List<dynamic>? ?? const [];
    return LiveLogsFixture(
      success: json['success'] as bool? ?? true,
      totalCount: (json['totalCount'] as num?)?.toInt() ?? raw.length,
      data: raw
          .cast<Map<String, dynamic>>()
          .map(LiveLogEntry.fromJson)
          .toList(),
    );
  }
}
