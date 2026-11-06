// Timeline junk/adversarial sweep (Task 1867, part c).
//
// Mechanism mirror of `src/timeline/`. Stable test ids follow the canonical
// convention (`stableTestId` in the testkit): `[timeline_junk_<case>]`.
// Positions are caller-computed doubles — the resolver is a pure function of
// (intent, authority, anchor): junk positions resolve deterministically, and
// deny always refuses with the reason intact.

import 'package:test/test.dart';
import 'package:warp_prism_interaction/src/input/action_availability.dart';
import 'package:warp_prism_interaction/src/timeline/timeline_intent.dart';

List<double> _junkPositions() => <double>[
  -1.0,
  0.0,
  123.456,
  -999999.999,
  1e308,
  5e-324,
  86400.0,
];

String _id(String c) => '[timeline_junk_$c]';

void main() {
  group('timeline junk sweep', () {
    test('${_id('seek_resolves')} junk seeks dispatch deterministically', () {
      const authority = ActionAvailability.allow();
      for (final position in _junkPositions()) {
        final first = resolveTimelineVerb(
          TimelineSeek(position),
          authority: authority,
        );
        final second = resolveTimelineVerb(
          TimelineSeek(position),
          authority: authority,
        );
        expect(first, equals(second));
        expect(first, isA<TimelineDispatch>());
        final dispatch = first as TimelineDispatch;
        expect(dispatch.limitation, isNull);
        expect(dispatch.edit, isA<TimelineSet>());
        expect((dispatch.edit as TimelineSet).position, equals(position));
      }
    });

    test('${_id('deny_refuses')} deny never dispatches, reason intact', () {
      const junkReason = '🔥 Missing capability: 日本語 {{cap}}';
      final authority = ActionAvailability.deny(junkReason);
      for (final position in _junkPositions()) {
        final resolution = resolveTimelineVerb(
          TimelineSeek(position),
          authority: authority,
        );
        expect(resolution, isA<TimelineRefusal>());
        expect((resolution as TimelineRefusal).reason, equals(junkReason));
      }
    });

    test('${_id('scrub_session_counts')} junk scrub updates count exactly', () {
      final session = TimelineScrubSession();
      for (var i = 0; i < _junkPositions().length; i++) {
        session.addUpdate(_junkPositions()[i]);
        expect(session.updateCount, equals(i + 1));
        expect(session.isFinished, isFalse);
      }
      final commit = session.finish(-42.5);
      expect(commit.position, equals(-42.5));
      expect(session.isFinished, isTrue);
      expect(() => session.finish(0), throwsA(isA<AssertionError>()));
    });
  });
}
