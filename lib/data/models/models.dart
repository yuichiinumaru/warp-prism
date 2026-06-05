/// Domain models for the ASW Observatory
/// Defines the core entities: Agent, Skill, Workflow, Task, ChangelogEntry
library;

import 'package:flutter/foundation.dart';

/// Status enum for agents
enum AgentStatus { active, idle, error, disabled }

/// Status enum for tasks
enum TaskStatus { backlog, inProgress, review, done, blocked }

/// Priority enum for tasks
enum TaskPriority { low, medium, high, critical }

/// Asset type enum for graph nodes
enum AssetType { agent, skill, workflow, task, doc }

/// Base class for all workspace assets
@immutable
abstract class Asset {
  final String id;
  final String name;
  final String description;
  final String version;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> tags;
  final Map<String, dynamic> metadata;

  const Asset({
    required this.id,
    required this.name,
    required this.description,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    this.tags = const [],
    this.metadata = const {},
  });

  AssetType get assetType;
}

/// Agent model
@immutable
class Agent extends Asset {
  final AgentStatus status;
  final AgentModel model;
  final String systemPrompt;
  final List<String> capabilities;
  final List<AgentTool> tools;
  final List<String> skillIds;
  final List<String> workflowIds;

  const Agent({
    required super.id,
    required super.name,
    required super.description,
    required super.version,
    required super.createdAt,
    required super.updatedAt,
    super.tags,
    super.metadata,
    required this.status,
    required this.model,
    required this.systemPrompt,
    this.capabilities = const [],
    this.tools = const [],
    this.skillIds = const [],
    this.workflowIds = const [],
  });

  @override
  AssetType get assetType => AssetType.agent;

  Agent copyWith({
    String? id,
    String? name,
    String? description,
    String? version,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
    Map<String, dynamic>? metadata,
    AgentStatus? status,
    AgentModel? model,
    String? systemPrompt,
    List<String>? capabilities,
    List<AgentTool>? tools,
    List<String>? skillIds,
    List<String>? workflowIds,
  }) {
    return Agent(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
      status: status ?? this.status,
      model: model ?? this.model,
      systemPrompt: systemPrompt ?? this.systemPrompt,
      capabilities: capabilities ?? this.capabilities,
      tools: tools ?? this.tools,
      skillIds: skillIds ?? this.skillIds,
      workflowIds: workflowIds ?? this.workflowIds,
    );
  }
}

/// Agent model configuration
@immutable
class AgentModel {
  final String provider;
  final String name;
  final double temperature;
  final int maxTokens;

  const AgentModel({
    required this.provider,
    required this.name,
    this.temperature = 0.7,
    this.maxTokens = 4096,
  });
}

/// Agent tool definition
@immutable
class AgentTool {
  final String name;
  final String description;
  final Map<String, ToolParameter> parameters;

  const AgentTool({
    required this.name,
    required this.description,
    this.parameters = const {},
  });
}

/// Tool parameter definition
@immutable
class ToolParameter {
  final String type;
  final bool required;
  final dynamic defaultValue;
  final List<String>? enumValues;

  const ToolParameter({
    required this.type,
    this.required = false,
    this.defaultValue,
    this.enumValues,
  });
}

/// Skill model
@immutable
class Skill extends Asset {
  final List<SkillInput> inputs;
  final List<SkillOutput> outputs;
  final List<SkillStep> steps;
  final List<String> usedByAgentIds;

  const Skill({
    required super.id,
    required super.name,
    required super.description,
    required super.version,
    required super.createdAt,
    required super.updatedAt,
    super.tags,
    super.metadata,
    this.inputs = const [],
    this.outputs = const [],
    this.steps = const [],
    this.usedByAgentIds = const [],
  });

  @override
  AssetType get assetType => AssetType.skill;

  Skill copyWith({
    String? id,
    String? name,
    String? description,
    String? version,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
    Map<String, dynamic>? metadata,
    List<SkillInput>? inputs,
    List<SkillOutput>? outputs,
    List<SkillStep>? steps,
    List<String>? usedByAgentIds,
  }) {
    return Skill(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
      inputs: inputs ?? this.inputs,
      outputs: outputs ?? this.outputs,
      steps: steps ?? this.steps,
      usedByAgentIds: usedByAgentIds ?? this.usedByAgentIds,
    );
  }
}

/// Skill input definition
@immutable
class SkillInput {
  final String name;
  final String type;
  final String description;
  final bool required;
  final dynamic defaultValue;

  const SkillInput({
    required this.name,
    required this.type,
    required this.description,
    this.required = false,
    this.defaultValue,
  });
}

/// Skill output definition
@immutable
class SkillOutput {
  final String name;
  final String type;
  final String description;

  const SkillOutput({
    required this.name,
    required this.type,
    required this.description,
  });
}

/// Skill step definition
@immutable
class SkillStep {
  final String name;
  final String action;
  final String description;
  final String? condition;
  final Map<String, dynamic> config;

  const SkillStep({
    required this.name,
    required this.action,
    required this.description,
    this.condition,
    this.config = const {},
  });
}

/// Workflow model
@immutable
class Workflow extends Asset {
  final String status;
  final WorkflowTrigger trigger;
  final List<WorkflowStage> stages;
  final WorkflowErrorHandling? errorHandling;
  final double? avgDurationMinutes;
  final double? successRate;

  const Workflow({
    required super.id,
    required super.name,
    required super.description,
    required super.version,
    required super.createdAt,
    required super.updatedAt,
    super.tags,
    super.metadata,
    required this.status,
    required this.trigger,
    this.stages = const [],
    this.errorHandling,
    this.avgDurationMinutes,
    this.successRate,
  });

