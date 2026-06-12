/// Tests for the normalized Warp-Prism backbone model contract.
///
/// Validates enum coverage, canonicality handling, and model
/// serialization/equality expectations for the workspace graph backbone.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_observatory/data/models/workspace_graph.dart';
import 'package:warp_prism_observatory/data/models/task_contracts.dart';
import 'package:warp_prism_observatory/data/models/changelog_contracts.dart';
import 'package:warp_prism_observatory/data/models/governance_diagnostics.dart';

void main() {
  group('AssetKind enum coverage', () {
    test('has exactly 9 values', () {
      expect(AssetKind.values.length, 9);
    });

    test('covers all required prompt contract kinds', () {
      const required = [
        'agent',
        'skill',
        'subskill',
        'workflow',
        'task',
        'changelog',
        'script',
        'reference',
        'rule',
      ];
      final names = AssetKind.values.map((e) => e.name).toList();
      for (final r in required) {
        expect(names, contains(r), reason: 'AssetKind missing: $r');
      }
    });
  });

  group('EdgeKind enum coverage', () {
    test('has exactly 7 values', () {
      expect(EdgeKind.values.length, 7);
    });

    test('covers all required prompt contract edge kinds', () {
      const required = [
        'contains',
        'routesTo',
        'dependsOn',
        'references',
        'changedBy',
        'proves',
        'uses',
      ];
      final names = EdgeKind.values.map((e) => e.name).toList();
      for (final r in required) {
        expect(names, contains(r), reason: 'EdgeKind missing: $r');
      }
    });
  });

  group('Canonicality enum coverage', () {
    test('has exactly 6 values', () {
      expect(Canonicality.values.length, 6);
    });

    test('covers all required prompt contract canonicality values', () {
      const required = [
        'parentCanonical',
        'childLocal',
        'generated',
        'appendOnly',
        'archive',
        'mock',
      ];
      final names = Canonicality.values.map((e) => e.name).toList();
      for (final r in required) {
        expect(names, contains(r), reason: 'Canonicality missing: $r');
      }
    });
  });

  group('WorkspaceAsset', () {
    test('can be constructed with required fields only', () {
      const asset = WorkspaceAsset(
        id: 'agent:test',
        kind: AssetKind.agent,
        name: 'test-agent',
        path: '.agents/agents/test-agent.md',
      );
      expect(asset.id, 'agent:test');
      expect(asset.kind, AssetKind.agent);
      expect(asset.canonicality, Canonicality.parentCanonical);
      expect(asset.tags, isEmpty);
      expect(asset.triggers, isEmpty);
      expect(asset.edges, isEmpty);
      expect(asset.frontmatter, isEmpty);
    });

    test('supports all AssetKind values', () {
      for (final kind in AssetKind.values) {
        final asset = WorkspaceAsset(
          id: '${kind.name}:test',
          kind: kind,
          name: 'test-${kind.name}',
          path: 'test/${kind.name}.md',
        );
        expect(asset.kind, kind);
      }
    });

    test('equality is based on id, kind, name, path, canonicality', () {
      const a = WorkspaceAsset(
        id: 'agent:test',
        kind: AssetKind.agent,
        name: 'test',
        path: 'test.md',
        description: 'different',
      );
      const b = WorkspaceAsset(
        id: 'agent:test',
        kind: AssetKind.agent,
        name: 'test',
        path: 'test.md',
        description: 'also different',
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('inequality on different id', () {
      const a = WorkspaceAsset(
        id: 'agent:a',
        kind: AssetKind.agent,
        name: 'test',
        path: 'test.md',
      );
      const b = WorkspaceAsset(
        id: 'agent:b',
        kind: AssetKind.agent,
        name: 'test',
        path: 'test.md',
      );
      expect(a, isNot(equals(b)));
    });

    test('copyWith creates a new instance with overridden fields', () {
      const original = WorkspaceAsset(
        id: 'agent:test',
        kind: AssetKind.agent,
        name: 'test',
        path: 'test.md',
      );
      final copied = original.copyWith(
        description: 'updated description',
        canonicality: Canonicality.mock,
      );
      expect(copied.id, original.id);
      expect(copied.description, 'updated description');
      expect(copied.canonicality, Canonicality.mock);
    });
  });

  group('WorkspaceEdge', () {
    test('can be constructed with required fields', () {
      const edge = WorkspaceEdge(
        sourceId: 'agent:a',
        targetId: 'skill:b',
        kind: EdgeKind.uses,
      );
      expect(edge.sourceId, 'agent:a');
      expect(edge.targetId, 'skill:b');
      expect(edge.kind, EdgeKind.uses);
      expect(edge.metadata, isEmpty);
    });

    test('supports all EdgeKind values', () {
      for (final kind in EdgeKind.values) {
        final edge = WorkspaceEdge(sourceId: 'a', targetId: 'b', kind: kind);
        expect(edge.kind, kind);
      }
    });

    test('equality is based on sourceId, targetId, kind', () {
      const a = WorkspaceEdge(
        sourceId: 'a',
        targetId: 'b',
        kind: EdgeKind.contains,
        metadata: {'weight': 1},
      );
      const b = WorkspaceEdge(
        sourceId: 'a',
        targetId: 'b',
        kind: EdgeKind.contains,
        metadata: {'weight': 2},
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('inequality on different kind', () {
      const a = WorkspaceEdge(
        sourceId: 'a',
        targetId: 'b',
        kind: EdgeKind.contains,
      );
      const b = WorkspaceEdge(
        sourceId: 'a',
        targetId: 'b',
        kind: EdgeKind.dependsOn,
      );
      expect(a, isNot(equals(b)));
    });
  });

  group('TaskLane', () {
    test('has exactly 5 values', () {
      expect(TaskLane.values.length, 5);
    });

    test('parses from directory prefix', () {
      expect(
        TaskLaneParsing.fromDirectoryPrefix('00-planning'),
        TaskLane.planning,
      );
      expect(TaskLaneParsing.fromDirectoryPrefix('02-doing'), TaskLane.doing);
      expect(
        TaskLaneParsing.fromDirectoryPrefix('04-completed'),
        TaskLane.completed,
      );
      expect(TaskLaneParsing.fromDirectoryPrefix('unknown'), TaskLane.open);
    });

    test('round-trips directory prefix', () {
      for (final lane in TaskLane.values) {
        expect(TaskLaneParsing.fromDirectoryPrefix(lane.directoryPrefix), lane);
      }
    });
  });

  group('ProofState', () {
    test('has exactly 4 values', () {
      expect(ProofState.values.length, 4);
    });

    test('parses from string', () {
      expect(ProofStateParsing.fromString('none'), ProofState.none);
      expect(ProofStateParsing.fromString('partial'), ProofState.partial);
      expect(ProofStateParsing.fromString('complete'), ProofState.complete);
      expect(ProofStateParsing.fromString('verified'), ProofState.verified);
      expect(ProofStateParsing.fromString(null), ProofState.none);
      expect(ProofStateParsing.fromString('invalid'), ProofState.none);
    });
  });

  group('TaskMetadata', () {
    test('can be constructed with required fields', () {
      final task = TaskMetadata(
        id: '0310',
        title: 'Backbone Model Contract Audit',
        created: DateTime(2026, 6, 7),
        updated: DateTime(2026, 6, 7),
      );
      expect(task.id, '0310');
      expect(task.lane, TaskLane.open);
      expect(task.proofState, ProofState.none);
      expect(task.reviewScore, isNull);
    });

    test('equality is based on id, lane, proofState', () {
      final a = TaskMetadata(
        id: '0310',
        title: 'Task A',
        created: DateTime(2026, 6, 7),
        updated: DateTime(2026, 6, 7),
      );
      final b = TaskMetadata(
        id: '0310',
        title: 'Task B',
        created: DateTime(2026, 1, 1),
        updated: DateTime(2026, 1, 1),
      );
      expect(a, equals(b));
    });
  });

  group('ChangelogMetadata', () {
    test('can be constructed with required fields', () {
      final cl = ChangelogMetadata(
        id: '2026-06-07-0310-backbone',
        date: DateTime(2026, 6, 7),
        project: 'warp-prism',
        task: '0310',
      );
      expect(cl.id, '2026-06-07-0310-backbone');
      expect(cl.type, ChangelogType.chore);
      expect(cl.impact, isEmpty);
    });

    test('ChangelogType parses from string', () {
      expect(ChangelogTypeParsing.fromString('feature'), ChangelogType.feature);
      expect(
        ChangelogTypeParsing.fromString('governance'),
        ChangelogType.governance,
      );
      expect(ChangelogTypeParsing.fromString(null), ChangelogType.chore);
    });
  });

  group('GovernanceDiagnostic', () {
    test('can be constructed with required fields', () {
      final diag = GovernanceDiagnostic(
        assetId: 'skill:test',
        severity: DiagnosticSeverity.warning,
        category: DiagnosticCategory.orphanAsset,
        message: 'Asset has no incoming edges',
        computedAt: DateTime(2026, 6, 7),
      );
      expect(diag.assetId, 'skill:test');
      expect(diag.severity, DiagnosticSeverity.warning);
      expect(diag.category, DiagnosticCategory.orphanAsset);
    });

    test('severity weight ordering', () {
      expect(
        DiagnosticSeverity.info.weight,
        lessThan(DiagnosticSeverity.warning.weight),
      );
      expect(
        DiagnosticSeverity.warning.weight,
        lessThan(DiagnosticSeverity.error.weight),
      );
      expect(
        DiagnosticSeverity.error.weight,
        lessThan(DiagnosticSeverity.critical.weight),
      );
    });

    test('DiagnosticCategory has all required categories', () {
      const required = [
        'orphanAsset',
        'staleReference',
        'proofGap',
        'reviewPressure',
        'canonicalityDrift',
        'missingDependency',
        'brokenEdge',
        'staleIndex',
        'childParentDrift',
      ];
      final names = DiagnosticCategory.values.map((e) => e.name).toList();
      for (final r in required) {
        expect(names, contains(r), reason: 'DiagnosticCategory missing: $r');
      }
    });
  });
}
