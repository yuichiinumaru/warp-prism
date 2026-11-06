import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_interaction/src/command/command.dart';
import 'package:warp_prism_interaction/src/input/action_availability.dart';
import 'package:warp_prism_ui/src/organisms/command_palette/ds_command_palette.dart';
import 'package:warp_prism_ui/src/organisms/tool_strip_slideout/ds_tool_strip_slideout.dart';

// End-to-end disabled-reason propagation (Task 1870, F-03).
//
// Proves IDS eligibility ⇒ palette/tool-strip render: a registry intent
// denied by the frozen Task 1868 outcome type maps (at the composition site,
// mirroring the dev-dependency precedent of ids_kernel_consumer_proof_test)
// onto DSCommand.disabledReason / DSToolStripItem.disabledReason, renders
// disabled-with-reason (never hidden, never dispatching), announces via
// Semantics, and refuses via tap AND keyboard (Enter) with the same reason.
//
// Covers: visible reason line, semantics announcement, tap refusal (palette
// stays open), keyboard-only path (arrows + Enter), tool-strip disabled
// propagation, and the enabled-command control path.
//
// EXPERIMENTAL: imports IDS via src path + UI via src paths; no barrel
// reliance for the new surface. flutter_tester headless sweep.
// Run: flutter test packages/warp_prism_ui/test/organisms/command_disabled_reason_test.dart

/// Composition-site mapper: IDS intent + context ⇒ palette command.
///
/// This is the miniature binding the task's propagation path relies on:
/// eligibility stays IDS; the UI carries only the rendered reason.
DSCommand mapIntent(CommandIntent intent, CommandContext context) {
  final availability = intent.availabilityIn(context);
  return DSCommand(
    id: intent.id,
    label: intent.label,
    description: intent.description,
    shortcut: intent.chord?.displayString,
    disabledReason: availability is ActionDeny ? availability.reason : null,
  );
}

CommandRegistry fixtureRegistry() {
  final registry = CommandRegistry();
  registry.registerAll([
    const CommandIntent(
      id: 'theme.toggle',
      label: 'Toggle Theme',
      description: 'Switch themes',
      chord: CommandChord(ctrl: true, key: 't'),
    ),
    CommandIntent(
      id: 'deploy.promote',
      label: 'Promote Deploy',
      description: 'Promote the staged deploy',
      chord: const CommandChord(ctrl: true, key: 'd'),
      resolveAvailability: (context) => context.flag('deployer')
          ? const ActionAvailability.allow()
          : ActionAvailability.missing('deploy.promote'),
    ),
  ]);
  return registry;
}

