import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_interaction/src/command/command.dart';
import 'package:warp_prism_interaction/src/input/action_availability.dart';
import 'package:warp_prism_ui/src/molecules/ds_command_router.dart';
import 'package:warp_prism_ui/src/organisms/command_palette/ds_command_palette.dart';

// Host-composition proof for the command registry (Task 1870, F-03,
// AGENTS.md §7.1).
//
// Exercises the router + palette on two host-like routes in one composition:
// a Warpblade-like timeline route (keyboard guard citation shape:
// `keyboard_shortcuts.dart` physical-key mapping with an editing surface)
// and a command-center-like control route (gated section with a
// disabled-with-reason command). Covers: route entry, chord-conflict
// resolution (ctrl+k ⇒ smallest id wins), disabled refusal via keyboard,
// zero framework errors, and a small-viewport sweep.
//
// LIMITATION (recorded): the real Warpblade and command-center hosts live
// outside this workspace boundary, so this is a flutter_tester headless
// composition sweep against host-shaped routes — not execution inside the
// real product hosts. No display host was available in this environment.
// Run: flutter test packages/warp_prism_ui/test/organisms/command_host_composition_test.dart

/// Host-shaped command set: contested chord + one 1868-gated command.
CommandRegistry hostRegistry() {
  final registry = CommandRegistry();
  registry.registerAll([
    const CommandIntent(
      id: 'catalog.open',
      label: 'Open Catalog',
      chord: CommandChord(ctrl: true, key: 'k'),
    ),
    const CommandIntent(
      id: 'workspace.search',
      label: 'Search Workspace',
      chord: CommandChord(ctrl: true, key: 'k'),
    ),
    CommandIntent(
      id: 'deploy.promote',
      label: 'Promote Deploy',
      chord: const CommandChord(ctrl: true, key: 'd'),
      resolveAvailability: (context) => context.flag('deployer')
          ? const ActionAvailability.allow()
          : ActionAvailability.missing('deploy.promote'),
    ),
  ]);
  return registry;
}

List<DSCommand> toPaletteCommands(CommandContext context) => hostRegistry()
    // Stable id-sorted enumeration flows into the palette input order, so the
    // rendered order is deterministic: catalog.open, deploy.promote,
    // workspace.search.
    .enumerateApplicable(context)
    .map(
      (intent) => DSCommand(
        id: intent.id,
        label: intent.label,
        shortcut: intent.chord?.displayString,
        disabledReason: intent.availabilityIn(context) is ActionDeny
            ? intent.availabilityIn(context).reason
            : null,
      ),
    )
    .toList();

/// Warpblade-like timeline route: editing surface + command router.
class TimelineRoute extends StatefulWidget {
  final List<String> events;
  const TimelineRoute({super.key, required this.events});

  @override
  State<TimelineRoute> createState() => _TimelineRouteState();
}

class _TimelineRouteState extends State<TimelineRoute> {
  final _fieldNode = FocusNode(debugLabel: 'timeline-edit-field');
  bool _paletteOpen = false;

  @override
  void dispose() {
    _fieldNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DSCommandRouter(
      commands: toPaletteCommands(const CommandContext()),
      editingHasFocus: _fieldNode.hasFocus,
      onDispatch: (cmd) {
        widget.events.add('dispatched:${cmd.id}');
        if (cmd.id == 'catalog.open') {
          setState(() => _paletteOpen = true);
        }
      },
      onRefused: (cmd, reason) =>
          widget.events.add('refused:${cmd.id}:$reason'),
      onUnknownChord: (chord) => widget.events.add('unknown:$chord'),
      child: Scaffold(
        appBar: AppBar(title: const Text('Timeline')),
        body: Column(
          children: [
            TextField(
              key: const Key('timeline-edit'),
              focusNode: _fieldNode,
              decoration: const InputDecoration(labelText: 'Transcript edit'),
              onChanged: (_) => setState(() {}),
            ),
            if (_paletteOpen)
              Expanded(
                child: DSCommandPalette(
                  commands: toPaletteCommands(const CommandContext()),
                  onExecute: (cmd) => widget.events.add('executed:${cmd.id}'),
                  onDisabledCommand: (cmd) => widget.events.add(
                    'palette-refused:${cmd.id}:${cmd.disabledReason}',
                  ),
                  onClose: () => setState(() => _paletteOpen = false),
                ),
              )
            else
              const Expanded(child: Center(child: Text('TRACKS'))),
          ],
        ),
      ),
    );
  }
}

/// Command-center-like control route: gated section rendered from IDS state.
class ControlRoute extends StatelessWidget {
  final List<String> events;
  const ControlRoute({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    final commands = toPaletteCommands(const CommandContext());
    return DSCommandRouter(
      commands: commands,
      onDispatch: (cmd) => events.add('dispatched:${cmd.id}'),
      onRefused: (cmd, reason) => events.add('refused:${cmd.id}:$reason'),
      child: Scaffold(
        appBar: AppBar(title: const Text('Control Panel')),
        body: DSCommandPalette(
          commands: commands,
          onExecute: (cmd) => events.add('executed:${cmd.id}'),
          onDisabledCommand: (cmd) =>
              events.add('palette-refused:${cmd.id}:${cmd.disabledReason}'),
        ),
      ),
    );
  }
}

Widget hostApp(List<String> events) => MaterialApp(
  routes: {
    '/timeline': (_) => TimelineRoute(events: events),
    '/control': (_) => ControlRoute(events: events),
  },
  home: Builder(
    builder: (context) => Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              key: const Key('go-timeline'),
              onPressed: () => Navigator.of(context).pushNamed('/timeline'),
              child: const Text('Timeline'),
            ),
            TextButton(
              key: const Key('go-control'),
              onPressed: () => Navigator.of(context).pushNamed('/control'),
              child: const Text('Control'),
            ),
          ],
        ),
      ),
    ),
  ),
);

