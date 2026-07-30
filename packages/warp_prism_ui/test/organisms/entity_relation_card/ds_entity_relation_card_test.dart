import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

void main() {
  List<PrismGraphNode> testNodes() => [
    PrismGraphNode(id: 'agent-1', label: 'Agent Alpha', type: 'agent'),
    PrismGraphNode(id: 'skill-1', label: 'Parse YAML', type: 'skill'),
    PrismGraphNode(id: 'task-1', label: 'Fix Bug', type: 'task'),
  ];

  List<PrismGraphEdge> testEdges() => [
    const PrismGraphEdge(
      sourceId: 'agent-1',
      targetId: 'skill-1',
      edgeType: 'uses',
    ),
    const PrismGraphEdge(
      sourceId: 'skill-1',
      targetId: 'task-1',
      edgeType: 'references',
    ),
  ];

  Widget harness({
    required List<PrismGraphNode> nodes,
    required List<PrismGraphEdge> edges,
    String type = 'agent',
    String title = 'Agent Alpha Relations',
    String? subtitle = 'Workspace context',
    VoidCallback? onInspectEntity,
    VoidCallback? onExpandGraph,
    void Function(String)? onLegendTap,
    bool? collapsed,
    bool initiallyCollapsed = false,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              PrismEntityRelationCard(
                title: title,
                subtitle: subtitle,
                type: type,
                nodes: nodes,
                edges: edges,
                onInspectEntity: onInspectEntity,
                onExpandGraph: onExpandGraph,
                onLegendTap: onLegendTap,
                collapsed: collapsed,
                initiallyCollapsed: initiallyCollapsed,
              ),
            ],
          ),
        ),
      ),
    );
  }

  group('PrismEntityRelationCard', () {
    testWidgets('renders header, graph view and action buttons', (
      tester,
    ) async {
      await tester.pumpWidget(
        harness(
          nodes: testNodes(),
          edges: testEdges(),
          onInspectEntity: () {},
          onExpandGraph: () {},
        ),
      );

      expect(find.byType(PrismEntityRelationCard), findsOneWidget);
      expect(find.byKey(PrismEntityRelationCard.cardRegionKey), findsOneWidget);
      expect(find.text('Agent Alpha Relations'), findsOneWidget);
      expect(find.text('AGENT'), findsOneWidget);
      expect(find.text('Workspace context'), findsOneWidget);

      // Verify header icon shows up
      expect(find.byType(PrismIcon), findsWidgets);

      // Verify mini-graph container is displayed (with default height)
      expect(find.byKey(PrismEntityRelationCard.bodyKey), findsOneWidget);
      expect(find.byType(PrismGraphCanvas), findsOneWidget);

      // Verify action buttons
      expect(
        find.byKey(PrismEntityRelationCard.inspectButtonKey),
        findsOneWidget,
      );
      expect(
        find.byKey(PrismEntityRelationCard.expandButtonKey),
        findsOneWidget,
      );
    });

    testWidgets('empty relations shows custom empty message', (tester) async {
      await tester.pumpWidget(harness(nodes: const [], edges: const []));

      expect(find.byType(PrismEntityRelationCard), findsOneWidget);
      expect(find.text('No related entities'), findsOneWidget);
      expect(find.byType(PrismGraphCanvas), findsNothing);
    });

    testWidgets('collapse hides body and expand reveals it', (tester) async {
      await tester.pumpWidget(
        harness(
          nodes: testNodes(),
          edges: testEdges(),
          initiallyCollapsed: true,
        ),
      );

      // Body should be hidden
      expect(find.byKey(PrismEntityRelationCard.bodyKey), findsNothing);

      // Tap the collapse toggle button
      await tester.tap(find.byKey(PrismEntityRelationCard.collapseButtonKey));
      await tester.pumpAndSettle();

      // Body should now be visible
      expect(find.byKey(PrismEntityRelationCard.bodyKey), findsOneWidget);
      expect(find.byType(PrismGraphCanvas), findsOneWidget);
    });

    testWidgets('callbacks fire on button and legend clicks', (tester) async {
      var inspected = false;
      var expanded = false;
      String? tappedLegendType;

      await tester.pumpWidget(
        harness(
          nodes: testNodes(),
          edges: testEdges(),
          onInspectEntity: () => inspected = true,
          onExpandGraph: () => expanded = true,
          onLegendTap: (type) => tappedLegendType = type,
        ),
      );

      // Tap Inspect Detail
      await tester.tap(find.byKey(PrismEntityRelationCard.inspectButtonKey));
      await tester.pump();
      expect(inspected, isTrue);

      // Tap Expand Graph
      await tester.tap(find.byKey(PrismEntityRelationCard.expandButtonKey));
      await tester.pump();
      expect(expanded, isTrue);

      // Tap Legend Item for 'skill'
      await tester.tap(find.text('Skill'));
      await tester.pump();
      expect(tappedLegendType, 'skill');
    });

    testWidgets('legend actions are keyboard accessible', (tester) async {
      String? tappedLegendType;

      await tester.pumpWidget(
        harness(
          nodes: testNodes(),
          edges: testEdges(),
          onLegendTap: (type) => tappedLegendType = type,
        ),
      );

      final skillLegend = find.ancestor(
        of: find.text('Skill'),
        matching: find.byType(FocusableActionDetector),
      );

      expect(skillLegend, findsOneWidget);

      await tester.tap(skillLegend);
      await tester.pump();
      expect(tappedLegendType, 'skill');

      tappedLegendType = null;
      await tester.tap(skillLegend);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(tappedLegendType, 'skill');
    });

    testWidgets('exposes proper semantic labels for screen readers', (
      tester,
    ) async {
      await tester.pumpWidget(
        harness(
          nodes: testNodes(),
          edges: testEdges(),
          onInspectEntity: () {},
          onExpandGraph: () {},
        ),
      );

      final cardSemantics = tester.getSemantics(
        find.byKey(PrismEntityRelationCard.cardRegionKey),
      );
      expect(
        cardSemantics.label,
        contains('Relations preview for Agent Alpha Relations'),
      );

      // Check footer action semantics
      final inspectSemantics = tester.getSemantics(
        find.byKey(PrismEntityRelationCard.inspectButtonKey),
      );
      expect(
        inspectSemantics.label,
        'Inspect detail specifications for Agent Alpha Relations',
      );
      expect(inspectSemantics.flagsCollection.isButton, isTrue);

      final expandSemantics = tester.getSemantics(
        find.byKey(PrismEntityRelationCard.expandButtonKey),
      );
      expect(
        expandSemantics.label,
        'Open full graph view for Agent Alpha Relations',
      );
      expect(expandSemantics.flagsCollection.isButton, isTrue);
    });

    testWidgets('legend filter hit targets meet 48dp minimum', (tester) async {
      await tester.pumpWidget(
        harness(nodes: testNodes(), edges: testEdges(), onLegendTap: (_) {}),
      );

      final skillLegend = find.byKey(
        PrismEntityRelationCard.legendKey('skill'),
      );
      expect(skillLegend, findsOneWidget);

      final size = tester.getSize(skillLegend);
      expect(size.width, greaterThanOrEqualTo(48.0));
      expect(size.height, greaterThanOrEqualTo(48.0));

      final agentLegend = find.byKey(
        PrismEntityRelationCard.legendKey('agent'),
      );
      final agentSize = tester.getSize(agentLegend);
      expect(agentSize.width, greaterThanOrEqualTo(48.0));
      expect(agentSize.height, greaterThanOrEqualTo(48.0));
    });

    testWidgets('footer action hit targets meet 48dp minimum', (tester) async {
      await tester.pumpWidget(
        harness(
          nodes: testNodes(),
          edges: testEdges(),
          onInspectEntity: () {},
          onExpandGraph: () {},
        ),
      );

      final inspectSize = tester.getSize(
        find.byKey(PrismEntityRelationCard.inspectButtonKey),
      );
      expect(inspectSize.height, greaterThanOrEqualTo(48.0));

      final expandSize = tester.getSize(
        find.byKey(PrismEntityRelationCard.expandButtonKey),
      );
      expect(expandSize.height, greaterThanOrEqualTo(48.0));
    });
  });
}
