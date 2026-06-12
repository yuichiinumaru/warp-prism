// DSToast and DSToastManager Widget Tests
// Task 1116: Validates the notification toast system contract
//
// Tests cover: severity rendering, auto-dismiss, action button callback,
// stacking behavior, and pause-on-hover.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// Helper: wraps a widget under test with MaterialApp + Scaffold.
Widget _wrapInApp(Widget child) {
  return MaterialApp(home: Scaffold(body: child));
}

/// Helper: wraps a widget with DSToastManager for overlay tests.
Widget _wrapWithManager(Widget child, {int maxVisible = 5}) {
  return MaterialApp(
    home: Scaffold(
      body: DSToastManager(maxVisible: maxVisible, child: child),
    ),
  );
}

void main() {
  // ==========================================================================
  // DSToastSeverity
  // ==========================================================================
  group('DSToastSeverity', () {
    test('defines exactly four severity levels', () {
      expect(DSToastSeverity.values.length, equals(4));
    });

    test('has info, success, warning, error', () {
      expect(DSToastSeverity.values, contains(DSToastSeverity.info));
      expect(DSToastSeverity.values, contains(DSToastSeverity.success));
      expect(DSToastSeverity.values, contains(DSToastSeverity.warning));
      expect(DSToastSeverity.values, contains(DSToastSeverity.error));
    });

    test('each severity maps to a distinct color', () {
      final colors = DSToastSeverity.values.map((s) => s.color).toSet();
      expect(colors.length, equals(4));
    });

    test('each severity maps to a distinct icon', () {
      final icons = DSToastSeverity.values.map((s) => s.icon).toSet();
      expect(icons.length, equals(4));
    });

    test('each severity has a non-empty label', () {
      for (final s in DSToastSeverity.values) {
        expect(s.label, isNotEmpty);
      }
    });

    test('info maps to statusInfo color', () {
      expect(DSToastSeverity.info.color, equals(DSColors.statusInfo));
    });

    test('success maps to statusSuccess color', () {
      expect(DSToastSeverity.success.color, equals(DSColors.statusSuccess));
    });

    test('warning maps to statusWarning color', () {
      expect(DSToastSeverity.warning.color, equals(DSColors.statusWarning));
    });

    test('error maps to statusError color', () {
      expect(DSToastSeverity.error.color, equals(DSColors.statusError));
    });
  });

  // ==========================================================================
  // DSToastEntry
  // ==========================================================================
  group('DSToastEntry', () {
    test('constructs with required fields', () {
      final entry = DSToastEntry(
        id: 'test-1',
        severity: DSToastSeverity.info,
        title: 'Test',
      );
      expect(entry.id, equals('test-1'));
      expect(entry.severity, equals(DSToastSeverity.info));
      expect(entry.title, equals('Test'));
      expect(entry.message, isNull);
      expect(entry.actionLabel, isNull);
    });

    test('defaults duration to 4 seconds', () {
      final entry = DSToastEntry(
        id: 'test-1',
        severity: DSToastSeverity.info,
        title: 'Test',
      );
      expect(entry.duration, equals(const Duration(seconds: 4)));
    });

    test('accepts optional message', () {
      final entry = DSToastEntry(
        id: 'test-1',
        severity: DSToastSeverity.info,
        title: 'Test',
        message: 'Details here',
      );
      expect(entry.message, equals('Details here'));
    });

    test('accepts optional actionLabel', () {
      final entry = DSToastEntry(
        id: 'test-1',
        severity: DSToastSeverity.info,
        title: 'Test',
        actionLabel: 'Undo',
      );
      expect(entry.actionLabel, equals('Undo'));
    });

    test('accepts custom duration', () {
      final entry = DSToastEntry(
        id: 'test-1',
        severity: DSToastSeverity.info,
        title: 'Test',
        duration: const Duration(seconds: 10),
      );
      expect(entry.duration, equals(const Duration(seconds: 10)));
    });

    test('copyWith creates a copy with overrides', () {
      final original = DSToastEntry(
        id: 'test-1',
        severity: DSToastSeverity.info,
        title: 'Original',
        message: 'Message',
      );

      final copy = original.copyWith(title: 'Updated');
      expect(copy.id, equals('test-1'));
      expect(copy.severity, equals(DSToastSeverity.info));
      expect(copy.title, equals('Updated'));
      expect(copy.message, equals('Message'));
    });

    test('copyWith clearMessage sets message to null', () {
      final original = DSToastEntry(
        id: 'test-1',
        severity: DSToastSeverity.info,
        title: 'Test',
        message: 'Message',
      );

      final copy = original.copyWith(clearMessage: true);
      expect(copy.message, isNull);
    });

    test('copyWith clearActionLabel sets actionLabel to null', () {
      final original = DSToastEntry(
        id: 'test-1',
        severity: DSToastSeverity.info,
        title: 'Test',
        actionLabel: 'Undo',
      );

      final copy = original.copyWith(clearActionLabel: true);
      expect(copy.actionLabel, isNull);
    });
  });

  // ==========================================================================
  // DSToast widget rendering
  // ==========================================================================
  group('DSToast widget', () {
    testWidgets('renders title text', (tester) async {
      await tester.pumpWidget(
        _wrapInApp(
          DSToast(
            entry: DSToastEntry(
              id: 't1',
              severity: DSToastSeverity.info,
              title: 'Info toast',
              duration: Duration.zero,
            ),
          ),
        ),
      );

      expect(find.text('Info toast'), findsOneWidget);
    });

    testWidgets('renders message when provided', (tester) async {
      await tester.pumpWidget(
        _wrapInApp(
          DSToast(
            entry: DSToastEntry(
              id: 't1',
              severity: DSToastSeverity.success,
              title: 'Done',
              message: 'All checks passed',
              duration: Duration.zero,
            ),
          ),
        ),
      );

      expect(find.text('Done'), findsOneWidget);
      expect(find.text('All checks passed'), findsOneWidget);
    });

    testWidgets('does not render message when null', (tester) async {
      await tester.pumpWidget(
        _wrapInApp(
          DSToast(
            entry: DSToastEntry(
              id: 't1',
              severity: DSToastSeverity.success,
              title: 'Done',
              duration: Duration.zero,
            ),
          ),
        ),
      );

      expect(find.text('Done'), findsOneWidget);
      // No secondary text should be present.
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('renders action button when actionLabel is set', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrapInApp(
          DSToast(
            entry: DSToastEntry(
              id: 't1',
              severity: DSToastSeverity.warning,
              title: 'Warning',
              actionLabel: 'View',
              duration: Duration.zero,
            ),
          ),
        ),
      );

      expect(find.text('View'), findsOneWidget);
    });

    testWidgets('does not render action button when actionLabel is null', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrapInApp(
          DSToast(
            entry: DSToastEntry(
              id: 't1',
              severity: DSToastSeverity.warning,
              title: 'Warning',
              duration: Duration.zero,
            ),
          ),
        ),
      );

      expect(find.byType(TextButton), findsNothing);
    });

    testWidgets('renders close button when onDismiss provided', (tester) async {
      await tester.pumpWidget(
        _wrapInApp(
          DSToast(
            entry: DSToastEntry(
              id: 't1',
              severity: DSToastSeverity.info,
              title: 'Info',
              duration: Duration.zero,
            ),
            onDismiss: () {},
          ),
        ),
      );

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('fires onDismiss when close button tapped', (tester) async {
      var dismissed = false;
      await tester.pumpWidget(
        _wrapInApp(
          DSToast(
            entry: DSToastEntry(
              id: 't1',
              severity: DSToastSeverity.info,
              title: 'Info',
              duration: Duration.zero,
            ),
            onDismiss: () => dismissed = true,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.close));
      expect(dismissed, isTrue);
    });

    testWidgets('renders each severity without errors', (tester) async {
      for (final severity in DSToastSeverity.values) {
        await tester.pumpWidget(
          _wrapInApp(
            DSToast(
              entry: DSToastEntry(
                id: 't-${severity.name}',
                severity: severity,
                title: severity.label,
                duration: Duration.zero,
              ),
            ),
          ),
        );

        expect(find.text(severity.label), findsOneWidget);
      }
    });

    testWidgets('provides Semantics with severity and title', (tester) async {
      await tester.pumpWidget(
        _wrapInApp(
          DSToast(
            entry: DSToastEntry(
              id: 't1',
              severity: DSToastSeverity.error,
              title: 'Parse error',
              duration: Duration.zero,
            ),
          ),
        ),
      );

      expect(find.bySemanticsLabel('Error: Parse error'), findsOneWidget);
    });

    testWidgets('exposes action and dismiss semantics', (tester) async {
      await tester.pumpWidget(
        _wrapInApp(
          DSToast(
            entry: DSToastEntry(
              id: 't1',
              severity: DSToastSeverity.info,
              title: 'Info',
              actionLabel: 'Undo',
              duration: Duration.zero,
            ),
            onDismiss: () {},
          ),
        ),
      );

      expect(find.bySemanticsLabel('Undo'), findsOneWidget);
      expect(find.bySemanticsLabel('Dismiss notification'), findsOneWidget);
    });
  });

  // ==========================================================================
  // DSToastManager — stacking
  // ==========================================================================
  group('DSToastManager', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(_wrapWithManager(const Text('Main content')));

      expect(find.text('Main content'), findsOneWidget);
    });

    testWidgets('shows a toast in the overlay', (tester) async {
      final key = GlobalKey();
      await tester.pumpWidget(
        _wrapWithManager(
          Builder(
            builder: (context) {
              return ElevatedButton(
                key: key,
                onPressed: () {
                  DSToastManager.of(context).show(
                    DSToastEntry(
                      id: 'toast-1',
                      severity: DSToastSeverity.info,
                      title: 'Test toast',
                      duration: Duration.zero,
                    ),
                  );
                },
                child: const Text('Show'),
              );
            },
          ),
        ),
      );

      // Tap button to show toast.
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      await tester.pump(DSMotion.slow);

      expect(find.text('Test toast'), findsOneWidget);
    });

    testWidgets('dismiss removes the toast', (tester) async {
      final managerKey = GlobalKey<_ManagerTestHelperState>();
      await tester.pumpWidget(
        _wrapWithManager(_ManagerTestHelper(key: managerKey)),
      );

      // Show a toast.
      managerKey.currentState!.showToast('toast-1');
      await tester.pump();
      await tester.pump(DSMotion.slow);
      expect(find.text('Toast toast-1'), findsOneWidget);

      // Dismiss the toast.
      managerKey.currentState!.dismissToast('toast-1');
      await tester.pump();
      // Animated out.
      await tester.pump(DSMotion.slow);
      await tester.pump(const Duration(milliseconds: 100));

      // After animation completes, toast should be gone.
      // Note: the AnimatedOpacity goes to 0, so text may still be in tree
      // but invisible. We check opacity instead.
      expect(find.text('Toast toast-1'), findsNothing);
    });

    testWidgets('auto-dismiss fires after duration', (tester) async {
      final managerKey = GlobalKey<_ManagerTestHelperState>();
      await tester.pumpWidget(
        _wrapWithManager(_ManagerTestHelper(key: managerKey)),
      );

      // Show a toast with 1-second duration.
      managerKey.currentState!.showToastWith(
        id: 'toast-auto',
        duration: const Duration(seconds: 1),
      );
      await tester.pump();
      await tester.pump(DSMotion.slow);
      expect(find.text('Toast toast-auto'), findsOneWidget);

      // Wait for auto-dismiss.
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(DSMotion.slow);
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Toast toast-auto'), findsNothing);
    });

    testWidgets('clear removes all toasts', (tester) async {
      final managerKey = GlobalKey<_ManagerTestHelperState>();
      await tester.pumpWidget(
        _wrapWithManager(_ManagerTestHelper(key: managerKey)),
      );

      // Show 3 toasts.
      managerKey.currentState!.showToast('toast-a');
      managerKey.currentState!.showToast('toast-b');
      managerKey.currentState!.showToast('toast-c');
      await tester.pump();
      await tester.pump(DSMotion.slow);

      expect(find.text('Toast toast-a'), findsOneWidget);
      expect(find.text('Toast toast-b'), findsOneWidget);
      expect(find.text('Toast toast-c'), findsOneWidget);

      // Clear all.
      managerKey.currentState!.clearToasts();
      await tester.pump();

      expect(find.text('Toast toast-a'), findsNothing);
      expect(find.text('Toast toast-b'), findsNothing);
      expect(find.text('Toast toast-c'), findsNothing);
    });

    testWidgets('maxVisible limits visible toasts', (tester) async {
      final managerKey = GlobalKey<_ManagerTestHelperState>();
      await tester.pumpWidget(
        _wrapWithManager(_ManagerTestHelper(key: managerKey), maxVisible: 2),
      );

      // Show 3 toasts (exceeding max of 2).
      managerKey.currentState!.showToast('toast-1');
      managerKey.currentState!.showToast('toast-2');
      managerKey.currentState!.showToast('toast-3');
      await tester.pump();
      await tester.pump(DSMotion.slow);

      // Only the most recent 2 should be visible.
      expect(find.text('Toast toast-1'), findsNothing);
      expect(find.text('Toast toast-2'), findsOneWidget);
      expect(find.text('Toast toast-3'), findsOneWidget);
    });

    testWidgets('show with same id replaces existing toast', (tester) async {
      final managerKey = GlobalKey<_ManagerTestHelperState>();
      await tester.pumpWidget(
        _wrapWithManager(_ManagerTestHelper(key: managerKey)),
      );

      // Show a toast.
      managerKey.currentState!.showToastWith(
        id: 'replace-me',
        title: 'Original',
      );
      await tester.pump();
      await tester.pump(DSMotion.slow);
      expect(find.text('Original'), findsOneWidget);

      // Replace with same id.
      managerKey.currentState!.showToastWith(
        id: 'replace-me',
        title: 'Replaced',
      );
      await tester.pump();
      await tester.pump(DSMotion.slow);
      expect(find.text('Original'), findsNothing);
      expect(find.text('Replaced'), findsOneWidget);
    });

    testWidgets('action button fires onAction callback', (tester) async {
      var actionFired = false;
      await tester.pumpWidget(
        _wrapInApp(
          DSToast(
            entry: DSToastEntry(
              id: 't1',
              severity: DSToastSeverity.info,
              title: 'Info',
              actionLabel: 'Undo',
              duration: Duration.zero,
            ),
            onAction: () => actionFired = true,
            onDismiss: () {},
          ),
        ),
      );

      await tester.tap(find.text('Undo'));
      expect(actionFired, isTrue);
    });

    testWidgets('dismiss button has minimum 48x48 touch target', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrapInApp(
          DSToast(
            entry: DSToastEntry(
              id: 't1',
              severity: DSToastSeverity.info,
              title: 'Info',
              duration: Duration.zero,
            ),
            onDismiss: () {},
          ),
        ),
      );

      final dismissButton = find.byIcon(Icons.close);
      expect(dismissButton, findsOneWidget);

      final dismissTarget = find.ancestor(
        of: dismissButton,
        matching: find.byType(SizedBox),
      );
      expect(dismissTarget, findsOneWidget);

      final size = tester.getSize(dismissTarget);
      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));
    });

    testWidgets('manager action tap dismisses toast', (tester) async {
      final managerKey = GlobalKey<_ManagerTestHelperState>();
      await tester.pumpWidget(
        _wrapWithManager(_ManagerTestHelper(key: managerKey)),
      );

      // Show a toast with action.
      managerKey.currentState!.showToastWith(
        id: 'toast-action',
        title: 'Action Toast',
        actionLabel: 'Action',
      );
      await tester.pump();
      await tester.pump(DSMotion.slow);

      expect(find.text('Action Toast'), findsOneWidget);
      expect(find.text('Action'), findsOneWidget);

      // Tap the action button.
      await tester.tap(find.text('Action'));
      await tester.pump();
      await tester.pump(DSMotion.slow);
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Action Toast'), findsNothing);
    });

    testWidgets('two toasts - dismiss one leaves other visible', (
      tester,
    ) async {
      final managerKey = GlobalKey<_ManagerTestHelperState>();
      await tester.pumpWidget(
        _wrapWithManager(_ManagerTestHelper(key: managerKey)),
      );

      // Show two toasts.
      managerKey.currentState!.showToastWith(id: 'toast-1', title: 'Toast 1');
      managerKey.currentState!.showToastWith(id: 'toast-2', title: 'Toast 2');
      await tester.pump();
      await tester.pump(DSMotion.slow);

      expect(find.text('Toast 1'), findsOneWidget);
      expect(find.text('Toast 2'), findsOneWidget);

      // Dismiss the first toast.
      managerKey.currentState!.dismissToast('toast-1');
      await tester.pump();
      // Animated out.
      await tester.pump(DSMotion.slow);
      await tester.pump(const Duration(milliseconds: 100));

      // Toast 1 should be gone, Toast 2 should remain.
      expect(find.text('Toast 1'), findsNothing);
      expect(find.text('Toast 2'), findsOneWidget);
    });
  });
}

