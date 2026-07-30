/// Maps normalized [WorkspaceAsset] + edges into [AssetDetailDescriptor].
///
/// This is the application layer that transforms backbone data into
/// inspector-ready descriptors for every asset kind. Kind-specific
/// section assembly lives here; kind-specific layout lives in the
/// presentation layer.
library;

import 'package:warp_prism_observatory/data/models/workspace_graph.dart';
import 'package:warp_prism_observatory/data/models/task_contracts.dart';
import 'package:warp_prism_observatory/data/models/changelog_contracts.dart';
import '../domain/asset_detail_descriptor.dart';

/// Builds an [AssetDetailDescriptor] from a [WorkspaceAsset] and its
/// full edge context (incoming + outgoing + related asset names).
AssetDetailDescriptor buildAssetDetailDescriptor({
  required WorkspaceAsset asset,
  required List<WorkspaceEdge> incoming,
  required List<WorkspaceEdge> outgoing,
  required Map<String, String> assetNames,
}) {
  final incomingLinks = _buildLinks(incoming, 'source', assetNames);
  final outgoingLinks = _buildLinks(outgoing, 'target', assetNames);

  switch (asset.kind) {
    case AssetKind.skill:
      return _buildSkillDescriptor(
        asset,
        incomingLinks,
        outgoingLinks,
        assetNames,
      );
    case AssetKind.task:
      return _buildTaskDescriptor(
        asset,
        incomingLinks,
        outgoingLinks,
        assetNames,
      );
    case AssetKind.agent:
      return _buildAgentDescriptor(
        asset,
        incomingLinks,
        outgoingLinks,
        assetNames,
      );
    case AssetKind.workflow:
      return _buildWorkflowDescriptor(
        asset,
        incomingLinks,
        outgoingLinks,
        assetNames,
      );
    case AssetKind.changelog:
      return _buildChangelogDescriptor(
        asset,
        incomingLinks,
        outgoingLinks,
        assetNames,
      );
    default:
      return _buildFallbackDescriptor(asset, incomingLinks, outgoingLinks);
  }
}

/// Builds incoming/outgoing [DetailLink]s from edges.
List<DetailLink> _buildLinks(
  List<WorkspaceEdge> edges,
  String direction,
  Map<String, String> names,
) {
  return edges.map((e) {
    final id = direction == 'source' ? e.sourceId : e.targetId;
    return DetailLink(targetId: id, label: names[id] ?? id, kind: e.kind.name);
  }).toList();
}

// ---------------------------------------------------------------------------
// Skill detail descriptor
// ---------------------------------------------------------------------------

