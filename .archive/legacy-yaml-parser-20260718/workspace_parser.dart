/// YAML parser for workspace files
/// Parses agent, skill, workflow YAML files into domain models
library;

import 'package:yaml/yaml.dart';
import '../models/models.dart';

/// Parser for workspace YAML files
class WorkspaceParser {
  /// Parse an agent YAML file
  Agent parseAgent(String yamlContent, String id) {
    final yaml = loadYaml(yamlContent) as YamlMap;

    final modelYaml = yaml['model'] as YamlMap?;
    final model = modelYaml != null
        ? AgentModel(
            provider: modelYaml['provider'] as String? ?? 'unknown',
            name: modelYaml['name'] as String? ?? 'unknown',
            temperature: (modelYaml['temperature'] as num?)?.toDouble() ?? 0.7,
            maxTokens: modelYaml['max_tokens'] as int? ?? 4096,
          )
        : const AgentModel(provider: 'unknown', name: 'unknown');

    final toolsYaml = yaml['tools'] as YamlList?;
    final tools =
        toolsYaml?.map((t) {
          final toolMap = t as YamlMap;
          final paramsYaml = toolMap['parameters'] as YamlMap?;
          final params = <String, ToolParameter>{};
          paramsYaml?.forEach((key, value) {
            final paramMap = value as YamlMap;
            params[key as String] = ToolParameter(
              type: paramMap['type'] as String? ?? 'string',
              required: paramMap['required'] as bool? ?? false,
              defaultValue: paramMap['default'],
              enumValues: (paramMap['enum'] as YamlList?)
                  ?.map((e) => e.toString())
                  .toList(),
            );
          });
          return AgentTool(
            name: toolMap['name'] as String? ?? '',
            description: toolMap['description'] as String? ?? '',
            parameters: params,
          );
        }).toList() ??
        [];

    final metadataYaml = yaml['metadata'] as YamlMap?;
    final tagsYaml = metadataYaml?['tags'] as YamlList?;

    return Agent(
      id: id,
      name: yaml['name'] as String? ?? id,
      description: yaml['description'] as String? ?? '',
      version: yaml['version'] as String? ?? '1.0.0',
      createdAt: _parseDate(metadataYaml?['created']),
      updatedAt: _parseDate(metadataYaml?['updated']),
      tags: tagsYaml?.map((t) => t.toString()).toList() ?? [],
      metadata: _yamlMapToMap(metadataYaml),
      status: _parseAgentStatus(yaml['status'] as String?),
      model: model,
      systemPrompt: yaml['system_prompt'] as String? ?? '',
      capabilities:
          (yaml['capabilities'] as YamlList?)
              ?.map((c) => c.toString())
              .toList() ??
          [],
      tools: tools,
      skillIds:
          (yaml['skills'] as YamlList?)?.map((s) => s.toString()).toList() ??
          [],
      workflowIds:
          (yaml['workflows'] as YamlList?)?.map((w) => w.toString()).toList() ??
          [],
    );
  }

  /// Parse a skill YAML file
  Skill parseSkill(String yamlContent, String id) {
    final yaml = loadYaml(yamlContent) as YamlMap;

    final inputsYaml = yaml['inputs'] as YamlList?;
    final inputs =
        inputsYaml?.map((i) {
          final inputMap = i as YamlMap;
          return SkillInput(
            name: inputMap['name'] as String? ?? '',
            type: inputMap['type'] as String? ?? 'string',
            description: inputMap['description'] as String? ?? '',
            required: inputMap['required'] as bool? ?? false,
            defaultValue: inputMap['default'],
          );
        }).toList() ??
        [];

    final outputsYaml = yaml['outputs'] as YamlList?;
    final outputs =
        outputsYaml?.map((o) {
          final outputMap = o as YamlMap;
          return SkillOutput(
            name: outputMap['name'] as String? ?? '',
            type: outputMap['type'] as String? ?? 'string',
            description: outputMap['description'] as String? ?? '',
          );
        }).toList() ??
        [];

    final stepsYaml = yaml['steps'] as YamlList?;
    final steps =
        stepsYaml?.map((s) {
          final stepMap = s as YamlMap;
          return SkillStep(
            name: stepMap['name'] as String? ?? '',
            action: stepMap['action'] as String? ?? '',
            description: stepMap['description'] as String? ?? '',
            condition: stepMap['condition'] as String?,
            config: _yamlMapToMap(stepMap['config'] as YamlMap?),
          );
        }).toList() ??
        [];

    final metadataYaml = yaml['metadata'] as YamlMap?;
    final tagsYaml = metadataYaml?['tags'] as YamlList?;
    final usedByYaml = metadataYaml?['used_by'] as YamlList?;

    return Skill(
      id: id,
      name: yaml['name'] as String? ?? id,
      description: yaml['description'] as String? ?? '',
      version: yaml['version'] as String? ?? '1.0.0',
      createdAt: _parseDate(metadataYaml?['created']),
      updatedAt: _parseDate(metadataYaml?['updated']),
      tags: tagsYaml?.map((t) => t.toString()).toList() ?? [],
      metadata: _yamlMapToMap(metadataYaml),
      inputs: inputs,
      outputs: outputs,
      steps: steps,
      usedByAgentIds: usedByYaml?.map((a) => a.toString()).toList() ?? [],
    );
  }

