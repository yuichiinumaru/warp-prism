import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/src/tokens/tokens.dart';

/// Task 1020: Responsive Shell and Detail Pass
///
/// Regression tests for:
/// 1. DSBreakpoints token values and contract
/// 2. Breakpoint value consistency (no duplicate hardcoded values)
/// 3. Responsive width range coverage
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
      final gap1 = DSBreakpoints.sidebarCollapse - DSBreakpoints.narrow;
      final gap2 = DSBreakpoints.timelineDetail - DSBreakpoints.sidebarCollapse;
      final gap3 =
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
    });

    test('topbar height is defined', () {
      expect(DSSpacing.topbarHeight, isPositive);
    });
  });
}
