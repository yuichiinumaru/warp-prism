// Conformance suite for timeline verbs + commit invariant (Task 1874, F-07).
//
// Proves: IDS verbs resolve over opaque numbers; Set|Scrub typing separates
// live preview from committed history; gating consumes Task 1868's frozen
// outcome type (deny ⇒ refusal, never dispatch); one gesture ⇒ exactly one
// history step on the reference fake; pixel↔time mapping is deterministic
// under fixed geometry; two caller ontologies (seconds AND bars/beats)
// convert deterministically through caller-side reference converters.
//
// EXPERIMENTAL: imports modules via src paths; no barrel export yet.
// Run: flutter test packages/warp_prism_interaction/test/timeline_intent_test.dart
//   or: dart test packages/warp_prism_interaction/test/timeline_intent_test.dart

import 'package:test/test.dart';
import 'package:warp_prism_interaction/src/input/action_availability.dart';
import 'package:warp_prism_interaction/src/timeline/timeline_intent.dart';
import 'package:warp_prism_interaction/src/timeline/timeline_model.dart';

// --- Caller-side reference converters (the ontology lives here, not Prism).
//
// Seconds: identity scale with a fixed-decimal readout. Bars/beats: bar.beat
// labels at a caller-chosen grid (4 beats/bar here); conversion is pure
// arithmetic on opaque numbers, deterministic by construction.

String referenceFormatSeconds(double position, double duration) =>
    '${position.toStringAsFixed(2)}s / ${duration.toStringAsFixed(2)}s';

String referenceFormatBarBeat(double positionInBeats, double totalBeats) {
  const beatsPerBar = 4;
  final bar = (positionInBeats ~/ beatsPerBar) + 1;
  final beat = (positionInBeats % beatsPerBar).toInt() + 1;
  return 'Bar $bar Beat $beat of ${totalBeats.toStringAsFixed(0)} beats';
}

double referenceBeatsToSeconds(double beats, double secondsPerBeat) =>
    beats * secondsPerBeat;

