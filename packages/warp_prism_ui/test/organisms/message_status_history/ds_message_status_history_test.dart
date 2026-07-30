import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// Task 1605: PrismMessageStatusHistory / DSMessageStatusHistory widget tests.
///
/// Covers: ordered steps with pending/running/success/error, empty steps safe,
/// horizontal + vertical, compact mode, step semantics, model helpers.
/// Fixture-only — no network.
void main() {
  Widget harness({
    required Widget child,
    double width = 560,
    double height = 320,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(width: width, height: height, child: child),
      ),
    );
  }

  List<PrismMessageStatusStep> multiStateSteps() {
    return const [
      PrismMessageStatusStep(
        id: 's1',
        label: 'Retrieving',
        state: PrismMessageStatusStepState.success,
        detail: '42ms',
      ),
      PrismMessageStatusStep(
        id: 's2',
        label: 'Thinking',
        state: PrismMessageStatusStepState.running,
        detail: '…',
      ),
      PrismMessageStatusStep(
        id: 's3',
        label: 'Generating',
        state: PrismMessageStatusStepState.pending,
      ),
      PrismMessageStatusStep(
        id: 's4',
        label: 'Failed',
        state: PrismMessageStatusStepState.error,
        detail: 'timeout',
      ),
    ];
  }

  group('PrismMessageStatusHistory', () {
    testWidgets('renders ordered steps with all states', (tester) async {
      await tester.pumpWidget(
        harness(child: PrismMessageStatusHistory(steps: multiStateSteps())),
      );

      expect(find.byType(PrismMessageStatusHistory), findsOneWidget);
      expect(find.text('Retrieving'), findsOneWidget);
      expect(find.text('Thinking'), findsOneWidget);
      expect(find.text('Generating'), findsOneWidget);
      expect(find.text('Failed'), findsOneWidget);
      expect(find.byKey(const Key('message-status-step-s1')), findsOneWidget);
      expect(find.byKey(const Key('message-status-step-s2')), findsOneWidget);
      expect(find.byKey(const Key('message-status-step-s3')), findsOneWidget);
      expect(find.byKey(const Key('message-status-step-s4')), findsOneWidget);
      // Details visible when not compact
      expect(find.text('42ms'), findsOneWidget);
      expect(find.text('timeout'), findsOneWidget);
    });

    testWidgets('empty steps is safe', (tester) async {
      await tester.pumpWidget(
        harness(child: const PrismMessageStatusHistory(steps: [])),
      );

      expect(find.byType(PrismMessageStatusHistory), findsOneWidget);
      expect(find.text('Retrieving'), findsNothing);
      expect(tester.takeException(), isNull);
      // Empty semantic region present
      expect(
        find.bySemanticsLabel('Message status history, empty'),
        findsOneWidget,
      );
    });

    testWidgets('error-only strip renders', (tester) async {
      await tester.pumpWidget(
        harness(
          child: const PrismMessageStatusHistory(
            steps: [
              PrismMessageStatusStep(
                id: 'err',
                label: 'Tool call',
                state: PrismMessageStatusStepState.error,
                detail: 'refused',
              ),
            ],
          ),
        ),
      );

      expect(find.text('Tool call'), findsOneWidget);
      expect(find.text('refused'), findsOneWidget);
    });

    testWidgets('vertical direction stacks steps', (tester) async {
      await tester.pumpWidget(
        harness(
          child: PrismMessageStatusHistory(
            direction: Axis.vertical,
            steps: multiStateSteps(),
          ),
        ),
      );

      expect(find.text('Retrieving'), findsOneWidget);
      expect(find.text('Thinking'), findsOneWidget);
      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('compact hides detail labels', (tester) async {
      await tester.pumpWidget(
        harness(
          child: PrismMessageStatusHistory(
            compact: true,
            steps: multiStateSteps(),
          ),
        ),
      );

      expect(find.text('Retrieving'), findsOneWidget);
      expect(find.text('42ms'), findsNothing);
      expect(find.text('timeout'), findsNothing);
    });

    testWidgets('step semantics include index, label, and state', (
      tester,
    ) async {
      await tester.pumpWidget(
        harness(
          child: const PrismMessageStatusHistory(
            steps: [
              PrismMessageStatusStep(
                id: 'sem-1',
                label: 'Retrieving',
                state: PrismMessageStatusStepState.success,
                detail: '10ms',
              ),
            ],
          ),
        ),
      );

      expect(
        find.bySemanticsLabel(RegExp(r'Step 1.*Retrieving.*Success')),
        findsOneWidget,
      );
    });

    testWidgets('region semantic label is exposed', (tester) async {
      await tester.pumpWidget(
        harness(
          child: PrismMessageStatusHistory(
            semanticLabel: 'Agent run pipeline',
            steps: multiStateSteps(),
          ),
        ),
      );

      expect(find.bySemanticsLabel('Agent run pipeline'), findsOneWidget);
    });

    testWidgets('composes inside transcript custom block', (tester) async {
      await tester.pumpWidget(
        harness(
          height: 480,
          child: PrismAgentTranscript(
            renderMarkdown: false,
            messages: [
              PrismAgentMessage(
                id: 'm1',
                role: PrismAgentRole.assistant,
                blocks: [
                  const PrismAgentMessageBlock.text('Checking health'),
                  PrismAgentMessageBlock.custom(
                    PrismMessageStatusHistory(steps: multiStateSteps()),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

      expect(find.byType(PrismMessageStatusHistory), findsOneWidget);
      expect(find.text('Retrieving'), findsOneWidget);
      expect(find.text('Checking health'), findsOneWidget);
    });
  });

  group('PrismMessageStatusStep model', () {
    test('stateLabel and stateColor map correctly', () {
      const pending = PrismMessageStatusStep(
        id: 'p',
        label: 'P',
        state: PrismMessageStatusStepState.pending,
      );
      const running = PrismMessageStatusStep(
        id: 'r',
        label: 'R',
        state: PrismMessageStatusStepState.running,
      );
      const success = PrismMessageStatusStep(
        id: 's',
        label: 'S',
        state: PrismMessageStatusStepState.success,
      );
      const error = PrismMessageStatusStep(
        id: 'e',
        label: 'E',
        state: PrismMessageStatusStepState.error,
      );

      expect(pending.stateLabel, 'Pending');
      expect(running.stateLabel, 'Running');
      expect(success.stateLabel, 'Success');
      expect(error.stateLabel, 'Error');
      expect(running.isAnimated, isTrue);
      expect(pending.isAnimated, isFalse);
      expect(success.stateColor, PrismColors.statusSuccess);
      expect(error.stateColor, PrismColors.statusError);
    });

    test('copyWith and equality', () {
      const a = PrismMessageStatusStep(
        id: '1',
        label: 'Step',
        state: PrismMessageStatusStepState.pending,
      );
      final b = a.copyWith(state: PrismMessageStatusStepState.success);
      expect(a == b, isFalse);
      expect(b.state, PrismMessageStatusStepState.success);
      expect(a.copyWith(), a);
    });
  });
}
