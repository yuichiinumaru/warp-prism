/// Performance benchmark for PrismVirtualList and PrismVirtualGrid.
///
/// ## Honest SLA contract (Task 1123 path-to-100)
///
/// `flutter_test` wall-clock around `pump()` is **not** a production GPU
/// frame time. Harness scheduling, debug mode, and host load routinely push
/// measured scroll steps into tens of ms (historical live: avg ~35ms,
/// P99 ~95ms). This suite therefore does **not** claim or assert a hard
/// 16ms / 60fps gate.
///
/// What this suite **does** prove (acceptance SLA):
/// 1. **Virtualization**: initial build of 10K items builds O(viewport+cache)
///    children only (buildCount ≪ N).
/// 2. **O(1) jump-to-index** with fixed [PrismVirtualScrollConfig.itemExtent]:
///    jump near end rebuilds only viewport+cache and lands on the exact index.
/// 3. **Informational harness timings**: reports avg / P99 / max wall-clock
///    per scroll step under a soft harness-noise ceiling (not a product FPS
///    claim).
/// 4. **Grid virtualization**: 5K grid builds O(viewport) only.
///
/// Run: flutter test test/performance/virtual_scroll_benchmark.dart
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// Soft wall-clock ceiling for harness scroll steps (ms) — **informational only**.
///
/// Not a production frame budget and **not** a hard test assert. Concurrent
/// package load can push flutter_test `pump()` wall-clock well above isolated
/// runs (live 2026-07-17: solo ~43ms avg vs contended ~350ms+). The hard SLA
/// remains virtualization buildCount / jumpTo; this constant is only printed.
const double kHarnessScrollAvgMsSoft = 200.0;

/// Viewport-bound build budget for a ~800×600 list at 48px + highCache.
const int kViewportBuildBudget = 200;

