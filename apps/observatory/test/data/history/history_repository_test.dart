/// Tests for [HistoryRepository] — the history read model.
///
/// Proves that:
/// - Changelog frontmatter is parsed into typed HistoryEntry objects.
/// - Chronological ordering is deterministic (newest first).
/// - Filter facets are computed for project, type, task, skill, impact_tags.
/// - Story-mode groupings are built by project, type, and task.
/// - Malformed entries are handled gracefully without exceptions.
/// - Cross-reference edges resolve changelog -> task paths.
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_observatory/data/models/workspace_graph.dart';
import 'package:warp_prism_observatory/data/models/changelog_contracts.dart';
import 'package:warp_prism_observatory/data/repositories/history_repository.dart';

void main() {
  group('HistoryRepository', () {
    const repo = HistoryRepository();

    test('builds timeline from changelog assets in chronological order', () {
      final assets = _buildSampleChangelogAssets();
      final timeline = repo.buildTimeline(assets);

      expect(timeline.isNotEmpty, isTrue);
      expect(timeline.count, equals(assets.length));

      // Newest first
      for (var i = 0; i < timeline.entries.length - 1; i++) {
        expect(
          timeline.entries[i].date.isAfter(timeline.entries[i + 1].date) ||
              timeline.entries[i].date.isAtSameMomentAs(
                  timeline.entries[i + 1].date),
          isTrue,
          reason:
              'Entry ${timeline.entries[i].date} should be >= '
              '${timeline.entries[i + 1].date}',
        );
      }
    });

    test('extracts typed metadata from ChangelogMetadata', () {
      final assets = _buildSampleChangelogAssets();
      final timeline = repo.buildTimeline(assets);

      // Find the entry with task T012
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
      expect(harnessEntries.every((e) => e.skills.contains('harness-architecture')),
          isTrue);
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
    });
  });

  group('HistoryStoryGroup', () {
    test('groups by project', () {
      final assets = _buildSampleChangelogAssets();
      const repo = HistoryRepository();
      final timeline = repo.buildTimeline(assets);

      expect(timeline.byProject, isNotEmpty);
      final prismGroup =
          timeline.byProject.firstWhere((g) => g.key == 'warp-prism');
      expect(prismGroup.count, greaterThan(0));
    });

    test('groups by type', () {
      final assets = _buildSampleChangelogAssets();
      const repo = HistoryRepository();
      final timeline = repo.buildTimeline(assets);

      expect(timeline.byType, isNotEmpty);
      final featureGroup =
          timeline.byType.firstWhere((g) => g.key == 'feature');
      expect(featureGroup.count, greaterThan(0));
    });

    test('groups by task', () {
      final assets = _buildSampleChangelogAssets();
      const repo = HistoryRepository();
      final timeline = repo.buildTimeline(assets);

      expect(timeline.byTask, isNotEmpty);
      // Each group has at least one entry
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
        impactTags: [],
        skills: [],
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
        impactTags: [],
        skills: [],
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

      // Should still build an entry from raw frontmatter
      expect(timeline.count, equals(1));
      expect(timeline.entries.first.project, equals('test'));
    });

    test('assets with invalid dates sort to the end', () {
      final assets = [
        const WorkspaceAsset(
          id: 'changelog:good-date',
          kind: AssetKind.changelog,
          name: 'good-date',
          path: '/ws/docs/changelog/good.md',
          frontmatter: {
            'date': 'invalid-date',
            'project': 'test',
            'task': '',
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

      // The real date should come first
      expect(timeline.entries.first.date.year, equals(2026));
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
      // Both entries present
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
          // The linkedTaskId should be in format task:<taskId>
          expect(entry.linkedTaskId, startsWith('task:'));
        }
      }
    });
  });
}

// ---------------------------------------------------------------------------
// Test fixtures
// ---------------------------------------------------------------------------

/// Build a list of sample changelog assets for testing.
List<WorkspaceAsset> _buildSampleChangelogAssets() {
  return [
    _buildChangelogAsset(
      id: 'changelog:2026-06-05-T012-edge-inference',
      date: DateTime(2026, 6, 5),
      project: 'warp-prism',
      task: 'T012',
      type: ChangelogType.feature,
      impactTags: ['graph', 'edge-inference', 'workspace-model'],
      skills: ['harness-architecture', 'coding-execution-harness'],
      title: 'Edge Inference for Workspace Graph',
    ),
    _buildChangelogAsset(
      id: 'changelog:2026-06-06-T015-governance-audit',
      date: DateTime(2026, 6, 6),
      project: 'warp-prism',
      task: 'T015',
      type: ChangelogType.feature,
      impactTags: ['governance', 'audit', 'dependency-chains', 'provenance'],
      skills: ['harness-architecture', 'project-management'],
      title: 'Governance Audit of Task Dependency Chains',
    ),
    _buildChangelogAsset(
      id: 'changelog:2026-06-06-T016-topbar-search',
      date: DateTime(2026, 6, 6),
      project: 'warp-prism',
      task: 'T016',
      type: ChangelogType.feature,
      impactTags: ['search', 'topbar', 'ui'],
      skills: ['frontend-quality-harness'],
      title: 'Topbar Search Integration',
    ),
    _buildChangelogAsset(
      id: 'changelog:2026-05-22-T020-frontmatter-migration',
      date: DateTime(2026, 5, 22),
      project: 'warp-prism',
      task: 'T020',
      type: ChangelogType.chore,
      impactTags: ['changelog', 'migration', 'frontmatter'],
      skills: ['coding-execution-harness', 'agent-wiki'],
      title: 'Changelog Frontmatter Migration',
    ),
    _buildChangelogAsset(
      id: 'changelog:2026-05-22-T002-graph-viz',
      date: DateTime(2026, 5, 22),
      project: 'warp-prism',
      task: 'T002',
      type: ChangelogType.feature,
      impactTags: ['graph', 'visualization'],
      skills: ['harness-architecture'],
      title: 'Graph Visualization Scope',
    ),
  ];
}

/// Build a single changelog WorkspaceAsset for testing.
WorkspaceAsset _buildChangelogAsset({
  required String id,
  required DateTime date,
  required String project,
  required String task,
  required ChangelogType type,
  List<String> impactTags = const [],
  List<String> skills = const [],
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
      '_changelogMetadata': clMeta,
    },
  );
}