AssetDetailDescriptor _buildSkillDescriptor(
  WorkspaceAsset asset,
  List<DetailLink> incoming,
  List<DetailLink> outgoing,
  Map<String, String> names,
) {
  final fm = asset.frontmatter;

  // 1. Identity
  final identity = DetailSection(
    title: 'Identity',
    key: 'identity',
    properties: [
      DetailProperty(label: 'Name', value: asset.name),
      DetailProperty(label: 'ID', value: asset.id),
      DetailProperty(label: 'Path', value: asset.path),
      DetailProperty(label: 'Provenance', value: asset.canonicality.name),
      if (asset.description.isNotEmpty)
        DetailProperty(label: 'Description', value: asset.description),
    ],
  );

  // 2. Role in the harness
  final roleHints = <DetailProperty>[];
  if (fm.containsKey('type')) {
    roleHints.add(DetailProperty(label: 'Type', value: fm['type'].toString()));
  }
  if (fm.containsKey('family')) {
    roleHints.add(
      DetailProperty(label: 'Family', value: fm['family'].toString()),
    );
  }
  if (fm.containsKey('gateway')) {
    roleHints.add(
      DetailProperty(label: 'Gateway', value: fm['gateway'].toString()),
    );
  }
  if (fm.containsKey('domain')) {
    roleHints.add(
      DetailProperty(label: 'Domain', value: fm['domain'].toString()),
    );
  }
  final role = DetailSection(
    title: 'Role in the Harness',
    key: 'role',
    kindSpecific: true,
    properties: roleHints.isEmpty
        ? [const DetailProperty(label: 'Role', value: 'Execution skill')]
        : roleHints,
  );

  // 3. Sub-structure (sub-skills, local workflows, references, scripts)
  final subProps = <DetailProperty>[];
  final subSkills =
      _listFromFrontmatter(fm, 'sub_skills') ??
      _listFromFrontmatter(fm, 'sub-skills');
  if (subSkills != null && subSkills.isNotEmpty) {
    subProps.add(
      DetailProperty(label: 'Sub-skills', value: subSkills.join(', ')),
    );
  }
  final localWorkflows =
      _listFromFrontmatter(fm, 'workflows') ??
      _listFromFrontmatter(fm, 'local_workflows');
  if (localWorkflows != null && localWorkflows.isNotEmpty) {
    subProps.add(
      DetailProperty(
        label: 'Local Workflows',
        value: localWorkflows.join(', '),
      ),
    );
  }
  final refs = _listFromFrontmatter(fm, 'references');
  if (refs != null && refs.isNotEmpty) {
    subProps.add(DetailProperty(label: 'References', value: refs.join(', ')));
  }
  final scripts = _listFromFrontmatter(fm, 'scripts');
  if (scripts != null && scripts.isNotEmpty) {
    subProps.add(DetailProperty(label: 'Scripts', value: scripts.join(', ')));
  }
  final substructure = DetailSection(
    title: 'Sub-structure',
    key: 'substructure',
    kindSpecific: true,
    count: (subSkills?.length ?? 0) + (localWorkflows?.length ?? 0),
    properties: subProps.isEmpty
        ? [
            const DetailProperty(
              label: 'Structure',
              value: 'Flat skill (no sub-structure declared)',
            ),
          ]
        : subProps,
  );

  // 4. Incoming links (agents/workflows that cite this skill)
  final incomingSection = DetailSection(
    title: 'Incoming Links',
    key: 'incoming',
    count: incoming.length,
    links: incoming,
  );

  // 5. Operational usage
  final usageProps = <DetailProperty>[];
  if (asset.triggers.isNotEmpty) {
    usageProps.add(
      DetailProperty(label: 'Triggers', value: asset.triggers.join(', ')),
    );
  }
  if (fm.containsKey('entry_workflow')) {
    usageProps.add(
      DetailProperty(
        label: 'Entry Workflow',
        value: fm['entry_workflow'].toString(),
      ),
    );
  }
  if (fm.containsKey('boundary')) {
    usageProps.add(
      DetailProperty(label: 'Boundary Cases', value: fm['boundary'].toString()),
    );
  }
  final usage = DetailSection(
    title: 'Operational Usage',
    key: 'usage',
    kindSpecific: true,
    properties: usageProps.isEmpty
        ? [
            const DetailProperty(
              label: 'Usage',
              value: 'No operational usage metadata',
            ),
          ]
        : usageProps,
  );

  // 6. Governance
  final govProps = <DetailProperty>[
    DetailProperty(label: 'Provenance', value: asset.canonicality.name),
  ];
  if (fm.containsKey('scorecard')) {
    govProps.add(
      DetailProperty(label: 'Scorecard', value: fm['scorecard'].toString()),
    );
  }
  if (fm.containsKey('drift')) {
    govProps.add(
      DetailProperty(label: 'Drift Flags', value: fm['drift'].toString()),
    );
  }
  if (fm.containsKey('archive_lineage')) {
    govProps.add(
      DetailProperty(
        label: 'Archive Lineage',
        value: fm['archive_lineage'].toString(),
      ),
    );
  }
  final governance = DetailSection(
    title: 'Governance',
    key: 'governance',
    kindSpecific: true,
    properties: govProps,
  );

  return AssetDetailDescriptor(
    asset: asset,
    sharedSections: [identity],
    kindSections: [role, substructure, incomingSection, usage, governance],
    incomingLinks: incoming,
    outgoingLinks: outgoing,
  );
}

// ---------------------------------------------------------------------------
// Task detail descriptor
// ---------------------------------------------------------------------------

