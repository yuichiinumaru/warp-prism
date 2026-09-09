// Catalog real-host exercise tests: SMOKE / CRAWL / seeded FUZZ + replay.
//
// FAST gate: SMOKE runs before shared UI/integration promotion to review.
// FULL crawl: wave closeout / pre-checkpoint. SEEDED FUZZ: checkpoint /
// milestone boundary and after high-blast-radius shell/theme changes.
//
// Runs headless in `flutter_tester` (offscreen): the harness value —
// semantic discovery, strict error oracle, seed replay — does not need a
// GPU window. A real-device/`integration_test` runner variant can be
// layered later without changing this suite's semantics.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_host_exercise/warp_prism_host_exercise.dart';

import 'catalog_host.dart';

void main() {
  group('Catalog Host Exercise — SMOKE', () {
    testWidgets('smoke: gallery round trip with strict error capture', (
      tester,
    ) async {
      final oracle = ExerciseErrorCollector()..install();
      addTearDown(oracle.uninstall);
      final config = catalogExerciseConfig(mode: 'smoke');
      final trace = await ExerciseRunner.runSmoke(
        tester: tester,
        config: config,
        callbacks: catalogCallbacks(tester),
        oracle: oracle,
      );
      expect(
        trace.errors,
        isEmpty,
        reason: 'SMOKE must be error-free: ${trace.errors.join('\n')}',
      );
      expect(trace.actions.length, catalogSmokeTargets.length);
      expect(trace.actions.first.target, 'key:catalog-nav-connected-lab');
      expect(trace.actions.first.routeAfter, 'connected-lab');
      expect(trace.actions.last.routeAfter, 'gallery');
    });
  });

  group('Catalog Host Exercise — CRAWL', () {
    testWidgets('crawl: deterministic bounded exploration is error-free', (
      tester,
    ) async {
      final oracle = ExerciseErrorCollector()..install();
      addTearDown(oracle.uninstall);
      final config = catalogExerciseConfig(mode: 'crawl', actionBudget: 8);
      final first = await ExerciseRunner.runCrawl(
        tester: tester,
        config: config,
        callbacks: catalogCallbacks(tester),
        oracle: oracle,
      );
      expect(
        first.errors,
        isEmpty,
        reason: 'CRAWL must be error-free: ${first.errors.join('\n')}',
      );
      expect(first.actions.length, lessThanOrEqualTo(8));

      // Determinism check: a second crawl from a fresh reset replays the
      // same ordered target sequence.
      final oracle2 = ExerciseErrorCollector()..install();
      addTearDown(oracle2.uninstall);
      final second = await ExerciseRunner.runCrawl(
        tester: tester,
        config: config,
        callbacks: catalogCallbacks(tester),
        oracle: oracle2,
      );
      expect(
        second.actions.map((a) => a.target).toList(),
        first.actions.map((a) => a.target).toList(),
      );
    });
  });

  group('Catalog Host Exercise — FUZZ', () {
    testWidgets('fuzz: seeded walk is reproducible via replay', (tester) async {
      const seed = 18473;
      final oracle = ExerciseErrorCollector()..install();
      addTearDown(oracle.uninstall);
      final config = catalogExerciseConfig(
        mode: 'fuzz',
        seed: seed,
        actionBudget: 8,
      );
      final trace = await ExerciseRunner.runFuzz(
        tester: tester,
        config: config,
        callbacks: catalogCallbacks(tester),
        oracle: oracle,
      );
      expect(
        trace.errors,
        isEmpty,
        reason: 'FUZZ must be error-free: ${trace.errors.join('\n')}',
      );
      expect(trace.seed, seed);

      // Fake-async zone: disk I/O must not happen inline (it never
      // completes under testWidgets). Encode/decode purely, persist via
      // runAsync for the durable failure artifact.
      final reread = ExerciseTraceWriter.decodeTraceJson(
        ExerciseTraceWriter.encodeTraceJson(trace),
      );
      expect(reread.seed, seed);
      expect(reread.actions.length, trace.actions.length);

      // Durable artifact (real disk) — persisted outside fake-async.
      final path = ExerciseTraceWriter.traceArtifactPath(
        trace,
        fileName: 'catalog_fuzz_s${seed}_vertical.json',
      );
      await tester.runAsync(() async {
        await File(path).writeAsString(
          '${ExerciseTraceWriter.encodeTraceJson(trace)}\n',
          flush: true,
        );
      });

      // Replay the exact recorded sequence deterministically.
      final oracle2 = ExerciseErrorCollector()..install();
      addTearDown(oracle2.uninstall);
      final replayed = await ExerciseRunner.replayTrace(
        tester: tester,
        config: config,
        callbacks: catalogCallbacks(tester),
        oracle: oracle2,
        trace: reread,
      );
      expect(
        replayed.errors,
        isEmpty,
        reason: 'REPLAY must be error-free: ${replayed.errors.join('\n')}',
      );
      expect(
        replayed.actions.map((a) => a.target).toList(),
        trace.actions.map((a) => a.target).toList(),
      );
    });

    // Artifact replay from disk — the command emitted by
    // `tool/warp_ui_exercise.dart --replay` targets THIS test via
    // WARP_UI_EXERCISE_TRACE, making the printed replay command real
    // instead of decorative.
    testWidgets('replay: recorded trace artifact replays from disk', (
      tester,
    ) async {
      final tracePath = Platform.environment['WARP_UI_EXERCISE_TRACE'];
      if (tracePath == null) {
        // Mark skipped: not runnable without an artifact — kept as a
        // shell so the CLI command has a real target.
        return;
      }
      final file = File(tracePath);
      expect(file.existsSync(), isTrue, reason: 'trace artifact missing');
      final String raw;
      final loaded = await tester.runAsync(file.readAsString);
      raw = loaded ?? '';
      final trace = ExerciseTraceWriter.decodeTraceJson(raw);

      final oracle = ExerciseErrorCollector()..install();
      addTearDown(oracle.uninstall);
      final config = catalogExerciseConfig(
        mode: 'replay',
        seed: trace.seed,
        actionBudget: trace.actions.length,
      );
      final replayed = await ExerciseRunner.replayTrace(
        tester: tester,
        config: config,
        callbacks: catalogCallbacks(tester),
        oracle: oracle,
        trace: trace,
      );
      expect(
        replayed.errors,
        isEmpty,
        reason:
            'ARTIFACT REPLAY must be error-free: ${replayed.errors.join('\n')}',
      );
      // Replay records every recorded step (skips become replay-skipped
      // entries); target list must match the artifact exactly.
      expect(
        replayed.actions.map((a) => a.target).toList(),
        trace.actions.map((a) => a.target).toList(),
      );
    });
  });
}
