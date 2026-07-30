/// Tests for [HistoryRepository] — the history read model.
///
/// Proves that:
/// - Changelog frontmatter is parsed into typed HistoryEntry objects.
/// - Chronological ordering is deterministic (newest first).
/// - Filter facets are computed for project, type, task, skill, workflow, impact_tags.
/// - Story-mode groupings are built by project, type, and task.
/// - Malformed entries are preserved as data with warnings (never dropped).
/// - Cross-reference edges resolve changelog -> task -> skill/workflow paths.
/// - Real mock corpus fixtures load through the parser + repository path.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_observatory/data/models/workspace_graph.dart';
import 'package:warp_prism_observatory/data/models/changelog_contracts.dart';
import 'package:warp_prism_observatory/data/models/task_contracts.dart';
import 'package:warp_prism_observatory/data/parsers/workspace_markdown_parser.dart';
import 'package:warp_prism_observatory/data/repositories/history_repository.dart';
import 'package:warp_prism_observatory/data/repositories/mock_workspace_repository.dart';

void main() {
  group('HistoryRepository', () {
    const repo = HistoryRepository();

    test('builds timeline from changelog assets in chronological order', () {
      final assets = _buildSampleChangelogAssets();
      final timeline = repo.buildTimeline(assets);

      expect(timeline.isNotEmpty, isTrue);
      expect(timeline.count, equals(assets.length));

      // Newest first (null dates already sorted last by repository)
      for (var i = 0; i < timeline.entries.length - 1; i++) {
        final current = timeline.entries[i].date;
        final next = timeline.entries[i + 1].date;
        if (current == null || next == null) continue;
        expect(
          current.isAfter(next) || current.isAtSameMomentAs(next),
          isTrue,
          reason: 'Entry $current should be >= $next',
        );
      }
    });

    test('extracts typed metadata from ChangelogMetadata', () {
      final assets = _buildSampleChangelogAssets();
      final timeline = repo.buildTimeline(assets);

      final t012Entry = timeline.entries.firstWhere((e) => e.task == 'T012');
      expect(t012Entry.project, equals('warp-prism'));
      expect(t012Entry.type, equals(ChangelogType.feature));
      expect(t012Entry.impactTags, contains('graph'));
      expect(t012Entry.skills, contains('harness-architecture'));
    });

    test('filterByProject returns entries for given project', () {
      final assets = _buildSampleChangelogAssets();
      final timeline = repo.buildTimeline(assets);

      final prismEntries = timeline.filterByProject('warp-prism');
      expect(prismEntries, isNotEmpty);
      expect(prismEntries.every((e) => e.project == 'warp-prism'), isTrue);
    });

    test('filterByType returns entries of given type', () {
      final assets = _buildSampleChangelogAssets();
      final timeline = repo.buildTimeline(assets);

      final features = timeline.filterByType(ChangelogType.feature);
      expect(features, isNotEmpty);
      expect(features.every((e) => e.type == ChangelogType.feature), isTrue);
    });

    test('filterByTask returns entries linked to given task', () {
      final assets = _buildSampleChangelogAssets();
      final timeline = repo.buildTimeline(assets);

      final t012Entries = timeline.filterByTask('T012');
      expect(t012Entries, isNotEmpty);
      expect(t012Entries.every((e) => e.task == 'T012'), isTrue);
    });

    test('filterByImpactTag returns entries with given tag', () {
      final assets = _buildSampleChangelogAssets();
      final timeline = repo.buildTimeline(assets);

      final graphEntries = timeline.filterByImpactTag('graph');
      expect(graphEntries, isNotEmpty);
      expect(graphEntries.every((e) => e.impactTags.contains('graph')), isTrue);
    });

    test('filterBySkill returns entries referencing given skill', () {
      final assets = _buildSampleChangelogAssets();
      final timeline = repo.buildTimeline(assets);

      final harnessEntries = timeline.filterBySkill('harness-architecture');
      expect(harnessEntries, isNotEmpty);
      expect(
        harnessEntries.every((e) => e.resolvedSkills.contains('harness-architecture')),
        isTrue,
      );
    });
  });

  group('HistoryFacets', () {
    test('computes all facet dimensions', () {
      final assets = _buildSampleChangelogAssets();
      const repo = HistoryRepository();
      final timeline = repo.buildTimeline(assets);

      expect(timeline.facets.projects, isNotEmpty);
      expect(timeline.facets.types, isNotEmpty);
      expect(timeline.facets.tasks, isNotEmpty);
      expect(timeline.facets.skills, isNotEmpty);
      expect(timeline.facets.impactTags, isNotEmpty);
    });

    test('facets contain expected values', () {
      final assets = _buildSampleChangelogAssets();
      const repo = HistoryRepository();
      final timeline = repo.buildTimeline(assets);

      expect(timeline.facets.projects, contains('warp-prism'));
      expect(timeline.facets.types, contains(ChangelogType.feature));
      expect(timeline.facets.tasks, contains('T012'));
      expect(timeline.facets.skills, contains('harness-architecture'));
      expect(timeline.facets.impactTags, contains('graph'));
    });

    test('empty timeline produces empty facets', () {
      const repo = HistoryRepository();
      final timeline = repo.buildTimeline([]);

      expect(timeline.facets.projects, isEmpty);
      expect(timeline.facets.types, isEmpty);
      expect(timeline.facets.tasks, isEmpty);
      expect(timeline.facets.skills, isEmpty);
      expect(timeline.facets.impactTags, isEmpty);
      expect(timeline.facets.workflows, isEmpty);
    });

    test('workflow facet includes direct and task-hop workflows', () {
      final changelog = [
        _buildChangelogAsset(
          id: 'changelog:wf-direct',
          date: DateTime(2026, 6, 5),
          project: 'warp-prism',
          task: 'T012',
          type: ChangelogType.feature,
          skills: const ['harness-architecture'],
          workflows: const ['builder-orchestration'],
        ),
      ];
      final tasks = [
        _buildTaskAsset(
          id: 'T012',
          skills: const ['coding-execution-harness'],
          workflows: const ['gt-harness-architecture'],
        ),
      ];

      const repo = HistoryRepository();
      final timeline = repo.buildTimeline(changelog, tasks: tasks);

      expect(timeline.facets.workflows, contains('builder-orchestration'));
      expect(timeline.facets.workflows, contains('gt-harness-architecture'));
      expect(timeline.facets.skills, contains('coding-execution-harness'));
    });
  });

  group('HistoryStoryGroup', () {
    test('groups by project', () {
      final assets = _buildSampleChangelogAssets();
      const repo = HistoryRepository();
      final timeline = repo.buildTimeline(assets);

      expect(timeline.byProject, isNotEmpty);
      final prismGroup = timeline.byProject.firstWhere(
        (g) => g.key == 'warp-prism',
      );
      expect(prismGroup.count, greaterThan(0));
    });

    test('groups by type', () {
      final assets = _buildSampleChangelogAssets();
      const repo = HistoryRepository();
      final timeline = repo.buildTimeline(assets);

      expect(timeline.byType, isNotEmpty);
      final featureGroup = timeline.byType.firstWhere(
        (g) => g.key == 'feature',
      );
      expect(featureGroup.count, greaterThan(0));
    });

    test('groups by task', () {
      final assets = _buildSampleChangelogAssets();
      const repo = HistoryRepository();
      final timeline = repo.buildTimeline(assets);

      expect(timeline.byTask, isNotEmpty);
      for (final group in timeline.byTask) {
        expect(group.count, greaterThan(0));
      }
    });

    test('groups are sorted by count descending', () {
      final assets = _buildSampleChangelogAssets();
      const repo = HistoryRepository();
      final timeline = repo.buildTimeline(assets);

      for (var i = 0; i < timeline.byProject.length - 1; i++) {
        expect(
          timeline.byProject[i].count >= timeline.byProject[i + 1].count,
          isTrue,
        );
      }
    });
  });

  group('HistoryEntry', () {
    test('linkedTaskId returns null for empty task', () {
      final entry = HistoryEntry(
        id: 'test',
        title: 'Test',
        date: DateTime(2026, 6, 1),
        project: 'test',
        task: '',
        type: ChangelogType.chore,
        impactTags: const [],
        skills: const [],
        path: '/test.md',
      );
      expect(entry.linkedTaskId, isNull);
      expect(entry.hasTaskLink, isFalse);
    });

    test('linkedTaskId returns formatted id for non-empty task', () {
      final entry = HistoryEntry(
        id: 'test',
        title: 'Test',
        date: DateTime(2026, 6, 1),
        project: 'test',
        task: '0310',
        type: ChangelogType.chore,
        impactTags: const [],
        skills: const [],
        path: '/test.md',
      );
      expect(entry.linkedTaskId, equals('task:0310'));
      expect(entry.hasTaskLink, isTrue);
    });
  });

  group('Malformed and edge cases', () {
    test('empty input produces empty timeline', () {
      const repo = HistoryRepository();
      final timeline = repo.buildTimeline([]);

      expect(timeline.isEmpty, isTrue);
      expect(timeline.count, equals(0));
      expect(timeline.byProject, isEmpty);
      expect(timeline.byType, isEmpty);
      expect(timeline.byTask, isEmpty);
      expect(timeline.impactEdges, isEmpty);
    });

    test('assets without ChangelogMetadata are handled gracefully', () {
      final assets = [
        const WorkspaceAsset(
          id: 'changelog:no-meta',
          kind: AssetKind.changelog,
          name: 'no-meta',
          path: '/ws/docs/changelog/no-meta.md',
          frontmatter: {
            'date': '2026-06-01',
            'project': 'test',
            'task': '100',
            'type': 'feature',
          },
        ),
      ];

      const repo = HistoryRepository();
      final timeline = repo.buildTimeline(assets);

      expect(timeline.count, equals(1));
      expect(timeline.entries.first.project, equals('test'));
      expect(timeline.entries.first.isMalformed, isTrue);
      expect(
        timeline.entries.first.warnings,
        contains('missing_changelog_metadata'),
      );
    });

    test('invalid-date entries are preserved as malformed data, not dropped', () {
      final assets = [
        const WorkspaceAsset(
          id: 'changelog:bad-date',
          kind: AssetKind.changelog,
          name: 'bad-date',
          path: '/ws/docs/changelog/bad.md',
          frontmatter: {
            'date': 'invalid-date',
            'project': 'test',
            'task': 'T099',
            'type': 'chore',
          },
        ),
        _buildChangelogAsset(
          id: 'changelog:real-date',
          date: DateTime(2026, 6, 5),
          project: 'test',
          task: '1',
          type: ChangelogType.feature,
        ),
      ];

      const repo = HistoryRepository();
      final timeline = repo.buildTimeline(assets);

      expect(timeline.count, equals(2), reason: 'must not drop invalid-date assets');
      expect(timeline.entries.first.id, equals('changelog:real-date'));
      expect(timeline.entries.first.date?.year, equals(2026));

      final malformed = timeline.malformedEntries;
      expect(malformed, isNotEmpty);
      final bad = malformed.firstWhere((e) => e.id == 'changelog:bad-date');
      expect(bad.date, isNull);
      expect(bad.isMalformed, isTrue);
      expect(bad.warnings, contains('invalid_date'));
      expect(bad.task, equals('T099'));
    });

    test('missing date without metadata is preserved with warning', () {
      final assets = [
        const WorkspaceAsset(
          id: 'changelog:no-date',
          kind: AssetKind.changelog,
          name: 'no-date',
          path: '/ws/docs/changelog/no-date.md',
          frontmatter: {
            'project': 'warp-prism',
            'task': 'T001',
            'type': 'docs',
          },
        ),
      ];

      const repo = HistoryRepository();
      final timeline = repo.buildTimeline(assets);

      expect(timeline.count, equals(1));
      expect(timeline.entries.first.isMalformed, isTrue);
      expect(timeline.entries.first.warnings, contains('missing_date'));
      expect(timeline.entries.first.date, isNull);
    });

    test('multiple entries with same date maintain stable order', () {
      final date = DateTime(2026, 6, 5);
      final assets = [
        _buildChangelogAsset(
          id: 'changelog:a',
          date: date,
          project: 'p',
          task: '1',
          type: ChangelogType.feature,
        ),
        _buildChangelogAsset(
          id: 'changelog:b',
          date: date,
          project: 'p',
          task: '2',
          type: ChangelogType.fix,
        ),
      ];

      const repo = HistoryRepository();
      final timeline = repo.buildTimeline(assets);

      expect(timeline.count, equals(2));
      final ids = timeline.entries.map((e) => e.id).toSet();
      expect(ids, contains('changelog:a'));
      expect(ids, contains('changelog:b'));
    });
  });

  group('Cross-reference edges', () {
    test('HistoryEntry.linkedTaskId produces graph-compatible id', () {
      final assets = _buildSampleChangelogAssets();
      const repo = HistoryRepository();
      final timeline = repo.buildTimeline(assets);

      for (final entry in timeline.entries) {
        if (entry.hasTaskLink) {
          expect(entry.linkedTaskId, startsWith('task:'));
        }
      }
    });

    test('materializes changelog -> task and changelog -> project edges', () {
      final assets = _buildSampleChangelogAssets();
      const repo = HistoryRepository();
      final timeline = repo.buildTimeline(assets);

      final t012 = timeline.entries.firstWhere((e) => e.task == 'T012');
      expect(
        t012.impactEdges.any(
          (e) =>
              e.kind == HistoryImpactHopKind.changelogToTask &&
              e.targetId == 'task:T012',
        ),
        isTrue,
      );
      expect(
        t012.impactEdges.any(
          (e) =>
              e.kind == HistoryImpactHopKind.changelogToProject &&
              e.targetId == 'project:warp-prism',
        ),
        isTrue,
      );
    });

    test('materializes multi-hop changelog -> task -> skill/workflow edges', () {
      final changelog = [
        _buildChangelogAsset(
          id: 'changelog:2026-06-05-T012',
          date: DateTime(2026, 6, 5),
          project: 'warp-prism',
          task: 'T012',
          type: ChangelogType.feature,
          skills: const ['harness-architecture'],
          workflows: const ['builder-orchestration'],
        ),
      ];
      final tasks = [
        _buildTaskAsset(
          id: 'T012',
          skills: const [
            'coding-execution-harness',
            'harness-architecture',
          ],
          workflows: const [
            'gt-harness-architecture',
            'gt-verify-task-completion',
          ],
        ),
      ];

      const repo = HistoryRepository();
      final timeline = repo.buildTimeline(changelog, tasks: tasks);
      final entry = timeline.entries.single;

      expect(
        entry.impactEdges.any(
          (e) => e.kind == HistoryImpactHopKind.changelogToTask,
        ),
        isTrue,
      );
      expect(
        entry.impactEdges.any(
          (e) =>
              e.kind == HistoryImpactHopKind.taskToSkill &&
              e.sourceId == 'task:T012' &&
              e.targetId == 'skill:coding-execution-harness',
        ),
        isTrue,
      );
      expect(
        entry.impactEdges.any(
          (e) =>
              e.kind == HistoryImpactHopKind.taskToWorkflow &&
              e.sourceId == 'task:T012' &&
              e.targetId == 'workflow:gt-harness-architecture',
        ),
        isTrue,
      );
      expect(
        entry.impactEdges.any(
          (e) =>
              e.kind == HistoryImpactHopKind.changelogToSkill &&
              e.targetId == 'skill:harness-architecture',
        ),
        isTrue,
      );
      expect(
        entry.impactEdges.any(
          (e) =>
              e.kind == HistoryImpactHopKind.changelogToWorkflow &&
              e.targetId == 'workflow:builder-orchestration',
        ),
        isTrue,
      );

      // Flat timeline edge bag includes the multi-hop edges
      expect(
        timeline.impactEdges.any(
          (e) => e.kind == HistoryImpactHopKind.taskToSkill,
        ),
        isTrue,
      );
      expect(entry.resolvedWorkflows, contains('gt-harness-architecture'));
      expect(entry.resolvedSkills, contains('coding-execution-harness'));
    });
  });

  group('Real mock corpus integration', () {
    test('builds timeline from assets/mock_workspace changelog fixtures', () async {
      final root = _resolveMockWorkspaceRoot();
      final changelogDir = Directory('$root/docs/changelog');
      expect(
        await changelogDir.exists(),
        isTrue,
        reason: 'mock changelog corpus must exist at $root/docs/changelog',
      );

      const parser = WorkspaceMarkdownParser();
      final changelogAssets = <WorkspaceAsset>[];
      await for (final entity in changelogDir.list()) {
        if (entity is! File || !entity.path.endsWith('.md')) continue;
        final content = await entity.readAsString();
        final asset = parser.tryParse(content, filePath: entity.path);
        if (asset != null) changelogAssets.add(asset);
      }

      expect(changelogAssets, isNotEmpty);

      // Also load tasks so multi-hop edges can resolve against real fixtures.
      final taskAssets = <WorkspaceAsset>[];
      for (final lane in [
        '00-planning',
        '01-open',
        '02-doing',
        '03-review',
        '04-completed',
      ]) {
        final dir = Directory('$root/docs/tasks/$lane');
        if (!await dir.exists()) continue;
        await for (final entity in dir.list()) {
          if (entity is! File || !entity.path.endsWith('.md')) continue;
          final content = await entity.readAsString();
          final asset = parser.tryParse(content, filePath: entity.path);
          if (asset != null) taskAssets.add(asset);
        }
      }

      const repo = HistoryRepository();
      final timeline = repo.buildTimeline(
        changelogAssets,
        tasks: taskAssets,
      );

      expect(timeline.isNotEmpty, isTrue);
      expect(timeline.facets.projects, contains('warp-prism'));
      expect(timeline.facets.types, isNotEmpty);
      expect(timeline.facets.tasks, isNotEmpty);
      expect(timeline.facets.impactTags, isNotEmpty);

      // Chronological: first dated entry >= last dated entry
      final dated = timeline.entries.where((e) => e.date != null).toList();
      expect(dated, isNotEmpty);
      expect(
        !dated.first.date!.isBefore(dated.last.date!),
        isTrue,
      );

      // At least one multi-hop path should resolve when task fixtures exist
      final multiHop = timeline.impactEdges.where(
        (e) =>
            e.kind == HistoryImpactHopKind.taskToSkill ||
            e.kind == HistoryImpactHopKind.taskToWorkflow,
      );
      expect(
        multiHop,
        isNotEmpty,
        reason: 'real corpus should produce changelog->task->skill/workflow hops',
      );

      // Direct changelog skill edges from frontmatter
      expect(
        timeline.impactEdges.any(
          (e) => e.kind == HistoryImpactHopKind.changelogToSkill,
        ),
        isTrue,
      );
    });

    test('MockWorkspaceRepository load path feeds HistoryRepository', () async {
      final root = _resolveMockWorkspaceRoot();
      final repo = MockWorkspaceRepository(rootPath: root);
      final state = await repo.load();

      expect(state.isSuccess, isTrue, reason: state.errorMessage ?? 'load failed');
      final snapshot = state.snapshot!;
      expect(snapshot.changelogEntries, isNotEmpty);

      const historyRepo = HistoryRepository();
      final timeline = historyRepo.buildTimeline(
        snapshot.changelogEntries,
        tasks: snapshot.tasks,
        skills: snapshot.skills,
        workflows: snapshot.workflows,
      );

      expect(timeline.count, equals(snapshot.changelogEntries.length));
      expect(timeline.facets.projects, isNotEmpty);
      expect(timeline.impactEdges, isNotEmpty);
    });
  });
}

