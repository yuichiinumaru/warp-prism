import 'package:meta/meta.dart';

import '../input/action_availability.dart';

/// Shell-slot router semantics (IDS, pure Dart).
///
/// Draw-derived focus shape (Figcraft A7/A8 idea-only donor): a shell is a
/// set of [ShellSlot]s; each slot hosts ordered [ShellRegion]s and names one
/// active pane. A layout *commit* freezes the last known-good arrangement;
/// the focus-return token is always derived from that committed layout, never
/// from transient drag/hover/animation state. Widgets perform the actual
/// focus/scroll mechanics (ADS); this file owns only the deterministic
/// token semantics: which pane focus returns to ([refocus]) and which region
/// a scroll edge resolves to ([scrollTo]).
///
/// Determinism: same committed layout + same trigger ⇒ same token. No
/// wall-clock, no randomness, no IO.
///
/// Consumes Task 1868's frozen eligibility shape ([CapabilityState] /
/// [availabilityFor]) for gated sidebar rows: a row whose capability is
/// absent resolves to deny-with-reason and is never silently enabled. This
/// file does not evaluate capabilities; it only projects the frozen outcome.
///
/// Lifecycle: EXPERIMENTAL (Task 1873). Spec + fake + suite only; no barrel
/// export, no STABLE promotion in this task.
enum ShellSlot {
  /// Navigation slot (sidebar sections/rows).
  sidebar,

  /// Primary content slot (tab panes, split leading/trailing).
  content,

  /// Detail/inspector slot (wide side-by-side or overlay drawer).
  inspector,
}

/// A focusable region inside a shell slot.
///
/// Draw-derived: a region is the stable identity focus returns to. The
/// [scrollOffset] is an opaque caller-space number (pixels, item index, or
/// fraction — the contract never interprets it); ADS clamps and applies it.
@immutable
final class ShellRegion {
  /// Stable region identity (e.g. `'sessions.list'`, `'control.panel'`).
  final String id;

  /// Slot hosting this region.
  final ShellSlot slot;

  /// Pane identity within the slot (e.g. tab id, split pane id).
  final String paneId;

  /// Opaque scroll position last recorded for this region.
  final double scrollOffset;

  const ShellRegion({
    required this.id,
    required this.slot,
    required this.paneId,
    this.scrollOffset = 0,
  });

  ShellRegion copyWith({
    String? id,
    ShellSlot? slot,
    String? paneId,
    double? scrollOffset,
  }) {
    return ShellRegion(
      id: id ?? this.id,
      slot: slot ?? this.slot,
      paneId: paneId ?? this.paneId,
      scrollOffset: scrollOffset ?? this.scrollOffset,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShellRegion &&
          other.id == id &&
          other.slot == slot &&
          other.paneId == paneId &&
          other.scrollOffset == scrollOffset);

  @override
  int get hashCode => Object.hash(id, slot, paneId, scrollOffset);

  @override
  String toString() => 'ShellRegion(id: "$id", slot: $slot, pane: "$paneId")';
}

/// A committed shell arrangement: ordered regions plus the active pane per
/// slot. Only committed layouts feed the focus token; transient layouts
/// (mid-drag, mid-animation) must never be committed.
@immutable
final class ShellLayout {
  /// Ordered regions; order is the traversal/scroll order.
  final List<ShellRegion> regions;

  /// Active pane per slot. Missing slots mean "no active pane".
  final Map<ShellSlot, String> activePaneBySlot;

  const ShellLayout({
    this.regions = const [],
    this.activePaneBySlot = const {},
  });

  /// Active pane for [slot], or null when the slot has none.
  String? activePane(ShellSlot slot) => activePaneBySlot[slot];

  /// Regions hosted in [slot], in traversal order.
  List<ShellRegion> regionsIn(ShellSlot slot) =>
      regions.where((region) => region.slot == slot).toList(growable: false);

