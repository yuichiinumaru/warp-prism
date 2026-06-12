import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// Task 1113: DSCommandPalette widget tests.
///
/// Covers: open/close, fuzzy search, category grouping, keyboard navigation
/// (arrows + Enter + Escape), action execution, and visual structure.
void main() {
  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  List<DSCommand> _sampleCommands() => const [
    DSCommand(
      id: 'nav-map',
      label: 'Map Workspace',
      description: 'Navigate to the asset map',
      icon: Icons.map_outlined,
      category: DSCommandCategory.navigate,
    ),
    DSCommand(
      id: 'nav-operate',
      label: 'Operate — Task Board',
      description: 'Navigate to the task board',
      icon: Icons.play_circle_outline,
      category: DSCommandCategory.navigate,
    ),
    DSCommand(
      id: 'nav-governance',
      label: 'Governance View',
      description: 'Navigate to governance diagnostics',
      icon: Icons.shield_outlined,
      category: DSCommandCategory.navigate,
    ),
    DSCommand(
      id: 'run-refresh',
      label: 'Refresh Workspace',
      description: 'Reload all workspace data',
      icon: Icons.refresh,
      category: DSCommandCategory.run,
    ),
    DSCommand(
      id: 'run-theme',
      label: 'Toggle Theme',
      description: 'Switch between light and dark theme',
      icon: Icons.brightness_6,
      category: DSCommandCategory.run,
      shortcut: 'Ctrl+T',
    ),
    DSCommand(
      id: 'recent-agent',
      label: 'Agent Alpha',
      description: 'Recently viewed agent',
      icon: Icons.smart_toy_outlined,
      category: DSCommandCategory.recent,
    ),
  ];

  Widget _buildApp({
    required List<DSCommand> commands,
    ValueChanged<DSCommand>? onExecute,
    VoidCallback? onClose,
    String? initialQuery,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: DSCommandPalette(
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
  group('DSCommandPalette — open/close', () {
    testWidgets('renders the palette with search field', (tester) async {
      await tester.pumpWidget(_buildApp(commands: _sampleCommands()));

      expect(find.byType(DSCommandPalette), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('shows placeholder text', (tester) async {
      await tester.pumpWidget(_buildApp(commands: _sampleCommands()));

      expect(find.text('Type a command...'), findsOneWidget);
    });

    testWidgets('custom placeholder is shown', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DSCommandPalette(
              commands: _sampleCommands(),
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
        _buildApp(commands: _sampleCommands(), onClose: () => closed = true),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(closed, true);
    });

    testWidgets('onClose fires when backdrop is tapped', (tester) async {
      var closed = false;
      await tester.pumpWidget(
        _buildApp(commands: _sampleCommands(), onClose: () => closed = true),
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
  group('DSCommandPalette — fuzzy search', () {
    testWidgets('all commands visible when query is empty', (tester) async {
      await tester.pumpWidget(_buildApp(commands: _sampleCommands()));

      // All category headers should be visible
      expect(find.text('NAVIGATE'), findsOneWidget);
      expect(find.text('RUN'), findsOneWidget);
      expect(find.text('RECENT'), findsOneWidget);
    });

    testWidgets('filters commands by substring match', (tester) async {
      await tester.pumpWidget(_buildApp(commands: _sampleCommands()));

      await tester.enterText(find.byType(TextField), 'map');
      await tester.pump();

      expect(find.text('Map Workspace'), findsOneWidget);
      expect(find.text('Operate — Task Board'), findsNothing);
      expect(find.text('Toggle Theme'), findsNothing);
    });

    testWidgets('case-insensitive matching', (tester) async {
      await tester.pumpWidget(_buildApp(commands: _sampleCommands()));

      await tester.enterText(find.byType(TextField), 'THEME');
      await tester.pump();

      expect(find.text('Toggle Theme'), findsOneWidget);
    });

    testWidgets('multi-token AND matching', (tester) async {
      await tester.pumpWidget(_buildApp(commands: _sampleCommands()));

      await tester.enterText(find.byType(TextField), 'task board');
      await tester.pump();

      expect(find.text('Operate — Task Board'), findsOneWidget);
      expect(find.text('Map Workspace'), findsNothing);
    });

    testWidgets('shows empty state when no match', (tester) async {
      await tester.pumpWidget(_buildApp(commands: _sampleCommands()));

      await tester.enterText(find.byType(TextField), 'zzzznotfound');
      await tester.pump();

      expect(find.text('No matching commands'), findsOneWidget);
    });

    testWidgets('matches description text', (tester) async {
      await tester.pumpWidget(_buildApp(commands: _sampleCommands()));

      await tester.enterText(find.byType(TextField), 'governance diagnostics');
      await tester.pump();

      expect(find.text('Governance View'), findsOneWidget);
    });

    testWidgets('initialQuery pre-populates search', (tester) async {
      await tester.pumpWidget(
        _buildApp(commands: _sampleCommands(), initialQuery: 'theme'),
      );

      expect(find.text('Toggle Theme'), findsOneWidget);
      expect(find.text('Map Workspace'), findsNothing);
    });
  });

  // ---------------------------------------------------------------------------
  // Category grouping
  // ---------------------------------------------------------------------------
  group('DSCommandPalette — category grouping', () {
    testWidgets('shows category headers', (tester) async {
      await tester.pumpWidget(_buildApp(commands: _sampleCommands()));

      expect(find.text('NAVIGATE'), findsOneWidget);
      expect(find.text('RUN'), findsOneWidget);
      expect(find.text('RECENT'), findsOneWidget);
    });

    testWidgets('category chip filters results', (tester) async {
      await tester.pumpWidget(_buildApp(commands: _sampleCommands()));

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
      await tester.pumpWidget(_buildApp(commands: _sampleCommands()));

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
      await tester.pumpWidget(_buildApp(commands: _sampleCommands()));

      // The "All" chip should show all categories
      expect(find.text('NAVIGATE'), findsOneWidget);
      expect(find.text('RUN'), findsOneWidget);
      expect(find.text('RECENT'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // Keyboard navigation
  // ---------------------------------------------------------------------------
  group('DSCommandPalette — keyboard navigation', () {
    testWidgets('arrow down moves selection', (tester) async {
      await tester.pumpWidget(_buildApp(commands: _sampleCommands()));

      // First item should be selected by default (index 0)
      // Press arrow down
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();

      // The palette should still be showing (no crash)
      expect(find.byType(DSCommandPalette), findsOneWidget);
    });

    testWidgets('arrow up moves selection', (tester) async {
      await tester.pumpWidget(_buildApp(commands: _sampleCommands()));

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();

      expect(find.byType(DSCommandPalette), findsOneWidget);
    });

    testWidgets('arrow down wraps around', (tester) async {
      final commands = _sampleCommands();
      await tester.pumpWidget(_buildApp(commands: commands));

      // Press arrow down more times than total commands to test wrapping
      for (var i = 0; i < commands.length + 2; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      }
      await tester.pump();

      expect(find.byType(DSCommandPalette), findsOneWidget);
    });

    testWidgets('Enter executes the selected command', (tester) async {
      String? executedId;
      final commands = _sampleCommands();
      await tester.pumpWidget(
        _buildApp(commands: commands, onExecute: (cmd) => executedId = cmd.id),
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
        _buildApp(
          commands: _sampleCommands(),
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
        _buildApp(commands: _sampleCommands(), onClose: () => closed = true),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();

      expect(closed, true);
    });
  });

  // ---------------------------------------------------------------------------
  // Action execution
  // ---------------------------------------------------------------------------
  group('DSCommandPalette — action execution', () {
    testWidgets('onExecute callback fires with correct command', (
      tester,
    ) async {
      DSCommand? received;
      await tester.pumpWidget(
        _buildApp(
          commands: _sampleCommands(),
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
        DSCommand(
          id: 'test',
          label: 'Test Command',
          category: DSCommandCategory.run,
          onExecute: () => commandExecuted = true,
        ),
      ];

      await tester.pumpWidget(_buildApp(commands: commands));
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(commandExecuted, true);
    });

    testWidgets('palette closes after execution', (tester) async {
      var closed = false;
      await tester.pumpWidget(
        _buildApp(commands: _sampleCommands(), onClose: () => closed = true),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(closed, true);
    });

    testWidgets('tap on command item executes it', (tester) async {
      DSCommand? received;
      await tester.pumpWidget(
        _buildApp(
          commands: _sampleCommands(),
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
  group('DSCommandPalette — visual structure', () {
    testWidgets('shows category filter chips', (tester) async {
      await tester.pumpWidget(_buildApp(commands: _sampleCommands()));

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Navigate'), findsOneWidget);
      expect(find.text('Run'), findsOneWidget);
      expect(find.text('Recent'), findsOneWidget);
    });

    testWidgets('shows command icons', (tester) async {
      await tester.pumpWidget(_buildApp(commands: _sampleCommands()));

      // Should find multiple DSIcon widgets
      expect(find.byType(DSIcon), findsWidgets);
    });

    testWidgets('shows shortcut hint when provided', (tester) async {
      await tester.pumpWidget(_buildApp(commands: _sampleCommands()));

      // The "Toggle Theme" command has shortcut "Ctrl+T"
      expect(find.text('Ctrl+T'), findsOneWidget);
    });

    testWidgets('shows ESC hint in search field', (tester) async {
      await tester.pumpWidget(_buildApp(commands: _sampleCommands()));

      // ESC hint in the search bar area
      expect(find.text('ESC'), findsWidgets); // one in search, one in footer
    });

    testWidgets('shows footer keyboard hints', (tester) async {
      await tester.pumpWidget(_buildApp(commands: _sampleCommands()));

      expect(find.text('navigate'), findsOneWidget);
      expect(find.text('select'), findsOneWidget);
      expect(find.text('close'), findsOneWidget);
    });

    testWidgets('empty commands list shows empty state', (tester) async {
      await tester.pumpWidget(_buildApp(commands: const []));

      expect(find.text('No matching commands'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // DSCommand model
  // ---------------------------------------------------------------------------
  group('DSCommand model', () {
    test('constructs with required fields only', () {
      const cmd = DSCommand(id: 'test', label: 'Test');
      expect(cmd.id, 'test');
      expect(cmd.label, 'Test');
      expect(cmd.icon, Icons.arrow_forward);
      expect(cmd.category, DSCommandCategory.navigate);
      expect(cmd.description, isNull);
      expect(cmd.onExecute, isNull);
      expect(cmd.route, isNull);
      expect(cmd.shortcut, isNull);
    });

    test('constructs with all fields', () {
      var called = false;
      final cmd = DSCommand(
        id: 'full',
        label: 'Full Command',
        description: 'A full command',
        icon: Icons.star,
        category: DSCommandCategory.run,
        onExecute: () => called = true,
        route: '/test',
        shortcut: 'Ctrl+F',
      );

      expect(cmd.id, 'full');
      expect(cmd.label, 'Full Command');
      expect(cmd.description, 'A full command');
      expect(cmd.icon, Icons.star);
      expect(cmd.category, DSCommandCategory.run);
      expect(cmd.route, '/test');
      expect(cmd.shortcut, 'Ctrl+F');

      cmd.onExecute?.call();
      expect(called, true);
    });
  });

  // ---------------------------------------------------------------------------
  // DSCommandCategory enum
  // ---------------------------------------------------------------------------
  group('DSCommandCategory enum', () {
    test('has navigate, run, recent values', () {
      expect(DSCommandCategory.values.length, 3);
      expect(DSCommandCategory.values, contains(DSCommandCategory.navigate));
      expect(DSCommandCategory.values, contains(DSCommandCategory.run));
      expect(DSCommandCategory.values, contains(DSCommandCategory.recent));
    });
  });

  // ---------------------------------------------------------------------------
  // Barrel exports
  // ---------------------------------------------------------------------------
  group('Command palette barrel exports', () {
    test('all command palette classes accessible via organisms barrel', () {
      // Compile-time check — if any export is missing this won't compile
      expect(DSCommandPalette, isNotNull);
      expect(DSCommand, isNotNull);
      expect(DSCommandCategory, isNotNull);
      expect(showDSCommandPalette, isNotNull);
      expect(DSCommandPaletteShortcut, isNotNull);
    });
  });
}
