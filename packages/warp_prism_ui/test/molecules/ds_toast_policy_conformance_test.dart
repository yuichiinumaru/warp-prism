// Toast policy conformance (Task 1867, part d).
//
// Proves the PrismToastManager policy: cap, sticky, action, hand-back, and
// onDismiss-only-on-close. Removal reasons are stable API
// ([PrismToastRemovalReason]); every removal hands back, but only an explicit
// close fires `onCloseDismissed`.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/src/molecules/molecules.dart';
import 'package:warp_prism_ui/src/tokens/tokens.dart';

DSToastEntry _entry(
  String id, {
  String? actionLabel,
  bool dismissOnAction = true,
  Duration duration = Duration.zero,
  VoidCallback? onAction,
}) {
  return DSToastEntry(
    id: id,
    severity: DSToastSeverity.info,
    title: 'Toast $id',
    actionLabel: actionLabel,
    dismissOnAction: dismissOnAction,
    duration: duration,
    onAction: onAction,
  );
}

Widget _wrapWithPolicyManager({
  required GlobalKey<DSToastManagerState> managerKey,
  required Widget child,
  int maxVisible = 5,
  PrismToastHandBack? onHandBack,
  void Function(DSToastEntry entry)? onCloseDismissed,
}) {
  return MaterialApp(
    home: Scaffold(
      body: DSToastManager(
        key: managerKey,
        maxVisible: maxVisible,
        onHandBack: onHandBack,
        onCloseDismissed: onCloseDismissed,
        child: child,
      ),
    ),
  );
}

