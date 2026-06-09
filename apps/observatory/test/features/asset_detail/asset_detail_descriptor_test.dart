/// Unit tests for the universal asset detail descriptor (Task 0902).
///
/// Covers:
/// - Descriptor shared sections (identity, metadata, body, links)
/// - Incoming/outgoing edge derivation
/// - Related assets from edges
/// - Unsupported-kind fallback
/// - Empty/unresolved asset fallback
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_observatory/data/models/workspace_graph.dart';
import 'package:warp_prism_observatory/features/asset_detail/domain/asset_detail_descriptor.dart';
import 'package:warp_prism_observatory/features/asset_detail/application/asset_detail_mapper.dart';
import 'package:warp_prism_observatory/features/asset_detail/application/asset_detail_controller.dart';

// ---------------------------------------------------------------------------
// Test Fixtures
// ---------------------------------------------------------------------------

WorkspaceAsset _agentAsset() => const WorkspaceAsset(
      id: 'agent:test-orchestrator',
      kind: AssetKind.agent,
      name: 'Test Orchestrator',
      path: 'agents/test-orchestrator.md',
      description: 'An agent that orchestrates test workflows.',
      canonicality: Canonicality.parentCanonical,
      frontmatter: {
        'version': '2.0.0',
        'status': 'active',
        'model': {'provider': 'openai', 'name': 'gpt-4'},
      },
      tags: ['orchestration', 'testing'],
    );

WorkspaceAsset _skillAsset() => const WorkspaceAsset(
      id: 'skill:test-runner',
      kind: AssetKind.skill,
      name: 'Test Runner',
      path: 'skills/test-runner.md',
      description: 'Runs test suites and reports results.',
      canonicality: Canonicality.parentCanonical,
      frontmatter: {
        'version': '1.5.0',
      },
      tags: ['testing'],
      triggers: ['run tests', 'execute tests'],
    );

WorkspaceAsset _taskAsset() => const WorkspaceAsset(
      id: 'task:0902',
      kind: AssetKind.task,
      name: 'Universal Asset Detail View Model',
      path: 'docs/tasks/01-open/0902.md',
      description: 'Create the universal asset detail domain.',
      canonicality: Canonicality.parentCanonical,
      frontmatter: {
        'priority': 'P1',
        'lane': 'doing',
        'status': 'open',
      },
    );

WorkspaceAsset _changelogAsset() => const WorkspaceAsset(
      id: 'changelog:2026-06-07-task-0902',
      kind: AssetKind.changelog,
      name: 'Task 0902 Changelog',
      path: 'docs/changelog/2026-06-07-task-0902.md',
      description: 'Changelog entry for task 0902.',
      canonicality: Canonicality.appendOnly,
    );

WorkspaceAsset _scriptAsset() => const WorkspaceAsset(
      id: 'script:setup.sh',
      kind: AssetKind.script,
      name: 'Setup Script',
      path: 'scripts/setup.sh',
      description: 'A setup script.',
    );

List<WorkspaceEdge> _testEdges() => [
      const WorkspaceEdge(
        sourceId: 'agent:test-orchestrator',
        targetId: 'skill:test-runner',
        kind: EdgeKind.uses,
      ),
      const WorkspaceEdge(
        sourceId: 'task:0902',
        targetId: 'skill:test-runner',
        kind: EdgeKind.dependsOn,
      ),
      const WorkspaceEdge(
        sourceId: 'changelog:2026-06-07-task-0902',
        targetId: 'task:0902',
        kind: EdgeKind.changedBy,
      ),
    ];

