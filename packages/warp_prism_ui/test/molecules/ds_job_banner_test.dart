// Contract tests for DSJobBanner (Task 1858, F-10 — EXPERIMENTAL).
//
// Staged job banner: staged progress, cancel affordance with reason,
// deterministic terminal receipt slot, and the fail-closed indeterminate
// contract (withheld determination never renders as success or disabled).
//
// Run: flutter test packages/warp_prism_ui/test/molecules/ds_job_banner_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/src/atoms/atoms.dart';
import 'package:warp_prism_ui/src/molecules/ds_job_banner.dart';
import 'package:warp_prism_ui/src/tokens/tokens.dart';

Widget wrapInApp(Widget child) {
  return MaterialApp(
    theme: ThemeData(
      useMaterial3: true,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
    ),
    home: Scaffold(body: child),
  );
}

const demoStages = [
  DSJobStage(label: 'Prepare', progress: 1.0, state: DSJobStageState.done),
  DSJobStage(label: 'Separate', progress: 0.5, state: DSJobStageState.active),
  DSJobStage(label: 'Export', progress: 0.0),
];

void main() {
  group('DSJobBanner vocabulary exists', () {
    test(
      'phases cover queued, running, succeeded, failed, cancelled, unknown',
      () {
        expect(DSJobBannerPhase.values, contains(DSJobBannerPhase.queued));
        expect(DSJobBannerPhase.values, contains(DSJobBannerPhase.running));
        expect(DSJobBannerPhase.values, contains(DSJobBannerPhase.succeeded));
        expect(DSJobBannerPhase.values, contains(DSJobBannerPhase.failed));
        expect(DSJobBannerPhase.values, contains(DSJobBannerPhase.cancelled));
        expect(DSJobBannerPhase.values, contains(DSJobBannerPhase.unknown));
      },
    );

    test('terminal phases are succeeded, failed, and cancelled only', () {
      expect(DSJobBannerPhase.succeeded.isTerminal, isTrue);
      expect(DSJobBannerPhase.failed.isTerminal, isTrue);
      expect(DSJobBannerPhase.cancelled.isTerminal, isTrue);
      expect(DSJobBannerPhase.queued.isTerminal, isFalse);
      expect(DSJobBannerPhase.running.isTerminal, isFalse);
      expect(DSJobBannerPhase.unknown.isTerminal, isFalse);
    });

    test('stage progress is clamped to 0..1', () {
      expect(const DSJobStage(label: 'x', progress: 2.5).progress, equals(1.0));
      expect(
        const DSJobStage(label: 'x', progress: -0.5).progress,
        equals(0.0),
      );
    });
  });

  group('fail-closed: withheld determination never renders as success', () {
    testWidgets('withheld case uses the neutral token, never success green', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapInApp(
          const DSJobBanner(
            title: 'Export take',
            phase: DSJobBannerPhase.unknown,
          ),
        ),
      );

      final icon = tester.widget<DSIcon>(find.byType(DSIcon).first);
      expect(
        icon.color,
        equals(DSColors.statusUnknown),
        reason: 'withheld determination must use the neutral token',
      );
      expect(icon.color, isNot(equals(DSColors.statusSuccess)));
      expect(icon.color, isNot(equals(DSColors.statusApproved)));
      expect(icon.color, isNot(equals(DSColors.statusHealthy)));
    });

    testWidgets('withheld case never renders disabled styling', (tester) async {
      await tester.pumpWidget(
        wrapInApp(
          const DSJobBanner(
            title: 'Export take',
            phase: DSJobBannerPhase.unknown,
          ),
        ),
      );

      final icon = tester.widget<DSIcon>(find.byType(DSIcon).first);
      expect(icon.color, isNot(equals(DSColors.textDisabled)));
      expect(icon.color, isNot(equals(DSColors.statusDisabled)));
      expect(find.byIcon(Icons.help_outline), findsWidgets);
      expect(find.byIcon(Icons.check_circle), findsNothing);
    });

    testWidgets('withheld case carries no progress animation', (tester) async {
      await tester.pumpWidget(
        wrapInApp(
          const DSJobBanner(
            title: 'Export take',
            phase: DSJobBannerPhase.unknown,
            progress: 0.5,
            stages: demoStages,
          ),
        ),
      );

      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(
        find.text('State not yet determined — no action taken'),
        findsOneWidget,
      );
    });

    testWidgets('withheld announcement claims nothing', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        wrapInApp(
          const DSJobBanner(
            title: 'Export take',
            phase: DSJobBannerPhase.unknown,
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(DSJobBanner));
      expect(semantics.label, contains('not yet determined'));
      expect(semantics.label, isNot(contains('Succeeded')));
      expect(semantics.label, isNot(contains('complete')));
      handle.dispose();
    });
  });

  group('staged progress is deterministic', () {
    testWidgets('fixed stage values render stage labels and percent', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapInApp(
          const DSJobBanner(
            title: 'Separate vocals',
            phase: DSJobBannerPhase.running,
            progress: 0.5,
            stages: demoStages,
          ),
        ),
      );

      expect(find.text('Separate vocals'), findsOneWidget);
      expect(find.text('Prepare'), findsOneWidget);
      expect(find.text('Separate'), findsOneWidget);
      expect(find.text('Export'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
      final bar = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(bar.value, equals(0.5));
    });

    testWidgets('indeterminate running renders static chrome, no animation', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapInApp(
          const DSJobBanner(
            title: 'Separate vocals',
            phase: DSJobBannerPhase.running,
            stages: demoStages,
          ),
        ),
      );

      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Working…'), findsOneWidget);
    });

    testWidgets('identical inputs render identical output on re-pump', (
      tester,
    ) async {
      Widget build() => wrapInApp(
        const DSJobBanner(
          title: 'Separate vocals',
          phase: DSJobBannerPhase.running,
          progress: 0.5,
          stages: demoStages,
        ),
      );
      await tester.pumpWidget(build());
      final first = tester.getSize(find.byType(DSJobBanner));
      await tester.pumpWidget(build());
      await tester.pump();
      final second = tester.getSize(find.byType(DSJobBanner));
      expect(second, equals(first));
      expect(find.text('50%'), findsOneWidget);
    });
  });

  group('cancel is offered only when cancellable', () {
    testWidgets('non-cancellable banner shows no cancel control', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapInApp(
          const DSJobBanner(
            title: 'Separate vocals',
            phase: DSJobBannerPhase.running,
            progress: 0.5,
            stages: demoStages,
          ),
        ),
      );

      expect(find.text('Cancel'), findsNothing);
    });

    testWidgets('terminal banner never offers cancel', (tester) async {
      var cancelled = false;
      await tester.pumpWidget(
        wrapInApp(
          DSJobBanner(
            title: 'Separate vocals',
            phase: DSJobBannerPhase.succeeded,
            progress: 1.0,
            cancellable: true,
            cancelReason: 'Too slow',
            onCancel: () => cancelled = true,
            receipt: const Text('DEST out/take-03.wav'),
          ),
        ),
      );

      expect(find.text('Cancel'), findsNothing);
      expect(cancelled, isFalse);
    });

    testWidgets('cancel tap dispatches and reason is announced', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      var cancelled = false;
      await tester.pumpWidget(
        wrapInApp(
          DSJobBanner(
            title: 'Separate vocals',
            phase: DSJobBannerPhase.running,
            progress: 0.5,
            stages: demoStages,
            cancellable: true,
            cancelReason: 'Takes too long',
            onCancel: () => cancelled = true,
          ),
        ),
      );

      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Takes too long'), findsOneWidget);
      final semantics = tester.getSemantics(find.byType(DSJobBanner));
      expect(semantics.label, contains('Cancel available: Takes too long'));

      await tester.tap(find.text('Cancel'));
      expect(cancelled, isTrue);
      handle.dispose();
    });

    testWidgets('cancel control meets the 48px minimum target', (tester) async {
      await tester.pumpWidget(
        wrapInApp(
          DSJobBanner(
            title: 'Separate vocals',
            phase: DSJobBannerPhase.running,
            cancellable: true,
            cancelReason: 'Too slow',
            onCancel: () {},
          ),
        ),
      );

      final size = tester.getSize(find.byType(OutlinedButton));
      expect(size.height, greaterThanOrEqualTo(48));
    });
  });

  group('terminal receipt slot is consumer-owned', () {
    testWidgets('receipt renders verbatim only in terminal phases', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapInApp(
          const DSJobBanner(
            title: 'Export take',
            phase: DSJobBannerPhase.succeeded,
            progress: 1.0,
            receipt: Text('DEST out/take-03.wav'),
          ),
        ),
      );

      expect(find.text('RECEIPT'), findsOneWidget);
      expect(find.text('DEST out/take-03.wav'), findsOneWidget);
    });

    testWidgets('non-terminal banner never shows the receipt slot', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapInApp(
          const DSJobBanner(
            title: 'Export take',
            phase: DSJobBannerPhase.running,
            progress: 0.5,
            stages: demoStages,
            receipt: Text('DEST out/take-03.wav'),
          ),
        ),
      );

      expect(find.text('RECEIPT'), findsNothing);
      expect(find.text('DEST out/take-03.wav'), findsNothing);
    });

    testWidgets('failed banner shows reason and receipt slot together', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapInApp(
          const DSJobBanner(
            title: 'Export take',
            phase: DSJobBannerPhase.failed,
            failureDetail: 'Render error at chunk 3',
            receipt: Text('PARTIAL out/take-03.part'),
          ),
        ),
      );

      expect(find.text('Render error at chunk 3'), findsOneWidget);
      expect(find.text('RECEIPT'), findsOneWidget);
      expect(find.text('PARTIAL out/take-03.part'), findsOneWidget);
    });
  });

  group('banner exposes progress and cancel through semantics', () {
    testWidgets('announcement carries phase, stage, and percent', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        wrapInApp(
          const DSJobBanner(
            title: 'Separate vocals',
            phase: DSJobBannerPhase.running,
            progress: 0.5,
            stages: demoStages,
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(DSJobBanner));
      expect(semantics.label, contains('Separate vocals'));
      expect(semantics.label, contains('Stage 2 of 3: Separate'));
      expect(semantics.label, contains('50 percent'));
      handle.dispose();
    });
  });
}
