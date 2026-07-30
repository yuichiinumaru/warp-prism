import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// Task 1504: PrismFilterWorkbench widget tests
///
/// Covers: sectioned criteria, apply, reset, advanced modal, empty schema,
/// a11y labels on apply/reset.
void main() {
  List<PrismFilterSection> fixtureSections({bool withAdvanced = true}) => [
    PrismFilterSection(
      id: 'assets',
      title: 'Asset type',
      criteria: [
        const PrismFilterCriterion(
          id: 'asset_type',
          label: 'Types',
          kind: PrismFilterCriterionKind.multiSelect,
          options: [
            PrismFilterOption(value: 'agent', label: 'Agent', count: 5),
            PrismFilterOption(value: 'skill', label: 'Skill', count: 12),
          ],
        ),
        const PrismFilterCriterion(
          id: 'lifecycle',
          label: 'Lifecycle',
          kind: PrismFilterCriterionKind.singleSelect,
          options: [
            PrismFilterOption(value: 'active', label: 'Active'),
            PrismFilterOption(value: 'stale', label: 'Stale'),
          ],
        ),
        const PrismFilterCriterion(
          id: 'query',
          label: 'Name contains',
          kind: PrismFilterCriterionKind.text,
          placeholder: 'search…',
        ),
        const PrismFilterCriterion(
          id: 'pinned',
          label: 'Pinned only',
          kind: PrismFilterCriterionKind.boolean,
        ),
        if (withAdvanced)
          const PrismFilterCriterion(
            id: 'freshness',
            label: 'Freshness',
            kind: PrismFilterCriterionKind.singleSelect,
            advanced: true,
            options: [
              PrismFilterOption(value: '1h', label: '1 hour'),
              PrismFilterOption(value: '24h', label: '24 hours'),
            ],
          ),
      ],
    ),
  ];

  Widget harness({
    List<PrismFilterSection>? sections,
    Map<String, Object?>? values,
    Map<String, Object?> initialValues = const {},
    ValueChanged<Map<String, Object?>>? onChanged,
    ValueChanged<Map<String, Object?>>? onApply,
    VoidCallback? onReset,
    bool enableAdvancedModal = true,
    bool showAdvancedSection = true,
    bool initiallyAdvancedExpanded = false,
    bool wrapInGlass = true,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 400,
          height: 640,
          child: PrismFilterWorkbench(
            title: 'Filters',
            sections: sections ?? fixtureSections(),
            values: values,
            initialValues: initialValues,
            onChanged: onChanged,
            onApply: onApply,
            onReset: onReset,
            enableAdvancedModal: enableAdvancedModal,
            showAdvancedSection: showAdvancedSection,
            initiallyAdvancedExpanded: initiallyAdvancedExpanded,
            wrapInGlass: wrapInGlass,
          ),
        ),
      ),
    );
  }

  group('PrismFilterWorkbench', () {
    testWidgets('renders sections and quick chips from fixture schema', (
      tester,
    ) async {
      await tester.pumpWidget(harness());

      expect(find.byKey(PrismFilterWorkbench.panelKey), findsOneWidget);
      expect(
        find.byKey(PrismFilterWorkbench.sectionKey('assets')),
        findsOneWidget,
      );
      expect(find.byKey(PrismFilterWorkbench.quickChipsKey), findsOneWidget);
      expect(
        find.byKey(PrismFilterWorkbench.criterionKey('asset_type')),
        findsOneWidget,
      );
      expect(
        find.byKey(PrismFilterWorkbench.criterionKey('lifecycle')),
        findsOneWidget,
      );
      expect(find.text('Agent'), findsOneWidget);
      expect(find.text('Skill'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
    });

    testWidgets('apply callback receives current draft values', (tester) async {
      Map<String, Object?>? applied;
      Map<String, Object?> draft = {};

      await tester.pumpWidget(
        harness(
          values: draft,
          onChanged: (next) => draft = Map<String, Object?>.from(next),
          onApply: (v) => applied = v,
        ),
      );

      // Toggle multi-select chip "Agent"
      await tester.tap(find.text('Agent'));
      await tester.pumpAndSettle();

      // Rebuild with updated draft (controlled)
      await tester.pumpWidget(
        harness(
          values: draft,
          onChanged: (next) => draft = Map<String, Object?>.from(next),
          onApply: (v) => applied = v,
        ),
      );
      await tester.pump();

      await tester.tap(find.byKey(PrismFilterWorkbench.applyButtonKey));
      await tester.pumpAndSettle();

      expect(applied, isNotNull);
      final types = PrismFilterWorkbench.readStringSet(applied!, 'asset_type');
      expect(types, contains('agent'));
    });

    testWidgets('clear resets draft and fires onReset', (tester) async {
      var resetCount = 0;
      Map<String, Object?> draft = {
        'asset_type': <String>{'agent'},
        'lifecycle': 'active',
      };

      await tester.pumpWidget(
        harness(
          values: draft,
          onChanged: (next) => draft = Map<String, Object?>.from(next),
          onReset: () => resetCount++,
        ),
      );

      await tester.tap(find.byKey(PrismFilterWorkbench.clearButtonKey));
      await tester.pumpAndSettle();

      expect(resetCount, 1);
      expect(draft, isEmpty);
    });

    testWidgets('empty schema shows empty state', (tester) async {
      await tester.pumpWidget(harness(sections: const []));

      expect(find.byKey(PrismFilterWorkbench.emptyStateKey), findsOneWidget);
      expect(find.text('No filter criteria defined'), findsOneWidget);
      expect(find.byKey(PrismFilterWorkbench.quickChipsKey), findsNothing);
    });

    testWidgets('advanced modal opens, edits, and merges on Done', (
      tester,
    ) async {
      Map<String, Object?> draft = {};

      await tester.pumpWidget(
        harness(
          values: draft,
          onChanged: (next) => draft = Map<String, Object?>.from(next),
          showAdvancedSection: false,
          enableAdvancedModal: true,
        ),
      );

      expect(
        find.byKey(PrismFilterWorkbench.advancedButtonKey),
        findsOneWidget,
      );
      expect(find.byKey(PrismFilterWorkbench.advancedModalKey), findsNothing);

      await tester.tap(find.byKey(PrismFilterWorkbench.advancedButtonKey));
      await tester.pumpAndSettle();

      expect(find.byKey(PrismFilterWorkbench.advancedModalKey), findsOneWidget);
      expect(find.text('1 hour'), findsOneWidget);

      await tester.tap(find.text('1 hour'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      expect(find.byKey(PrismFilterWorkbench.advancedModalKey), findsNothing);
      expect(PrismFilterWorkbench.readString(draft, 'freshness'), '1h');
    });

    testWidgets('advanced expandable section toggles without modal', (
      tester,
    ) async {
      await tester.pumpWidget(
        harness(
          enableAdvancedModal: false,
          showAdvancedSection: true,
          initiallyAdvancedExpanded: false,
        ),
      );

      // Advanced criterion hidden until expanded
      expect(find.text('1 hour'), findsNothing);
      expect(
        find.byKey(PrismFilterWorkbench.advancedSectionKey),
        findsOneWidget,
      );

      await tester.tap(find.text('Advanced'));
      await tester.pumpAndSettle();

      expect(find.text('1 hour'), findsOneWidget);
    });

    testWidgets('apply and clear have Semantics labels', (tester) async {
      await tester.pumpWidget(harness());

      final applyHandle = tester.getSemantics(
        find.byKey(PrismFilterWorkbench.applyButtonKey),
      );
      expect(applyHandle.label, PrismFilterWorkbench.applySemanticLabel);
      expect(applyHandle.flagsCollection.isButton, isTrue);

      final clearHandle = tester.getSemantics(
        find.byKey(PrismFilterWorkbench.clearButtonKey),
      );
      expect(clearHandle.label, PrismFilterWorkbench.clearSemanticLabel);
      expect(clearHandle.flagsCollection.isButton, isTrue);

      final panelHandle = tester.getSemantics(
        find.byKey(PrismFilterWorkbench.panelKey),
      );
      expect(
        panelHandle.label,
        contains(PrismFilterWorkbench.panelSemanticLabel),
      );
    });

    testWidgets('public Prism alias constructs and mounts', (tester) async {
      await tester.pumpWidget(harness());
      expect(find.byType(PrismFilterWorkbench), findsOneWidget);
      // typedef static members forward to implementation
      expect(PrismFilterWorkbench.panelKey, isNotNull);
      expect(PrismFilterWorkbench.applySemanticLabel, isNotEmpty);
    });

    testWidgets('uncontrolled initialValues seed draft for apply', (
      tester,
    ) async {
      Map<String, Object?>? applied;

      await tester.pumpWidget(
        harness(
          initialValues: {
            'asset_type': <String>{'skill'},
          },
          onApply: (v) => applied = v,
        ),
      );

      await tester.tap(find.byKey(PrismFilterWorkbench.applyButtonKey));
      await tester.pumpAndSettle();

      expect(applied, isNotNull);
      expect(
        PrismFilterWorkbench.readStringSet(applied!, 'asset_type'),
        contains('skill'),
      );
    });

    testWidgets('boolean criterion toggles value', (tester) async {
      Map<String, Object?> draft = {};

      await tester.pumpWidget(
        harness(
          values: draft,
          onChanged: (next) => draft = Map<String, Object?>.from(next),
        ),
      );

      // Boolean row shows "Disabled" initially
      expect(find.text('Disabled'), findsOneWidget);
      await tester.tap(find.text('Disabled'));
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        harness(
          values: draft,
          onChanged: (next) => draft = Map<String, Object?>.from(next),
        ),
      );
      await tester.pump();

      expect(PrismFilterWorkbench.readBool(draft, 'pinned'), isTrue);
      expect(find.text('Enabled'), findsOneWidget);
    });

    testWidgets('interactive controls meet 48dp minimum touch target', (
      tester,
    ) async {
      await tester.pumpWidget(harness());

      void expectMinTouchTarget(Finder finder) {
        final size = tester.getSize(finder);
        expect(
          size.height,
          greaterThanOrEqualTo(kMinInteractiveDimension),
          reason: 'height of $finder',
        );
        expect(
          size.width,
          greaterThanOrEqualTo(kMinInteractiveDimension),
          reason: 'width of $finder',
        );
      }

      expectMinTouchTarget(find.byKey(PrismFilterWorkbench.applyButtonKey));
      expectMinTouchTarget(find.byKey(PrismFilterWorkbench.clearButtonKey));
      expectMinTouchTarget(find.byKey(PrismFilterWorkbench.advancedButtonKey));

      // Advanced expandable toggle (inline section mode).
      await tester.pumpWidget(
        harness(
          enableAdvancedModal: false,
          showAdvancedSection: true,
          initiallyAdvancedExpanded: false,
        ),
      );
      final advancedSection = find.byKey(
        PrismFilterWorkbench.advancedSectionKey,
      );
      expect(advancedSection, findsOneWidget);
      // Measure the expandable hit region via the Advanced label row.
      final advancedLabel = find.descendant(
        of: advancedSection,
        matching: find.text('Advanced'),
      );
      expect(advancedLabel, findsOneWidget);
      // Walk up to the constrained container: height must be ≥ 48.
      final expandableHit = find.ancestor(
        of: advancedLabel,
        matching: find.byWidgetPredicate(
          (w) =>
              w is Container &&
              w.constraints != null &&
              w.constraints!.minHeight >= kMinInteractiveDimension,
        ),
      );
      expect(expandableHit, findsWidgets);
      expect(
        tester.getSize(expandableHit.first).height,
        greaterThanOrEqualTo(kMinInteractiveDimension),
      );

      // Modal close / cancel / done.
      await tester.pumpWidget(harness());
      await tester.tap(find.byKey(PrismFilterWorkbench.advancedButtonKey));
      await tester.pumpAndSettle();

      expectMinTouchTarget(
        find.byKey(PrismFilterWorkbench.advancedModalCloseKey),
      );
      expectMinTouchTarget(
        find.byKey(PrismFilterWorkbench.advancedModalCancelKey),
      );
      expectMinTouchTarget(
        find.byKey(PrismFilterWorkbench.advancedModalDoneKey),
      );
    });
  });
}
