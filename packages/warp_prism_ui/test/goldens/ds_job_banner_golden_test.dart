@Tags(['golden'])
library;

// Golden tests for DSJobBanner (Task 1858, F-10 — EXPERIMENTAL).
//
// Deterministic capture only: every case pins fixed stage values, fixed
// progress, and fixed receipt text. Phases without determination are
// excluded from golden capture by contract, so no such case appears here.
//
// Run from packages/warp_prism_ui/:
//   flutter test --update-goldens test/goldens/ds_job_banner_golden_test.dart
//   flutter test test/goldens/ds_job_banner_golden_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/src/molecules/ds_job_banner.dart';
import 'package:warp_prism_ui/src/tokens/tokens.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

Widget _inApp(Widget child) {
  return MaterialApp(
    theme: PrismTheme.dark(),
    home: Scaffold(
      backgroundColor: DSColors.obsidianBase,
      body: Center(child: SizedBox(width: 560, child: child)),
    ),
  );
}

const _fixedStages = [
  DSJobStage(label: 'Prepare', progress: 1.0, state: DSJobStageState.done),
  DSJobStage(label: 'Separate', progress: 0.5, state: DSJobStageState.active),
  DSJobStage(label: 'Export', progress: 0.0),
];

void main() {
  group('DSJobBanner golden — fixed stage values', () {
    testWidgets('renders queued banner', (tester) async {
      await tester.pumpWidget(
        _inApp(
          const DSJobBanner(title: 'Separate vocals', stages: _fixedStages),
        ),
      );
      await expectLater(
        find.byType(DSJobBanner),
        matchesGoldenFile('goldens/banner_1858_queued.png'),
      );
    });

    testWidgets('renders running banner at fixed progress', (tester) async {
      await tester.pumpWidget(
        _inApp(
          DSJobBanner(
            title: 'Separate vocals',
            subtitle: 'Session 7 · take 3',
            phase: DSJobBannerPhase.running,
            progress: 0.5,
            stages: _fixedStages,
            elapsedLabel: '00:42',
            cancellable: true,
            cancelReason: 'Takes too long',
            onCancel: () {},
          ),
        ),
      );
      await expectLater(
        find.byType(DSJobBanner),
        matchesGoldenFile('goldens/banner_1858_running.png'),
      );
    });

    testWidgets('renders succeeded banner with receipt slot', (tester) async {
      await tester.pumpWidget(
        _inApp(
          const DSJobBanner(
            title: 'Export take',
            phase: DSJobBannerPhase.succeeded,
            progress: 1.0,
            stages: [
              DSJobStage(
                label: 'Prepare',
                progress: 1.0,
                state: DSJobStageState.done,
              ),
              DSJobStage(
                label: 'Export',
                progress: 1.0,
                state: DSJobStageState.done,
              ),
            ],
            receipt: Text('DEST out/take-03.wav'),
          ),
        ),
      );
      await expectLater(
        find.byType(DSJobBanner),
        matchesGoldenFile('goldens/banner_1858_succeeded.png'),
      );
    });

    testWidgets('renders failed banner with reason', (tester) async {
      await tester.pumpWidget(
        _inApp(
          const DSJobBanner(
            title: 'Export take',
            phase: DSJobBannerPhase.failed,
            progress: 0.75,
            stages: _fixedStages,
            failureDetail: 'Render error at chunk 3',
          ),
        ),
      );
      await expectLater(
        find.byType(DSJobBanner),
        matchesGoldenFile('goldens/banner_1858_failed.png'),
      );
    });

    testWidgets('renders cancelled banner', (tester) async {
      await tester.pumpWidget(
        _inApp(
          const DSJobBanner(
            title: 'Export take',
            phase: DSJobBannerPhase.cancelled,
            progress: 0.25,
            stages: _fixedStages,
          ),
        ),
      );
      await expectLater(
        find.byType(DSJobBanner),
        matchesGoldenFile('goldens/banner_1858_cancelled.png'),
      );
    });
  });
}
