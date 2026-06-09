import 'dart:async';
import 'package:flutter/material.dart';
import '../tokens/tokens.dart';
import 'ds_toast.dart';

/// ASW Observatory Molecule - Toast Manager
///
/// Overlay-based stacking manager for [DSToast] notifications.
///
/// Manages multiple simultaneous toasts with:
/// - Vertical stacking from bottom-right
/// - Animated slide-in / fade-out transitions
/// - Auto-dismiss with configurable duration per toast
/// - Pause-on-hover via [MouseRegion]
/// - Manual dismiss via close button
/// - Action button callbacks
///
/// ## Usage
///
/// ```dart
/// // Get or create the manager for the current overlay context.
/// final manager = DSToastManager.of(context);
///
/// // Show a toast.
/// manager.show(DSToastEntry(
///   id: 'toast-1',
///   severity: DSToastSeverity.success,
///   title: 'Task completed',
///   message: 'All proofs verified',
/// ));
///
/// // Dismiss programmatically.
/// manager.dismiss('toast-1');
/// ```
///
/// ## Riverpod Integration Contract
///
/// The toast system is designed for a Riverpod StateNotifier pattern where
/// the notifier owns dispatching and the widget layer renders:
///
/// ```dart
/// // In the app layer (not in the DS package):
///
/// // 1. Define a notifier that holds toast entries.
/// @riverpod
/// class ToastNotifier extends _$ToastNotifier {
///   @override
///   List<DSToastEntry> build() => [];
///
///   void show(DSToastEntry entry) {
///     state = [...state, entry];
///   }
///
///   void dismiss(String id) {
///     state = state.where((e) => e.id != id).toList();
///   }
///
///   void clear() {
///     state = [];
///   }
/// }
///
/// // 2. In the widget tree, watch the provider and render through
/// //    DSToastManager:
/// //    ref.watch(toastNotifierProvider).whenData((entries) {
/// //      DSToastManager.of(context).replaceAll(entries);
/// //    });
/// ```
class DSToastManager extends StatefulWidget {
  /// The child widget that the toast overlay sits above.
  final Widget child;

  /// Maximum number of toasts shown simultaneously.
  ///
  /// Older toasts beyond this limit are dismissed. Defaults to 5.
  final int maxVisible;

  /// Vertical gap between stacked toasts.
  final double stackGap;

  /// Inset from screen edges.
  final EdgeInsetsGeometry inset;

  const DSToastManager({
    super.key,
    required this.child,
    this.maxVisible = 5,
    this.stackGap = DSSpacing.sm,
    this.inset = const EdgeInsets.only(
      right: DSSpacing.xl,
      bottom: DSSpacing.xl,
    ),
  });

  /// Returns the nearest [DSToastManagerState] from the widget tree.
  ///
  /// Throws if no [DSToastManager] ancestor is found.
  static DSToastManagerState of(BuildContext context) {
    final state = context.findAncestorStateOfType<DSToastManagerState>();
    assert(state != null, 'No DSToastManager found in ancestor tree');
    return state!;
  }

  /// Returns the nearest [DSToastManagerState] or null.
  static DSToastManagerState? maybeOf(BuildContext context) {
    return context.findAncestorStateOfType<DSToastManagerState>();
  }

  @override
  DSToastManagerState createState() => DSToastManagerState();
}

/// State for [DSToastManager].
///
/// Manages the active entry list, auto-dismiss timers, overlay lifecycle,
/// and pause-on-hover state. Call [show], [dismiss], or [clear] to
/// interact with the toast stack programmatically.
class DSToastManagerState extends State<DSToastManager> {
  final List<_ManagedToastEntry> _entries = [];

  OverlayEntry? _overlayEntry;

  /// Set of toast IDs currently hovered (paused).
  final Set<String> _hoveredIds = {};

  @override
  void dispose() {
    _removeOverlay();
    _cancelAllTimers();
    super.dispose();
  }

  // === PUBLIC API ===

  /// Shows a toast notification.
  ///
  /// If a toast with the same [entry.id] already exists, it is replaced.
  /// If the stack exceeds [DSToastManager.maxVisible], the oldest toast
  /// is dismissed.
  void show(DSToastEntry entry) {
    if (!mounted) return;

    setState(() {
      // Replace if same id exists.
      final existingIdx = _entries.indexWhere((e) => e.entry.id == entry.id);
      if (existingIdx >= 0) {
        _entries[existingIdx].timer?.cancel();
        _entries[existingIdx] = _ManagedToastEntry(entry: entry);
      } else {
        _entries.add(_ManagedToastEntry(entry: entry));
      }

      // Enforce max visible limit.
      while (_entries.length > widget.maxVisible) {
        _entries.first.timer?.cancel();
        _entries.removeAt(0);
      }
    });

    // Start auto-dismiss timer for the new/replaced entry.
    _startTimer(entry);

    // Ensure overlay is inserted.
    _ensureOverlay();
  }