void main() {
  // ---------------------------------------------------------------------------
  // GROUP: PrismVirtualList 10K — virtualization SLA
  // ---------------------------------------------------------------------------
  group('PrismVirtualList 10K virtualization SLA', () {
    testWidgets('10K fixed-extent items only build viewport + cache', (
      tester,
    ) async {
      const itemCount = 10000;
      var buildCount = 0;

      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: PrismVirtualList(
                itemCount: itemCount,
                config: PrismVirtualScrollConfig.highCache,
                itemBuilder: (context, index) {
                  buildCount++;
                  return SizedBox(
                    height: 48,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Text('Item $index'),
                          const Spacer(),
                          Text('Value ${index * 2}'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );

      stopwatch.stop();
      final buildTimeMs = stopwatch.elapsedMilliseconds;

      // Hard SLA: virtualization effectiveness.
      expect(
        buildCount,
        lessThan(itemCount),
        reason: 'Virtual scroll must not materialize all 10K items',
      );
      expect(
        buildCount,
        lessThan(kViewportBuildBudget),
        reason:
            '10K fixed-extent list must stay O(viewport+cache); '
            'built $buildCount (budget $kViewportBuildBudget)',
      );

      // Soft harness wall-clock (informational gate, not FPS claim).
      expect(
        buildTimeMs,
        lessThan(2000),
        reason:
            'Initial build under 2s (harness-tolerant; not a production frame budget)',
      );

      debugPrint('=== PrismVirtualList 10K Fixed — Virtualization SLA ===');
      debugPrint('  Total items:     $itemCount');
      debugPrint('  Items built:     $buildCount (SLA: < $kViewportBuildBudget)');
      debugPrint('  Build time:      ${buildTimeMs}ms (harness wall-clock)');
      debugPrint('  Config:          highCache (48px extent, 500px cache)');
      debugPrint('  Note:            No 16ms/60fps claim in flutter_test');
    });

    testWidgets(
      'scroll through 10K reports harness timings (soft reference, hard virt)',
      (tester) async {
        const itemCount = 10000;
        final controller = ScrollController();
        final frameTimes = <double>[];
        var buildCount = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 800,
                height: 600,
                child: PrismVirtualList(
                  itemCount: itemCount,
                  scrollController: controller,
                  config: PrismVirtualScrollConfig.highCache,
                  itemBuilder: (context, index) {
                    buildCount++;
                    return SizedBox(
                      height: 48,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text('Item $index'),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );

        final initialBuilds = buildCount;
        expect(initialBuilds, lessThan(kViewportBuildBudget));

        // Scroll through the list in steps; measure harness wall-clock only.
        const scrollStep = 2400.0; // ~50 items per step
        const maxExtent = itemCount * 48.0 - 600.0;

        for (double offset = 0; offset < maxExtent; offset += scrollStep) {
          final frameStopwatch = Stopwatch()..start();
          controller.jumpTo(offset);
          await tester.pump();
          frameStopwatch.stop();
          frameTimes.add(frameStopwatch.elapsedMicroseconds / 1000.0);
        }

        frameTimes.sort();
        final avgFrameTime =
            frameTimes.reduce((a, b) => a + b) / frameTimes.length;
        final p99Index = (frameTimes.length * 0.99).floor().clamp(
          0,
          frameTimes.length - 1,
        );
        final p99FrameTime = frameTimes[p99Index];
        final maxFrameTime = frameTimes.last;

        debugPrint('=== PrismVirtualList 10K Scroll — Harness Timings ===');
        debugPrint('  Total items:         $itemCount');
        debugPrint('  Frames measured:     ${frameTimes.length}');
        debugPrint(
          '  Avg step wall-clock: ${avgFrameTime.toStringAsFixed(2)}ms',
        );
        debugPrint(
          '  P99 step wall-clock: ${p99FrameTime.toStringAsFixed(2)}ms',
        );
        debugPrint(
          '  Max step wall-clock: ${maxFrameTime.toStringAsFixed(2)}ms',
        );
        debugPrint(
          '  Soft harness reference: ${kHarnessScrollAvgMsSoft.toStringAsFixed(0)}ms avg '
          '(informational; not asserted — contention-sensitive)',
        );
        if (avgFrameTime >= kHarnessScrollAvgMsSoft) {
          debugPrint(
            '  NOTE: soft reference exceeded under current host load '
            '(avg=${avgFrameTime.toStringAsFixed(2)}ms). Hard SLA is '
            'virtualization only, not wall-clock.',
          );
        }
        debugPrint(
          '  DISCLAIMER: flutter_test wall-clock ≠ production GPU frame time. '
          'Do not interpret as 60fps proof.',
        );

        // Hard SLA after full scroll: virtualization still holds (no wall-clock
        // soft assert — flaky under concurrent package test load).
        expect(find.text('Item 0'), findsNothing); // scrolled away
        expect(controller.offset, greaterThan(0));
        expect(
          buildCount,
          lessThan(itemCount),
          reason: 'Post-scroll virtualization must not materialize all items',
        );

        controller.dispose();
      },
    );

    testWidgets('fixed itemExtent enables O(1) jumpTo without full rebuild', (
      tester,
    ) async {
      const itemCount = 10000;
      var buildCount = 0;
      final controller = ScrollController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: PrismVirtualList(
                itemCount: itemCount,
                scrollController: controller,
                config: PrismVirtualScrollConfig.highCache,
                itemBuilder: (context, index) {
                  buildCount++;
                  return SizedBox(height: 48, child: Text('Item $index'));
                },
              ),
            ),
          ),
        ),
      );

      final initialBuilds = buildCount;
      expect(initialBuilds, lessThan(kViewportBuildBudget));

      // Jump near end — fixed extent allows O(1) offset math.
      buildCount = 0;
      controller.jumpTo((itemCount - 20) * 48.0);
      await tester.pump();

      expect(
        buildCount,
        lessThan(kViewportBuildBudget),
        reason: 'Jump-to-index must only rebuild viewport + cache, not 10K',
      );
      expect(find.text('Item ${itemCount - 15}'), findsOneWidget);

      controller.dispose();
    });
  });

  // ---------------------------------------------------------------------------
  // GROUP: fixed itemExtent advantage vs variable-extent builder
  // ---------------------------------------------------------------------------
  group('fixed itemExtent advantage', () {
    testWidgets(
      'fixed extent lands exact index; both stay O(viewport) on build',
      (tester) async {
        const itemCount = 10000;
        var fixedBuildCount = 0;
        var variableBuildCount = 0;
        final fixedController = ScrollController();
        final variableController = ScrollController();

        // Fixed-extent list.
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 800,
                height: 600,
                child: PrismVirtualList(
                  // Distinct key so later variable list is a fresh Element tree.
                  // Without this, Scrollable reuses the prior scroll offset and
                  // variable-extent layout measures every child up to that offset
                  // (~9000 builds) — a test harness artifact, not product cost.
                  key: const ValueKey('fixed-extent-list'),
                  itemCount: itemCount,
                  scrollController: fixedController,
                  config: const PrismVirtualScrollConfig(
                    itemExtent: 48,
                    cacheExtent: 250,
                  ),
                  itemBuilder: (context, index) {
                    fixedBuildCount++;
                    return SizedBox(height: 48, child: Text('Fixed $index'));
                  },
                ),
              ),
            ),
          ),
        );

        expect(fixedBuildCount, lessThan(kViewportBuildBudget));
        expect(fixedBuildCount, lessThan(itemCount));

        // Exact O(1) jump with fixed extent.
        fixedBuildCount = 0;
        const targetIndex = 9000;
        fixedController.jumpTo(targetIndex * 48.0);
        await tester.pump();

        expect(
          fixedBuildCount,
          lessThan(kViewportBuildBudget),
          reason: 'Fixed-extent jumpTo must stay viewport-bounded',
        );
        expect(
          find.text('Fixed $targetIndex'),
          findsOneWidget,
          reason: 'Fixed itemExtent enables exact index landing via O(1) math',
        );

        // Reset tree so residual ScrollPosition is not adopted by the next list.
        await tester.pumpWidget(const SizedBox.shrink());
        fixedController.dispose();

        // Variable-extent list still virtualizes on a **fresh** initial build.
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 800,
                height: 600,
                child: PrismVirtualList(
                  key: const ValueKey('variable-extent-list'),
                  itemCount: itemCount,
                  scrollController: variableController,
                  config: PrismVirtualScrollConfig.variable,
                  itemBuilder: (context, index) {
                    variableBuildCount++;
                    return SizedBox(
                      height: 40.0 + (index % 3) * 8.0,
                      child: Text('Var $index'),
                    );
                  },
                ),
              ),
            ),
          ),
        );

        expect(variableBuildCount, lessThan(itemCount));
        expect(
          variableBuildCount,
          lessThan(kViewportBuildBudget),
          reason: 'Variable-extent builder still virtualizes visible window',
        );

        debugPrint('=== Fixed vs Variable Comparison ===');
        debugPrint(
          '  Fixed post-jump builds: $fixedBuildCount (exact index $targetIndex)',
        );
        debugPrint(
          '  Variable initial builds: $variableBuildCount (still virtualized)',
        );
        debugPrint(
          '  Advantage: fixed itemExtent = exact O(1) jumpTo + stable extent',
        );
        debugPrint(
          '  Note: variable lists lack O(1) jump; deep scroll needs measure-from-start',
        );

        variableController.dispose();
      },
    );
  });

  // ---------------------------------------------------------------------------
  // GROUP: PrismVirtualGrid 5K — virtualization SLA
  // ---------------------------------------------------------------------------
  group('PrismVirtualGrid 5K virtualization SLA', () {
    testWidgets('5K grid items only build viewport + cache', (tester) async {
      const itemCount = 5000;
      var buildCount = 0;

      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: PrismVirtualGrid(
                itemCount: itemCount,
                crossAxisCount: 4,
                cacheExtent: 250,
                itemBuilder: (context, index) {
                  buildCount++;
                  return Card(child: Center(child: Text('Grid $index')));
                },
              ),
            ),
          ),
        ),
      );

      stopwatch.stop();
      final buildTimeMs = stopwatch.elapsedMilliseconds;

      expect(
        buildCount,
        lessThan(itemCount),
        reason: 'Virtual grid must not materialize all 5K items',
      );
      expect(
        buildCount,
        lessThan(kViewportBuildBudget),
        reason:
            '5K grid must stay O(viewport+cache); built $buildCount',
      );
      expect(
        buildTimeMs,
        lessThan(2000),
        reason:
            'Initial build under 2s (harness-tolerant; not a production frame budget)',
      );

      debugPrint('=== PrismVirtualGrid 5K — Virtualization SLA ===');
      debugPrint('  Total items:  $itemCount');
      debugPrint('  Items built:  $buildCount (SLA: < $kViewportBuildBudget)');
      debugPrint('  Build time:   ${buildTimeMs}ms (harness wall-clock)');
      debugPrint('  Note:         No 16ms/60fps claim in flutter_test');
    });
  });
}
