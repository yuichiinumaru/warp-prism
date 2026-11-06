import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/src/organisms/data_table/ds_data_table.dart';
import 'package:warp_prism_ui/src/organisms/time_machine_scrubber/ds_time_machine_scrubber.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// Task 1832: Combined Regression Test Suite for Fixed-Height Constraints
///
/// Asserts that both [DSTimeMachineScrubber] and [DSDataTable] render cleanly
/// without any RenderFlex overflow exceptions under real host constraints:
/// - DSTimeMachineScrubber under h=119 panel constraint (from Catalog)
/// - DSDataTable under BoxConstraints(w=958, h=50) (from CyberCore)
void main() {
  final domainStart = DateTime.utc(2026, 7, 10, 0, 0);

  List<PrismTimeDensityBucket> fixtureBuckets() {
    return List<PrismTimeDensityBucket>.generate(24, (i) {
      final start = domainStart.add(Duration(hours: i));
      return PrismTimeDensityBucket(
        id: 'b$i',
        start: start,
        end: start.add(const Duration(hours: 1)),
        count: 5 + i,
        severity: PrismTimeDensitySeverity.none,
        label: 'Bucket $i',
      );
    });
  }

  List<String> setupStrictOverflowFailure(WidgetTester tester) {
    final overflowErrors = <String>[];
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      final message = details.exceptionAsString();
      if (message.contains('overflow') || message.contains('RenderFlex')) {
        overflowErrors.add(message);
      }
      originalOnError?.call(details);
    };
    addTearDown(() {
      FlutterError.onError = originalOnError;
      expect(
        overflowErrors,
        isEmpty,
        reason: 'RenderFlex overflow detected:\n${overflowErrors.join('\n')}',
      );
    });
    return overflowErrors;
  }

  group('Task 1832 — Fixed-Height Layout Contract Regressions', () {
    testWidgets(
      'DSTimeMachineScrubber renders without RenderFlex overflow under h=119',
      (tester) async {
        setupStrictOverflowFailure(tester);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 640,
                height: 119,
                child: DSTimeMachineScrubber(
                  title: 'Activity density (fixture)',
                  buckets: fixtureBuckets(),
                  initialPlayhead: domainStart.add(const Duration(hours: 12)),
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.byType(DSTimeMachineScrubber), findsOneWidget);
      },
    );

    testWidgets(
      'DSDataTable renders without RenderFlex overflow under BoxConstraints(w=958, h=50)',
      (tester) async {
        setupStrictOverflowFailure(tester);

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 958,
                height: 50,
                child: DSDataTable(
                  columns: [
                    DSDataColumn(id: 'name', label: 'Name', sortable: true),
                    DSDataColumn(
                      id: 'provider',
                      label: 'Provider',
                      sortable: true,
                    ),
                    DSDataColumn(id: 'status', label: 'Status'),
                  ],
                  rows: [
                    DSDataRow(
                      id: '1',
                      cells: {
                        'name': 'OpenAI Production',
                        'provider': 'openai',
                        'status': 'active',
                      },
                    ),
                  ],
                  showPagination: false,
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.byType(DSDataTable), findsOneWidget);
      },
    );
  });
}
