import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// Helper: finds text content within any RichText widget on screen.
Finder findTextInRichText(String text) {
  return find.byWidgetPredicate((widget) {
    if (widget is RichText) {
      return widget.text.toPlainText().contains(text);
    }
    return false;
  });
}

/// Task 1121: DSMarkdownRenderer widget tests.
void main() {
  group('DSMarkdownRenderer', () {
    // ---------------------------------------------------------------------------
    // Empty content
    // ---------------------------------------------------------------------------
    testWidgets('renders "No content" when data is empty', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DSMarkdownRenderer(data: '')),
        ),
      );

      expect(find.text('No content'), findsOneWidget);
    });

    // ---------------------------------------------------------------------------
    // Headings
    // ---------------------------------------------------------------------------
    testWidgets('renders h1 heading', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DSMarkdownRenderer(data: '# Hello World')),
        ),
      );

      expect(findTextInRichText('Hello World'), findsOneWidget);
    });

    testWidgets('renders h2 heading', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DSMarkdownRenderer(data: '## Section Title')),
        ),
      );

      expect(findTextInRichText('Section Title'), findsOneWidget);
    });

    testWidgets('renders h3 heading', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DSMarkdownRenderer(data: '### Subsection')),
        ),
      );

      expect(findTextInRichText('Subsection'), findsOneWidget);
    });

    testWidgets('renders h4 heading', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DSMarkdownRenderer(data: '#### Level 4')),
        ),
      );

      expect(findTextInRichText('Level 4'), findsOneWidget);
    });

    // ---------------------------------------------------------------------------
    // Bold and italic
    // ---------------------------------------------------------------------------
    testWidgets('renders bold text in RichText', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DSMarkdownRenderer(data: 'This is **bold** text'),
          ),
        ),
      );

      expect(find.byType(RichText), findsWidgets);
      expect(findTextInRichText('bold'), findsOneWidget);
    });

    testWidgets('renders italic text in RichText', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DSMarkdownRenderer(data: 'This is *italic* text'),
          ),
        ),
      );

      expect(find.byType(RichText), findsWidgets);
      expect(findTextInRichText('italic'), findsOneWidget);
    });

    // ---------------------------------------------------------------------------
    // Inline code
    // ---------------------------------------------------------------------------
    testWidgets('renders inline code', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DSMarkdownRenderer(data: 'Use `const` keyword')),
        ),
      );

      expect(find.byType(RichText), findsWidgets);
      expect(findTextInRichText('const'), findsOneWidget);
    });

    // ---------------------------------------------------------------------------
    // Code blocks
    // ---------------------------------------------------------------------------
    testWidgets('renders fenced code block as DSCodeBlock', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DSMarkdownRenderer(
              data: 'Some text\n\n```json\n{"key": "value"}\n```\n\nMore text',
            ),
          ),
        ),
      );

      expect(find.byType(DSCodeBlock), findsOneWidget);
    });

    testWidgets('renders code block with language label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DSMarkdownRenderer(data: '```dart\nvoid main() {}\n```'),
          ),
        ),
      );

      expect(find.byType(DSCodeBlock), findsOneWidget);
      expect(find.text('Dart'), findsOneWidget);
    });

    testWidgets('renders code block without language', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DSMarkdownRenderer(data: '```\nplain code block\n```'),
          ),
        ),
      );

      expect(find.byType(DSCodeBlock), findsOneWidget);
    });

    // ---------------------------------------------------------------------------
    // Bullet lists
    // ---------------------------------------------------------------------------
    testWidgets('renders bullet list items', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DSMarkdownRenderer(
              data: '- Item one\n- Item two\n- Item three',
            ),
          ),
        ),
      );

      expect(findTextInRichText('Item one'), findsOneWidget);
      expect(findTextInRichText('Item two'), findsOneWidget);
      expect(findTextInRichText('Item three'), findsOneWidget);
    });

    testWidgets('renders bullet list with * prefix', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DSMarkdownRenderer(data: '* Alpha\n* Beta')),
        ),
      );

      expect(findTextInRichText('Alpha'), findsOneWidget);
      expect(findTextInRichText('Beta'), findsOneWidget);
    });

    // ---------------------------------------------------------------------------
    // Ordered lists
    // ---------------------------------------------------------------------------
    testWidgets('renders ordered list with numbers', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DSMarkdownRenderer(data: '1. First\n2. Second\n3. Third'),
          ),
        ),
      );

      expect(findTextInRichText('First'), findsOneWidget);
      expect(findTextInRichText('Second'), findsOneWidget);
      expect(findTextInRichText('Third'), findsOneWidget);
      expect(find.text('1.'), findsOneWidget);
      expect(find.text('2.'), findsOneWidget);
      expect(find.text('3.'), findsOneWidget);
    });

    // ---------------------------------------------------------------------------
    // Blockquotes
    // ---------------------------------------------------------------------------
    testWidgets('renders blockquote text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DSMarkdownRenderer(data: '> This is a quote')),
        ),
      );

      expect(findTextInRichText('This is a quote'), findsOneWidget);
    });

    // ---------------------------------------------------------------------------
    // Links
    // ---------------------------------------------------------------------------
    testWidgets('renders link text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DSMarkdownRenderer(
              data: 'Check [this link](https://example.com)',
            ),
          ),
        ),
      );

      expect(findTextInRichText('this link'), findsOneWidget);
    });

    // ---------------------------------------------------------------------------
    // Mixed content
    // ---------------------------------------------------------------------------
    testWidgets('renders mixed content with all block types', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DSMarkdownRenderer(
              data:
                  '# Title\n'
                  '\n'
                  'Some **bold** and *italic* text with `code`.\n'
                  '\n'
                  '- List item 1\n'
                  '- List item 2\n'
                  '\n'
                  '> A blockquote\n'
                  '\n'
                  '1. Ordered 1\n'
                  '2. Ordered 2\n'
                  '\n'
                  '```json\n{"key": 1}\n```\n'
                  '\n'
                  'A [link](https://example.com) in text.',
            ),
          ),
        ),
      );

      // All major block types should be present
      expect(findTextInRichText('Title'), findsWidgets);
      expect(findTextInRichText('A blockquote'), findsOneWidget);
      expect(findTextInRichText('Ordered 1'), findsOneWidget);
      expect(findTextInRichText('List item 1'), findsOneWidget);
      expect(find.byType(DSCodeBlock), findsOneWidget);
    });

    // ---------------------------------------------------------------------------
    // Malformed markdown
    // ---------------------------------------------------------------------------
    testWidgets('handles unclosed code fence gracefully', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DSMarkdownRenderer(data: '```dart\nvoid main() {'),
          ),
        ),
      );

      // Unclosed code block should still render
      expect(find.byType(DSCodeBlock), findsOneWidget);
    });

    testWidgets('handles unclosed bold marker gracefully', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DSMarkdownRenderer(data: 'This has **unclosed bold'),
          ),
        ),
      );

      // Should render as plain text paragraph
      expect(find.byType(RichText), findsWidgets);
    });

    // ---------------------------------------------------------------------------
    // Paragraph rendering
    // ---------------------------------------------------------------------------
    testWidgets('renders plain paragraph text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DSMarkdownRenderer(data: 'Just a simple paragraph of text.'),
          ),
        ),
      );

      expect(
        findTextInRichText('Just a simple paragraph of text.'),
        findsOneWidget,
      );
    });

    testWidgets('renders multi-line paragraph as single block', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DSMarkdownRenderer(
              data: 'First line of paragraph\nSecond line of paragraph',
            ),
          ),
        ),
      );

      // Multi-line paragraph should be joined
      expect(findTextInRichText('First line of paragraph'), findsOneWidget);
    });
  });
}
