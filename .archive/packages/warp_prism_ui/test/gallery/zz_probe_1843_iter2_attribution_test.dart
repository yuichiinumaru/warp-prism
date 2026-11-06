// TEMPORARY Task 1843 iteration-2 attribution probe — archived after the run.
// Isolates the 7.3px bottom overflow observed in section `health-dashboard` at
// 1280x800 during the census, and captures the offending widget from the
// FlutterErrorDetails information collector.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

void main() {
  testWidgets('attribute the health-dashboard 1280x800 overflow', (
    tester,
  ) async {
    final FlutterExceptionHandler? previous = FlutterError.onError;
    int hits = 0;
    FlutterError.onError = (FlutterErrorDetails details) {
      final String msg = details.exceptionAsString();
      if (msg.contains('overflowed')) {
        hits++;
        // ignore: avoid_print
        print('===ATTR-HIT=== $msg');
        // ignore: avoid_print
        print(
          '===ATTR-DIAGNOSTICS=== ${details.toDiagnosticsNode().toStringDeep()}',
        );
        final Iterable<DiagnosticsNode> info =
            details.informationCollector?.call() ?? const <DiagnosticsNode>[];
        for (final DiagnosticsNode node in info) {
          // ignore: avoid_print
          print('===ATTR-INFO=== ${node.toString()}');
        }
      }
      previous?.call(details);
    };
    addTearDown(() => FlutterError.onError = previous);

    await tester.binding.setSurfaceSize(const Size(1280, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final section = dsGallerySections.firstWhere(
      (dynamic s) => s.id == 'health-dashboard',
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: SingleChildScrollView(child: section.builder())),
      ),
    );
    await tester.pump();
    while (tester.takeException() != null) {}

    // ignore: avoid_print
    print('===ATTR-TOTAL=== $hits');
  });
}
