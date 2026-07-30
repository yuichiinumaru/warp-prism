/// Builds [OperateProjection] from workspace task assets.
///
/// Bridges Task 0610's parsed [WorkspaceAsset] + [TaskMetadata] contract into
/// the Operate board's [TaskProjection] read model without re-parsing markdown
/// in the presentation layer.
library;

import 'package:warp_prism_observatory/data/models/task_contracts.dart';
import 'package:warp_prism_observatory/data/models/task_projection.dart';
import 'package:warp_prism_observatory/data/models/workspace_graph.dart';
import 'package:warp_prism_observatory/data/parsers/workspace_task_projection_parser.dart';

/// Build a complete [OperateProjection] from snapshot task assets.
///
/// Always returns all five canonical lanes (empty when no tasks match).
OperateProjection buildOperateProjection(Iterable<WorkspaceAsset> taskAssets) {
  final laneMap = <TaskLane, List<TaskProjection>>{
    for (final lane in TaskLane.values) lane: <TaskProjection>[],
  };

  for (final asset in taskAssets) {
    if (asset.kind != AssetKind.task) continue;
    final projection = taskProjectionFromAsset(asset);
    laneMap[projection.lane]!.add(projection);
  }

  for (final entry in laneMap.entries) {
    entry.value.sort((a, b) {
      final byPriority = _priorityWeight(
        a.priority,
      ).compareTo(_priorityWeight(b.priority));
      if (byPriority != 0) return byPriority;
      return a.created.compareTo(b.created);
    });
  }

  final lanes = TaskLane.values
      .map((lane) => TaskLaneProjection(lane: lane, tasks: laneMap[lane]!))
      .toList();
  final total = lanes.fold<int>(0, (sum, lane) => sum + lane.tasks.length);
  return OperateProjection(lanes: lanes, totalTasks: total);
}

/// Map a single task [WorkspaceAsset] into a [TaskProjection].
///
/// Uses the same path-wins lane rule as [WorkspaceTaskProjectionParser] and
/// extracts full body fields (sections, evidence rows, exit conditions) when
/// `_taskBody` was stored by the markdown parser.
TaskProjection taskProjectionFromAsset(WorkspaceAsset asset) {
  final meta = asset.frontmatter['_taskMetadata'] as TaskMetadata?;
  final fm = asset.frontmatter;
  final body = (fm['_taskBody'] as String?) ?? '';
  final bodyFields = body.isNotEmpty
      ? WorkspaceTaskProjectionParser.extractBodyFields(body)
      : const TaskBodyFields();

  final id = meta?.id ?? fm['id']?.toString() ?? _idFromPath(asset.path);
  final title = meta?.title ?? fm['title']?.toString() ?? asset.name;
  // Always re-derive path-wins; do not trust status-first meta.lane.
  final lane = WorkspaceTaskProjectionParser.inferLaneFromPath(
    asset.path,
    fm['status']?.toString(),
  );
  final priority = meta?.priority ?? fm['priority']?.toString() ?? 'P2';
  final owner = meta?.owner ?? fm['owner']?.toString() ?? 'unassigned';
  final proofState =
      meta?.proofState ??
      ProofStateParsing.fromString(fm['proof_state']?.toString());
  final reviewScore = meta?.reviewScore ?? _parseDouble(fm['review_score']);
  final skills = meta?.skills ?? _stringList(fm['skills']);
  final workflows = meta?.workflows ?? _stringList(fm['workflows']);
  final dependsOn = meta?.dependsOn ?? _stringList(fm['depends_on']);
  final blockers = _stringList(fm['blockers']);
  final created = meta?.created ?? _parseDate(fm['created']);
  final updated = meta?.updated ?? _parseDate(fm['updated']);

  final verificationCommands = bodyFields.verificationCommands.isNotEmpty
      ? bodyFields.verificationCommands
      : _commandsFromMeta(meta?.verificationCommands);
  final evidenceSummary =
      bodyFields.completionEvidenceSummary ?? meta?.completionEvidence;

  return TaskProjection(
    id: id,
    slug: _slugFromPath(asset.path),
    title: title,
    lane: lane,
    statusLabel: fm['status']?.toString() ?? lane.name,
    type: fm['type']?.toString() ?? 'task',
    priority: priority,
    owner: owner,
    proofState: proofState,
    reviewScore: reviewScore,
    linkedSkills: skills,
    linkedWorkflows: workflows,
    dependsOn: dependsOn,
    blockers: blockers,
    created: created,
    updated: updated,
    verificationCommands: verificationCommands,
    completionEvidenceSummary: evidenceSummary,
    completionEvidenceRows: bodyFields.completionEvidenceRows,
    sections: bodyFields.sections,
    exitConditions: bodyFields.exitConditions,
    bodyMarkdown: body.isNotEmpty ? body : asset.description,
    filePath: asset.path,
  );
}

List<String> _commandsFromMeta(String? raw) {
  if (raw == null || raw.trim().isEmpty) return const [];
  return raw
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty && !line.startsWith('#'))
      .toList();
}

String _idFromPath(String path) {
  final filename = path.split('/').last.replaceAll('.md', '');
  final match = RegExp(r'(T\d+)').firstMatch(filename);
  return match?.group(1) ?? filename;
}

String _slugFromPath(String path) {
  return path.split('/').last.replaceAll('.md', '');
}

List<String> _stringList(dynamic value) {
  if (value == null) return const [];
  if (value is List) return value.map((e) => e.toString()).toList();
  return const [];
}

double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  final str = value.toString();
  if (str.toLowerCase() == 'n/a') return null;
  return double.tryParse(str);
}

DateTime _parseDate(dynamic value) {
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value) ?? DateTime(1970);
  return DateTime(1970);
}

int _priorityWeight(String priority) {
  switch (priority.toUpperCase()) {
    case 'P0':
    case 'CRITICAL':
      return 0;
    case 'P1':
    case 'HIGH':
      return 1;
    case 'P2':
    case 'MEDIUM':
      return 2;
    case 'P3':
    case 'LOW':
      return 3;
    default:
      return 99;
  }
}