  @override
  AssetType get assetType => AssetType.workflow;

  Workflow copyWith({
    String? id,
    String? name,
    String? description,
    String? version,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
    Map<String, dynamic>? metadata,
    String? status,
    WorkflowTrigger? trigger,
    List<WorkflowStage>? stages,
    WorkflowErrorHandling? errorHandling,
    double? avgDurationMinutes,
    double? successRate,
  }) {
    return Workflow(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
      status: status ?? this.status,
      trigger: trigger ?? this.trigger,
      stages: stages ?? this.stages,
      errorHandling: errorHandling ?? this.errorHandling,
      avgDurationMinutes: avgDurationMinutes ?? this.avgDurationMinutes,
      successRate: successRate ?? this.successRate,
    );
  }
}

/// Workflow trigger definition
@immutable
class WorkflowTrigger {
  final String type;
  final String? event;
  final List<SkillInput> inputs;

  const WorkflowTrigger({
    required this.type,
    this.event,
    this.inputs = const [],
  });
}

/// Workflow stage definition
@immutable
class WorkflowStage {
  final String name;
  final String description;
  final String? agentId;
  final String? skillId;
  final String? type;
  final Map<String, dynamic> inputs;
  final List<String> outputs;
  final int? timeout;
  final bool parallel;
  final String? condition;
  final Map<String, String>? branches;

  const WorkflowStage({
    required this.name,
    required this.description,
    this.agentId,
    this.skillId,
    this.type,
    this.inputs = const {},
    this.outputs = const [],
    this.timeout,
    this.parallel = false,
    this.condition,
    this.branches,
  });
}

/// Workflow error handling configuration
@immutable
class WorkflowErrorHandling {
  final RetryPolicy? retryPolicy;
  final List<FallbackRule> fallbackRules;

  const WorkflowErrorHandling({
    this.retryPolicy,
    this.fallbackRules = const [],
  });
}

/// Retry policy for workflow stages
@immutable
class RetryPolicy {
  final int maxAttempts;
  final String backoff;
  final int initialDelay;

  const RetryPolicy({
    this.maxAttempts = 3,
    this.backoff = 'exponential',
    this.initialDelay = 30,
  });
}

/// Fallback rule for error handling
@immutable
class FallbackRule {
  final String condition;
  final String action;

  const FallbackRule({
    required this.condition,
    required this.action,
  });
}

/// Task model
@immutable
class Task extends Asset {
  final TaskStatus status;
  final TaskPriority priority;
  final String? assignedAgentId;
  final String? workflowId;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final double? progress;

  const Task({
    required super.id,
    required super.name,
    required super.description,
    required super.version,
    required super.createdAt,
    required super.updatedAt,
    super.tags,
    super.metadata,
    required this.status,
    required this.priority,
    this.assignedAgentId,
    this.workflowId,
    this.startedAt,
    this.completedAt,
    this.progress,
  });

  @override
  AssetType get assetType => AssetType.task;

  Task copyWith({
    String? id,
    String? name,
    String? description,
    String? version,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
    Map<String, dynamic>? metadata,
    TaskStatus? status,
    TaskPriority? priority,
    String? assignedAgentId,
    String? workflowId,
    DateTime? startedAt,
    DateTime? completedAt,
    double? progress,
  }) {
    return Task(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      assignedAgentId: assignedAgentId ?? this.assignedAgentId,
      workflowId: workflowId ?? this.workflowId,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      progress: progress ?? this.progress,
    );
  }
}

/// Changelog entry model
@immutable
class ChangelogEntry extends Asset {
  final String summary;
  final List<ChangeSection> changes;
  final List<AffectedAsset> affectedAssets;
  final List<Evidence> evidence;
  final String author;

  const ChangelogEntry({
    required super.id,
    required super.name,
    required super.description,
    required super.version,
    required super.createdAt,
    required super.updatedAt,
    super.tags,
    super.metadata,
    required this.summary,
    this.changes = const [],
    this.affectedAssets = const [],
    this.evidence = const [],
    required this.author,
  });

  @override
  AssetType get assetType => AssetType.doc;

  ChangelogEntry copyWith({
    String? id,
    String? name,
    String? description,
    String? version,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
    Map<String, dynamic>? metadata,
    String? summary,
    List<ChangeSection>? changes,
    List<AffectedAsset>? affectedAssets,
    List<Evidence>? evidence,
    String? author,
  }) {
    return ChangelogEntry(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
      summary: summary ?? this.summary,
      changes: changes ?? this.changes,
      affectedAssets: affectedAssets ?? this.affectedAssets,
      evidence: evidence ?? this.evidence,
      author: author ?? this.author,
    );
  }
}

/// Change section in changelog
@immutable
class ChangeSection {
  final String type; // added, changed, fixed, deprecated, removed, security
  final List<String> items;

  const ChangeSection({
    required this.type,
    required this.items,
  });
}

/// Affected asset reference in changelog
@immutable
class AffectedAsset {
  final AssetType type;
  final String name;
  final String? oldVersion;
  final String newVersion;

  const AffectedAsset({
    required this.type,
    required this.name,
    this.oldVersion,
    required this.newVersion,
  });
}

/// Evidence reference in changelog
@immutable
class Evidence {
  final String type; // pr, issue, benchmark, report
  final String reference;
  final String? description;

  const Evidence({
    required this.type,
    required this.reference,
    this.description,
  });
}

/// Edge connection between assets
@immutable
class AssetEdge {
  final String sourceId;
  final String targetId;
  final String edgeType; // uses, triggers, references, delegates

  const AssetEdge({
    required this.sourceId,
    required this.targetId,
    required this.edgeType,
  });
}
