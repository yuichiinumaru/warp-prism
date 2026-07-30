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

/// Task 1511: PrismAiAnalystPanel / DSAiAnalystPanel widget + controller tests.
///
/// Covers: multi-turn fixtures, send + scripted reply, empty, streaming,
/// error fixture, a11y send label, alias export. Fixture-only — no network.
void main() {
  Widget harness({
    required Widget child,
    double width = 420,
    double height = 560,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(width: width, height: height, child: child),
      ),
    );
  }

  group('PrismAiAnalystTurn model', () {
    test('copyWith and equality', () {
      const a = PrismAiAnalystTurn(
        id: 't1',
        role: PrismAiAnalystRole.user,
        content: 'hi',
      );
      final b = a.copyWith(content: 'hello');
      expect(a == b, isFalse);
      expect(b.content, 'hello');
      expect(a.roleLabel, 'User');
      expect(a.displayAuthor, 'User');
      expect(a.hasContent, isTrue);
      expect(a.isStreaming, isFalse);
      expect(a.isError, isFalse);

      final streaming = a.copyWith(
        role: PrismAiAnalystRole.assistant,
        status: PrismAiAnalystTurnStatus.streaming,
        content: '',
      );
      expect(streaming.isStreaming, isTrue);
      expect(streaming.hasContent, isFalse);
    });

    test('default fixture reply is deterministic and offline', () {
      final history = prismAiAnalystFixtureTurns();
      final brief = prismAiAnalystDefaultFixtureReply('brief me', history);
      expect(brief, contains('Fixture briefing'));
      expect(brief.toLowerCase(), isNot(contains('api key value')));

      final health = prismAiAnalystDefaultFixtureReply('health check', history);
      expect(health, contains('healthy'));

      final echo = prismAiAnalystDefaultFixtureReply('ping', history);
      expect(echo, contains('fixture-only'));
      expect(echo, contains('ping'));

      expect(
        () => prismAiAnalystDefaultFixtureReply('force error now', history),
        throwsA(isA<StateError>()),
      );
    });

    test('fixture turns seed multi-role conversation', () {
      final turns = prismAiAnalystFixtureTurns();
      expect(turns.length, greaterThanOrEqualTo(4));
      expect(turns.first.role, PrismAiAnalystRole.system);
      expect(turns.any((t) => t.role == PrismAiAnalystRole.user), isTrue);
      expect(turns.any((t) => t.role == PrismAiAnalystRole.assistant), isTrue);
    });
  });

  group('PrismAiAnalystController', () {
    test('send appends user + scripted assistant reply', () async {
      final controller = PrismAiAnalystController(
        initialTurns: const [],
        simulateStreaming: false,
        streamSimulationDelay: Duration.zero,
        now: () => DateTime.utc(2026, 7, 11, 12, 0, 0),
      );

      await controller.send('Check health');
      expect(controller.turns.length, 2);
      expect(controller.turns[0].role, PrismAiAnalystRole.user);
      expect(controller.turns[0].content, 'Check health');
      expect(controller.turns[1].role, PrismAiAnalystRole.assistant);
      expect(controller.turns[1].status, PrismAiAnalystTurnStatus.complete);
      expect(controller.turns[1].content.toLowerCase(), contains('healthy'));
      expect(controller.isBusy, isFalse);
      controller.dispose();
    });

    test('send with streaming simulation then completes', () async {
      final controller = PrismAiAnalystController(
        simulateStreaming: true,
        streamSimulationDelay: Duration.zero,
      );

      final future = controller.send('overview please');
      // After microtask/sync start, busy may flip; await full cycle.
      await future;
      expect(controller.turns.length, 2);
      expect(controller.turns.last.status, PrismAiAnalystTurnStatus.complete);
      expect(controller.turns.last.content, contains('Fixture briefing'));
      controller.dispose();
    });

    test('error fixture path sets error status', () async {
      final controller = PrismAiAnalystController(
        simulateStreaming: false,
        streamSimulationDelay: Duration.zero,
      );

      await controller.send('please fail this');
      expect(controller.turns.length, 2);
      expect(controller.turns.last.status, PrismAiAnalystTurnStatus.error);
      expect(controller.turns.last.content, contains('Fixture error'));
      expect(controller.lastError, isNotNull);
      controller.dispose();
    });

    test('empty and whitespace messages are ignored', () async {
      final controller = PrismAiAnalystController(
        simulateStreaming: false,
        streamSimulationDelay: Duration.zero,
      );
      await controller.send('   ');
      await controller.send('');
      expect(controller.turns, isEmpty);
      controller.dispose();
    });

    test('clear resets turns', () async {
      final controller = PrismAiAnalystController(
        initialTurns: prismAiAnalystFixtureTurns(),
        simulateStreaming: false,
      );
      expect(controller.isEmpty, isFalse);
      controller.clear();
      expect(controller.isEmpty, isTrue);
      controller.dispose();
    });

    test('dispose during stream does not notify after dispose', () async {
      final controller = PrismAiAnalystController(
        initialTurns: const [],
        simulateStreaming: true,
        streamSimulationDelay: const Duration(milliseconds: 100),
      );

      var notifications = 0;
      controller.addListener(() => notifications++);

      final pending = controller.send('ping');
      // Allow streaming placeholder notify, then dispose mid-stream.
      await Future<void>.delayed(Duration.zero);
      expect(controller.isBusy, isTrue);
      final notificationsBeforeDispose = notifications;

      controller.dispose();
      expect(controller.isDisposed, isTrue);

      await pending;
      // Pump past the stream delay so any late notify would fire.
      await Future<void>.delayed(const Duration(milliseconds: 120));

      expect(notifications, notificationsBeforeDispose);
      expect(controller.isBusy, isFalse);
    });
  });

  group('PrismAiAnalystPanel widget', () {
    testWidgets('renders multi-turn conversation from fixtures', (
      tester,
    ) async {
      await tester.pumpWidget(
        harness(
          height: 720,
          child: PrismAiAnalystPanel(
            initialTurns: prismAiAnalystFixtureTurns(),
            simulateStreaming: false,
            streamSimulationDelay: Duration.zero,
          ),
        ),
      );

      expect(find.byType(PrismAiAnalystPanel), findsOneWidget);
      expect(find.byKey(const Key('ds-ai-analyst-panel')), findsOneWidget);
      expect(find.byKey(const Key('ds-ai-analyst-transcript')), findsOneWidget);
      expect(
        findVisibleText('Give me a brief workspace overview.'),
        findsOneWidget,
      );
      // Later turns may need scroll in dense fixture sessions.
      await tester.scrollUntilVisible(
        find.byKey(const Key('ds-ai-analyst-turn-ai-user-2')),
        120,
        scrollable: find.descendant(
          of: find.byKey(const Key('ds-ai-analyst-transcript')),
          matching: find.byType(Scrollable),
        ),
      );
      expect(findVisibleText('Check provider health.'), findsOneWidget);
      expect(find.textContaining('Fixture-only'), findsWidgets);
      expect(find.text('Operator'), findsWidgets);
      expect(find.text('Prism Analyst'), findsWidgets);
    });

    testWidgets('empty state when no turns', (tester) async {
      await tester.pumpWidget(
        harness(
          child: const PrismAiAnalystPanel(
            initialTurns: [],
            simulateStreaming: false,
            streamSimulationDelay: Duration.zero,
          ),
        ),
      );

      expect(find.byKey(const Key('ds-ai-analyst-empty')), findsOneWidget);
      expect(find.text('No conversation yet'), findsOneWidget);
      expect(find.byKey(const Key('ds-ai-analyst-transcript')), findsNothing);
    });

    testWidgets('send message appends scripted reply via composer', (
      tester,
    ) async {
      final controller = PrismAiAnalystController(
        initialTurns: const [],
        simulateStreaming: false,
        streamSimulationDelay: Duration.zero,
        now: () => DateTime.utc(2026, 7, 11, 12, 0, 0),
      );

      await tester.pumpWidget(
        harness(child: PrismAiAnalystPanel(controller: controller)),
      );

      expect(find.byKey(const Key('ds-ai-analyst-empty')), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('ds-ai-analyst-composer-field')),
        'health status please',
      );
      await tester.tap(find.byKey(const Key('ds-ai-analyst-send')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('ds-ai-analyst-empty')), findsNothing);
      expect(findVisibleText('health status please'), findsOneWidget);
      expect(findVisibleText('healthy'), findsWidgets);
      expect(controller.turns.length, 2);

      controller.dispose();
    });

    testWidgets('streaming placeholder appears then resolves', (tester) async {
      final controller = PrismAiAnalystController(
        initialTurns: const [],
        simulateStreaming: true,
        streamSimulationDelay: const Duration(milliseconds: 50),
      );

      await tester.pumpWidget(
        harness(child: PrismAiAnalystPanel(controller: controller)),
      );

      await tester.enterText(
        find.byKey(const Key('ds-ai-analyst-composer-field')),
        'ping',
      );
      await tester.tap(find.byKey(const Key('ds-ai-analyst-send')));
      await tester.pump(); // start send

      // Streaming placeholder should show while delay is pending.
      expect(find.byKey(const Key('ds-ai-analyst-streaming')), findsOneWidget);
      expect(find.textContaining('preparing a reply'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsWidgets);

      await tester.pump(const Duration(milliseconds: 60));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('ds-ai-analyst-streaming')), findsNothing);
      expect(findVisibleText('fixture-only'), findsWidgets);
      controller.dispose();
    });

    testWidgets('dispose panel during stream produces no Flutter errors', (
      tester,
    ) async {
      final controller = PrismAiAnalystController(
        initialTurns: const [],
        simulateStreaming: true,
        streamSimulationDelay: const Duration(milliseconds: 80),
      );

      await tester.pumpWidget(
        harness(child: PrismAiAnalystPanel(controller: controller)),
      );

      await tester.enterText(
        find.byKey(const Key('ds-ai-analyst-composer-field')),
        'ping',
      );
      await tester.tap(find.byKey(const Key('ds-ai-analyst-send')));
      await tester.pump();
      expect(find.byKey(const Key('ds-ai-analyst-streaming')), findsOneWidget);

      // Remove panel mid-stream (external controller disposed after unmount).
      await tester.pumpWidget(harness(child: const SizedBox.shrink()));
      controller.dispose();

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();
      // No FlutterError from use-after-dispose (implicit via test binding).
    });

    testWidgets('reduced motion uses static streaming indicator', (
      tester,
    ) async {
      final controller = PrismAiAnalystController(
        initialTurns: const [],
        simulateStreaming: true,
        streamSimulationDelay: const Duration(milliseconds: 50),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: Scaffold(
              body: SizedBox(
                width: 420,
                height: 560,
                child: PrismAiAnalystPanel(controller: controller),
              ),
            ),
          ),
        ),
      );

      await tester.enterText(
        find.byKey(const Key('ds-ai-analyst-composer-field')),
        'ping',
      );
      await tester.tap(find.byKey(const Key('ds-ai-analyst-send')));
      await tester.pump();

      expect(find.byKey(const Key('ds-ai-analyst-streaming')), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byIcon(Icons.hourglass_top_rounded), findsWidgets);

      await tester.pump(const Duration(milliseconds: 60));
      await tester.pumpAndSettle();
      controller.dispose();
    });

    testWidgets('error fixture turn renders error chrome', (tester) async {
      await tester.pumpWidget(
        harness(
          child: PrismAiAnalystPanel(
            initialTurns: [
              PrismAiAnalystTurn.text(
                id: 'u1',
                role: PrismAiAnalystRole.user,
                content: 'break it',
              ),
              prismAiAnalystErrorFixtureTurn(),
            ],
            simulateStreaming: false,
            streamSimulationDelay: Duration.zero,
          ),
        ),
      );

      expect(find.textContaining('Fixture error'), findsOneWidget);
      expect(find.text('Error'), findsWidgets);
    });

    testWidgets('send control has a11y label', (tester) async {
      final handle = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          harness(
            child: const PrismAiAnalystPanel(
              initialTurns: [],
              simulateStreaming: false,
              streamSimulationDelay: Duration.zero,
            ),
          ),
        );

        // IconButton exposes tooltip as semantics/tooltip for the send control.
        expect(
          find.byTooltip(PrismAiAnalystPanel.sendControlSemanticLabel),
          findsOneWidget,
        );

        final panel = tester.getSemantics(
          find.byKey(const Key('ds-ai-analyst-panel')),
        );
        expect(panel.label, contains(PrismAiAnalystPanel.panelSemanticLabel));

        final field = tester.getSemantics(find.byType(TextField));
        expect(
          field.label,
          contains(PrismAiAnalystPanel.composerFieldSemanticLabel),
        );

        // Touch target ≥ 48 for send.
        final sendBox = tester.getSize(
          find.byKey(const Key('ds-ai-analyst-send')),
        );
        expect(sendBox.width, greaterThanOrEqualTo(48));
        expect(sendBox.height, greaterThanOrEqualTo(48));
      } finally {
        handle.dispose();
      }
    });

    testWidgets('custom reply adapter is used', (tester) async {
      final controller = PrismAiAnalystController(
        simulateStreaming: false,
        streamSimulationDelay: Duration.zero,
        replyAdapter: (msg, history) => 'CUSTOM:$msg',
      );

      await tester.pumpWidget(
        harness(child: PrismAiAnalystPanel(controller: controller)),
      );

      await tester.enterText(
        find.byKey(const Key('ds-ai-analyst-composer-field')),
        'alpha',
      );
      await tester.tap(find.byKey(const Key('ds-ai-analyst-send')));
      await tester.pumpAndSettle();

      expect(findVisibleText('CUSTOM:alpha'), findsOneWidget);
      controller.dispose();
    });

    test('public aliases construct typed models and controller', () {
      const turn = PrismAiAnalystTurn(
        id: 'alias-1',
        role: PrismAiAnalystRole.assistant,
        content: 'ok',
        status: PrismAiAnalystTurnStatus.complete,
      );
      expect(turn.id, 'alias-1');
      final controller = PrismAiAnalystController(
        initialTurns: [turn],
        simulateStreaming: false,
      );
      expect(controller.turns.single.content, 'ok');
      controller.dispose();
    });
  });
}
