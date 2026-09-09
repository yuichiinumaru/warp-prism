import 'dart:convert';
import 'dart:io';

import '../models/exercise_trace.dart';

/// Failure-artifact writer for host exercise runs.
///
/// On failure preserves: seed, ordered action trace, host, route, viewport,
/// theme, exact error/stack, last successful action, screenshot path when
/// reliable capture exists, log excerpt, and the deterministic replay
/// command. Artifacts land under the existing canonical test/report
/// location (`docs/reports/host-exercise/traces/`) — no second governance
/// ledger is invented.
class ExerciseTraceWriter {
  /// Builds the deterministic replay command for a trace artifact path.
  static String replayCommand({
    required String host,
    required String mode,
    required int seed,
    required String tracePath,
  }) {
    return 'dart run tool/warp_ui_exercise.dart '
        '--host $host --mode $mode --seed $seed --replay $tracePath';
  }

  /// Flutter-test invocation that replays the same host/mode/seed.
  static String flutterReplayCommand({
    required String host,
    required String mode,
    required int seed,
  }) {
    final testFile = _testFileForHost(host);
    return 'cd apps/$host && flutter test '
        'integration_test/host_exercise/$testFile '
        '--plain-name "${mode.toUpperCase()} seed=$seed"';
  }

  static String _testFileForHost(String host) {
    switch (host) {
      case 'catalog':
        return 'catalog_exercise_test.dart';
      case 'observatory':
        return 'observatory_exercise_test.dart';
      case 'cybercore':
        return 'cybercore_exercise_test.dart';
      default:
        return '${host}_exercise_test.dart';
    }
  }

  /// Resolves the repository root by walking up to `docs/reports`.
  static Directory repositoryRoot() {
    var directory = Directory.current;
    while (directory.parent.path != directory.path) {
      if (Directory('${directory.path}/docs/reports').existsSync()) {
        return directory;
      }
      directory = directory.parent;
    }
    return Directory.current;
  }

  /// Writes [trace] as compact JSON and returns the artifact file.
  ///
  /// NOTE: this performs real disk I/O. `testWidgets` bodies run in a
  /// fake-async zone where disk I/O never completes — callers inside
  /// widget tests must use [encodeTraceJson]/[decodeTraceJson] instead,
  /// or wrap this in `tester.runAsync`.
  static Future<File> writeTrace(
    ExerciseTrace trace, {
    String? fileName,
  }) async {
    final root = repositoryRoot();
    final directory = Directory(
      '${root.path}/docs/reports/host-exercise/traces',
    );
    await directory.create(recursive: true);
    final name =
        fileName ??
        '${trace.host}_${trace.mode}_s${trace.seed}_${DateTime.now().millisecondsSinceEpoch}.json';
    final file = File('${directory.path}/$name');
    await file.writeAsString('${encodeTraceJson(trace)}\n', flush: true);
    return file;
  }

  /// Pure JSON encode — safe inside the fake-async `testWidgets` zone.
  static String encodeTraceJson(ExerciseTrace trace) {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(trace.toJson());
  }

  /// Pure JSON decode — safe inside the fake-async `testWidgets` zone.
  static ExerciseTrace decodeTraceJson(String raw) {
    return ExerciseTrace.fromJson(
      Map<String, Object?>.from(json.decode(raw) as Map),
    );
  }

  /// Resolves the canonical trace artifact path for a run (caller may
  /// write it from a `tester.runAsync` block or a process boundary).
  static String traceArtifactPath(ExerciseTrace trace, {String? fileName}) {
    final root = repositoryRoot();
    final directory = Directory(
      '${root.path}/docs/reports/host-exercise/traces',
    );
    final name =
        fileName ??
        '${trace.host}_${trace.mode}_s${trace.seed}_${DateTime.now().millisecondsSinceEpoch}.json';
    return '${directory.path}/$name';
  }

  /// Reads a trace artifact back (replay input).
  static Future<ExerciseTrace> readTrace(File file) async {
    final raw = await file.readAsString();
    return ExerciseTrace.fromJson(
      Map<String, Object?>.from(json.decode(raw) as Map),
    );
  }

  /// Builds a trace with the replay command filled in.
  static ExerciseTrace withReplayCommand(
    ExerciseTrace trace,
    String tracePath,
  ) {
    return ExerciseTrace(
      seed: trace.seed,
      host: trace.host,
      mode: trace.mode,
      initialRoute: trace.initialRoute,
      viewport: trace.viewport,
      themeRecipe: trace.themeRecipe,
      actionBudget: trace.actionBudget,
      actions: trace.actions,
      errors: trace.errors,
      replayCommand: replayCommand(
        host: trace.host,
        mode: trace.mode,
        seed: trace.seed,
        tracePath: tracePath,
      ),
    );
  }
}