  /// True when [paneId] is present in any region.
  bool containsPane(String paneId) =>
      regions.any((region) => region.paneId == paneId);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ShellLayout) return false;
    if (activePaneBySlot.length != other.activePaneBySlot.length) {
      return false;
    }
    for (final entry in activePaneBySlot.entries) {
      if (other.activePaneBySlot[entry.key] != entry.value) return false;
    }
    if (regions.length != other.regions.length) return false;
    for (var i = 0; i < regions.length; i++) {
      if (regions[i] != other.regions[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
    Object.hashAll(regions),
    Object.hashAll(
      activePaneBySlot.entries.map(
        (entry) => Object.hash(entry.key, entry.value),
      ),
    ),
  );

  @override
  String toString() =>
      'ShellLayout(regions: ${regions.length}, active: $activePaneBySlot)';
}

/// Focus-return token derived from the last committed layout.
///
/// The token names the pane focus must return to after a layout transition
/// (tab switch, inspector open/close, breakpoint reflow). ADS resolves the
/// token to a real [FocusNode]; when the token pane is gone, ADS follows the
/// documented fallback chain (slot active pane → content active pane →
/// first region). The chain lives here so every host resolves identically.
@immutable
final class FocusReturnToken {
  /// Pane focus returns to.
  final String paneId;

  /// Slot hosting the pane at commit time.
  final ShellSlot slot;

  /// Region identity at commit time (may be empty when unknown).
  final String regionId;

  const FocusReturnToken({
    required this.paneId,
    required this.slot,
    this.regionId = '',
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FocusReturnToken &&
          other.paneId == paneId &&
          other.slot == slot &&
          other.regionId == regionId);

  @override
  int get hashCode => Object.hash(paneId, slot, regionId);

  @override
  String toString() =>
      'FocusReturnToken(pane: "$paneId", slot: $slot, region: "$regionId")';
}

/// Scroll edge resolution for a region: the clamped offset ADS should apply.
@immutable
final class ScrollEdge {
  /// Region the scroll applies to.
  final String regionId;

  /// Clamped offset in the caller's opaque units.
  final double offset;

  /// True when the requested offset was outside bounds and got clamped.
  final bool clamped;

  const ScrollEdge({
    required this.regionId,
    required this.offset,
    required this.clamped,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScrollEdge &&
          other.regionId == regionId &&
          other.offset == offset &&
          other.clamped == clamped);

  @override
  int get hashCode => Object.hash(regionId, offset, clamped);

  @override
  String toString() =>
      'ScrollEdge(region: "$regionId", offset: $offset, clamped: $clamped)';
}

/// Gated sidebar row: a row identity plus the product-reported capability
/// presence behind it (Task 1868 frozen shape). The machine projects each
/// row through [availabilityFor] so gated rows resolve fail-closed.
@immutable
final class ShellRowGate {
  /// Stable row identity (sidebar row id).
  final String rowId;

  /// Product-reported capability presence for this row.
  final CapabilityState capability;

  const ShellRowGate({required this.rowId, required this.capability});

  /// Frozen 1868 projection: present ⇒ allow, absent ⇒ deny-with-reason.
  ActionAvailability get availability => availabilityFor(capability);

  /// True when the row may render enabled (allow or constrain).
  bool get isEnabled => !availability.isDenied;
}

/// Deterministic shell-slot state machine.
///
/// Holds the last committed layout; every token derives from it. Transition
/// triggers are explicit method calls ([commitLayout], [refocus], [scrollTo])
/// so transitions never depend on animation or frame timing.
final class ShellSlotMachine {
  ShellLayout _committed;
  final List<void Function(ShellLayout previous, ShellLayout next)> _listeners =
      [];
  bool _isDisposed = false;

  ShellSlotMachine({ShellLayout initial = const ShellLayout()})
    : _committed = initial;

  /// Last committed layout. Tokens always derive from this snapshot.
  ShellLayout get committed => _committed;

  /// True after [dispose].
  bool get isDisposed => _isDisposed;

  /// Commits [next] as the last known-good arrangement and notifies.
  ShellLayout commitLayout(ShellLayout next) {
    if (_isDisposed) {
      throw StateError('Cannot commit layout after disposal');
    }
    final previous = _committed;
    _committed = next;
    final listeners = List.of(_listeners);
    for (final listener in listeners) {
      listener(previous, next);
    }
    return _committed;
  }

  /// Derives the focus-return token for [paneId] from the committed layout.
  ///
  /// When [paneId] is null, the content slot's active pane wins, then the
  /// first committed region. The result is deterministic for a fixed commit.
  FocusReturnToken deriveFocusToken({String? paneId}) {
    final committed = _committed;
    if (paneId != null) {
      final match = _findRegionForPane(committed, paneId);
      if (match != null) {
        return FocusReturnToken(
          paneId: paneId,
          slot: match.slot,
          regionId: match.id,
        );
      }
    }
    final contentActive = committed.activePane(ShellSlot.content);
    if (contentActive != null) {
      final match = _findRegionForPane(committed, contentActive);
      return FocusReturnToken(
        paneId: contentActive,
        slot: match?.slot ?? ShellSlot.content,
        regionId: match?.id ?? '',
      );
    }
    if (committed.regions.isNotEmpty) {
      final first = committed.regions.first;
      return FocusReturnToken(
        paneId: first.paneId,
        slot: first.slot,
        regionId: first.id,
      );
    }
    return const FocusReturnToken(paneId: '', slot: ShellSlot.content);
  }

  /// Refocus resolution with the documented fallback chain.
  ///
  /// 1. Requested pane when still committed; 2. its slot's active pane;
  /// 3. content slot active pane; 4. first committed region; 5. empty token
  /// (no focus target — ADS must not invent one). Covers the edge cases:
  /// token pane removed, slot emptied, layout cleared.
  FocusReturnToken refocus({String? paneId}) {
    final committed = _committed;
    if (paneId != null && committed.containsPane(paneId)) {
      return deriveFocusToken(paneId: paneId);
    }
    if (paneId != null) {
      final slot = _slotForPane(committed, paneId);
      if (slot != null) {
        final slotActive = committed.activePane(slot);
        if (slotActive != null && committed.containsPane(slotActive)) {
          return deriveFocusToken(paneId: slotActive);
        }
      }
    }
    final contentActive = committed.activePane(ShellSlot.content);
    if (contentActive != null && committed.containsPane(contentActive)) {
      return deriveFocusToken(paneId: contentActive);
    }
    if (committed.regions.isNotEmpty) {
      return deriveFocusToken();
    }
    return const FocusReturnToken(paneId: '', slot: ShellSlot.content);
  }

  /// Scroll edge resolution: clamps [requestedOffset] into `[0, maxOffset]`.
  ///
  /// Unknown regions resolve to the first committed region (stable fallback);
  /// a caller [maxOffset] < 0 is treated as 0. Never throws for unknown ids —
  /// the edge case is a clamped fallback, not an exception.
  ScrollEdge scrollTo(
    String regionId, {
    double requestedOffset = 0,
    double maxOffset = double.infinity,
  }) {
    final committed = _committed;
    final ceiling = maxOffset.isNaN || maxOffset < 0 ? 0.0 : maxOffset;
    var targetId = regionId;
    if (!committed.regions.any((region) => region.id == regionId)) {
      if (committed.regions.isEmpty) {
        return ScrollEdge(
          regionId: regionId,
          offset: 0,
          clamped: requestedOffset != 0,
        );
      }
      targetId = committed.regions.first.id;
    }
    final clampedOffset = requestedOffset.clamp(0.0, ceiling).toDouble();
    return ScrollEdge(
      regionId: targetId,
      offset: clampedOffset,
      clamped: clampedOffset != requestedOffset || targetId != regionId,
    );
  }

  /// Resolves gated sidebar rows through the frozen 1868 outcome shape.
  ///
  /// Fail-closed: absent capabilities deny with reason. Returns the row ids
  /// that may render enabled, in input order.
  List<String> enabledRows(List<ShellRowGate> rows) {
    final enabled = <String>[];
    for (final row in rows) {
      if (row.isEnabled) enabled.add(row.rowId);
    }
    return enabled;
  }

  /// Adds a commit listener.
  void addListener(
    void Function(ShellLayout previous, ShellLayout next) listener,
  ) {
    if (_isDisposed) return;
    _listeners.add(listener);
  }

  /// Removes a commit listener.
  void removeListener(
    void Function(ShellLayout previous, ShellLayout next) listener,
  ) {
    _listeners.remove(listener);
  }

  /// Disposes the machine and clears listeners.
  void dispose() {
    _isDisposed = true;
    _listeners.clear();
  }

  static ShellRegion? _findRegionForPane(ShellLayout layout, String paneId) {
    for (final region in layout.regions) {
      if (region.paneId == paneId) return region;
    }
    return null;
  }

  static ShellSlot? _slotForPane(ShellLayout layout, String paneId) {
    for (final region in layout.regions) {
      if (region.paneId == paneId) return region.slot;
    }
    final active = layout.activePaneBySlot.entries;
    for (final entry in active) {
      if (entry.value == paneId) return entry.key;
    }
    return null;
  }
}

/// Deterministic reference catalog for the shell-slot contract.
///
/// Supplies the same committed layouts the conformance suite stages, so the
/// fake and the machine agree by construction. No time, no randomness.
@immutable
final class ReferenceShellCatalog {
  /// Two-pane wide layout: nav sidebar + sessions/content + control pane.
  static ShellLayout wideControlLayout() {
    return const ShellLayout(
      regions: [
        ShellRegion(id: 'nav.sessions', slot: ShellSlot.sidebar, paneId: 'nav'),
        ShellRegion(
          id: 'sessions.list',
          slot: ShellSlot.content,
          paneId: 'sessions',
        ),
        ShellRegion(
          id: 'control.panel',
          slot: ShellSlot.inspector,
          paneId: 'control',
        ),
      ],
      activePaneBySlot: {
        ShellSlot.sidebar: 'nav',
        ShellSlot.content: 'sessions',
        ShellSlot.inspector: 'control',
      },
    );
  }

  /// Narrow single-pane layout: content only (sidebar/inspector folded).
  static ShellLayout narrowSingleLayout() {
    return const ShellLayout(
      regions: [
        ShellRegion(
          id: 'sessions.list',
          slot: ShellSlot.content,
          paneId: 'sessions',
        ),
      ],
      activePaneBySlot: {ShellSlot.content: 'sessions'},
    );
  }

  /// Empty layout: no committed regions (refocus/scroll_to edge stage).
  static ShellLayout emptyLayout() => const ShellLayout();
}
