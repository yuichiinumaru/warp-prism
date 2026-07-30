/// Adapters that project surface-local selection models into the universal
/// [AssetDetailDescriptor] contract so Map / Operate / History can render
/// [AssetDetailView] instead of screen-local inspectors.
library;

import 'package:warp_prism_observatory/data/models/changelog_contracts.dart';
import 'package:warp_prism_observatory/data/models/task_contracts.dart';
import 'package:warp_prism_observatory/data/models/task_projection.dart';
import 'package:warp_prism_observatory/data/models/workspace_graph.dart';
import 'package:warp_prism_observatory/data/repositories/history_repository.dart';
import '../domain/asset_detail_descriptor.dart';
import 'asset_detail_controller.dart';
import 'asset_detail_mapper.dart';

/// Builds a descriptor from a map/catalog [WorkspaceAsset] already in hand.
AssetDetailDescriptor descriptorFromWorkspaceAsset(
  WorkspaceAsset asset, {
  List<WorkspaceEdge> allEdges = const [],
  Map<String, String>? assetNames,
}) {
  return buildDescriptorFromSnapshot(
    asset: asset,
    allEdges: allEdges,
    assetNames: assetNames ?? {asset.id: asset.name},
  );
}

/// Projects an Operate [TaskProjection] into the universal task descriptor.
AssetDetailDescriptor descriptorFromTaskProjection(TaskProjection task) {
  final meta = TaskMetadata(
    id: task.id,
    title: task.title,
    lane: task.lane,
    priority: task.priority,
    owner: task.owner,
    created: task.created,
    updated: task.updated,
    skills: task.linkedSkills,
    workflows: task.linkedWorkflows,
    dependsOn: task.dependsOn,
    proofState: task.proofState,
    reviewScore: task.reviewScore,
    verificationCommands: task.verificationCommands.isEmpty
        ? null
        : task.verificationCommands.join('\n'),
    completionEvidence: task.completionEvidenceSummary,
  );

  final assetId = task.id.startsWith('task:') ? task.id : 'task:${task.id}';
  final asset = WorkspaceAsset(
    id: assetId,
    kind: AssetKind.task,
    name: task.title,
    path: task.filePath,
    description: task.bodyMarkdown,
    frontmatter: {
      '_taskMetadata': meta,
      'priority': task.priority,
      'lane': task.lane.name,
      'owner': task.owner,
      'status': task.statusLabel.isNotEmpty
          ? task.statusLabel
          : task.lane.name,
      'proof_state': task.proofState.name,
      'skills': task.linkedSkills,
      'workflows': task.linkedWorkflows,
      'depends_on': task.dependsOn,
      if (task.reviewScore != null) 'review_score': task.reviewScore,
    },
  );

  return buildAssetDetailDescriptor(
    asset: asset,
    incoming: const [],
    outgoing: const [],
    assetNames: {asset.id: asset.name},
  );
}

/// Projects a History [HistoryEntry] into the universal changelog descriptor.
AssetDetailDescriptor descriptorFromHistoryEntry(HistoryEntry entry) {
  final meta = ChangelogMetadata(
    id: entry.id,
    date: entry.date ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    project: entry.project,
    task: entry.task,
    type: entry.type,
    impact: entry.impactTags,
    skills: entry.skills,
    workflows: entry.workflows,
  );

  final asset = WorkspaceAsset(
    id: entry.id,
    kind: AssetKind.changelog,
    name: entry.title.isNotEmpty ? entry.title : entry.id,
    path: entry.path,
    description: '${entry.project} • ${entry.type.name}',
    frontmatter: {
      '_changelogMetadata': meta,
      'project': entry.project,
      'task': entry.task,
      'type': entry.type.name,
      if (entry.date != null) 'date': entry.date!.toIso8601String(),
      'impact': entry.impactTags,
      'skills': entry.skills,
      'workflows': entry.workflows,
    },
  );

  return buildAssetDetailDescriptor(
    asset: asset,
    incoming: const [],
    outgoing: const [],
    assetNames: {asset.id: asset.name},
  );
}
