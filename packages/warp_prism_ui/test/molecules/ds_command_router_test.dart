import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/src/molecules/ds_command_router.dart';
import 'package:warp_prism_ui/src/organisms/command_palette/ds_command_palette.dart';

// Conformance suite for the DSCommandRouter molecule (Task 1870, F-03).
//
// Proves: chord routing with smallest-id-wins precedence, disabled-reason
// refusal (never dispatch), edit-focus guard (bare keys suppressed while
// editing, modified chords still dispatch), unknown-chord observability,
// and canonical chord normalization parity with the IDS CommandChord.
//
// EXPERIMENTAL: imports the molecule via its src path; no barrel export yet.
// Run: flutter test packages/warp_prism_ui/test/molecules/ds_command_router_test.dart

void main() {
  List<DSCommand> fixtureCommands() => const [
    DSCommand(id: 'catalog.open', label: 'Open Catalog', shortcut: 'Ctrl+K'),
    DSCommand(
      id: 'workspace.search',
      label: 'Search Workspace',
      shortcut: 'ctrl+k',
    ),
    DSCommand(
      id: 'deploy.promote',
      label: 'Promote Deploy',
      shortcut: 'Ctrl+D',
      disabledReason: 'Missing capability: deploy.promote',
    ),
    DSCommand(id: 'theme.toggle', label: 'Toggle Theme', shortcut: 'Ctrl+T'),
  ];

  Widget harness({
    List<DSCommand>? commands,
    bool editingHasFocus = false,
    ValueChanged<DSCommand>? onDispatch,
    void Function(DSCommand command, String reason)? onRefused,
    ValueChanged<String>? onUnknownChord,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: DSCommandRouter(
          commands: commands ?? fixtureCommands(),
          editingHasFocus: editingHasFocus,
          onDispatch: onDispatch,
          onRefused: onRefused,
          onUnknownChord: onUnknownChord,
          child: const TextField(key: Key('router-probe-field')),
        ),
      ),
    );
  }

  Future<void> sendChord(
    WidgetTester tester,
    LogicalKeyboardKey modifier,
    LogicalKeyboardKey key,
  ) async {
    await tester.sendKeyDownEvent(modifier);
    await tester.sendKeyDownEvent(key);
    await tester.sendKeyUpEvent(key);
    await tester.sendKeyUpEvent(modifier);
    await tester.pump();
  }

  group('DSCommandRouter normalization parity', () {
    test('canonicalizes aliases and modifier order like IDS CommandChord', () {
      expect(DSCommandRouter.normalizeChordDisplay('Ctrl+K'), equals('ctrl+k'));
      expect(
        DSCommandRouter.normalizeChordDisplay(' ctrl + k '),
        equals('ctrl+k'),
      );
      expect(
        DSCommandRouter.normalizeChordDisplay('cmd+shift+p'),
        equals('meta+shift+p'),
      );
      expect(
        DSCommandRouter.normalizeChordDisplay('shift+ctrl+k'),
        equals('ctrl+shift+k'),
      );
      expect(DSCommandRouter.normalizeChordDisplay('Ctrl'), isNull);
      expect(DSCommandRouter.normalizeChordDisplay(''), isNull);
    });

    test('refusal announcements name the command and reason', () {
      const cmd = DSCommand(id: 'x', label: 'Promote Deploy');
      expect(
        DSCommandRouter.refusalAnnouncement(cmd, 'Nope'),
        equals('Promote Deploy. Refused: Nope'),
      );
    });
  });

  group('DSCommandRouter dispatch', () {
    testWidgets('modified chord dispatches the precedence winner', (
      tester,
    ) async {
      String? dispatched;
      await tester.pumpWidget(
        harness(onDispatch: (cmd) => dispatched = cmd.id),
      );

      await sendChord(
        tester,
        LogicalKeyboardKey.controlLeft,
        LogicalKeyboardKey.keyK,
      );

      // ctrl+k is contested; smallest id wins.
      expect(dispatched, equals('catalog.open'));
    });

    testWidgets('disabled command refuses with its reason, never dispatches', (
      tester,
    ) async {
      String? dispatched;
      DSCommand? refusedCmd;
      String? refusedReason;
      await tester.pumpWidget(
        harness(
          onDispatch: (cmd) => dispatched = cmd.id,
          onRefused: (cmd, reason) {
            refusedCmd = cmd;
            refusedReason = reason;
          },
        ),
      );

      await sendChord(
        tester,
        LogicalKeyboardKey.controlLeft,
        LogicalKeyboardKey.keyD,
      );

      expect(dispatched, isNull);
      expect(refusedCmd?.id, equals('deploy.promote'));
      expect(refusedReason, equals('Missing capability: deploy.promote'));
    });

    testWidgets('unknown chords are observed, never dispatched', (
      tester,
    ) async {
      String? dispatched;
      String? unknown;
      await tester.pumpWidget(
        harness(
          onDispatch: (cmd) => dispatched = cmd.id,
          onUnknownChord: (chord) => unknown = chord,
        ),
      );

      await sendChord(
        tester,
        LogicalKeyboardKey.controlLeft,
        LogicalKeyboardKey.keyZ,
      );

      expect(dispatched, isNull);
      expect(unknown, equals('ctrl+z'));
    });

    testWidgets('bare key while editing refuses via the focus guard', (
      tester,
    ) async {
      String? dispatched;
      String? refusedReason;
      await tester.pumpWidget(
        harness(
          commands: const [
            DSCommand(id: 'select.all', label: 'Select All', shortcut: 'a'),
          ],
          editingHasFocus: true,
          onDispatch: (cmd) => dispatched = cmd.id,
          onRefused: (_, reason) => refusedReason = reason,
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
      await tester.pump();

      expect(dispatched, isNull);
      expect(refusedReason, contains('Editing has focus'));
    });

    testWidgets('modified chords still dispatch while editing', (tester) async {
      String? dispatched;
      await tester.pumpWidget(
        harness(
          editingHasFocus: true,
          onDispatch: (cmd) => dispatched = cmd.id,
        ),
      );

      await sendChord(
        tester,
        LogicalKeyboardKey.controlLeft,
        LogicalKeyboardKey.keyK,
      );

      expect(dispatched, equals('catalog.open'));
    });

    testWidgets('bare key dispatches when editing does not have focus', (
      tester,
    ) async {
      String? dispatched;
      await tester.pumpWidget(
        harness(
          commands: const [
            DSCommand(id: 'select.all', label: 'Select All', shortcut: 'a'),
          ],
          onDispatch: (cmd) => dispatched = cmd.id,
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
      await tester.pump();

      expect(dispatched, equals('select.all'));
    });
  });
}
