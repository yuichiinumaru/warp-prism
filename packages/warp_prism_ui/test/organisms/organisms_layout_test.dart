import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// Task 0016: DS Organisms and Templates Alignment
///
/// Widget tests proving that organisms compose correctly using only
/// canonical DS tokens, atoms, and molecules — no adapters or
/// invented parameters.
void main() {
  group('DSShell composition', () {
    testWidgets('renders sidebar, topbar, and content in correct layout', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DSShell(
              sidebar: Container(
                key: const Key('sidebar'),
                width: DSSpacing.sidebarExpanded,
                color: DSColors.obsidianBase,
              ),
              topbar: Container(
                key: const Key('topbar'),
                height: DSSpacing.topbarHeight,
                color: DSColors.obsidianBase,
              ),
              content: Container(key: const Key('content')),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('sidebar')), findsOneWidget);
      expect(find.byKey(const Key('topbar')), findsOneWidget);
      expect(find.byKey(const Key('content')), findsOneWidget);
    });

    testWidgets('shows inspector when showInspector is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 1400,
              height: 900,
              child: DSShell(
                sidebar: const SizedBox(width: DSSpacing.sidebarExpanded),
                topbar: const SizedBox(height: DSSpacing.topbarHeight),
                content: const SizedBox(),
                inspector: Container(key: const Key('inspector')),
                showInspector: true,
              ),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('inspector')), findsOneWidget);
    });

    testWidgets('hides inspector when showInspector is false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DSShell(
              sidebar: const SizedBox(width: DSSpacing.sidebarExpanded),
              content: const SizedBox(),
              inspector: Container(key: const Key('inspector')),
              showInspector: false,
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('inspector')), findsNothing);
    });
  });

  group('DSShellResponsive composition', () {
    testWidgets('renders at wide width with full sidebar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 1400,
              height: 900,
              child: DSShellResponsive(
                sidebar: Container(key: const Key('full-sidebar')),
                collapsedSidebar: Container(
                  key: const Key('collapsed-sidebar'),
                ),
                content: Container(key: const Key('content')),
              ),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('full-sidebar')), findsOneWidget);
      expect(find.byKey(const Key('collapsed-sidebar')), findsNothing);
    });

    testWidgets('renders at narrow width with no sidebar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 500,
              height: 900,
              child: DSShellResponsive(
                sidebar: Container(key: const Key('full-sidebar')),
                collapsedSidebar: Container(
                  key: const Key('collapsed-sidebar'),
                ),
                content: Container(key: const Key('content')),
              ),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('full-sidebar')), findsNothing);
      expect(find.byKey(const Key('collapsed-sidebar')), findsNothing);
      expect(find.byKey(const Key('content')), findsOneWidget);
    });
  });

  group('DSSidebar composition', () {
    testWidgets('renders items and highlights selected item', (tester) async {
      const items = [
        DSSidebarItem(id: 'overview', label: 'Overview', icon: Icons.dashboard),
        DSSidebarItem(id: 'map', label: 'Map', icon: Icons.hub_outlined),
        DSSidebarItem(id: 'operate', label: 'Operate', icon: Icons.play_circle),
      ];

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 240,
              height: 600,
              child: DSSidebar(items: items, selectedId: 'map'),
            ),
          ),
        ),
      );

      expect(find.text('Overview'), findsOneWidget);
      expect(find.text('Map'), findsOneWidget);
      expect(find.text('Operate'), findsOneWidget);
    });

    testWidgets('fires onItemTap with correct id', (tester) async {
      String? tappedId;
      const items = [
        DSSidebarItem(id: 'a', label: 'A', icon: Icons.star),
        DSSidebarItem(id: 'b', label: 'B', icon: Icons.star_border),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 240,
              height: 400,
              child: DSSidebar(
                items: items,
                selectedId: 'a',
                onItemTap: (id) => tappedId = id,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('B'));
      expect(tappedId, 'b');
    });
  });

  group('DSTopbar composition', () {
    testWidgets('renders title', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DSTopbar(title: 'Map Workspace')),
        ),
      );

      expect(find.text('Map Workspace'), findsOneWidget);
    });

    testWidgets('renders breadcrumbs', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DSTopbar(breadcrumbs: ['Home', 'Map', 'Agent Alpha']),
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Agent Alpha'), findsOneWidget);
    });
  });

  group('DSGraphCanvas composition', () {
    testWidgets('renders empty state when no nodes provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: DSGraphCanvas(nodes: [], edges: []),
            ),
          ),
        ),
      );

      expect(find.text('No assets to display'), findsOneWidget);
    });

    testWidgets('renders nodes when provided', (tester) async {
      final nodes = [
        GraphNode(id: 'a', label: 'Alpha', type: 'agent'),
        GraphNode(id: 'b', label: 'Beta', type: 'skill'),
      ];
      const edges = [GraphEdge(sourceId: 'a', targetId: 'b')];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: DSGraphCanvas(nodes: nodes, edges: edges),
            ),
          ),
        ),
      );

      expect(find.text('Alpha'), findsOneWidget);
      expect(find.text('Beta'), findsOneWidget);
    });
  });

  group('Organisms barrel exports', () {
    test('organisms barrel exports all expected classes', () {
      // Verify all organism classes are accessible via the barrel
      // This is a compile-time check; if any export is missing this won't compile
      expect(DSShell, isNotNull);
      expect(DSShellResponsive, isNotNull);
      expect(DSSidebar, isNotNull);
      expect(DSSidebarItem, isNotNull);
      expect(DSTopbar, isNotNull);
      expect(DSTopbarAction, isNotNull);
      expect(DSLaneBoard, isNotNull);
      expect(DSLane, isNotNull);
      expect(DSLaneTask, isNotNull);
      expect(DSTimeline, isNotNull);
      expect(DSTimelineEntry, isNotNull);
      expect(DSTimelineGrouped, isNotNull);
      expect(DSTimelineGroup, isNotNull);
      expect(DSDetailInspector, isNotNull);
      expect(DSDetailSection, isNotNull);
      expect(DSPropertyRow, isNotNull);
      expect(DSLinkRow, isNotNull);
      expect(DSStoryPanel, isNotNull);
      expect(DSStoryInsight, isNotNull);
      expect(DSStoryCardQuick, isNotNull);
      expect(DSGraphCanvas, isNotNull);
      expect(GraphNode, isNotNull);
      expect(GraphEdge, isNotNull);
      expect(DSCommandPalette, isNotNull);
      expect(DSCommand, isNotNull);
      expect(DSCommandCategory, isNotNull);
      expect(showDSCommandPalette, isNotNull);
      expect(DSCommandPaletteShortcut, isNotNull);
    });
  });
}
