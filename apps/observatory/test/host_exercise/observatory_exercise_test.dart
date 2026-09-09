// Observatory real-host exercise tests: SMOKE / CRAWL / seeded FUZZ.
// Headless (flutter_tester offscreen): semantic discovery + strict error
// oracle + seed replay do not require a GPU window.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_host_exercise/warp_prism_host_exercise.dart';

import 'observatory_host.dart';

void main() {
  group('Observatory Host Exercise — SMOKE', () {
    testWidgets('smoke: five shell branches with strict error capture', (
      tester,
    ) async {
      final oracle = ExerciseErrorCollector()..install();
      addTearDown(oracle.uninstall);
      final config = observatoryExerciseConfig(mode: 'smoke');
      final trace = await ExerciseRunner.runSmoke(
        tester: tester,
        config: config,
        callbacks: observatoryCallbacks(tester),
        oracle: oracle,
      );
      expect(
        trace.errors,
        isEmpty,
        reason: 'SMOKE must be error-free: ${trace.errors.join('\n')}',
      );
      expect(trace.actions.length, observatorySmokeTargets.length);
      // Each branch tap must change the GoRouter location.
      final routes = trace.actions.map((a) => a.routeAfter).toSet();
      expect(routes, contains('/map'));
      expect(routes, contains('/operate'));
      expect(routes, contains('/history'));
      expect(routes, contains('/governance'));
      expect(trace.actions.last.routeAfter, '/overview');
    });
  });

  group('Observatory Host Exercise — CRAWL', () {
    testWidgets('crawl: deterministic bounded exploration is error-free', (
      tester,
    ) async {
      final oracle = ExerciseErrorCollector()..install();
      addTearDown(oracle.uninstall);
      final config = observatoryExerciseConfig(mode: 'crawl', actionBudget: 10);
      final first = await ExerciseRunner.runCrawl(
        tester: tester,
        config: config,
        callbacks: observatoryCallbacks(tester),
        oracle: oracle,
      );
      expect(
        first.errors,
        isEmpty,
        reason: 'CRAWL must be error-free: ${first.errors.join('\n')}',
      );
      expect(first.actions.length, lessThanOrEqualTo(10));

      // Determinism: second crawl from fresh reset replays same order.
      final oracle2 = ExerciseErrorCollector()..install();
      addTearDown(oracle2.uninstall);
      final second = await ExerciseRunner.runCrawl(
        tester: tester,
        config: config,
        callbacks: observatoryCallbacks(tester),
        oracle: oracle2,
      );
      expect(
        second.actions.map((a) => a.target).toList(),
        first.actions.map((a) => a.target).toList(),
      );
    });
  });

  group('Observatory Host Exercise — FUZZ', () {
    testWidgets('fuzz: seeded walk is reproducible via replay', (tester) async {
      const seed = 90210;
      final oracle = ExerciseErrorCollector()..install();
      addTearDown(oracle.uninstall);
      final config = observatoryExerciseConfig(
        mode: 'fuzz',
        seed: seed,
        actionBudget: 8,
      );
      final trace = await ExerciseRunner.runFuzz(
        tester: tester,
        config: config,
        callbacks: observatoryCallbacks(tester),
        oracle: oracle,
      );
      expect(
        trace.errors,
        isEmpty,
        reason: 'FUZZ must be error-free: ${trace.errors.join('\n')}',
      );
      expect(trace.seed, seed);

      // Pure roundtrip + replay (fake-async-safe; disk I/O via runAsync).
      final reread = ExerciseTraceWriter.decodeTraceJson(
        ExerciseTraceWriter.encodeTraceJson(trace),
      );
      expect(reread.seed, seed);

      final oracle2 = ExerciseErrorCollector()..install();
      addTearDown(oracle2.uninstall);
      final replayed = await ExerciseRunner.replayTrace(
        tester: tester,
        config: config,
        callbacks: observatoryCallbacks(tester),
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
  });

  group('Observatory Host Exercise — VIEWPORT MATRIX', () {
    testWidgets('narrow viewport exercises collapsed-shell composition', (
      tester,
    ) async {
      final oracle = ExerciseErrorCollector()..install();
      addTearDown(oracle.uninstall);
      final config = observatoryExerciseConfig(
        mode: 'smoke',
        viewport: ExerciseViewport.narrow800x600,
      );
      final trace = await ExerciseRunner.runSmoke(
        tester: tester,
        config: config,
        callbacks: observatoryCallbacks(tester),
        oracle: oracle,
      );
      expect(
        trace.errors,
        isEmpty,
        reason: 'NARROW SMOKE must be error-free: ${trace.errors.join('\n')}',
      );
    });

    testWidgets('compact viewport exercises bottom-nav composition', (
      tester,
    ) async {
      final oracle = ExerciseErrorCollector()..install();
      addTearDown(oracle.uninstall);
      final config = observatoryExerciseConfig(
        mode: 'smoke',
        viewport: ExerciseViewport.compact390x844,
      );
      final trace = await ExerciseRunner.runSmoke(
        tester: tester,
        config: config,
        callbacks: observatoryCallbacks(tester),
        oracle: oracle,
      );
      expect(
        trace.errors,
        isEmpty,
        reason: 'COMPACT SMOKE must be error-free: ${trace.errors.join('\n')}',
      );
    });
  });
}
