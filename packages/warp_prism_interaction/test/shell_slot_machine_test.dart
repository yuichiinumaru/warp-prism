import 'package:test/test.dart';
import 'package:warp_prism_interaction/src/input/action_availability.dart';
import 'package:warp_prism_interaction/src/state_machine/shell_slot_machine.dart';

/// Task 1873 (F-06): shell-slot machine + focus-return token conformance.
///
/// Draw-derived semantics: the token always derives from the last committed
/// layout; refocus/scroll_to edge cases resolve deterministically.
void main() {
  ShellLayout wide() => ReferenceShellCatalog.wideControlLayout();

  group('ShellSlotMachine commit + token derivation', () {
    test('deriveFocusToken names the requested committed pane', () {
      final machine = ShellSlotMachine(initial: wide());

      final token = machine.deriveFocusToken(paneId: 'control');

      expect(token.paneId, 'control');
      expect(token.slot, ShellSlot.inspector);
      expect(token.regionId, 'control.panel');
    });

    test('null pane falls back to content active pane', () {
      final machine = ShellSlotMachine(initial: wide());

      final token = machine.deriveFocusToken();

      expect(token.paneId, 'sessions');
      expect(token.slot, ShellSlot.content);
    });

    test('commitLayout replaces the committed snapshot deterministically', () {
      final machine = ShellSlotMachine(initial: wide());
      var notified = 0;
      machine.addListener((_, _) => notified++);

      machine.commitLayout(ReferenceShellCatalog.narrowSingleLayout());

      expect(machine.committed, ReferenceShellCatalog.narrowSingleLayout());
      expect(notified, 1);
      expect(machine.deriveFocusToken().paneId, 'sessions');
    });

    test('same input yields same token across machines (determinism)', () {
      final first = ShellSlotMachine(initial: wide());
      final second = ShellSlotMachine(initial: wide());

      expect(
        first.deriveFocusToken(paneId: 'sessions'),
        second.deriveFocusToken(paneId: 'sessions'),
      );
      expect(
        first.scrollTo('sessions.list', requestedOffset: 12, maxOffset: 100),
        second.scrollTo('sessions.list', requestedOffset: 12, maxOffset: 100),
      );
    });
  });

  group('refocus edge cases', () {
    test('removed pane falls back to its slot active pane', () {
      final machine = ShellSlotMachine(initial: wide());
      machine.commitLayout(
        const ShellLayout(
          regions: [
            ShellRegion(
              id: 'nav.sessions',
              slot: ShellSlot.sidebar,
              paneId: 'nav',
            ),
            ShellRegion(
              id: 'sessions.list',
              slot: ShellSlot.content,
              paneId: 'sessions',
            ),
          ],
          activePaneBySlot: {
            ShellSlot.sidebar: 'nav',
            ShellSlot.content: 'sessions',
            ShellSlot.inspector: 'control',
          },
        ),
      );

      final token = machine.refocus(paneId: 'control');

      expect(token.paneId, 'sessions');
      expect(token.slot, ShellSlot.content);
    });

    test('emptied layout returns the empty token (no invented target)', () {
      final machine = ShellSlotMachine(initial: wide());
      machine.commitLayout(ReferenceShellCatalog.emptyLayout());

      final token = machine.refocus(paneId: 'sessions');

      expect(token.paneId, isEmpty);
      expect(machine.deriveFocusToken().paneId, isEmpty);
    });

    test('unknown pane with content active resolves to content pane', () {
      final machine = ShellSlotMachine(initial: wide());

      final token = machine.refocus(paneId: 'never-committed');

      expect(token.paneId, 'sessions');
    });
  });

  group('scrollTo edge cases', () {
    test('offset beyond max clamps and flags clamped', () {
      final machine = ShellSlotMachine(initial: wide());

      final edge = machine.scrollTo(
        'sessions.list',
        requestedOffset: 900,
        maxOffset: 200,
      );

      expect(edge.regionId, 'sessions.list');
      expect(edge.offset, 200);
      expect(edge.clamped, isTrue);
    });

    test('negative offset clamps to zero', () {
      final machine = ShellSlotMachine(initial: wide());

      final edge = machine.scrollTo(
        'sessions.list',
        requestedOffset: -40,
        maxOffset: 200,
      );

      expect(edge.offset, 0);
      expect(edge.clamped, isTrue);
    });

    test('unknown region falls back to first committed region', () {
      final machine = ShellSlotMachine(initial: wide());

      final edge = machine.scrollTo(
        'missing.region',
        requestedOffset: 10,
        maxOffset: 100,
      );

      expect(edge.regionId, 'nav.sessions');
      expect(edge.offset, 10);
      expect(edge.clamped, isTrue);
    });

    test('empty layout scroll_to returns zero without throwing', () {
      final machine = ShellSlotMachine(
        initial: ReferenceShellCatalog.emptyLayout(),
      );

      final edge = machine.scrollTo(
        'any.region',
        requestedOffset: 25,
        maxOffset: 100,
      );

      expect(edge.regionId, 'any.region');
      expect(edge.offset, 0);
      expect(edge.clamped, isTrue);
    });
  });

  group('gated sidebar rows consume frozen 1868 eligibility', () {
    test('absent capability denies fail-closed, never silent enable', () {
      final machine = ShellSlotMachine(initial: wide());
      final rows = [
        const ShellRowGate(
          rowId: 'sessions',
          capability: CapabilityState.available('nav.sessions'),
        ),
        const ShellRowGate(
          rowId: 'control',
          capability: CapabilityState.missing(
            'nav.control',
            detail: 'daemon offline',
          ),
        ),
      ];

      expect(machine.enabledRows(rows), ['sessions']);
      expect(rows[1].availability.isDenied, isTrue);
      expect(rows[1].availability.reason, contains('nav.control'));
    });
  });
}
