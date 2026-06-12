/// Tests for Map selection synchronization and inspector integration.
///
/// Covers:
/// - Single shared selection state between catalog and graph
/// - Selection from card tap and graph node tap converge on same state
/// - Inspector renders selected asset with identity, governance, relationships
/// - Deselect/clear selection returns to no-selection state
/// - Edge case: selected asset disappears after tab change
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_observatory/data/models/workspace_graph.dart';
import 'package:warp_prism_observatory/features/map/map_workspace_state.dart';
import 'package:warp_prism_observatory/features/map/map_workspace_provider.dart';
import 'package:warp_prism_observatory/features/map/map_selection_controller.dart';
import 'package:warp_prism_observatory/features/map/widgets/map_inspector_panel.dart';

/// Test assets for selection testing.
final _testAssets = [
  const WorkspaceAsset(
    id: 'agent:orchestrator',
    kind: AssetKind.agent,
    name: 'Architect Orchestrator',
    path: '.agents/agents/orchestrator.md',
    description: 'Main orchestration agent',
    canonicality: Canonicality.parentCanonical,
    tags: ['core', 'orchestration'],
    edges: [
      WorkspaceEdge(
        sourceId: 'agent:orchestrator',
        targetId: 'skill:harness',
        kind: EdgeKind.uses,
      ),
    ],
    frontmatter: {'owner': 'builder', 'status': 'active'},
  ),
  const WorkspaceAsset(
    id: 'skill:harness',
    kind: AssetKind.skill,
    name: 'Test Harness',
    path: '.agents/skills/harness.md',
    description: 'Testing framework skill',
    canonicality: Canonicality.parentCanonical,
    tags: ['testing', 'core'],
    triggers: ['run tests', 'test harness'],
    edges: [
      WorkspaceEdge(
        sourceId: 'skill:harness',
        targetId: 'workflow:ci',
        kind: EdgeKind.contains,
      ),
    ],
  ),
  const WorkspaceAsset(
    id: 'workflow:ci',
    kind: AssetKind.workflow,
    name: 'CI Pipeline',
    path: '.agents/workflows/ci.md',
    description: 'Continuous integration workflow',
    canonicality: Canonicality.parentCanonical,
    tags: ['ci', 'automation'],
  ),
];

