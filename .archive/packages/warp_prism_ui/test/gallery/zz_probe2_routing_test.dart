// TEMPORARY INVESTIGATION PROBE 2 — Task 1843. To be removed.
// Question: does a deliberate RenderFlex overflow actually reach
// FlutterError.onError under TestWidgetsFlutterBinding, and would an
// unconsumed error fail the test? Determines how the regression
// assertion must be written to be non-vacuous.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('PROBE2: does overflow reach FlutterError.onError?', (
    tester,
  ) async {
    final seen = <String>[];
    final baseline = FlutterError.onError;
    FlutterError.onError = (d) => seen.add(d.exceptionAsString());
    addTearDown(() => FlutterError.onError = baseline);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Row(
            children: <Widget>[
              const SizedBox(width: 500, child: Text('AAAAAAAAAA')),
              Container(width: 500, color: const Color(0xFFFF0000)),
            ],
          ),
        ),
      ),
    );
    await tester.pump();

    // ignore: avoid_print
    print('===PROBE2=== ONERROR_COUNT=${seen.length}');
    for (final s in seen) {
      // ignore: avoid_print
      print('===PROBE2=== ${s.split('\n').first}');
    }
    FlutterError.onError = baseline;
  });

  testWidgets('PROBE2: would an UNCONSUMED error fail this test?', (
    tester,
  ) async {
    // Deliberately raise an error and never call takeException().
    // If flutter_test auto-fails, this test fails — which tells us the
    // gallery suite WOULD catch a real layout error without a suppressor.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Row(
            children: <Widget>[
              const SizedBox(width: 500, child: Text('AAAAAAAAAA')),
              Container(width: 500, color: const Color(0xFFFF0000)),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
  });
}
