// Conformance + widget suite for the filter-builder seam (Task 1860, F-12).
//
// Proves: fake model shape + stable enumeration; group-tree ops (add/remove/
// operator/nested); per-type editors emit normalized values; debounce-commit
// + flush deterministic under an injected clock (unit) and via explicit flush
// / Apply / zero-delay auto-commit (widget); fieldsFromSections anchor mapping;
// a11y labels + 48dp targets + keyboard activation.
//
// EXPERIMENTAL: imports via src paths; no barrel export yet.
// Run: flutter test packages/warp_prism_ui/test/organisms/filter_workbench/filter_builder_1860_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/src/molecules/ds_filter_chip_group.dart';
import 'package:warp_prism_ui/src/organisms/filter_workbench/ds_filter_builder.dart';
import 'package:warp_prism_ui/src/organisms/filter_workbench/ds_filter_builder_editors.dart';
import 'package:warp_prism_ui/src/organisms/filter_workbench/ds_filter_builder_model.dart';
import 'package:warp_prism_ui/src/organisms/filter_workbench/ds_filter_workbench.dart';

// --- Deterministic clock (injected; no wall-clock in tests). ---------------

class FakeFilterClock {
  DateTime now = DateTime(2026, 1, 1, 12);

  DateTime call() => now;

  void advance(Duration delta) {
    now = now.add(delta);
  }
}

Widget wrapTest(Widget child) => MaterialApp(home: Scaffold(body: child));

DSFilterGroup seedTree() => const DSFilterGroup(
  id: 'root',
  predicates: [
    DSFilterPredicate(id: 'p-severity', fieldId: 'severity', values: ['error']),
  ],
);

