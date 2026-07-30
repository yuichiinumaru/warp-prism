/// Dashboard summary fixture model.
///
/// Aggregated workspace metrics for the CyberCore dashboard route.
/// Maps to CyberCore entity: system health overview (Feature 1307).
class DashboardSummary {
  final AgentMetrics agentMetrics;
  final SkillMetrics skillMetrics;
  final WorkflowMetrics workflowMetrics;
  final ExecutionMetrics executionMetrics;
  final RecentActivity recentActivity;

  const DashboardSummary({
    required this.agentMetrics,
    required this.skillMetrics,
    required this.workflowMetrics,
    required this.executionMetrics,
    required this.recentActivity,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      agentMetrics: AgentMetrics.fromJson(
        json['agentMetrics'] as Map<String, dynamic>,
      ),
      skillMetrics: SkillMetrics.fromJson(
        json['skillMetrics'] as Map<String, dynamic>,
      ),
      workflowMetrics: WorkflowMetrics.fromJson(
        json['workflowMetrics'] as Map<String, dynamic>,
      ),
      executionMetrics: ExecutionMetrics.fromJson(
        json['executionMetrics'] as Map<String, dynamic>,
      ),
      recentActivity: RecentActivity.fromJson(
        json['recentActivity'] as Map<String, dynamic>,
      ),
    );
  }

  int get totalEntities =>
      agentMetrics.total +
      skillMetrics.total +
      workflowMetrics.total +
      executionMetrics.totalTasks;
}

class AgentMetrics {
  final int total;
  final int healthy;
  final int degraded;

  const AgentMetrics({
    required this.total,
    required this.healthy,
    required this.degraded,
  });

  factory AgentMetrics.fromJson(Map<String, dynamic> json) {
    return AgentMetrics(
      total: json['total'] as int,
      healthy: json['healthy'] as int,
      degraded: json['degraded'] as int,
    );
  }
}

class SkillMetrics {
  final int total;
  final int withTriggers;
  final int noTriggers;

  const SkillMetrics({
    required this.total,
    required this.withTriggers,
    required this.noTriggers,
  });

  factory SkillMetrics.fromJson(Map<String, dynamic> json) {
    return SkillMetrics(
      total: json['total'] as int,
      withTriggers: json['withTriggers'] as int,
      noTriggers: json['noTriggers'] as int,
    );
  }
}

class WorkflowMetrics {
  final int total;
  final int active;
  final int orphaned;

  const WorkflowMetrics({
    required this.total,
    required this.active,
    required this.orphaned,
  });

  factory WorkflowMetrics.fromJson(Map<String, dynamic> json) {
    return WorkflowMetrics(
      total: json['total'] as int,
      active: json['active'] as int,
      orphaned: json['orphaned'] as int,
    );
  }
}

class ExecutionMetrics {
  final int planning;
  final int open;
  final int doing;
  final int review;
  final int completed;

  const ExecutionMetrics({
    required this.planning,
    required this.open,
    required this.doing,
    required this.review,
    required this.completed,
  });

  factory ExecutionMetrics.fromJson(Map<String, dynamic> json) {
    return ExecutionMetrics(
      planning: json['planning'] as int,
      open: json['open'] as int,
      doing: json['doing'] as int,
      review: json['review'] as int,
      completed: json['completed'] as int,
    );
  }

  int get totalTasks => planning + open + doing + review + completed;
}

class RecentActivity {
  final int total;
  final int lastWeek;
  final Map<String, int> types;

  const RecentActivity({
    required this.total,
    required this.lastWeek,
    required this.types,
  });

  factory RecentActivity.fromJson(Map<String, dynamic> json) {
    final typesMap = <String, int>{};
    final rawTypes = json['types'] as Map<String, dynamic>;
    for (final entry in rawTypes.entries) {
      typesMap[entry.key] = entry.value as int;
    }
    return RecentActivity(
      total: json['total'] as int,
      lastWeek: json['lastWeek'] as int,
      types: typesMap,
    );
  }
}