Map<String, WorkspaceAsset> _testAssetIndex() {
  final assets = [
    _agentAsset(),
    _skillAsset(),
    _taskAsset(),
    _changelogAsset(),
  ];
  return buildAssetIndex(assets);
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('AssetDetailDescriptor', () {
    test('has shared sections for supported kind', () {
      final result = resolveAssetDetail(
        assetId: 'agent:test-orchestrator',
        assetIndex: _testAssetIndex(),
        allEdges: _testEdges(),
      );
      final desc = result.descriptor;

      expect(desc.asset.id, 'agent:test-orchestrator');
      expect(desc.asset.name, 'Test Orchestrator');
      expect(desc.asset.kind, AssetKind.agent);
      expect(desc.isFallback, isFalse);
      expect(desc.sharedSections, isNotEmpty);
    });

    test('fallback descriptor for unsupported kind', () {
      final assetIndex = {
        ..._testAssetIndex(),
        'script:setup.sh': _scriptAsset(),
      };
      final result = resolveAssetDetail(
        assetId: 'script:setup.sh',
        assetIndex: assetIndex,
        allEdges: _testEdges(),
      );

      expect(result.isFallback, isTrue);
      expect(result.descriptor.isFallback, isTrue);
    });

    test('fallback descriptor for unknown asset ID', () {
      final result = resolveAssetDetail(
        assetId: 'agent:nonexistent',
        assetIndex: _testAssetIndex(),
        allEdges: _testEdges(),
      );

      expect(result.isFallback, isTrue);
      expect(result.descriptor.asset.id, 'agent:nonexistent');
    });

    test('fallback descriptor for empty asset ID', () {
      final result = resolveAssetDetail(
        assetId: '',
        assetIndex: _testAssetIndex(),
        allEdges: _testEdges(),
      );

      expect(result.isFallback, isTrue);
      expect(result.resolved, isFalse);
    });

    test('fallback descriptor for "unknown" asset ID', () {
      final result = resolveAssetDetail(
        assetId: 'unknown',
        assetIndex: _testAssetIndex(),
        allEdges: _testEdges(),
      );

      expect(result.isFallback, isTrue);
      expect(result.resolved, isFalse);
    });
  });

  group('Descriptor identity section', () {
    test('contains identity section with path and provenance', () {
      final result = resolveAssetDetail(
        assetId: 'agent:test-orchestrator',
        assetIndex: _testAssetIndex(),
        allEdges: _testEdges(),
      );
      final identitySections = result.descriptor.sharedSections
          .where((s) => s.key == 'identity');
      expect(identitySections, isNotEmpty);

      final identity = identitySections.first;
      final labels = identity.properties.map((p) => p.label).toList();
      expect(labels, contains('ID'));
      expect(labels, contains('Path'));
      expect(labels, contains('Provenance'));
    });

    test('kind matches asset kind', () {
      final result = resolveAssetDetail(
        assetId: 'skill:test-runner',
        assetIndex: _testAssetIndex(),
        allEdges: _testEdges(),
      );

      expect(result.descriptor.asset.kind, AssetKind.skill);
    });
  });

  group('Descriptor metadata section', () {
    test('includes frontmatter metadata', () {
      final result = resolveAssetDetail(
        assetId: 'agent:test-orchestrator',
        assetIndex: _testAssetIndex(),
        allEdges: _testEdges(),
      );
      // The mapper builds metadata sections from frontmatter
      final allProps = result.descriptor.allSections
          .expand((s) => s.properties)
          .toList();
      final labels = allProps.map((p) => p.label).toList();

      // Agent should have version, status from frontmatter
      expect(labels, contains('version'));
      expect(labels, contains('status'));
    });

    test('includes task-specific fields', () {
      final result = resolveAssetDetail(
        assetId: 'task:0902',
        assetIndex: _testAssetIndex(),
        allEdges: _testEdges(),
      );
      final allProps = result.descriptor.allSections
          .expand((s) => s.properties)
          .toList();
      final labels = allProps.map((p) => p.label).toList();

      expect(labels, contains('priority'));
      expect(labels, contains('lane'));
    });

    test('includes trigger phrases for skills', () {
      final result = resolveAssetDetail(
        assetId: 'skill:test-runner',
        assetIndex: _testAssetIndex(),
        allEdges: _testEdges(),
      );
      final allProps = result.descriptor.allSections
          .expand((s) => s.properties)
          .toList();
      final triggerProp =
          allProps.where((p) => p.label == 'Triggers');

      expect(triggerProp, isNotEmpty);
      expect(triggerProp.first.value, contains('run tests'));
    });
  });

  group('Descriptor body summary', () {
    test('contains asset description in identity section', () {
      final result = resolveAssetDetail(
        assetId: 'agent:test-orchestrator',
        assetIndex: _testAssetIndex(),
        allEdges: _testEdges(),
      );
      final identitySections = result.descriptor.sharedSections
          .where((s) => s.key == 'identity');
      expect(identitySections, isNotEmpty);

      final descProp = identitySections.first.properties
          .where((p) => p.label == 'Description');
      expect(descProp, isNotEmpty);
      expect(descProp.first.value, contains('orchestrates test'));
    });
  });

  group('Descriptor incoming/outgoing links', () {
    test('skill:test-runner has two incoming links', () {
      final result = resolveAssetDetail(
        assetId: 'skill:test-runner',
        assetIndex: _testAssetIndex(),
        allEdges: _testEdges(),
      );

      expect(result.descriptor.incomingLinks.length, 2);
    });

    test('incoming link has correct target ID and kind', () {
      final result = resolveAssetDetail(
        assetId: 'skill:test-runner',
        assetIndex: _testAssetIndex(),
        allEdges: _testEdges(),
      );
      final usesLink = result.descriptor.incomingLinks
          .firstWhere((l) => l.kind == 'uses');

      expect(usesLink.targetId, 'agent:test-orchestrator');
      expect(usesLink.label, 'Test Orchestrator');
    });

    test('outgoing link resolves name from asset index', () {
      final result = resolveAssetDetail(
        assetId: 'agent:test-orchestrator',
        assetIndex: _testAssetIndex(),
        allEdges: _testEdges(),
      );

      expect(result.descriptor.outgoingLinks.length, 1);
      expect(result.descriptor.outgoingLinks.first.label, 'Test Runner');
    });

    test('related assets combines incoming and outgoing', () {
      final result = resolveAssetDetail(
        assetId: 'task:0902',
        assetIndex: _testAssetIndex(),
        allEdges: _testEdges(),
      );

      // task:0902 has 1 outgoing (dependsOn skill:test-runner)
      // and 1 incoming (changedBy changelog:...)
      expect(result.descriptor.totalLinkCount, 2);
    });

    test('unknown target resolves to ID in link label', () {
      final edges = [
        const WorkspaceEdge(
          sourceId: 'agent:test-orchestrator',
          targetId: 'skill:nonexistent',
          kind: EdgeKind.uses,
        ),
      ];
      final result = resolveAssetDetail(
        assetId: 'agent:test-orchestrator',
        assetIndex: _testAssetIndex(),
        allEdges: edges,
      );

      expect(result.descriptor.outgoingLinks.length, 1);
      expect(result.descriptor.outgoingLinks.first.label, 'skill:nonexistent');
    });
  });

  group('Descriptor tags', () {
    test('includes tags from asset', () {
      final result = resolveAssetDetail(
        assetId: 'agent:test-orchestrator',
        assetIndex: _testAssetIndex(),
        allEdges: _testEdges(),
      );

      expect(result.descriptor.asset.tags, contains('orchestration'));
      expect(result.descriptor.asset.tags, contains('testing'));
    });
  });

  group('AssetDetailResult', () {
    test('resolved is true for supported kind', () {
      final result = resolveAssetDetail(
        assetId: 'agent:test-orchestrator',
        assetIndex: _testAssetIndex(),
        allEdges: _testEdges(),
      );

      expect(result.resolved, isTrue);
      expect(result.isFallback, isFalse);
    });

    test('resolved is false for unknown asset', () {
      final result = resolveAssetDetail(
        assetId: 'agent:nonexistent',
        assetIndex: _testAssetIndex(),
        allEdges: _testEdges(),
      );

      expect(result.resolved, isFalse);
      expect(result.isFallback, isTrue);
    });
  });

  group('buildAssetIndex', () {
    test('indexes assets by ID', () {
      final assets = [_agentAsset(), _skillAsset()];
      final index = buildAssetIndex(assets);

      expect(index.length, 2);
      expect(index.containsKey('agent:test-orchestrator'), isTrue);
      expect(index.containsKey('skill:test-runner'), isTrue);
    });
  });

  group('AssetDetailDescriptor.fallback', () {
    test('creates fallback with defaults', () {
      final asset = _scriptAsset();
      final desc = AssetDetailDescriptor.fallback(asset: asset);

      expect(desc.isFallback, isTrue);
      expect(desc.asset.id, 'script:setup.sh');
      expect(desc.fallbackMessage, isNotNull);
      expect(desc.sharedSections, isNotEmpty);
    });

    test('creates fallback with custom message', () {
      final asset = _scriptAsset();
      final desc = AssetDetailDescriptor.fallback(
        asset: asset,
        message: 'Custom reason',
      );

      expect(desc.fallbackMessage, 'Custom reason');
    });
  });

  group('buildAssetDetailDescriptor', () {
    test('produces descriptor with shared sections for agent', () {
      final asset = _agentAsset();
      final names = {
        'agent:test-orchestrator': 'Test Orchestrator',
        'skill:test-runner': 'Test Runner',
      };
      final desc = buildAssetDetailDescriptor(
        asset: asset,
        incoming: [],
        outgoing: _testEdges()
            .where((e) => e.sourceId == 'agent:test-orchestrator')
            .toList(),
        assetNames: names,
      );

      expect(desc.isFallback, isFalse);
      expect(desc.sharedSections, isNotEmpty);
      expect(desc.outgoingLinks.length, 1);
      expect(desc.outgoingLinks.first.label, 'Test Runner');
    });

    test('produces descriptor with shared sections for task', () {
      final asset = _taskAsset();
      final names = {
        'task:0902': 'Universal Asset Detail View Model',
        'skill:test-runner': 'Test Runner',
      };
      final desc = buildAssetDetailDescriptor(
        asset: asset,
        incoming: _testEdges()
            .where((e) => e.targetId == 'task:0902')
            .toList(),
        outgoing: _testEdges()
            .where((e) => e.sourceId == 'task:0902')
            .toList(),
        assetNames: names,
      );

      expect(desc.isFallback, isFalse);
      expect(desc.sharedSections, isNotEmpty);
      expect(desc.incomingLinks.length, 1);
      expect(desc.outgoingLinks.length, 1);
    });

    test('produces fallback for script kind', () {
      final asset = _scriptAsset();
      final desc = buildAssetDetailDescriptor(
        asset: asset,
        incoming: [],
        outgoing: [],
        assetNames: {},
      );

      expect(desc.isFallback, isTrue);
    });

    test('produces descriptor for changelog kind', () {
      final asset = _changelogAsset();
      final names = {
        'changelog:2026-06-07-task-0902': 'Task 0902 Changelog',
        'task:0902': 'Universal Asset Detail View Model',
      };
      final desc = buildAssetDetailDescriptor(
        asset: asset,
        incoming: [],
        outgoing: _testEdges()
            .where(
                (e) => e.sourceId == 'changelog:2026-06-07-task-0902')
            .toList(),
        assetNames: names,
      );

      expect(desc.isFallback, isFalse);
      expect(desc.sharedSections, isNotEmpty);
    });
  });
}
