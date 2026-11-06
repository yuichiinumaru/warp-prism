// Conformance + table suite for the numeric-field seam
// (Task 1881, F-14 — EXPERIMENTAL).
//
// Ports the donor parse table (`field_tests.rs:18-52`), the scrub-rate and
// quantum rows (`field_tests.rs:113-145`), and the commit-typing contract
// (`widgets.rs:20-133`: `Set|Scrub` in the type, quantum, modifier rates,
// release-frame no-op, Lead-as-name, keep-after-scrub, sibling-untouched).
// Junk/adversarial sweep asserts fail-closed (null / keep-old, never a
// throw), per the Task 1867 standing-net posture.
//
// Run: flutter test packages/warp_prism_ui/test/atoms/numeric_field_1881_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/src/atoms/numeric_field/ds_numeric_field.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('numeric_1881 ported parse table (donor field_tests 18-52)', () {
    // (text, percentUnit, want): NumericValue(v) / NumericAdd / Mul / Div / null.
    final rows = <(String, bool, NumericTypedEdit?)>[
      ('12', false, const NumericValue(12.0)),
      (' 12.5 ', false, const NumericValue(12.5)),
      ('12,5', false, const NumericValue(12.5)),
      ('.5', false, const NumericValue(0.5)),
      ('-3', false, const NumericValue(-3.0)),
      ('- 3', false, const NumericValue(-3.0)),
      ('10+5', false, const NumericValue(15.0)),
      ('10 - 3', false, const NumericValue(7.0)),
      ('2*3+4', false, const NumericValue(10.0)),
      ('2+3*4', false, const NumericValue(14.0)),
      ('(2+3)*4', false, const NumericValue(20.0)),
      ('100/(2+3)', false, const NumericValue(20.0)),
      ('-(4+1)', false, const NumericValue(-5.0)),
      ('((1+2)*(3+4))/7', false, const NumericValue(3.0)),
      ('2*-3', false, const NumericValue(-6.0)),
      ('10--2', false, const NumericValue(12.0)),
      ('12px', false, const NumericValue(12.0)),
      ('45°', false, const NumericValue(45.0)),
      ('2x', false, const NumericValue(2.0)),
      ('300ms', false, const NumericValue(300.0)),
      ('10px + 2px', false, const NumericValue(12.0)),
      ('+10', false, const NumericAdd(10.0)),
      ('+ 2*3', false, const NumericAdd(6.0)),
      ('*2', false, const NumericMul(2.0)),
      ('/4', false, const NumericDiv(4.0)),
      ('*(1+1)', false, const NumericMul(2.0)),
      ('50%', false, const NumericMul(0.5)),
      ('+10%', false, const NumericMul(1.1)),
      ('-10%', false, const NumericMul(0.9)),
      ('50%', true, const NumericValue(50.0)),
      ('+10%', true, const NumericAdd(10.0)),
      ('50% + 10%', true, const NumericValue(60.0)),
      ('', false, null),
      ('   ', false, null),
      ('abc', false, null),
      ('1/0', false, null),
      ('/0', false, const NumericDiv(0.0)),
      ('(1+2', false, null),
      ('1+2)', false, null),
      ('1+', false, null),
      ('*', false, null),
      ('1 2', false, null),
      ('1..2', false, null),
      ('50%%', false, null),
      ('5%+1', false, null),
      ('1e999', false, null),
      ('٣', false, null),
    ];
    for (final (text, percent, want) in rows) {
      test('parse("$text", percentUnit: $percent) → $want', () {
        expect(
          dsNumericReferenceParse(text, percent),
          equals(want),
          reason: 'parse("$text", $percent)',
        );
      });
    }

    test('relative edits apply, div-by-zero and overflow are null', () {
      expect(const NumericAdd(10.0).applyTo(5.0), equals(15.0));
      expect(const NumericMul(2.0).applyTo(5.0), equals(10.0));
      expect(const NumericDiv(4.0).applyTo(10.0), equals(2.5));
      expect(const NumericDiv(0.0).applyTo(10.0), isNull);
      expect(
        const NumericMul(double.maxFinite).applyTo(double.maxFinite),
        isNull,
      );
    });

    test('eval: every unit is a unit; without a value +4 is 4', () {
      final rows = <(String, double?, double?)>[
        ('12', null, 12.0),
        ('10+5', null, 15.0),
        ('*2', 8.0, 16.0),
        ('+4', 8.0, 12.0),
        ('+4', null, 4.0),
        ('*2', null, null),
        ('-3', null, -3.0),
        ('50%', null, 50.0),
        ('1/0', null, null),
        ('abc', null, null),
      ];
      for (final (text, current, want) in rows) {
        expect(
          dsNumericEval(text, current),
          equals(want),
          reason: 'eval("$text", $current)',
        );
      }
    });
  });

  group('numeric_1881 scrub rates and quantum (donor field_tests 113-145)', () {
    test('scrub_amount: step a point, 10x Shift, 0.1x Alt, 1x both', () {
      final rows = <(double, double, bool, bool, double)>[
        (25.0, 1.0, false, false, 25.0),
        (-25.0, 1.0, false, false, -25.0),
        (10.0, 1.0, true, false, 100.0),
        (20.0, 1.0, false, true, 2.0),
        (20.0, 1.0, true, true, 20.0),
        (10.0, 0.1, false, false, 1.0),
        (10.0, 0.1, true, false, 10.0),
        (10.0, 10.0, false, false, 100.0),
        (0.0, 1.0, true, false, 0.0),
      ];
      for (final (dx, step, shift, alt, want) in rows) {
        expect(
          numericScrubAmount(dx, step, shift, alt),
          moreOrLessEquals(want),
          reason: '$dx points, step $step, shift $shift, alt $alt',
        );
      }
    });

    test('scrubbed: whole steps from origin, tenths under Alt, no dust', () {
      final rows = <(double, double, double, double)>[
        (12.5, 3.4, 1.0, 15.5),
        (12.5, -3.6, 1.0, 8.5),
        (10.0, 0.34, 0.1, 10.3),
        (0.1, 0.2, 0.1, 0.3),
      ];
      for (final (from, amount, quantum, want) in rows) {
        expect(
          numericScrubbed(from, amount, quantum),
          equals(want),
          reason: 'from $from, moved $amount, quantum $quantum',
        );
      }
      // Fail-closed: zero quantum and NaN travel keep the origin.
      expect(numericScrubbed(5.0, 7.0, 0.0), equals(5.0));
      expect(numericScrubbed(5.0, double.nan, 1.0), equals(5.0));
      expect(numericStepped(0.1, 1.0, 0.2), equals(0.3));
      expect(numericStepped(1.0, 1.0, double.infinity), equals(1.0));
    });

    test('session accumulates stretches at their own modifier rates', () {
      final session = NumericScrubSession();
      session.addStretch(10.0, 1.0, false, false);
      session.addStretch(10.0, 1.0, true, false);
      expect(session.amount, moreOrLessEquals(110.0));
      expect(session.resolve(0.0, 1.0), equals(110.0));
      session.reset();
      expect(session.isUnmoved, isTrue);
    });

    test('quantum resolves tenths under Alt, steps otherwise', () {
      expect(numericQuantumFor(1.0, false), equals(1.0));
      expect(numericQuantumFor(1.0, true), moreOrLessEquals(0.1));
    });
  });

  group('numeric_1881 junk/adversarial sweep (fail-closed, never throws)', () {
    test('long, deep, and odd text never throws and never settles', () {
      final junk = <String>[
        '((((((((((((((' * 385,
        '1+1+1+1+1+1+1+' * 385,
        '${'(' * 40}1${')' * 40}',
        '−1',
        '1\x002',
        'é%',
        'NaN',
        'Infinity',
        '+',
        '/',
        '%',
        '()',
        '--',
        '.,',
        List.filled(400, '9').join(),
      ];
      for (final text in junk) {
        NumericTypedEdit? parsed;
        double? settled;
        expect(
          () {
            parsed = dsNumericReferenceParse(text, false);
            final alt = dsNumericReferenceParse(text, true);
            settled = numericSettled(parsed, 5.0);
            numericSettled(alt, null);
            dsNumericEval(text, null);
          },
          returnsNormally,
          reason: 'junk must never throw: ${text.length} chars',
        );
        expect(
          settled,
          anyOf(isNull, isA<double>()),
          reason: 'junk settles fail-closed or to a finite double',
        );
        if (settled != null) {
          expect(settled!.isFinite, isTrue);
        }
      }
    });

    test('reference formatter never emits non-finite text', () {
      expect(dsNumericReferenceFormat(double.nan), equals(''));
      expect(dsNumericReferenceFormat(double.infinity), equals(''));
      expect(dsNumericReferenceFormat(double.negativeInfinity), equals(''));
      expect(dsNumericReferenceFormat(12.0), equals('12'));
      expect(dsNumericReferenceFormat(12.5), equals('12.5'));
      // Same input yields same output (fake determinism).
      expect(
        dsNumericReferenceFormat(-3.25),
        equals(dsNumericReferenceFormat(-3.25)),
      );
    });
  });

  group('numeric_1881 Lead-as-name convention', () {
    test('W and H resolve to Width and Height, others verbatim', () {
      expect(const DSNumericLeadText('W').resolvedName, equals('Width'));
      expect(const DSNumericLeadText('H').resolvedName, equals('Height'));
      expect(
        const DSNumericLeadText('Opacity').resolvedName,
        equals('Opacity'),
      );
      expect(
        const DSNumericLeadIcon(Icons.straighten, 'Width').resolvedName,
        equals('Width'),
      );
      expect(
        const DSNumericLeadNamed('Rotation').resolvedName,
        equals('Rotation'),
      );
      expect(const DSNumericLeadNone().resolvedName, equals(''));
    });

    testWidgets('lead text shows short label, semantics carry the name', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const DSNumericField(lead: DSNumericLeadText('W'), value: 40.0)),
      );
      expect(find.text('W'), findsOneWidget);
      expect(find.bySemanticsLabel('Width'), findsOneWidget);
    });
  });

  group('numeric_1881 widget commit typing (Set vs Scrub)', () {
    testWidgets('submit commits Set; invalid text keeps old value silently', (
      tester,
    ) async {
      final commits = <NumericCommit>[];
      await tester.pumpWidget(
        _wrap(
          DSNumericField(
            lead: const DSNumericLeadText('X'),
            value: 5.0,
            onCommit: commits.add,
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), '+10');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(commits, equals(const [NumericSet(15.0)]));

      await tester.enterText(find.byType(TextField), 'nonsense');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(
        commits,
        equals(const [NumericSet(15.0)]),
        reason: 'invalid text emits nothing (fail-closed)',
      );
    });

    testWidgets('Mixed field settles +4 to 4, rejects *2', (tester) async {
      final commits = <NumericCommit>[];
      await tester.pumpWidget(
        _wrap(DSNumericField(value: null, onCommit: commits.add)),
      );
      expect(find.text('Mixed'), findsWidgets);

      await tester.enterText(find.byType(TextField), '+4');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(commits, equals(const [NumericSet(4.0)]));

      await tester.enterText(find.byType(TextField), '*2');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(
        commits,
        equals(const [NumericSet(4.0)]),
        reason: 'relative edit with no value commits nothing',
      );
    });

    testWidgets(
      'scrub emits live previews plus one terminal; release moves nothing',
      (tester) async {
        final commits = <NumericCommit>[];
        await tester.pumpWidget(
          _wrap(
            DSNumericField(
              lead: const DSNumericLeadText('X'),
              value: 10.0,
              onCommit: commits.add,
            ),
          ),
        );
        final lead = find.text('X');
        expect(lead, findsOneWidget);

        final gesture = await tester.startGesture(tester.getCenter(lead));
        await gesture.moveBy(const Offset(25.0, 0.0));
        await tester.pump();
        await gesture.moveBy(const Offset(10.0, 0.0));
        await tester.pump();
        await gesture.up();
        await tester.pump();

        expect(commits.length, greaterThanOrEqualTo(2));
        final terminal = commits.last;
        expect(terminal, isA<NumericScrub>());
        final ended = terminal as NumericScrub;
        expect(ended.ended, isTrue);
        final lives = commits.whereType<NumericScrub>().toList();
        expect(lives.length, greaterThanOrEqualTo(2));
        for (final live in lives.take(lives.length - 1)) {
          expect(live.ended, isFalse);
        }
        // Release-frame no-op: terminal equals the last live value.
        expect(ended.value, equals(lives[lives.length - 2].value));
        // Keep-after-scrub: the field shows the terminal value.
        expect(
          find.text(dsNumericReferenceFormat(ended.value)),
          findsOneWidget,
        );
        // One gesture ⇒ live previews plus exactly one terminal.
        expect(lives.where((e) => e.ended).length, equals(1));
      },
    );

    testWidgets('a press on the lead that does not move commits nothing', (
      tester,
    ) async {
      final commits = <NumericCommit>[];
      await tester.pumpWidget(
        _wrap(
          DSNumericField(
            lead: const DSNumericLeadText('Y'),
            value: 20.0,
            onCommit: commits.add,
          ),
        ),
      );
      await tester.tap(find.text('Y'));
      await tester.pump();
      expect(commits, isEmpty);
    });

    testWidgets(
      'sibling untouched: scrubbing one field never mutates another',
      (tester) async {
        final first = <NumericCommit>[];
        final second = <NumericCommit>[];
        await tester.pumpWidget(
          _wrap(
            Row(
              children: [
                SizedBox(
                  width: 300,
                  child: DSNumericField(
                    lead: const DSNumericLeadText('X'),
                    value: 10.0,
                    onCommit: first.add,
                  ),
                ),
                SizedBox(
                  width: 300,
                  child: DSNumericField(
                    lead: const DSNumericLeadText('Y'),
                    value: 20.0,
                    onCommit: second.add,
                  ),
                ),
              ],
            ),
          ),
        );
        final gesture = await tester.startGesture(
          tester.getCenter(find.text('X')),
        );
        await gesture.moveBy(const Offset(15.0, 0.0));
        await tester.pump();
        await gesture.up();
        await tester.pump();

        expect(first, isNotEmpty);
        expect(second, isEmpty, reason: 'sibling emits nothing');
        expect(
          find.text('20'),
          findsOneWidget,
          reason: 'sibling text unchanged',
        );
      },
    );
  });
}
