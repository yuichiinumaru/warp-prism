import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// Finds plain [Text], [SelectableText], or [RichText] content.
Finder findVisibleText(String text) {
  final plain = find.text(text);
  if (plain.evaluate().isNotEmpty) return plain;
  final containing = find.textContaining(text);
  if (containing.evaluate().isNotEmpty) return containing;
  return find.byWidgetPredicate((widget) {
    if (widget is RichText) {
      return widget.text.toPlainText().contains(text);
    }
    if (widget is SelectableText) {
      return (widget.data ?? widget.textSpan?.toPlainText() ?? '').contains(
        text,
      );
    }
    return false;
  });
}

/// Task 1606: PrismArtifactWorkbench / DSArtifactWorkbench widget tests.
///
/// Covers: fixture list + select preview, type badges (code/md/text),
/// empty list, unknown type fallback, controlled selection, a11y regions.
/// Fixture-only — no network / no mermaid engines.
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

  List<PrismArtifact> fixtures() => prismArtifactWorkbenchFixtures();

  group('PrismArtifactWorkbench', () {
    testWidgets('lists fixture artifacts and selects one to preview', (
      tester,
    ) async {
      await tester.pumpWidget(
        harness(
          child: PrismArtifactWorkbench(
            artifacts: fixtures(),
            initialSelectedId: 'art-code-1',
          ),
        ),
      );

      expect(find.byType(PrismArtifactWorkbench), findsOneWidget);
      expect(find.byKey(PrismArtifactWorkbench.panelKey), findsOneWidget);
      expect(find.byKey(PrismArtifactWorkbench.listKey), findsOneWidget);
      expect(find.byKey(PrismArtifactWorkbench.previewKey), findsOneWidget);

      // List titles
      expect(find.text('health_check.dart'), findsWidgets);
      expect(find.text('run-summary.md'), findsOneWidget);
      expect(find.text('stdout.log'), findsOneWidget);

      // Code selected by default → code block preview
      expect(find.byType(PrismCodeBlock), findsOneWidget);
      expect(findVisibleText('healthCheck'), findsWidgets);

      // Select markdown artifact
      await tester.tap(find.byKey(PrismArtifactWorkbench.rowKey('art-md-1')));
      await tester.pumpAndSettle();

      expect(find.byType(PrismMarkdownRenderer), findsOneWidget);
      expect(findVisibleText('Run summary'), findsWidgets);

      // Select text artifact
      await tester.tap(find.byKey(PrismArtifactWorkbench.rowKey('art-text-1')));
      await tester.pumpAndSettle();

      expect(findVisibleText('probe start'), findsWidgets);
      expect(find.byType(PrismCodeBlock), findsNothing);
      expect(find.byType(PrismMarkdownRenderer), findsNothing);
    });

    testWidgets('renders type badges for code, markdown, and text', (
      tester,
    ) async {
      await tester.pumpWidget(
        harness(child: PrismArtifactWorkbench(artifacts: fixtures())),
      );

      expect(
        find.byKey(PrismArtifactWorkbench.typeBadgeKey('art-code-1')),
        findsOneWidget,
      );
      expect(
        find.byKey(PrismArtifactWorkbench.typeBadgeKey('art-md-1')),
        findsOneWidget,
      );
      expect(
        find.byKey(PrismArtifactWorkbench.typeBadgeKey('art-text-1')),
        findsOneWidget,
      );

      // Type labels appear in list badges (and possibly preview header)
      expect(find.text('code'), findsWidgets);
      expect(find.text('markdown'), findsWidgets);
      expect(find.text('text'), findsWidgets);
    });

    testWidgets('empty list shows empty state', (tester) async {
      await tester.pumpWidget(
        harness(child: const PrismArtifactWorkbench(artifacts: [])),
      );

      expect(find.byKey(PrismArtifactWorkbench.emptyStateKey), findsOneWidget);
      expect(find.text('No artifacts'), findsOneWidget);
      expect(find.byKey(PrismArtifactWorkbench.listKey), findsNothing);
      expect(find.byType(PrismCodeBlock), findsNothing);
    });

    testWidgets('unknown type falls back safely', (tester) async {
      final unknown = prismArtifactUnknownFixture();

      await tester.pumpWidget(
        harness(
          child: PrismArtifactWorkbench(
            artifacts: [unknown],
            initialSelectedId: unknown.id,
          ),
        ),
      );

      expect(
        find.byKey(PrismArtifactWorkbench.unknownPreviewKey),
        findsOneWidget,
      );
      expect(find.text('Unknown artifact type'), findsOneWidget);
      expect(find.textContaining('mermaid'), findsWidgets);
      // No crash; plain fallback content present
      expect(find.textContaining('graph TD'), findsOneWidget);
    });

    testWidgets('controlled selection honors host', (tester) async {
      String? selectedId = 'art-code-1';
      PrismArtifact? lastCallback;

      await tester.pumpWidget(
        harness(
          child: StatefulBuilder(
            builder: (context, setState) {
              return PrismArtifactWorkbench(
                artifacts: fixtures(),
                selectedId: selectedId,
                onSelectionChanged: (a) {
                  lastCallback = a;
                  setState(() => selectedId = a?.id);
                },
              );
            },
          ),
        ),
      );

      expect(find.byType(PrismCodeBlock), findsOneWidget);

      await tester.tap(find.byKey(PrismArtifactWorkbench.rowKey('art-md-1')));
      await tester.pumpAndSettle();

      expect(lastCallback?.id, 'art-md-1');
      expect(selectedId, 'art-md-1');
      expect(find.byType(PrismMarkdownRenderer), findsOneWidget);
    });

    testWidgets('a11y: list and preview regions labeled', (tester) async {
      final handle = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          harness(
            child: PrismArtifactWorkbench(
              artifacts: fixtures(),
              semanticLabel: 'Workbench region',
              listSemanticLabel: 'Artifact list region',
              previewSemanticLabel: 'Artifact preview region',
            ),
          ),
        );

        expect(find.bySemanticsLabel('Workbench region'), findsOneWidget);
        expect(find.bySemanticsLabel('Artifact list region'), findsOneWidget);
        expect(
          find.bySemanticsLabel('Artifact preview region'),
          findsOneWidget,
        );
      } finally {
        handle.dispose();
      }
    });

    testWidgets('fixed list width mode without split pane', (tester) async {
      await tester.pumpWidget(
        harness(
          width: 720,
          child: PrismArtifactWorkbench(
            artifacts: fixtures(),
            useSplitPane: false,
            listWidth: 240,
            initialSelectedId: 'art-text-1',
          ),
        ),
      );

      expect(find.byType(PrismArtifactWorkbench), findsOneWidget);
      expect(findVisibleText('probe start'), findsWidgets);
      expect(find.byType(PrismSplitPane), findsNothing);
    });

    testWidgets('model helpers: typeLabel and equality', (tester) async {
      const a = PrismArtifact(
        id: 'x',
        title: 't',
        type: PrismArtifactType.code,
        content: 'c',
        language: 'dart',
      );
      const b = PrismArtifact(
        id: 'x',
        title: 't',
        type: PrismArtifactType.code,
        content: 'c',
        language: 'dart',
      );
      expect(a, equals(b));
      expect(a.typeLabel, 'code');
      expect(a.copyWith(title: 't2').title, 't2');
      expect(
        const PrismArtifact(
          id: 'i',
          title: 't',
          type: PrismArtifactType.markdown,
          content: '',
        ).typeLabel,
        'markdown',
      );
      expect(
        const PrismArtifact(
          id: 'i',
          title: 't',
          type: PrismArtifactType.text,
          content: '',
        ).typeLabel,
        'text',
      );
      expect(
        const PrismArtifact(
          id: 'i',
          title: 't',
          type: PrismArtifactType.unknown,
          content: '',
        ).typeLabel,
        'unknown',
      );
    });
  });
}
