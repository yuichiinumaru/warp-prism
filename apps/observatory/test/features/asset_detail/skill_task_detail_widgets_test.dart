/// Widget tests for skill and task detail variants.
///
/// Verifies:
/// - Skill detail renders 6 panels (identity, role, sub-structure, incoming, usage, governance)
/// - Task detail renders forensic sections (contract, deps, validation, evidence, lifecycle)
/// - Related tasks/changelog/skills/workflows shown when present
/// - Loading, empty, and partial-data states don't break the inspector
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_observatory/data/models/workspace_graph.dart';
import 'package:warp_prism_observatory/data/models/task_contracts.dart';
import 'package:warp_prism_observatory/features/asset_detail/domain/asset_detail_descriptor.dart';
import 'package:warp_prism_observatory/features/asset_detail/presentation/skill_detail_view.dart';
import 'package:warp_prism_observatory/features/asset_detail/presentation/task_detail_view.dart';
import 'package:warp_prism_observatory/features/asset_detail/presentation/asset_detail_view.dart';

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

WorkspaceAsset _testSkillAsset({
  String name = 'agent-wiki',
  String id = 'skill:agent-wiki',
  String description = 'Wiki documentation skill for agent knowledge',
  Map<String, dynamic> frontmatter = const {},
  List<String> triggers = const ['wiki', 'documentation', 'knowledge'],
  List<String> tags = const ['documentation', 'harness'],
}) {
  return WorkspaceAsset(
    id: id,
    kind: AssetKind.skill,
    name: name,
    path: '.agents/skills/agent-wiki/SKILL.md',
    description: description,
    canonicality: Canonicality.parentCanonical,
    frontmatter: frontmatter,
    tags: tags,
    triggers: triggers,
  );
}

AssetDetailDescriptor _testSkillDescriptor({
  WorkspaceAsset? asset,
  List<DetailLink> incoming = const [
    DetailLink(targetId: 'agent:builder', label: 'builder', kind: 'agent'),
    DetailLink(
      targetId: 'workflow:doc-gen',
      label: 'doc-gen',
      kind: 'workflow',
    ),
  ],
  List<DetailLink> outgoing = const [
    DetailLink(
      targetId: 'subskill:readme-writer',
      label: 'readme-writer',
      kind: 'skill',
    ),
  ],
}) {
  final a = asset ?? _testSkillAsset();
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
          DetailProperty(label: 'Provenance', value: a.canonicality.name),
          DetailProperty(label: 'Description', value: a.description),
        ],
      ),
    ],
    kindSections: [
      DetailSection(
        title: 'Role in the Harness',
        key: 'role',
        kindSpecific: true,
        properties: [
          const DetailProperty(label: 'Type', value: 'Execution skill'),
        ],
      ),
      DetailSection(
        title: 'Sub-structure',
        key: 'substructure',
        kindSpecific: true,
        count: 2,
        properties: [
          const DetailProperty(
            label: 'Sub-skills',
            value: 'readme-writer, api-doc-writer',
          ),
        ],
      ),
      DetailSection(
        title: 'Incoming Links',
        key: 'incoming',
        kindSpecific: true,
        count: incoming.length,
        links: incoming,
      ),
      DetailSection(
        title: 'Operational Usage',
        key: 'usage',
        kindSpecific: true,
        properties: [
          DetailProperty(label: 'Triggers', value: a.triggers.join(', ')),
        ],
      ),
      DetailSection(
        title: 'Governance',
        key: 'governance',
        kindSpecific: true,
        properties: [
          DetailProperty(label: 'Provenance', value: a.canonicality.name),
        ],
      ),
    ],
    incomingLinks: incoming,
    outgoingLinks: outgoing,
  );
}

WorkspaceAsset _testTaskAsset({
  String name = 'Skill and Task Detail Variants',
  String id = 'task:0903',
  Map<String, dynamic> frontmatter = const {},
}) {
  return WorkspaceAsset(
    id: id,
    kind: AssetKind.task,
    name: name,
    path: 'docs/tasks/02-doing/0903-warp-prism-skill-task-detail-variants.md',
    description: 'Implement detail views for skill and task assets',
    canonicality: Canonicality.parentCanonical,
    frontmatter: frontmatter,
  );
}

