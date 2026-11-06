// Honest-unknown + abstention vocabulary suite (Task 1869, F-02).
//
// EXPERIMENTAL IDS vocabulary: inspection `unknown`, query
// `unknown` / `abstained` / `notAttempted`, with the fail-closed rule
// suite-proven: an indeterminate query is never success, never verified,
// never enabled.
//
// Failing-first provenance: written before the new statuses existed (Red),
// turned green by the implementation.

import 'package:test/test.dart';
import 'package:warp_prism_interaction/warp_prism_interaction.dart';

QueryIntent intent([String token = 'q-1']) =>
    QueryIntent(rawQuery: 'service:auth', queryToken: token);

void main() {
  group('inspection unknown vocabulary exists', () {
    test('InspectionLifecycle declares unknown', () {
      expect(InspectionLifecycle.values, contains(InspectionLifecycle.unknown));
    });

    test('unknown payload is not active, proposed, or dismissed', () {
      final payload = InspectionPayload<String>(
        intent: InspectionIntent(target: 'node-1'),
        status: InspectionLifecycle.unknown,
      );

      expect(payload.isUnknown, isTrue);
      expect(payload.isActive, isFalse);
      expect(payload.isProposed, isFalse);
      expect(payload.isDismissed, isFalse);
    });

    test(
      'transition table resolves unknown outward, never inward by trick',
      () {
        expect(
          inspectionTransitionTable.resolveNextState(
            InspectionLifecycle.unknown,
            InspectionTrigger.propose,
          ),
          equals(InspectionLifecycle.proposed),
        );
        expect(
          inspectionTransitionTable.resolveNextState(
            InspectionLifecycle.unknown,
            InspectionTrigger.activate,
          ),
          equals(InspectionLifecycle.active),
        );
        expect(
          inspectionTransitionTable.resolveNextState(
            InspectionLifecycle.unknown,
            InspectionTrigger.dismiss,
          ),
          equals(InspectionLifecycle.dismissed),
        );
        // No trigger manufactures unknown from a settled lifecycle position.
        for (final state in [
          InspectionLifecycle.proposed,
          InspectionLifecycle.active,
          InspectionLifecycle.dismissed,
        ]) {
          for (final trigger in InspectionTrigger.values) {
            final target =
                inspectionTransitionTable.targetStates[(state, trigger)];
            expect(
              target,
              isNot(equals(InspectionLifecycle.unknown)),
              reason: '($state, $trigger) must never resolve to unknown',
            );
          }
        }
      },
    );

    test('fail-closed: unknown session is never reported as active', () {
      final notifier = InspectionNotifier<String>(
        initialSession: InspectionPayload<String>(
          intent: InspectionIntent(target: 'node-1'),
          status: InspectionLifecycle.unknown,
        ),
      );

      expect(notifier.hasActiveInspection, isFalse);
    });
  });

  group('query abstention vocabulary exists', () {
    test('QueryStatus declares unknown, abstained, notAttempted', () {
      expect(QueryStatus.values, contains(QueryStatus.unknown));
      expect(QueryStatus.values, contains(QueryStatus.abstained));
      expect(QueryStatus.values, contains(QueryStatus.notAttempted));
    });

    test('indeterminate constructors are flagged indeterminate', () {
      final q = intent();
      expect(QueryState<String>.unknown(intent: q).isIndeterminate, isTrue);
      expect(QueryState<String>.abstained(intent: q).isIndeterminate, isTrue);
      expect(
        QueryState<String>.notAttempted(intent: q).isIndeterminate,
        isTrue,
      );
      expect(QueryState<String>.unknown(intent: q).isUnknown, isTrue);
      expect(QueryState<String>.abstained(intent: q).isAbstained, isTrue);
      expect(QueryState<String>.notAttempted(intent: q).isNotAttempted, isTrue);
    });

    test('determinate states stay non-indeterminate', () {
      final q = intent();
      expect(const QueryState<String>.idle().isIndeterminate, isFalse);
      expect(QueryState<String>.running(q).isIndeterminate, isFalse);
      expect(
        QueryState<String>.complete(
          intent: q,
          result: QueryResultReference(token: 'r', totalCount: 1),
        ).isIndeterminate,
        isFalse,
      );
      expect(
        QueryState<String>.error(intent: q, error: 'boom').isIndeterminate,
        isFalse,
      );
      expect(QueryState<String>.cancelled(intent: q).isIndeterminate, isFalse);
    });
  });

  group('fail-closed: unknown is not success', () {
    test('indeterminate states never report isComplete', () {
      final q = intent();
      expect(QueryState<String>.unknown(intent: q).isComplete, isFalse);
      expect(QueryState<String>.abstained(intent: q).isComplete, isFalse);
      expect(QueryState<String>.notAttempted(intent: q).isComplete, isFalse);
    });

    test('controller can reach unknown without ever reporting complete', () {
      final controller = QueryController<String>();
      final execution = controller.submit(intent());
      final committed = controller.markUnknownExecution(
        execution,
        detail: 'verification inconclusive',
      );

      expect(committed, isTrue);
      expect(controller.state.isUnknown, isTrue);
      expect(controller.state.isComplete, isFalse);
    });
  });

  group('fail-closed: unknown is not verified', () {
    test('indeterminate states carry no verified result reference', () {
      final q = intent();
      expect(QueryState<String>.unknown(intent: q).result, isNull);
      expect(QueryState<String>.abstained(intent: q).result, isNull);
      expect(QueryState<String>.notAttempted(intent: q).result, isNull);
    });

    test('abstained records the reason instead of a result', () {
      final state = QueryState<String>.abstained(
        intent: intent(),
        reason: 'declined: insufficient evidence',
      );

      expect(state.reason, equals('declined: insufficient evidence'));
      expect(state.result, isNull);
      expect(state.isComplete, isFalse);
    });
  });

  group('fail-closed: unknown is not enabled', () {
    test('indeterminate states never report isRunning', () {
      final q = intent();
      expect(QueryState<String>.unknown(intent: q).isRunning, isFalse);
      expect(QueryState<String>.abstained(intent: q).isRunning, isFalse);
      expect(QueryState<String>.notAttempted(intent: q).isRunning, isFalse);
    });

    test('controller refuses outcome commits from indeterminate states', () {
      final controller = QueryController<String>();
      final execution = controller.submit(intent());
      expect(controller.markUnknownExecution(execution), isTrue);

      // Unknown is settled-out of the running path: complete/fail/cancel
      // triggers are rejected, and the controller is not running.
      expect(controller.isRunning, isFalse);
      expect(
        () => queryTransitionTable.validateTransition(
          controller.state.status,
          QueryTrigger.complete,
        ),
        throwsStateError,
      );
      expect(
        () => queryTransitionTable.validateTransition(
          controller.state.status,
          QueryTrigger.cancel,
        ),
        throwsStateError,
      );
    });

    test('stale handle cannot markUnknown into a newer execution', () {
      final controller = QueryController<String>();
      final first = controller.submit(intent('tok-1'));
      controller.submit(intent('tok-2'));

      expect(controller.markUnknownExecution(first), isFalse);
      expect(controller.state.isRunning, isTrue);
      expect(controller.state.intent!.queryToken, equals('tok-2'));
    });
  });

  group('abstention lifecycle transitions', () {
    test('skip records a planned-but-never-submitted query', () {
      final controller = QueryController<String>();
      controller.skip(intent());

      expect(controller.state.isNotAttempted, isTrue);
      expect(controller.state.isIndeterminate, isTrue);
    });

    test('notAttempted can still be submitted, then abstained, then reset', () {
      final controller = QueryController<String>();
      controller.skip(intent());
      final execution = controller.submit(intent());
      expect(controller.state.isRunning, isTrue);

      expect(controller.abstainExecution(execution), isTrue);
      expect(controller.state.isAbstained, isTrue);
      expect(controller.state.isComplete, isFalse);

      controller.reset();
      expect(controller.state.isIdle, isTrue);
    });

    test('legacy uncorrelated markUnknown is rejected like complete/fail', () {
      final controller = QueryController<String>();
      controller.submit(intent('tok-1'));

      expect(controller.markUnknown(), isFalse);
      expect(controller.state.isRunning, isTrue);
    });
  });
}