  /// Parse a workflow YAML file
  Workflow parseWorkflow(String yamlContent, String id) {
    final yaml = loadYaml(yamlContent) as YamlMap;

    final triggerYaml = yaml['trigger'] as YamlMap?;
    final triggerInputsYaml = triggerYaml?['inputs'] as YamlList?;
    final trigger = WorkflowTrigger(
      type: triggerYaml?['type'] as String? ?? 'manual',
      event: triggerYaml?['event'] as String?,
      inputs:
          triggerInputsYaml?.map((i) {
            final inputMap = i as YamlMap;
            return SkillInput(
              name: inputMap['name'] as String? ?? '',
              type: inputMap['type'] as String? ?? 'string',
              description: inputMap['description'] as String? ?? '',
              required: inputMap['required'] as bool? ?? false,
              defaultValue: inputMap['default'],
            );
          }).toList() ??
          [],
    );

    final stagesYaml = yaml['stages'] as YamlList?;
    final stages =
        stagesYaml?.map((s) {
          final stageMap = s as YamlMap;
          final branchesYaml = stageMap['branches'] as YamlMap?;
          return WorkflowStage(
            name: stageMap['name'] as String? ?? '',
            description: stageMap['description'] as String? ?? '',
            agentId: stageMap['agent'] as String?,
            skillId: stageMap['skill'] as String?,
            type: stageMap['type'] as String?,
            inputs: _yamlMapToMap(stageMap['inputs'] as YamlMap?),
            outputs:
                (stageMap['outputs'] as YamlList?)
                    ?.map((o) => o.toString())
                    .toList() ??
                [],
            timeout: stageMap['timeout'] as int?,
            parallel: stageMap['parallel'] as bool? ?? false,
            condition: stageMap['condition'] as String?,
            branches: branchesYaml?.map(
              (key, value) => MapEntry(key.toString(), value.toString()),
            ),
          );
        }).toList() ??
        [];

    final errorYaml = yaml['error_handling'] as YamlMap?;
    WorkflowErrorHandling? errorHandling;
    if (errorYaml != null) {
      final retryYaml = errorYaml['retry_policy'] as YamlMap?;
      final fallbackYaml = errorYaml['fallback'] as YamlList?;
      errorHandling = WorkflowErrorHandling(
        retryPolicy: retryYaml != null
            ? RetryPolicy(
                maxAttempts: retryYaml['max_attempts'] as int? ?? 3,
                backoff: retryYaml['backoff'] as String? ?? 'exponential',
                initialDelay: retryYaml['initial_delay'] as int? ?? 30,
              )
            : null,
        fallbackRules:
            fallbackYaml?.map((f) {
              final ruleMap = f as YamlMap;
              return FallbackRule(
                condition: ruleMap['condition'] as String? ?? '',
                action: ruleMap['action'] as String? ?? '',
              );
            }).toList() ??
            [],
      );
    }

    final metadataYaml = yaml['metadata'] as YamlMap?;
    final tagsYaml = metadataYaml?['tags'] as YamlList?;

    return Workflow(
      id: id,
      name: yaml['name'] as String? ?? id,
      description: yaml['description'] as String? ?? '',
      version: yaml['version'] as String? ?? '1.0.0',
      createdAt: _parseDate(metadataYaml?['created']),
      updatedAt: _parseDate(metadataYaml?['updated']),
      tags: tagsYaml?.map((t) => t.toString()).toList() ?? [],
      metadata: _yamlMapToMap(metadataYaml),
      status: yaml['status'] as String? ?? 'active',
      trigger: trigger,
      stages: stages,
      errorHandling: errorHandling,
      avgDurationMinutes: (metadataYaml?['avg_duration_minutes'] as num?)
          ?.toDouble(),
      successRate: (metadataYaml?['success_rate'] as num?)?.toDouble(),
    );
  }

