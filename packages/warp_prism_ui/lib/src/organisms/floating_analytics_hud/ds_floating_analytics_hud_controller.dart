import 'package:flutter/material.dart';

// =============================================================================
// Controller (testable drag + minimize)
// =============================================================================

/// Imperative handle for floating analytics HUD position / minimize / close.
///
/// Widget tests inject a controller and call [minimize], [expand], [moveTo],
/// or [dragBy] without pointer simulation when preferred. Pointer drag still
/// updates the same controller state when attached.
class DSFloatingAnalyticsHudController extends ChangeNotifier {
  /// Top-left panel offset relative to the host stage.
  Offset offset;

  /// Whether the multi-section body is collapsed to the title strip.
  bool isMinimized;

  /// Whether the overlay is shown. [close] sets this to false.
  bool isVisible;

  /// Creates a controller with optional seed position / minimize / visibility.
  DSFloatingAnalyticsHudController({
    this.offset = Offset.zero,
    this.isMinimized = false,
    this.isVisible = true,
  });

  /// Jump to an absolute offset (clamped by the attached HUD when known).
  void moveTo(Offset next) {
    if (offset == next) return;
    offset = next;
    notifyListeners();
  }

  /// Apply a drag delta (pointer or test).
  void dragBy(Offset delta) {
    if (delta == Offset.zero) return;
    offset += delta;
    notifyListeners();
  }

  /// Collapse body to title strip.
  void minimize() {
    if (isMinimized) return;
    isMinimized = true;
    notifyListeners();
  }

  /// Expand multi-section body.
  void expand() {
    if (!isMinimized) return;
    isMinimized = false;
    notifyListeners();
  }

  /// Toggle minimize / expand.
  void toggleMinimized() {
    isMinimized = !isMinimized;
    notifyListeners();
  }

  /// Hide the HUD (fires the host `onClose` callback when wired).
  void close() {
    if (!isVisible) return;
    isVisible = false;
    notifyListeners();
  }

  /// Show the HUD after [close].
  void show() {
    if (isVisible) return;
    isVisible = true;
    notifyListeners();
  }

  /// Reset to seed values without disposing.
  void reset({
    Offset offset = Offset.zero,
    bool minimized = false,
    bool visible = true,
  }) {
    this.offset = offset;
    isMinimized = minimized;
    isVisible = visible;
    notifyListeners();
  }
}