Future<void> _settleToast(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(DSMotion.slow);
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  group('toast_policy_1867 cap', () {
    testWidgets('[toast_1867_cap_eviction] oldest evicted + handed back', (
      tester,
    ) async {
      final managerKey = GlobalKey<DSToastManagerState>();
      final handedBack = <String>[];
      final reasons = <PrismToastRemovalReason>[];
      var closes = 0;
      await tester.pumpWidget(
        _wrapWithPolicyManager(
          managerKey: managerKey,
          maxVisible: 2,
          onHandBack: (entry, reason) {
            handedBack.add(entry.id);
            reasons.add(reason);
          },
          onCloseDismissed: (_) => closes++,
          child: const SizedBox.shrink(),
        ),
      );

      managerKey.currentState!.show(_entry('cap-1'));
      managerKey.currentState!.show(_entry('cap-2'));
      managerKey.currentState!.show(_entry('cap-3'));
      await _settleToast(tester);

      expect(find.text('Toast cap-1'), findsNothing);
      expect(find.text('Toast cap-2'), findsOneWidget);
      expect(find.text('Toast cap-3'), findsOneWidget);
      expect(handedBack, equals(['cap-1']));
      expect(reasons, equals([PrismToastRemovalReason.evicted]));
      // Eviction is not a close.
      expect(closes, isZero);
    });
  });

  group('toast_policy_1867 sticky', () {
    testWidgets('[toast_1867_sticky_persists] zero duration never expires', (
      tester,
    ) async {
      final managerKey = GlobalKey<DSToastManagerState>();
      final handedBack = <String>[];
      await tester.pumpWidget(
        _wrapWithPolicyManager(
          managerKey: managerKey,
          onHandBack: (entry, _) => handedBack.add(entry.id),
          child: const SizedBox.shrink(),
        ),
      );

      managerKey.currentState!.show(_entry('sticky-1'));
      await _settleToast(tester);
      await tester.pump(const Duration(seconds: 60));
      await tester.pump(DSMotion.slow);

      expect(find.text('Toast sticky-1'), findsOneWidget);
      expect(handedBack, isEmpty);
    });
  });

  group('toast_policy_1867 action', () {
    testWidgets('[toast_1867_action_keep_open] fires without dismissing', (
      tester,
    ) async {
      final managerKey = GlobalKey<DSToastManagerState>();
      var actionCount = 0;
      var closes = 0;
      final handedBack = <String>[];
      await tester.pumpWidget(
        _wrapWithPolicyManager(
          managerKey: managerKey,
          onHandBack: (entry, _) => handedBack.add(entry.id),
          onCloseDismissed: (_) => closes++,
          child: const SizedBox.shrink(),
        ),
      );

      managerKey.currentState!.show(
        _entry(
          'action-keep',
          actionLabel: 'Retry',
          dismissOnAction: false,
          onAction: () => actionCount++,
        ),
      );
      await _settleToast(tester);

      await tester.tap(find.text('Retry'));
      await _settleToast(tester);

      expect(actionCount, 1);
      expect(find.text('Toast action-keep'), findsOneWidget);
      expect(handedBack, isEmpty);
      expect(closes, isZero);
    });

    testWidgets('[toast_1867_action_dismiss] hands back actioned, not closed', (
      tester,
    ) async {
      final managerKey = GlobalKey<DSToastManagerState>();
      var actionCount = 0;
      var closes = 0;
      final reasons = <PrismToastRemovalReason>[];
      await tester.pumpWidget(
        _wrapWithPolicyManager(
          managerKey: managerKey,
          onHandBack: (_, reason) => reasons.add(reason),
          onCloseDismissed: (_) => closes++,
          child: const SizedBox.shrink(),
        ),
      );

      managerKey.currentState!.show(
        _entry(
          'action-drop',
          actionLabel: 'Undo',
          onAction: () => actionCount++,
        ),
      );
      await _settleToast(tester);

      await tester.tap(find.text('Undo'));
      await _settleToast(tester);

      expect(actionCount, 1);
      expect(find.text('Toast action-drop'), findsNothing);
      expect(reasons, equals([PrismToastRemovalReason.actioned]));
      expect(closes, isZero);
    });
  });

  group('toast_policy_1867 hand-back', () {
    testWidgets('[toast_1867_expiry_hand_back] expiry hands back expired', (
      tester,
    ) async {
      final managerKey = GlobalKey<DSToastManagerState>();
      var closes = 0;
      final reasons = <PrismToastRemovalReason>[];
      await tester.pumpWidget(
        _wrapWithPolicyManager(
          managerKey: managerKey,
          onHandBack: (_, reason) => reasons.add(reason),
          onCloseDismissed: (_) => closes++,
          child: const SizedBox.shrink(),
        ),
      );

      managerKey.currentState!.show(
        _entry('expiry-1', duration: const Duration(seconds: 1)),
      );
      await _settleToast(tester);
      expect(find.text('Toast expiry-1'), findsOneWidget);

      await tester.pump(const Duration(seconds: 1));
      await _settleToast(tester);

      expect(find.text('Toast expiry-1'), findsNothing);
      expect(reasons, equals([PrismToastRemovalReason.expired]));
      // Expiry is not a close.
      expect(closes, isZero);
    });

    testWidgets('[toast_1867_clear_hand_back] clear hands back cleared', (
      tester,
    ) async {
      final managerKey = GlobalKey<DSToastManagerState>();
      var closes = 0;
      final reasons = <PrismToastRemovalReason>[];
      await tester.pumpWidget(
        _wrapWithPolicyManager(
          managerKey: managerKey,
          onHandBack: (_, reason) => reasons.add(reason),
          onCloseDismissed: (_) => closes++,
          child: const SizedBox.shrink(),
        ),
      );

      managerKey.currentState!.show(_entry('clear-1'));
      managerKey.currentState!.show(_entry('clear-2'));
      await _settleToast(tester);

      managerKey.currentState!.clear();
      await _settleToast(tester);

      expect(find.text('Toast clear-1'), findsNothing);
      expect(find.text('Toast clear-2'), findsNothing);
      expect(
        reasons,
        equals([
          PrismToastRemovalReason.cleared,
          PrismToastRemovalReason.cleared,
        ]),
      );
      expect(closes, isZero);
    });
  });

  group('toast_policy_1867 onDismiss-only-on-close', () {
    testWidgets('[toast_1867_close_button_fires_onDismiss] close path', (
      tester,
    ) async {
      final managerKey = GlobalKey<DSToastManagerState>();
      final closedIds = <String>[];
      final reasons = <PrismToastRemovalReason>[];
      await tester.pumpWidget(
        _wrapWithPolicyManager(
          managerKey: managerKey,
          onHandBack: (entry, reason) {
            reasons.add(reason);
          },
          onCloseDismissed: (entry) => closedIds.add(entry.id),
          child: const SizedBox.shrink(),
        ),
      );

      managerKey.currentState!.show(_entry('close-1'));
      managerKey.currentState!.show(_entry('close-2'));
      await _settleToast(tester);

      await tester.tap(find.byIcon(Icons.close).first);
      await _settleToast(tester);

      // One toast closed by the user; the other remains.
      expect(closedIds.length, 1);
      expect(reasons, equals([PrismToastRemovalReason.closed]));
      expect(reasons.length, equals(closedIds.length));
    });

    testWidgets('[toast_1867_programmatic_dismiss_is_close] dismiss(id)', (
      tester,
    ) async {
      final managerKey = GlobalKey<DSToastManagerState>();
      final closedIds = <String>[];
      final reasons = <PrismToastRemovalReason>[];
      await tester.pumpWidget(
        _wrapWithPolicyManager(
          managerKey: managerKey,
          onHandBack: (_, reason) => reasons.add(reason),
          onCloseDismissed: (entry) => closedIds.add(entry.id),
          child: const SizedBox.shrink(),
        ),
      );

      managerKey.currentState!.show(_entry('prog-1'));
      await _settleToast(tester);

      managerKey.currentState!.dismiss('prog-1');
      await _settleToast(tester);

      expect(closedIds, equals(['prog-1']));
      expect(reasons, equals([PrismToastRemovalReason.closed]));
    });
  });
}
