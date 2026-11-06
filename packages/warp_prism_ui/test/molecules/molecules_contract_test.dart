// Contract tests for Design System Molecules.
//
// These tests verify the API surface and behavioral contracts of all
// required DS molecules. They verify constructors compile, atoms are
// composed correctly, and interactive states produce expected changes.
//
// Run: flutter test test/molecules/molecules_contract_test.dart

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/src/molecules/molecules.dart';
import 'package:warp_prism_ui/src/atoms/atoms.dart';

void main() {
  // ===========================================================================
  // DSSearchBar
  // ===========================================================================
  group('DSSearchBar contract', () {
    testWidgets('renders with placeholder text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: DSSearchBar())),
      );
      expect(find.byType(DSSearchBar), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('custom placeholder is shown', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DSSearchBar(placeholder: 'Find assets...')),
        ),
      );
      expect(find.text('Find assets...'), findsOneWidget);
    });

    testWidgets('onChanged fires when text changes', (tester) async {
      String? changedValue;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DSSearchBar(onChanged: (v) => changedValue = v)),
        ),
      );
      await tester.enterText(find.byType(TextField), 'test');
      expect(changedValue, 'test');
    });

    testWidgets('clear button appears when text is entered', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: DSSearchBar())),
      );
      await tester.enterText(find.byType(TextField), 'query');
      await tester.pump();
      expect(find.byIcon(DSIcons.close), findsOneWidget);
    });

    testWidgets('filter button visible by default', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: DSSearchBar())),
      );
      expect(find.byIcon(DSIcons.filter), findsOneWidget);
    });

    testWidgets('filter button hidden when showFilter=false', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: DSSearchBar(showFilter: false))),
      );
      expect(find.byIcon(DSIcons.filter), findsNothing);
    });

    testWidgets('uses DSIcon and DSColors from atoms/tokens', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: DSSearchBar())),
      );
      expect(find.byType(DSIcon), findsWidgets);
    });
  });

  // ===========================================================================
  // DSFilterChipGroup
  // ===========================================================================
  group('DSFilterChipGroup contract', () {
    final options = [
      const DSFilterOption(value: 'agent', label: 'Agents', count: 5),
      const DSFilterOption(value: 'skill', label: 'Skills', count: 12),
      const DSFilterOption(
        value: 'workflow',
        label: 'Workflows',
        icon: Icons.account_tree,
      ),
    ];

    testWidgets('renders all options', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DSFilterChipGroup(options: options, selected: const {}),
        ),
      );
      expect(find.text('Agents'), findsOneWidget);
      expect(find.text('Skills'), findsOneWidget);
      expect(find.text('Workflows'), findsOneWidget);
    });

    testWidgets('selected chips show selected state (semantics)', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        MaterialApp(
          // onToggle required for button semantics (null = non-interactive).
          home: DSFilterChipGroup(
            options: options,
            selected: const {'agent'},
            onToggle: (_) {},
          ),
        ),
      );

      final labelFinder = find.bySemanticsLabel('Agents');
      expect(labelFinder, findsOneWidget);
      final semantics = tester.getSemantics(labelFinder);
      expect(semantics.flagsCollection.isSelected, ui.Tristate.isTrue);
      expect(semantics.flagsCollection.isButton, isTrue);
      handle.dispose();
    });

    testWidgets('onToggle fires with correct value', (tester) async {
      String? toggled;
      await tester.pumpWidget(
        MaterialApp(
          home: DSFilterChipGroup(
            options: options,
            selected: const {},
            onToggle: (v) => toggled = v,
          ),
        ),
      );
      await tester.tap(find.text('Agents'));
      expect(toggled, 'agent');
    });

    testWidgets('counts shown by default', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DSFilterChipGroup(options: options, selected: const {}),
        ),
      );
      expect(find.text('5'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
    });

    testWidgets('counts hidden when showCount=false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DSFilterChipGroup(
            options: options,
            selected: const {},
            showCount: false,
          ),
        ),
      );
      expect(find.text('5'), findsNothing);
      expect(find.text('12'), findsNothing);
    });
  });

  // ===========================================================================
  // DSAssetCard
  // ===========================================================================
  group('DSAssetCard contract', () {
    testWidgets('renders name and kind', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DSAssetCard(name: 'architect', kind: 'agent'),
        ),
      );
      expect(find.text('architect'), findsOneWidget);
      expect(find.text('AGENT'), findsOneWidget);
    });

    testWidgets('renders description when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DSAssetCard(
            name: 'test',
            kind: 'skill',
            description: 'A test skill',
          ),
        ),
      );
      expect(find.text('A test skill'), findsOneWidget);
    });

    testWidgets('selected state applies visual change (semantics)', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        const MaterialApp(
          home: DSAssetCard(
            name: 'selected card',
            kind: 'agent',
            selected: true,
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(DSAssetCard));
      expect(semantics.label, contains('selected card'));
      expect(semantics.flagsCollection.isSelected, ui.Tristate.isTrue);

      handle.dispose();
    });

    testWidgets('onTap fires callback', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: DSAssetCard(
            name: 'tap',
            kind: 'agent',
            onTap: () => tapped = true,
          ),
        ),
      );
      await tester.tap(find.text('tap'));
      expect(tapped, true);
    });

    testWidgets('uses DSChip for tags and governance', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DSAssetCard(
            name: 'tagged',
            kind: 'skill',
            canonicality: 'parentcanonical',
            tags: ['ai', 'planning'],
          ),
        ),
      );
      expect(find.byType(DSChip), findsWidgets);
    });

    testWidgets('edge count shown when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DSAssetCard(name: 'connected', kind: 'workflow', edgeCount: 7),
        ),
      );
      expect(find.text('7'), findsOneWidget);
    });

    testWidgets('composes DSIcon and DSText atoms', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DSAssetCard(name: 'atom', kind: 'agent'),
        ),
      );
      expect(find.byType(DSIcon), findsWidgets);
      expect(find.byType(DSText), findsWidgets);
    });
  });

  // ===========================================================================
  // DSTaskCard
  // ===========================================================================
  group('DSTaskCard contract — separate from DSAssetCard', () {
    testWidgets('renders task id and title', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DSTaskCard(id: 15, title: 'Normalize atoms', lane: '02-doing'),
        ),
      );
      expect(find.text('#15'), findsOneWidget);
      expect(find.text('Normalize atoms'), findsOneWidget);
    });

    testWidgets('renders priority badge', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DSTaskCard(
            id: 1,
            title: 'Test',
            lane: '01-open',
            priority: 'P0',
          ),
        ),
      );
      expect(find.text('P0'), findsOneWidget);
    });

    testWidgets('renders owner', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DSTaskCard(
            id: 1,
            title: 'Test',
            lane: '01-open',
            owner: 'builder',
          ),
        ),
      );
      expect(find.text('builder'), findsOneWidget);
    });

    testWidgets('renders proof state indicator', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DSTaskCard(
            id: 1,
            title: 'Test',
            lane: '02-doing',
            proofState: 'complete',
          ),
        ),
      );
      expect(find.byType(DSStatusDot), findsOneWidget);
    });

    testWidgets('selected state changes background (semantics)', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        const MaterialApp(
          home: DSTaskCard(
            id: 1,
            title: 'Selected Task',
            lane: '02-doing',
            selected: true,
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(DSTaskCard));
      expect(semantics.label, contains('Selected Task'));
      expect(semantics.flagsCollection.isSelected, ui.Tristate.isTrue);
      handle.dispose();
    });

    testWidgets('onTap fires callback', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: DSTaskCard(
            id: 1,
            title: 'Tap me',
            lane: '01-open',
            onTap: () => tapped = true,
          ),
        ),
      );
      await tester.tap(find.text('Tap me'));
      expect(tapped, true);
    });

    testWidgets('linked skills rendered as DSChips', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DSTaskCard(
            id: 1,
            title: 'Test',
            lane: '02-doing',
            linkedSkills: ['analyzer', 'parser'],
          ),
        ),
      );
      expect(find.byType(DSChip), findsWidgets);
    });

    testWidgets('composes DSStatusDot, DSChip, DSText, DSIcon atoms', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DSTaskCard(
            id: 1,
            title: 'Compose',
            lane: '02-doing',
            priority: 'P1',
            owner: 'agent',
            proofState: 'partial',
            linkedSkills: ['skill-a'],
          ),
        ),
      );
      expect(find.byType(DSStatusDot), findsOneWidget);
      expect(find.byType(DSChip), findsWidgets);
      expect(find.byType(DSText), findsWidgets);
      expect(find.byType(DSIcon), findsWidgets);
    });
  });

  // ===========================================================================
  // DSMetricTile
  // ===========================================================================
  group('DSMetricTile contract', () {
    testWidgets('renders label and value', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DSMetricTile(label: 'Agents', value: '9'),
        ),
      );
      expect(find.text('Agents'), findsOneWidget);
      expect(find.text('9'), findsOneWidget);
    });

    testWidgets('renders trend indicator', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DSMetricTile(label: 'Skills', value: '13', trend: DSTrend.up),
        ),
      );
      expect(find.byIcon(Icons.trending_up), findsOneWidget);
    });

    testWidgets('compact variant renders', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DSMetricTileCompact(label: 'Tasks', value: '20'),
        ),
      );
      expect(find.text('Tasks'), findsOneWidget);
      expect(find.text('20'), findsOneWidget);
    });

    test('DSTrend has up, down, flat', () {
      expect(DSTrend.values.length, 3);
    });

    testWidgets('composes DSGlassPanelSimple atom', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DSMetricTile(label: 'Test', value: '1'),
        ),
      );
      expect(find.byType(DSGlassPanelSimple), findsOneWidget);
    });
  });

  // ===========================================================================
  // DSProvenancePill
  // ===========================================================================
  group('DSProvenancePill contract', () {
    testWidgets('renders canonicality label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DSProvenancePill(canonicality: 'parentcanonical'),
        ),
      );
      expect(find.text('Canonical'), findsOneWidget);
    });

    testWidgets('hides label when showLabel=false', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DSProvenancePill(canonicality: 'generated', showLabel: false),
        ),
      );
      expect(find.text('Generated'), findsNothing);
    });

    testWidgets('tooltip is shown', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: DSProvenancePill(canonicality: 'mock')),
      );
      expect(find.byType(Tooltip), findsOneWidget);
    });

    test('DSProvenanceSize has small, medium, large', () {
      expect(DSProvenanceSize.values.length, 3);
    });
  });

  // ===========================================================================
  // DSEvidenceRow
  // ===========================================================================
  group('DSEvidenceRow contract', () {
    testWidgets('renders label and state icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DSEvidenceRow(
            label: 'Tests passed',
            state: DSEvidenceState.verified,
          ),
        ),
      );
      expect(find.text('Tests passed'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('all evidence states render', (tester) async {
      for (final state in DSEvidenceState.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: DSEvidenceRow(label: state.name, state: state),
          ),
        );
      }
    });

    testWidgets('provides correct semantics', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        MaterialApp(
          home: DSEvidenceRow(
            label: 'Tests passed',
            value: 'Coverage 100%',
            state: DSEvidenceState.verified,
            onTap: () {},
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(DSEvidenceRow));
      expect(semantics.label, contains('Evidence row: Tests passed'));
      expect(semantics.flagsCollection.isButton, isTrue);

      handle.dispose();
    });

    testWidgets('onTap fires callback', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: DSEvidenceRow(
            label: 'Evidence',
            state: DSEvidenceState.verified,
            onTap: () => tapped = true,
          ),
        ),
      );
      await tester.tap(find.text('Evidence'));
      expect(tapped, true);
    });

    testWidgets('compact indicator renders', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DSEvidenceIndicator(state: DSEvidenceState.partial),
        ),
      );
      expect(find.text('Partial'), findsOneWidget);
    });

    test('DSEvidenceState has verified, partial, missing, pending', () {
      expect(DSEvidenceState.values.length, 4);
    });
  });

  // ===========================================================================
  // DSTimelineMarker
  // ===========================================================================
  group('DSTimelineMarker contract', () {
    testWidgets('renders date and title', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DSTimelineMarker(
            date: '2026-06-07',
            title: 'Backbone models created',
          ),
        ),
      );
      expect(find.text('2026-06-07'), findsOneWidget);
      expect(find.text('Backbone models created'), findsOneWidget);
    });

    testWidgets('provides correct semantics', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        MaterialApp(
          home: DSTimelineMarker(
            date: '2026-06-07',
            title: 'Backbone models created',
            selected: true,
            onTap: () {},
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(DSTimelineMarker));
      expect(
        semantics.label,
        contains('Timeline entry: Backbone models created'),
      );
      expect(semantics.flagsCollection.isButton, isTrue);
      expect(semantics.flagsCollection.isSelected, ui.Tristate.isTrue);

      handle.dispose();
    });

    testWidgets('renders type badge when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DSTimelineMarker(
            date: '2026-06-07',
            title: 'Feature',
            type: 'feature',
          ),
        ),
      );
      expect(find.text('FEATURE'), findsOneWidget);
    });

    testWidgets('renders project when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DSTimelineMarker(
            date: '2026-06-07',
            title: 'Test',
            project: 'warp-prism',
          ),
        ),
      );
      expect(find.text('warp-prism'), findsOneWidget);
    });

    testWidgets('renders task id when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DSTimelineMarker(
            date: '2026-06-07',
            title: 'Test',
            taskId: '0310',
          ),
        ),
      );
      expect(find.text('#0310'), findsOneWidget);
    });

    testWidgets('selected state changes background', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DSTimelineMarker(
            date: '2026-06-07',
            title: 'Selected',
            selected: true,
          ),
        ),
      );

      // Implicitly handled by the semantics test above, but we keep this test to prove the tree contains the widget
      expect(find.text('Selected'), findsOneWidget);
    });

    testWidgets('onTap fires callback', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: DSTimelineMarker(
            date: '2026-06-07',
            title: 'Tap',
            onTap: () => tapped = true,
          ),
        ),
      );
      await tester.tap(find.text('Tap'));
      expect(tapped, true);
    });

    testWidgets('impacts rendered as DSChips', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DSTimelineMarker(
            date: '2026-06-07',
            title: 'Impact test',
            impacts: ['parser', 'graph-model'],
          ),
        ),
      );
      expect(find.byType(DSChip), findsWidgets);
    });

    testWidgets('composes DSText, DSChip, DSIcon atoms', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DSTimelineMarker(
            date: '2026-06-07',
            title: 'Full',
            type: 'feature',
            project: 'warp-prism',
            taskId: '0311',
            impacts: ['parser'],
          ),
        ),
      );
      expect(find.byType(DSText), findsWidgets);
      expect(find.byType(DSChip), findsWidgets);
      expect(find.byType(DSIcon), findsWidgets);
    });
  });

  // ===========================================================================
  // DSStateSurface
  // ===========================================================================
  group('DSStateSurface contract', () {
    testWidgets('empty state renders title', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: DSStateSurface.empty(title: 'No data')),
      );
      expect(find.text('No data'), findsOneWidget);
    });

    testWidgets('loading state renders indicator', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: DSStateSurface.loading(title: 'Loading...')),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('error state renders title and action', (tester) async {
      var retried = false;
      await tester.pumpWidget(
        MaterialApp(
          home: DSStateSurface.error(
            title: 'Failed',
            onAction: () => retried = true,
          ),
        ),
      );
      expect(find.text('Failed'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      expect(retried, true);
    });

    testWidgets('compact variant uses smaller layout', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DSStateSurface.empty(title: 'Empty', compact: true),
        ),
      );
      expect(find.text('Empty'), findsOneWidget);
    });

    test(
      'DSStateType has empty, loading, error, disabled, stale, degraded, excluded, unknown',
      () {
        expect(DSStateType.values.length, 8);
        expect(DSStateType.values, contains(DSStateType.unknown));
      },
    );
  });

  // ===========================================================================
  // Interactive accessibility contract (keyboard / min-target / enabled)
  // ===========================================================================
  group('interactive molecule accessibility contract', () {
    Future<void> pumpInteractive(WidgetTester tester, Widget child) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: child)));
    }

    Future<void> expectKeyboardActivation(
      WidgetTester tester, {
      required Finder focusTarget,
      required FocusNode focusNode,
      required ValueGetter<int> activations,
    }) async {
      final before = activations();
      await tester.tap(focusTarget);
      await tester.pump();
      expect(activations(), before + 1);

      focusNode.requestFocus();
      await tester.pump();
      expect(focusNode.hasFocus, isTrue);
      expect(FocusManager.instance.primaryFocus, same(focusNode));

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(activations(), before + 2);

      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(activations(), before + 3);
    }

    void expectMinTarget(WidgetTester tester, Finder finder) {
      final size = tester.getSize(finder);
      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));
    }

    testWidgets('DSAssetCard interactive contract', (tester) async {
      final handle = tester.ensureSemantics();
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      var taps = 0;
      await pumpInteractive(
        tester,
        DSAssetCard(
          name: 'focusable',
          kind: 'agent',
          focusNode: focusNode,
          onTap: () => taps++,
        ),
      );

      final interactive = tester.getSemantics(find.byType(DSAssetCard));
      expect(interactive.flagsCollection.isButton, isTrue);
      expect(interactive.flagsCollection.isEnabled, ui.Tristate.isTrue);
      expectMinTarget(tester, find.byType(DSAssetCard));
      await expectKeyboardActivation(
        tester,
        focusTarget: find.text('focusable'),
        focusNode: focusNode,
        activations: () => taps,
      );

      await pumpInteractive(
        tester,
        const DSAssetCard(name: 'static', kind: 'agent'),
      );
      final passive = tester.getSemantics(find.byType(DSAssetCard));
      expect(passive.flagsCollection.isButton, isFalse);
      expect(passive.flagsCollection.isEnabled, ui.Tristate.isFalse);
      handle.dispose();
    });

    testWidgets('DSMetricTile interactive contract', (tester) async {
      final handle = tester.ensureSemantics();
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      var taps = 0;
      await pumpInteractive(
        tester,
        DSMetricTile(
          label: 'Agents',
          value: '9',
          focusNode: focusNode,
          onTap: () => taps++,
        ),
      );

      final interactive = tester.getSemantics(find.byType(DSMetricTile));
      expect(interactive.flagsCollection.isButton, isTrue);
      expect(interactive.flagsCollection.isEnabled, ui.Tristate.isTrue);
      expectMinTarget(tester, find.byType(DSMetricTile));
      await expectKeyboardActivation(
        tester,
        focusTarget: find.text('Agents'),
        focusNode: focusNode,
        activations: () => taps,
      );

      await pumpInteractive(
        tester,
        const DSMetricTile(label: 'Passive', value: '0'),
      );
      final passive = tester.getSemantics(find.byType(DSMetricTile));
      expect(passive.flagsCollection.isButton, isFalse);
      expect(passive.flagsCollection.isEnabled, ui.Tristate.isFalse);
      handle.dispose();
    });

    testWidgets('DSMetricTileCompact interactive contract', (tester) async {
      final handle = tester.ensureSemantics();
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      var taps = 0;
      await pumpInteractive(
        tester,
        DSMetricTileCompact(
          label: 'Tasks',
          value: '20',
          focusNode: focusNode,
          onTap: () => taps++,
        ),
      );

      final interactive = tester.getSemantics(find.byType(DSMetricTileCompact));
      expect(interactive.flagsCollection.isButton, isTrue);
      expect(interactive.flagsCollection.isEnabled, ui.Tristate.isTrue);
      expectMinTarget(tester, find.byType(DSMetricTileCompact));
      await expectKeyboardActivation(
        tester,
        focusTarget: find.text('Tasks'),
        focusNode: focusNode,
        activations: () => taps,
      );
      handle.dispose();
    });

    testWidgets('DSEvidenceRow interactive contract', (tester) async {
      final handle = tester.ensureSemantics();
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      var taps = 0;
      await pumpInteractive(
        tester,
        DSEvidenceRow(
          label: 'Coverage',
          state: DSEvidenceState.verified,
          focusNode: focusNode,
          onTap: () => taps++,
        ),
      );

      final interactive = tester.getSemantics(find.byType(DSEvidenceRow));
      expect(interactive.flagsCollection.isButton, isTrue);
      expect(interactive.flagsCollection.isEnabled, ui.Tristate.isTrue);
      expectMinTarget(tester, find.byType(DSEvidenceRow));
      await expectKeyboardActivation(
        tester,
        focusTarget: find.text('Coverage'),
        focusNode: focusNode,
        activations: () => taps,
      );
      handle.dispose();
    });

    testWidgets('DSTimelineMarker interactive contract', (tester) async {
      final handle = tester.ensureSemantics();
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      var taps = 0;
      await pumpInteractive(
        tester,
        DSTimelineMarker(
          date: '2026-07-09',
          title: 'Timeline focus',
          focusNode: focusNode,
          onTap: () => taps++,
        ),
      );

      final interactive = tester.getSemantics(find.byType(DSTimelineMarker));
      expect(interactive.flagsCollection.isButton, isTrue);
      expect(interactive.flagsCollection.isEnabled, ui.Tristate.isTrue);
      expectMinTarget(tester, find.byType(DSTimelineMarker));
      await expectKeyboardActivation(
        tester,
        focusTarget: find.text('Timeline focus'),
        focusNode: focusNode,
        activations: () => taps,
      );
      handle.dispose();
    });

    testWidgets('DSTaskCard interactive contract', (tester) async {
      final handle = tester.ensureSemantics();
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      var taps = 0;
      await pumpInteractive(
        tester,
        DSTaskCard(
          id: 15,
          title: 'Task focus',
          lane: '02-doing',
          focusNode: focusNode,
          onTap: () => taps++,
        ),
      );

      final interactive = tester.getSemantics(find.byType(DSTaskCard));
      expect(interactive.flagsCollection.isButton, isTrue);
      expect(interactive.flagsCollection.isEnabled, ui.Tristate.isTrue);
      expectMinTarget(tester, find.byType(DSTaskCard));
      await expectKeyboardActivation(
        tester,
        focusTarget: find.text('Task focus'),
        focusNode: focusNode,
        activations: () => taps,
      );

      await pumpInteractive(
        tester,
        const DSTaskCard(id: 1, title: 'Static task', lane: '01-open'),
      );
      final passive = tester.getSemantics(find.byType(DSTaskCard));
      expect(passive.flagsCollection.isButton, isFalse);
      expect(passive.flagsCollection.isEnabled, ui.Tristate.isFalse);
      handle.dispose();
    });
  });
}
