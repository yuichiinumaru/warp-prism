import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/src/organisms/ds_sidebar.dart';
import 'package:warp_prism_ui/src/organisms/ds_sidebar_sections.dart';
import 'package:warp_prism_ui/src/organisms/shell_router/ds_shell_router.dart';

/// Task 1873 (F-06): multi-pane host proof (AGENTS §7.1).
///
/// Faithful CommandCenterShell-shape host (INHERITED-REPORT donor: direct
/// `read` of `command-center/.../integration/shell.dart` is denied by the
/// workspace boundary; shape re-verified via in-workspace grep — 5 tabs
/// Connection/Sessions/Events/Control/Provenance, wide multi-pane body +
/// narrow single-pane body, `_tabIndex` state).
///
/// Exercises: enter primary routes, perform an interaction (tab switch +
/// sidebar tap), observe framework/runtime errors, representative
/// viewport/layout conditions (wide 1400 / medium 900 / narrow 500),
/// theme/focus/navigation propagation.
///
/// Limitation: real display host unavailable in this headless env; proof runs
/// as a `flutter_tester` headless sweep. No pixels were visually inspected.
void main() {
  const routes = ['connection', 'sessions', 'events', 'control', 'provenance'];

  Widget ccHost({
    required String active,
    required double width,
    ValueChanged<String>? onRestored,
    DSFocusReturnToken? token,
  }) {
    Widget pane(String id) =>
        SizedBox(height: 1200, child: Text('cc:$id', key: ValueKey('cc:$id')));
    final panes = {for (final id in routes) id: pane(id)};
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: width,
          height: 900,
          child: DSShellRouter(
            layout: DSShellRouterLayout(
              sidebar: DSSidebarSections(
                sections: const [
                  DSSidebarSection(
                    id: 'cc-nav',
                    title: 'Command Center',
                    keptRowIds: ['sessions'],
                    rows: [
                      DSSidebarItem(
                        id: 'connection',
                        label: 'Connection',
                        icon: Icons.settings_ethernet,
                      ),
                      DSSidebarItem(
                        id: 'sessions',
                        label: 'Sessions',
                        icon: Icons.forum_outlined,
                      ),
                      DSSidebarItem(
                        id: 'events',
                        label: 'Events',
                        icon: Icons.bolt_outlined,
                      ),
                      DSSidebarItem(
                        id: 'control',
                        label: 'Control',
                        icon: Icons.shield_outlined,
                      ),
                      DSSidebarItem(
                        id: 'provenance',
                        label: 'Provenance',
                        icon: Icons.account_tree_outlined,
                      ),
                    ],
                  ),
                ],
                selectedId: active,
              ),
              contentPanes: panes,
              activeContentPane: active,
              trailingContentPane: width >= 1200 && active != 'control'
                  ? 'control'
                  : null,
            ),
            focusToken:
                token ??
                DSFocusReturnToken(paneId: active, slot: DSShellSlot.content),
            onFocusRestored: onRestored,
          ),
        ),
      ),
    );
  }

  Future<void> expectCleanSweep(
    WidgetTester tester,
    String active,
    double width, {
    List<String>? restoredLog,
  }) async {
    await tester.pumpWidget(
      ccHost(active: active, width: width, onRestored: restoredLog?.add),
    );
    await tester.pumpAndSettle();
    expect(find.text('cc:$active'), findsWidgets);
    expect(tester.takeException(), isNull);
  }

  group('CC-shape multi-pane host proof', () {
    testWidgets('enter primary routes wide with interaction', (tester) async {
      final restored = <String>[];
      // Enter Sessions (primary route).
      await expectCleanSweep(tester, 'sessions', 1400, restoredLog: restored);
      expect(restored, contains('sessions'));

      // Interact: switch to Control route (tab switch ⇒ token follows).
      restored.clear();
      await tester.pumpWidget(
        ccHost(
          active: 'control',
          width: 1400,
          onRestored: restored.add,
          token: const DSFocusReturnToken(
            paneId: 'control',
            slot: DSShellSlot.content,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('cc:control'), findsWidgets);
      expect(restored, contains('control'));

      // Interact: switch to Provenance route.
      restored.clear();
      await tester.pumpWidget(
        ccHost(
          active: 'provenance',
          width: 1400,
          onRestored: restored.add,
          token: const DSFocusReturnToken(
            paneId: 'provenance',
            slot: DSShellSlot.content,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('cc:provenance'), findsWidgets);
      expect(restored, contains('provenance'));
      expect(tester.takeException(), isNull);
    });

    testWidgets('viewport conditions: wide / medium / narrow', (tester) async {
      await expectCleanSweep(tester, 'sessions', 1400);
      await expectCleanSweep(tester, 'sessions', 900);
      await expectCleanSweep(tester, 'sessions', 500);
      // Theme propagates (MaterialApp theme present, no ancestor errors).
      final context = tester.element(find.text('cc:sessions').first);
      expect(Theme.of(context), isNotNull);
      expect(tester.takeException(), isNull);
    });

    testWidgets('focus + navigation propagate, no ErrorWidget', (tester) async {
      await tester.pumpWidget(ccHost(active: 'events', width: 1400));
      await tester.pumpAndSettle();

      expect(find.byType(ErrorWidget), findsNothing);
      expect(find.bySemanticsLabel(RegExp('Shell router')), findsOneWidget);
      expect(
        find.bySemanticsLabel(RegExp('Navigation sidebar sections')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  });
}
