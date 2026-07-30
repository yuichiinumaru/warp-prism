import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../atoms/ds_glass_panel.dart';
import '../../atoms/ds_icon.dart';
import '../../atoms/ds_text.dart';
import '../../tokens/tokens.dart';

// =============================================================================
// Models
// =============================================================================

/// Single legend entry (icon/swatch + label) for [DSMapLegend].
@immutable
class DSMapLegendItem {
  /// Stable identity within its category.
  final String id;

  /// Display label.
  final String label;

  /// Optional leading icon.
  final IconData? icon;

  /// Optional color swatch / accent.
  final Color? color;

  /// Whether this entry is visible on the stage (when toggles enabled).
  final bool visible;

  /// Optional secondary line.
  final String? subtitle;

  const DSMapLegendItem({
    required this.id,
    required this.label,
    this.icon,
    this.color,
    this.visible = true,
    this.subtitle,
  });

  DSMapLegendItem copyWith({
    String? id,
    String? label,
    IconData? icon,
    Color? color,
    bool? visible,
    String? subtitle,
    bool clearIcon = false,
    bool clearColor = false,
    bool clearSubtitle = false,
  }) {
    return DSMapLegendItem(
      id: id ?? this.id,
      label: label ?? this.label,
      icon: clearIcon ? null : (icon ?? this.icon),
      color: clearColor ? null : (color ?? this.color),
      visible: visible ?? this.visible,
      subtitle: clearSubtitle ? null : (subtitle ?? this.subtitle),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DSMapLegendItem &&
        other.id == id &&
        other.label == label &&
        other.icon == icon &&
        other.color == color &&
        other.visible == visible &&
        other.subtitle == subtitle;
  }

  @override
  int get hashCode => Object.hash(id, label, icon, color, visible, subtitle);
}

/// Named category of [DSMapLegendItem] rows.
@immutable
class DSMapLegendCategory {
  /// Stable category identity.
  final String id;

  /// Category header label.
  final String label;

  /// Items in this category (order preserved).
  final List<DSMapLegendItem> items;

  /// Whether the category starts expanded (uncontrolled).
  final bool initiallyExpanded;

  /// Optional header icon.
  final IconData? icon;

  const DSMapLegendCategory({
    required this.id,
    required this.label,
    this.items = const <DSMapLegendItem>[],
    this.initiallyExpanded = true,
    this.icon,
  });

