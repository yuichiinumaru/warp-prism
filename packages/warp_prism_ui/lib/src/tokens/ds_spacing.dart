/// ASW Observatory Design Tokens - Spacing
///
/// Consistent spacing scale for information-dense layouts
abstract class DSSpacing {
  // === BASE SCALE ===
  /// 2px - micro spacing
  static const double xxs = 2;

  /// 4px - tight spacing
  static const double xs = 4;

  /// 8px - compact spacing
  static const double sm = 8;

  /// 12px - default tight
  static const double md = 12;

  /// 16px - default comfortable
  static const double lg = 16;

  /// 20px - comfortable
  static const double xl = 20;

  /// 24px - spacious
  static const double xxl = 24;

  /// 32px - section spacing
  static const double xxxl = 32;

  /// 48px - large section spacing
  static const double huge = 48;

  /// 64px - page section spacing
  static const double massive = 64;

  // === SEMANTIC SPACING ===
  /// Inset padding for cards/panels
  static const double insetCard = 16;

  /// Inset padding for compact cards
  static const double insetCardCompact = 12;

  /// Gap between items in a list
  static const double gapList = 8;

  /// Gap between items in a compact list
  static const double gapListCompact = 4;

  /// Gap between sections
  static const double gapSection = 24;

  /// Sidebar width - collapsed
  static const double sidebarCollapsed = 64;

  /// Sidebar width - expanded
  static const double sidebarExpanded = 240;

  /// Inspector panel width (canvas overlay / compact inspector)
  static const double inspectorWidth = 360;

  /// Master-detail / responsive detail overlay drawer width (medium breakpoint)
  static const double detailOverlayWidth = 400;

  /// Top bar height
  static const double topbarHeight = 56;

  /// Card minimum height
  static const double cardMinHeight = 80;

  /// Icon button size
  static const double iconButtonSize = 40;

  /// Icon button size - compact
  static const double iconButtonSizeCompact = 32;
}