  /// Dismisses the toast with the given [id].
  void dismiss(String id) {
    final idx = _entries.indexWhere((e) => e.entry.id == id);
    if (idx < 0) return;

    _entries[idx].timer?.cancel();
    _entries[idx].removing = true;

    // Animate out, then remove.
    setState(() {});
    Future.delayed(DSMotion.slow, () {
      if (!mounted) return;
      setState(() {
        _entries.removeWhere((e) => e.entry.id == id);
        if (_entries.isEmpty) {
          _removeOverlay();
        }
      });
    });
  }

  /// Dismisses all active toasts.
  void clear() {
    _cancelAllTimers();
    _removeOverlay();
    setState(() {
      _entries.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  // === INTERNALS ===

  void _startTimer(DSToastEntry entry) {
    if (entry.duration == Duration.zero) return;

    final idx = _entries.indexWhere((e) => e.entry.id == entry.id);
    if (idx < 0) return;

    _entries[idx].timer?.cancel();
    _entries[idx].timer = Timer(entry.duration, () {
      if (!mounted) return;
      // Skip dismiss if hovered.
      if (_hoveredIds.contains(entry.id)) {
        // Re-queue: the user will un-hover and the timer restarts
        // via [_onHoverChanged].
        _entries[idx].paused = true;
        return;
      }
      dismiss(entry.id);
    });
  }

  void _onHoverChanged(String id, bool isHovered) {
    setState(() {
      if (isHovered) {
        _hoveredIds.add(id);
        // Pause timer.
        final idx = _entries.indexWhere((e) => e.entry.id == id);
        if (idx >= 0) {
          _entries[idx].timer?.cancel();
          _entries[idx].paused = true;
        }
      } else {
        _hoveredIds.remove(id);
        // Restart timer with remaining duration.
        final idx = _entries.indexWhere((e) => e.entry.id == id);
        if (idx >= 0 && _entries[idx].paused) {
          _entries[idx].paused = false;
          // Re-fire with the entry's full duration for simplicity.
          _startTimer(_entries[idx].entry);
        }
      }
    });
  }

  void _ensureOverlay() {
    if (_overlayEntry != null) return;
    _overlayEntry = OverlayEntry(builder: _buildOverlay);
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry?.dispose();
    _overlayEntry = null;
  }

  void _cancelAllTimers() {
    for (final e in _entries) {
      e.timer?.cancel();
    }
  }

  Widget _buildOverlay(BuildContext context) {
    // Parse the inset to get actual pixel values.
    final resolvedInset = _resolvedInset.resolve(Directionality.of(context));

    return Positioned(
      right: resolvedInset.right,
      bottom: resolvedInset.bottom,
      child: _buildStack(),
    );
  }

  EdgeInsets get _resolvedInset {
    final i = widget.inset;
    if (i is EdgeInsets) return i;
    // Fallback for non-EdgeInsets types.
    return const EdgeInsets.only(
      right: DSSpacing.xl,
      bottom: DSSpacing.xl,
    );
  }

  Widget _buildStack() {
    // Use Material + MediaQuery to provide ambient context for text
    // rendering and accessibility.
    return MediaQuery.fromView(
      view: View.of(context),
      child: Material(
        color: DSColors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (int i = 0; i < _entries.length; i++) ...[
              if (i > 0) SizedBox(height: widget.stackGap),
              _buildAnimatedToast(_entries[i]),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedToast(_ManagedToastEntry managed) {
    final isRemoving = managed.removing;
    final entry = managed.entry;

    return AnimatedSlide(
      duration: DSMotion.slow,
      curve: isRemoving ? DSMotion.exit : DSMotion.enter,
      offset: isRemoving ? const Offset(1, 0) : Offset.zero,
      child: AnimatedOpacity(
        duration: DSMotion.slow,
        curve: isRemoving ? DSMotion.exit : DSMotion.enter,
        opacity: isRemoving ? 0.0 : 1.0,
        child: MouseRegion(
          onEnter: (_) => _onHoverChanged(entry.id, true),
          onExit: (_) => _onHoverChanged(entry.id, false),
          child: DSToast(
            entry: entry,
            hovered: _hoveredIds.contains(entry.id),
            onDismiss: () => dismiss(entry.id),
            onAction: () {
              // Dismiss after action by default.
              dismiss(entry.id);
            },
          ),
        ),
      ),
    );
  }
}

/// Internal wrapper pairing a [DSToastEntry] with its lifecycle state.
class _ManagedToastEntry {
  final DSToastEntry entry;
  Timer? timer;
  bool removing;
  bool paused;

  _ManagedToastEntry({required this.entry})
      : removing = false,
        paused = false;
}
