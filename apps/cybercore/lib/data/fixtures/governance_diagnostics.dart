/// Governance diagnostics fixture model.
///
/// Maps to CyberCore entity: policy compliance diagnostics.
class GovernanceDiagnostics {
  final List<String> orphanWorkflows;
  final List<String> noTriggerSkills;
  final List<UnverifiedTask> unverifiedTasks;
  final Map<String, int> canonicalityBoundary;
  final List<FanInHotspot> fanInHotspots;

  const GovernanceDiagnostics({
    required this.orphanWorkflows,
    required this.noTriggerSkills,
    required this.unverifiedTasks,
    required this.canonicalityBoundary,
    required this.fanInHotspots,
  });

  factory GovernanceDiagnostics.fromJson(Map<String, dynamic> json) {
    return GovernanceDiagnostics(
      orphanWorkflows: (json['orphanWorkflows'] as List<dynamic>).cast<String>(),
      noTriggerSkills: (json['noTriggerSkills'] as List<dynamic>).cast<String>(),
      unverifiedTasks: (json['unverifiedTasks'] as List<dynamic>)
          .map((e) => UnverifiedTask.fromJson(e as Map<String, dynamic>))
          .toList(),
      canonicalityBoundary: (json['canonicalityBoundary'] as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, v as int)),
      fanInHotspots: (json['fanInHotspots'] as List<dynamic>)
          .map((e) => FanInHotspot.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  int get totalIssues =>
      orphanWorkflows.length + noTriggerSkills.length + unverifiedTasks.length;
}

class UnverifiedTask {
  final String taskId;
  final String title;
  final String priority;

  const UnverifiedTask({
    required this.taskId,
    required this.title,
    required this.priority,
  });

  factory UnverifiedTask.fromJson(Map<String, dynamic> json) {
    return UnverifiedTask(
      taskId: json['taskId'] as String,
      title: json['title'] as String,
      priority: json['priority'] as String,
    );
  }
}

class FanInHotspot {
  final String skillName;
  final int referenceCount;

  const FanInHotspot({
    required this.skillName,
    required this.referenceCount,
  });

  factory FanInHotspot.fromJson(Map<String, dynamic> json) {
    return FanInHotspot(
      skillName: json['skillName'] as String,
      referenceCount: json['referenceCount'] as int,
    );
  }
}
