import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';
import 'package:warp_prism_ui/src/molecules/accordion/ds_accordion.dart';
import 'package:warp_prism_ui/src/molecules/ds_state_surface.dart';
import 'package:warp_prism_ui/src/atoms/ds_divider.dart';
import 'package:warp_prism_ui/src/atoms/ds_glass_panel.dart';

void main() {
  final sampleItems = [
    const DSAccordionItem(
      id: 'sec-1',
      title: 'Section 1',
      subtitle: 'Subtitle 1',
      icon: Icons.info,
      content: Text('Content 1'),
    ),
    const DSAccordionItem(
      id: 'sec-2',
      title: 'Section 2',
      subtitle: 'Subtitle 2',
      icon: Icons.settings,
      content: Text('Content 2'),
    ),
    const DSAccordionItem(
      id: 'sec-3',
      title: 'Section 3',
      disabled: true,
      content: Text('Content 3'),
    ),
  ];

  group('DSAccordion / PrismAccordion Widget Tests', () {
    testWidgets('renders all section headers in initial state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DSAccordion(items: sampleItems)),
        ),
      );

      expect(find.text('Section 1'), findsOneWidget);
      expect(find.text('Section 2'), findsOneWidget);
      expect(find.text('Section 3'), findsOneWidget);

      // Collapsed initially, so content is not visible
      expect(find.text('Content 1'), findsNothing);
      expect(find.text('Content 2'), findsNothing);
      expect(find.text('Content 3'), findsNothing);
    });

    testWidgets('respects defaultOpen for items', (tester) async {
      final itemsWithDefaultOpen = [
        const DSAccordionItem(
          title: 'Open Section',
          defaultOpen: true,
          content: Text('Open Content'),
        ),
        const DSAccordionItem(
          title: 'Closed Section',
          content: Text('Closed Content'),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DSAccordion(items: itemsWithDefaultOpen)),
        ),
      );

      expect(find.text('Open Content'), findsOneWidget);
      expect(find.text('Closed Content'), findsNothing);
    });

    testWidgets('tap on header toggles open/close', (tester) async {
      int? toggledSection;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DSAccordion(
              items: sampleItems,
              onSectionToggled: (index) => toggledSection = index,
            ),
          ),
        ),
      );

      // Tap Section 1
      await tester.tap(find.text('Section 1'));
      await tester.pumpAndSettle();

      expect(toggledSection, 0);
      expect(find.text('Content 1'), findsOneWidget);

      // Tap Section 1 again to close
      await tester.tap(find.text('Section 1'));
      await tester.pumpAndSettle();

      expect(toggledSection, null);
      expect(find.text('Content 1'), findsNothing);
    });

    testWidgets('single-expand closes others when one opens', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DSAccordion(items: sampleItems, multiExpand: false),
          ),
        ),
      );

      // Tap Section 1
      await tester.tap(find.text('Section 1'));
      await tester.pumpAndSettle();
      expect(find.text('Content 1'), findsOneWidget);
      expect(find.text('Content 2'), findsNothing);

      // Tap Section 2
      await tester.tap(find.text('Section 2'));
      await tester.pumpAndSettle();
      expect(find.text('Content 1'), findsNothing);
      expect(find.text('Content 2'), findsOneWidget);
    });

    testWidgets('multi-expand keeps multiple sections open', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DSAccordion(items: sampleItems, multiExpand: true),
          ),
        ),
      );

      // Tap Section 1
      await tester.tap(find.text('Section 1'));
      await tester.pumpAndSettle();

      // Tap Section 2
      await tester.tap(find.text('Section 2'));
      await tester.pumpAndSettle();

      expect(find.text('Content 1'), findsOneWidget);
      expect(find.text('Content 2'), findsOneWidget);
    });

    testWidgets('disabled section ignores taps', (tester) async {
      int? toggled;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DSAccordion(
              items: sampleItems,
              onSectionToggled: (index) => toggled = index,
            ),
          ),
        ),
      );

      // Section 3 is disabled
      await tester.tap(find.text('Section 3'));
      await tester.pumpAndSettle();

      expect(toggled, null);
      expect(find.text('Content 3'), findsNothing);
    });

    testWidgets('empty content shows empty state fallback', (tester) async {
      final itemsWithNullContent = [
        const DSAccordionItem(
          title: 'Empty Section',
          defaultOpen: true,
          content: null,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DSAccordion(items: itemsWithNullContent)),
        ),
      );

      expect(find.text('No content'), findsOneWidget);
      expect(find.byType(DSStateSurface), findsOneWidget);
    });

    testWidgets('PrismAccordion and PrismAccordionItem aliases work', (
      tester,
    ) async {
      final items = [
        const PrismAccordionItem(
          title: 'Alias Section',
          defaultOpen: true,
          content: Text('Alias Content'),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: PrismAccordion(items: items)),
        ),
      );

      expect(find.text('Alias Section'), findsOneWidget);
      expect(find.text('Alias Content'), findsOneWidget);
    });

    testWidgets('rendered header interactive target size is at least 48dp', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DSAccordion(items: sampleItems)),
        ),
      );

      final headerFinder = find.ancestor(
        of: find.text('Section 1'),
        matching: find.byType(PrismInteractiveSurface),
      );
      expect(headerFinder, findsOneWidget);

      final size = tester.getSize(headerFinder);
      expect(
        size.height,
        greaterThanOrEqualTo(48.0),
        reason:
            'Section header interactive target height must be at least 48dp.',
      );
    });
  });

  // ---------------------------------------------------------------------------
  // Coverage gap closure — Axiom 5 (Proof Reality).
  // These tests prove behavior of public API surfaces that were previously
  // untested: chevron rotation animation, onExpandedIndicesChanged callback,
  // controlled expansion via expandedIndices, showDividers toggle,
  // wrapInGlass toggle, and the empty-items-list fallback branch.
  // ---------------------------------------------------------------------------

  group('DSAccordion animation & optional surface coverage', () {
    testWidgets(
      'chevron rotates 180 degrees (0.0 turns -> 0.5 turns) on expand',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: DSAccordion(items: sampleItems)),
          ),
        );

        // Collapsed: chevron rotation is 0.0 turns.
        final rotationCollapsed = tester.widget<AnimatedRotation>(
          find.byType(AnimatedRotation).first,
        );
        expect(
          rotationCollapsed.turns,
          0.0,
          reason: 'Collapsed chevron must be at 0.0 turns (pointing down).',
        );

        // Expand Section 1. Pump a single frame (not settle) so we observe the
        // target turns value even mid-animation — the AnimatedRotation `turns`
        // property reflects the destination immediately.
        await tester.tap(find.text('Section 1'));
        await tester.pump();

        final rotationExpanded = tester.widget<AnimatedRotation>(
          find.byType(AnimatedRotation).first,
        );
        expect(
          rotationExpanded.turns,
          0.5,
          reason:
              'Expanded chevron must animate to 0.5 turns (180 degrees rotation).',
        );

        // Collapse again and confirm turns returns to 0.0.
        await tester.tap(find.text('Section 1'));
        await tester.pump();

        final rotationRecollapsed = tester.widget<AnimatedRotation>(
          find.byType(AnimatedRotation).first,
        );
        expect(
          rotationRecollapsed.turns,
          0.0,
          reason: 'Recollapsed chevron must return to 0.0 turns.',
        );
      },
    );

    testWidgets('onExpandedIndicesChanged fires with the correct Set<int>', (
      tester,
    ) async {
      final List<Set<int>> emitted = [];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DSAccordion(
              items: sampleItems,
              multiExpand: true,
              onExpandedIndicesChanged: (indices) => emitted.add({...indices}),
            ),
          ),
        ),
      );

      // Expand Section 1 -> {0}.
      await tester.tap(find.text('Section 1'));
      await tester.pumpAndSettle();
      expect(emitted.last, {0});

      // Expand Section 2 -> {0, 1}.
      await tester.tap(find.text('Section 2'));
      await tester.pumpAndSettle();
      expect(emitted.last, {0, 1});

      // Collapse Section 1 -> {1}.
      await tester.tap(find.text('Section 1'));
      await tester.pumpAndSettle();
      expect(emitted.last, {1});

      // Collapse Section 2 -> {} (empty set, not null).
      await tester.tap(find.text('Section 2'));
      await tester.pumpAndSettle();
      expect(emitted.last, <int>{});
    });

    testWidgets(
      'controlled mode (expandedIndices) reflects parent state and does not '
      'mutate internally on tap',
      (tester) async {
        // In controlled mode, the widget must display whatever the parent
        // passes via `expandedIndices` and must NOT flip its own state on tap.
        // The tap should still fire callbacks, but the visible expansion is
        // owned by the parent (here we keep it pinned to {1}).
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DSAccordion(items: sampleItems, expandedIndices: const {1}),
            ),
          ),
        );

        // Only Section 2 is expanded per the controlled set.
        expect(find.text('Content 1'), findsNothing);
        expect(find.text('Content 2'), findsOneWidget);
        expect(find.text('Content 3'), findsNothing);

        // Tap Section 1 — in controlled mode the widget must NOT internally
        // expand Section 1, because the parent still owns {1}.
        await tester.tap(find.text('Section 1'));
        await tester.pumpAndSettle();

        expect(
          find.text('Content 1'),
          findsNothing,
          reason:
              'Controlled mode must not mutate internal state on tap; parent owns expansion.',
        );
        expect(
          find.text('Content 2'),
          findsOneWidget,
          reason: 'Parent-controlled {1} must remain the visible expansion.',
        );
      },
    );

    testWidgets('showDividers: false suppresses DSDivider between sections', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DSAccordion(items: sampleItems, showDividers: false),
          ),
        ),
      );

      expect(
        find.byType(DSDivider),
        findsNothing,
        reason: 'With showDividers: false, no DSDivider should be inserted.',
      );
    });

    testWidgets(
      'showDividers: true (default) inserts dividers between sections',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: DSAccordion(items: sampleItems)),
          ),
        );

        // Three sections -> two inter-section dividers (i in 1..2).
        expect(find.byType(DSDivider), findsNWidgets(2));
      },
    );

    testWidgets('wrapInGlass: false omits the DSGlassPanel wrapper', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DSAccordion(items: sampleItems, wrapInGlass: false),
          ),
        ),
      );

      expect(
        find.byType(DSGlassPanel),
        findsNothing,
        reason:
            'With wrapInGlass: false, no DSGlassPanel should wrap the body.',
      );
    });

    testWidgets('wrapInGlass: true (default) wraps body in DSGlassPanel', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DSAccordion(items: sampleItems)),
        ),
      );

      expect(find.byType(DSGlassPanel), findsOneWidget);
    });

    testWidgets('empty items list renders the "No sections" fallback', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DSAccordion(items: [])),
        ),
      );

      // The empty-list branch in build() renders DSStateSurface.empty with
      // title 'No sections', wrapped in DSGlassPanel by default.
      expect(
        find.text('No sections'),
        findsOneWidget,
        reason: 'Empty items list must render the "No sections" fallback.',
      );
      expect(find.byType(DSStateSurface), findsOneWidget);
      expect(find.byType(DSGlassPanel), findsOneWidget);
    });

    testWidgets(
      'empty items list with wrapInGlass: false omits DSGlassPanel for the fallback',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: DSAccordion(items: [], wrapInGlass: false)),
          ),
        );

        expect(find.text('No sections'), findsOneWidget);
        expect(
          find.byType(DSGlassPanel),
          findsNothing,
          reason:
              'wrapInGlass: false must also apply to the empty-items fallback.',
        );
      },
    );
  });
}