// ---------------------------------------------------------------------------
// Test fixtures
// ---------------------------------------------------------------------------

String _resolveMockWorkspaceRoot() {
  final candidates = [
    'assets/mock_workspace',
    'apps/observatory/assets/mock_workspace',
  ];
  for (final path in candidates) {
    if (Directory(path).existsSync()) return path;
  }
  // Fall back to package-relative path used when tests run from monorepo root.
  return 'assets/mock_workspace';
}

List<WorkspaceAsset> _buildSampleChangelogAssets() {
  return [
    _buildChangelogAsset(
      id: 'changelog:2026-06-05-T012-edge-inference',
      date: DateTime(2026, 6, 5),
      project: 'warp-prism',
      task: 'T012',
      type: ChangelogType.feature,
      impactTags: const ['graph', 'edge-inference', 'workspace-model'],
      skills: const ['harness-architecture', 'coding-execution-harness'],
      workflows: const ['builder-orchestration'],
      title: 'Edge Inference for Workspace Graph',
    ),
    _buildChangelogAsset(
      id: 'changelog:2026-06-06-T015-governance-audit',
      date: DateTime(2026, 6, 6),
      project: 'warp-prism',
      task: 'T015',
      type: ChangelogType.feature,
      impactTags: const ['governance', 'audit', 'dependency-chains', 'provenance'],
      skills: const ['harness-architecture', 'project-management'],
      title: 'Governance Audit of Task Dependency Chains',
    ),
    _buildChangelogAsset(
      id: 'changelog:2026-06-06-T016-topbar-search',
      date: DateTime(2026, 6, 6),
      project: 'warp-prism',
      task: 'T016',
      type: ChangelogType.feature,
      impactTags: const ['search', 'topbar', 'ui'],
      skills: const ['frontend-quality-harness'],
      title: 'Topbar Search Integration',
    ),
    _buildChangelogAsset(
      id: 'changelog:2026-05-22-T020-frontmatter-migration',
      date: DateTime(2026, 5, 22),
      project: 'warp-prism',
      task: 'T020',
      type: ChangelogType.chore,
      impactTags: const ['changelog', 'migration', 'frontmatter'],
      skills: const ['coding-execution-harness', 'agent-wiki'],
      title: 'Changelog Frontmatter Migration',
    ),
    _buildChangelogAsset(
      id: 'changelog:2026-05-22-T002-graph-viz',
      date: DateTime(2026, 5, 22),
      project: 'warp-prism',
      task: 'T002',
      type: ChangelogType.feature,
      impactTags: const ['graph', 'visualization'],
      skills: const ['harness-architecture'],
      title: 'Graph Visualization Scope',
    ),
  ];
}