  DSMapLegendCategory copyWith({
    String? id,
    String? label,
    List<DSMapLegendItem>? items,
    bool? initiallyExpanded,
    IconData? icon,
    bool clearIcon = false,
  }) {
    return DSMapLegendCategory(
      id: id ?? this.id,
      label: label ?? this.label,
      items: items ?? this.items,
      initiallyExpanded: initiallyExpanded ?? this.initiallyExpanded,
      icon: clearIcon ? null : (icon ?? this.icon),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DSMapLegendCategory &&
        other.id == id &&
        other.label == label &&
        other.initiallyExpanded == initiallyExpanded &&
        other.icon == icon &&
        _listEquals(other.items, items);
  }

  @override
  int get hashCode =>
      Object.hash(id, label, Object.hashAll(items), initiallyExpanded, icon);
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

// =============================================================================
// Fixtures
// =============================================================================

/// Shared fixture catalog for gallery / tests (Task 1509).
abstract final class DSMapLegendFixtures {
  static const List<DSMapLegendCategory> defaultCategories =
      <DSMapLegendCategory>[
        DSMapLegendCategory(
          id: 'entities',
          label: 'Entities',
          icon: Icons.hub_outlined,
          items: [
            DSMapLegendItem(
              id: 'agent',
              label: 'Agent',
              icon: Icons.smart_toy_outlined,
              color: DSColors.accentCyan,
            ),
            DSMapLegendItem(
              id: 'skill',
              label: 'Skill',
              icon: Icons.psychology_outlined,
              color: DSColors.statusInfo,
            ),
            DSMapLegendItem(
              id: 'workflow',
              label: 'Workflow',
              icon: Icons.account_tree_outlined,
              color: DSColors.accentGold,
            ),
          ],
        ),
        DSMapLegendCategory(
          id: 'signals',
          label: 'Signals',
          icon: Icons.radar_outlined,
          items: [
            DSMapLegendItem(
              id: 'alert',
              label: 'Alert',
              icon: Icons.warning_amber_outlined,
              color: DSColors.statusWarning,
            ),
            DSMapLegendItem(
              id: 'incident',
              label: 'Incident',
              icon: Icons.error_outline,
              color: DSColors.statusError,
              visible: false,
            ),
            DSMapLegendItem(
              id: 'proof',
              label: 'Proof node',
              icon: Icons.verified_outlined,
              color: DSColors.statusSuccess,
              subtitle: 'Verified artifact',
            ),
          ],
        ),
        DSMapLegendCategory(
          id: 'empty',
          label: 'Empty category',
          initiallyExpanded: false,
          items: [],
        ),
      ];
}

// =============================================================================
// Organism
// =============================================================================

/// ASW Observatory Organism — Map Legend
///
/// Categorized icon/swatch catalog for dense multi-layer stages. Collapsible
/// categories; optional per-item visibility toggle. Fixture-first — no
/// MapLibre, no product-route coupling. Distinct from graph canvas legends.
///
/// EPIC-15 O-13 / Task 1509.
class DSMapLegend extends StatefulWidget {
  /// Legend categories (order preserved).
  final List<DSMapLegendCategory> categories;

  /// Panel title.
  final String title;

  /// When true, each item shows a visibility toggle.
  final bool allowVisibilityToggle;

  /// Controlled visibility set (item ids that are visible). When non-null,
  /// parent owns visibility; item.visible is ignored for state.
  final Set<String>? visibleItemIds;

  /// Fired when an item visibility changes.
  final void Function(String itemId, bool visible)? onVisibilityChanged;

  /// Fired with the full next visibility set after any toggle.
  final ValueChanged<Set<String>>? onVisibleItemsChanged;

  /// Controlled expansion set for categories.
  final Set<String>? expandedCategoryIds;

  /// Seed expansion for uncontrolled mode.
  final Set<String>? initiallyExpandedCategoryIds;

  /// Fired when category expansion changes.
  final ValueChanged<Set<String>>? onExpandedCategoryIdsChanged;

  /// Optional close affordance (parent dismisses).
  final VoidCallback? onClose;

  /// Whether to wrap content in [DSGlassPanel].
  final bool wrapInGlass;

  /// Empty catalog placeholder.
  final String emptyLabel;

  /// Show empty placeholder when [categories] is empty.
  final bool showEmptyPlaceholder;

  /// Semantic label for the panel region.
  final String semanticLabel;

  const DSMapLegend({
    super.key,
    required this.categories,
    this.title = 'Map legend',
    this.allowVisibilityToggle = true,
    this.visibleItemIds,
    this.onVisibilityChanged,
    this.onVisibleItemsChanged,
    this.expandedCategoryIds,
    this.initiallyExpandedCategoryIds,
    this.onExpandedCategoryIdsChanged,
    this.onClose,
    this.wrapInGlass = true,
    this.emptyLabel = 'No legend entries',
    this.showEmptyPlaceholder = true,
    this.semanticLabel = 'Map legend',
  });

  bool get isVisibilityControlled => visibleItemIds != null;

  bool get isExpansionControlled => expandedCategoryIds != null;

  // --- Stable keys ---

  static const Key panelRegionKey = Key('ds-map-legend');
  static const Key emptyPlaceholderKey = Key('ds-map-legend-empty');
  static const Key closeButtonKey = Key('ds-map-legend-close');
  static const Key listKey = Key('ds-map-legend-list');

  static Key categoryHeaderKey(String categoryId) =>
      Key('ds-map-legend-category-$categoryId');

  static Key itemRowKey(String itemId) => Key('ds-map-legend-item-$itemId');

  static Key itemToggleKey(String itemId) =>
      Key('ds-map-legend-toggle-$itemId');

  static String categorySemanticLabel(String label, {required bool expanded}) =>
      expanded ? '$label, expanded' : '$label, collapsed';

  static String itemToggleSemanticLabel(
    String label, {
    required bool visible,
  }) => visible ? 'Hide $label' : 'Show $label';

  @override
  State<DSMapLegend> createState() => _DSMapLegendState();
}

class _DSMapLegendState extends State<DSMapLegend> {
  late Set<String> _uncontrolledVisible;
  late Set<String> _uncontrolledExpanded;

  @override
  void initState() {
    super.initState();
    _uncontrolledVisible = _seedVisible(widget.categories);
    _uncontrolledExpanded = _seedExpanded(widget);
  }

  @override
  void didUpdateWidget(covariant DSMapLegend oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isVisibilityControlled &&
        oldWidget.categories != widget.categories) {
      _uncontrolledVisible = _seedVisible(widget.categories);
    }
    if (!widget.isExpansionControlled &&
        oldWidget.initiallyExpandedCategoryIds !=
            widget.initiallyExpandedCategoryIds &&
        oldWidget.isExpansionControlled) {
      _uncontrolledExpanded = _seedExpanded(widget);
    }
  }

  static Set<String> _seedVisible(List<DSMapLegendCategory> categories) {
    final next = <String>{};
    for (final cat in categories) {
      for (final item in cat.items) {
        if (item.visible) next.add(item.id);
      }
    }
    return next;
  }

  static Set<String> _seedExpanded(DSMapLegend widget) {
    if (widget.initiallyExpandedCategoryIds != null) {
      return {...widget.initiallyExpandedCategoryIds!};
    }
    return {
      for (final c in widget.categories)
        if (c.initiallyExpanded) c.id,
    };
  }

  Set<String> get _visible => widget.visibleItemIds ?? _uncontrolledVisible;

  Set<String> get _expanded =>
      widget.expandedCategoryIds ?? _uncontrolledExpanded;

  void _toggleCategory(String categoryId) {
    final next = Set<String>.from(_expanded);
    if (next.contains(categoryId)) {
      next.remove(categoryId);
    } else {
      next.add(categoryId);
    }
    if (!widget.isExpansionControlled) {
      setState(() => _uncontrolledExpanded = next);
    }
    widget.onExpandedCategoryIdsChanged?.call(Set<String>.unmodifiable(next));
  }

  void _toggleItem(DSMapLegendItem item) {
    if (!widget.allowVisibilityToggle) return;
    final currentlyOn = _visible.contains(item.id);
    final want = !currentlyOn;
    final next = Set<String>.from(_visible);
    if (want) {
      next.add(item.id);
    } else {
      next.remove(item.id);
    }
    if (!widget.isVisibilityControlled) {
      setState(() => _uncontrolledVisible = next);
    }
    widget.onVisibilityChanged?.call(item.id, want);
    widget.onVisibleItemsChanged?.call(Set<String>.unmodifiable(next));
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    final categories = widget.categories;

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(),
        const SizedBox(height: DSSpacing.xs),
        if (categories.isEmpty && widget.showEmptyPlaceholder)
          _buildEmpty()
        else
          KeyedSubtree(
            key: DSMapLegend.listKey,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 360),
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final expanded = _expanded.contains(cat.id);
                  return _CategoryBlock(
                    category: cat,
                    expanded: expanded,
                    visibleIds: _visible,
                    allowToggle: widget.allowVisibilityToggle,
                    onToggleCategory: () => _toggleCategory(cat.id),
                    onToggleItem: _toggleItem,
                  );
                },
              ),
            ),
          ),
      ],
    );

    final content = widget.wrapInGlass
        ? DSGlassPanel(padding: const EdgeInsets.all(DSSpacing.sm), child: body)
        : Padding(padding: const EdgeInsets.all(DSSpacing.sm), child: body);

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: widget.semanticLabel,
      child: KeyedSubtree(key: DSMapLegend.panelRegionKey, child: content),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const DSIcon(Icons.legend_toggle, size: 16, color: DSColors.accentGold),
        const SizedBox(width: DSSpacing.xs),
        Expanded(
          child: DSText.labelLarge(widget.title, color: DSColors.textPrimary),
        ),
        if (widget.onClose != null)
          Semantics(
            button: true,
            label: 'Close map legend',
            child: IconButton(
              key: DSMapLegend.closeButtonKey,
              tooltip: 'Close map legend',
              iconSize: 18,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              onPressed: widget.onClose,
              icon: const Icon(Icons.close, color: DSColors.textSecondary),
            ),
          ),
      ],
    );
  }

  Widget _buildEmpty() {
    return KeyedSubtree(
      key: DSMapLegend.emptyPlaceholderKey,
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
}

class _CategoryBlock extends StatelessWidget {
  final DSMapLegendCategory category;
  final bool expanded;
  final Set<String> visibleIds;
  final bool allowToggle;
  final VoidCallback onToggleCategory;
  final void Function(DSMapLegendItem item) onToggleItem;

  const _CategoryBlock({
    required this.category,
    required this.expanded,
    required this.visibleIds,
    required this.allowToggle,
    required this.onToggleCategory,
    required this.onToggleItem,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          button: true,
          expanded: expanded,
          label: DSMapLegend.categorySemanticLabel(
            category.label,
            expanded: expanded,
          ),
          excludeSemantics: true,
          child: InkWell(
            key: DSMapLegend.categoryHeaderKey(category.id),
            onTap: onToggleCategory,
            borderRadius: BorderRadius.circular(DSRadii.sm),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: DSSpacing.xs,
                  horizontal: DSSpacing.xxs,
                ),
                child: Row(
                  children: [
                    Icon(
                      expanded ? Icons.expand_more : Icons.chevron_right,
                      size: 16,
                      color: DSColors.textTertiary,
                    ),
                    if (category.icon != null) ...[
                      const SizedBox(width: DSSpacing.xxs),
                      Icon(
                        category.icon,
                        size: 14,
                        color: DSColors.textSecondary,
                      ),
                    ],
                    const SizedBox(width: DSSpacing.xs),
                    Expanded(
                      child: DSText.labelLarge(
                        category.label,
                        color: DSColors.textSecondary,
                      ),
                    ),
                    DSText.labelSmall(
                      '${category.items.length}',
                      color: DSColors.textTertiary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (expanded)
          if (category.items.isEmpty)
            const Padding(
              padding: EdgeInsets.only(
                left: DSSpacing.lg,
                bottom: DSSpacing.xs,
              ),
              child: DSText.labelSmall(
                'No entries',
                color: DSColors.textTertiary,
              ),
            )
          else
            ...category.items.map((item) {
              final visible = visibleIds.contains(item.id);
              return _LegendItemRow(
                item: item,
                visible: visible,
                allowToggle: allowToggle,
                onToggle: () => onToggleItem(item),
              );
            }),
      ],
    );
  }
}

class _LegendItemRow extends StatelessWidget {
  final DSMapLegendItem item;
  final bool visible;
  final bool allowToggle;
  final VoidCallback onToggle;

  const _LegendItemRow({
    required this.item,
    required this.visible,
    required this.allowToggle,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final accent = item.color ?? DSColors.textSecondary;
    final opacity = visible ? 1.0 : 0.45;

    return Opacity(
      opacity: opacity,
      child: Padding(
        padding: const EdgeInsets.only(
          left: DSSpacing.md,
          right: DSSpacing.xxs,
          bottom: DSSpacing.xxs,
        ),
        child: Row(
          children: [
            Container(
              key: DSMapLegend.itemRowKey(item.id),
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(DSRadii.sm),
                border: Border.all(color: accent.withValues(alpha: 0.4)),
              ),
              child: item.icon != null
                  ? Icon(item.icon, size: 13, color: accent)
                  : Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: accent,
                        shape: BoxShape.circle,
                      ),
                    ),
            ),
            const SizedBox(width: DSSpacing.xs),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DSText.labelSmall(
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
            if (allowToggle)
              Semantics(
                button: true,
                label: DSMapLegend.itemToggleSemanticLabel(
                  item.label,
                  visible: visible,
                ),
                child: IconButton(
                  key: DSMapLegend.itemToggleKey(item.id),
                  tooltip: DSMapLegend.itemToggleSemanticLabel(
                    item.label,
                    visible: visible,
                  ),
                  iconSize: 16,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                  onPressed: onToggle,
                  icon: Icon(
                    visible
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: visible
                        ? DSColors.textSecondary
                        : DSColors.textTertiary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