AssetDetailDescriptor _buildTaskDescriptor(
  WorkspaceAsset asset,
  List<DetailLink> incoming,
  List<DetailLink> outgoing,
  Map<String, String> names,
) {
  final fm = asset.frontmatter;
  final taskMeta = fm['_taskMetadata'] as TaskMetadata?;

  // 1. Identity header (lane-neutral)
  final identity = DetailSection(
    title: 'Identity',
    key: 'identity',
    properties: [
      DetailProperty(label: 'Task', value: asset.name),
      DetailProperty(label: 'ID', value: asset.id),
      DetailProperty(label: 'Path', value: asset.path),
      if (taskMeta != null) ...[
        DetailProperty(label: 'Priority', value: taskMeta.priority),
        DetailProperty(label: 'Owner', value: taskMeta.owner),
      ],
      if (taskMeta == null && fm.containsKey('priority'))
        DetailProperty(label: 'priority', value: fm['priority'].toString()),
      if (taskMeta == null && fm.containsKey('lane'))
        DetailProperty(label: 'lane', value: fm['lane'].toString()),
      if (fm.containsKey('status'))
        DetailProperty(label: 'Status', value: fm['status'].toString()),
    ],
  );

  // 2. Contract section
  final contractProps = <DetailProperty>[];
  if (taskMeta != null) {
    contractProps.addAll([
      DetailProperty(label: 'Lane', value: taskMeta.lane.directoryPrefix),
      DetailProperty(label: 'Proof State', value: taskMeta.proofState.name),
      if (taskMeta.reviewScore != null)
        DetailProperty(
          label: 'Review Score',
          value: taskMeta.reviewScore!.toStringAsFixed(1),
        ),
      DetailProperty(
        label: 'Created',
        value: taskMeta.created.toIso8601String(),
      ),
      DetailProperty(
        label: 'Updated',
        value: taskMeta.updated.toIso8601String(),
      ),
    ]);
  }
  final contract = DetailSection(
    title: 'Contract',
    key: 'contract',
    kindSpecific: true,
    properties: contractProps.isEmpty
        ? [
            const DetailProperty(
              label: 'Contract',
              value: 'No structured contract metadata',
            ),
          ]
        : contractProps,
  );

  // 3. Dependencies
  final deps =
      taskMeta?.dependsOn ?? (_listFromFrontmatter(fm, 'depends_on') ?? []);
  final depLinks = deps
      .map((d) => DetailLink(targetId: d, label: d, kind: 'dependsOn'))
      .toList();
  final dependencies = DetailSection(
    title: 'Dependencies',
    key: 'dependencies',
    kindSpecific: true,
    count: deps.length,
    links: depLinks,
    properties: deps.isEmpty
        ? [
            const DetailProperty(
              label: 'Dependencies',
              value: 'No dependencies declared',
            ),
          ]
        : [],
  );

  // 4. Validation commands
  final commands = _extractVerificationCommands(asset);
  final validation = DetailSection(
    title: 'Validation Commands',
    key: 'validation',
    kindSpecific: true,
    count: commands.length,
    codeBlocks: commands,
    properties: commands.isEmpty
        ? [
            const DetailProperty(
              label: 'Commands',
              value: 'No verification commands',
            ),
          ]
        : [],
  );

  // 5. Evidence
  final evidenceProps = <DetailProperty>[];
  if (taskMeta?.completionEvidence != null &&
      taskMeta!.completionEvidence!.isNotEmpty) {
    evidenceProps.add(
      DetailProperty(label: 'Evidence', value: taskMeta.completionEvidence!),
    );
  }
  if (fm.containsKey('exit_conditions')) {
    final ec = fm['exit_conditions'];
    if (ec is List) {
      evidenceProps.add(
        DetailProperty(label: 'Exit Conditions', value: ec.join('\n')),
      );
    }
  }
  final evidence = DetailSection(
    title: 'Evidence',
    key: 'evidence',
    kindSpecific: true,
    properties: evidenceProps.isEmpty
        ? [const DetailProperty(label: 'Evidence', value: 'Not yet provided')]
        : evidenceProps,
  );

  // 6. Lifecycle
  final lifecycleProps = <DetailProperty>[];
  if (taskMeta != null) {
    lifecycleProps.add(
      DetailProperty(label: 'Created', value: _formatDate(taskMeta.created)),
    );
    lifecycleProps.add(
      DetailProperty(label: 'Updated', value: _formatDate(taskMeta.updated)),
    );
  }
  if (fm.containsKey('started_at')) {
    lifecycleProps.add(
      DetailProperty(label: 'Started', value: fm['started_at'].toString()),
    );
  }
  if (fm.containsKey('completed_at')) {
    lifecycleProps.add(
      DetailProperty(label: 'Completed', value: fm['completed_at'].toString()),
    );
  }
  final lifecycle = DetailSection(
    title: 'Lifecycle',
    key: 'lifecycle',
    kindSpecific: true,
    properties: lifecycleProps,
  );

  // Related skills/workflows
  final relatedSkills =
      taskMeta?.skills ?? (_listFromFrontmatter(fm, 'skills') ?? []);
  final relatedWorkflows =
      taskMeta?.workflows ?? (_listFromFrontmatter(fm, 'workflows') ?? []);
  final relatedLinks = <DetailLink>[
    ...relatedSkills.map(
      (s) => DetailLink(targetId: s, label: s, kind: 'skill'),
    ),
    ...relatedWorkflows.map(
      (w) => DetailLink(targetId: w, label: w, kind: 'workflow'),
    ),
  ];
  final related = DetailSection(
    title: 'Related Skills & Workflows',
    key: 'related',
    kindSpecific: true,
    count: relatedLinks.length,
    links: relatedLinks,
    properties: relatedLinks.isEmpty
        ? [
            const DetailProperty(
              label: 'Related',
              value: 'No linked skills or workflows',
            ),
          ]
        : [],
  );

  return AssetDetailDescriptor(
    asset: asset,
    sharedSections: [identity],
    kindSections: [
      contract,
      dependencies,
      validation,
      evidence,
      related,
      lifecycle,
      if (_buildMetadataSection(fm, {
            'status',
            'priority',
            'lane',
            'proof_state',
            'created',
            'updated',
            'owner',
            'skills',
            'workflows',
            'depends_on',
            'verification_commands',
            'completion_evidence',
            'exit_conditions',
            'started_at',
            'completed_at',
          }) !=
          null)
        _buildMetadataSection(fm, {
          'status',
          'priority',
          'lane',
          'proof_state',
          'created',
          'updated',
          'owner',
          'skills',
          'workflows',
          'depends_on',
          'verification_commands',
          'completion_evidence',
          'exit_conditions',
          'started_at',
          'completed_at',
        })!,
    ],
    incomingLinks: incoming,
    outgoingLinks: outgoing,
    taskMetadata: taskMeta,
  );
}