void main() {
  group('IDS eligibility ⇒ palette propagation', () {
    testWidgets('denied command renders disabled with its visible reason', (
      tester,
    ) async {
      final commands = fixtureRegistry()
          .enumerate()
          .map((intent) => mapIntent(intent, const CommandContext()))
          .toList();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DSCommandPalette(commands: commands)),
        ),
      );

      expect(find.text('Promote Deploy'), findsOneWidget);
      expect(find.text('Missing capability: deploy.promote'), findsOneWidget);
      expect(find.text('Toggle Theme'), findsOneWidget);
    });

    testWidgets('disabled semantics announce label plus reason', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      final commands = fixtureRegistry()
          .enumerate()
          .map((intent) => mapIntent(intent, const CommandContext()))
          .toList();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DSCommandPalette(commands: commands)),
        ),
      );

      final semantics = tester.getSemantics(
        find.widgetWithText(InkWell, 'Promote Deploy'),
      );
      expect(semantics.flagsCollection.isEnabled, ui.Tristate.isFalse);
      expect(semantics.label, contains('Promote Deploy'));
      expect(semantics.label, contains('Missing capability: deploy.promote'));
      handle.dispose();
    });

    testWidgets('tap on disabled command refuses; palette stays open', (
      tester,
    ) async {
      String? executed;
      DSCommand? refused;
      var closed = false;
      final commands = fixtureRegistry()
          .enumerate()
          .map((intent) => mapIntent(intent, const CommandContext()))
          .toList();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DSCommandPalette(
              commands: commands,
              onExecute: (cmd) => executed = cmd.id,
              onDisabledCommand: (cmd) => refused = cmd,
              onClose: () => closed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Promote Deploy'));
      await tester.pump();

      expect(executed, isNull);
      expect(refused?.id, equals('deploy.promote'));
      expect(closed, isFalse);
    });

    testWidgets('keyboard-only path: arrows + Enter refuses disabled', (
      tester,
    ) async {
      String? executed;
      DSCommand? refused;
      var closed = false;
      final commands = fixtureRegistry()
          .enumerate()
          .map((intent) => mapIntent(intent, const CommandContext()))
          .toList();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DSCommandPalette(
              commands: commands,
              onExecute: (cmd) => executed = cmd.id,
              onDisabledCommand: (cmd) => refused = cmd,
              onClose: () => closed = true,
            ),
          ),
        ),
      );

      // Stable enumeration: deploy.promote sorts before theme.toggle, so the
      // disabled command is selected by default; Enter alone refuses it.
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(executed, isNull);
      expect(refused?.id, equals('deploy.promote'));
      expect(closed, isFalse);
    });

    testWidgets('keyboard-only path: arrows reach and execute enabled', (
      tester,
    ) async {
      String? executed;
      var closed = false;
      final commands = fixtureRegistry()
          .enumerate()
          .map((intent) => mapIntent(intent, const CommandContext()))
          .toList();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DSCommandPalette(
              commands: commands,
              onExecute: (cmd) => executed = cmd.id,
              onDisabledCommand: (_) => fail('must not refuse the enabled one'),
              onClose: () => closed = true,
            ),
          ),
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(executed, equals('theme.toggle'));
      expect(closed, isTrue);
    });

    testWidgets('allowed context renders no reason and dispatches', (
      tester,
    ) async {
      String? executed;
      final commands = fixtureRegistry()
          .enumerate()
          .map(
            (intent) =>
                mapIntent(intent, const CommandContext({'deployer': true})),
          )
          .toList();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DSCommandPalette(
              commands: commands,
              onExecute: (cmd) => executed = cmd.id,
            ),
          ),
        ),
      );

      expect(find.text('Missing capability: deploy.promote'), findsNothing);
      await tester.tap(find.text('Promote Deploy'));
      await tester.pump();
      expect(executed, equals('deploy.promote'));
    });
  });

  group('IDS eligibility ⇒ tool-strip propagation', () {
    List<DSToolStripItem> fixtureTools() => [
      DSToolStripItem(
        id: 'recon',
        icon: Icons.radar_outlined,
        label: 'Recon',
        builder: (_) => const Text('BODY_RECON'),
      ),
      const DSToolStripItem(
        id: 'deploy',
        icon: Icons.rocket_launch_outlined,
        label: 'Deploy',
        builder: _deployBody,
        disabledReason: 'Missing capability: deploy.promote',
      ),
    ];

    testWidgets('disabled tool announces reason and never opens', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      String? changedTo;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: Align(
                alignment: Alignment.centerRight,
                child: DSToolStripSlideout(
                  tools: fixtureTools(),
                  onActiveToolChanged: (id) => changedTo = id,
                ),
              ),
            ),
          ),
        ),
      );

      final semantics = tester.getSemantics(
        find.byKey(DSToolStripSlideout.toolButtonKey('deploy')),
      );
      expect(semantics.flagsCollection.isEnabled, ui.Tristate.isFalse);
      expect(semantics.label, contains('Deploy'));
      expect(semantics.label, contains('Missing capability: deploy.promote'));

      await tester.tap(find.byKey(DSToolStripSlideout.toolButtonKey('deploy')));
      await tester.pump();

      expect(changedTo, isNull);
      expect(find.byKey(DSToolStripSlideout.panelRegionKey), findsNothing);
      handle.dispose();
    });

    testWidgets('enabled tool still opens its panel', (tester) async {
      String? changedTo;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: Align(
                alignment: Alignment.centerRight,
                child: DSToolStripSlideout(
                  tools: fixtureTools(),
                  onActiveToolChanged: (id) => changedTo = id,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(DSToolStripSlideout.toolButtonKey('recon')));
      await tester.pump();

      expect(changedTo, equals('recon'));
      expect(find.text('BODY_RECON'), findsOneWidget);
    });
  });
}

Widget _deployBody(BuildContext context) => const Text('BODY_DEPLOY');
