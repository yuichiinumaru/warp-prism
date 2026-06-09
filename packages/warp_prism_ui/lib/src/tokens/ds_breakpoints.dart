/// ASW Observatory Design Tokens - Responsive Breakpoints
///
/// Centralized breakpoint contract for shell, templates, and organisms.
/// All responsive layout decisions MUST reference these values instead of
/// hardcoding pixel thresholds.
///
/// Width ranges:
///   narrow:   < 600px  (search collapses, sidebar hidden, full-screen detail)
///   medium:   600-1199px (collapsed sidebar, overlay detail)
///   wide:     >= 1200px (full sidebar, side-by-side detail)
///
/// Special thresholds:
///   sidebarCollapse: sidebar switches from expanded to collapsed
///   timelineDetail: timeline switches from inline to side-by-side detail
abstract class DSBreakpoints {
  /// Below this width the topbar search bar collapses and
  /// detail panels go full-screen.
  /// Also used as the minimum width before the sidebar is shown at all.
  static const double narrow = 600;

  /// Below this width the sidebar shows in collapsed (icon-only) mode.
  /// Above this width the sidebar is expanded with labels.
  static const double sidebarCollapse = 800;

  /// Above this width the master-detail template shows side-by-side panels.
  /// Below this width it shows overlay or full-screen detail.
  static const double masterDetailSideBySide = 1200;

  /// Above this width the timeline template shows timeline + detail panel
  /// side by side.
  static const double timelineDetail = 1000;
}