// ---------------------------------------------------------------------------
// Agent detail descriptor
// ---------------------------------------------------------------------------

AssetDetailDescriptor _buildAgentDescriptor(
  WorkspaceAsset asset,
  List<DetailLink> incoming,
  List<DetailLink> outgoing,
  Map<String, String> names,
) {
  final fm = asset.frontmatter;

  // 1. Identity
  final identity = DetailSection(
    title: 'Identity',
    key: 'identity',
    properties: [
      DetailProperty(label: 'Name', value: asset.name),
      DetailProperty(label: 'ID', value: asset.id),
      DetailProperty(label: 'Path', value: asset.path),
      DetailProperty(label: 'Provenance', value: asset.canonicality.name),
      if (asset.description.isNotEmpty)
        DetailProperty(label: 'Description', value: asset.description),
    ],
  );

  // 2. Operational metadata (model, status, capabilities)
  final opsProps = <DetailProperty>[];
  if (fm.containsKey('model')) {
    opsProps.add(DetailProperty(label: 'Model', value: fm['model'].toString()));
  }
  if (fm.containsKey('provider')) {
    opsProps.add(
      DetailProperty(label: 'Provider', value: fm['provider'].toString()),
    );
  }
  if (fm.containsKey('status')) {
    opsProps.add(
      DetailProperty(label: 'Status', value: fm['status'].toString()),
    );
  }
  if (fm.containsKey('temperature')) {
    opsProps.add(
      DetailProperty(label: 'Temperature', value: fm['temperature'].toString()),
    );
  }
  if (fm.containsKey('max_tokens')) {
    opsProps.add(
      DetailProperty(label: 'Max Tokens', value: fm['max_tokens'].toString()),
    );
  }
  final capabilities = _listFromFrontmatter(fm, 'capabilities');
  if (capabilities != null && capabilities.isNotEmpty) {
    opsProps.add(
      DetailProperty(label: 'Capabilities', value: capabilities.join(', ')),
    );
  }
  final operational = DetailSection(
    title: 'Operational Metadata',
    key: 'operational',
    kindSpecific: true,
    properties: opsProps.isEmpty
        ? [
            const DetailProperty(
              label: 'Agent',
              value: 'No operational metadata',
            ),
          ]
        : opsProps,
  );

  // 3. Tools
  final tools = _listFromFrontmatter(fm, 'tools');
  final toolsSection = DetailSection(
    title: 'Tools',
    key: 'tools',
    kindSpecific: true,
    count: tools?.length ?? 0,
    properties: (tools == null || tools.isEmpty)
        ? [const DetailProperty(label: 'Tools', value: 'No tools declared')]
        : [DetailProperty(label: 'Tools', value: tools.join(', '))],
  );

  // 4. Skill affinity (which skills this agent uses)
  final skillAffinity =
      _listFromFrontmatter(fm, 'skills') ??
      _listFromFrontmatter(fm, 'skill_ids');
  final skillLinks = (skillAffinity ?? [])
      .map((s) => DetailLink(targetId: s, label: s, kind: 'skill'))
      .toList();
  final skillsSection = DetailSection(
    title: 'Skill Affinity',
    key: 'skill_affinity',
    kindSpecific: true,
    count: skillLinks.length,
    links: skillLinks,
    properties: skillLinks.isEmpty
        ? [
            const DetailProperty(
              label: 'Skills',
              value: 'No skill affinity declared',
            ),
          ]
        : [],
  );

  // 5. Workflow affinity
  final workflowAffinity =
      _listFromFrontmatter(fm, 'workflows') ??
      _listFromFrontmatter(fm, 'workflow_ids');
  final workflowLinks = (workflowAffinity ?? [])
      .map((w) => DetailLink(targetId: w, label: w, kind: 'workflow'))
      .toList();
  final workflowsSection = DetailSection(
    title: 'Workflow Affinity',
    key: 'workflow_affinity',
    kindSpecific: true,
    count: workflowLinks.length,
    links: workflowLinks,
    properties: workflowLinks.isEmpty
        ? [
            const DetailProperty(
              label: 'Workflows',
              value: 'No workflow affinity declared',
            ),
          ]
        : [],
  );

  // 6. Usage context
  final usageProps = <DetailProperty>[];
  if (fm.containsKey('role')) {
    usageProps.add(DetailProperty(label: 'Role', value: fm['role'].toString()));
  }
  if (fm.containsKey('context')) {
    usageProps.add(
      DetailProperty(label: 'Context', value: fm['context'].toString()),
    );
  }
  if (asset.triggers.isNotEmpty) {
    usageProps.add(
      DetailProperty(label: 'Triggers', value: asset.triggers.join(', ')),
    );
  }
  final usage = DetailSection(
    title: 'Usage Context',
    key: 'usage',
    kindSpecific: true,
    properties: usageProps.isEmpty
        ? [
            const DetailProperty(
              label: 'Context',
              value: 'No usage context declared',
            ),
          ]
        : usageProps,
  );

  return AssetDetailDescriptor(
    asset: asset,
    sharedSections: [identity],
    kindSections: [
      operational,
      toolsSection,
      skillsSection,
      workflowsSection,
      usage,
      if (_buildMetadataSection(fm, {
            'model',
            'provider',
            'status',
            'temperature',
            'max_tokens',
            'capabilities',
            'skills',
            'skill_ids',
            'workflows',
            'workflow_ids',
            'role',
            'context',
            'tools',
            'scorecard',
            'drift',
            'archive_lineage',
          }) !=
          null)
        _buildMetadataSection(fm, {
          'model',
          'provider',
          'status',
          'temperature',
          'max_tokens',
          'capabilities',
          'skills',
          'skill_ids',
          'workflows',
          'workflow_ids',
          'role',
          'context',
          'tools',
          'scorecard',
          'drift',
          'archive_lineage',
        })!,
    ],
    incomingLinks: incoming,
    outgoingLinks: outgoing,
  );
}

