// Task 1838 real-host revalidation matrix for the Catalog host.
//
// Runs the required Task 1838 coverage: SMOKE + CRAWL at the canonical
// desktop viewport, plus SMOKE at a second representative viewport
// (laptop-1366x768 — wide-1920x1080 smoke is already covered by
// catalog_theme_matrix_test.dart). Every run persists its trace JSON
// under docs/reports/host-exercise/traces/ (naming follows the
// trace_writer.dart convention: <host>_<mode>_s<seed>_<tag>.json).
//
// Theme-recipe switch propagation for this host is proven by the
// existing catalog_theme_matrix_test.dart (A→B→C→D→A ladder) — recorded
// as evidence in the Task 1838 report rather than duplicated here.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_host_exercise/warp_prism_host_exercise.dart';

import 'catalog_host.dart';

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
    '1838: catalog SMOKE @ desktop-1280x800 (khalai-blue) is error-free',
    (tester) async {
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
        reason: 'SMOKE @ desktop must be error-free: ${trace.errors.join('\n')}',
      );
      await _persist(tester, trace, 'catalog_smoke_s0_desktop-1280x800.json');
    },
  );

  testWidgets(
    '1838: catalog CRAWL @ desktop-1280x800 (khalai-blue) is error-free',
    (tester) async {
      final oracle = ExerciseErrorCollector()..install();
      addTearDown(oracle.uninstall);
      final config = catalogExerciseConfig(mode: 'crawl', actionBudget: 8);
      final trace = await ExerciseRunner.runCrawl(
        tester: tester,
        config: config,
        callbacks: catalogCallbacks(tester),
        oracle: oracle,
      );
      expect(
        trace.errors,
        isEmpty,
        reason: 'CRAWL @ desktop must be error-free: ${trace.errors.join('\n')}',
      );
      await _persist(tester, trace, 'catalog_crawl_s0_desktop-1280x800.json');
    },
  );

  testWidgets(
    '1838: catalog SMOKE @ laptop-1366x768 (khalai-blue) is error-free',
    (tester) async {
      final oracle = ExerciseErrorCollector()..install();
      addTearDown(oracle.uninstall);
      final config = catalogExerciseConfig(
        mode: 'smoke',
        viewport: ExerciseViewport.laptop1366x768,
      );
      final trace = await ExerciseRunner.runSmoke(
        tester: tester,
        config: config,
        callbacks: catalogCallbacks(tester),
        oracle: oracle,
      );
      expect(
        trace.errors,
        isEmpty,
        reason: 'SMOKE @ laptop must be error-free: ${trace.errors.join('\n')}',
      );
      await _persist(tester, trace, 'catalog_smoke_s0_laptop-1366x768.json');
    },
  );
}