void main() {
  group('filter_1860 fake model', () {
    test('fixture tree has root AND, two predicates, one nested OR group', () {
      final tree = DSFilterBuilderFake.fixtureTree();
      expect(tree.operator, DSFilterGroupOperator.and);
      expect(tree.predicates.map((p) => p.id), ['p-severity', 'p-service']);
      expect(tree.subgroups, hasLength(1));
      expect(tree.subgroups.single.operator, DSFilterGroupOperator.or);
    });

    test('fixture fields cover all five per-type editor kinds', () {
      final kinds = {
        for (final f in DSFilterBuilderFake.fixtureFields()) f.editorKind,
      };
      expect(kinds, {
        DSFilterEditorKind.text,
        DSFilterEditorKind.number,
        DSFilterEditorKind.enumSingle,
        DSFilterEditorKind.enumMulti,
        DSFilterEditorKind.boolean,
      });
    });

    test('enumeration order is stable across repeated builds', () {
      final first = DSFilterBuilderFake.fixtureTree().predicateIds;
      final second = DSFilterBuilderFake.fixtureTree().predicateIds;
      expect(first, ['p-severity', 'p-service', 'p-env', 'p-pinned']);
      expect(second, first);
    });

    test('fixture snapshot carries revision 1 over the fixture tree', () {
      final snapshot = DSFilterBuilderFake.fixtureSnapshot();
      expect(snapshot.revision, 1);
      expect(snapshot.root, DSFilterBuilderFake.fixtureTree());
      expect(snapshot.predicateIds, [
        'p-severity',
        'p-service',
        'p-env',
        'p-pinned',
      ]);
    });

    test('group equality is structural, not identical', () {
      expect(
        DSFilterBuilderFake.fixtureTree(),
        DSFilterBuilderFake.fixtureTree(),
      );
      expect(
        DSFilterBuilderFake.fixtureTree().hashCode,
        DSFilterBuilderFake.fixtureTree().hashCode,
      );
    });
  });

  group('filter_1860 debounce controller (injected clock)', () {
    test('edit is not due before the delay, due at the delay', () {
      final clock = FakeFilterClock();
      final controller = DSFilterDebounceController(
        commitDelay: const Duration(milliseconds: 350),
        clock: clock.call,
      );
      addTearDown(controller.dispose);

      controller.markEdited(clock());
      expect(controller.hasPending, isTrue);
      expect(controller.isDue(clock()), isFalse);
      expect(controller.dueIn(clock()), const Duration(milliseconds: 350));

      clock.advance(const Duration(milliseconds: 349));
      expect(controller.isDue(clock()), isFalse);
      expect(controller.commitIfDue(clock()), isFalse);
      expect(controller.hasPending, isTrue);

      clock.advance(const Duration(milliseconds: 1));
      expect(controller.isDue(clock()), isTrue);
      expect(controller.dueIn(clock()), Duration.zero);
      expect(controller.commitIfDue(clock()), isTrue);
      expect(controller.hasPending, isFalse);
      expect(controller.revision, 1);
      // Second commit without a new edit is a no-op.
      expect(controller.commitIfDue(clock()), isFalse);
      expect(controller.revision, 1);
    });

    test('flush commits pending edits immediately and never waits', () {
      final clock = FakeFilterClock();
      final controller = DSFilterDebounceController(
        commitDelay: const Duration(seconds: 30),
        clock: clock.call,
      );
      addTearDown(controller.dispose);

      expect(controller.flush(), isFalse);
      controller.markEdited(clock());
      expect(controller.flush(), isTrue);
      expect(controller.revision, 1);
      expect(controller.hasPending, isFalse);
      expect(controller.flush(), isFalse);
    });

    test('a newer edit restarts the debounce window', () {
      final clock = FakeFilterClock();
      final controller = DSFilterDebounceController(
        commitDelay: const Duration(milliseconds: 100),
        clock: clock.call,
      );
      addTearDown(controller.dispose);

      controller.markEdited(clock());
      clock.advance(const Duration(milliseconds: 90));
      controller.markEdited(clock());
      clock.advance(const Duration(milliseconds: 90));
      expect(controller.isDue(clock()), isFalse);
      clock.advance(const Duration(milliseconds: 10));
      expect(controller.commitIfDue(clock()), isTrue);
    });

    test('cancel drops the pending edit without committing', () {
      final clock = FakeFilterClock();
      final controller = DSFilterDebounceController(
        commitDelay: const Duration(milliseconds: 100),
        clock: clock.call,
      );
      addTearDown(controller.dispose);

      controller.markEdited(clock());
      controller.cancel();
      expect(controller.hasPending, isFalse);
      clock.advance(const Duration(seconds: 1));
      expect(controller.commitIfDue(clock()), isFalse);
      expect(controller.revision, 0);
    });

    test('markEditedNow and commitIfDueNow use the injected clock', () {
      var now = DateTime(2026, 2, 2, 8);
      final controller = DSFilterDebounceController(
        commitDelay: const Duration(milliseconds: 50),
        clock: () => now,
      );
      addTearDown(controller.dispose);

      controller.markEditedNow();
      now = now.add(const Duration(milliseconds: 50));
      expect(controller.commitIfDueNow(), isTrue);
    });
  });

  group('filter_1860 fieldsFromSections anchor mapping', () {
    test('maps all four workbench criterion kinds to editors', () {
      final sections = [
        const DSFilterSection(
          id: 's',
          title: 'S',
          criteria: [
            DSFilterCriterion(
              id: 'm',
              label: 'M',
              kind: DSFilterCriterionKind.multiSelect,
              options: [DSFilterOption(value: 'a', label: 'A')],
            ),
            DSFilterCriterion(
              id: 'g',
              label: 'G',
              kind: DSFilterCriterionKind.singleSelect,
              options: [DSFilterOption(value: 'b', label: 'B')],
            ),
            DSFilterCriterion(
              id: 't',
              label: 'T',
              kind: DSFilterCriterionKind.text,
            ),
            DSFilterCriterion(
              id: 'o',
              label: 'O',
              kind: DSFilterCriterionKind.boolean,
            ),
          ],
        ),
      ];
      final fields = fieldsFromSections(sections);
      expect(fields.map((f) => f.editorKind), [
        DSFilterEditorKind.enumMulti,
        DSFilterEditorKind.enumSingle,
        DSFilterEditorKind.text,
        DSFilterEditorKind.boolean,
      ]);
      expect(fields.first.options.single.value, 'a');
    });
  });

  group('filter_1860 DSFilterBuilder widget', () {
    testWidgets('renders seeded tree with summary, group, and footer', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapTest(
          SizedBox(
            width: 480,
            height: 640,
            child: DSFilterBuilder(
              fields: DSFilterBuilderFake.fixtureFields(),
              initialTree: seedTree(),
            ),
          ),
        ),
      );

      expect(find.byKey(DSFilterBuilder.panelKey), findsOneWidget);
      expect(find.byKey(DSFilterBuilder.groupKey('root')), findsOneWidget);
      expect(
        find.byKey(DSFilterBuilder.predicateKey('p-severity')),
        findsOneWidget,
      );
      expect(find.byKey(DSFilterBuilder.summaryKey), findsOneWidget);
      expect(find.byKey(DSFilterBuilder.applyButtonKey), findsOneWidget);
      expect(find.byKey(DSFilterBuilder.clearButtonKey), findsOneWidget);
      expect(find.text('1 active'), findsOneWidget);
    });

    testWidgets('edits update draft without committing until flush', (
      tester,
    ) async {
      final drafts = <DSFilterGroup>[];
      final commits = <DSFilterBuilderSnapshot>[];
      final handle = DSFilterBuilderController();

      await tester.pumpWidget(
        wrapTest(
          SizedBox(
            width: 480,
            height: 640,
            child: DSFilterBuilder(
              fields: DSFilterBuilderFake.fixtureFields(),
              initialTree: seedTree(),
              controller: handle,
              commitDelay: const Duration(minutes: 5),
              onChanged: drafts.add,
              onCommit: commits.add,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Warning'));
      await tester.pump();

      expect(drafts, hasLength(1));
      expect(commits, isEmpty);
      expect(handle.hasPending, isTrue);

      // Explicit flush through the external handle commits synchronously.
      expect(handle.flush(), isTrue);
      await tester.pump();
      expect(commits, hasLength(1));
      expect(commits.single.revision, 1);
      expect(handle.hasPending, isFalse);
    });

    testWidgets('Apply commits the current draft', (tester) async {
      final commits = <DSFilterBuilderSnapshot>[];

      await tester.pumpWidget(
        wrapTest(
          SizedBox(
            width: 480,
            height: 640,
            child: DSFilterBuilder(
              fields: DSFilterBuilderFake.fixtureFields(),
              initialTree: seedTree(),
              commitDelay: const Duration(minutes: 5),
              onCommit: commits.add,
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(DSFilterBuilder.applyButtonKey));
      await tester.pump();

      expect(commits, hasLength(1));
      expect(commits.single.predicateIds, ['p-severity']);
      expect(commits.single.revision, 0);
    });

    testWidgets('edit then Apply commits revision 1 with edited values', (
      tester,
    ) async {
      final commits = <DSFilterBuilderSnapshot>[];

      await tester.pumpWidget(
        wrapTest(
          SizedBox(
            width: 480,
            height: 640,
            child: DSFilterBuilder(
              fields: DSFilterBuilderFake.fixtureFields(),
              initialTree: seedTree(),
              commitDelay: const Duration(minutes: 5),
              onCommit: commits.add,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Warning'));
      await tester.pump();
      await tester.tap(find.byKey(DSFilterBuilder.applyButtonKey));
      await tester.pump();

      expect(commits, hasLength(1));
      expect(commits.single.revision, 1);
      final edited = commits.single.root.predicates.single;
      expect(edited.values.toSet(), containsAll({'error', 'warning'}));
    });

    testWidgets('zero commit delay auto-commits on elapsed pump', (
      tester,
    ) async {
      final commits = <DSFilterBuilderSnapshot>[];
      final drafts = <DSFilterGroup>[];

      await tester.pumpWidget(
        wrapTest(
          SizedBox(
            width: 480,
            height: 640,
            child: DSFilterBuilder(
              fields: DSFilterBuilderFake.fixtureFields(),
              initialTree: seedTree(),
              commitDelay: Duration.zero,
              onChanged: drafts.add,
              onCommit: commits.add,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Warning'));
      await tester.pump();
      // Zero-delay timers fire on fakeAsync elapse, not on a bare pump.
      await tester.pump(const Duration(milliseconds: 1));

      expect(drafts, hasLength(1));
      expect(commits, hasLength(1));
      expect(commits.single.revision, 1);
    });

    testWidgets('bounded delay auto-commits after elapse, not before', (
      tester,
    ) async {
      final commits = <DSFilterBuilderSnapshot>[];

      await tester.pumpWidget(
        wrapTest(
          SizedBox(
            width: 480,
            height: 640,
            child: DSFilterBuilder(
              fields: DSFilterBuilderFake.fixtureFields(),
              initialTree: seedTree(),
              commitDelay: const Duration(milliseconds: 350),
              onCommit: commits.add,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Warning'));
      await tester.pump();
      expect(commits, isEmpty);

      // Partial elapse: still pending.
      await tester.pump(const Duration(milliseconds: 100));
      expect(commits, isEmpty);

      // Full elapse past the bounded delay: exactly one commit.
      await tester.pump(const Duration(milliseconds: 300));
      expect(commits, hasLength(1));
      expect(commits.single.revision, 1);
    });

    testWidgets('Clear empties the tree and fires onClear', (tester) async {
      var cleared = 0;
      final drafts = <DSFilterGroup>[];

      await tester.pumpWidget(
        wrapTest(
          SizedBox(
            width: 480,
            height: 640,
            child: DSFilterBuilder(
              fields: DSFilterBuilderFake.fixtureFields(),
              initialTree: DSFilterBuilderFake.fixtureTree(),
              onChanged: drafts.add,
              onClear: () => cleared++,
            ),
          ),
        ),
      );

      expect(find.text('4 active'), findsOneWidget);
      await tester.tap(find.byKey(DSFilterBuilder.clearButtonKey));
      await tester.pump();

      expect(cleared, 1);
      expect(drafts.last.predicateCount, 0);
      expect(find.byKey(DSFilterBuilder.emptyStateKey), findsOneWidget);
    });

    testWidgets('operator toggle flips AND to OR', (tester) async {
      final drafts = <DSFilterGroup>[];

      await tester.pumpWidget(
        wrapTest(
          SizedBox(
            width: 480,
            height: 640,
            child: DSFilterBuilder(
              fields: DSFilterBuilderFake.fixtureFields(),
              initialTree: seedTree(),
              onChanged: drafts.add,
            ),
          ),
        ),
      );

      await tester.tap(find.text('OR'));
      await tester.pump();

      expect(drafts, hasLength(1));
      expect(drafts.single.operator, DSFilterGroupOperator.or);
    });

    testWidgets('add predicate, nested group, and summary remove', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapTest(
          SizedBox(
            width: 480,
            height: 720,
            child: DSFilterBuilder(
              fields: DSFilterBuilderFake.fixtureFields(),
              initialTree: DSFilterBuilderFake.emptyTree(),
            ),
          ),
        ),
      );

      expect(find.byKey(DSFilterBuilder.emptyStateKey), findsOneWidget);

      // Add a text predicate to the root group.
      await tester.tap(
        find.byKey(DSFilterBuilder.fieldPickKey('root', 'service')),
      );
      await tester.pump();

      expect(find.byKey(DSFilterBuilder.emptyStateKey), findsNothing);
      expect(find.text('1 active'), findsOneWidget);

      // Add a nested subgroup, then a boolean predicate inside it.
      await tester.tap(find.byKey(DSFilterBuilder.addGroupKeyFor('root')));
      await tester.pumpAndSettle();

      final nestedGroup = find.byWidgetPredicate(
        (w) =>
            w is KeyedSubtree &&
            w.key.toString().contains('ds-filter-1860-group-g-'),
      );
      expect(nestedGroup, findsOneWidget);

      // Add a boolean predicate inside the nested subgroup.
      final nestedGroupId =
          (tester.widget<KeyedSubtree>(nestedGroup).key as ValueKey<String>)
              .value
              .replaceFirst('ds-filter-1860-group-', '');
      final nestedPick = find.byKey(
        DSFilterBuilder.fieldPickKey(nestedGroupId, 'pinned'),
      );
      await tester.scrollUntilVisible(
        nestedPick,
        200,
        scrollable: find.byWidgetPredicate(
          (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
        ),
      );
      await tester.pump();
      await tester.tap(nestedPick);
      await tester.pump();

      expect(find.text('2 active'), findsOneWidget);
    });

    testWidgets('summary chip tap removes that predicate', (tester) async {
      await tester.pumpWidget(
        wrapTest(
          SizedBox(
            width: 480,
            height: 640,
            child: DSFilterBuilder(
              fields: DSFilterBuilderFake.fixtureFields(),
              initialTree: seedTree(),
            ),
          ),
        ),
      );

      // Summary shows one chip labelled "Severity: error".
      await tester.tap(find.text('Severity: error'));
      await tester.pump();

      expect(find.text('0 active'), findsOneWidget);
      expect(find.byKey(DSFilterBuilder.emptyStateKey), findsOneWidget);
    });

    testWidgets('panel, apply, and clear expose semantics labels', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapTest(
          SizedBox(
            width: 480,
            height: 640,
            child: DSFilterBuilder(
              fields: DSFilterBuilderFake.fixtureFields(),
              initialTree: seedTree(),
            ),
          ),
        ),
      );

      expect(
        tester.getSemantics(find.byKey(DSFilterBuilder.panelKey)).label,
        DSFilterBuilder.panelSemanticLabel,
      );
      expect(
        tester.getSemantics(find.byKey(DSFilterBuilder.applyButtonKey)).label,
        'Apply filters',
      );
      expect(
        tester.getSemantics(find.byKey(DSFilterBuilder.clearButtonKey)).label,
        'Clear filters',
      );
    });

    testWidgets('interactive controls meet 48dp minimum touch target', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapTest(
          SizedBox(
            width: 480,
            height: 640,
            child: DSFilterBuilder(
              fields: DSFilterBuilderFake.fixtureFields(),
              initialTree: seedTree(),
            ),
          ),
        ),
      );

      void expectMinTouchTarget(Finder finder) {
        final size = tester.getSize(finder);
        expect(size.height, greaterThanOrEqualTo(kMinInteractiveDimension));
        expect(size.width, greaterThanOrEqualTo(kMinInteractiveDimension));
      }

      expectMinTouchTarget(find.byKey(DSFilterBuilder.applyButtonKey));
      expectMinTouchTarget(find.byKey(DSFilterBuilder.clearButtonKey));
      expectMinTouchTarget(
        find.byKey(DSFilterBuilder.removeKeyFor('p-severity')),
      );
    });

    testWidgets('boolean editor toggles via keyboard activate intent', (
      tester,
    ) async {
      const tree = DSFilterGroup(
        id: 'root',
        predicates: [DSFilterPredicate(id: 'p-pinned', fieldId: 'pinned')],
      );
      final drafts = <DSFilterGroup>[];

      await tester.pumpWidget(
        wrapTest(
          SizedBox(
            width: 480,
            height: 640,
            child: DSFilterBuilder(
              fields: DSFilterBuilderFake.fixtureFields(),
              initialTree: tree,
              onChanged: drafts.add,
            ),
          ),
        ),
      );

      final descFinder = find.descendant(
        of: find.byKey(DSFilterBooleanEditor.keyFor('p-pinned')),
        matching: find.text('Disabled'),
      );
      expect(descFinder, findsOneWidget);

      final element = tester.element(descFinder);
      Actions.maybeInvoke(element, const ActivateIntent());
      await tester.pump();

      expect(drafts, hasLength(1));
      expect(drafts.single.predicates.single.values, ['true']);
    });
  });

  group('filter_1860 per-type editors', () {
    testWidgets('text editor emits normalized values', (tester) async {
      var current = <String>['obs'];
      await tester.pumpWidget(
        wrapTest(
          StatefulBuilder(
            builder: (context, setState) => DSFilterTextEditor(
              key: DSFilterTextEditor.keyFor('p'),
              values: current,
              fieldLabel: 'Service',
              onChanged: (v) => setState(() => current = v),
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'tempo');
      await tester.pump();
      expect(current, ['tempo']);

      await tester.enterText(find.byType(TextField), '');
      await tester.pump();
      expect(current, isEmpty);
    });

    testWidgets('number editor flags non-numeric input but still emits', (
      tester,
    ) async {
      var current = <String>[];
      await tester.pumpWidget(
        wrapTest(
          StatefulBuilder(
            builder: (context, setState) => DSFilterNumberEditor(
              key: DSFilterNumberEditor.keyFor('p'),
              values: current,
              fieldLabel: 'Latency',
              onChanged: (v) => setState(() => current = v),
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'abc');
      await tester.pump();
      expect(current, ['abc']);
      expect(find.text('Enter a number'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '250');
      await tester.pump();
      expect(current, ['250']);
      expect(find.text('Enter a number'), findsNothing);
    });

    testWidgets('enum multi editor emits catalog-ordered values', (
      tester,
    ) async {
      var current = <String>[];
      await tester.pumpWidget(
        wrapTest(
          StatefulBuilder(
            builder: (context, setState) => DSFilterEnumEditor(
              key: DSFilterEnumEditor.keyFor('p'),
              values: current,
              fieldLabel: 'Severity',
              options: const [
                DSFilterBuilderOption(value: 'error', label: 'Error'),
                DSFilterBuilderOption(value: 'warning', label: 'Warning'),
                DSFilterBuilderOption(value: 'info', label: 'Info'),
              ],
              allowMultiple: true,
              onChanged: (v) => setState(() => current = v),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Info'));
      await tester.pump();
      await tester.tap(find.text('Error'));
      await tester.pump();
      // Catalog order, not tap order.
      expect(current, ['error', 'info']);
    });

    testWidgets('enum single editor replaces the value', (tester) async {
      var current = <String>[];
      await tester.pumpWidget(
        wrapTest(
          StatefulBuilder(
            builder: (context, setState) => DSFilterEnumEditor(
              key: DSFilterEnumEditor.keyFor('p'),
              values: current,
              fieldLabel: 'Environment',
              options: const [
                DSFilterBuilderOption(value: 'prod', label: 'Prod'),
                DSFilterBuilderOption(value: 'staging', label: 'Staging'),
              ],
              allowMultiple: false,
              onChanged: (v) => setState(() => current = v),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Prod'));
      await tester.pump();
      expect(current, ['prod']);

      await tester.tap(find.text('Staging'));
      await tester.pump();
      expect(current, ['staging']);
    });

    testWidgets('boolean editor toggles normalized true', (tester) async {
      var current = <String>[];
      await tester.pumpWidget(
        wrapTest(
          StatefulBuilder(
            builder: (context, setState) => DSFilterBooleanEditor(
              key: DSFilterBooleanEditor.keyFor('p'),
              values: current,
              fieldLabel: 'Pinned',
              onChanged: (v) => setState(() => current = v),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Disabled'));
      await tester.pump();
      expect(current, ['true']);

      await tester.tap(find.text('Enabled'));
      await tester.pump();
      expect(current, isEmpty);
    });
  });
}
