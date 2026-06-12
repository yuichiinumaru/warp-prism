/// Widget tests for agent, workflow, changelog, and generic fallback variants.
///
/// Verifies:
/// - Agent detail renders operational metadata, tools, skill/workflow affinity, usage
/// - Workflow detail renders trigger, stages, branches, error handling, related assets
/// - Changelog detail distinguishes ledger source, related task, affected assets, impact story
/// - Generic fallback renders partial-support banner for subskill/script/reference/rule
/// - All variants handle empty and partial data gracefully
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_observatory/data/models/workspace_graph.dart';
import 'package:warp_prism_observatory/data/models/changelog_contracts.dart';
import 'package:warp_prism_observatory/features/asset_detail/domain/asset_detail_descriptor.dart';
import 'package:warp_prism_observatory/features/asset_detail/presentation/agent_detail_view.dart';
import 'package:warp_prism_observatory/features/asset_detail/presentation/workflow_detail_view.dart';
import 'package:warp_prism_observatory/features/asset_detail/presentation/changelog_detail_view.dart';
import 'package:warp_prism_observatory/features/asset_detail/presentation/generic_asset_detail_view.dart';
import 'package:warp_prism_observatory/features/asset_detail/presentation/asset_detail_view.dart';

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

WorkspaceAsset _testAgentAsset({
  String name = 'architect-orchestrator',
  String id = 'agent:architect-orchestrator',
  Map<String, dynamic> frontmatter = const {},
}) {
  return WorkspaceAsset(
    id: id,
    kind: AssetKind.agent,
    name: name,
    path: '.agents/agents/architect-orchestrator/AGENT.md',
    description: 'Orchestrates architect-tier agents for complex tasks',
    canonicality: Canonicality.parentCanonical,
    frontmatter: frontmatter,
    tags: const ['orchestrator', 'architect'],
  );
}

AssetDetailDescriptor _testAgentDescriptor({WorkspaceAsset? asset}) {
  final a = asset ?? _testAgentAsset();
  return AssetDetailDescriptor(
    asset: a,
    sharedSections: [
      DetailSection(
        title: 'Identity',
        key: 'identity',
        properties: [
          DetailProperty(label: 'Name', value: a.name),
          DetailProperty(label: 'ID', value: a.id),
          DetailProperty(label: 'Path', value: a.path),
        ],
      ),
    ],
    kindSections: [
      const DetailSection(
        title: 'Operational Metadata',
        key: 'operational',
        kindSpecific: true,
        properties: [
          DetailProperty(label: 'Model', value: 'claude-3.5-sonnet'),
          DetailProperty(label: 'Provider', value: 'anthropic'),
          DetailProperty(label: 'Status', value: 'active'),
        ],
      ),
      const DetailSection(
        title: 'Tools',
        key: 'tools',
        kindSpecific: true,
        count: 3,
        properties: [
          DetailProperty(
            label: 'Tools',
            value: 'read_file, search_files, terminal',
          ),
        ],
      ),
      const DetailSection(
        title: 'Skill Affinity',
        key: 'skill_affinity',
        kindSpecific: true,
        count: 2,
        links: [
          DetailLink(
            targetId: 'skill:harness-management',
            label: 'harness-management',
            kind: 'skill',
          ),
          DetailLink(
            targetId: 'skill:agent-wiki',
            label: 'agent-wiki',
            kind: 'skill',
          ),
        ],
      ),
      const DetailSection(
        title: 'Workflow Affinity',
        key: 'workflow_affinity',
        kindSpecific: true,
        count: 1,
        links: [
          DetailLink(
            targetId: 'workflow:build-orchestrator',
            label: 'build-orchestrator',
            kind: 'workflow',
          ),
        ],
      ),
      const DetailSection(
        title: 'Usage Context',
        key: 'usage',
        kindSpecific: true,
        properties: [
          DetailProperty(label: 'Role', value: 'Orchestrator'),
          DetailProperty(
            label: 'Context',
            value: 'Complex multi-step architecture tasks',
          ),
        ],
      ),
    ],
    incomingLinks: const [],
    outgoingLinks: const [
      DetailLink(
        targetId: 'skill:harness-management',
        label: 'harness-management',
        kind: 'skill',
      ),
    ],
  );
}

