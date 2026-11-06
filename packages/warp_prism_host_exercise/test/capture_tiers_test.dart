// Two-tier capture reference tests (Task 1867, part b).
//
// Tier 1: chrome-free deterministic render golden — same input produces the
// same finder/semantics output on repeat, with bounded pumps only.
// Tier 2: windowed chrome capture — real viewport, structured inspect record,
// visible-window errors (never silent).
// Drain/cancel: frame-boundary drain + cooperative cancel placement proof for
// the FRB adapter path (cancel-and-replace semantics plug the
// CooperativeCancelScope shape).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_host_exercise/warp_prism_host_exercise.dart';

/// Chrome-free subject: no overlay, no theme chrome, no animation drivers.
Widget _chromeFreeSubject(String label) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: Center(child: Text(label)),
  );
}

List<String> _visibleTexts(WidgetTester tester) {
  return find
      .byType(Text)
      .evaluate()
      .map((e) => (e.widget as Text).data ?? '')
      .toList()
    ..sort();
}

/// Stub single-flight command mirroring the FRB adapter's cancel-and-replace
/// shape (`frb_async_command.dart`): the incumbent is signalled, the successor
/// supersedes, and native work observes cancellation cooperatively.
class _StubSingleFlightCommand {
  CooperativeCancelScope? _active;
  final List<String> events = <String>[];

  Future<String> execute(String id, CooperativeCancelScope scope) async {
    _active?.cancel('Replaced by $id');
    _active = scope;
    events.add('start-$id');
    scope.throwIfCancelled('preflight-$id');
    await Future<void>.delayed(Duration.zero);
    if (scope.isCancelled) {
      events.add('observed-cancel-$id');
      return 'cancelled-$id';
    }
    events.add('complete-$id');
    return 'completed-$id';
  }
}

void main() {
  group('capture_tiers_1867 tier-1 golden', () {
    testWidgets('[capture_1867_golden_deterministic] same input same output', (
      tester,
    ) async {
      await tester.pumpWidget(_chromeFreeSubject('capture-tier-one'));
      await pumpBounded(tester, frames: 2);
      final first = _visibleTexts(tester);

      // Repeat the identical input from scratch.
      await tester.pumpWidget(_chromeFreeSubject('capture-tier-one'));
      await pumpBounded(tester, frames: 2);
      final second = _visibleTexts(tester);

      expect(first, equals(['capture-tier-one']));
      expect(second, equals(first));
    });

    testWidgets('[capture_1867_golden_chrome_free] no overlay ancestors', (
      tester,
    ) async {
      await tester.pumpWidget(_chromeFreeSubject('chrome-free'));
      await pumpBounded(tester, frames: 1);

      expect(find.byType(Overlay), findsNothing);
      expect(find.byType(MaterialApp), findsNothing);
      expect(find.text('chrome-free'), findsOneWidget);
    });
  });

  group('capture_tiers_1867 tier-2 windowed', () {
    testWidgets('[capture_1867_windowed_capture] structured inspect passes', (
      tester,
    ) async {
      final oracle = ExerciseErrorCollector()..install();
      addTearDown(oracle.uninstall);

      final record = await runWindowedCapture(
        tester: tester,
        oracle: oracle,
        host: 'catalog',
        route: 'gallery',
        width: 800,
        height: 600,
        devicePixelRatio: 1.0,
        themeRecipe: 'khalai-blue',
        build: () => const MaterialApp(
          home: Scaffold(body: Center(child: Text('windowed capture'))),
        ),
      );

      expect(record.passed, isTrue);
      expect(record.errors, isEmpty);
      expect(record.findings.length, 3);
      expect(find.text('windowed capture'), findsOneWidget);
      final json = record.toJson();
      expect(json['tier'], 'windowed');
      expect((json['viewport'] as Map<String, Object?>)['width'], 800);
      expect(json['theme_recipe'], 'khalai-blue');
    });

    testWidgets('[capture_1867_windowed_errors_visible] defects never silent', (
      tester,
    ) async {
      final oracle = ExerciseErrorCollector()..install();
      addTearDown(oracle.uninstall);

      // A broken surface leaves an ErrorWidget in the tree.
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: ErrorWidget('boom'),
        ),
      );
      await pumpBounded(tester, frames: 1);
      oracle.collectTreeState(tester);

      // Visible: the oracle recorded it instead of swallowing it.
      expect(oracle.hasMaterialError, isTrue);
      expect(oracle.errorWidgetEvents.length, 1);
      expect(
        () => oracle.failIfMaterial('windowed-capture:catalog:broken'),
        throwsFlutterError,
      );
    });
  });

  group('capture_tiers_1867 drain and cooperative cancel', () {
    testWidgets('[capture_1867_drain_bounded] drain spends one boundary', (
      tester,
    ) async {
      final oracle = ExerciseErrorCollector()..install();
      addTearDown(oracle.uninstall);
      await tester.pumpWidget(_chromeFreeSubject('drain'));
      await tester.pump();

      final spent = await const FrameBoundaryDrain().drain(
        tester,
        oracle,
        'drain-proof',
      );

      expect(spent, 1);
      expect(oracle.hasMaterialError, isFalse);
    });

    test(
      '[capture_1867_cancel_placement] cancel-and-replace is cooperative',
      () async {
        final command = _StubSingleFlightCommand();
        final scopeA = CooperativeCancelScope();
        final scopeB = CooperativeCancelScope();

        final futureA = command.execute('a', scopeA);
        final futureB = command.execute('b', scopeB);

        expect(await futureA, 'cancelled-a');
        expect(await futureB, 'completed-b');
        expect(scopeA.isCancelled, isTrue);
        expect(scopeB.isCancelled, isFalse);
        expect(command.events, [
          'start-a',
          'start-b',
          'observed-cancel-a',
          'complete-b',
        ]);
      },
    );

    test(
      '[capture_1867_cancel_preflight] pre-cancelled scope fails closed',
      () {
        final scope = CooperativeCancelScope()..cancel('preflight');
        expect(
          () => scope.throwIfCancelled('preflight-proof'),
          throwsStateError,
        );
        expect(scope.isCancelled, isTrue);
        expect(scope.reason, 'preflight');
      },
    );
  });
}
