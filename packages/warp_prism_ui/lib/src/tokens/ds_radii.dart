/// ASW Observatory Design Tokens - Border Radii
///
/// Consistent corner rounding for glass/obsidian aesthetic
abstract class DSRadii {
  /// No rounding - sharp edges
  static const double none = 0;

  /// 2px - subtle rounding
  static const double xs = 2;

  /// 4px - slight rounding
  static const double sm = 4;

  /// 6px - default rounding
  static const double md = 6;

  /// 8px - comfortable rounding
  static const double lg = 8;

  /// 12px - pronounced rounding
  static const double xl = 12;

  /// 16px - large rounding
  static const double xxl = 16;

  /// Full circle/pill
  static const double full = 9999;

  // === SEMANTIC RADII ===
  /// Card radius
  static const double card = 8;

  /// Button radius
  static const double button = 6;

  /// Chip/badge radius
  static const double chip = 4;

  /// Input field radius
  static const double input = 6;

  /// Panel radius
  static const double panel = 12;

  /// Modal radius
  static const double modal = 16;
}