WorkspaceAsset _testWorkflowAsset({
  String name = 'build-orchestrator',
  String id = 'workflow:build-orchestrator',
  Map<String, dynamic> frontmatter = const {},
}) {
  return WorkspaceAsset(
    id: id,
    kind: AssetKind.workflow,
    name: name,
    path: '.agents/workflows/build-orchestrator/WORKFLOW.md',
    description: 'Orchestrates build and test pipeline',
    canonicality: Canonicality.parentCanonical,
    frontmatter: frontmatter,
    tags: const ['build', 'orchestrator'],
  );
}

AssetDetailDescriptor _testWorkflowDescriptor({WorkspaceAsset? asset}) {
  final a = asset ?? _testWorkflowAsset();
  return AssetDetailDescriptor(
    asset: a,
    sharedSections: [
      DetailSection(
        title: 'Identity',
        key: 'identity',
        properties: [
          DetailProperty(label: 'Name', value: a.name),
          DetailProperty(label: 'ID', value: a.id),
        ],
      ),
    ],
    kindSections: [
      const DetailSection(
        title: 'Trigger',
        key: 'trigger',
        kindSpecific: true,
        properties: [DetailProperty(label: 'Trigger Type', value: 'manual')],
      ),
      const DetailSection(
        title: 'Stages',
        key: 'stages',
        kindSpecific: true,
        count: 3,
        properties: [
          DetailProperty(label: 'Stage 1', value: 'Lint & Format'),
          DetailProperty(label: 'Stage 2', value: 'Analyze'),
          DetailProperty(label: 'Stage 3', value: 'Test'),
        ],
      ),
      const DetailSection(
        title: 'Branches & Error Handling',
        key: 'branches',
        kindSpecific: true,
        properties: [
          DetailProperty(
            label: 'Retry Policy',
            value: 'exponential backoff, max 3',
          ),
        ],
      ),
      const DetailSection(
        title: 'Related Assets',
        key: 'related',
        kindSpecific: true,
        count: 1,
        links: [
          DetailLink(
            targetId: 'agent:builder-agent',
            label: 'builder-agent',
            kind: 'agent',
          ),
        ],
      ),
      const DetailSection(
        title: 'Performance',
        key: 'performance',
        kindSpecific: true,
        properties: [
          DetailProperty(label: 'Avg Duration', value: '5m'),
          DetailProperty(label: 'Success Rate', value: '95%'),
        ],
      ),
    ],
    incomingLinks: const [
      DetailLink(
        targetId: 'agent:builder-orchestrator',
        label: 'builder-orchestrator',
        kind: 'agent',
      ),
    ],
    outgoingLinks: const [],
  );
}

WorkspaceAsset _testChangelogAsset({
  String name = '2026-06-07-0902-universal-descriptor',
  String id = 'changelog:2026-06-07-0902-universal-descriptor',
  Map<String, dynamic> frontmatter = const {},
}) {
  return WorkspaceAsset(
    id: id,
    kind: AssetKind.changelog,
    name: name,
    path: 'docs/changelog/2026-06-07-0902-universal-descriptor.md',
    description: 'Added universal asset detail descriptor',
    canonicality: Canonicality.appendOnly,
    frontmatter: frontmatter,
    tags: const ['feature'],
  );
}

