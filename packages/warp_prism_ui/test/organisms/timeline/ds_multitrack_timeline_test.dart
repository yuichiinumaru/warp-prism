// Conformance + widget suite for timeline chrome + verbs (Task 1874, F-07).
//
// Proves: organism (ruler + lanes + playhead) renders two caller ontologies
// (seconds AND bars/beats) through injected formatters; verbs resolve through
// Task 1868's frozen token-side interface (DSActionAuthority — consumed, never
// duplicated); the injected reference model stub holds the commit invariant
// (one gesture ⇒ one history step, live-vs-committed typed Set|Scrub);
// pixel↔time mapping is deterministic under fixed geometry; 48dp targets and
// a11y announcements hold; headless viewport/text-scale sweep stays green.
//
// EXPERIMENTAL: imports via src paths; no barrel export yet.
// Run: flutter test packages/warp_prism_ui/test/organisms/timeline/ds_multitrack_timeline_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_interaction/src/input/action_availability.dart';
import 'package:warp_prism_interaction/src/timeline/timeline_intent.dart';
import 'package:warp_prism_interaction/src/timeline/timeline_model.dart';
import 'package:warp_prism_ui/src/organisms/timeline/ds_multitrack_timeline.dart';
import 'package:warp_prism_ui/src/organisms/timeline/ds_time_ruler.dart';
import 'package:warp_prism_ui/src/organisms/timeline/ds_track_lane.dart';
import 'package:warp_prism_ui/src/tokens/ds_action_authority.dart';

// --- Caller-side reference formatters (the fake for this seam). ------------
//
// Prism ships no time ontology; these live in the test to prove the chrome
// renders whatever the caller injects, deterministically, in both ontologies.

// Ontology 1: seconds (WB `TimelineStrip` shape — 1s ticks).
String referenceFormatSecondsTick(double tick) =>
    '00:00:${tick.toInt().toString().padLeft(2, '0')}';

// Ontology 2: bars/beats (TP `MusicalRuler` shape — Bar.Beat labels).
String referenceFormatBarBeatTick(double beat) {
  const beatsPerBar = 4;
  final bar = (beat ~/ beatsPerBar) + 1;
  final current = (beat % beatsPerBar).toInt() + 1;
  return '${bar.toString().padLeft(3, '0')}.${current.toString().padLeft(2, '0')}';
}

Widget wrapTest(Widget child, {double width = 800, double height = 400}) =>
    MaterialApp(
      home: Scaffold(
        body: SizedBox(width: width, height: height, child: child),
      ),
    );

DSMultitrackTimeline buildTimeline({
  required String Function(double) formatTick,
  required List<double> ticks,
  required double displayPosition,
  DSActionAuthority rulerAuthority = DSActionAuthority.allow,
  String? rulerReason,
  DSActionAuthority laneAuthority = DSActionAuthority.allow,
  String? laneReason,
  ValueChanged<double>? onSeek,
  ValueChanged<double>? onScrubStart,
  ValueChanged<double>? onScrubUpdate,
  ValueChanged<double>? onScrubEnd,
  ValueChanged<String>? onClipTap,
  ValueChanged<String>? onRefused,
}) {
  return DSMultitrackTimeline(
    tracks: const [
      DSTimelineTrack(
        trackId: 'v1',
        label: 'V1',
        clips: [
          DSTimelineClip(id: 'c1', start: 1.0, end: 3.0, label: 'Intro'),
          DSTimelineClip(
            id: 'c2',
            start: 4.0,
            end: 6.0,
            label: 'Verse',
            selected: true,
          ),
        ],
      ),
      DSTimelineTrack(
        trackId: 'a1',
        label: 'A1',
        clips: [
          DSTimelineClip(id: 'c3', start: 0.5, end: 7.5, label: 'Music bed'),
        ],
      ),
    ],
    ticks: ticks,
    formatTick: formatTick,
    visibleStart: 0.0,
    visibleEnd: 8.0,
    displayPosition: displayPosition,
    rulerAuthority: rulerAuthority,
    rulerReason: rulerReason,
    laneAuthority: laneAuthority,
    laneReason: laneReason,
    onSeek: onSeek,
    onScrubStart: onScrubStart,
    onScrubUpdate: onScrubUpdate,
    onScrubEnd: onScrubEnd,
    onClipTap: onClipTap,
    onRefused: onRefused,
  );
}

