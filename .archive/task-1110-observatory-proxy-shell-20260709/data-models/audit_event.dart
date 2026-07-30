/// Audit event fixture model.
///
/// Maps to CyberCore entity: AuditEvent.
class AuditEvent {
  final String id;
  final String date;
  final String project;
  final String task;
  final String type;
  final String impact;
  final List<String> skills;
  final String? body;

  const AuditEvent({
    required this.id,
    required this.date,
    required this.project,
    required this.task,
    required this.type,
    required this.impact,
    required this.skills,
    this.body,
  });

  factory AuditEvent.fromJson(Map<String, dynamic> json) {
    return AuditEvent(
      id: json['id'] as String,
      date: json['date'] as String,
      project: json['project'] as String,
      task: json['task'] as String,
      type: json['type'] as String,
      impact: json['impact'] as String,
      skills: (json['skills'] as List<dynamic>).cast<String>(),
      body: json['body'] as String?,
    );
  }

  /// Parsed date for display.
  DateTime get dateTime => DateTime.parse(date);

  /// Display-formatted date string.
  String get displayDate {
    final dt = dateTime;
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