// =============================================================================
// TEST HELPERS
// =============================================================================

/// A helper widget that exposes DSToastManager methods for testing.
class _ManagerTestHelper extends StatefulWidget {
  const _ManagerTestHelper({super.key});

  @override
  State<_ManagerTestHelper> createState() => _ManagerTestHelperState();
}

class _ManagerTestHelperState extends State<_ManagerTestHelper> {
  int _counter = 0;

  void showToast(String id) {
    DSToastManager.of(context).show(
      DSToastEntry(
        id: id,
        severity: DSToastSeverity.info,
        title: 'Toast $id',
        duration: Duration.zero,
      ),
    );
  }

  void showToastWith({
    required String id,
    String? title,
    String? actionLabel,
    Duration duration = Duration.zero,
  }) {
    DSToastManager.of(context).show(
      DSToastEntry(
        id: id,
        severity: DSToastSeverity.success,
        title: title ?? 'Toast $id',
        actionLabel: actionLabel,
        duration: duration,
      ),
    );
  }

  void showNextToast() {
    _counter++;
    DSToastManager.of(context).show(
      DSToastEntry(
        id: 'toast-$_counter',
        severity: DSToastSeverity.info,
        title: 'Toast $_counter',
        duration: Duration.zero,
      ),
    );
  }

  void dismissToast(String id) {
    DSToastManager.of(context).dismiss(id);
  }

  void clearToasts() {
    DSToastManager.of(context).clear();
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
