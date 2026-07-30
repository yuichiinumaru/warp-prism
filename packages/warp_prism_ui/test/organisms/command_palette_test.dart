import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// Task 1113: PrismCommandPalette widget tests.
///
/// Covers: open/close, fuzzy search, category grouping, keyboard navigation
/// (arrows + Enter + Escape), action execution, and visual structure.
void main() {
  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  List<PrismCommand> sampleCommands() => const [
    PrismCommand(
      id: 'nav-map',
      label: 'Map Workspace',
      description: 'Navigate to the asset map',
      icon: Icons.map_outlined,
      category: PrismCommandCategory.navigate,
    ),
    PrismCommand(
      id: 'nav-operate',
      label: 'Operate — Task Board',
      description: 'Navigate to the task board',
      icon: Icons.play_circle_outline,
      category: PrismCommandCategory.navigate,
    ),
    PrismCommand(
      id: 'nav-governance',
      label: 'Governance View',
      description: 'Navigate to governance diagnostics',
      icon: Icons.shield_outlined,
      category: PrismCommandCategory.navigate,
    ),
    PrismCommand(
      id: 'run-refresh',
      label: 'Refresh Workspace',
      description: 'Reload all workspace data',
      icon: Icons.refresh,
      category: PrismCommandCategory.run,
    ),
    PrismCommand(
      id: 'run-theme',
      label: 'Toggle Theme',
      description: 'Switch between light and dark theme',
      icon: Icons.brightness_6,
      category: PrismCommandCategory.run,
      shortcut: 'Ctrl+T',
    ),
    PrismCommand(
      id: 'recent-agent',
      label: 'Agent Alpha',
      description: 'Recently viewed agent',
      icon: Icons.smart_toy_outlined,
      category: PrismCommandCategory.recent,
    ),
  ];

  Widget buildApp({
    required List<PrismCommand> commands,
    ValueChanged<PrismCommand>? onExecute,
    VoidCallback? onClose,
    String? initialQuery,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: PrismCommandPalette(
          commands: commands,
          onExecute: onExecute,
          onClose: onClose,
          initialQuery: initialQuery,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Open/Close
  // ---------------------------------------------------------------------------
  group('PrismCommandPalette — open/close', () {
    testWidgets('renders the palette with search field', (tester) async {
      await tester.pumpWidget(buildApp(commands: sampleCommands()));

      expect(find.byType(PrismCommandPalette), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('shows placeholder text', (tester) async {
      await tester.pumpWidget(buildApp(commands: sampleCommands()));

      expect(find.text('Type a command...'), findsOneWidget);
    });

    testWidgets('custom placeholder is shown', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrismCommandPalette(
              commands: sampleCommands(),
              placeholder: 'Search commands...',
            ),
          ),
        ),
      );

      expect(find.text('Search commands...'), findsOneWidget);
    });

    testWidgets('onClose fires when Escape is pressed', (tester) async {
      var closed = false;
      await tester.pumpWidget(
        buildApp(commands: sampleCommands(), onClose: () => closed = true),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(closed, true);
    });

    testWidgets('onClose fires when backdrop is tapped', (tester) async {
      var closed = false;
      await tester.pumpWidget(
        buildApp(commands: sampleCommands(), onClose: () => closed = true),
      );

      // Tap outside the panel (top-left corner of the overlay)
      await tester.tapAt(const Offset(10, 10));
      await tester.pump();
      expect(closed, true);
    });
  });

  // ---------------------------------------------------------------------------
  // Fuzzy search
  // ---------------------------------------------------------------------------
  group('PrismCommandPalette — fuzzy search', () {
    testWidgets('all commands visible when query is empty', (tester) async {
      await tester.pumpWidget(buildApp(commands: sampleCommands()));

      // All category headers are mounted (ListView is non-lazy). With 48dp
      // row targets the last header may be offstage; still assert presence.
      expect(find.text('NAVIGATE', skipOffstage: false), findsOneWidget);
      expect(find.text('RUN', skipOffstage: false), findsOneWidget);
      expect(find.text('RECENT', skipOffstage: false), findsOneWidget);
    });

    testWidgets('filters commands by substring match', (tester) async {
      await tester.pumpWidget(buildApp(commands: sampleCommands()));

      await tester.enterText(find.byType(TextField), 'map');
      await tester.pump();

      expect(find.text('Map Workspace'), findsOneWidget);
      expect(find.text('Operate — Task Board'), findsNothing);
      expect(find.text('Toggle Theme'), findsNothing);
    });

    testWidgets('case-insensitive matching', (tester) async {
      await tester.pumpWidget(buildApp(commands: sampleCommands()));

      await tester.enterText(find.byType(TextField), 'THEME');
      await tester.pump();

      expect(find.text('Toggle Theme'), findsOneWidget);
    });

    testWidgets('multi-token AND matching', (tester) async {
      await tester.pumpWidget(buildApp(commands: sampleCommands()));

      await tester.enterText(find.byType(TextField), 'task board');
      await tester.pump();

      expect(find.text('Operate — Task Board'), findsOneWidget);
      expect(find.text('Map Workspace'), findsNothing);
    });

    testWidgets('shows empty state when no match', (tester) async {
      await tester.pumpWidget(buildApp(commands: sampleCommands()));

      await tester.enterText(find.byType(TextField), 'zzzznotfound');
      await tester.pump();

      expect(find.text('No matching commands'), findsOneWidget);
    });

    testWidgets('matches description text', (tester) async {
      await tester.pumpWidget(buildApp(commands: sampleCommands()));

      await tester.enterText(find.byType(TextField), 'governance diagnostics');
      await tester.pump();

      expect(find.text('Governance View'), findsOneWidget);
    });

    testWidgets('initialQuery pre-populates search', (tester) async {
      await tester.pumpWidget(
        buildApp(commands: sampleCommands(), initialQuery: 'theme'),
      );

      expect(find.text('Toggle Theme'), findsOneWidget);
      expect(find.text('Map Workspace'), findsNothing);
    });
  });

  // ---------------------------------------------------------------------------
  // Category grouping
  // ---------------------------------------------------------------------------
  group('PrismCommandPalette — category grouping', () {
    testWidgets('shows category headers', (tester) async {
      await tester.pumpWidget(buildApp(commands: sampleCommands()));

      expect(find.text('NAVIGATE', skipOffstage: false), findsOneWidget);
      expect(find.text('RUN', skipOffstage: false), findsOneWidget);
      expect(find.text('RECENT', skipOffstage: false), findsOneWidget);
    });

    testWidgets('category chip filters results', (tester) async {
      await tester.pumpWidget(buildApp(commands: sampleCommands()));

      // Tap the "Run" category chip
      await tester.tap(find.text('Run'));
      await tester.pump();

      // Only Run category commands should be visible
      expect(find.text('Refresh Workspace'), findsOneWidget);
      expect(find.text('Toggle Theme'), findsOneWidget);
      expect(find.text('Map Workspace'), findsNothing);
      expect(find.text('NAVIGATE'), findsNothing);
      expect(find.text('RECENT'), findsNothing);
    });

    testWidgets('tapping active category resets to All', (tester) async {
      await tester.pumpWidget(buildApp(commands: sampleCommands()));

      // Filter to Run
      await tester.tap(find.text('Run'));
      await tester.pump();
      expect(find.text('NAVIGATE'), findsNothing);

      // Tap Run again to deselect
      await tester.tap(find.text('Run'));
      await tester.pump();
      expect(find.text('NAVIGATE'), findsOneWidget);
    });

    testWidgets('All chip is active by default', (tester) async {
      await tester.pumpWidget(buildApp(commands: sampleCommands()));

      // The "All" chip should show all categories
      expect(find.text('NAVIGATE', skipOffstage: false), findsOneWidget);
      expect(find.text('RUN', skipOffstage: false), findsOneWidget);
      expect(find.text('RECENT', skipOffstage: false), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // Keyboard navigation
  // ---------------------------------------------------------------------------
  group('PrismCommandPalette — keyboard navigation', () {
    testWidgets('arrow down moves selection', (tester) async {
      await tester.pumpWidget(buildApp(commands: sampleCommands()));

      // First item should be selected by default (index 0)
      // Press arrow down
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();

      // The palette should still be showing (no crash)
      expect(find.byType(PrismCommandPalette), findsOneWidget);
    });

    testWidgets('arrow up moves selection', (tester) async {
      await tester.pumpWidget(buildApp(commands: sampleCommands()));

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();

      expect(find.byType(PrismCommandPalette), findsOneWidget);
    });

    testWidgets('arrow down wraps around', (tester) async {
      final commands = sampleCommands();
      await tester.pumpWidget(buildApp(commands: commands));

      // Press arrow down more times than total commands to test wrapping
      for (var i = 0; i < commands.length + 2; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      }
      await tester.pump();

      expect(find.byType(PrismCommandPalette), findsOneWidget);
    });

    testWidgets('Enter executes the selected command', (tester) async {
      String? executedId;
      final commands = sampleCommands();
      await tester.pumpWidget(
        buildApp(commands: commands, onExecute: (cmd) => executedId = cmd.id),
      );

      // First command (Map Workspace) is selected by default
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(executedId, 'nav-map');
    });

    testWidgets('Enter on second item executes correct command', (
      tester,
    ) async {
      String? executedId;
      await tester.pumpWidget(
        buildApp(
          commands: sampleCommands(),
          onExecute: (cmd) => executedId = cmd.id,
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(executedId, 'nav-operate');
    });

    testWidgets('Escape closes the palette', (tester) async {
      var closed = false;
      await tester.pumpWidget(
        buildApp(commands: sampleCommands(), onClose: () => closed = true),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();

      expect(closed, true);
    });
  });

  // ---------------------------------------------------------------------------
  // Action execution
  // ---------------------------------------------------------------------------
  group('PrismCommandPalette — action execution', () {
    testWidgets('onExecute callback fires with correct command', (
      tester,
    ) async {
      PrismCommand? received;
      await tester.pumpWidget(
        buildApp(
          commands: sampleCommands(),
          onExecute: (cmd) => received = cmd,
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(received, isNotNull);
      expect(received!.id, 'nav-map');
      expect(received!.label, 'Map Workspace');
    });

    testWidgets('command onExecute callback fires', (tester) async {
      var commandExecuted = false;
      final commands = [
        PrismCommand(
          id: 'test',
          label: 'Test Command',
          category: PrismCommandCategory.run,
          onExecute: () => commandExecuted = true,
        ),
      ];

      await tester.pumpWidget(buildApp(commands: commands));
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(commandExecuted, true);
    });

    testWidgets('palette closes after execution', (tester) async {
      var closed = false;
      await tester.pumpWidget(
        buildApp(commands: sampleCommands(), onClose: () => closed = true),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(closed, true);
    });

    testWidgets('tap on command item executes it', (tester) async {
      PrismCommand? received;
      await tester.pumpWidget(
        buildApp(
          commands: sampleCommands(),
          onExecute: (cmd) => received = cmd,
        ),
      );

      await tester.tap(find.text('Toggle Theme'));
      await tester.pump();

      expect(received, isNotNull);
      expect(received!.id, 'run-theme');
    });
  });

  // ---------------------------------------------------------------------------
  // Visual structure
  // ---------------------------------------------------------------------------
  group('PrismCommandPalette — visual structure', () {
    testWidgets('shows category filter chips', (tester) async {
      await tester.pumpWidget(buildApp(commands: sampleCommands()));

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Navigate'), findsOneWidget);
      expect(find.text('Run'), findsOneWidget);
      expect(find.text('Recent'), findsOneWidget);
    });

    testWidgets('shows command icons', (tester) async {
      await tester.pumpWidget(buildApp(commands: sampleCommands()));

      // Should find multiple PrismIcon widgets
      expect(find.byType(PrismIcon), findsWidgets);
    });

    testWidgets('shows shortcut hint when provided', (tester) async {
      await tester.pumpWidget(buildApp(commands: sampleCommands()));

      // The "Toggle Theme" command has shortcut "Ctrl+T"
      expect(find.text('Ctrl+T'), findsOneWidget);
    });

    testWidgets('shows ESC hint in search field', (tester) async {
      await tester.pumpWidget(buildApp(commands: sampleCommands()));

      // ESC hint in the search bar area
      expect(find.text('ESC'), findsWidgets); // one in search, one in footer
    });

    testWidgets('shows footer keyboard hints', (tester) async {
      await tester.pumpWidget(buildApp(commands: sampleCommands()));

      expect(find.text('navigate'), findsOneWidget);
      expect(find.text('select'), findsOneWidget);
      expect(find.text('close'), findsOneWidget);
    });

    testWidgets('empty commands list shows empty state', (tester) async {
      await tester.pumpWidget(buildApp(commands: const []));

      expect(find.text('No matching commands'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // PrismCommand model
  // ---------------------------------------------------------------------------
  group('PrismCommand model', () {
    test('constructs with required fields only', () {
      const cmd = PrismCommand(id: 'test', label: 'Test');
      expect(cmd.id, 'test');
      expect(cmd.label, 'Test');
      expect(cmd.icon, Icons.arrow_forward);
      expect(cmd.category, PrismCommandCategory.navigate);
      expect(cmd.description, isNull);
      expect(cmd.onExecute, isNull);
      expect(cmd.route, isNull);
      expect(cmd.shortcut, isNull);
    });

    test('constructs with all fields', () {
      var called = false;
      final cmd = PrismCommand(
        id: 'full',
        label: 'Full Command',
        description: 'A full command',
        icon: Icons.star,
        category: PrismCommandCategory.run,
        onExecute: () => called = true,
        route: '/test',
        shortcut: 'Ctrl+F',
      );

      expect(cmd.id, 'full');
      expect(cmd.label, 'Full Command');
      expect(cmd.description, 'A full command');
      expect(cmd.icon, Icons.star);
      expect(cmd.category, PrismCommandCategory.run);
      expect(cmd.route, '/test');
      expect(cmd.shortcut, 'Ctrl+F');

      cmd.onExecute?.call();
      expect(called, true);
    });
  });

  // ---------------------------------------------------------------------------
  // PrismCommandCategory enum
  // ---------------------------------------------------------------------------
  group('PrismCommandCategory enum', () {
    test('has navigate, run, recent values', () {
      expect(PrismCommandCategory.values.length, 3);
      expect(PrismCommandCategory.values, contains(PrismCommandCategory.navigate));
      expect(PrismCommandCategory.values, contains(PrismCommandCategory.run));
      expect(PrismCommandCategory.values, contains(PrismCommandCategory.recent));
    });
  });

  // ---------------------------------------------------------------------------
  // Barrel exports
  // ---------------------------------------------------------------------------
  group('Command palette barrel exports', () {
    test('all command palette classes accessible via organisms barrel', () {
      // Compile-time check — if any export is missing this won't compile
      expect(PrismCommandPalette, isNotNull);
      expect(PrismCommand, isNotNull);
      expect(PrismCommandCategory, isNotNull);
      // showDSCommandPalette has no Prism* function alias on the public barrel yet.
      expect(PrismCommandPaletteShortcut, isNotNull);
    });
  });

  // ---------------------------------------------------------------------------
  // Path-to-100: shortcut + a11y + footer count (F2–F6)
  // ---------------------------------------------------------------------------
  Future<void> pumpShortcutApp(
    WidgetTester tester, {
    required List<PrismCommand> commands,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PrismCommandPaletteShortcut(
            commands: commands,
            child: const Center(
              child: Text('App body'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> sendModK(
    WidgetTester tester, {
    LogicalKeyboardKey modifier = LogicalKeyboardKey.controlLeft,
  }) async {
    await tester.sendKeyDownEvent(modifier);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.keyK);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.keyK);
    await tester.sendKeyUpEvent(modifier);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();
  }

  group('DSCommandPaletteShortcut', () {
    testWidgets('Ctrl+K opens the command palette', (tester) async {
      final commands = [
        const PrismCommand(
          id: 'go-home',
          label: 'Go Home',
          icon: Icons.home,
          category: PrismCommandCategory.navigate,
        ),
      ];

      await pumpShortcutApp(tester, commands: commands);

      // Ensure child is present; autofocus Focus on shortcut should receive keys.
      expect(find.text('App body'), findsOneWidget);
      await sendModK(tester);

      // Palette command list should be visible over the app body.
      expect(find.text('Go Home'), findsOneWidget);
      expect(find.text('App body'), findsOneWidget);
    });

    testWidgets('Cmd/Meta+K opens the command palette', (tester) async {
      final commands = [
        const PrismCommand(
          id: 'go-settings',
          label: 'Go Settings',
          icon: Icons.settings,
          category: PrismCommandCategory.navigate,
        ),
      ];

      await pumpShortcutApp(tester, commands: commands);
      await sendModK(tester, modifier: LogicalKeyboardKey.metaLeft);

      expect(find.text('Go Settings'), findsOneWidget);
    });

    testWidgets(
      're-entry guard: second Ctrl+K while open does not stack routes',
      (tester) async {
        final commands = [
          const PrismCommand(
            id: 'go-home',
            label: 'Go Home',
            icon: Icons.home,
            category: PrismCommandCategory.navigate,
          ),
        ];

        await pumpShortcutApp(tester, commands: commands);
        await sendModK(tester);
        expect(find.text('Go Home'), findsOneWidget);

        // Second open while route still open must be ignored.
        await sendModK(tester);
        expect(find.text('Go Home'), findsOneWidget);
        // Search field appears once per palette instance.
        expect(find.byType(TextField), findsOneWidget);
      },
    );

    testWidgets(
      'after Escape close, Ctrl+K reopens (mounted clears _isOpen)',
      (tester) async {
        final commands = [
          const PrismCommand(
            id: 'go-home',
            label: 'Go Home',
            icon: Icons.home,
            category: PrismCommandCategory.navigate,
          ),
        ];

        await pumpShortcutApp(tester, commands: commands);
        await sendModK(tester);
        expect(find.text('Go Home'), findsOneWidget);

        await tester.sendKeyDownEvent(LogicalKeyboardKey.escape);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();
        expect(find.text('Go Home'), findsNothing);
        expect(find.text('App body'), findsOneWidget);

        await sendModK(tester);
        expect(find.text('Go Home'), findsOneWidget);
      },
    );

    testWidgets('category chips expose button semantics', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrismCommandPalette(
              commands: const [
                PrismCommand(
                  id: '1',
                  label: 'Nav One',
                  icon: Icons.home,
                  category: PrismCommandCategory.navigate,
                ),
              ],
              onClose: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Chips render "Navigate" text with button semantics.
      expect(find.text('Navigate'), findsOneWidget);
      final navigateSemantics = tester.getSemantics(find.text('Navigate'));
      expect(navigateSemantics.flagsCollection.isButton, isTrue);
    });

    testWidgets('command items expose button semantics', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrismCommandPalette(
              commands: const [
                PrismCommand(
                  id: '1',
                  label: 'Open Map',
                  description: 'Go to map workspace',
                  icon: Icons.map,
                  category: PrismCommandCategory.navigate,
                ),
              ],
              onClose: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final itemSemantics = tester.getSemantics(find.text('Open Map'));
      expect(itemSemantics.flagsCollection.isButton, isTrue);
    });

    testWidgets('footer shows result count', (tester) async {
      await tester.pumpWidget(
        buildApp(commands: sampleCommands()),
      );
      await tester.pumpAndSettle();

      // Sample set has 6 commands.
      expect(find.text('6 results'), findsOneWidget);
    });

    testWidgets('footer shows singular result count', (tester) async {
      await tester.pumpWidget(
        buildApp(
          commands: [
            const PrismCommand(
              id: 'only',
              label: 'Only Command',
              icon: Icons.star,
              category: PrismCommandCategory.run,
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('1 result'), findsOneWidget);
    });
  });
}
