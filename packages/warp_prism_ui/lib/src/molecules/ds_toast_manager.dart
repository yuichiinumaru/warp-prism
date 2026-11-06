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
/// Removal cause for a toast leaving the manager stack (Task 1867 policy).
///
/// The manager hands every removed entry back through [DSToastManager.onHandBack]
/// with one of these reasons; [DSToastManager.onCloseDismissed] fires only for
/// [closed] — never for expiry, eviction, action, or clear.
enum PrismToastRemovalReason {
  /// Explicit close: close-button tap or programmatic `dismiss(id)`.
  closed,

  /// Action-button tap with `dismissOnAction: true`.
  actioned,

  /// Auto-dismiss timer fired (non-sticky entry only).
  expired,

  /// Cap (`maxVisible`) eviction of the oldest entry.
  evicted,

  /// `clear()` removed the whole stack.
  cleared,
}

/// Hand-back callback for removed toasts (Task 1867 policy).
///
/// Receives every entry the manager drops, with its [PrismToastRemovalReason].
/// Telemetry, re-queue, and undo surfaces consume this — never the close path.
typedef PrismToastHandBack =
    void Function(DSToastEntry entry, PrismToastRemovalReason reason);

class DSToastManager extends StatefulWidget {
  /// The child widget that the toast overlay sits above.
  final Widget child;

  /// Maximum number of toasts shown simultaneously.
  ///
  /// Older toasts beyond this limit are dismissed. Defaults to 5.
  /// Evicted entries are handed back via [onHandBack] with
  /// [PrismToastRemovalReason.evicted] — the cap never drops silently.
  final int maxVisible;

  /// Vertical gap between stacked toasts.
  final double stackGap;

  /// Inset from screen edges.
  final EdgeInsetsGeometry inset;

  /// Hand-back for every removed entry (evicted/expired/actioned/cleared/closed).
  ///
  /// Sticky entries (`duration == Duration.zero`) never expire, so they only
  /// arrive here via close, action, eviction, or clear.
  final PrismToastHandBack? onHandBack;

  /// Close-only dismiss callback (Task 1867 policy).
  ///
  /// Fires exactly when the user closes a toast (close-button tap) or the
  /// host dismisses it programmatically via `dismiss(id)` — and never on
  /// timer expiry, cap eviction, action tap, or `clear()`. Auto-dismiss is
  /// not a dismissal decision; it is an expiry.
  final void Function(DSToastEntry entry)? onCloseDismissed;

  const DSToastManager({
    super.key,
    required this.child,
    this.maxVisible = 5,
    this.stackGap = DSSpacing.sm,
    this.inset = const EdgeInsets.only(
      right: DSSpacing.xl,
      bottom: DSSpacing.xl,
    ),
    this.onHandBack,
    this.onCloseDismissed,
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
  /// is evicted and handed back with [PrismToastRemovalReason.evicted].
  /// Entries with `duration == Duration.zero` are sticky: they never start
  /// an auto-dismiss timer and persist until closed, actioned, evicted, or
  /// cleared.
  void show(DSToastEntry entry) {
    if (!mounted) return;

    final evicted = <DSToastEntry>[];
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
        evicted.add(_entries.first.entry);
        _entries.removeAt(0);
      }
    });

    // Hand back cap-evicted entries outside setState (policy: cap never
    // drops silently, and eviction is not a close — no onCloseDismissed).
    for (final removed in evicted) {
      widget.onHandBack?.call(removed, PrismToastRemovalReason.evicted);
    }

    // Force the overlay entry to rebuild so the new/replaced toast renders.
    _overlayEntry?.markNeedsBuild();

    // Start auto-dismiss timer for the new/replaced entry.
    _startTimer(entry);

