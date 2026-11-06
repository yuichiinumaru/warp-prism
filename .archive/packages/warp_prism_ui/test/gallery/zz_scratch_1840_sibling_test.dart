// TEMPORARY DIAGNOSTIC HARNESS — Task 1840. NOT A DELIVERABLE.
// Detail capture for the sibling finding at the default catalog viewport.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

void main() {
  testWidgets('1840 sibling detail: health-dashboard @ 1280x800', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final section = dsGallerySections.firstWhere(
      (s) => s.id == 'health-dashboard',
    );

    final original = FlutterError.onError;
    addTearDown(() => FlutterError.onError = original);

    final captured = <FlutterErrorDetails>[];
    FlutterError.onError = captured.add;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: section.builder()),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    FlutterError.onError = original;

    for (final d in captured) {
      // ignore: avoid_print
      print('1840|DETAIL>>>');
      // ignore: avoid_print
      print(d.toString());
    }
    // ignore: avoid_print
    print('1840|errors=${captured.length}');
  });
}
