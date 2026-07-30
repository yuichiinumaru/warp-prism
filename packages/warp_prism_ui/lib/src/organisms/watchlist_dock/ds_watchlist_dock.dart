import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../atoms/ds_badge.dart';
import '../../atoms/ds_glass_panel.dart';
import '../../atoms/ds_icon.dart';
import '../../atoms/ds_text.dart';
import '../../tokens/tokens.dart';

// =============================================================================
// Models
// =============================================================================

/// Pinned entity entry for [DSWatchlistDock].
///
/// Domain-agnostic fixture model — agents, tasks, places, assets. No live
/// pin store, no MapLibre fly-to engine.
@immutable
class DSWatchlistItem {
  /// Stable identity within the dock.
  final String id;

  /// Primary display label.
  final String label;

  /// Optional secondary line (type, region, owner).
  final String? subtitle;

  /// Domain entity kind (e.g. `"agent"`, `"task"`, `"place"`).
  final String entityType;

  /// Optional leading icon (falls back to type-based default).
  final IconData? icon;

  /// Optional accent color for the type glyph.
  final Color? color;

  /// Optional WGS84 latitude for locate/select consumers.
  final double? latitude;

  /// Optional WGS84 longitude for locate/select consumers.
  final double? longitude;

  const DSWatchlistItem({
    required this.id,
    required this.label,
    this.subtitle,
    required this.entityType,
    this.icon,
    this.color,
    this.latitude,
    this.longitude,
  });

  /// Whether this entry carries spatial coordinates.
  bool get hasCoordinates => latitude != null && longitude != null;