// ---------------------------------------------------------------------------
// Workflow detail descriptor
// ---------------------------------------------------------------------------

AssetDetailDescriptor _buildWorkflowDescriptor(
  WorkspaceAsset asset,
  List<DetailLink> incoming,
  List<DetailLink> outgoing,
  Map<String, String> names,
) {
  final fm = asset.frontmatter;

  // 1. Identity
  final identity = DetailSection(
    title: 'Identity',
    key: 'identity',
    properties: [
      DetailProperty(label: 'Name', value: asset.name),
      DetailProperty(label: 'ID', value: asset.id),
      DetailProperty(label: 'Path', value: asset.path),
      DetailProperty(label: 'Provenance', value: asset.canonicality.name),
      if (asset.description.isNotEmpty)
        DetailProperty(label: 'Description', value: asset.description),
    ],
  );

  // 2. Trigger
  final triggerProps = <DetailProperty>[];
  if (fm.containsKey('trigger_type')) {
    triggerProps.add(
      DetailProperty(
        label: 'Trigger Type',
        value: fm['trigger_type'].toString(),
      ),
    );
  } else if (fm.containsKey('trigger')) {
    final trigger = fm['trigger'];
    if (trigger is Map) {
      trigger.forEach((k, v) {
        triggerProps.add(
          DetailProperty(label: 'Trigger $k', value: v.toString()),
        );
      });
    } else {
      triggerProps.add(
        DetailProperty(label: 'Trigger', value: trigger.toString()),
      );
    }
  }
  if (fm.containsKey('event')) {
    triggerProps.add(
      DetailProperty(label: 'Event', value: fm['event'].toString()),
    );
  }
  final trigger = DetailSection(
    title: 'Trigger',
    key: 'trigger',
    kindSpecific: true,
    properties: triggerProps.isEmpty
        ? [const DetailProperty(label: 'Trigger', value: 'No trigger declared')]
        : triggerProps,
  );

  // 3. Stages
  final stages = _listFromFrontmatter(fm, 'stages');
  final stageProps = <DetailProperty>[];
  if (stages != null && stages.isNotEmpty) {
    for (var i = 0; i < stages.length; i++) {
      stageProps.add(DetailProperty(label: 'Stage ${i + 1}', value: stages[i]));
    }
  }
  // Also handle stages as structured maps
  if (fm.containsKey('stages') && fm['stages'] is List) {
    final stageList = fm['stages'] as List;
    stageProps.clear();
    for (var i = 0; i < stageList.length; i++) {
      final stage = stageList[i];
      if (stage is Map) {
        final name = stage['name']?.toString() ?? 'Stage ${i + 1}';
        final desc = stage['description']?.toString() ?? '';
        stageProps.add(
          DetailProperty(
            label: name,
            value: desc.isNotEmpty ? desc : 'No description',
          ),
        );
      }
    }
  }
  final stagesSection = DetailSection(
    title: 'Stages',
    key: 'stages',
    kindSpecific: true,
    count: stages?.length ?? 0,
    properties: stageProps.isEmpty
        ? [const DetailProperty(label: 'Stages', value: 'No stages defined')]
        : stageProps,
  );

  // 4. Branches & error handling
  final branchProps = <DetailProperty>[];
  if (fm.containsKey('branches')) {
    final branches = fm['branches'];
    if (branches is Map) {
      branches.forEach((k, v) {
        branchProps.add(
          DetailProperty(label: 'Branch: $k', value: v.toString()),
        );
      });
    }
  }
  if (fm.containsKey('error_handling')) {
    final eh = fm['error_handling'];
    if (eh is Map) {
      eh.forEach((k, v) {
        branchProps.add(
          DetailProperty(label: 'Error: $k', value: v.toString()),
        );
      });
    } else {
      branchProps.add(
        DetailProperty(label: 'Error Handling', value: eh.toString()),
      );
    }
  }
  if (fm.containsKey('retry_policy')) {
    branchProps.add(
      DetailProperty(
        label: 'Retry Policy',
        value: fm['retry_policy'].toString(),
      ),
    );
  }
  final branches = DetailSection(
    title: 'Branches & Error Handling',
    key: 'branches',
    kindSpecific: true,
    properties: branchProps.isEmpty
        ? [
            const DetailProperty(
              label: 'Handling',
              value: 'No branch/error handling declared',
            ),
          ]
        : branchProps,
  );

  // 5. Related assets (skills, agents)
  final relatedSkills = _listFromFrontmatter(fm, 'skills') ?? [];
  final relatedAgents = _listFromFrontmatter(fm, 'agents') ?? [];
  final relatedLinks = <DetailLink>[
    ...relatedSkills.map(
      (s) => DetailLink(targetId: s, label: s, kind: 'skill'),
    ),
    ...relatedAgents.map(
      (a) => DetailLink(targetId: a, label: a, kind: 'agent'),
    ),
  ];
  final related = DetailSection(
    title: 'Related Assets',
    key: 'related',
    kindSpecific: true,
    count: relatedLinks.length,
    links: relatedLinks,
    properties: relatedLinks.isEmpty
        ? [
            const DetailProperty(
              label: 'Related',
              value: 'No related assets declared',
            ),
          ]
        : [],
  );

  // 6. Performance metrics
  final perfProps = <DetailProperty>[];
  if (fm.containsKey('avg_duration')) {
    perfProps.add(
      DetailProperty(
        label: 'Avg Duration',
        value: fm['avg_duration'].toString(),
      ),
    );
  }
  if (fm.containsKey('success_rate')) {
    perfProps.add(
      DetailProperty(
        label: 'Success Rate',
        value: fm['success_rate'].toString(),
      ),
    );
  }
  if (fm.containsKey('timeout')) {
    perfProps.add(
      DetailProperty(label: 'Timeout', value: fm['timeout'].toString()),
    );
  }
  final perf = DetailSection(
    title: 'Performance',
    key: 'performance',
    kindSpecific: true,
    properties: perfProps.isEmpty
        ? [
            const DetailProperty(
              label: 'Performance',
              value: 'No performance metrics',
            ),
          ]
        : perfProps,
  );

  return AssetDetailDescriptor(
    asset: asset,
    sharedSections: [identity],
    kindSections: [trigger, stagesSection, branches, related, perf],
    incomingLinks: incoming,
    outgoingLinks: outgoing,
  );
}