AssetDetailDescriptor _testChangelogDescriptor({WorkspaceAsset? asset}) {
  final a = asset ?? _testChangelogAsset();
  return AssetDetailDescriptor(
    asset: a,
    sharedSections: [
      DetailSection(
        title: 'Identity',
        key: 'identity',
        properties: [
          DetailProperty(label: 'Entry', value: a.name),
          DetailProperty(label: 'ID', value: a.id),
          DetailProperty(label: 'Path', value: a.path),
        ],
      ),
    ],
    kindSections: [
      const DetailSection(
        title: 'Ledger Source',
        key: 'ledger',
        kindSpecific: true,
        properties: [
          DetailProperty(label: 'Source', value: 'appendOnly'),
          DetailProperty(label: 'Date', value: '2026-06-07'),
          DetailProperty(label: 'Project', value: 'warp-prism'),
          DetailProperty(label: 'Type', value: 'feature'),
        ],
      ),
      const DetailSection(
        title: 'Related Task',
        key: 'related_task',
        kindSpecific: true,
        links: [DetailLink(targetId: 'task:0902', label: '0902', kind: 'task')],
        properties: [DetailProperty(label: 'Task', value: '0902')],
      ),
      const DetailSection(
        title: 'Affected Assets',
        key: 'affected',
        kindSpecific: true,
        count: 3,
        links: [
          DetailLink(targetId: 'parser', label: 'parser', kind: 'impact'),
          DetailLink(
            targetId: 'graph-model',
            label: 'graph-model',
            kind: 'impact',
          ),
        ],
        properties: [
          DetailProperty(label: 'Impact', value: 'parser, graph-model'),
        ],
      ),
      const DetailSection(
        title: 'Impact Story',
        key: 'story',
        kindSpecific: true,
        properties: [
          DetailProperty(
            label: 'Why',
            value:
                'The universal descriptor enables kind-specific detail views.',
          ),
          DetailProperty(
            label: 'Changed',
            value: 'Added AssetDetailDescriptor, mapper, and detail views.',
          ),
          DetailProperty(
            label: 'Evidence',
            value: 'Tests pass, dart format clean.',
          ),
        ],
      ),
    ],
    incomingLinks: const [],
    outgoingLinks: const [
      const DetailLink(targetId: 'task:0902', label: '0902', kind: 'task'),
    ],
    changelogMetadata: ChangelogMetadata(
      id: '2026-06-07-0902-universal-descriptor',
      date: DateTime(2026, 6, 7),
      project: 'warp-prism',
      task: '0902',
      type: ChangelogType.feature,
      impact: const ['parser', 'graph-model'],
      skills: const ['agent-wiki'],
      why: 'The universal descriptor enables kind-specific detail views.',
      changed: 'Added AssetDetailDescriptor, mapper, and detail views.',
      evidence: 'Tests pass, dart format clean.',
    ),
  );
}

WorkspaceAsset _testGenericAsset({
  AssetKind kind = AssetKind.subskill,
  String name = 'readme-writer',
  String id = 'subskill:readme-writer',
}) {
  return WorkspaceAsset(
    id: id,
    kind: kind,
    name: name,
    path: '.agents/skills/agent-wiki/sub-skills/readme-writer/SKILL.md',
    description: 'Writes README files for skills',
    canonicality: Canonicality.parentCanonical,
    tags: const ['documentation'],
  );
}

AssetDetailDescriptor _testGenericDescriptor({WorkspaceAsset? asset}) {
  final a = asset ?? _testGenericAsset();
  return AssetDetailDescriptor.fallback(
    asset: a,
    message:
        '${a.kind.name} assets have partial detail support. '
        'Showing available identity, metadata, and tags. '
        'Kind-specific panels for ${a.kind.name} are not yet implemented.',
  );
}