  DSWatchlistItem copyWith({
    String? id,
    String? label,
    String? subtitle,
    String? entityType,
    IconData? icon,
    Color? color,
    double? latitude,
    double? longitude,
    bool clearSubtitle = false,
    bool clearIcon = false,
    bool clearColor = false,
    bool clearLatitude = false,
    bool clearLongitude = false,
  }) {
    return DSWatchlistItem(
      id: id ?? this.id,
      label: label ?? this.label,
      subtitle: clearSubtitle ? null : (subtitle ?? this.subtitle),
      entityType: entityType ?? this.entityType,
      icon: clearIcon ? null : (icon ?? this.icon),
      color: clearColor ? null : (color ?? this.color),
      latitude: clearLatitude ? null : (latitude ?? this.latitude),
      longitude: clearLongitude ? null : (longitude ?? this.longitude),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DSWatchlistItem &&
        other.id == id &&
        other.label == label &&
        other.subtitle == subtitle &&
        other.entityType == entityType &&
        other.icon == icon &&
        other.color == color &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode => Object.hash(
    id,
    label,
    subtitle,
    entityType,
    icon,
    color,
    latitude,
    longitude,
  );
}

// =============================================================================
// Fixtures
// =============================================================================

/// Shared fixture catalog for gallery / tests (Task 1509).
abstract final class DSWatchlistFixtures {
  /// Default pinned set used by gallery demos.
  static const List<DSWatchlistItem> defaultItems = <DSWatchlistItem>[
    DSWatchlistItem(
      id: 'agent-orion',
      label: 'Orion Scout',
      subtitle: 'agent · map sector A',
      entityType: 'agent',
      icon: Icons.smart_toy_outlined,
      color: DSColors.accentCyan,
      latitude: 37.7749,
      longitude: -122.4194,
    ),
    DSWatchlistItem(
      id: 'task-1509',
      label: 'Stage chrome pack',
      subtitle: 'task · Ready For Review',
      entityType: 'task',
      icon: Icons.task_outlined,
      color: DSColors.accentViolet,
    ),
    DSWatchlistItem(
      id: 'place-obs',
      label: 'Observatory Node',
      subtitle: 'place · HQ anchor',
      entityType: 'place',
      icon: Icons.place_outlined,
      color: DSColors.accentGold,
      latitude: 51.5074,
      longitude: -0.1278,
    ),
    DSWatchlistItem(
      id: 'skill-recon',
      label: 'Recon Sweep',
      subtitle: 'skill · OSINT family',
      entityType: 'skill',
      icon: Icons.psychology_outlined,
      color: DSColors.statusInfo,
    ),
  ];
}

// =============================================================================
// Organism
// =============================================================================

/// ASW Observatory Organism — Watchlist Dock
///
/// Compact pinned-entity list for stage chrome. Supports expand/collapse,
/// select (focus / fly-to handoff), and unpin. Fixture-first / read-only pin
/// set — no live store, no MapLibre.
///
/// EPIC-15 O-11 / Task 1509.
class DSWatchlistDock extends StatefulWidget {
  /// Pinned items (order preserved).
  final List<DSWatchlistItem> items;

  /// Called when a row is activated (tap / keyboard).
  final ValueChanged<DSWatchlistItem>? onSelect;

  /// Called when the user unpins an item. Parent owns the list in controlled
  /// mode; uncontrolled mode removes the item internally then fires this.
  final ValueChanged<DSWatchlistItem>? onUnpin;

  /// Called when the dock expand/collapse state changes.
  final ValueChanged<bool>? onExpandedChanged;

  /// Controlled expansion. When non-null, parent owns expand state.
  final bool? expanded;

  /// Seed expansion for uncontrolled mode.
  final bool initiallyExpanded;

  /// Panel title.
  final String title;

  /// Empty-state message.
  final String emptyLabel;

  /// When true and [items] is empty, renders a compact empty placeholder
  /// (still visible so gallery/tests can assert). Defaults to true.
  final bool showWhenEmpty;

  /// Whether to wrap content in [DSGlassPanel].
  final bool wrapInGlass;

  /// Optional semantic label for the panel region.
  final String semanticLabel;

  /// Currently selected item id (highlight only; parent-owned).
  final String? selectedId;

  const DSWatchlistDock({
    super.key,
    required this.items,
    this.onSelect,
    this.onUnpin,
    this.onExpandedChanged,
    this.expanded,
    this.initiallyExpanded = true,
    this.title = 'Watchlist',
    this.emptyLabel = 'No pinned entities',
    this.showWhenEmpty = true,
    this.wrapInGlass = true,
    this.semanticLabel = 'Watchlist dock',
    this.selectedId,
  });

  bool get isExpansionControlled => expanded != null;

  // --- Stable keys ---

  static const Key panelRegionKey = Key('ds-watchlist-dock');
  static const Key expandToggleKey = Key('ds-watchlist-expand');
  static const Key emptyPlaceholderKey = Key('ds-watchlist-empty');
  static const Key listKey = Key('ds-watchlist-list');

  static Key itemRowKey(String id) => Key('ds-watchlist-item-$id');

  static Key unpinKey(String id) => Key('ds-watchlist-unpin-$id');

  static String expandSemanticLabel({required bool expanded}) =>
      expanded ? 'Collapse watchlist' : 'Expand watchlist';

  static String itemSemanticLabel(DSWatchlistItem item) =>
      '${item.label}, ${item.entityType}';

  static String unpinSemanticLabel(String label) => 'Unpin $label';

  /// Default glyph for a known entity type.
  static IconData defaultIconForType(String entityType) {
    switch (entityType.toLowerCase()) {
      case 'agent':
        return DSIcons.agent;
      case 'skill':
        return DSIcons.skill;
      case 'task':
        return DSIcons.task;
      case 'workflow':
        return DSIcons.workflow;
      case 'place':
      case 'location':
        return Icons.place_outlined;
      default:
        return Icons.bookmark_outline;
    }
  }

  /// Default accent for a known entity type.
  static Color defaultColorForType(String entityType) {
    switch (entityType.toLowerCase()) {
      case 'agent':
        return DSColors.accentCyan;
      case 'skill':
        return DSColors.statusInfo;
      case 'task':
        return DSColors.accentViolet;
      case 'workflow':
        return DSColors.accentGold;
      case 'place':
      case 'location':
        return DSColors.statusSuccess;
      default:
        return DSColors.textSecondary;
    }
  }

  @override
  State<DSWatchlistDock> createState() => _DSWatchlistDockState();
}

class _DSWatchlistDockState extends State<DSWatchlistDock> {
  late bool _uncontrolledExpanded;
  late List<DSWatchlistItem> _uncontrolledItems;
  bool _ownsItems = false;

  @override
  void initState() {
    super.initState();
    _uncontrolledExpanded = widget.initiallyExpanded;
    // When parent provides onUnpin but no external list mutation, we still
    // treat [items] as the source of truth each build unless we own a local
    // copy after first unpin in uncontrolled UX demos.
    _uncontrolledItems = List<DSWatchlistItem>.from(widget.items);
  }

  @override
  void didUpdateWidget(covariant DSWatchlistDock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_ownsItems && oldWidget.items != widget.items) {
      _uncontrolledItems = List<DSWatchlistItem>.from(widget.items);
    }
    // Parent replaced the list — resume controlled-from-props mode.
    if (oldWidget.items != widget.items &&
        !identical(oldWidget.items, widget.items)) {
      // Prefer parent list when it changes (standard controlled pattern).
      if (widget.onUnpin == null || widget.items != oldWidget.items) {
        _ownsItems = false;
        _uncontrolledItems = List<DSWatchlistItem>.from(widget.items);
      }
    }
  }

  bool get _expanded => widget.expanded ?? _uncontrolledExpanded;

  List<DSWatchlistItem> get _items {
    // Prefer live widget.items unless we locally own after unpin without
    // parent rewrite (demo convenience). When parent updates items, didUpdate
    // resets ownership.
    if (_ownsItems) return _uncontrolledItems;
    return widget.items;
  }

  void _toggleExpanded() {
    final next = !_expanded;
    if (!widget.isExpansionControlled) {
      setState(() => _uncontrolledExpanded = next);
    }
    widget.onExpandedChanged?.call(next);
  }

  void _select(DSWatchlistItem item) {
    HapticFeedback.selectionClick();
    widget.onSelect?.call(item);
  }

  void _unpin(DSWatchlistItem item) {
    HapticFeedback.lightImpact();
    if (widget.onUnpin == null) {
      // Local demo ownership so gallery can unpin without a host.
      setState(() {
        _ownsItems = true;
        _uncontrolledItems = _items
            .where((e) => e.id != item.id)
            .toList(growable: false);
      });
    } else {
      // Still drop locally for immediate UX when parent is slow; parent
      // rewrite wins on next didUpdateWidget.
      setState(() {
        _ownsItems = true;
        _uncontrolledItems = _items
            .where((e) => e.id != item.id)
            .toList(growable: false);
      });
      widget.onUnpin!(item);
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    final expanded = _expanded;

    if (items.isEmpty && !widget.showWhenEmpty) {
      return const SizedBox.shrink();
    }

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(count: items.length, expanded: expanded),
        if (expanded) ...[
          const SizedBox(height: DSSpacing.xs),
          if (items.isEmpty) _buildEmpty() else _buildList(items),
        ],
      ],
    );

    final content = widget.wrapInGlass
        ? DSGlassPanel(padding: const EdgeInsets.all(DSSpacing.sm), child: body)
        : Padding(padding: const EdgeInsets.all(DSSpacing.sm), child: body);

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: widget.semanticLabel,
      child: KeyedSubtree(key: DSWatchlistDock.panelRegionKey, child: content),
    );
  }

  Widget _buildHeader({required int count, required bool expanded}) {
    return Row(
      children: [
        const DSIcon(
          Icons.bookmarks_outlined,
          size: 16,
          color: DSColors.accentCyan,
        ),
        const SizedBox(width: DSSpacing.xs),
        Expanded(
          child: DSText.labelLarge(widget.title, color: DSColors.textPrimary),
        ),
        DSBadge.count(
          count,
          size: DSBadgeSize.small,
          color: DSColors.accentCyan,
        ),
        const SizedBox(width: DSSpacing.xs),
        Semantics(
          button: true,
          label: DSWatchlistDock.expandSemanticLabel(expanded: expanded),
          child: IconButton(
            key: DSWatchlistDock.expandToggleKey,
            tooltip: DSWatchlistDock.expandSemanticLabel(expanded: expanded),
            iconSize: 18,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            onPressed: _toggleExpanded,
            icon: Icon(
              expanded ? Icons.expand_less : Icons.expand_more,
              color: DSColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmpty() {
    return KeyedSubtree(
      key: DSWatchlistDock.emptyPlaceholderKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: DSSpacing.sm),
        child: DSText.labelSmall(
          widget.emptyLabel,
          color: DSColors.textTertiary,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildList(List<DSWatchlistItem> items) {
    return KeyedSubtree(
      key: DSWatchlistDock.listKey,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 280),
        child: ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: DSSpacing.xxs),
          itemBuilder: (context, index) {
            final item = items[index];
            return _WatchlistRow(
              item: item,
              selected: widget.selectedId == item.id,
              onSelect: () => _select(item),
              onUnpin: () => _unpin(item),
            );
          },
        ),
      ),
    );
  }
}

class _WatchlistRow extends StatelessWidget {
  final DSWatchlistItem item;
  final bool selected;
  final VoidCallback onSelect;
  final VoidCallback onUnpin;

  const _WatchlistRow({
    required this.item,
    required this.selected,
    required this.onSelect,
    required this.onUnpin,
  });

  @override
  Widget build(BuildContext context) {
    final accent =
        item.color ?? DSWatchlistDock.defaultColorForType(item.entityType);
    final icon =
        item.icon ?? DSWatchlistDock.defaultIconForType(item.entityType);

    // Select target and unpin control are sibling semantics nodes so the
    // nested action remains independently reachable by assistive tech.
    return Material(
      color: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DSSpacing.xs,
            vertical: DSSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: selected
                ? DSColors.obsidianActive
                : DSColors.obsidianHover.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(DSRadii.sm),
            border: Border.all(
              color: selected
                  ? accent.withValues(alpha: 0.55)
                  : DSColors.borderSubtle,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Semantics(
                  button: true,
                  selected: selected,
                  label: DSWatchlistDock.itemSemanticLabel(item),
                  excludeSemantics: true,
                  child: InkWell(
                    key: DSWatchlistDock.itemRowKey(item.id),
                    onTap: onSelect,
                    borderRadius: BorderRadius.circular(DSRadii.sm),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 48),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(DSRadii.sm),
                              border: Border.all(
                                color: accent.withValues(alpha: 0.35),
                              ),
                            ),
                            child: Icon(icon, size: 16, color: accent),
                          ),
                          const SizedBox(width: DSSpacing.xs),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                DSText.labelLarge(
                                  item.label,
                                  color: DSColors.textPrimary,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (item.subtitle != null)
                                  DSText.labelSmall(
                                    item.subtitle!,
                                    color: DSColors.textTertiary,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Semantics(
                button: true,
                label: DSWatchlistDock.unpinSemanticLabel(item.label),
                excludeSemantics: true,
                child: IconButton(
                  key: DSWatchlistDock.unpinKey(item.id),
                  tooltip: DSWatchlistDock.unpinSemanticLabel(item.label),
                  iconSize: 16,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                  onPressed: onUnpin,
                  icon: const Icon(
                    Icons.push_pin_outlined,
                    color: DSColors.textTertiary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