// ---------------------------------------------------------------------------
// Changelog detail descriptor
// ---------------------------------------------------------------------------

AssetDetailDescriptor _buildChangelogDescriptor(
  WorkspaceAsset asset,
  List<DetailLink> incoming,
  List<DetailLink> outgoing,
  Map<String, String> names,
) {
  final fm = asset.frontmatter;
  final clMeta = fm['_changelogMetadata'] as ChangelogMetadata?;

  // 1. Identity
  final identity = DetailSection(
    title: 'Identity',
    key: 'identity',
    properties: [
      DetailProperty(label: 'Entry', value: asset.name),
      DetailProperty(label: 'ID', value: asset.id),
      DetailProperty(label: 'Path', value: asset.path),
      DetailProperty(label: 'Provenance', value: asset.canonicality.name),
    ],
  );

  // 2. Ledger source (canonical vs generated)
  final ledgerProps = <DetailProperty>[
    DetailProperty(label: 'Source', value: asset.canonicality.name),
  ];
  if (clMeta != null) {
    ledgerProps.add(
      DetailProperty(label: 'Date', value: _formatDate(clMeta.date)),
    );
    ledgerProps.add(DetailProperty(label: 'Project', value: clMeta.project));
    ledgerProps.add(DetailProperty(label: 'Type', value: clMeta.type.name));
  } else {
    if (fm.containsKey('date')) {
      ledgerProps.add(
        DetailProperty(label: 'Date', value: fm['date'].toString()),
      );
    }
    if (fm.containsKey('type')) {
      ledgerProps.add(
        DetailProperty(label: 'Type', value: fm['type'].toString()),
      );
    }
  }
  final ledger = DetailSection(
    title: 'Ledger Source',
    key: 'ledger',
    kindSpecific: true,
    properties: ledgerProps,
  );

  // 3. Related task
  final taskRef = clMeta?.task ?? fm['task']?.toString();
  final relatedTask = DetailSection(
    title: 'Related Task',
    key: 'related_task',
    kindSpecific: true,
    links: taskRef != null
        ? [DetailLink(targetId: taskRef, label: taskRef, kind: 'task')]
        : [],
    properties: taskRef == null
        ? [const DetailProperty(label: 'Task', value: 'No related task')]
        : [DetailProperty(label: 'Task', value: taskRef)],
  );

  // 4. Affected assets
  final impactAreas =
      clMeta?.impact ?? (_listFromFrontmatter(fm, 'impact') ?? []);
  final affectedSkills =
      clMeta?.skills ?? (_listFromFrontmatter(fm, 'skills') ?? []);
  final affectedLinks = <DetailLink>[
    ...impactAreas.map(
      (i) => DetailLink(targetId: i, label: i, kind: 'impact'),
    ),
    ...affectedSkills.map(
      (s) => DetailLink(targetId: s, label: s, kind: 'skill'),
    ),
  ];
  final affected = DetailSection(
    title: 'Affected Assets',
    key: 'affected',
    kindSpecific: true,
    count: affectedLinks.length,
    links: affectedLinks,
    properties: affectedLinks.isEmpty
        ? [
            const DetailProperty(
              label: 'Impact',
              value: 'No affected assets declared',
            ),
          ]
        : [],
  );

  // 5. Impact story (Why, Changed, Evidence body sections)
  final storyProps = <DetailProperty>[];
  if (clMeta?.why != null && clMeta!.why!.isNotEmpty) {
    storyProps.add(DetailProperty(label: 'Why', value: clMeta.why!));
  }
  if (clMeta?.changed != null && clMeta!.changed!.isNotEmpty) {
    storyProps.add(DetailProperty(label: 'Changed', value: clMeta.changed!));
  }
  if (clMeta?.evidence != null && clMeta!.evidence!.isNotEmpty) {
    storyProps.add(DetailProperty(label: 'Evidence', value: clMeta.evidence!));
  }
  // Fallback to raw frontmatter body
  if (storyProps.isEmpty) {
    if (fm.containsKey('summary')) {
      storyProps.add(
        DetailProperty(label: 'Summary', value: fm['summary'].toString()),
      );
    }
  }
  final story = DetailSection(
    title: 'Impact Story',
    key: 'story',
    kindSpecific: true,
    properties: storyProps.isEmpty
        ? [
            const DetailProperty(
              label: 'Story',
              value: 'No impact story available',
            ),
          ]
        : storyProps,
  );

  return AssetDetailDescriptor(
    asset: asset,
    sharedSections: [identity],
    kindSections: [ledger, relatedTask, affected, story],
    incomingLinks: incoming,
    outgoingLinks: outgoing,
    changelogMetadata: clMeta,
  );
}

