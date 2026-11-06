// Conformance suite for the IDS command registry (Task 1870, F-03).
//
// Proves: stable enumeration (same content ⇒ same order), chord-collision
// determinism (smallest id wins), disabled-reason propagation via the frozen
// Task 1868 outcome type, edit-focus guard, keyboard-chord normalization,
// Figcraft-style describe() shape, and the reference catalog fixture.
//
// EXPERIMENTAL: imports the module via its src/command/ path; no barrel
// export yet. Run: flutter test packages/warp_prism_interaction/test/command_registry_test.dart

import 'package:test/test.dart';
import 'package:warp_prism_interaction/src/command/command.dart';
import 'package:warp_prism_interaction/src/input/action_availability.dart';

void main() {
  group('CommandChord normalization', () {
    test('parse is case-insensitive and whitespace-tolerant', () {
      expect(
        CommandChord.parse('Ctrl+K'),
        equals(CommandChord.parse(' ctrl + k ')),
      );
      expect(CommandChord.parse('CTRL+K').normalized, equals('ctrl+k'));
    });

    test('modifier aliases converge to the canonical form', () {
      expect(CommandChord.parse('control+k').normalized, equals('ctrl+k'));
      expect(
        CommandChord.parse('cmd+shift+p').normalized,
        equals('meta+shift+p'),
      );
      expect(CommandChord.parse('command+p').normalized, equals('meta+p'));
      expect(CommandChord.parse('opt+x').normalized, equals('alt+x'));
      expect(CommandChord.parse('option+x').normalized, equals('alt+x'));
    });

    test('modifier order is canonical regardless of input order', () {
      expect(
        CommandChord.parse('shift+ctrl+k').normalized,
        equals('ctrl+shift+k'),
      );
      expect(
        CommandChord.parse('alt+meta+ctrl+shift+x').normalized,
        equals('ctrl+meta+alt+shift+x'),
      );
    });

    test('chords without a key are rejected', () {
      expect(() => CommandChord.parse(''), throwsArgumentError);
      expect(() => CommandChord.parse('ctrl+shift'), throwsArgumentError);
    });

    test('bare printable keys are detected for the edit-focus guard', () {
      expect(const CommandChord(key: 'a').isBareKey, isTrue);
      expect(const CommandChord(ctrl: true, key: 'a').isBareKey, isFalse);
      expect(const CommandChord(key: 'enter').isBareKey, isFalse);
    });

    test('display strings round-trip through parse', () {
      const chord = CommandChord(ctrl: true, shift: true, key: 'a');
      expect(CommandChord.parse(chord.displayString), equals(chord));
    });
  });

  group('CommandRegistry enumeration stability', () {
    test('enumerate is id-sorted regardless of registration order', () {
      final reversed = CommandRegistry()
        ..registerAll(ReferenceCommandCatalog.build().enumerate().reversed);
      final forward = ReferenceCommandCatalog.build();
      expect(
        reversed.enumerate().map((c) => c.id),
        equals(forward.enumerate().map((c) => c.id)),
      );
    });

    test('repeated enumeration of one registry is identical', () {
      final registry = ReferenceCommandCatalog.build();
      final first = registry.enumerate().map((c) => c.id).toList();
      final second = registry.enumerate().map((c) => c.id).toList();
      expect(second, equals(first));
      expect(
        first,
        equals([
          'catalog.open',
          'session.abort',
          'theme.toggle',
          'workspace.search',
        ]),
      );
    });

    test('duplicate ids are rejected, never silently overwritten', () {
      final registry = ReferenceCommandCatalog.build();
      expect(
        () => registry.register(
          const CommandIntent(id: 'catalog.open', label: 'Duplicate'),
        ),
        throwsStateError,
      );
      expect(registry.byId('catalog.open')?.label, equals('Open Catalog'));
    });
  });

  group('Chord collision determinism', () {
    test('contested chord resolves to the smallest id', () {
      final registry = ReferenceCommandCatalog.build();
      final resolution = registry.resolveChord('ctrl+k');
      expect(resolution.matched, isTrue);
      expect(resolution.winner?.id, equals('catalog.open'));
      expect(resolution.shadowedIds, equals(['workspace.search']));
    });

    test('collision report is deterministic and sorted', () {
      final first = ReferenceCommandCatalog.build().collisions();
      final second = ReferenceCommandCatalog.build().collisions();
      expect(first, equals(second));
      expect(first.length, equals(1));
      expect(first.single.chord, equals('ctrl+k'));
      expect(first.single.winnerId, equals('catalog.open'));
      expect(first.single.shadowedIds, equals(['workspace.search']));
    });

    test('unmatched chords resolve to no match', () {
      final registry = ReferenceCommandCatalog.build();
      final resolution = registry.resolveChord('ctrl+z');
      expect(resolution.matched, isFalse);
      expect(resolution.winner, isNull);
      expect(resolution.contested, isFalse);
    });

    test('registration order does not change the winner', () {
      final registry = CommandRegistry()
        ..register(
          const CommandIntent(
            id: 'workspace.search',
            label: 'Search Workspace',
            chord: CommandChord(ctrl: true, key: 'k'),
          ),
        )
        ..register(
          const CommandIntent(
            id: 'catalog.open',
            label: 'Open Catalog',
            chord: CommandChord(ctrl: true, key: 'k'),
          ),
        );
      expect(
        registry.resolveChord('ctrl+k').winner?.id,
        equals('catalog.open'),
      );
    });
  });

  group('Applicability and 1868 availability', () {
    test('not-applicable commands filter out of enumerateApplicable', () {
      final registry = CommandRegistry()
        ..register(
          CommandIntent(
            id: 'route.only',
            label: 'Route Only',
            isApplicable: (context) => context.value<String>('route') == 'map',
          ),
        );
      expect(
        registry.enumerateApplicable(const CommandContext()).length,
        equals(0),
      );
      expect(
        registry
            .enumerateApplicable(const CommandContext({'route': 'map'}))
            .length,
        equals(1),
      );
    });

    test('availability defaults to allow without a resolver', () {
      const intent = CommandIntent(id: 'plain', label: 'Plain');
      expect(
        intent.availabilityIn(const CommandContext()),
        equals(const ActionAvailability.allow()),
      );
    });

    test('deny outcome carries the frozen 1868 reason verbatim', () {
      final registry = ReferenceCommandCatalog.buildWithGated();
      final gated = registry.byId('deploy.promote')!;
      final denied = gated.availabilityIn(const CommandContext());
      expect(denied.isDenied, isTrue);
      expect(denied.reason, contains('deploy.promote'));

      final allowed = gated.availabilityIn(
        const CommandContext({'deployer': true}),
      );
      expect(allowed.isAllowed, isTrue);
    });

    test('constrain outcome propagates its limitation', () {
      final intent = CommandIntent(
        id: 'limited',
        label: 'Limited',
        resolveAvailability: (_) =>
            ActionAvailability.constrain('Read-only session'),
      );
      final outcome = intent.availabilityIn(const CommandContext());
      expect(outcome.isConstrained, isTrue);
      expect(outcome.reason, equals('Read-only session'));
    });
  });

  group('CommandRouter', () {
    test('routes an allowed chord to dispatch', () {
      final registry = ReferenceCommandCatalog.build();
      final route = CommandRouter.route(registry, 'ctrl+t');
      expect(route, isA<CommandDispatch>());
      expect((route as CommandDispatch).intent.id, equals('theme.toggle'));
    });

    test('routes unknown chords to a noMatch refusal', () {
      final registry = ReferenceCommandCatalog.build();
      final route = CommandRouter.route(registry, 'ctrl+z');
      expect(route, isA<CommandRefusal>());
      final refusal = route as CommandRefusal;
      expect(refusal.kind, equals(CommandRefusalKind.noMatch));
      expect(refusal.reason, isNotEmpty);
    });

    test('denied commands refuse with the 1868 reason', () {
      final registry = ReferenceCommandCatalog.buildWithGated();
      final route = CommandRouter.route(registry, 'ctrl+d');
      expect(route, isA<CommandRefusal>());
      final refusal = route as CommandRefusal;
      expect(refusal.kind, equals(CommandRefusalKind.denied));
      expect(refusal.commandId, equals('deploy.promote'));
      expect(refusal.reason, contains('deploy.promote'));
    });

    test('allowed context dispatches the gated command', () {
      final registry = ReferenceCommandCatalog.buildWithGated();
      final route = CommandRouter.route(
        registry,
        'ctrl+d',
        context: const CommandContext({'deployer': true}),
      );
      expect(route, isA<CommandDispatch>());
      expect((route as CommandDispatch).intent.id, equals('deploy.promote'));
    });

    test('not-applicable winners refuse as notApplicable', () {
      final registry = CommandRegistry()
        ..register(
          CommandIntent(
            id: 'route.only',
            label: 'Route Only',
            chord: const CommandChord(ctrl: true, key: 'r'),
            isApplicable: (context) => context.flag('onRoute'),
          ),
        );
      final route = CommandRouter.route(registry, 'ctrl+r');
      expect(route, isA<CommandRefusal>());
      expect(
        (route as CommandRefusal).kind,
        equals(CommandRefusalKind.notApplicable),
      );
    });

    test('edit-focus guard suppresses bare keys while editing', () {
      final registry = CommandRegistry()
        ..register(
          const CommandIntent(
            id: 'select.all',
            label: 'Select All',
            chord: CommandChord(key: 'a'),
          ),
        );
      final suppressed = CommandRouter.route(
        registry,
        'a',
        editingHasFocus: true,
      );
      expect(suppressed, isA<CommandRefusal>());
      final refusal = suppressed as CommandRefusal;
      expect(refusal.kind, equals(CommandRefusalKind.editingFocus));
      expect(refusal.reason, contains('Editing has focus'));

      final typed = CommandRouter.route(registry, 'a');
      expect(typed, isA<CommandDispatch>());
    });

    test('modified chords still dispatch while editing', () {
      final registry = ReferenceCommandCatalog.build();
      final route = CommandRouter.route(
        registry,
        'ctrl+k',
        editingHasFocus: true,
      );
      expect(route, isA<CommandDispatch>());
      expect(
        (route as CommandDispatch).shadowedIds,
        equals(['workspace.search']),
      );
    });

    test('contested chords carry shadowed ids on dispatch', () {
      final registry = ReferenceCommandCatalog.build();
      final route = CommandRouter.route(registry, 'ctrl+k');
      final dispatch = route as CommandDispatch;
      expect(dispatch.intent.id, equals('catalog.open'));
      expect(dispatch.shadowedIds, equals(['workspace.search']));
    });
  });

  group('describe() self-documentation seam', () {
    test('intent describe carries the donor-A2 shape', () {
      const intent = CommandIntent(
        id: 'catalog.open',
        label: 'Open Catalog',
        chord: CommandChord(ctrl: true, key: 'k'),
      );
      final described = intent.describe();
      expect(described['id'], equals('catalog.open'));
      expect(described['label'], equals('Open Catalog'));
      expect(described['chord'], equals('ctrl+k'));
      expect(described, contains('description'));
      expect(described, contains('hasApplicability'));
      expect(described, contains('hasAvailabilityResolver'));
    });

    test('registry describe enumerates stably with indices and collisions', () {
      final first = ReferenceCommandCatalog.build().describe();
      final second = ReferenceCommandCatalog.build().describe();
      expect(second, equals(first));

      expect(first['count'], equals(4));
      final commands = first['commands'] as List;
      expect(commands.length, equals(4));
      expect((commands.first as Map)['index'], equals(0));
      final collisions = first['collisions'] as List;
      expect(collisions.length, equals(1));
      expect((collisions.single as Map)['winnerId'], equals('catalog.open'));
    });

    test('contextual describe adds applicability and availability', () {
      final registry = ReferenceCommandCatalog.buildWithGated();
      final described = registry.describe(const CommandContext());
      final commands = described['commands'] as List;
      final gated = (commands.cast<Map<String, Object?>>()).firstWhere(
        (entry) => entry['id'] == 'deploy.promote',
      );
      expect(gated['applicable'], isTrue);
      expect(gated['availability'], equals('deny'));
      expect((gated['reason'] as String?) ?? '', contains('deploy.promote'));
    });
  });
}