void main() {
  Widget wrapInApp(Widget child) {
    return MaterialApp(
      home: Scaffold(body: SizedBox(width: 800, height: 600, child: child)),
    );
  }

  // ===========================================================================
  // MapSelectionController - unit tests
  // ===========================================================================
  group('MapSelectionController', () {
    late MapWorkspaceProvider provider;
    late MapSelectionController controller;

    setUp(() {
      provider = MapWorkspaceProvider(
        initialState: MapWorkspaceState(catalogAssets: _testAssets),
      );
      controller = MapSelectionController(provider);
    });

    tearDown(() {
      provider.dispose();
    });

    test('initially has no selection', () {
      expect(controller.hasSelection, isFalse);
      expect(controller.selectedAssetId, isNull);
      expect(controller.selectedAsset, isNull);
      expect(controller.buildInspectorSections(), isEmpty);
    });

    test('selectAsset sets selection from catalog tap', () {
      controller.selectAsset('agent:orchestrator');

      expect(controller.hasSelection, isTrue);
      expect(controller.selectedAssetId, 'agent:orchestrator');
      expect(controller.selectedAsset?.name, 'Architect Orchestrator');
    });

    test('selectAsset sets selection from graph node tap (same id)', () {
      // Simulate graph node tap with the same id as a catalog card tap
      controller.selectAsset('agent:orchestrator');

      expect(controller.selectedAssetId, 'agent:orchestrator');
      expect(controller.selectedAsset?.kind, AssetKind.agent);
    });

    test('selecting same asset twice is idempotent', () {
      controller.selectAsset('skill:harness');
      controller.selectAsset('skill:harness');

      expect(controller.selectedAssetId, 'skill:harness');
      expect(controller.selectedAsset?.name, 'Test Harness');
    });

    test('deselectAsset clears selection', () {
      controller.selectAsset('agent:orchestrator');
      expect(controller.hasSelection, isTrue);

      controller.deselectAsset();
      expect(controller.hasSelection, isFalse);
      expect(controller.selectedAssetId, isNull);
      expect(controller.selectedAsset, isNull);
    });

    test('selecting a different asset replaces the previous selection', () {
      controller.selectAsset('agent:orchestrator');
      controller.selectAsset('workflow:ci');

      expect(controller.selectedAssetId, 'workflow:ci');
      expect(controller.selectedAsset?.name, 'CI Pipeline');
    });

    test('selectedAsset returns null for nonexistent id', () {
      controller.selectAsset('nonexistent:id');
      expect(controller.selectedAsset, isNull);
    });

    test('buildInspectorSections returns sections for selected asset', () {
      controller.selectAsset('agent:orchestrator');
      final sections = controller.buildInspectorSections();

      // Should have at least: Identity, Governance, Relationships, Operational
      expect(sections.length, greaterThanOrEqualTo(3));

      // Identity section
      final identity = sections.firstWhere((s) => s.title == 'Identity');
      expect(identity.rows.any((r) => r.value == 'agent:orchestrator'), isTrue);
      expect(identity.rows.any((r) => r.value == 'agent'), isTrue);
      expect(
        identity.rows.any((r) => r.value == 'Architect Orchestrator'),
        isFalse,
      );
      // name goes in the inspector header, not sections
    });

    test('buildInspectorSections includes governance for canonicality', () {
      controller.selectAsset('skill:harness');
      final sections = controller.buildInspectorSections();

      final gov = sections.firstWhere((s) => s.title == 'Governance');
      expect(gov.rows.any((r) => r.value == 'canonical'), isTrue);
      expect(gov.rows.any((r) => r.label == 'Tags'), isTrue);
    });

    test('buildInspectorSections includes triggers for skills', () {
      controller.selectAsset('skill:harness');
      final sections = controller.buildInspectorSections();

      final triggers = sections.firstWhere((s) => s.title == 'Triggers');
      expect(triggers.count, 2);
      expect(triggers.rows.length, 2);
    });

    test('buildInspectorSections includes relationships when edges exist', () {
      controller.selectAsset('agent:orchestrator');
      final sections = controller.buildInspectorSections();

      final rels = sections.firstWhere((s) => s.title == 'Relationships');
      expect(rels.count, 1);
      expect(rels.rows.first.value.contains('skill:harness'), isTrue);
    });

    test(
      'buildInspectorSections includes operational hints from frontmatter',
      () {
        controller.selectAsset('agent:orchestrator');
        final sections = controller.buildInspectorSections();

        final ops = sections.firstWhere((s) => s.title == 'Operational');
        expect(
          ops.rows.any((r) => r.label == 'Owner' && r.value == 'builder'),
          isTrue,
        );
        expect(
          ops.rows.any((r) => r.label == 'Status' && r.value == 'active'),
          isTrue,
        );
      },
    );

    test('buildInspectorSections empty when nothing selected', () {
      expect(controller.buildInspectorSections(), isEmpty);
    });
  });

  // ===========================================================================
  // MapSelectionController - synchronized state
  // ===========================================================================
  group('MapSelectionController - synchronized state', () {
    late MapWorkspaceProvider provider;
    late MapSelectionController controller;

    setUp(() {
      provider = MapWorkspaceProvider(
        initialState: MapWorkspaceState(catalogAssets: _testAssets),
      );
      controller = MapSelectionController(provider);
    });

    tearDown(() {
      provider.dispose();
    });

    test('catalog tap and graph tap on same asset produce identical state', () {
      // Simulate: user taps card in catalog
      controller.selectAsset('agent:orchestrator');
      final stateFromCatalog = provider.state.selectedAssetId;

      // Clear and simulate: user taps same node in graph
      controller.deselectAsset();
      controller.selectAsset('agent:orchestrator');
      final stateFromGraph = provider.state.selectedAssetId;

      expect(stateFromCatalog, stateFromGraph);
      expect(stateFromCatalog, 'agent:orchestrator');
    });

    test('selection is visible in provider state stream', () async {
      final states = <MapWorkspaceState>[];
      final sub = provider.stateStream.listen(states.add);

      controller.selectAsset('skill:harness');
      controller.deselectAsset();

      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      expect(states, hasLength(2));
      expect(states[0].selectedAssetId, 'skill:harness');
      expect(states[1].selectedAssetId, isNull);
    });

    test('tab change clears selection via provider', () {
      controller.selectAsset('agent:orchestrator');
      expect(controller.hasSelection, isTrue);

      provider.changeSubview(MapSubview.skills);
      expect(controller.hasSelection, isFalse);
    });
  });

  // ===========================================================================
  // MapInspectorPanel widget
  // ===========================================================================
  group('MapInspectorPanel widget', () {
    testWidgets('shows no-selection state when nothing selected', (
      tester,
    ) async {
      final provider = MapWorkspaceProvider(
        initialState: MapWorkspaceState(catalogAssets: _testAssets),
      );
      final controller = MapSelectionController(provider);

      await tester.pumpWidget(
        wrapInApp(MapInspectorPanel(controller: controller)),
      );

      expect(find.text('No asset selected'), findsOneWidget);
      provider.dispose();
    });

    testWidgets('shows inspector with asset name when selected', (
      tester,
    ) async {
      final provider = MapWorkspaceProvider(
        initialState: MapWorkspaceState(catalogAssets: _testAssets),
      );
      final controller = MapSelectionController(provider);
      controller.selectAsset('agent:orchestrator');

      await tester.pumpWidget(
        wrapInApp(MapInspectorPanel(controller: controller)),
      );

      expect(find.text('Architect Orchestrator'), findsOneWidget);
      expect(find.text('AGENT'), findsOneWidget);
      provider.dispose();
    });

    testWidgets('shows close button and handles close', (tester) async {
      final provider = MapWorkspaceProvider(
        initialState: MapWorkspaceState(catalogAssets: _testAssets),
      );
      final controller = MapSelectionController(provider);
      controller.selectAsset('workflow:ci');

      var closed = false;
      await tester.pumpWidget(
        wrapInApp(
          MapInspectorPanel(
            controller: controller,
            onClose: () {
              closed = true;
              controller.deselectAsset();
            },
          ),
        ),
      );

      expect(find.text('CI Pipeline'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();
      expect(closed, isTrue);
      provider.dispose();
    });

    testWidgets('switches from selected to no-selection when cleared', (
      tester,
    ) async {
      final provider = MapWorkspaceProvider(
        initialState: MapWorkspaceState(catalogAssets: _testAssets),
      );
      final controller = MapSelectionController(provider);
      controller.selectAsset('skill:harness');

      await tester.pumpWidget(
        wrapInApp(MapInspectorPanel(controller: controller)),
      );

      expect(find.text('Test Harness'), findsOneWidget);

      // Clear selection
      controller.deselectAsset();
      await tester.pump();

      expect(find.text('No asset selected'), findsWidgets);
      provider.dispose();
    });
  });
}