AssetDetailDescriptor _testTaskDescriptor({WorkspaceAsset? asset}) {
  final a = asset ?? _testTaskAsset();
  return AssetDetailDescriptor(
    asset: a,
    sharedSections: [
      DetailSection(
        title: 'Identity',
        key: 'identity',
        properties: [
          DetailProperty(label: 'Task', value: a.name),
          DetailProperty(label: 'ID', value: a.id),
          DetailProperty(label: 'Path', value: a.path),
          DetailProperty(label: 'Priority', value: 'P1'),
          DetailProperty(label: 'Owner', value: 'builder-agent'),
        ],
      ),
    ],
    kindSections: [
      DetailSection(
        title: 'Contract',
        key: 'contract',
        kindSpecific: true,
        properties: [
          const DetailProperty(label: 'Lane', value: '02-doing'),
          const DetailProperty(label: 'Proof State', value: 'partial'),
          const DetailProperty(label: 'Created', value: '2026-06-07'),
          const DetailProperty(label: 'Updated', value: '2026-06-07'),
        ],
      ),
      DetailSection(
        title: 'Dependencies',
        key: 'dependencies',
        kindSpecific: true,
        count: 1,
        links: [
          const DetailLink(targetId: 'task:0902', label: '0902', kind: 'task'),
        ],
      ),
      DetailSection(
        title: 'Validation Commands',
        key: 'validation',
        kindSpecific: true,
        count: 2,
        codeBlocks: [
          'flutter test test/features/asset_detail/skill_task_detail_widgets_test.dart',
          'flutter analyze',
        ],
      ),
      DetailSection(
        title: 'Evidence',
        key: 'evidence',
        kindSpecific: true,
        properties: [
          const DetailProperty(label: 'Evidence', value: 'Not yet provided'),
        ],
      ),
      DetailSection(
        title: 'Related Skills & Workflows',
        key: 'related',
        kindSpecific: true,
        count: 2,
        links: [
          const DetailLink(
            targetId: 'skill:agent-wiki',
            label: 'agent-wiki',
            kind: 'skill',
          ),
          const DetailLink(
            targetId: 'workflow:build-orchestrator',
            label: 'build-orchestrator',
            kind: 'workflow',
          ),
        ],
      ),
      DetailSection(
        title: 'Lifecycle',
        key: 'lifecycle',
        kindSpecific: true,
        properties: [
          const DetailProperty(label: 'Created', value: '2026-06-07'),
          const DetailProperty(label: 'Updated', value: '2026-06-07'),
        ],
      ),
    ],
    incomingLinks: const [],
    outgoingLinks: const [
      DetailLink(targetId: 'task:0902', label: '0902', kind: 'task'),
    ],
    taskMetadata: TaskMetadata(
      id: '0903',
      title: 'Skill and Task Detail Variants',
      lane: TaskLane.doing,
      priority: 'P1',
      owner: 'builder-agent',
      created: DateTime(2026, 6, 7),
      updated: DateTime(2026, 6, 7),
      proofState: ProofState.partial,
      dependsOn: const ['0902'],
      skills: const ['agent-wiki'],
      workflows: const ['build-orchestrator'],
    ),
  );
}

