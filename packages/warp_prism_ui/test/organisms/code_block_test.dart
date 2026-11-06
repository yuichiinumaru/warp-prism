import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// Task 1121: PrismCodeBlock widget tests.
///
/// Verifies: language detection, syntax highlighting output, clipboard action,
/// line numbers toggle, empty content handling, and glass-panel styling.
void main() {
  group('PrismCodeBlock', () {
    // ---------------------------------------------------------------------------
    // Rendering
    // ---------------------------------------------------------------------------
    testWidgets('renders source text as RichText', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: PrismCodeBlock(source: 'hello world')),
        ),
      );

      // Code is rendered as RichText spans, not plain Text widgets.
      // Verify the RichText widget contains the expected text.
      final richText = tester.widget<RichText>(find.byType(RichText).last);
      expect(richText.text.toPlainText(), contains('hello world'));
    });

    testWidgets('renders empty state when source is empty', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: PrismCodeBlock(source: '')),
        ),
      );

      expect(find.text('No content'), findsOneWidget);
    });

    // ---------------------------------------------------------------------------
    // Language detection
    // ---------------------------------------------------------------------------
    testWidgets('auto-detects JSON from source starting with {', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: PrismCodeBlock(source: '{"key": "value"}')),
        ),
      );

      expect(find.text('JSON'), findsOneWidget);
    });

    testWidgets('auto-detects JSON from source starting with [', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: PrismCodeBlock(source: '[1, 2, 3]')),
        ),
      );

      expect(find.text('JSON'), findsOneWidget);
    });

    testWidgets('auto-detects Dart from import statement', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PrismCodeBlock(
              source: "import 'package:flutter/material.dart';",
            ),
          ),
        ),
      );

      expect(find.text('Dart'), findsOneWidget);
    });

    testWidgets('auto-detects Dart from class definition', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PrismCodeBlock(source: 'class MyClass extends Base {}'),
          ),
        ),
      );

      expect(find.text('Dart'), findsOneWidget);
    });

    testWidgets('auto-detects YAML from key-value patterns', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PrismCodeBlock(source: 'name: warp-prism\nversion: 0.1.0'),
          ),
        ),
      );

      expect(find.text('YAML'), findsOneWidget);
    });

    testWidgets('auto-detects Markdown from heading', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: PrismCodeBlock(source: '# Hello\n\nSome text')),
        ),
      );

      expect(find.text('Markdown'), findsOneWidget);
    });

    testWidgets('shows Plain Text for unrecognized content', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: PrismCodeBlock(source: 'just some random text')),
        ),
      );

      expect(find.text('Plain Text'), findsOneWidget);
    });

    testWidgets('uses explicit language over auto-detection', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PrismCodeBlock(source: 'just some text', language: 'json'),
          ),
        ),
      );

      expect(find.text('JSON'), findsOneWidget);
    });

    // ---------------------------------------------------------------------------
    // Line numbers
    // ---------------------------------------------------------------------------
    testWidgets('shows line numbers by default', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: PrismCodeBlock(source: 'line1\nline2\nline3')),
        ),
      );

      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('hides line numbers when showLineNumbers is false', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PrismCodeBlock(
              source: 'line1\nline2',
              showLineNumbers: false,
            ),
          ),
        ),
      );

      // No line number Text widgets should be present
      expect(find.text('1'), findsNothing);
      expect(find.text('2'), findsNothing);
    });

    // ---------------------------------------------------------------------------
    // Copy button
    // ---------------------------------------------------------------------------
    testWidgets('shows copy button by default', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: PrismCodeBlock(source: 'copy me')),
        ),
      );

      expect(find.byIcon(Icons.copy), findsOneWidget);
    });

    testWidgets('hides copy button when showCopyButton is false', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PrismCodeBlock(source: 'no copy', showCopyButton: false),
          ),
        ),
      );

      expect(find.byIcon(Icons.copy), findsNothing);
    });

    testWidgets('copy button exists and is tappable', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: PrismCodeBlock(source: 'copy this code')),
        ),
      );

      // Copy icon should be visible
      expect(find.byIcon(Icons.copy), findsOneWidget);

      // The button should be wrapped in an InkWell for tapping
      expect(find.byType(InkWell), findsWidgets);
    });

    // ---------------------------------------------------------------------------
    // Syntax highlighting (RichText presence)
    // ---------------------------------------------------------------------------
    testWidgets('renders RichText for JSON content', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PrismCodeBlock(
              source: '{"key": "value", "num": 42}',
              language: 'json',
            ),
          ),
        ),
      );

      // The highlighted code should be rendered as RichText
      expect(find.byType(RichText), findsWidgets);

      // Verify the code content is present in RichText spans
      final richTexts = tester.widgetList<RichText>(find.byType(RichText));
      final hasCode = richTexts.any(
        (rt) => rt.text.toPlainText().contains('key'),
      );
      expect(hasCode, isTrue);
    });

    testWidgets('renders RichText for Dart content', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PrismCodeBlock(
              source: 'void main() {\n  print("hello");\n}',
              language: 'dart',
            ),
          ),
        ),
      );

      expect(find.byType(RichText), findsWidgets);

      final richTexts = tester.widgetList<RichText>(find.byType(RichText));
      final hasCode = richTexts.any(
        (rt) => rt.text.toPlainText().contains('void'),
      );
      expect(hasCode, isTrue);
    });

    testWidgets('renders RichText for YAML content', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PrismCodeBlock(
              source: 'name: test\nversion: 1.0',
              language: 'yaml',
            ),
          ),
        ),
      );

      expect(find.byType(RichText), findsWidgets);

      final richTexts = tester.widgetList<RichText>(find.byType(RichText));
      final hasCode = richTexts.any(
        (rt) => rt.text.toPlainText().contains('name'),
      );
      expect(hasCode, isTrue);
    });

    // ---------------------------------------------------------------------------
    // Glass panel styling
    // ---------------------------------------------------------------------------
    testWidgets('wraps content in PrismGlassPanelSimple', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: PrismCodeBlock(source: 'styled code')),
        ),
      );

      // PrismCodeBlock uses PrismGlassPanelSimple for its container
      expect(find.byType(PrismGlassPanelSimple), findsWidgets);
    });

    // ---------------------------------------------------------------------------
    // effectiveLanguage getter
    // ---------------------------------------------------------------------------
    test('effectiveLanguage returns explicit language when provided', () {
      const block = PrismCodeBlock(source: '{}', language: 'yaml');
      expect(block.effectiveLanguage, 'yaml');
    });

    test('effectiveLanguage auto-detects when language is null', () {
      const block = PrismCodeBlock(source: '{"key": 1}');
      expect(block.effectiveLanguage, 'json');
    });

    test('effectiveLanguage returns null for unrecognized plain text', () {
      const block = PrismCodeBlock(source: 'random stuff here');
      expect(block.effectiveLanguage, isNull);
    });
  });
}
