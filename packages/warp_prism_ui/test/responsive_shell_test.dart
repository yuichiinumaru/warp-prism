import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/src/templates/master_detail_template.dart';
import 'package:warp_prism_ui/src/tokens/tokens.dart';
import 'package:warp_prism_ui/src/organisms/ds_sidebar.dart';

/// Task 1020: Responsive Shell and Detail Pass
///
/// Regression tests for:
/// 1. DSBreakpoints token values and contract
/// 2. Breakpoint value consistency (no duplicate hardcoded values)
/// 3. Responsive width range coverage
/// 4. MasterDetailTemplate width transitions (path-to-100 residual)
void main() {
  group('DSBreakpoints Contract', () {
    test('narrow breakpoint is 600px', () {
      expect(
        DSBreakpoints.narrow,
        600.0,
        reason: 'Narrow breakpoint must be 600px per contract',
      );
    });

    test('sidebarCollapse breakpoint is 800px', () {
      expect(
        DSBreakpoints.sidebarCollapse,
        800.0,
        reason: 'Sidebar collapse breakpoint must be 800px per contract',
      );
    });

    test('timelineDetail breakpoint is 1000px', () {
      expect(
        DSBreakpoints.timelineDetail,
        1000.0,
        reason: 'Timeline detail breakpoint must be 1000px per contract',
      );
    });

    test('masterDetailSideBySide breakpoint is 1200px', () {
      expect(
        DSBreakpoints.masterDetailSideBySide,
        1200.0,
        reason:
            'Master-detail side-by-side breakpoint must be 1200px per contract',
      );
    });

    test('breakpoints are in ascending order', () {
      expect(DSBreakpoints.narrow, lessThan(DSBreakpoints.sidebarCollapse));
      expect(
        DSBreakpoints.sidebarCollapse,
        lessThan(DSBreakpoints.timelineDetail),
      );
      expect(
        DSBreakpoints.timelineDetail,
        lessThanOrEqualTo(DSBreakpoints.masterDetailSideBySide),
      );
    });
  });

  group('Responsive Width Ranges', () {
    test('narrow range covers 0-599px', () {
      expect(DSBreakpoints.narrow, 600);
      // Below 600: no sidebar, search collapses
    });

    test('medium range covers 800-1199px', () {
      expect(DSBreakpoints.sidebarCollapse, 800);
      expect(DSBreakpoints.masterDetailSideBySide, 1200);
      // 800-1199: full sidebar, overlay detail, no inspector
    });

    test('wide range starts at 1200px', () {
      expect(DSBreakpoints.masterDetailSideBySide, 1200);
      // >= 1200: full sidebar, side-by-side detail, inspector visible
    });

    test('sidebar collapse threshold matches shell responsive behavior', () {
      // DSShellResponsive uses sidebarCollapse to decide expanded vs collapsed
      expect(DSBreakpoints.sidebarCollapse, 800);
    });
  });

  group('Breakpoint Spacing', () {
    test('gaps between breakpoints are reasonable (not too tight)', () {
      const gap1 = DSBreakpoints.sidebarCollapse - DSBreakpoints.narrow;
      const gap2 = DSBreakpoints.timelineDetail - DSBreakpoints.sidebarCollapse;
      const gap3 =
          DSBreakpoints.masterDetailSideBySide - DSBreakpoints.timelineDetail;

      expect(
        gap1,
        greaterThanOrEqualTo(100),
        reason: 'Gap between narrow and sidebarCollapse should be >= 100px',
      );
      expect(
        gap2,
        greaterThanOrEqualTo(100),
        reason:
            'Gap between sidebarCollapse and timelineDetail should be >= 100px',
      );
      expect(
        gap3,
        greaterThanOrEqualTo(100),
        reason:
            'Gap between timelineDetail and masterDetail should be >= 100px',
      );
    });
  });

  group('Layout Token Constants', () {
    test('sidebar widths are defined', () {
      expect(DSSpacing.sidebarCollapsed, isPositive);
      expect(DSSpacing.sidebarExpanded, isPositive);
      expect(
        DSSpacing.sidebarExpanded,
        greaterThan(DSSpacing.sidebarCollapsed),
      );
    });

    test('inspector width is defined', () {
      expect(DSSpacing.inspectorWidth, isPositive);
      expect(DSSpacing.inspectorWidth, 360.0);
    });

    test('detail overlay width is defined', () {
      expect(DSSpacing.detailOverlayWidth, isPositive);
      expect(DSSpacing.detailOverlayWidth, 400.0);
    });

    test('topbar height is defined', () {
      expect(DSSpacing.topbarHeight, isPositive);
    });
  });

  group('MasterDetailTemplate responsive transitions', () {
    // MasterDetailTemplate measures the content pane (after sidebar).
    // Use an expanded sidebar (~240) budget when choosing surface widths:
    //   content wide (>=1200)  → surface ~1500
    //   content medium (800-1199) → surface ~1100
    //   content narrow (<800) → surface ~900
    const sidebarItems = [
      DSSidebarItem(id: 'map', label: 'Map', icon: Icons.map),
      DSSidebarItem(id: 'ops', label: 'Operate', icon: Icons.view_kanban),
    ];

    Widget buildHarness({required bool showDetail}) {
      return MaterialApp(
        home: MasterDetailTemplate(
          sidebarItems: sidebarItems,
          selectedIndex: 0,
          onSidebarItemSelected: (_) {},
          title: 'Workspace',
          masterContent: const Center(child: Text('master-panel')),
          detailContent: const Center(child: Text('detail-panel')),
          showDetail: showDetail,
          onDetailClose: () {},
          detailTitle: 'Asset',
        ),
      );
    }

    Future<void> setSurface(WidgetTester tester, Size size) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetDevicePixelRatio);
    }

    testWidgets('wide layout shows master and detail side by side', (
      tester,
    ) async {
      await setSurface(tester, const Size(1500, 800));
      await tester.pumpWidget(buildHarness(showDetail: true));
      await tester.pumpAndSettle();

      expect(find.text('master-panel'), findsOneWidget);
      expect(find.text('detail-panel'), findsOneWidget);
      // Wide mode has no full-screen back app bar.
      expect(find.byTooltip('Back'), findsNothing);
    });

    testWidgets('medium layout keeps master under overlay detail', (
      tester,
    ) async {
      // Content pane ≈ 1100 - ~240 sidebar ≈ 860 → medium overlay range.
      await setSurface(tester, const Size(1100, 800));
      await tester.pumpWidget(buildHarness(showDetail: true));
      await tester.pumpAndSettle();

      expect(find.text('master-panel'), findsOneWidget);
      expect(find.text('detail-panel'), findsOneWidget);
      expect(find.byTooltip('Back'), findsNothing);
    });

    testWidgets('narrow layout shows full-screen detail with back', (
      tester,
    ) async {
      // Content pane ≈ 900 - ~240 sidebar ≈ 660 → full-screen detail.
      await setSurface(tester, const Size(900, 800));
      await tester.pumpWidget(buildHarness(showDetail: true));
      await tester.pumpAndSettle();

      expect(find.text('detail-panel'), findsOneWidget);
      expect(find.byTooltip('Back'), findsOneWidget);
      // Master is replaced in full-screen mode.
      expect(find.text('master-panel'), findsNothing);
    });

    testWidgets('closed detail shows master only', (tester) async {
      await setSurface(tester, const Size(1500, 800));
      await tester.pumpWidget(buildHarness(showDetail: false));
      await tester.pumpAndSettle();

      expect(find.text('master-panel'), findsOneWidget);
      expect(find.text('detail-panel'), findsNothing);
    });
  });
}
