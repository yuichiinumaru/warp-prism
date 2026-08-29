import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// Task 1507: PrismTimeMachineScrubber widget tests
///
/// Covers: density buckets render, scrub, play/pause, empty series,
/// min/max bounds, range/playhead callbacks, a11y transport labels.
void main() {
  final domainStart = DateTime.utc(2026, 7, 10, 0, 0);
  final domainEnd = DateTime.utc(2026, 7, 11, 0, 0);

  List<PrismTimeDensityBucket> fixtureBuckets({int hours = 24}) {
    return List<PrismTimeDensityBucket>.generate(hours, (i) {
      final start = domainStart.add(Duration(hours: i));
      return PrismTimeDensityBucket(
        id: 'b$i',
        start: start,
        end: start.add(const Duration(hours: 1)),
        count: 4 + (i % 5) * 3,
        severity: i == 18
            ? PrismTimeDensitySeverity.high
            : PrismTimeDensitySeverity.none,
        label: 'Bucket $i',
      );
    });
  }

  Widget harness({
    List<PrismTimeDensityBucket>? buckets,
    DateTime? playhead,
    DateTime? initialPlayhead,
    DateTime? minTime,
    DateTime? maxTime,
    ValueChanged<DateTime>? onPlayheadChanged,
    ValueChanged<DateTimeRange>? onRangeChanged,
    ValueChanged<bool>? onPlayingChanged,
    Duration playbackStep = const Duration(hours: 1),
    Duration playbackTickInterval = const Duration(milliseconds: 100),
    bool showTransport = true,
    String? title = 'Time machine',
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 640,
          height: 200,
          child: PrismTimeMachineScrubber(
            title: title,
            buckets: buckets ?? fixtureBuckets(),
            playhead: playhead,
            initialPlayhead: initialPlayhead ?? domainStart,
            minTime: minTime,
            maxTime: maxTime,
            onPlayheadChanged: onPlayheadChanged,
            onRangeChanged: onRangeChanged,
            onPlayingChanged: onPlayingChanged,
            playbackStep: playbackStep,
            playbackTickInterval: playbackTickInterval,
            showTransport: showTransport,
          ),
        ),
      ),
    );
  }

  group('PrismTimeMachineScrubber', () {
    testWidgets('renders density histogram and transport from fixture series', (
      tester,
    ) async {
      await tester.pumpWidget(harness());

      expect(find.byType(PrismTimeMachineScrubber), findsOneWidget);
      expect(
        find.byKey(PrismTimeMachineScrubber.panelRegionKey),
        findsOneWidget,
      );
      expect(find.byKey(PrismTimeMachineScrubber.histogramKey), findsOneWidget);
      expect(
        find.byKey(PrismTimeMachineScrubber.playheadHandleKey),
        findsOneWidget,
      );
      expect(find.text('Time machine'), findsOneWidget);
      expect(find.byKey(PrismTimeMachineScrubber.playPauseKey), findsOneWidget);
      expect(find.byKey(PrismTimeMachineScrubber.skipBackKey), findsOneWidget);
      expect(
        find.byKey(PrismTimeMachineScrubber.skipForwardKey),
        findsOneWidget,
      );
      expect(find.byKey(PrismTimeMachineScrubber.liveKey), findsOneWidget);
      expect(find.byKey(PrismTimeMachineScrubber.clockKey), findsOneWidget);
    });

    testWidgets('emits playhead + as-of range on skip forward/back', (
      tester,
    ) async {
      final playheads = <DateTime>[];
      final ranges = <DateTimeRange>[];

      await tester.pumpWidget(
        harness(
          initialPlayhead: domainStart.add(const Duration(hours: 6)),
          onPlayheadChanged: playheads.add,
          onRangeChanged: ranges.add,
        ),
      );
      await tester.pump(); // post-frame initial emit
      playheads.clear();
      ranges.clear();

      await tester.tap(find.byKey(PrismTimeMachineScrubber.skipForwardKey));
      await tester.pump();

      expect(playheads, isNotEmpty);
      expect(playheads.last, equals(domainStart.add(const Duration(hours: 7))));
      expect(ranges.last.start, equals(domainStart));
      expect(ranges.last.end, equals(playheads.last));

      await tester.tap(find.byKey(PrismTimeMachineScrubber.skipBackKey));
      await tester.pump();

      expect(playheads.last, equals(domainStart.add(const Duration(hours: 6))));
    });

    testWidgets('scrub via histogram tap moves playhead', (tester) async {
      final playheads = <DateTime>[];

      await tester.pumpWidget(
        harness(initialPlayhead: domainStart, onPlayheadChanged: playheads.add),
      );
      await tester.pump();
      playheads.clear();

      final hist = find.byKey(PrismTimeMachineScrubber.histogramKey);
      expect(hist, findsOneWidget);

      // Tap near the right edge → near domain end.
      await tester.tapAt(tester.getTopRight(hist) + const Offset(-8, 20));
      await tester.pump();

      expect(playheads, isNotEmpty);
      // Should be closer to end than start.
      final mid = domainStart.add(
        Duration(
          milliseconds: domainEnd.difference(domainStart).inMilliseconds ~/ 2,
        ),
      );
      expect(playheads.last.isAfter(mid), isTrue);
    });

    testWidgets('play/pause advances playhead then stops', (tester) async {
      final playheads = <DateTime>[];
      final playing = <bool>[];

      await tester.pumpWidget(
        harness(
          initialPlayhead: domainStart,
          playbackStep: const Duration(hours: 2),
          playbackTickInterval: const Duration(milliseconds: 50),
          onPlayheadChanged: playheads.add,
          onPlayingChanged: playing.add,
        ),
      );
      await tester.pump();
      playheads.clear();

      await tester.tap(find.byKey(PrismTimeMachineScrubber.playPauseKey));
      await tester.pump();
      expect(playing, contains(true));

      // Advance a few ticks.
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 50));

      expect(playheads, isNotEmpty);
      expect(playheads.last.isAfter(domainStart), isTrue);

      await tester.tap(find.byKey(PrismTimeMachineScrubber.playPauseKey));
      await tester.pump();
      expect(playing.last, isFalse);

      final afterPause = List<DateTime>.from(playheads);
      await tester.pump(const Duration(milliseconds: 200));
      // No further advances while paused.
      expect(playheads.length, equals(afterPause.length));
    });

    testWidgets('empty series shows placeholder', (tester) async {
      await tester.pumpWidget(harness(buckets: const [], title: null));

      expect(
        find.byKey(PrismTimeMachineScrubber.emptyPlaceholderKey),
        findsOneWidget,
      );
      expect(find.text('No time series'), findsOneWidget);
      expect(find.byKey(PrismTimeMachineScrubber.histogramKey), findsNothing);
    });

    testWidgets('clamps playhead to min/max domain bounds', (tester) async {
      final playheads = <DateTime>[];
      final minT = domainStart.add(const Duration(hours: 4));
      final maxT = domainStart.add(const Duration(hours: 8));

      await tester.pumpWidget(
        harness(
          buckets: fixtureBuckets(hours: 24),
          minTime: minT,
          maxTime: maxT,
          initialPlayhead: domainStart, // before min → clamp to min
          onPlayheadChanged: playheads.add,
        ),
      );
      await tester.pump();

      // Initial emit should clamp to min.
      expect(playheads, isNotEmpty);
      expect(playheads.first, equals(minT));

      // Skip back at min stays at min.
      playheads.clear();
      await tester.tap(find.byKey(PrismTimeMachineScrubber.skipBackKey));
      await tester.pump();
      if (playheads.isNotEmpty) {
        expect(playheads.last, equals(minT));
      }

      // Jump live → max.
      playheads.clear();
      await tester.tap(find.byKey(PrismTimeMachineScrubber.liveKey));
      await tester.pump();
      expect(playheads.last, equals(maxT));

      // Skip forward at max stays at max.
      playheads.clear();
      await tester.tap(find.byKey(PrismTimeMachineScrubber.skipForwardKey));
      await tester.pump();
      if (playheads.isNotEmpty) {
        expect(playheads.last, equals(maxT));
      }
    });

    testWidgets('controlled playhead does not mutate internal state on skip', (
      tester,
    ) async {
      var current = domainStart.add(const Duration(hours: 3));
      final emitted = <DateTime>[];

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                body: SizedBox(
                  width: 640,
                  height: 200,
                  child: PrismTimeMachineScrubber(
                    buckets: fixtureBuckets(),
                    playhead: current,
                    playbackStep: const Duration(hours: 1),
                    onPlayheadChanged: (t) {
                      emitted.add(t);
                      setState(() => current = t);
                    },
                  ),
                ),
              ),
            );
          },
        ),
      );
      await tester.pump();
      emitted.clear();

      await tester.tap(find.byKey(PrismTimeMachineScrubber.skipForwardKey));
      await tester.pump();

      expect(emitted, isNotEmpty);
      expect(emitted.last, equals(domainStart.add(const Duration(hours: 4))));
    });

    testWidgets('transport controls expose a11y labels', (tester) async {
      final handle = tester.ensureSemantics();
      try {
        await tester.pumpWidget(harness(initialPlayhead: domainStart));
        await tester.pump();

        expect(find.bySemanticsLabel('Play'), findsOneWidget);
        expect(find.bySemanticsLabel('Skip forward'), findsOneWidget);
        expect(find.bySemanticsLabel('Jump to live'), findsOneWidget);
        // At domain start, skip back is disabled but still labeled.
        expect(find.bySemanticsLabel('Skip back'), findsOneWidget);

        // Panel region semantic label on the root Semantics node.
        final panelSemantics = tester.getSemantics(
          find.byKey(PrismTimeMachineScrubber.panelRegionKey),
        );
        expect(panelSemantics.label, contains('Time machine scrubber'));
      } finally {
        handle.dispose();
      }
    });

    testWidgets('slider semantics handle increase and decrease actions', (
      tester,
    ) async {
      final playheads = <DateTime>[];
      final handle = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          harness(
            initialPlayhead: domainStart.add(const Duration(hours: 6)),
            playbackStep: const Duration(hours: 1),
            onPlayheadChanged: playheads.add,
          ),
        );
        await tester.pump();
        playheads.clear();

        final semanticsFinder = find.byKey(
          PrismTimeMachineScrubber.histogramKey,
        );
        expect(semanticsFinder, findsOneWidget);

        final node = tester.getSemantics(semanticsFinder);
        expect(
          node.getSemanticsData().hasAction(SemanticsAction.increase),
          isTrue,
        );
        node.owner!.performAction(node.id, SemanticsAction.increase);
        await tester.pump();

        expect(playheads, isNotEmpty);
        expect(
          playheads.last,
          equals(domainStart.add(const Duration(hours: 7))),
        );

        playheads.clear();
        expect(
          node.getSemanticsData().hasAction(SemanticsAction.decrease),
          isTrue,
        );
        node.owner!.performAction(node.id, SemanticsAction.decrease);
        await tester.pump();

        expect(playheads, isNotEmpty);
        expect(
          playheads.last,
          equals(domainStart.add(const Duration(hours: 6))),
        );
      } finally {
        handle.dispose();
      }
    });

    testWidgets('domainOf derives min/max from buckets', (tester) async {
      final buckets = fixtureBuckets(hours: 6);
      final domain = PrismTimeMachineScrubber.domainOf(buckets: buckets);
      expect(domain.start, equals(domainStart));
      expect(domain.end, equals(domainStart.add(const Duration(hours: 6))));
    });

    test('public model + severity construct via Prism aliases', () {
      final start = DateTime.utc(2026, 1, 1);
      final bucket = PrismTimeDensityBucket(
        start: start,
        end: start.add(const Duration(hours: 1)),
        count: 3,
        severity: PrismTimeDensitySeverity.medium,
      );
      expect(bucket.count, 3);
      expect(bucket.severity, PrismTimeDensitySeverity.medium);
      expect(
        PrismTimeDensitySeverity.values,
        contains(PrismTimeDensitySeverity.high),
      );
    });
  });
}
