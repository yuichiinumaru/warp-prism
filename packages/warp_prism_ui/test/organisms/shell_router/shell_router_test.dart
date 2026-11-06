import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/src/organisms/ds_sidebar.dart';
import 'package:warp_prism_ui/src/organisms/ds_sidebar_sections.dart';
import 'package:warp_prism_ui/src/organisms/shell_router/ds_shell_router.dart';

/// Task 1873 (F-06): PrismShellRouter + focus-restoration suite.
///
/// Proves layout transitions return focus to the committed token, with
/// refocus/scroll_to edge cases, over DSShell + SplitPane.
void main() {
  DSShellRouterLayout layoutFor(String active, {String? trailing}) {
    Widget pane(String label) => SizedBox(
      height: 1200,
      child: Text('pane:$label', key: ValueKey('pane:$label')),
    );
    return DSShellRouterLayout(
      sidebar: DSSidebarSections(
        sections: const [
          DSSidebarSection(
            id: 'nav',
            title: 'Navigate',
            rows: [
              DSSidebarItem(id: 'sessions', label: 'Sessions'),
              DSSidebarItem(id: 'control', label: 'Control'),
            ],
          ),
        ],
        selectedId: active,
      ),
      contentPanes: {'sessions': pane('sessions'), 'control': pane('control')},
      activeContentPane: active,
      trailingContentPane: trailing,
    );
  }

  Widget harness({
    required DSShellRouterLayout layout,
    required DSFocusReturnToken token,
    ValueChanged<String>? onRestored,
    double? scrollEdge,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 1400,
          height: 900,
          child: DSShellRouter(
            layout: layout,
            focusToken: token,
            scrollEdgeOffset: scrollEdge,
            onFocusRestored: onRestored,
          ),
        ),
      ),
    );
  }

  group('DSShellRouter focus restoration (committed token)', () {
    testWidgets('layout transition returns focus to committed token pane', (
      tester,
    ) async {
      var restored = <String>[];
      await tester.pumpWidget(
        harness(
          layout: layoutFor('sessions'),
          token: const DSFocusReturnToken(
            paneId: 'sessions',
            slot: DSShellSlot.content,
          ),
          onRestored: restored.add,
        ),
      );
      await tester.pumpAndSettle();
      restored.clear();

      await tester.pumpWidget(
        harness(
          layout: layoutFor('control'),
          token: const DSFocusReturnToken(
            paneId: 'control',
            slot: DSShellSlot.content,
          ),
          onRestored: restored.add,
        ),
      );
      await tester.pumpAndSettle();

      expect(restored, contains('control'));
      expect(find.text('pane:control'), findsOneWidget);
    });

    testWidgets('removed token pane invents no focus target', (tester) async {
      var restored = <String>[];
      await tester.pumpWidget(
        harness(
          layout: layoutFor('sessions'),
          token: const DSFocusReturnToken(
            paneId: 'ghost-pane',
            slot: DSShellSlot.content,
          ),
          onRestored: restored.add,
        ),
      );
      await tester.pumpAndSettle();

      expect(restored, isEmpty);
      expect(find.text('pane:sessions'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('empty token never requests focus', (tester) async {
      var restored = <String>[];
      await tester.pumpWidget(
        harness(
          layout: layoutFor('sessions'),
          token: const DSFocusReturnToken(paneId: ''),
          onRestored: restored.add,
        ),
      );
      await tester.pumpAndSettle();

      expect(restored, isEmpty);
      expect(tester.takeException(), isNull);
    });

    testWidgets('split panes render leading + trailing with token focus', (
      tester,
    ) async {
      var restored = <String>[];
      await tester.pumpWidget(
        harness(
          layout: layoutFor('sessions', trailing: 'control'),
          token: const DSFocusReturnToken(paneId: 'sessions'),
          onRestored: restored.add,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('pane:sessions'), findsOneWidget);
      expect(find.text('pane:control'), findsOneWidget);
      expect(restored, contains('sessions'));
    });

    testWidgets('scroll edge applies without framework errors', (tester) async {
      await tester.pumpWidget(
        harness(
          layout: layoutFor('sessions'),
          token: const DSFocusReturnToken(paneId: 'sessions'),
          scrollEdge: 400,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('pane:sessions'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('same layout + same token restores deterministically', (
      tester,
    ) async {
      var first = <String>[];
      await tester.pumpWidget(
        harness(
          layout: layoutFor('control'),
          token: const DSFocusReturnToken(paneId: 'control'),
          onRestored: first.add,
        ),
      );
      await tester.pumpAndSettle();
      expect(first, contains('control'));
      expect(
        FocusManager.instance.primaryFocus?.debugLabel,
        'shell-router:control',
      );

      // Same token re-committed: idempotent — no redundant restore, focus
      // stays on the committed pane (state preserved across the rebuild).
      var second = <String>[];
      await tester.pumpWidget(
        harness(
          layout: layoutFor('control'),
          token: const DSFocusReturnToken(paneId: 'control'),
          onRestored: second.add,
        ),
      );
      await tester.pumpAndSettle();
      expect(second, isEmpty);
      expect(
        FocusManager.instance.primaryFocus?.debugLabel,
        'shell-router:control',
      );

      // And the transition back through another pane reproduces the token.
      var third = <String>[];
      await tester.pumpWidget(
        harness(
          layout: layoutFor('sessions'),
          token: const DSFocusReturnToken(paneId: 'sessions'),
          onRestored: third.add,
        ),
      );
      await tester.pumpAndSettle();
      await tester.pumpWidget(
        harness(
          layout: layoutFor('control'),
          token: const DSFocusReturnToken(paneId: 'control'),
          onRestored: third.add,
        ),
      );
      await tester.pumpAndSettle();
      expect(third, contains('control'));
    });
  });
}
