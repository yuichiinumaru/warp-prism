import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_catalog/main.dart';
import 'package:warp_prism_runtime/warp_prism_runtime.dart';
import 'package:warp_prism_testkit/warp_prism_testkit.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

void main() {
  group('ConnectedBridgeLabPage — Fallback Mode Proofs', () {
    testWidgets('gracefully degrades to fixture mode when bridge init throws', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: PrismTheme.dark(),
          home: ConnectedBridgeLabPage(
            enablePhysics: false,
            bridgeInit: () async {
              throw StateError('libwarp_bridge_frb.so not found');
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Heading and badges rendered
      expect(find.text('Connected Bridge Lab'), findsOneWidget);
      expect(find.text('FIXTURE MODE (FAKE)'), findsOneWidget);
      expect(
        find.text(
          'Bridge unavailable — fixture mode (offline fallback active)',
        ),
        findsOneWidget,
      );

      // Graph organism rendered with initial fixture nodes
      expect(find.byType(PrismGraphCanvas), findsOneWidget);
      expect(find.text('Nodes: 3'), findsOneWidget);
      expect(find.text('Edges: 2'), findsOneWidget);
      expect(find.text('Rust FFI: OFFLINE'), findsOneWidget);

      // Interactive mutation: clicking Add Fixture Node updates the graph
      final addBtn = find.text('Add Fixture Node');
      expect(addBtn, findsOneWidget);

      await tester.tap(addBtn);
      await tester.pumpAndSettle();

      expect(find.text('Nodes: 4'), findsOneWidget);
    });
  });

  group('ConnectedBridgeLabPage — Injected Source Proofs', () {
    testWidgets('projects injected FakeGraphSource through binding to canvas', (
      tester,
    ) async {
      final fakeSource = FakeGraphSource<String, String>(
        initialNodes: [
          const GraphNode<String>(
            id: 'node-inj-1',
            kind: 'agent',
            label: 'Builder Agent',
            status: 'active',
            payload: 'p1',
          ),
          const GraphNode<String>(
            id: 'node-inj-2',
            kind: 'skill',
            label: 'Rust Bridge Skill',
            status: 'ready',
            payload: 'p2',
          ),
        ],
        initialEdges: [
          const GraphEdge<String>(
            id: 'edge-inj-1',
            kind: 'depends_on',
            fromNodeId: 'node-inj-1',
            toNodeId: 'node-inj-2',
            payload: 'e1',
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: PrismTheme.dark(),
          home: ConnectedBridgeLabPage(
            source: fakeSource,
            enablePhysics: false,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Connected Bridge Lab'), findsOneWidget);
      expect(find.text('Nodes: 2'), findsOneWidget);
      expect(find.text('Edges: 1'), findsOneWidget);
      expect(find.byType(PrismGraphCanvas), findsOneWidget);

      // External stream mutation flows into UI
      fakeSource.addNode(
        const GraphNode<String>(
          id: 'node-inj-3',
          kind: 'workflow',
          label: 'Parity Workflow',
          status: 'running',
          payload: 'p3',
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Nodes: 3'), findsOneWidget);

      // UI button triggers mutation on injected source
      final addBtn = find.text('Add Fixture Node');
      await tester.tap(addBtn);
      await tester.pumpAndSettle();

      expect(find.text('Nodes: 4'), findsOneWidget);
    });

    testWidgets('relayout button triggers binding relayout without error', (
      tester,
    ) async {
      final fakeSource = FakeGraphSource<String, String>(
        initialNodes: [
          const GraphNode<String>(
            id: 'n1',
            kind: 'agent',
            label: 'N1',
            payload: 'p1',
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: PrismTheme.dark(),
          home: ConnectedBridgeLabPage(
            source: fakeSource,
            enablePhysics: false,
          ),
        ),
      );

      await tester.pumpAndSettle();

      final relayoutBtn = find.text('Relayout Circle');
      expect(relayoutBtn, findsOneWidget);

      await tester.tap(relayoutBtn);
      await tester.pumpAndSettle();

      expect(find.text('Nodes: 1'), findsOneWidget);
    });
  });

  group('Catalog Navigation & Section Registration', () {
    testWidgets('switches between ADS Gallery and Connected Bridge Lab', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final fakeSource = FakeGraphSource<String, String>(
        initialNodes: [
          const GraphNode<String>(
            id: 'test-node-1',
            kind: 'agent',
            label: 'Lab Agent',
            payload: 'data',
          ),
        ],
      );

      await tester.pumpWidget(
        WarpPrismCatalogApp(
          initialSectionIndex: 0,
          connectedSource: fakeSource,
          enablePhysics: false,
        ),
      );
      await tester.pumpAndSettle();

      // Section 0: ADS Gallery mounted
      expect(find.byType(DesignSystemGalleryPage), findsOneWidget);
      expect(find.text('ADS Gallery'), findsOneWidget);
      expect(find.text('STATIC / INTERACTIVE'), findsOneWidget);
      expect(find.text('Connected Bridge Lab'), findsOneWidget);
      expect(find.text('CONNECTED'), findsOneWidget);

      // Switch to Section 1: Connected Bridge Lab
      final connectedNavTab = find.byKey(
        const Key('catalog-nav-connected-lab'),
      );
      expect(connectedNavTab, findsOneWidget);

      await tester.tap(connectedNavTab);
      await tester.pumpAndSettle();

      // Section 1: ConnectedBridgeLabPage mounted
      expect(find.byType(ConnectedBridgeLabPage), findsOneWidget);
      expect(find.text('Nodes: 1'), findsOneWidget);

      // Switch back to Section 0: ADS Gallery
      final galleryNavTab = find.byKey(const Key('catalog-nav-gallery'));
      expect(galleryNavTab, findsOneWidget);

      await tester.tap(galleryNavTab);
      await tester.pumpAndSettle();

      expect(find.byType(DesignSystemGalleryPage), findsOneWidget);
    });
  });
}