    // Ensure overlay is inserted.
    _ensureOverlay();
  }

  /// Explicit close: close-button tap or programmatic dismiss.
  ///
  /// This is the ONLY path that fires [DSToastManager.onCloseDismissed].
  /// Timer expiry, cap eviction, and [clear] hand back without it.
  void dismiss(String id) {
    if (!mounted) return;

    final idx = _entries.indexWhere((e) => e.entry.id == id);
    if (idx < 0) return;

    final closed = _entries[idx].entry;
    _entries[idx].timer?.cancel();
    _entries[idx].removing = true;
    widget.onCloseDismissed?.call(closed);

    // Animate out, then remove.
    setState(() {});
    _overlayEntry?.markNeedsBuild();
    Future.delayed(DSMotion.slow, () {
      if (!mounted) return;
      setState(() {
        _entries.removeWhere((e) => e.entry.id == id);
        _hoveredIds.remove(id);
        if (_entries.isEmpty) {
          _removeOverlay();
        } else {
          // Mark overlay dirty for non-empty stacks so remaining toasts render.
          _overlayEntry?.markNeedsBuild();
        }
      });
      widget.onHandBack?.call(closed, PrismToastRemovalReason.closed);
      // Overlay rebuild can drop MouseRegion enter/exit pairing. Re-sync
      // timers from the authoritative [_hoveredIds] set after structural change.
      _resyncHoverTimers();
    });
  }

  /// Aligns timer paused/running state with [_hoveredIds] after list mutations.
  void _resyncHoverTimers() {
    if (!mounted) return;
    for (final managed in List<_ManagedToastEntry>.from(_entries)) {
      final entryId = managed.entry.id;
      final hovered = _hoveredIds.contains(entryId);
      if (hovered) {
        managed.timer?.cancel();
        managed.paused = true;
      } else if (managed.paused) {
        managed.paused = false;
        _startTimer(managed.entry);
      }
    }
  }

  /// Dismisses all active toasts.
  ///
  /// Every removed entry is handed back with [PrismToastRemovalReason.cleared];
  /// clear is never a close, so [DSToastManager.onCloseDismissed] does not fire.
  void clear() {
    if (!mounted) return;

    _cancelAllTimers();
    _removeOverlay();
    final removed = [for (final managed in _entries) managed.entry];
    setState(() {
      _entries.clear();
    });
    for (final entry in removed) {
      widget.onHandBack?.call(entry, PrismToastRemovalReason.cleared);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  // === INTERNALS ===

  void _startTimer(DSToastEntry entry) {
    // Sticky entries never auto-dismiss: Duration.zero means persist until
    // the user or host removes the toast.
    if (entry.duration == Duration.zero) return;

    final idx = _entries.indexWhere((e) => e.entry.id == entry.id);
    if (idx < 0) return;

    // Capture id only — list indices go stale after maxVisible front-removal
    // or other mutations of [_entries] while the timer is outstanding.
    final entryId = entry.id;
    _entries[idx].timer?.cancel();
    _entries[idx].timer = Timer(entry.duration, () {
      if (!mounted) return;
      // Always re-resolve by id; never trust a captured list index.
      final currentIdx = _entries.indexWhere((e) => e.entry.id == entryId);
      if (currentIdx < 0) return;
      // Skip dismiss if hovered.
      if (_hoveredIds.contains(entryId)) {
        // Re-queue: the user will un-hover and the timer restarts
        // via [_onHoverChanged].
        _entries[currentIdx].paused = true;
        return;
      }
      // Expiry is not a close: remove silently with an expired hand-back.
      final expired = _entries[currentIdx].entry;
      _entries[currentIdx].timer?.cancel();
      _entries[currentIdx].removing = true;
      setState(() {});
      _overlayEntry?.markNeedsBuild();
      Future.delayed(DSMotion.slow, () {
        if (!mounted) return;
        setState(() {
          _entries.removeWhere((e) => e.entry.id == entryId);
          _hoveredIds.remove(entryId);
          if (_entries.isEmpty) {
            _removeOverlay();
          } else {
            _overlayEntry?.markNeedsBuild();
          }
        });
        widget.onHandBack?.call(expired, PrismToastRemovalReason.expired);
        _resyncHoverTimers();
      });
    });
  }

  void _onHoverChanged(String id, bool isHovered) {
    if (!mounted) return;

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
    _overlayEntry?.markNeedsBuild();
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

    // Constrain the overlay content to the available viewport size.
    // Without a bounded height, Positioned(right, bottom) yields
    // unconstrained BoxConstraints and the accent bar's fixed height
    // collapses to 0 because the cross-axis constraint is clamped.
    final viewHeight =
        View.of(context).physicalSize.height /
        View.of(context).devicePixelRatio;

    return Positioned(
      right: resolvedInset.right,
      bottom: resolvedInset.bottom,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: viewHeight),
        child: _buildStack(),
      ),
    );
  }

  EdgeInsets get _resolvedInset {
    final i = widget.inset;
    if (i is EdgeInsets) return i;
    // Fallback for non-EdgeInsets types.
    return const EdgeInsets.only(right: DSSpacing.xl, bottom: DSSpacing.xl);
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

  /// Action-tap removal: hands back with [PrismToastRemovalReason.actioned].
  ///
  /// Never fires [DSToastManager.onCloseDismissed] — an action is not a close.
  void _removeAfterAction(DSToastEntry entry) {
    if (!mounted) return;

    final idx = _entries.indexWhere((e) => e.entry.id == entry.id);
    if (idx < 0) return;

    _entries[idx].timer?.cancel();
    _entries[idx].removing = true;

    setState(() {});
    _overlayEntry?.markNeedsBuild();
    Future.delayed(DSMotion.slow, () {
      if (!mounted) return;
      setState(() {
        _entries.removeWhere((e) => e.entry.id == entry.id);
        _hoveredIds.remove(entry.id);
        if (_entries.isEmpty) {
          _removeOverlay();
        } else {
          _overlayEntry?.markNeedsBuild();
        }
      });
      widget.onHandBack?.call(entry, PrismToastRemovalReason.actioned);
      _resyncHoverTimers();
    });
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
            onAction: entry.actionLabel == null
                ? null
                : () {
                    // Prefer entry-owned action; action tap is not a close.
                    entry.onAction?.call();
                    if (entry.dismissOnAction) {
                      _removeAfterAction(entry);
                    }
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

  _ManagedToastEntry({required this.entry}) : removing = false, paused = false;
}
