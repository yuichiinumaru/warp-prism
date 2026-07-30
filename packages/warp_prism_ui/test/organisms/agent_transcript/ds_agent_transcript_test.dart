import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// Finds plain [Text] or [RichText] content (markdown uses RichText).
Finder findVisibleText(String text) {
  final plain = find.text(text);
  if (plain.evaluate().isNotEmpty) return plain;
  return find.byWidgetPredicate((widget) {
    if (widget is RichText) {
      return widget.text.toPlainText().contains(text);
    }
    return false;
  });
}

/// Task 1604: PrismAgentTranscript / DSAgentTranscript widget tests.
///
/// Covers: empty, single turn, multi-turn (user + assistant + system),
/// timestamps optional, think/plan stubs, long content scroll, markdown
/// composition, a11y conversation region + ordered messages, custom block
/// slot, model helpers. Fixture-only — no network.
void main() {
  Widget harness({
    required Widget child,
    double width = 720,
    double height = 480,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(width: width, height: height, child: child),
      ),
    );
  }

  List<PrismAgentMessage> multiTurnFixture() {
    final t0 = DateTime.utc(2026, 7, 10, 12, 0, 0);
    return [
      PrismAgentMessage(
        id: 'sys-1',
        role: PrismAgentRole.system,
        timestamp: t0,
        blocks: const [PrismAgentMessageBlock.text('System online.')],
      ),
      PrismAgentMessage(
        id: 'user-1',
        role: PrismAgentRole.user,
        timestamp: t0.add(const Duration(seconds: 5)),
        authorLabel: 'Operator',
        blocks: const [PrismAgentMessageBlock.text('Hello agent.')],
      ),
      PrismAgentMessage(
        id: 'asst-1',
        role: PrismAgentRole.assistant,
        timestamp: t0.add(const Duration(seconds: 12)),
        authorLabel: 'Prism Analyst',
        blocks: const [
          PrismAgentMessageBlock.think('Consider response tone.'),
          PrismAgentMessageBlock.text('Hello **Operator**. How can I help?'),
          PrismAgentMessageBlock.plan('1. Greet\n2. Wait for task'),
        ],
      ),
    ];
  }

  group('PrismAgentTranscript', () {
    testWidgets('empty transcript shows placeholder', (tester) async {
      await tester.pumpWidget(
        harness(child: const PrismAgentTranscript(messages: [])),
      );

      expect(find.byType(PrismAgentTranscript), findsOneWidget);
      expect(find.text('No messages'), findsOneWidget);
      expect(find.byKey(const Key('agent-transcript-list')), findsNothing);
    });

    testWidgets('empty without placeholder stays stable', (tester) async {
      await tester.pumpWidget(
        harness(
          child: const PrismAgentTranscript(
            messages: [],
            showEmptyPlaceholder: false,
          ),
        ),
      );

      expect(find.text('No messages'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('single turn renders role and text', (tester) async {
      await tester.pumpWidget(
        harness(
          child: PrismAgentTranscript(
            messages: [
              PrismAgentMessage.text(
                id: 'only',
                role: PrismAgentRole.user,
                text: 'Single turn body',
              ),
            ],
          ),
        ),
      );

      expect(find.byKey(const Key('agent-message-only')), findsOneWidget);
      expect(findVisibleText('Single turn body'), findsOneWidget);
      expect(find.text('User'), findsWidgets);
    });

    testWidgets('multi-turn fixture renders user + assistant + system', (
      tester,
    ) async {
      await tester.pumpWidget(
        harness(child: PrismAgentTranscript(messages: multiTurnFixture())),
      );

      expect(find.byType(PrismAgentTranscript), findsOneWidget);
      expect(find.byKey(const Key('agent-transcript-list')), findsOneWidget);
      expect(findVisibleText('System online.'), findsOneWidget);
      expect(findVisibleText('Hello agent.'), findsOneWidget);
      expect(findVisibleText('Hello'), findsWidgets);
      expect(find.text('Operator'), findsOneWidget);
      expect(find.text('Prism Analyst'), findsOneWidget);
      expect(find.text('System'), findsWidgets);
      expect(find.text('User'), findsWidgets);
      expect(find.text('Assistant'), findsWidgets);
      // Think / plan stubs (plain DSText)
      expect(find.text('Thinking'), findsOneWidget);
      expect(find.text('Plan'), findsOneWidget);
      expect(find.text('Consider response tone.'), findsOneWidget);
    });

    testWidgets('timestamps optional — hidden when disabled', (tester) async {
      final messages = multiTurnFixture();

      await tester.pumpWidget(
        harness(
          child: PrismAgentTranscript(
            messages: messages,
            showTimestamps: false,
          ),
        ),
      );

      // HH:mm:ss labels should not appear when timestamps are off.
      expect(find.textContaining(':'), findsNothing);

      await tester.pumpWidget(
        harness(
          child: PrismAgentTranscript(messages: messages, showTimestamps: true),
        ),
      );
      await tester.pumpAndSettle();

      // At least one timestamp string is rendered.
      expect(find.textContaining(':'), findsWidgets);
    });

    testWidgets('long content is scrollable', (tester) async {
      final long = List.generate(
        20,
        (i) => PrismAgentMessage.text(
          id: 'long-$i',
          role: i.isEven ? PrismAgentRole.user : PrismAgentRole.assistant,
          text: 'Message number $i — ${'word ' * 40}',
        ),
      );

      await tester.pumpWidget(
        harness(height: 320, child: PrismAgentTranscript(messages: long)),
      );

      expect(find.byKey(const Key('agent-message-long-0')), findsOneWidget);
      expect(find.byKey(const Key('agent-transcript-list')), findsOneWidget);

      // Last messages start off-screen; scroll until the final turn mounts.
      await tester.scrollUntilVisible(
        find.byKey(const Key('agent-message-long-19')),
        400,
        scrollable: find.descendant(
          of: find.byKey(const Key('agent-transcript-list')),
          matching: find.byType(Scrollable),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('agent-message-long-19')), findsOneWidget);
      expect(findVisibleText('Message number 19'), findsOneWidget);
    });

    testWidgets('custom block slot embeds host widget', (tester) async {
      await tester.pumpWidget(
        harness(
          child: const PrismAgentTranscript(
            messages: [
              PrismAgentMessage(
                id: 'custom-1',
                role: PrismAgentRole.assistant,
                blocks: [
                  PrismAgentMessageBlock.text('Before tool'),
                  PrismAgentMessageBlock.custom(
                    ColoredBox(
                      key: Key('tool-call-slot'),
                      color: Colors.transparent,
                      child: Text('tool-call-placeholder'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

      expect(find.byKey(const Key('tool-call-slot')), findsOneWidget);
      expect(find.text('tool-call-placeholder'), findsOneWidget);
      expect(findVisibleText('Before tool'), findsOneWidget);
    });

    testWidgets('footer slot renders under list', (tester) async {
      await tester.pumpWidget(
        harness(
          child: PrismAgentTranscript(
            messages: [
              PrismAgentMessage.text(
                id: 'm1',
                role: PrismAgentRole.user,
                text: 'hi',
              ),
            ],
            footer: const Text('disabled-composer'),
          ),
        ),
      );

      expect(find.text('disabled-composer'), findsOneWidget);
      expect(findVisibleText('hi'), findsOneWidget);
    });

    testWidgets('conversation region is labeled for a11y', (tester) async {
      await tester.pumpWidget(
        harness(
          child: PrismAgentTranscript(
            semanticLabel: 'Agent conversation',
            messages: multiTurnFixture(),
          ),
        ),
      );

      final labeled = find.bySemanticsLabel('Agent conversation');
      expect(labeled, findsOneWidget);

      // Message turns carry ordered semantics (Turn N, …).
      expect(find.bySemanticsLabel(RegExp(r'Turn 1,')), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp(r'Turn 2,')), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp(r'Turn 3,')), findsOneWidget);
    });

    testWidgets('plain text mode skips markdown composition', (tester) async {
      await tester.pumpWidget(
        harness(
          child: PrismAgentTranscript(
            renderMarkdown: false,
            messages: [
              PrismAgentMessage.text(
                id: 'md',
                role: PrismAgentRole.assistant,
                text: 'Use **bold** here',
              ),
            ],
          ),
        ),
      );

      // Literal markdown markers remain when markdown is off.
      expect(find.text('Use **bold** here'), findsOneWidget);
      expect(find.byType(PrismMarkdownRenderer), findsNothing);
    });
  });

  group('PrismAgentMessage model', () {
    test('text factory and role labels', () {
      final msg = PrismAgentMessage.text(
        id: 'a',
        role: PrismAgentRole.assistant,
        text: 'hi',
        authorLabel: 'Bot',
      );
      expect(msg.blocks, hasLength(1));
      expect(msg.blocks.first.type, PrismAgentMessageBlockType.text);
      expect(msg.roleLabel, 'Assistant');
      expect(msg.displayAuthor, 'Bot');
      expect(msg.hasContent, isTrue);
    });

    test('equality by id + fields', () {
      const a = PrismAgentMessage(
        id: '1',
        role: PrismAgentRole.user,
        blocks: [PrismAgentMessageBlock.text('x')],
      );
      const b = PrismAgentMessage(
        id: '1',
        role: PrismAgentRole.user,
        blocks: [PrismAgentMessageBlock.text('x')],
      );
      const c = PrismAgentMessage(
        id: '2',
        role: PrismAgentRole.user,
        blocks: [PrismAgentMessageBlock.text('x')],
      );
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('copyWith clears optional fields', () {
      final original = PrismAgentMessage(
        id: '1',
        role: PrismAgentRole.system,
        timestamp: DateTime.utc(2026),
        authorLabel: 'Sys',
        blocks: const [PrismAgentMessageBlock.text('n')],
      );
      final cleared = original.copyWith(
        clearTimestamp: true,
        clearAuthorLabel: true,
      );
      expect(cleared.timestamp, isNull);
      expect(cleared.authorLabel, isNull);
      expect(cleared.displayAuthor, 'System');
    });
  });
}
