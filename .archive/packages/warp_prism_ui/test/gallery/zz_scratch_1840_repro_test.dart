// TEMPORARY DIAGNOSTIC HARNESS — Task 1840. NOT A DELIVERABLE.
// Post-fix content-integrity check for the two fixed sections.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

void main() {
  testWidgets('1840: fixed sections still render full content', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1400, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final captured = <FlutterErrorDetails>[];
    final original = FlutterError.onError;
    addTearDown(() => FlutterError.onError = original);

    // --- epic15-stage-chrome: StatusTicker demo content intact ---
    FlutterError.onError = captured.add;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: PrismGallerySections.buildEpic15StageChromeSection(),
          ),
        ),
      ),
    );
    await tester.pump();
    FlutterError.onError = original;

    // ignore: avoid_print
    print('1840|chrome|captions=${find.text('Rotate (auto · pause on hover)').evaluate().length}');
    // ignore: avoid_print
    print('1840|chrome|marqueeCaption=${find.text('Marquee (seamless track)').evaluate().length}');
    // ignore: avoid_print
    print('1840|chrome|tickers=${find.byKey(const Key('ds-status-ticker')).evaluate().length}');
    final tickerSize = tester.getSize(find.byKey(const Key('ds-status-ticker')).first);
    // ignore: avoid_print
    print('1840|chrome|tickerRenderedSize=${tickerSize.width}x${tickerSize.height}');
    final demoSize = tester.getSize(find.byKey(const Key('ds-status-ticker')).first);
    // ignore: avoid_print
    print('1840|chrome|tickerWidgetSize=${demoSize.width}x${demoSize.height}');

    // --- epic15-stage-relations: layer registry switches intact ---
    captured.clear();
    FlutterError.onError = captured.add;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: PrismGallerySections.buildEpic15StageRelationsSection(),
          ),
        ),
      ),
    );
    await tester.pump();
    FlutterError.onError = original;

    for (final label in ['Basemap grid', 'Agents', 'Alerts']) {
      // ignore: avoid_print
      print('1840|relations|layer[$label]=${find.text(label).evaluate().length}');
    }
    // ignore: avoid_print
    print('1840|relations|switchTiles=${find.byType(SwitchListTile).evaluate().length}');

    // ignore: avoid_print
    print('1840|TOTAL_ERRORS=${captured.length}');
    // ignore: avoid_print
    print('===== INTEGRITY DONE =====');
  });
}
