import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_interaction/src/input/action_availability.dart';
import 'package:warp_prism_interaction/src/state_machine/shell_slot_machine.dart';
import 'package:warp_prism_ui/src/organisms/ds_sidebar.dart';
import 'package:warp_prism_ui/src/organisms/ds_sidebar_sections.dart';

/// Task 1873 (F-06): PrismSidebar section-model extension.
///
/// Covers kept-row fold, insertion line, Starred, unread pills, gated rows
/// (disabled-with-reason, never hidden), and the IDS↔ADS eligibility
/// projection proof (Task 1868 frozen shape → [DSSidebarRowGateData]).
void main() {
  List<DSSidebarSection> sections() => const [
    DSSidebarSection(
      id: 'ops',
      title: 'Operations',
      keptRowIds: ['sessions'],
      rows: [
        DSSidebarItem(id: 'sessions', label: 'Sessions'),
        DSSidebarItem(id: 'control', label: 'Control'),
        DSSidebarItem(id: 'provenance', label: 'Provenance'),
      ],
    ),
  ];

  Widget harness({
    List<DSSidebarSection>? override,
    Map<String, DSSidebarRowGateData> gates = const {},
    Map<String, DSSidebarRowFlags> flags = const {},
    int? insertionIndex,
    String? selectedId,
    ValueChanged<String>? onItemTap,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 400,
          height: 800,
          child: DSSidebarSections(
            sections: override ?? sections(),
            gates: gates,
            flags: flags,
            insertionIndex: insertionIndex,
            selectedId: selectedId,
            onItemTap: onItemTap,
          ),
        ),
      ),
    );
  }

  group('DSSidebarSections section model', () {
    testWidgets('renders all rows expanded by default', (tester) async {
      await tester.pumpWidget(harness());
      await tester.pumpAndSettle();

      expect(find.text('Sessions'), findsOneWidget);
      expect(find.text('Control'), findsOneWidget);
      expect(find.text('Provenance'), findsOneWidget);
    });

    testWidgets('collapsed section keeps only the kept-row fold', (
      tester,
    ) async {
      await tester.pumpWidget(
        harness(
          override: const [
            DSSidebarSection(
              id: 'ops',
              title: 'Operations',
              initiallyCollapsed: true,
              keptRowIds: ['sessions'],
              rows: [
                DSSidebarItem(id: 'sessions', label: 'Sessions'),
                DSSidebarItem(id: 'control', label: 'Control'),
              ],
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sessions'), findsOneWidget);
      expect(find.text('Control'), findsNothing);
    });

    testWidgets('insertion line renders at the flat offset', (tester) async {
      await tester.pumpWidget(harness(insertionIndex: 1));
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Row insertion point'), findsOneWidget);
    });

    testWidgets('starred + unread render without hiding the row', (
      tester,
    ) async {
      await tester.pumpWidget(
        harness(
          flags: const {
            'sessions': DSSidebarRowFlags(starred: true, unreadCount: 3),
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sessions'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('denied gated row renders disabled with reason, never hidden', (
      tester,
    ) async {
      final tapped = <String>[];
      await tester.pumpWidget(
        harness(
          gates: const {
            'control': DSSidebarRowGateData(
              rowId: 'control',
              denied: true,
              reason: 'Missing capability: nav.control',
            ),
          },
          onItemTap: tapped.add,
        ),
      );
      await tester.pumpAndSettle();

      // Still rendered (never hidden) with the denial announced.
      expect(find.text('Control'), findsOneWidget);
      expect(
        find.bySemanticsLabel(RegExp('disabled: Missing capability')),
        findsOneWidget,
      );
      // Tapping a denied row dispatches nothing.
      await tester.tap(find.text('Control'));
      await tester.pumpAndSettle();
      expect(tapped, isEmpty);

      // An enabled row still dispatches.
      await tester.tap(find.text('Sessions'));
      await tester.pumpAndSettle();
      expect(tapped, ['sessions']);
    });

    test('IDS availability projects onto gate data fail-closed', () {
      // Projection law (product-side): allow/constrain ⇒ enabled;
      // deny/missing ⇒ denied-with-reason. Proved here so the ADS file can
      // stay dependency-light while the contract stays frozen.
      DSSidebarRowGateData project(String rowId, CapabilityState state) {
        final outcome = availabilityFor(state);
        return DSSidebarRowGateData(
          rowId: rowId,
          denied: outcome.isDenied,
          reason: outcome.reason,
        );
      }

      final machine = ShellSlotMachine(
        initial: ReferenceShellCatalog.wideControlLayout(),
      );
      final rows = [
        const ShellRowGate(
          rowId: 'sessions',
          capability: CapabilityState.available('nav.sessions'),
        ),
        const ShellRowGate(
          rowId: 'control',
          capability: CapabilityState.missing('nav.control'),
        ),
      ];

      final gates = {
        for (final row in rows) row.rowId: project(row.rowId, row.capability),
      };

      expect(machine.enabledRows(rows), ['sessions']);
      expect(gates['sessions']!.denied, isFalse);
      expect(gates['control']!.denied, isTrue);
      expect(gates['control']!.reason, contains('nav.control'));
    });
  });
}