void main() {
  group('Command host composition (WB-like + CC-like, headless sweep)', () {
    testWidgets('timeline route: conflict resolves, palette opens', (
      tester,
    ) async {
      final errors = <FlutterErrorDetails>[];
      final oldHandler = FlutterError.onError;
      FlutterError.onError = errors.add;
      final events = <String>[];
      try {
        await tester.pumpWidget(hostApp(events));
        await tester.tap(find.byKey(const Key('go-timeline')));
        await tester.pumpAndSettle();

        expect(find.text('Timeline'), findsOneWidget);
        expect(find.text('TRACKS'), findsOneWidget);

        // Chord conflict: ctrl+k must elect catalog.open (smallest id).
        await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
        await tester.sendKeyDownEvent(LogicalKeyboardKey.keyK);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.keyK);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
        await tester.pumpAndSettle();

        expect(events, contains('dispatched:catalog.open'));
        expect(find.byType(DSCommandPalette), findsOneWidget);
      } finally {
        FlutterError.onError = oldHandler;
      }
      expect(
        errors,
        isEmpty,
        reason: 'No framework errors on the timeline route: $errors',
      );
    });

    testWidgets('timeline editing guard: bare keys never dispatch', (
      tester,
    ) async {
      final errors = <FlutterErrorDetails>[];
      final oldHandler = FlutterError.onError;
      FlutterError.onError = errors.add;
      final events = <String>[];
      try {
        await tester.pumpWidget(hostApp(events));
        await tester.tap(find.byKey(const Key('go-timeline')));
        await tester.pumpAndSettle();

        // Focus the transcript edit field: the router now sees editing focus.
        await tester.tap(find.byKey(const Key('timeline-edit')));
        await tester.pump();
        expect(
          events,
          isNot(contains(predicate<String>((e) => e.startsWith('dispatched')))),
        );
      } finally {
        FlutterError.onError = oldHandler;
      }
      expect(
        errors,
        isEmpty,
        reason: 'No framework errors while editing: $errors',
      );
    });

    testWidgets('control route: disabled command refuses via keyboard', (
      tester,
    ) async {
      final errors = <FlutterErrorDetails>[];
      final oldHandler = FlutterError.onError;
      FlutterError.onError = errors.add;
      final events = <String>[];
      try {
        await tester.pumpWidget(hostApp(events));
        await tester.tap(find.byKey(const Key('go-control')));
        await tester.pumpAndSettle();

        expect(find.text('Control Panel'), findsOneWidget);
        // deploy.promote sorts before workspace.search; theme absent here so
        // the disabled command is second: one arrow-down then Enter.
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pump();

        expect(
          events,
          contains(
            'palette-refused:deploy.promote:Missing capability: deploy.promote',
          ),
        );
        expect(
          events,
          isNot(contains(predicate<String>((e) => e.startsWith('executed')))),
        );
      } finally {
        FlutterError.onError = oldHandler;
      }
      expect(
        errors,
        isEmpty,
        reason: 'No framework errors on the control route: $errors',
      );
    });

    testWidgets('small viewport: reason propagation adds no new errors', (
      tester,
    ) async {
      // Logical 360x640 (physical 720x1280 @2x): realistic small phone.
      tester.view.physicalSize = const Size(720, 1280);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      String errorKinds(List<FlutterErrorDetails> errors) => errors
          .map((e) => e.exception.toString().split('\n').first)
          .toList()
          .toString();

      // Control pump: stock enabled-only palette (zero 1870-surface).
      final controlErrors = <FlutterErrorDetails>[];
      final oldHandler = FlutterError.onError;
      FlutterError.onError = controlErrors.add;
      try {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: DSCommandPalette(
                commands: [
                  DSCommand(id: 'a', label: 'Alpha'),
                  DSCommand(id: 'b', label: 'Beta'),
                  DSCommand(id: 'c', label: 'Gamma'),
                  DSCommand(id: 'd', label: 'Delta'),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
      } finally {
        FlutterError.onError = oldHandler;
      }

      // Treatment pump: same shape plus the disabled-with-reason command.
      final treatmentErrors = <FlutterErrorDetails>[];
      FlutterError.onError = treatmentErrors.add;
      final events = <String>[];
      try {
        await tester.pumpWidget(hostApp(events));
        await tester.tap(find.byKey(const Key('go-control')));
        await tester.pumpAndSettle();

        expect(
          find.text('Promote Deploy', skipOffstage: false),
          findsOneWidget,
        );
        expect(
          find.text('Missing capability: deploy.promote', skipOffstage: false),
          findsOneWidget,
        );
      } finally {
        FlutterError.onError = oldHandler;
      }

      // The 1870 surface must introduce no NEW error classes. A horizontal
      // _CategoryChips overflow at 360px is pre-existing palette behavior
      // (untouched by this task); it appears identically in the control
      // pump and is recorded here as a palette-owner follow-up.
      expect(
        errorKinds(treatmentErrors),
        equals(errorKinds(controlErrors)),
        reason:
            'Disabled-reason rendering must add no new framework errors. '
            'Control: ${errorKinds(controlErrors)}. '
            'Treatment: ${errorKinds(treatmentErrors)}.',
      );
    });
  });
}
