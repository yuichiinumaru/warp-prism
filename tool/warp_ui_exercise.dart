#!/usr/bin/env dart

// Warp Prism Real-Host UI Exercise — replay CLI helper.
//
// Conceptual contract:
//   warp-ui-exercise --host catalog --seed 18473 --replay <trace.json>
//
// This CLI validates a recorded trace artifact and prints the deterministic
// flutter-test replay command. The actual replay executes through each
// host's exercise test file (see --replay output), keeping a single
// execution surface consistent with repository conventions (melos +
// flutter test) rather than a second runner process.
//
// Pure Dart (no Flutter import): runs with `dart run` at the repo root.
library;

import 'dart:convert';
import 'dart:io';

const hosts = <String>['catalog', 'observatory', 'cybercore'];

void main(List<String> args) {
  var host = 'catalog';
  var mode = 'fuzz';
  var seed = 0;
  String? tracePath;

  for (var i = 0; i < args.length; i++) {
    switch (args[i]) {
      case '--host':
        host = args[++i];
      case '--mode':
        mode = args[++i];
      case '--seed':
        seed = int.tryParse(args[++i]) ?? 0;
      case '--replay':
        tracePath = args[++i];
      case '--help' || '-h':
        _usage();
        return;
      default:
        stderr.writeln('unknown argument: ${args[i]}');
        _usage();
        exitCode = 2;
        return;
    }
  }

  if (!hosts.contains(host)) {
    stderr.writeln('unknown host: $host (expected one of $hosts)');
    exitCode = 2;
    return;
  }

  stdout.writeln('warp-ui-exercise: host=$host mode=$mode seed=$seed');

  if (tracePath != null) {
    final file = File(tracePath);
    if (!file.existsSync()) {
      stderr.writeln('trace not found: $tracePath');
      exitCode = 2;
      return;
    }
    final decoded = _validateTrace(file, tracePath);
    if (decoded == null) return; // exitCode set by _validateTrace
    stdout.writeln(
      'trace OK: ${decoded['host']} ${decoded['mode']} '
      'seed=${decoded['seed']} steps='
      '${(decoded['actions'] as List?)?.length ?? 0} '
      'errors=${((decoded['errors'] as List?) ?? const []).length}',
    );
    final replaySeed = (decoded['seed'] as num?)?.toInt() ?? seed;
    stdout.writeln();
    stdout.writeln('deterministic replay command:');
    stdout.writeln('  WARP_UI_EXERCISE_TRACE=$tracePath \\');
    stdout.writeln(
      '    cd apps/$host && flutter test test/host_exercise/'
      '${host}_exercise_test.dart --plain-name '
      '"replay: recorded trace artifact replays from disk"',
    );
    stdout.writeln();
    stdout.writeln('seeded regeneration command (no artifact needed):');
    stdout.writeln(
      '  cd apps/$host && flutter test test/host_exercise/'
      '${host}_exercise_test.dart --plain-name '
      '"FUZZ seed=$replaySeed"',
    );
    stdout.writeln();
    stdout.writeln('ordered action trace:');
    final actions =
        (decoded['actions'] as List?)?.cast<Map<String, Object?>>() ??
        const <Map<String, Object?>>[];
    for (final action in actions) {
      stdout.writeln(
        '  [${action['index']}] ${action['action']} ${action['target']} '
        '(${action['route_before']} -> ${action['route_after']})',
      );
    }
    return;
  }

  // No --replay: print the canonical run commands for host+mode+seed.
  stdout.writeln();
  stdout.writeln('run commands:');
  stdout.writeln(
    '  cd apps/$host && flutter test test/host_exercise/'
    '${host}_exercise_test.dart '
    '--plain-name "${mode.toUpperCase()} seed=$seed"',
  );
  stdout.writeln();
  stdout.writeln(
    'artifact replay (any recorded trace): set '
    'WARP_UI_EXERCISE_TRACE=<trace.json> and run the '
    '"replay: recorded trace artifact replays from disk" test.',
  );
}

Map<String, Object?>? _validateTrace(File file, String path) {
  try {
    final decoded = json.decode(file.readAsStringSync());
    if (decoded is! Map<String, Object?>) {
      stderr.writeln('trace root is not an object: $path');
      exitCode = 2;
      return null;
    }
    for (final field in <String>['seed', 'host', 'mode', 'actions']) {
      if (!decoded.containsKey(field)) {
        stderr.writeln('trace missing required field "$field": $path');
        exitCode = 2;
        return null;
      }
    }
    return decoded;
  } on FormatException catch (error) {
    stderr.writeln('invalid trace JSON ($path): $error');
    exitCode = 2;
    return null;
  }
}

void _usage() {
  stdout.writeln('''

warp-ui-exercise — Warp Prism real-host UI exercise harness control

Usage:
  dart run tool/warp_ui_exercise.dart --host <host> [--mode <smoke|crawl|fuzz>] [--seed <n>] [--replay <trace.json>]

Hosts: ${hosts.join(', ')}

Modes:
  smoke  cheap deterministic canonical paths (affected-host gate)
  crawl  deterministic bounded sequential exploration (wave closeout)
  fuzz   seeded reproducible random walk (checkpoint / milestone boundary)

Without --replay, prints the canonical flutter-test run commands.
With --replay, validates the trace artifact and prints the deterministic
replay command plus the ordered action list.

Trace artifacts live under docs/reports/host-exercise/traces/.
''');
}
