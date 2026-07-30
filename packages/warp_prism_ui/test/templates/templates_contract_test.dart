import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
// import 'package:warp_prism_ui/warp_prism_ui.dart'; // No public barrel, testing internal contract
import 'package:warp_prism_ui/src/molecules/molecules.dart';
import 'package:warp_prism_ui/src/organisms/organisms.dart';
import 'package:warp_prism_ui/src/templates/templates.dart';

/// Task 0016: DS Organisms and Templates Alignment
///
/// Widget tests proving that templates compose organisms correctly
/// using only canonical DS constructors and parameters — no adapters.
void main() {
  group('MasterDetailTemplate composition', () {
    testWidgets('renders shell with sidebar, topbar, and master content', (
      tester,
    ) async {
      const sidebarItems = [
        DSSidebarItem(id: 'overview', label: 'Overview', icon: Icons.dashboard),
        DSSidebarItem(id: 'map', label: 'Map', icon: Icons.hub_outlined),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 1400,
              height: 900,
              child: MasterDetailTemplate(
                sidebarItems: sidebarItems,
                selectedIndex: 0,
                onSidebarItemSelected: (_) {},
                title: 'Map Workspace',
                masterContent: Container(key: const Key('master')),
              ),
            ),
          ),
        ),
      );

      // Shell renders sidebar labels
      expect(find.text('Overview'), findsOneWidget);
      expect(find.text('Map'), findsOneWidget);

      // Topbar renders title
      expect(find.text('Map Workspace'), findsOneWidget);

      // Master content renders
      expect(find.byKey(const Key('master')), findsOneWidget);
    });

    testWidgets('shows detail panel when showDetail is true at wide width', (
      tester,
    ) async {
      // Ensure the test surface is wide enough for side-by-side layout.
      // Content area = surface width - sidebar (240) must >= 1200.
      await tester.binding.setSurfaceSize(const Size(1600, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      const sidebarItems = [
        DSSidebarItem(id: 'op', label: 'Operate', icon: Icons.play_circle),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MasterDetailTemplate(
              sidebarItems: sidebarItems,
              selectedIndex: 0,
              onSidebarItemSelected: (_) {},
              title: 'Operate',
              masterContent: Container(key: const Key('master')),
              detailContent: Container(key: const Key('detail')),
              showDetail: true,
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('master')), findsOneWidget);
      expect(find.byKey(const Key('detail')), findsOneWidget);
    });

    testWidgets('renders search bar when onSearchChanged is provided', (
      tester,
    ) async {
      // DSTopbar collapses search when maxWidth < DSBreakpoints.narrow (600).
      // Ensure the test surface is wide enough for search to render.
      await tester.binding.setSurfaceSize(const Size(1600, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      const sidebarItems = [
        DSSidebarItem(id: 'map', label: 'Map', icon: Icons.hub_outlined),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: MasterDetailTemplate(
              sidebarItems: sidebarItems,
              selectedIndex: 0,
              onSidebarItemSelected: (_) {},
              title: 'Map',
              onSearchChanged: (_) {},
              masterContent: const SizedBox(),
            ),
          ),
        ),
      );

      // DSSearchBar should be present (renders TextField inside)
      expect(find.byType(DSSearchBar), findsOneWidget);
    });

    testWidgets('renders filter chips when filters are provided', (
      tester,
    ) async {
      const sidebarItems = [
        DSSidebarItem(id: 'op', label: 'Operate', icon: Icons.play_circle),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 1400,
              height: 900,
              child: MasterDetailTemplate(
                sidebarItems: sidebarItems,
                selectedIndex: 0,
                onSidebarItemSelected: (_) {},
                title: 'Operate',
                filters: const ['Agent', 'Skill', 'Workflow'],
                selectedFilters: const {'Agent'},
                onFiltersChanged: (_) {},
                masterContent: const SizedBox(),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Agent'), findsOneWidget);
      expect(find.text('Skill'), findsOneWidget);
      expect(find.text('Workflow'), findsOneWidget);
    });
  });

  group('CanvasTemplate composition', () {
    testWidgets('renders shell with sidebar, topbar, and canvas', (
      tester,
    ) async {
      const sidebarItems = [
        DSSidebarItem(id: 'map', label: 'Map', icon: Icons.hub_outlined),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 1400,
              height: 900,
              child: CanvasTemplate(
                sidebarItems: sidebarItems,
                selectedIndex: 0,
                onSidebarItemSelected: (_) {},
                title: 'Graph Canvas',
                canvas: Container(key: const Key('canvas')),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Map'), findsOneWidget);
      expect(find.text('Graph Canvas'), findsOneWidget);
      expect(find.byKey(const Key('canvas')), findsOneWidget);
    });

    testWidgets('shows overlay panel when showOverlay is true', (tester) async {
      const sidebarItems = [
        DSSidebarItem(id: 'map', label: 'Map', icon: Icons.hub_outlined),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 1400,
              height: 900,
              child: CanvasTemplate(
                sidebarItems: sidebarItems,
                selectedIndex: 0,
                onSidebarItemSelected: (_) {},
                title: 'Map',
                canvas: const SizedBox(),
                overlayPanel: Container(key: const Key('overlay')),
                showOverlay: true,
              ),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('overlay')), findsOneWidget);
    });
  });

  group('TimelineTemplate composition', () {
    testWidgets('renders shell with sidebar, topbar, and timeline entries', (
      tester,
    ) async {
      const sidebarItems = [
        DSSidebarItem(id: 'history', label: 'History', icon: Icons.history),
      ];
      const entries = [
        DSTimelineEntry(
          id: '1',
          date: '2025-06-01',
          title: 'Initial setup',
          type: 'feature',
        ),
        DSTimelineEntry(
          id: '2',
          date: '2025-06-02',
          title: 'Bug fix',
          type: 'fix',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 1400,
              height: 900,
              child: TimelineTemplate(
                sidebarItems: sidebarItems,
                selectedIndex: 0,
                onSidebarItemSelected: (_) {},
                title: 'History',
                entries: entries,
              ),
            ),
          ),
        ),
      );

      expect(
        find.text('History'),
        findsNWidgets(2),
      ); // sidebar label + topbar title
      expect(find.text('Initial setup'), findsOneWidget);
      expect(find.text('Bug fix'), findsOneWidget);
    });
  });

  group('Templates barrel exports', () {
    test('templates barrel exports all template classes', () {
      expect(MasterDetailTemplate, isNotNull);
      expect(CanvasTemplate, isNotNull);
      expect(TimelineTemplate, isNotNull);
    });
  });
}