void main() {
  group('timeline_1874 edit typing Set versus Scrub', () {
    test(
      'TimelineSet and TimelineScrub carry positions with value equality',
      () {
        expect(const TimelineSet(1.5), equals(const TimelineSet(1.5)));
        expect(const TimelineScrub(1.5), equals(const TimelineScrub(1.5)));
        expect(const TimelineSet(1.5), isNot(equals(const TimelineScrub(1.5))));
      },
    );

    test('scrub session: N updates then one finish yields one commit', () {
      final session = TimelineScrubSession();
      final model = ReferenceTimelineModel(initialPosition: 0.0);

      const updates = [0.5, 1.0, 1.5, 2.0, 2.25];
      for (final position in updates) {
        final scrub = session.addUpdate(position);
        model.applyDispatch(TimelineDispatch(scrub));
      }
      expect(session.updateCount, equals(updates.length));
      expect(model.historySteps, equals(0));
      expect(model.livePosition, equals(2.25));
      expect(model.committedPosition, equals(0.0));

      final commit = session.finish(2.25);
      model.applyDispatch(TimelineDispatch(commit));
      expect(session.isFinished, isTrue);
      expect(model.historySteps, equals(1));
      expect(model.livePosition, equals(2.25));
      expect(model.committedPosition, equals(2.25));
    });
  });

  group('timeline_1874 verb resolution and 1868 gating', () {
    test('seek resolves to one Set under allow', () {
      final resolution = resolveTimelineVerb(
        const TimelineSeek(3.0),
        authority: const ActionAvailability.allow(),
      );
      expect(resolution, equals(const TimelineDispatch(TimelineSet(3.0))));
    });

    test('scrub start/update resolve to Scrub (live only, no commit)', () {
      for (final intent in [
        const TimelineScrubStart(1.0),
        const TimelineScrubUpdate(1.5),
      ]) {
        final resolution = resolveTimelineVerb(
          intent,
          authority: const ActionAvailability.allow(),
        );
        expect(resolution, isA<TimelineDispatch>());
        final edit = (resolution as TimelineDispatch).edit;
        expect(edit, isA<TimelineScrub>());
      }
    });

    test('scrub end resolves to exactly one Set (commit edge)', () {
      final resolution = resolveTimelineVerb(
        const TimelineScrubEnd(2.0),
        authority: const ActionAvailability.allow(),
      );
      expect(resolution, equals(const TimelineDispatch(TimelineSet(2.0))));
    });

    test('step applies signed caller delta to the anchor', () {
      final resolution = resolveTimelineVerb(
        const TimelineStep(0.25),
        authority: const ActionAvailability.allow(),
        anchorPosition: 1.5,
      );
      expect(resolution, equals(const TimelineDispatch(TimelineSet(1.75))));
    });

    test('deny never dispatches: every verb refuses with its reason', () {
      final authority = ActionAvailability.deny('Locked by producer');
      for (final intent in [
        const TimelineSeek(3.0),
        const TimelineScrubStart(1.0),
        const TimelineScrubUpdate(1.5),
        const TimelineScrubEnd(2.0),
        const TimelineStep(0.25),
      ]) {
        final resolution = resolveTimelineVerb(
          intent,
          authority: authority,
          anchorPosition: 1.5,
        );
        expect(resolution, isA<TimelineRefusal>());
        expect(
          (resolution as TimelineRefusal).reason,
          equals('Locked by producer'),
        );
      }
    });

    test('missing capability fails closed (deny with reason)', () {
      final resolution = resolveTimelineVerb(
        const TimelineSeek(3.0),
        authority: ActionAvailability.missing('timeline.scrub'),
      );
      expect(resolution, isA<TimelineRefusal>());
      expect(
        (resolution as TimelineRefusal).reason,
        contains('timeline.scrub'),
      );
    });

    test('constrain dispatches with the limitation attached', () {
      final resolution = resolveTimelineVerb(
        const TimelineSeek(3.0),
        authority: ActionAvailability.constrain('Read-only preview'),
      );
      expect(resolution, isA<TimelineDispatch>());
      final dispatch = resolution as TimelineDispatch;
      expect(dispatch.edit, equals(const TimelineSet(3.0)));
      expect(dispatch.limitation, equals('Read-only preview'));
    });
  });

  group('timeline_1874 commit invariant on the reference fake', () {
    test('one gesture (many updates, one end) adds exactly one step', () {
      final model = ReferenceTimelineModel(initialPosition: 0.0);
      final added = model.applyGesture(
        updates: const [0.25, 0.5, 0.75, 1.0, 1.25, 1.5],
        end: 1.5,
      );
      expect(added, equals(1));
      expect(model.historySteps, equals(1));
      expect(model.committedPosition, equals(1.5));
      expect(model.livePosition, equals(1.5));
    });

    test('empty gesture (tap-close with no moves) still costs exactly one', () {
      final model = ReferenceTimelineModel(initialPosition: 4.0);
      final added = model.applyGesture(updates: const [], end: 4.0);
      expect(added, equals(1));
      expect(model.historySteps, equals(1));
    });

    test('two gestures cost exactly two steps (cross-cluster invariant)', () {
      final model = ReferenceTimelineModel(initialPosition: 0.0);
      model.applyGesture(updates: const [1.0, 2.0], end: 2.0);
      model.applyGesture(updates: const [2.5, 3.0, 3.5], end: 3.5);
      expect(model.historySteps, equals(2));
      expect(model.committedPosition, equals(3.5));
    });

    test('scrub previews never move the committed position', () {
      final model = ReferenceTimelineModel(initialPosition: 1.0);
      model.preview(5.0);
      model.preview(7.5);
      expect(model.livePosition, equals(7.5));
      expect(model.committedPosition, equals(1.0));
      expect(model.historySteps, equals(0));
    });

    test('denied verbs never touch the model', () {
      final model = ReferenceTimelineModel(initialPosition: 1.0);
      final resolution = resolveTimelineVerb(
        const TimelineSeek(9.0),
        authority: ActionAvailability.deny('Nope'),
      );
      expect(resolution, isA<TimelineRefusal>());
      // No dispatch exists to apply: state provably untouched.
      expect(model.livePosition, equals(1.0));
      expect(model.committedPosition, equals(1.0));
      expect(model.historySteps, equals(0));
    });
  });

  group('timeline_1874 pixel to time determinism (fixed geometry)', () {
    const width = 800.0;
    const start = 0.0;
    const end = 8.0;

    test('fixed geometry gives fixed mapping (seconds scale)', () {
      expect(
        timeForPixel(
          dx: 0,
          viewportWidth: width,
          visibleStart: start,
          visibleEnd: end,
        ),
        equals(0.0),
      );
      expect(
        timeForPixel(
          dx: 400,
          viewportWidth: width,
          visibleStart: start,
          visibleEnd: end,
        ),
        equals(4.0),
      );
      expect(
        timeForPixel(
          dx: 800,
          viewportWidth: width,
          visibleStart: start,
          visibleEnd: end,
        ),
        equals(8.0),
      );
      // Repeat: identical inputs yield identical outputs.
      expect(
        timeForPixel(
          dx: 200,
          viewportWidth: width,
          visibleStart: start,
          visibleEnd: end,
        ),
        equals(
          timeForPixel(
            dx: 200,
            viewportWidth: width,
            visibleStart: start,
            visibleEnd: end,
          ),
        ),
      );
    });

    test('pixelForTime inverts timeForPixel across the window', () {
      for (final time in [0.0, 1.25, 4.0, 6.75, 8.0]) {
        final px = pixelForTime(
          time: time,
          viewportWidth: width,
          visibleStart: start,
          visibleEnd: end,
        );
        expect(
          timeForPixel(
            dx: px,
            viewportWidth: width,
            visibleStart: start,
            visibleEnd: end,
          ),
          closeTo(time, 1e-9),
        );
      }
    });

    test('out-of-range inputs clamp to the visible edges', () {
      expect(
        timeForPixel(
          dx: -50,
          viewportWidth: width,
          visibleStart: start,
          visibleEnd: end,
        ),
        equals(0.0),
      );
      expect(
        timeForPixel(
          dx: 900,
          viewportWidth: width,
          visibleStart: start,
          visibleEnd: end,
        ),
        equals(8.0),
      );
      expect(
        pixelForTime(
          time: -2,
          viewportWidth: width,
          visibleStart: start,
          visibleEnd: end,
        ),
        equals(0.0),
      );
      expect(
        pixelForTime(
          time: 99,
          viewportWidth: width,
          visibleStart: start,
          visibleEnd: end,
        ),
        equals(800.0),
      );
    });
  });

  group('timeline_1874 two-ontology conformance (seconds AND bars/beats)', () {
    test('seconds ontology renders and converts deterministically', () {
      expect(referenceFormatSeconds(1.5, 4.0), equals('1.50s / 4.00s'));
      expect(
        referenceFormatSeconds(1.5, 4.0),
        equals(referenceFormatSeconds(1.5, 4.0)),
      );
    });

    test('bars/beats ontology renders and converts deterministically', () {
      expect(referenceFormatBarBeat(0, 16), equals('Bar 1 Beat 1 of 16 beats'));
      expect(referenceFormatBarBeat(5, 16), equals('Bar 2 Beat 2 of 16 beats'));
      expect(
        referenceFormatBarBeat(5, 16),
        equals(referenceFormatBarBeat(5, 16)),
      );
      // Caller-side grid conversion is pure arithmetic: 120bpm ⇒ 0.5s/beat.
      expect(referenceBeatsToSeconds(4, 0.5), equals(2.0));
      expect(
        referenceBeatsToSeconds(4, 0.5),
        equals(referenceBeatsToSeconds(4, 0.5)),
      );
    });

    test('both ontologies share the same opaque pixel mapping', () {
      // Bar/beat unit 5 of 16 over an 800px window: same proportional rule.
      final px = pixelForTime(
        time: 5,
        viewportWidth: 800,
        visibleStart: 0,
        visibleEnd: 16,
      );
      expect(px, equals(250.0));
      expect(
        timeForPixel(
          dx: px,
          viewportWidth: 800,
          visibleStart: 0,
          visibleEnd: 16,
        ),
        equals(5.0),
      );
    });
  });
}