void main() {
  group('timeline_1874 seconds ontology renders', () {
    testWidgets('1s ticks render through the injected formatter', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapTest(
          buildTimeline(
            formatTick: referenceFormatSecondsTick,
            ticks: const [0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0],
            displayPosition: 1.5,
          ),
        ),
      );

      expect(find.text('00:00:01'), findsOneWidget);
      expect(find.text('00:00:08'), findsOneWidget);
      expect(find.byKey(DSMultitrackTimeline.playheadKey), findsOneWidget);
      expect(find.byKey(const Key('ds-track-lane-v1')), findsOneWidget);
      expect(find.byKey(const Key('ds-track-lane-a1')), findsOneWidget);
    });

    testWidgets('clips render positioned with labels and selection', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapTest(
          buildTimeline(
            formatTick: referenceFormatSecondsTick,
            ticks: const [0.0, 4.0, 8.0],
            displayPosition: 1.5,
          ),
        ),
      );

      expect(find.text('Intro'), findsOneWidget);
      expect(find.text('Verse'), findsOneWidget);
      expect(find.text('Music bed'), findsOneWidget);
    });
  });

  group('timeline_1874 bars/beats ontology renders', () {
    testWidgets('bar/beat ticks render through the injected formatter', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapTest(
          buildTimeline(
            formatTick: referenceFormatBarBeatTick,
            ticks: const [0.0, 4.0, 8.0, 12.0],
            displayPosition: 5.0,
          ),
        ),
      );

      expect(find.text('001.01'), findsOneWidget);
      expect(find.text('002.01'), findsOneWidget);
      expect(find.text('004.01'), findsOneWidget);
      // Same organism, second ontology: no Prism-side conversion involved.
      expect(find.byKey(DSMultitrackTimeline.playheadKey), findsOneWidget);
    });

    testWidgets('same inputs rebuild to the same strings (determinism)', (
      tester,
    ) async {
      Future<void> pump() => tester.pumpWidget(
        wrapTest(
          buildTimeline(
            formatTick: referenceFormatBarBeatTick,
            ticks: const [0.0, 4.0, 8.0],
            displayPosition: 5.0,
          ),
        ),
      );

      await pump();
      expect(find.text('002.01'), findsOneWidget);
      await pump();
      expect(find.text('002.01'), findsOneWidget);
    });
  });

  group('timeline_1874 pixel to time determinism (fixed geometry)', () {
    test('ruler mapping is fixed under fixed geometry', () {
      expect(
        DSTimeRuler.positionForPixel(
          dx: 400,
          viewportWidth: 800,
          start: 0,
          end: 8,
        ),
        equals(4.0),
      );
      expect(
        DSTimeRuler.pixelForPosition(
          position: 4,
          viewportWidth: 800,
          start: 0,
          end: 8,
        ),
        equals(400.0),
      );
    });

    testWidgets('tap seeks at the proportional position', (tester) async {
      double? sought;
      await tester.pumpWidget(
        wrapTest(
          buildTimeline(
            formatTick: referenceFormatSecondsTick,
            ticks: const [0.0, 4.0, 8.0],
            displayPosition: 0.0,
            onSeek: (position) => sought = position,
          ),
        ),
      );

      // Tap the horizontal center of the ruler: opaque position ≈ mid-window.
      final ruler = find.byKey(DSTimeRuler.rulerRegionKey);
      expect(ruler, findsOneWidget);
      await tester.tapAt(tester.getCenter(ruler));
      await tester.pump();
      expect(sought, isNotNull);
      expect(sought!, closeTo(4.0, 0.5));
    });

    testWidgets('clip tap reports the clip id', (tester) async {
      String? tapped;
      await tester.pumpWidget(
        wrapTest(
          buildTimeline(
            formatTick: referenceFormatSecondsTick,
            ticks: const [0.0, 4.0, 8.0],
            displayPosition: 0.0,
            onClipTap: (id) => tapped = id,
          ),
        ),
      );

      await tester.tap(find.text('Intro'));
      await tester.pump();
      expect(tapped, equals('c1'));
    });
  });

  group('timeline_1874 reference model stub and commit invariant', () {
    testWidgets('scrub gesture over the stub commits exactly once', (
      tester,
    ) async {
      // WB-side first (weaker layout): seconds ontology drives the gesture.
      final model = ReferenceTimelineModel(initialPosition: 1.5);
      final session = TimelineScrubSession();
      var live = 1.5;

      await tester.pumpWidget(
        wrapTest(
          StatefulBuilder(
            builder: (context, setState) => buildTimeline(
              formatTick: referenceFormatSecondsTick,
              ticks: const [0.0, 4.0, 8.0],
              displayPosition: live,
              onScrubStart: (position) {
                model.applyDispatch(
                  TimelineDispatch(session.addUpdate(position)),
                );
                setState(() => live = model.livePosition);
              },
              onScrubUpdate: (position) {
                model.applyDispatch(
                  TimelineDispatch(session.addUpdate(position)),
                );
                setState(() => live = model.livePosition);
              },
              onScrubEnd: (position) {
                model.applyDispatch(TimelineDispatch(session.finish(position)));
                setState(() => live = model.livePosition);
              },
            ),
          ),
        ),
      );

      final ruler = find.byKey(DSTimeRuler.rulerRegionKey);
      final center = tester.getCenter(ruler);
      final gesture = await tester.startGesture(center);
      await gesture.moveBy(const Offset(100, 0));
      await gesture.moveBy(const Offset(100, 0));
      await gesture.up();
      await tester.pump();

      expect(session.updateCount, greaterThanOrEqualTo(2));
      expect(session.isFinished, isTrue);
      expect(model.historySteps, equals(1));
      expect(model.livePosition, equals(model.committedPosition));
    });

    test('IDS verbs gate through allow/deny around the stub', () {
      final model = ReferenceTimelineModel(initialPosition: 0.0);

      final allowed = resolveTimelineVerb(
        const TimelineSeek(2.0),
        authority: const ActionAvailability.allow(),
      );
      expect(allowed, isA<TimelineDispatch>());
      model.applyDispatch(allowed as TimelineDispatch);
      expect(model.historySteps, equals(1));

      final denied = resolveTimelineVerb(
        const TimelineSeek(6.0),
        authority: ActionAvailability.deny('Locked'),
      );
      expect(denied, isA<TimelineRefusal>());
      expect((denied as TimelineRefusal).reason, equals('Locked'));
      expect(model.historySteps, equals(1));
      expect(model.committedPosition, equals(2.0));
    });
  });

  group('timeline_1874 gating renders disabled-with-reason (1868 seam)', () {
    testWidgets('denied ruler stays visible with reason and refuses', (
      tester,
    ) async {
      String? refused;
      await tester.pumpWidget(
        wrapTest(
          buildTimeline(
            formatTick: referenceFormatSecondsTick,
            ticks: const [0.0, 4.0, 8.0],
            displayPosition: 1.0,
            rulerAuthority: DSActionAuthority.deny,
            rulerReason: 'Timeline locked',
            onSeek: (_) => fail('denied seek must not dispatch'),
            onRefused: (reason) => refused = reason,
          ),
        ),
      );

      expect(find.byKey(DSTimeRuler.rulerRegionKey), findsOneWidget);
      expect(find.byKey(DSTimeRuler.refusalLineKey), findsOneWidget);
      expect(find.textContaining('Timeline locked'), findsWidgets);
      await tester.tap(find.byKey(DSTimeRuler.rulerRegionKey));
      await tester.pump();
      expect(refused, equals('Timeline locked'));
    });

    testWidgets('denied lanes stay visible with reason', (tester) async {
      await tester.pumpWidget(
        wrapTest(
          buildTimeline(
            formatTick: referenceFormatSecondsTick,
            ticks: const [0.0, 4.0, 8.0],
            displayPosition: 1.0,
            laneAuthority: DSActionAuthority.deny,
            laneReason: 'Read-only mix',
            onSeek: (_) => fail('denied lane seek must not dispatch'),
          ),
        ),
      );

      expect(find.byKey(const Key('ds-track-lane-v1')), findsOneWidget);
      expect(find.textContaining('Read-only mix'), findsWidgets);
    });

    testWidgets('constrained ruler dispatches with limitation visible', (
      tester,
    ) async {
      double? sought;
      await tester.pumpWidget(
        wrapTest(
          buildTimeline(
            formatTick: referenceFormatSecondsTick,
            ticks: const [0.0, 4.0, 8.0],
            displayPosition: 1.0,
            rulerAuthority: DSActionAuthority.constrain,
            rulerReason: 'Preview only',
            onSeek: (position) => sought = position,
          ),
        ),
      );

      expect(find.textContaining('Preview only'), findsWidgets);
      await tester.tap(find.byKey(DSTimeRuler.rulerRegionKey));
      await tester.pump();
      expect(sought, isNotNull);
    });
  });

  group('timeline_1874 a11y, targets, and headless sweep', () {
    testWidgets('ruler meets 48dp minimum and announces its label', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapTest(
          buildTimeline(
            formatTick: referenceFormatSecondsTick,
            ticks: const [0.0, 4.0, 8.0],
            displayPosition: 1.0,
          ),
        ),
      );

      final size = tester.getSize(find.byKey(DSTimeRuler.rulerRegionKey));
      expect(size.height, greaterThanOrEqualTo(48.0));
      expect(
        find.bySemanticsLabel(RegExp('Time ruler')),
        findsAtLeastNWidgets(1),
      );
    });

    testWidgets('headless sweep: narrow viewport and large text scale', (
      tester,
    ) async {
      for (final config in [
        (width: 360.0, scale: 1.0),
        (width: 800.0, scale: 2.0),
      ]) {
        await tester.pumpWidget(
          MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(config.scale)),
            child: wrapTest(
              buildTimeline(
                formatTick: referenceFormatSecondsTick,
                ticks: const [0.0, 2.0, 4.0, 6.0, 8.0],
                displayPosition: 3.0,
              ),
              width: config.width,
            ),
          ),
        );
        await tester.pump();
        expect(
          tester.takeException(),
          isNull,
          reason: 'width ${config.width}, scale ${config.scale}',
        );
        expect(find.byKey(DSMultitrackTimeline.playheadKey), findsOneWidget);
      }
    });
  });
}
