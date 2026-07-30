import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// Task 1608: PrismMcpCapabilityInspector / DSMcpCapabilityInspector tests.
///
/// Covers: fixture tools+resources (+prompts), capability-gated tabs,
/// selection → detail metadata, empty capability set, a11y labels.
/// Fixture-only — no live MCP network client.
void main() {
  Widget harness({
    required Widget child,
    double width = 900,
    double height = 520,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(width: width, height: height, child: child),
      ),
    );
  }

  group('PrismMcpCapabilityInspector', () {
    testWidgets('renders fixture tools and resources sections', (tester) async {
      final fixture = prismMcpCapabilityInspectorMinimalFixture();

      await tester.pumpWidget(
        harness(
          child: PrismMcpCapabilityInspector(
            capabilities: fixture.capabilities,
            tools: fixture.tools,
            resources: fixture.resources,
            useSplitPane: false,
            listWidth: 280,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PrismMcpCapabilityInspector), findsOneWidget);
      expect(find.text('Tools'), findsWidgets);
      expect(find.text('Resources'), findsWidgets);
      // Name appears in list row + detail title + property row
      expect(find.text('echo'), findsWidgets);
      expect(find.text('disabled_tool'), findsOneWidget);
      // Detail for first tool
      expect(find.text('Echo fixture tool'), findsWidgets);
    });

    testWidgets('standard fixture shows tools, resources, and prompts tabs', (
      tester,
    ) async {
      await tester.pumpWidget(
        harness(
          child: PrismMcpCapabilityInspector(
            capabilities: prismMcpCapabilityInspectorStandardCapabilities(),
            tools: prismMcpCapabilityInspectorFixtureTools(),
            resources: prismMcpCapabilityInspectorFixtureResources(),
            prompts: prismMcpCapabilityInspectorFixturePrompts(),
            useSplitPane: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tools'), findsWidgets);
      expect(find.text('Resources'), findsWidgets);
      expect(find.text('Prompts'), findsWidgets);
      expect(find.text('list_directory'), findsWidgets);
      expect(find.text('read_file'), findsOneWidget);
    });

    testWidgets('capability gating hides prompts when flag is false', (
      tester,
    ) async {
      await tester.pumpWidget(
        harness(
          child: PrismMcpCapabilityInspector(
            capabilities: prismMcpCapabilityInspectorToolsResourcesOnly(),
            tools: prismMcpCapabilityInspectorFixtureTools(),
            resources: prismMcpCapabilityInspectorFixtureResources(),
            prompts: prismMcpCapabilityInspectorFixturePrompts(),
            useSplitPane: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tools'), findsWidgets);
      expect(find.text('Resources'), findsWidgets);
      // Prompts capability gated off — tab label must not appear
      expect(find.text('Prompts'), findsNothing);
      // Prompt items must not appear in list either
      expect(find.text('summarize_workspace'), findsNothing);
    });

    testWidgets('empty capability set shows empty surface', (tester) async {
      await tester.pumpWidget(
        harness(
          child: PrismMcpCapabilityInspector(
            capabilities: prismMcpCapabilityInspectorEmptyCapabilities(),
            tools: prismMcpCapabilityInspectorFixtureTools(),
            emptyCapabilitiesTitle: 'No capabilities',
            emptyCapabilitiesSubtitle: 'Fixture empty',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No capabilities'), findsOneWidget);
      expect(find.text('Fixture empty'), findsOneWidget);
      expect(find.byKey(PrismMcpCapabilityInspector.emptyKey), findsOneWidget);
      expect(find.text('Tools'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('selecting a tool shows detail metadata', (tester) async {
      final fixture = prismMcpCapabilityInspectorMinimalFixture();
      PrismMcpCapabilitySelection? selected;

      await tester.pumpWidget(
        harness(
          child: PrismMcpCapabilityInspector(
            capabilities: fixture.capabilities,
            tools: fixture.tools,
            resources: fixture.resources,
            useSplitPane: false,
            onSelectionChanged: (s) => selected = s,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(
          PrismMcpCapabilityInspector.rowKey(
            PrismMcpCapabilityKind.tools,
            't2',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(selected, isNotNull);
      expect(selected!.kind, PrismMcpCapabilityKind.tools);
      expect(selected!.id, 't2');
      // Detail pane shows selected tool name + enabled false
      expect(find.text('disabled_tool'), findsWidgets);
      expect(find.text('false'), findsOneWidget);
    });

    testWidgets('selecting a resource shows URI and MIME in detail', (
      tester,
    ) async {
      final fixture = prismMcpCapabilityInspectorMinimalFixture();

      await tester.pumpWidget(
        harness(
          child: PrismMcpCapabilityInspector(
            capabilities: fixture.capabilities,
            tools: fixture.tools,
            resources: fixture.resources,
            useSplitPane: false,
            initialSelection: const PrismMcpCapabilitySelection(
              kind: PrismMcpCapabilityKind.resources,
              id: 'r1',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('a.txt'), findsWidgets);
      expect(find.text('file:///a.txt'), findsWidgets);
      expect(find.text('text/plain'), findsWidgets);
    });

    testWidgets('controlled selectedItemId highlights row', (tester) async {
      final fixture = prismMcpCapabilityInspectorMinimalFixture();

      await tester.pumpWidget(
        harness(
          child: PrismMcpCapabilityInspector(
            capabilities: fixture.capabilities,
            tools: fixture.tools,
            resources: fixture.resources,
            selectedKind: PrismMcpCapabilityKind.tools,
            selectedItemId: 't2',
            useSplitPane: false,
            onSelectionChanged: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      final surface = tester.widget<PrismInteractiveSurface>(
        find.byKey(
          PrismMcpCapabilityInspector.rowKey(
            PrismMcpCapabilityKind.tools,
            't2',
          ),
        ),
      );
      expect(surface.selected, isTrue);

      final other = tester.widget<PrismInteractiveSurface>(
        find.byKey(
          PrismMcpCapabilityInspector.rowKey(
            PrismMcpCapabilityKind.tools,
            't1',
          ),
        ),
      );
      expect(other.selected, isFalse);
    });

    testWidgets('a11y: inspector, list, and row labels present', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      try {
        final fixture = prismMcpCapabilityInspectorMinimalFixture();
        await tester.pumpWidget(
          harness(
            child: PrismMcpCapabilityInspector(
              semanticLabel: 'MCP capability inspector',
              capabilities: fixture.capabilities,
              tools: fixture.tools,
              resources: fixture.resources,
              useSplitPane: false,
              onSelectionChanged: (_) {},
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.bySemanticsLabel(
            RegExp(r'MCP capability inspector: Tools, Resources'),
          ),
          findsOneWidget,
        );

        final row = tester.getSemantics(
          find.byKey(
            PrismMcpCapabilityInspector.rowKey(
              PrismMcpCapabilityKind.tools,
              't1',
            ),
          ),
        );
        expect(row.label, contains('Tool echo'));
        expect(row.label, contains('enabled'));
        expect(row.flagsCollection.isButton, isTrue);

        expect(
          find.bySemanticsLabel(RegExp(r'Tools list, 2 items')),
          findsOneWidget,
        );
        expect(
          find.bySemanticsLabel(RegExp(r'MCP capability sections')),
          findsOneWidget,
        );
      } finally {
        handle.dispose();
      }
    });

    testWidgets('full gallery fixture renders without crash', (tester) async {
      await tester.pumpWidget(
        harness(
          width: 960,
          height: 560,
          child: PrismMcpCapabilityInspector(
            title: 'MCP Capabilities',
            subtitle: 'filesystem — fixture server',
            connectionStatus: 'connected',
            capabilities: prismMcpCapabilityInspectorStandardCapabilities(),
            tools: prismMcpCapabilityInspectorFixtureTools(),
            resources: prismMcpCapabilityInspectorFixtureResources(),
            prompts: prismMcpCapabilityInspectorFixturePrompts(),
            initialSelection: const PrismMcpCapabilitySelection(
              kind: PrismMcpCapabilityKind.tools,
              id: 'tool-list-dir',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('MCP Capabilities'), findsOneWidget);
      expect(find.text('connected'), findsOneWidget);
      expect(find.text('list_directory'), findsWidgets);
      expect(find.text('Invoke (mock)'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    test('capability flags compute enabledKinds and isEmpty', () {
      const empty = PrismMcpCapabilities.none();
      expect(empty.isEmpty, isTrue);
      expect(empty.enabledKinds, isEmpty);

      const std = PrismMcpCapabilities.standard();
      expect(std.enabledKinds, [
        PrismMcpCapabilityKind.tools,
        PrismMcpCapabilityKind.resources,
        PrismMcpCapabilityKind.prompts,
      ]);
      expect(std.allows(PrismMcpCapabilityKind.tools), isTrue);
      expect(std.allows(PrismMcpCapabilityKind.roots), isFalse);
    });

    test('tool and resource semanticLabel helpers', () {
      const tool = PrismMcpToolItem(
        id: 't',
        name: 'echo',
        description: 'Echo tool',
        enabled: true,
      );
      expect(tool.semanticLabel, 'Tool echo, enabled: Echo tool');

      const resource = PrismMcpResourceItem(
        id: 'r',
        uri: 'file:///x',
        name: 'x',
        mimeType: 'text/plain',
      );
      expect(resource.semanticLabel, 'Resource x, file:///x, text/plain');
    });
  });
}
