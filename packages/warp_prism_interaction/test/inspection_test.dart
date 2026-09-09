import 'package:test/test.dart';
import 'package:warp_prism_interaction/warp_prism_interaction.dart';

void main() {
  group('InspectionIntent', () {
    test('instantiation, attributes, and value equality', () {
      final intent1 = InspectionIntent<String>(
        target: 'entity-42',
        targetType: 'node',
        reason: 'user_click',
        context: {'source': 'graph_canvas'},
      );

      final intent2 = InspectionIntent<String>(
        target: 'entity-42',
        targetType: 'node',
        reason: 'user_click',
        context: {'source': 'graph_canvas'},
      );

      final intent3 = InspectionIntent<String>(
        target: 'entity-43',
        targetType: 'node',
        reason: 'user_click',
      );

      expect(intent1.target, equals('entity-42'));
      expect(intent1.targetType, equals('node'));
      expect(intent1.reason, equals('user_click'));
      expect(intent1.context['source'], equals('graph_canvas'));
      expect(intent1, equals(intent2));
      expect(intent1.hashCode, equals(intent2.hashCode));
      expect(intent1, isNot(equals(intent3)));
    });
  });

  group('InspectionLifecycle & TransitionTable', () {
    test('valid transitions in transition table', () {
      expect(
        inspectionTransitionTable.canTransition(
          InspectionLifecycle.proposed,
          InspectionTrigger.activate,
        ),
        isTrue,
      );
      expect(
        inspectionTransitionTable.canTransition(
          InspectionLifecycle.active,
          InspectionTrigger.dismiss,
        ),
        isTrue,
      );
      expect(
        inspectionTransitionTable.canTransition(
          InspectionLifecycle.dismissed,
          InspectionTrigger.propose,
        ),
        isTrue,
      );
    });

    test('invalid transition throws StateError', () {
      expect(
        () => inspectionTransitionTable.validateTransition(
          InspectionLifecycle.dismissed,
          InspectionTrigger.dismiss,
        ),
        throwsStateError,
      );
    });
  });

  group('InspectionPayload', () {
    test('payload lifecycle states and transitions', () {
      final intent = InspectionIntent<String>(target: 'node-99');
      final proposed = InspectionPayload<String>(
        intent: intent,
        status: InspectionLifecycle.proposed,
      );

      expect(proposed.isProposed, isTrue);
      expect(proposed.isActive, isFalse);
      expect(proposed.isDismissed, isFalse);
      expect(proposed.target, equals('node-99'));

      final active = proposed.transitionTo(InspectionLifecycle.active);
      expect(active.isActive, isTrue);
      expect(active.isProposed, isFalse);
      expect(active.dismissedAt, isNull);

      final dismissed = active.transitionTo(InspectionLifecycle.dismissed);
      expect(dismissed.isDismissed, isTrue);
      expect(dismissed.isActive, isFalse);
      expect(dismissed.dismissedAt, isNotNull);
    });
  });

  group('InspectionNotifier', () {
    test('propose -> activate -> dismiss -> reset lifecycle workflow', () {
      final notifier = InspectionNotifier<String>();
      final events = <InspectionPayload<String>?>[];

      notifier.addListener(events.add);

      expect(notifier.session, isNull);
      expect(notifier.hasActiveInspection, isFalse);

      // 1. Propose
      final intent = InspectionIntent<String>(
        target: 'node-1',
        reason: 'hover',
      );
      notifier.propose(intent);

      expect(notifier.session, isNotNull);
      expect(notifier.session!.isProposed, isTrue);
      expect(notifier.hasActiveInspection, isFalse);
      expect(events.length, equals(1));

      // 2. Activate
      notifier.activate();
      expect(notifier.session!.isActive, isTrue);
      expect(notifier.hasActiveInspection, isTrue);
      expect(events.length, equals(2));

      // 3. Dismiss
      notifier.dismiss();
      expect(notifier.session!.isDismissed, isTrue);
      expect(notifier.hasActiveInspection, isFalse);
      expect(events.length, equals(3));

      // 4. Reset
      notifier.reset();
      expect(notifier.session, isNull);
      expect(events.length, equals(4));
    });

    test('direct activate with new intent', () {
      final notifier = InspectionNotifier<String>();
      final intent = InspectionIntent<String>(
        target: 'node-2',
        reason: 'click',
      );

      notifier.activate(intent);
      expect(notifier.hasActiveInspection, isTrue);
      expect(notifier.session!.target, equals('node-2'));
    });

    test('illegal activation throws StateError', () {
      final notifier = InspectionNotifier<String>();
      // Activating without an intent or proposed session
      expect(() => notifier.activate(), throwsStateError);

      // Dismissing when no session exists
      expect(() => notifier.dismiss(), throwsStateError);
    });

    test('disposal prevents further mutations', () {
      final notifier = InspectionNotifier<String>();
      notifier.dispose();
      expect(notifier.isDisposed, isTrue);

      expect(
        () => notifier.propose(InspectionIntent<String>(target: 'item')),
        throwsStateError,
      );
      expect(() => notifier.activate(), throwsStateError);
      expect(() => notifier.dismiss(), throwsStateError);
      expect(() => notifier.reset(), throwsStateError);
    });
  });
}
