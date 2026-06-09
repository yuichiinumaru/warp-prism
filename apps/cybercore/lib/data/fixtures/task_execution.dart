/// Task execution fixture model.
///
/// Maps to CyberCore entity: Task A2A / WorkflowExecution.
class TaskExecution {
  final String id;
  final String title;
  final String lane;
  final String? priority;
  final String? owner;
  final String proofState;
  final double? reviewScore;
  final List<String> dependsOn;
  final String operationalState;

  const TaskExecution({
    required this.id,
    required this.title,
    required this.lane,
    this.priority,
    this.owner,
    required this.proofState,
    this.reviewScore,
    required this.dependsOn,
    required this.operationalState,
  });

  factory TaskExecution.fromJson(Map<String, dynamic> json) {
    return TaskExecution(
      id: json['id'] as String,
      title: json['title'] as String,
      lane: json['lane'] as String,
      priority: json['priority'] as String?,
      owner: json['owner'] as String?,
      proofState: json['proofState'] as String,
      reviewScore: (json['reviewScore'] as num?)?.toDouble(),
      dependsOn: (json['dependsOn'] as List<dynamic>).cast<String>(),
      operationalState: json['operationalState'] as String,
    );
  }

  /// Lane ID without numeric prefix for display.
  String get laneName {
    final parts = lane.split('-');
    if (parts.length > 1) {
      return parts.sublist(1).join('-');
    }
    return lane;
  }
}