  /// Parse a changelog markdown file
  ChangelogEntry parseChangelog(String content, String id, String filename) {
    final lines = content.split('\n');
    String summary = '';
    String author = 'unknown';
    final changes = <ChangeSection>[];
    final affectedAssets = <AffectedAsset>[];
    final evidence = <Evidence>[];
    final tags = <String>[];

    String? currentSection;
    List<String> currentItems = [];
    DateTime? date;

    // Extract date from filename (e.g., 2025-06-01-coder-update.md)
    final dateMatch = RegExp(r'(\d{4}-\d{2}-\d{2})').firstMatch(filename);
    if (dateMatch != null) {
      date = DateTime.tryParse(dateMatch.group(1)!);
    }

    for (final line in lines) {
      if (line.startsWith('## Summary')) {
        currentSection = 'summary';
      } else if (line.startsWith('### Added')) {
        _saveCurrentSection(changes, currentSection, currentItems);
        currentSection = 'added';
        currentItems = [];
      } else if (line.startsWith('### Changed')) {
        _saveCurrentSection(changes, currentSection, currentItems);
        currentSection = 'changed';
        currentItems = [];
      } else if (line.startsWith('### Fixed')) {
        _saveCurrentSection(changes, currentSection, currentItems);
        currentSection = 'fixed';
        currentItems = [];
      } else if (line.startsWith('### Deprecated')) {
        _saveCurrentSection(changes, currentSection, currentItems);
        currentSection = 'deprecated';
        currentItems = [];
      } else if (line.startsWith('### Security')) {
        _saveCurrentSection(changes, currentSection, currentItems);
        currentSection = 'security';
        currentItems = [];
      } else if (line.startsWith('## Affected Assets')) {
        _saveCurrentSection(changes, currentSection, currentItems);
        currentSection = 'affected';
        currentItems = [];
      } else if (line.startsWith('## Evidence')) {
        currentSection = 'evidence';
      } else if (line.startsWith('## Author')) {
        currentSection = 'author';
      } else if (line.startsWith('## Tags')) {
        currentSection = 'tags';
      } else if (line.startsWith('- ') && currentSection != null) {
        final item = line.substring(2).trim();
        if (currentSection == 'summary') {
          summary = item;
        } else if (currentSection == 'affected') {
          final affectedMatch = RegExp(
            r'(\w+):\s+(\S+)\s+\(v?([\d.]+)\s*->\s*v?([\d.]+)\)',
          ).firstMatch(item);
          if (affectedMatch != null) {
            affectedAssets.add(
              AffectedAsset(
                type: _parseAssetType(affectedMatch.group(1)!),
                name: affectedMatch.group(2)!,
                oldVersion: affectedMatch.group(3),
                newVersion: affectedMatch.group(4)!,
              ),
            );
          }
        } else if (currentSection == 'evidence') {
          evidence.add(
            Evidence(
              type: item.contains('PR')
                  ? 'pr'
                  : item.contains('Issue')
                  ? 'issue'
                  : item.contains('Benchmark')
                  ? 'benchmark'
                  : 'report',
              reference: item,
            ),
          );
        } else if (currentSection == 'tags') {
          tags.add(item);
        } else if ([
          'added',
          'changed',
          'fixed',
          'deprecated',
          'security',
        ].contains(currentSection)) {
          currentItems.add(item);
        }
      } else if (currentSection == 'summary' &&
          line.isNotEmpty &&
          !line.startsWith('#')) {
        summary = line.trim();
      } else if (currentSection == 'author' &&
          line.isNotEmpty &&
          !line.startsWith('#')) {
        author = line.trim();
      }
    }

    _saveCurrentSection(changes, currentSection, currentItems);

    return ChangelogEntry(
      id: id,
      name: filename.replaceAll('.md', ''),
      description: summary,
      version: '1.0.0',
      createdAt: date ?? DateTime.now(),
      updatedAt: date ?? DateTime.now(),
      tags: tags,
      summary: summary,
      changes: changes,
      affectedAssets: affectedAssets,
      evidence: evidence,
      author: author,
    );
  }

  void _saveCurrentSection(
    List<ChangeSection> changes,
    String? section,
    List<String> items,
  ) {
    if (section != null &&
        items.isNotEmpty &&
        [
          'added',
          'changed',
          'fixed',
          'deprecated',
          'security',
        ].contains(section)) {
      changes.add(ChangeSection(type: section, items: List.from(items)));
    }
  }

  AgentStatus _parseAgentStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return AgentStatus.active;
      case 'idle':
        return AgentStatus.idle;
      case 'error':
        return AgentStatus.error;
      case 'disabled':
        return AgentStatus.disabled;
      default:
        return AgentStatus.idle;
    }
  }

  AssetType _parseAssetType(String type) {
    switch (type.toLowerCase()) {
      case 'agent':
        return AssetType.agent;
      case 'skill':
        return AssetType.skill;
      case 'workflow':
        return AssetType.workflow;
      case 'task':
        return AssetType.task;
      default:
        return AssetType.doc;
    }
  }

  DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }

  Map<String, dynamic> _yamlMapToMap(YamlMap? yaml) {
    if (yaml == null) return {};
    return yaml.map((key, value) {
      if (value is YamlMap) {
        return MapEntry(key.toString(), _yamlMapToMap(value));
      } else if (value is YamlList) {
        return MapEntry(
          key.toString(),
          value.map((e) => e is YamlMap ? _yamlMapToMap(e) : e).toList(),
        );
      }
      return MapEntry(key.toString(), value);
    });
  }
}
