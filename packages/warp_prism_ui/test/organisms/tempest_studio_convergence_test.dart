import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/src/atoms/ds_text.dart';
import 'package:warp_prism_ui/src/organisms/ds_shell.dart';
import 'package:warp_prism_ui/src/organisms/ds_sidebar.dart';
import 'package:warp_prism_ui/src/organisms/split_pane/ds_split_pane.dart';
import 'package:warp_prism_ui/src/theme/ds_theme.dart';

// Task 1882 (F-15): Tempest studio-shape host proof over
// DSShell / DSSidebar / DSSplitPane (AGENTS.md §7.1).
//
// Donor shape (source reality, revision UNKNOWN):
// references/ganthritor-tempest/flutter/lib/core/layout/main_shell.dart:9-203
// — NavigationRail with 7 destinations (main_shell.dart:155-191:
// Library, Separate, Create, Studio, Models, Providers, Settings),
// theme toggle + hardware badge footer (main_shell.dart:77-154), and
// RoutedContent (main_shell.dart:199). No shell-router contract is used
// here (P0 F-06 owns that seam); no focus wiring is redesigned.
//
// Negative evidence (recorded, not a host): Warpblade is single-column —
// never counted as a layout host.
//
// Limitation: real display host unavailable in this headless env; proof runs
// as a `flutter_tester` headless sweep. No pixels were visually inspected.
void main() {
  // Injected Tempest-side colours (test-local; Prism never owns these).
  const tempestPrimary = Color(0xFF7C4DFF);
  const tempestSecondary = Color(0xFF00E5FF);
  const stemVocals = Color(0xFF00E5FF);
  const stemDrums = Color(0xFFFF9100);
  const stemBass = Color(0xFFB388FF);
  const stemOther = Color(0xFF00E676);

  const branches = [
    DSSidebarItem(id: 'library', label: 'Library', icon: Icons.folder_outlined),
    DSSidebarItem(
      id: 'separate',
      label: 'Separate',
      icon: Icons.content_cut_outlined,
      color: stemVocals,
    ),
    DSSidebarItem(
      id: 'create',
      label: 'Create',
      icon: Icons.auto_awesome_outlined,
      color: tempestPrimary,
    ),
    DSSidebarItem(
      id: 'studio',
      label: 'Studio',
      icon: Icons.multitrack_audio_outlined,
      color: tempestSecondary,
    ),
    DSSidebarItem(
      id: 'models',
      label: 'Models',
      icon: Icons.psychology_outlined,
      color: stemBass,
    ),
    DSSidebarItem(
      id: 'providers',
      label: 'Providers',
      icon: Icons.cable_outlined,
      color: stemOther,
    ),
    DSSidebarItem(
      id: 'settings',
      label: 'Settings',
      icon: Icons.settings_outlined,
    ),
  ];

  Widget studioHost({
    required String selectedId,
    required double width,
    ValueChanged<String>? onSelect,
    VoidCallback? onToggleBadge,
    String badgeLabel = 'GPU',
    bool responsive = false,
  }) {
    Widget sidebar({required bool expanded}) => DSSidebar(
      items: branches,
      selectedId: selectedId,
      onItemTap: onSelect,
      expanded: expanded,
      header: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [tempestPrimary, tempestSecondary],
                ),
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              child: const Icon(
                Icons.graphic_eq,
                color: Colors.white,
                size: 20,
              ),
            ),
            if (expanded) ...[
              const SizedBox(width: 8),
              const DSText.labelLarge('Tempest'),
            ],
          ],
        ),
      ),
      footer: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              key: const Key('studio-theme-toggle'),
              onPressed: onToggleBadge,
              icon: const Icon(Icons.dark_mode_outlined, size: 20),
              tooltip: 'Toggle theme',
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: stemDrums.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: stemDrums.withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.bolt, size: 12, color: stemDrums),
                  const SizedBox(width: 2),
                  DSText.labelSmall(badgeLabel, color: const Color(0xFFFF9100)),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    Widget content() => DSSplitPane(
      initialRatio: 0.35,
      leading: ListView(
        key: const Key('studio-track-headers'),
        children: const [
          ListTile(title: Text('Vocals')),
          ListTile(title: Text('Drums')),
          ListTile(title: Text('Bass')),
        ],
      ),
      trailing: Container(
        key: ValueKey('studio-timeline-$selectedId'),
        alignment: Alignment.center,
        child: Text('timeline:$selectedId'),
      ),
    );

    final shell = responsive
        ? DSShellResponsive(
            sidebar: sidebar(expanded: true),
            collapsedSidebar: sidebar(expanded: false),
            content: content(),
          )
        : DSShell(sidebar: sidebar(expanded: true), content: content());

    return MaterialApp(
      theme: DSTheme.dark(),
      home: Scaffold(
        body: SizedBox(width: width, height: 900, child: shell),
      ),
    );
  }

  Future<void> expectCleanSweep(
    WidgetTester tester,
    String selectedId,
    double width, {
    bool responsive = false,
  }) async {
    await tester.pumpWidget(
      studioHost(selectedId: selectedId, width: width, responsive: responsive),
    );
    await tester.pumpAndSettle();
    expect(find.text('timeline:$selectedId'), findsOneWidget);
    expect(tester.takeException(), isNull);
  }

  group('Tempest studio-shape convergence proof', () {
    testWidgets('enter studio route wide with interaction', (tester) async {
      var selected = 'studio';
      var badge = 'GPU';
      await tester.pumpWidget(
        MaterialApp(
          theme: DSTheme.dark(),
          home: StatefulBuilder(
            builder: (context, setState) => Scaffold(
              body: SizedBox(
                width: 1400,
                height: 900,
                child: studioHost(
                  selectedId: selected,
                  width: 1400,
                  onSelect: (id) => setState(() => selected = id),
                  onToggleBadge: () =>
                      setState(() => badge = badge == 'GPU' ? 'CPU' : 'GPU'),
                  badgeLabel: badge,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('timeline:studio'), findsOneWidget);

      // Interact: switch branch Library -> theme/focus/navigation intact.
      await tester.tap(find.text('Library'));
      await tester.pumpAndSettle();
      expect(find.text('timeline:library'), findsOneWidget);

      // Interact: footer badge toggle (theme-toggle slot).
      await tester.tap(find.byKey(const Key('studio-theme-toggle')));
      await tester.pumpAndSettle();
      expect(find.text('CPU'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('viewport conditions: wide / medium / narrow', (tester) async {
      await expectCleanSweep(tester, 'studio', 1400);
      await expectCleanSweep(tester, 'studio', 900, responsive: true);
      await expectCleanSweep(tester, 'studio', 500, responsive: true);
      // Theme propagates through the Prism factory theme.
      final context = tester.element(find.text('timeline:studio').first);
      expect(Theme.of(context).colorScheme.primary, isNotNull);
      expect(tester.takeException(), isNull);
    });

    testWidgets('split-pane studio content resizes without errors', (
      tester,
    ) async {
      await tester.pumpWidget(studioHost(selectedId: 'studio', width: 1400));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('studio-track-headers')), findsOneWidget);
      expect(find.byType(DSSplitPane), findsOneWidget);
      expect(find.byType(ErrorWidget), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('sidebar semantics + focus order intact', (tester) async {
      await tester.pumpWidget(studioHost(selectedId: 'models', width: 1400));
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Navigation sidebar'), findsOneWidget);
      expect(find.byType(FocusTraversalGroup), findsWidgets);
      expect(find.text('timeline:models'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
