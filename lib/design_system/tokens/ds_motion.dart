/// ASW Observatory Design Tokens - Motion/Animation
/// 
/// Consistent animation curves and durations
abstract class DSMotion {
  // === DURATIONS ===
  /// Instant - no animation
  static const Duration instant = Duration.zero;
  
  /// Fast - micro interactions
  static const Duration fast = Duration(milliseconds: 100);
  
  /// Normal - standard interactions
  static const Duration normal = Duration(milliseconds: 200);
  
  /// Slow - emphasis animations
  static const Duration slow = Duration(milliseconds: 300);
  
  /// Slower - major transitions
  static const Duration slower = Duration(milliseconds: 400);
  
  /// Slowest - dramatic reveals
  static const Duration slowest = Duration(milliseconds: 500);
  
  // === CURVES ===
  /// Standard easing - most interactions
  static const Curve standard = Curves.easeInOut;
  
  /// Enter easing - elements appearing
  static const Curve enter = Curves.easeOut;
  
  /// Exit easing - elements disappearing
  static const Curve exit = Curves.easeIn;
  
  /// Emphasized easing - dramatic transitions
  static const Curve emphasized = Curves.easeInOutCubic;
  
  /// Spring easing - playful bounce
  static const Curve spring = Curves.elasticOut;
  
  /// Linear - constant speed
  static const Curve linear = Curves.linear;
  
  // === SEMANTIC ANIMATIONS ===
  /// Hover state transition
  static const Duration hoverDuration = Duration(milliseconds: 150);
  static const Curve hoverCurve = Curves.easeOut;
  
  /// Focus state transition
  static const Duration focusDuration = Duration(milliseconds: 100);
  static const Curve focusCurve = Curves.easeOut;
  
  /// Page transition
  static const Duration pageDuration = Duration(milliseconds: 300);
  static const Curve pageCurve = Curves.easeInOutCubic;
  
  /// Panel expand/collapse
  static const Duration panelDuration = Duration(milliseconds: 250);
  static const Curve panelCurve = Curves.easeInOut;
  
  /// List item stagger delay
  static const Duration staggerDelay = Duration(milliseconds: 50);
}
