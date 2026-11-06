// TEMPORARY INVESTIGATION PROBE — Task 1843. To be removed.
// Captures every FlutterError raised by the gallery surface with NO
// suppressor installed, so the exact set of currently-suppressed
// messages can be measured rather than guessed.
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

void main() {
  testWidgets('PROBE: gallery page error census @1400x2400', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final captured = <String>[];
    final original = FlutterError.onError;
    FlutterError.onError = (details) {
      captured.add(details.exceptionAsString());
    };
    addTearDown(() => FlutterError.onError = original);

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: DesignSystemGalleryPage())),
    );
    await tester.pump();

    // Scroll the whole gallery so every section renders.
    for (final title in dsGallerySectionTitles) {
      try {
        await tester.scrollUntilVisible(
          find.textContaining(title).first,
          400,
          scrollable: find.byType(Scrollable).first,
        );
      } catch (_) {
        // Section may already be visible or not present; keep probing.
      }
      await tester.pump();
    }

    // ignore: avoid_print
    print('===PROBE=== PAGE_ERRORS_COUNT=${captured.length}');
    for (final m in captured) {
      final first = m.split('\n').first;
      // ignore: avoid_print
      print('===PROBE=== $first');
    }
    FlutterError.onError = original;
  });

  testWidgets('PROBE: each registry section builder error census', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1400, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final captured = <String, int>{};
    final original = FlutterError.onError;
    FlutterError.onError = (details) {
      final key = details.exceptionAsString().split('\n').first;
      captured[key] = (captured[key] ?? 0) + 1;
    };
    addTearDown(() => FlutterError.onError = original);

    for (final section in dsGallerySections) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: SingleChildScrollView(child: section.builder())),
        ),
      );
      await tester.pump();
    }

    // ignore: avoid_print
    print('===PROBE=== BUILDER_ERRORS_COUNT=${captured.length}');
    final keys = captured.keys.toList()..sort();
    for (final k in keys) {
      // ignore: avoid_print
      print('===PROBE=== x${captured[k]} | $k');
    }
    FlutterError.onError = original;
  });
}