Widget _wrapInApp(Widget child) {
  return MaterialApp(home: SizedBox.expand(child: child));
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('SkillDetailView', () {
    testWidgets('renders all 6 panels for a complete skill', (tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final descriptor = _testSkillDescriptor();
      await tester.pumpWidget(
        _wrapInApp(SkillDetailView(descriptor: descriptor)),
      );

      // Identity
      expect(find.text('Identity'), findsOneWidget);
      expect(find.text('agent-wiki'), findsWidgets);

      // Role
      expect(find.text('Role in the Harness'), findsOneWidget);
      expect(find.text('Execution skill'), findsOneWidget);

      // Sub-structure
      expect(find.text('Sub-structure'), findsOneWidget);
      expect(find.text('readme-writer, api-doc-writer'), findsOneWidget);

      // Incoming links
      expect(find.text('Incoming Links'), findsWidgets);

      // Usage
      expect(find.text('Operational Usage'), findsOneWidget);

      // Governance
      expect(find.text('Governance'), findsOneWidget);
    });

    testWidgets('renders triggers and tags', (tester) async {
      final descriptor = _testSkillDescriptor();
      await tester.pumpWidget(
        _wrapInApp(SkillDetailView(descriptor: descriptor)),
      );

      expect(find.textContaining('wiki'), findsWidgets);
      expect(find.textContaining('documentation'), findsWidgets);
    });

    testWidgets('renders incoming links as link rows', (tester) async {
      final descriptor = _testSkillDescriptor();
      await tester.pumpWidget(
        _wrapInApp(SkillDetailView(descriptor: descriptor)),
      );

      expect(find.textContaining('builder'), findsWidgets);
      expect(find.textContaining('doc-gen'), findsWidgets);
    });

    testWidgets('handles skill with empty sub-structure', (tester) async {
      final descriptor = _testSkillDescriptor(
        asset: _testSkillAsset(triggers: []),
        incoming: const [],
        outgoing: const [],
      );
      await tester.pumpWidget(
        _wrapInApp(SkillDetailView(descriptor: descriptor)),
      );

      // Should not crash
      expect(find.text('Identity'), findsOneWidget);
      expect(find.text('Role in the Harness'), findsOneWidget);
    });
  });

  group('TaskDetailView', () {
    testWidgets('renders forensic sections with lane-neutral header', (
      tester,
    ) async {
      final descriptor = _testTaskDescriptor();
      await tester.pumpWidget(
        _wrapInApp(TaskDetailView(descriptor: descriptor)),
      );

      // Header with task id and title
      expect(find.textContaining('task:0903'), findsWidgets);
      expect(
        find.textContaining('Skill and Task Detail Variants'),
        findsWidgets,
      );

      // Contract section
      expect(find.text('Contract'), findsOneWidget);
      expect(find.text('02-doing'), findsOneWidget);
      expect(find.text('P1'), findsOneWidget);
      expect(find.text('builder-agent'), findsOneWidget);
    });

    testWidgets('renders dependencies as link rows', (tester) async {
      final descriptor = _testTaskDescriptor();
      await tester.pumpWidget(
        _wrapInApp(TaskDetailView(descriptor: descriptor)),
      );

      expect(find.text('Dependencies'), findsOneWidget);
      expect(find.text('0902'), findsWidgets);
    });

    testWidgets('renders validation commands as code blocks', (tester) async {
      final descriptor = _testTaskDescriptor();
      await tester.pumpWidget(
        _wrapInApp(TaskDetailView(descriptor: descriptor)),
      );

      expect(find.text('Validation Commands'), findsOneWidget);
      expect(find.textContaining('flutter test'), findsOneWidget);
      expect(find.textContaining('flutter analyze'), findsOneWidget);
    });

    testWidgets('renders evidence section', (tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final descriptor = _testTaskDescriptor();
      await tester.pumpWidget(
        _wrapInApp(TaskDetailView(descriptor: descriptor)),
      );

      expect(find.text('Evidence'), findsWidgets);
      expect(find.text('Not yet provided'), findsOneWidget);
    });

    testWidgets('renders related skills and workflows', (tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final descriptor = _testTaskDescriptor();
      await tester.pumpWidget(
        _wrapInApp(TaskDetailView(descriptor: descriptor)),
      );

      expect(find.text('Related Skills & Workflows'), findsOneWidget);
      expect(find.text('agent-wiki'), findsOneWidget);
      expect(find.text('build-orchestrator'), findsOneWidget);
    });

    testWidgets('renders lifecycle section', (tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final descriptor = _testTaskDescriptor();
      await tester.pumpWidget(
        _wrapInApp(TaskDetailView(descriptor: descriptor)),
      );

      expect(find.text('Lifecycle'), findsOneWidget);
    });

    testWidgets('renders close button', (tester) async {
      var closed = false;
      final descriptor = _testTaskDescriptor();
      await tester.pumpWidget(
        _wrapInApp(
          TaskDetailView(descriptor: descriptor, onClose: () => closed = true),
        ),
      );

      final closeBtn = find.byTooltip('Close');
      expect(closeBtn, findsOneWidget);
      await tester.tap(closeBtn);
      expect(closed, isTrue);
    });
  });

  group('AssetDetailEmpty', () {
    testWidgets('renders empty state when no asset selected', (tester) async {
      await tester.pumpWidget(_wrapInApp(const AssetDetailEmpty()));
      expect(find.text('No asset selected'), findsOneWidget);
    });
  });

  group('AssetDetailView dispatcher', () {
    testWidgets('dispatches skill to SkillDetailView', (tester) async {
      final descriptor = _testSkillDescriptor();
      await tester.pumpWidget(
        _wrapInApp(AssetDetailView(descriptor: descriptor)),
      );

      // Skill-specific panels should be visible
      expect(find.text('Role in the Harness'), findsOneWidget);
      expect(find.text('Sub-structure'), findsOneWidget);
    });

    testWidgets('dispatches task to TaskDetailView', (tester) async {
      final descriptor = _testTaskDescriptor();
      await tester.pumpWidget(
        _wrapInApp(AssetDetailView(descriptor: descriptor)),
      );

      // Task-specific panels should be visible
      expect(find.text('Contract'), findsOneWidget);
      expect(find.text('Validation Commands'), findsOneWidget);
    });
  });
}
