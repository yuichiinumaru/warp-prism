// CyberCore real-host exercise tests: SMOKE / CRAWL / seeded FUZZ.
// Headless (flutter_tester offscreen): semantic discovery + strict error
// oracle + seed replay do not require a GPU window.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_host_exercise/warp_prism_host_exercise.dart';

import 'cybercore_host.dart';

void main() {
  group('CyberCore Host Exercise — SMOKE', () {
    testWidgets('smoke: four pilot branches with strict error capture', (
      tester,
    ) async {
      final oracle = ExerciseErrorCollector()..install();
      addTearDown(oracle.uninstall);
      final config = cybercoreExerciseConfig(mode: 'smoke');
      final trace = await ExerciseRunner.runSmoke(
        tester: tester,
        config: config,
        callbacks: cybercoreCallbacks(tester),
        oracle: oracle,
      );
      expect(
        trace.errors,
        isEmpty,
        reason: 'SMOKE must be error-free: ${trace.errors.join('\n')}',
      );
      expect(trace.actions.length, cybercoreSmokeTargets.length);
      final routes = trace.actions.map((a) => a.routeAfter).toSet();
      expect(routes, contains('/mcp-servers'));
      expect(routes, contains('/mcp-inspector'));
      expect(routes, contains('/live-logs'));
      expect(trace.actions.last.routeAfter, '/providers');
    });
  });

  group('CyberCore Host Exercise — CRAWL', () {
    testWidgets('crawl: deterministic bounded exploration is error-free', (
      tester,
    ) async {
      final oracle = ExerciseErrorCollector()..install();
      addTearDown(oracle.uninstall);
      final config = cybercoreExerciseConfig(mode: 'crawl', actionBudget: 10);
      final first = await ExerciseRunner.runCrawl(
        tester: tester,
        config: config,
        callbacks: cybercoreCallbacks(tester),
        oracle: oracle,
      );
      expect(
        first.errors,
        isEmpty,
        reason: 'CRAWL must be error-free: ${first.errors.join('\n')}',
      );
      expect(first.actions.length, lessThanOrEqualTo(10));

      final oracle2 = ExerciseErrorCollector()..install();
      addTearDown(oracle2.uninstall);
      final second = await ExerciseRunner.runCrawl(
        tester: tester,
        config: config,
        callbacks: cybercoreCallbacks(tester),
        oracle: oracle2,
      );
      expect(
        second.actions.map((a) => a.target).toList(),
        first.actions.map((a) => a.target).toList(),
      );
    });
  });

  group('CyberCore Host Exercise — FUZZ', () {
    testWidgets('fuzz: seeded walk is reproducible via replay', (tester) async {
      const seed = 71717;
      final oracle = ExerciseErrorCollector()..install();
      addTearDown(oracle.uninstall);
      final config = cybercoreExerciseConfig(
        mode: 'fuzz',
        seed: seed,
        actionBudget: 8,
      );
      final trace = await ExerciseRunner.runFuzz(
        tester: tester,
        config: config,
        callbacks: cybercoreCallbacks(tester),
        oracle: oracle,
      );
      expect(
        trace.errors,
        isEmpty,
        reason: 'FUZZ must be error-free: ${trace.errors.join('\n')}',
      );
      expect(trace.seed, seed);

      final reread = ExerciseTraceWriter.decodeTraceJson(
        ExerciseTraceWriter.encodeTraceJson(trace),
      );
      expect(reread.seed, seed);

      final oracle2 = ExerciseErrorCollector()..install();
      addTearDown(oracle2.uninstall);
      final replayed = await ExerciseRunner.replayTrace(
        tester: tester,
        config: config,
        callbacks: cybercoreCallbacks(tester),
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

  group('CyberCore Host Exercise — VIEWPORT MATRIX', () {
    testWidgets('compact viewport exercises bottom-nav composition', (
      tester,
    ) async {
      final oracle = ExerciseErrorCollector()..install();
      addTearDown(oracle.uninstall);
      final config = cybercoreExerciseConfig(
        mode: 'smoke',
        viewport: ExerciseViewport.compact390x844,
      );
      final trace = await ExerciseRunner.runSmoke(
        tester: tester,
        config: config,
        callbacks: cybercoreCallbacks(tester),
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