// ---------------------------------------------------------------------------
// Fallback descriptor
// ---------------------------------------------------------------------------

AssetDetailDescriptor _buildFallbackDescriptor(
  WorkspaceAsset asset,
  List<DetailLink> incoming,
  List<DetailLink> outgoing,
) {
  final kindLabel = asset.kind.name;
  return AssetDetailDescriptor.fallback(
    asset: asset,
    message:
        '$kindLabel assets have partial detail support. '
        'Showing available identity, metadata, and tags. '
        'Kind-specific panels for $kindLabel are not yet implemented.',
    incomingLinks: incoming,
    outgoingLinks: outgoing,
  );
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Extracts a list from frontmatter (handles both List and comma-separated String).
List<String>? _listFromFrontmatter(Map<String, dynamic> fm, String key) {
  final value = fm[key];
  if (value == null) return null;
  if (value is List) return value.map((e) => e.toString()).toList();
  if (value is String) {
    return value
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }
  return null;
}

/// Builds a metadata section from raw frontmatter keys not already captured
/// by kind-specific sections. Keys starting with '_' are excluded.
DetailSection? _buildMetadataSection(
  Map<String, dynamic> fm,
  Set<String> excludeKeys,
) {
  final remaining = fm.entries
      .where((e) => !e.key.startsWith('_') && !excludeKeys.contains(e.key))
      .toList();
  if (remaining.isEmpty) return null;
  return DetailSection(
    title: 'Metadata',
    key: 'metadata',
    kindSpecific: true,
    count: remaining.length,
    properties: remaining
        .map(
          (e) => DetailProperty(
            label: e.key,
            value: _formatFrontmatterValue(e.value),
          ),
        )
        .toList(),
  );
}

/// Formats a frontmatter value for display.
String _formatFrontmatterValue(dynamic value) {
  if (value == null) return 'null';
  if (value is List) return value.map((e) => e.toString()).join(', ');
  if (value is Map) {
    return value.entries.map((e) => '${e.key}: ${e.value}').join(', ');
  }
  return value.toString();
}

/// Extracts verification commands from the asset's frontmatter or body metadata.
List<String> _extractVerificationCommands(WorkspaceAsset asset) {
  final fm = asset.frontmatter;
  final commands = <String>[];
  if (fm.containsKey('verification_commands')) {
    final vc = fm['verification_commands'];
    if (vc is List) {
      commands.addAll(vc.map((e) => e.toString()));
    } else if (vc is String) {
      commands.add(vc);
    }
  }
  if (fm.containsKey('_taskMetadata')) {
    final meta = fm['_taskMetadata'] as TaskMetadata?;
    if (meta?.verificationCommands != null &&
        meta!.verificationCommands!.isNotEmpty) {
      commands.add(meta.verificationCommands!);
    }
  }
  return commands;
}

String _formatDate(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