Widget _wrapInApp(Widget child) {
  return MaterialApp(
    home: Scaffold(body: SizedBox(width: 800, height: 900, child: child)),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('AgentDetailView', () {
    testWidgets('renders operational metadata panels', (tester) async {
      final descriptor = _testAgentDescriptor();
      await tester.pumpWidget(
        _wrapInApp(AgentDetailView(descriptor: descriptor)),
      );

      expect(find.text('Operational Metadata'), findsOneWidget);
      expect(find.text('claude-3.5-sonnet'), findsOneWidget);
      expect(find.text('anthropic'), findsOneWidget);
      expect(find.text('active'), findsOneWidget);
    });

    testWidgets('renders tools section', (tester) async {
      final descriptor = _testAgentDescriptor();
      await tester.pumpWidget(
        _wrapInApp(AgentDetailView(descriptor: descriptor)),
      );

      expect(find.text('Tools'), findsWidgets);
      expect(find.textContaining('read_file'), findsOneWidget);
      expect(find.textContaining('terminal'), findsOneWidget);
    });

    testWidgets('renders skill and workflow affinity links', (tester) async {
      final descriptor = _testAgentDescriptor();
      await tester.pumpWidget(
        _wrapInApp(AgentDetailView(descriptor: descriptor)),
      );

      expect(find.text('Skill Affinity'), findsOneWidget);
      expect(find.text('harness-management'), findsOneWidget);
      expect(find.text('agent-wiki'), findsOneWidget);

      expect(find.text('Workflow Affinity'), findsOneWidget);
      expect(find.text('build-orchestrator'), findsOneWidget);
    });

    testWidgets('renders usage context', (tester) async {
      final descriptor = _testAgentDescriptor();
      await tester.pumpWidget(
        _wrapInApp(AgentDetailView(descriptor: descriptor)),
      );

      expect(find.text('Usage Context'), findsOneWidget);
      expect(find.text('Orchestrator'), findsOneWidget);
    });

    testWidgets('handles agent with no operational data', (tester) async {
      final descriptor = _testAgentDescriptor(
        asset: _testAgentAsset(frontmatter: const {}),
      );
      await tester.pumpWidget(
        _wrapInApp(AgentDetailView(descriptor: descriptor)),
      );

      // Should not crash
      expect(find.text('Identity'), findsOneWidget);
    });
  });

  group('WorkflowDetailView', () {
    testWidgets('renders trigger, stages, and error handling', (tester) async {
      final descriptor = _testWorkflowDescriptor();
      await tester.pumpWidget(
        _wrapInApp(WorkflowDetailView(descriptor: descriptor)),
      );

      expect(find.text('Trigger'), findsOneWidget);
      expect(find.text('manual'), findsOneWidget);

      expect(find.text('Stages'), findsOneWidget);
      expect(find.text('Stage 1'), findsOneWidget);
      expect(find.text('Stage 3'), findsOneWidget);

      expect(find.text('Branches & Error Handling'), findsOneWidget);
      expect(find.text('exponential backoff, max 3'), findsOneWidget);
    });

    testWidgets('renders related assets', (tester) async {
      final descriptor = _testWorkflowDescriptor();
      await tester.pumpWidget(
        _wrapInApp(WorkflowDetailView(descriptor: descriptor)),
      );

      expect(find.text('Related Assets'), findsOneWidget);
      expect(find.text('builder-agent'), findsOneWidget);
    });

    testWidgets('renders performance metrics', (tester) async {
      final descriptor = _testWorkflowDescriptor();
      await tester.pumpWidget(
        _wrapInApp(WorkflowDetailView(descriptor: descriptor)),
      );

      expect(find.text('Performance'), findsOneWidget);
      expect(find.text('5m'), findsOneWidget);
      expect(find.text('95%'), findsOneWidget);
    });

    testWidgets('handles workflow with no stages', (tester) async {
      final descriptor = _testWorkflowDescriptor(
        asset: _testWorkflowAsset(frontmatter: const {}),
      );
      await tester.pumpWidget(
        _wrapInApp(WorkflowDetailView(descriptor: descriptor)),
      );

      expect(find.text('Identity'), findsOneWidget);
    });
  });

  group('ChangelogDetailView', () {
    testWidgets('renders ledger source and related task', (tester) async {
      final descriptor = _testChangelogDescriptor();
      await tester.pumpWidget(
        _wrapInApp(ChangelogDetailView(descriptor: descriptor)),
      );

      expect(find.text('Ledger Source'), findsOneWidget);
      expect(find.text('2026-06-07'), findsOneWidget);
      expect(find.text('warp-prism'), findsOneWidget);
      expect(find.text('feature'), findsOneWidget);

      expect(find.text('Related Task'), findsOneWidget);
      expect(find.text('0902'), findsWidgets);
    });

    testWidgets('renders affected assets', (tester) async {
      final descriptor = _testChangelogDescriptor();
      await tester.pumpWidget(
        _wrapInApp(ChangelogDetailView(descriptor: descriptor)),
      );

      expect(find.text('Affected Assets'), findsOneWidget);
      expect(find.text('parser'), findsOneWidget);
      expect(find.text('graph-model'), findsOneWidget);
    });

    testWidgets('renders impact story with Why/Changed/Evidence', (
      tester,
    ) async {
      final descriptor = _testChangelogDescriptor();
      await tester.pumpWidget(
        _wrapInApp(ChangelogDetailView(descriptor: descriptor)),
      );

      expect(find.text('Impact Story'), findsOneWidget);
      expect(find.text('Why'), findsOneWidget);
      expect(find.text('Changed'), findsOneWidget);
      expect(find.text('Evidence'), findsOneWidget);
    });
  });

  group('GenericAssetDetailView (fallback)', () {
    testWidgets('renders partial support banner for subskill', (tester) async {
      final descriptor = _testGenericDescriptor(
        asset: _testGenericAsset(kind: AssetKind.subskill),
      );
      await tester.pumpWidget(
        _wrapInApp(GenericAssetDetailView(descriptor: descriptor)),
      );

      expect(find.text('Partial support'), findsOneWidget);
      expect(find.text('Identity'), findsOneWidget);
      expect(find.text('readme-writer'), findsWidgets);
    });

    testWidgets('renders partial support banner for script', (tester) async {
      final descriptor = _testGenericDescriptor(
        asset: _testGenericAsset(
          kind: AssetKind.script,
          name: 'validate-changelog',
          id: 'script:validate-changelog',
        ),
      );
      await tester.pumpWidget(
        _wrapInApp(GenericAssetDetailView(descriptor: descriptor)),
      );

      expect(find.text('Partial support'), findsOneWidget);
    });

    testWidgets('renders partial support banner for reference', (tester) async {
      final descriptor = _testGenericDescriptor(
        asset: _testGenericAsset(
          kind: AssetKind.reference,
          name: 'flutter-docs',
          id: 'reference:flutter-docs',
        ),
      );
      await tester.pumpWidget(
        _wrapInApp(GenericAssetDetailView(descriptor: descriptor)),
      );

      expect(find.text('Partial support'), findsOneWidget);
    });

    testWidgets('renders partial support banner for rule', (tester) async {
      final descriptor = _testGenericDescriptor(
        asset: _testGenericAsset(
          kind: AssetKind.rule,
          name: 'no-mutation-in-read-only',
          id: 'rule:no-mutation-in-read-only',
        ),
      );
      await tester.pumpWidget(
        _wrapInApp(GenericAssetDetailView(descriptor: descriptor)),
      );

      expect(find.text('Partial support'), findsOneWidget);
    });

    testWidgets('shows identity and metadata in fallback view', (tester) async {
      final descriptor = _testGenericDescriptor(
        asset: _testGenericAsset(kind: AssetKind.subskill),
      );
      await tester.pumpWidget(
        _wrapInApp(GenericAssetDetailView(descriptor: descriptor)),
      );

      expect(find.text('Identity'), findsOneWidget);
      expect(find.text('readme-writer'), findsWidgets);
      // Subskill has tags
      expect(find.textContaining('documentation'), findsWidgets);
    });
  });

  group('AssetDetailView dispatcher', () {
    testWidgets('dispatches agent to AgentDetailView', (tester) async {
      final descriptor = _testAgentDescriptor();
      await tester.pumpWidget(
        _wrapInApp(AssetDetailView(descriptor: descriptor)),
      );

      expect(find.text('Operational Metadata'), findsOneWidget);
      expect(find.text('Skill Affinity'), findsOneWidget);
    });

    testWidgets('dispatches workflow to WorkflowDetailView', (tester) async {
      final descriptor = _testWorkflowDescriptor();
      await tester.pumpWidget(
        _wrapInApp(AssetDetailView(descriptor: descriptor)),
      );

      expect(find.text('Trigger'), findsOneWidget);
      expect(find.text('Stages'), findsOneWidget);
    });

    testWidgets('dispatches changelog to ChangelogDetailView', (tester) async {
      final descriptor = _testChangelogDescriptor();
      await tester.pumpWidget(
        _wrapInApp(AssetDetailView(descriptor: descriptor)),
      );

      expect(find.text('Ledger Source'), findsOneWidget);
      expect(find.text('Impact Story'), findsOneWidget);
    });

    testWidgets('dispatches subskill to GenericAssetDetailView', (
      tester,
    ) async {
      final descriptor = _testGenericDescriptor(
        asset: _testGenericAsset(kind: AssetKind.subskill),
      );
      await tester.pumpWidget(
        _wrapInApp(AssetDetailView(descriptor: descriptor)),
      );

      expect(find.text('Partial support'), findsOneWidget);
    });

    testWidgets('dispatches script to GenericAssetDetailView', (tester) async {
      final descriptor = _testGenericDescriptor(
        asset: _testGenericAsset(
          kind: AssetKind.script,
          name: 'test-script',
          id: 'script:test-script',
        ),
      );
      await tester.pumpWidget(
        _wrapInApp(AssetDetailView(descriptor: descriptor)),
      );

      expect(find.text('Partial support'), findsOneWidget);
    });

    testWidgets('dispatches reference to GenericAssetDetailView', (
      tester,
    ) async {
      final descriptor = _testGenericDescriptor(
        asset: _testGenericAsset(
          kind: AssetKind.reference,
          name: 'test-ref',
          id: 'reference:test-ref',
        ),
      );
      await tester.pumpWidget(
        _wrapInApp(AssetDetailView(descriptor: descriptor)),
      );

      expect(find.text('Partial support'), findsOneWidget);
    });

    testWidgets('dispatches rule to GenericAssetDetailView', (tester) async {
      final descriptor = _testGenericDescriptor(
        asset: _testGenericAsset(
          kind: AssetKind.rule,
          name: 'test-rule',
          id: 'rule:test-rule',
        ),
      );
      await tester.pumpWidget(
        _wrapInApp(AssetDetailView(descriptor: descriptor)),
      );

      expect(find.text('Partial support'), findsOneWidget);
    });
  });

  group('Partial-data and empty states', () {
    testWidgets('agent with empty frontmatter does not crash', (tester) async {
      final asset = _testAgentAsset(frontmatter: const {});
      final descriptor = AssetDetailDescriptor(
        asset: asset,
        sharedSections: [
          DetailSection(
            title: 'Identity',
            key: 'identity',
            properties: [
              DetailProperty(label: 'Name', value: asset.name),
              DetailProperty(label: 'ID', value: asset.id),
            ],
          ),
        ],
        kindSections: const [],
        incomingLinks: const [],
        outgoingLinks: const [],
      );
      await tester.pumpWidget(
        _wrapInApp(AgentDetailView(descriptor: descriptor)),
      );

      expect(find.text('Identity'), findsOneWidget);
    });

    testWidgets('workflow with no stages or trigger does not crash', (
      tester,
    ) async {
      final asset = _testWorkflowAsset(frontmatter: const {});
      final descriptor = AssetDetailDescriptor(
        asset: asset,
        sharedSections: [
          DetailSection(
            title: 'Identity',
            key: 'identity',
            properties: [DetailProperty(label: 'Name', value: asset.name)],
          ),
        ],
        kindSections: const [],
        incomingLinks: const [],
        outgoingLinks: const [],
      );
      await tester.pumpWidget(
        _wrapInApp(WorkflowDetailView(descriptor: descriptor)),
      );

      expect(find.text('Identity'), findsOneWidget);
    });

    testWidgets('changelog with no task or impact does not crash', (
      tester,
    ) async {
      final asset = _testChangelogAsset(frontmatter: const {});
      final descriptor = AssetDetailDescriptor(
        asset: asset,
        sharedSections: [
          DetailSection(
            title: 'Identity',
            key: 'identity',
            properties: [DetailProperty(label: 'Entry', value: asset.name)],
          ),
        ],
        kindSections: const [],
        incomingLinks: const [],
        outgoingLinks: const [],
      );
      await tester.pumpWidget(
        _wrapInApp(ChangelogDetailView(descriptor: descriptor)),
      );

      expect(find.text('Identity'), findsOneWidget);
    });
  });
}