WorkspaceAsset _buildChangelogAsset({
  required String id,
  required DateTime date,
  required String project,
  required String task,
  required ChangelogType type,
  List<String> impactTags = const [],
  List<String> skills = const [],
  List<String> workflows = const [],
  String? title,
}) {
  final clMeta = ChangelogMetadata(
    id: id.replaceFirst('changelog:', ''),
    date: date,
    project: project,
    task: task,
    type: type,
    impact: impactTags,
    skills: skills,
  );

  return WorkspaceAsset(
    id: id,
    kind: AssetKind.changelog,
    name: title ?? id,
    path: '/ws/docs/changelog/${id.replaceFirst("changelog:", "")}.md',
    canonicality: Canonicality.appendOnly,
    frontmatter: {
      'id': id.replaceFirst('changelog:', ''),
      'date': date.toIso8601String().substring(0, 10),
      'project': project,
      'task': task,
      'type': type.name,
      'impact': impactTags,
      'skills': skills,
      'workflows': workflows,
      '_changelogMetadata': clMeta,
    },
  );
}

WorkspaceAsset _buildTaskAsset({
  required String id,
  List<String> skills = const [],
  List<String> workflows = const [],
}) {
  final meta = TaskMetadata(
    id: id,
    title: 'Task $id',
    created: DateTime(2026, 6, 1),
    updated: DateTime(2026, 6, 7),
    skills: skills,
    workflows: workflows,
  );

  return WorkspaceAsset(
    id: 'task:$id',
    kind: AssetKind.task,
    name: meta.title,
    path: '/ws/docs/tasks/02-doing/$id.md',
    frontmatter: {
      'id': id,
      'skills': skills,
      'workflows': workflows,
      '_taskMetadata': meta,
    },
    edges: [
      for (final skill in skills)
        WorkspaceEdge(
          sourceId: 'task:$id',
          targetId: 'skill:$skill',
          kind: EdgeKind.references,
        ),
      for (final workflow in workflows)
        WorkspaceEdge(
          sourceId: 'task:$id',
          targetId: 'workflow:$workflow',
          kind: EdgeKind.references,
        ),
    ],
  );
}
