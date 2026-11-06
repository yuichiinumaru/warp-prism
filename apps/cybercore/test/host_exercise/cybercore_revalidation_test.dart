// Task 1838 real-host revalidation matrix for the CyberCore host.
//
// Runs the required Task 1838 coverage: SMOKE + CRAWL at the canonical
// desktop viewport AND the compact viewport (the Task 1833 F6 divergence
// surface — compact bottom-nav selection must resolve teal from the
// installed theme), all under the production nerazim-teal recipe.
// Every run persists its trace JSON under
// .project/reports/host-exercise/traces/.
//
// The teal recipe is CyberCore's production install (applied inside
// WarpPrismCyberCoreApp.build); the runner records it as the trace's
// theme_recipe id.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_host_exercise/warp_prism_host_exercise.dart';

import 'cybercore_host.dart';

/// Persists [trace] as a durable artifact outside the fake-async zone.
Future<void> _persist(
  WidgetTester tester,
  ExerciseTrace trace,
  String fileName,
) async {
  final path = ExerciseTraceWriter.traceArtifactPath(
    trace,
    fileName: fileName,
  );
  await tester.runAsync(() async {
    await File(path).writeAsString(
      '${ExerciseTraceWriter.encodeTraceJson(trace)}\n',
      flush: true,
    );
  });
}

void main() {
  testWidgets(
    '1838: cybercore SMOKE @ desktop-1280x800 (nerazim-teal) is error-free',
    (tester) async {
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
        reason: 'SMOKE @ desktop must be error-free: ${trace.errors.join('\n')}',
      );
      expect(trace.themeRecipe, 'nerazim-teal');
      await _persist(
        tester,
        trace,
        'cybercore_smoke_s0_desktop-1280x800.json',
      );
    },
  );

  testWidgets(
    '1838: cybercore CRAWL @ desktop-1280x800 (nerazim-teal) is error-free',
    (tester) async {
      final oracle = ExerciseErrorCollector()..install();
      addTearDown(oracle.uninstall);
      final config = cybercoreExerciseConfig(
        mode: 'crawl',
        actionBudget: 10,
      );
      final trace = await ExerciseRunner.runCrawl(
        tester: tester,
        config: config,
        callbacks: cybercoreCallbacks(tester),
        oracle: oracle,
      );
      expect(
        trace.errors,
        isEmpty,
        reason: 'CRAWL @ desktop must be error-free: ${trace.errors.join('\n')}',
      );
      expect(trace.themeRecipe, 'nerazim-teal');
      await _persist(
        tester,
        trace,
        'cybercore_crawl_s0_desktop-1280x800.json',
      );
    },
  );

  testWidgets(
    '1838: cybercore SMOKE @ compact-500x900 (nerazim-teal) is error-free',
    (tester) async {
      final oracle = ExerciseErrorCollector()..install();
      addTearDown(oracle.uninstall);
      final config = cybercoreExerciseConfig(
        mode: 'smoke',
        viewport: const ExerciseViewport(
          name: 'compact-500x900',
          width: 500,
          height: 900,
        ),
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
        reason:
            'SMOKE @ compact-500x900 (F6 divergence surface) must be error-free: '
            '${trace.errors.join('\n')}',
      );
      expect(trace.themeRecipe, 'nerazim-teal');
      await _persist(
        tester,
        trace,
        'cybercore_smoke_s0_compact-500x900.json',
      );
    },
  );

  testWidgets(
    '1838: cybercore SMOKE @ compact-390x844 (nerazim-teal) is error-free',
    (tester) async {
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
        reason:
            'SMOKE @ compact (F6 divergence surface) must be error-free: '
            '${trace.errors.join('\n')}',
      );
      expect(trace.themeRecipe, 'nerazim-teal');
      await _persist(
        tester,
        trace,
        'cybercore_smoke_s0_compact-390x844.json',
      );
    },
  );
}
