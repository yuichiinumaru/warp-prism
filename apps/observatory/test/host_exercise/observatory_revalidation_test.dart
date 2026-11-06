// Task 1838 real-host revalidation matrix for the Observatory host.
//
// Runs the required Task 1838 coverage: SMOKE + CRAWL at the canonical
// desktop viewport, plus SMOKE at a second representative viewport
// (narrow-800x600 — exercises the collapsed-sidebar shell path; compact
// 390x844 is additionally covered by observatory_exercise_test.dart).
// Every run persists its trace JSON under
// .project/reports/host-exercise/traces/.
//
// Observatory hardwires PrismTheme.dark() (Khalai Blue) by product
// decision (Task 1833); no recipe ladder applies to this host.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_host_exercise/warp_prism_host_exercise.dart';

import 'observatory_host.dart';

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
    '1838: observatory SMOKE @ desktop-1280x800 (khalai-blue) is error-free',
    (tester) async {
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
        reason: 'SMOKE @ desktop must be error-free: ${trace.errors.join('\n')}',
      );
      await _persist(
        tester,
        trace,
        'observatory_smoke_s0_desktop-1280x800.json',
      );
    },
  );

  testWidgets(
    '1838: observatory CRAWL @ desktop-1280x800 (khalai-blue) is error-free',
    (tester) async {
      final oracle = ExerciseErrorCollector()..install();
      addTearDown(oracle.uninstall);
      final config = observatoryExerciseConfig(
        mode: 'crawl',
        actionBudget: 10,
      );
      final trace = await ExerciseRunner.runCrawl(
        tester: tester,
        config: config,
        callbacks: observatoryCallbacks(tester),
        oracle: oracle,
      );
      expect(
        trace.errors,
        isEmpty,
        reason: 'CRAWL @ desktop must be error-free: ${trace.errors.join('\n')}',
      );
      await _persist(
        tester,
        trace,
        'observatory_crawl_s0_desktop-1280x800.json',
      );
    },
  );

  testWidgets(
    '1838: observatory SMOKE @ narrow-800x600 (khalai-blue) is error-free',
    (tester) async {
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
        reason: 'SMOKE @ narrow must be error-free: ${trace.errors.join('\n')}',
      );
      await _persist(
        tester,
        trace,
        'observatory_smoke_s0_narrow-800x600.json',
      );
    },
  );
}
