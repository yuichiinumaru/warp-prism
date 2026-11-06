import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

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

  group('DSTimeMachineScrubber Layout Contract & Constraint Regressions', () {
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

    testWidgets(
      'renders without RenderFlex overflow under h=119 fixed panel constraint',
      (tester) async {
        setupStrictOverflowFailure(tester);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 640,
                height: 119,
                child: PrismTimeMachineScrubber(
                  title: 'Activity density (fixture)',
                  buckets: fixtureBuckets(),
                  initialPlayhead: domainStart.add(const Duration(hours: 12)),
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.byType(PrismTimeMachineScrubber), findsOneWidget);
        expect(
          find.byKey(PrismTimeMachineScrubber.histogramKey),
          findsOneWidget,
        );
        expect(find.text('Activity density (fixture)'), findsOneWidget);
      },
    );

    testWidgets(
      'renders without overflow under real Catalog host constraint (SizedBox 180 Column Expanded)',
      (tester) async {
        setupStrictOverflowFailure(tester);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                height: 180,
                width: 640,
                child: ColoredBox(
                  color: PrismColors.obsidianDeep,
                  child: Padding(
                    padding: const EdgeInsets.all(PrismSpacing.sm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: PrismTimeMachineScrubber(
                            title: 'Activity density (fixture)',
                            buckets: fixtureBuckets(),
                            initialPlayhead: domainStart.add(
                              const Duration(hours: 12),
                            ),
                          ),
                        ),
                        const SizedBox(height: PrismSpacing.xs),
                        const PrismText.labelSmall(
                          'Fixture 24h density · scrub or play',
                          color: PrismColors.textTertiary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.byType(PrismTimeMachineScrubber), findsOneWidget);
      },
    );

    testWidgets('renders without overflow when title is null and height=119', (
      tester,
    ) async {
      setupStrictOverflowFailure(tester);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 640,
              height: 119,
              child: PrismTimeMachineScrubber(
                title: null,
                buckets: fixtureBuckets(),
                initialPlayhead: domainStart.add(const Duration(hours: 12)),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(PrismTimeMachineScrubber), findsOneWidget);
    });

    testWidgets(
      'renders without overflow when buckets are empty and height=119',
      (tester) async {
        setupStrictOverflowFailure(tester);

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 640,
                height: 119,
                child: PrismTimeMachineScrubber(
                  title: 'Empty fixture',
                  buckets: [],
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.byType(PrismTimeMachineScrubber), findsOneWidget);
      },
    );

    testWidgets('holds at 1280x800 capture viewport', (tester) async {
      setupStrictOverflowFailure(tester);
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 640,
              height: 119,
              child: PrismTimeMachineScrubber(
                title: 'Capture Viewport 1280x800',
                buckets: fixtureBuckets(),
                initialPlayhead: domainStart.add(const Duration(hours: 12)),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(PrismTimeMachineScrubber), findsOneWidget);
    });

    testWidgets('holds at 1920x1080 desktop viewport class', (tester) async {
      setupStrictOverflowFailure(tester);
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 119,
              child: PrismTimeMachineScrubber(
                title: 'Desktop Class 1920x1080',
                buckets: fixtureBuckets(),
                initialPlayhead: domainStart.add(const Duration(hours: 12)),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(PrismTimeMachineScrubber), findsOneWidget);
    });

    testWidgets(
      'handles extreme constraint h=60 with scrollable fallback without throwing RenderFlex error',
      (tester) async {
        setupStrictOverflowFailure(tester);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 640,
                height: 60,
                child: PrismTimeMachineScrubber(
                  title: 'Extreme Constraint',
                  buckets: fixtureBuckets(),
                  initialPlayhead: domainStart.add(const Duration(hours: 12)),
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.byType(PrismTimeMachineScrubber), findsOneWidget);
      },
    );

    // =========================================================================
    // Task 1836 F1: Titled Scrubber Height Band Regressions {70, 80, 90, 95, 100}
    // =========================================================================
    for (final h in [70.0, 80.0, 90.0, 95.0, 100.0]) {
      testWidgets(
        'Task 1836 F1: titled scrubber renders without overflow at h=$h',
        (tester) async {
          setupStrictOverflowFailure(tester);

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: SizedBox(
                  width: 640,
                  height: h,
                  child: PrismTimeMachineScrubber(
                    title: 'Activity density (fixture)',
                    buckets: fixtureBuckets(),
                    initialPlayhead: domainStart.add(const Duration(hours: 12)),
                  ),
                ),
              ),
            ),
          );
          await tester.pump();

          expect(find.byType(PrismTimeMachineScrubber), findsOneWidget);
        },
      );
    }

    // =========================================================================
    // Task 1836 F2: Empty State with Title Band Regressions {110, 118, 119}
    // =========================================================================
    for (final h in [110.0, 118.0, 119.0]) {
      testWidgets(
        'Task 1836 F2: empty state with title renders without overflow at h=$h',
        (tester) async {
          setupStrictOverflowFailure(tester);

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: SizedBox(
                  width: 640,
                  height: h,
                  child: const PrismTimeMachineScrubber(
                    title: 'Empty fixture with title',
                    buckets: [],
                  ),
                ),
              ),
            ),
          );
          await tester.pump();

          expect(find.byType(PrismTimeMachineScrubber), findsOneWidget);

          if (h == 119.0) {
            // Assert at least 4px of slack at h=119
            final columnFinder = find
                .descendant(
                  of: find.byType(PrismTimeMachineScrubber),
                  matching: find.byType(Column),
                )
                .first;
            final columnSize = tester.getSize(columnFinder);
            // In compact mode, panel padding is DSSpacing.sm (8px each side = 16px total)
            const panelVerticalPadding = 16.0;
            final totalRenderedHeight =
                columnSize.height + panelVerticalPadding;
            final slack = 119.0 - totalRenderedHeight;
            expect(
              slack,
              greaterThanOrEqualTo(4.0),
              reason:
                  'Rendered slack at h=119 must be >= 4px, but was $slack '
                  '(rendered content: $totalRenderedHeight px)',
            );
          }
        },
      );
    }

    // =========================================================================
    // Task 1836 F4: Text Scaling Regressions at h=119 {1.3, 1.6, 2.0}
    // =========================================================================
    for (final textScale in [1.3, 1.6, 2.0]) {
      testWidgets(
        'Task 1836 F4: renders without overflow under textScale=$textScale @ h=119',
        (tester) async {
          setupStrictOverflowFailure(tester);

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: MediaQuery(
                  data: MediaQueryData(
                    textScaler: TextScaler.linear(textScale),
                  ),
                  child: SizedBox(
                    width: 640,
                    height: 119,
                    child: PrismTimeMachineScrubber(
                      title: 'Activity density (scaled)',
                      buckets: fixtureBuckets(),
                      initialPlayhead: domainStart.add(
                        const Duration(hours: 12),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pump();

          expect(find.byType(PrismTimeMachineScrubber), findsOneWidget);
        },
      );
    }
  });
}
