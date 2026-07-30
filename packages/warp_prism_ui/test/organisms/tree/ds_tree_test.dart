import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// Task 1603: PrismTree / DSTree widget tests.
///
/// Covers: multi-level fixture render, expand/collapse, selection callback +
/// selected visual, optional status/meta, empty tree, deep nesting (≥3),
/// selected semantics, expand controls focusable.
void main() {
  Widget harness({
    required Widget child,
    double width = 400,
    double height = 600,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(width: width, height: height, child: child),
      ),
    );
  }

  /// providers → accounts → models (≥3 levels)
  List<PrismTreeNode> fixtureTree() {
    return const [
      PrismTreeNode(
        id: 'prov-openai',
        label: 'OpenAI',
        status: PrismOperationalState.healthy,
        meta: '2 accounts',
        children: [
          PrismTreeNode(
            id: 'acct-main',
            label: 'main-prod',
            status: PrismOperationalState.healthy,
            meta: 'us-east',
            children: [
              PrismTreeNode(
                id: 'model-gpt4o',
                label: 'gpt-4o',
                status: PrismOperationalState.healthy,
                meta: 'chat',
              ),
              PrismTreeNode(
                id: 'model-o1',
                label: 'o1-mini',
                status: PrismOperationalState.degraded,
              ),
            ],
          ),
          PrismTreeNode(
            id: 'acct-dev',
            label: 'dev-sandbox',
            status: PrismOperationalState.stale,
            children: [PrismTreeNode(id: 'model-mini', label: 'gpt-4o-mini')],
          ),
        ],
      ),
      PrismTreeNode(
        id: 'prov-anthropic',
        label: 'Anthropic',
        status: PrismOperationalState.degraded,
        meta: '1 account',
        children: [
          PrismTreeNode(
            id: 'acct-claude',
            label: 'claude-prod',
            children: [
              PrismTreeNode(id: 'model-sonnet', label: 'claude-sonnet-4'),
            ],
          ),
        ],
      ),
    ];
  }

  group('PrismTree', () {
    testWidgets('renders root nodes of multi-level fixture', (tester) async {
      await tester.pumpWidget(harness(child: PrismTree(nodes: fixtureTree())));

      expect(find.byType(PrismTree), findsOneWidget);
      expect(find.text('OpenAI'), findsOneWidget);
      expect(find.text('Anthropic'), findsOneWidget);
      // Nested children hidden until expanded.
      expect(find.text('main-prod'), findsNothing);
      expect(find.text('gpt-4o'), findsNothing);
    });

    testWidgets('expand reveals children; collapse hides them', (tester) async {
      await tester.pumpWidget(harness(child: PrismTree(nodes: fixtureTree())));

      // Expand OpenAI via caret IconButton.
      await tester.tap(find.byKey(const Key('tree-expand-OpenAI')));
      await tester.pumpAndSettle();

      expect(find.text('main-prod'), findsOneWidget);
      expect(find.text('dev-sandbox'), findsOneWidget);
      expect(find.text('gpt-4o'), findsNothing);

      // Expand account for deep child.
      await tester.tap(find.byKey(const Key('tree-expand-main-prod')));
      await tester.pumpAndSettle();
      expect(find.text('gpt-4o'), findsOneWidget);
      expect(find.text('o1-mini'), findsOneWidget);

      // Collapse OpenAI hides all descendants.
      await tester.tap(find.byKey(const Key('tree-expand-OpenAI')));
      await tester.pumpAndSettle();
      expect(find.text('main-prod'), findsNothing);
      expect(find.text('gpt-4o'), findsNothing);
    });

    testWidgets('onNodeSelected fires and selected visual state applies', (
      tester,
    ) async {
      String? selectedId;

      await tester.pumpWidget(
        harness(
          child: StatefulBuilder(
            builder: (context, setState) {
              return PrismTree(
                nodes: fixtureTree(),
                selectedId: selectedId,
                initiallyExpandedIds: const {'prov-openai'},
                onNodeSelected: (node) {
                  setState(() => selectedId = node.id);
                },
              );
            },
          ),
        ),
      );

      expect(find.byKey(const Key('tree-node-acct-main')), findsOneWidget);
      await tester.ensureVisible(find.byKey(const Key('tree-node-acct-main')));
      await tester.tap(find.byKey(const Key('tree-node-acct-main')));
      await tester.pumpAndSettle();

      // Callback reports node.id (not label).
      expect(selectedId, 'acct-main');

      // Selected semantics announced on the row.
      expect(
        find.bySemanticsLabel(RegExp(r'main-prod.*selected')),
        findsOneWidget,
      );
    });

    testWidgets('renders optional status dots and meta trailing text', (
      tester,
    ) async {
      await tester.pumpWidget(
        harness(
          child: PrismTree(
            nodes: fixtureTree(),
            initiallyExpandedIds: const {'prov-openai'},
          ),
        ),
      );

      expect(find.text('2 accounts'), findsOneWidget);
      expect(find.text('us-east'), findsOneWidget);
      // Status dots present (at least roots + expanded children).
      expect(find.byType(PrismStatusDot), findsWidgets);
    });

    testWidgets('empty tree shows placeholder without crash', (tester) async {
      await tester.pumpWidget(
        harness(
          child: const PrismTree(
            nodes: <PrismTreeNode>[],
            emptyLabel: 'No providers',
          ),
        ),
      );

      expect(find.text('No providers'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('empty tree can suppress placeholder', (tester) async {
      await tester.pumpWidget(
        harness(
          child: const PrismTree(
            nodes: <PrismTreeNode>[],
            showEmptyPlaceholder: false,
          ),
        ),
      );

      expect(find.text('No items'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('deep nesting ≥3 levels expands fully', (tester) async {
      await tester.pumpWidget(
        harness(
          child: PrismTree(
            nodes: fixtureTree(),
            initiallyExpandedIds: const {'prov-openai', 'acct-main'},
          ),
        ),
      );

      // Level 0
      expect(find.text('OpenAI'), findsOneWidget);
      // Level 1
      expect(find.text('main-prod'), findsOneWidget);
      // Level 2
      expect(find.text('gpt-4o'), findsOneWidget);
      expect(find.text('chat'), findsOneWidget);
    });

    testWidgets('controlled expansion defers to expandedIds parent', (
      tester,
    ) async {
      var expanded = <String>{};

      await tester.pumpWidget(
        harness(
          child: StatefulBuilder(
            builder: (context, setState) {
              return PrismTree(
                nodes: fixtureTree(),
                expandedIds: expanded,
                onExpandedIdsChanged: (next) {
                  setState(() => expanded = next);
                },
              );
            },
          ),
        ),
      );

      expect(find.text('main-prod'), findsNothing);

      await tester.tap(find.byKey(const Key('tree-expand-OpenAI')));
      await tester.pumpAndSettle();

      expect(expanded, contains('prov-openai'));
      expect(find.text('main-prod'), findsOneWidget);
    });

    testWidgets('expand control is focusable (semantics button)', (
      tester,
    ) async {
      await tester.pumpWidget(harness(child: PrismTree(nodes: fixtureTree())));

      final expand = find.bySemanticsLabel('Expand OpenAI');
      expect(expand, findsOneWidget);

      final semantics = tester.getSemantics(expand);
      expect(
        semantics.flagsCollection.isButton,
        isTrue,
        reason: 'expand caret must be a semantic button',
      );
      // IconButton exposes enabled as Tristate on newer Flutter SDKs.
      expect(
        semantics.flagsCollection.isEnabled.toString(),
        contains('True'),
        reason: 'expand caret must be enabled / activatable',
      );
    });

    testWidgets('expand control toggles via IconButton keyboard path', (
      tester,
    ) async {
      await tester.pumpWidget(harness(child: PrismTree(nodes: fixtureTree())));

      await tester.tap(find.byKey(const Key('tree-expand-OpenAI')));
      await tester.pumpAndSettle();
      expect(find.text('main-prod'), findsOneWidget);

      // Collapse via same caret key (toggle).
      await tester.tap(find.byKey(const Key('tree-expand-OpenAI')));
      await tester.pumpAndSettle();
      expect(find.text('main-prod'), findsNothing);

      // Re-expand.
      await tester.tap(find.byKey(const Key('tree-expand-OpenAI')));
      await tester.pumpAndSettle();
      expect(find.text('main-prod'), findsOneWidget);
    });

    testWidgets('public PrismTree alias is DSTree', (tester) async {
      await tester.pumpWidget(
        harness(
          child: const PrismTree(
            nodes: [PrismTreeNode(id: 'a', label: 'Alpha')],
          ),
        ),
      );

      expect(find.byType(PrismTree), findsOneWidget);
      // Typedef identity: PrismTree is DSTree at runtime type.
      final widget = tester.widget(find.byType(PrismTree));
      expect(widget.runtimeType.toString(), contains('DSTree'));
    });

    testWidgets('Arrow Up/Down roves focus across flattened visible rows', (
      tester,
    ) async {
      await tester.pumpWidget(
        harness(
          child: PrismTree(
            nodes: fixtureTree(),
            initiallyExpandedIds: const {'prov-openai'},
            onNodeSelected: (_) {},
          ),
        ),
      );

      // Visible flatten order: OpenAI, main-prod, dev-sandbox, Anthropic.
      String? primaryLabel() => FocusManager.instance.primaryFocus?.debugLabel;

      // Focus first visible row via InkWell key → enclosing FocusableActionDetector.
      final openAiInk = find.byKey(const Key('tree-node-prov-openai'));
      final openAiDetector = find.ancestor(
        of: openAiInk,
        matching: find.byType(FocusableActionDetector),
      );
      final openAiFocus = tester
          .widget<FocusableActionDetector>(openAiDetector)
          .focusNode!;
      openAiFocus.requestFocus();
      await tester.pump();
      expect(primaryLabel(), 'tree-row-prov-openai');

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(primaryLabel(), 'tree-row-acct-main');

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(primaryLabel(), 'tree-row-acct-dev');

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(primaryLabel(), 'tree-row-prov-anthropic');

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      expect(primaryLabel(), 'tree-row-acct-dev');
    });
  });

  group('PrismTreeNode', () {
    test('isExpandable defaults from children', () {
      const leaf = PrismTreeNode(id: 'l', label: 'Leaf');
      const parent = PrismTreeNode(
        id: 'p',
        label: 'Parent',
        children: [PrismTreeNode(id: 'c', label: 'Child')],
      );
      const forced = PrismTreeNode(id: 'f', label: 'Forced', expandable: true);

      expect(leaf.isExpandable, isFalse);
      expect(parent.isExpandable, isTrue);
      expect(forced.isExpandable, isTrue);
      expect(forced.hasChildren, isFalse);
    });

    test('copyWith clears optional fields', () {
      const node = PrismTreeNode(
        id: 'n',
        label: 'Node',
        status: PrismOperationalState.healthy,
        meta: 'meta',
      );
      final cleared = node.copyWith(clearStatus: true, clearMeta: true);
      expect(cleared.status, isNull);
      expect(cleared.meta, isNull);
      expect(cleared.label, 'Node');
    });
  });
}
