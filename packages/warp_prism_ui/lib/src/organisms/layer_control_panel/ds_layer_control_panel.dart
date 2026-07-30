import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../atoms/ds_badge.dart';
import '../../atoms/ds_glass_panel.dart';
import '../../atoms/ds_icon.dart';
import '../../atoms/ds_status_dot.dart';
import '../../atoms/ds_text.dart';
import '../../tokens/tokens.dart';

// =============================================================================
// Models
// =============================================================================

/// Relative freshness band for a layer feed (fixture-friendly).
///
/// Maps to status-dot coloring; optional [DSLayerItem.freshnessLabel] carries
/// a human string such as `"12s ago"`.
enum DSLayerFreshness {
  /// Actively updating / live stream.
  live,

  /// Recently updated (still current).
  recent,

  /// Aging — still usable but lagging.
  aging,

  /// Stale — data may be unreliable.
  stale,

  /// Freshness unknown / not reported.
  unknown,
}

/// Single layer entry for [DSLayerControlPanel].
///
/// Domain-agnostic: map tiles, feed flags, capability toggles — no MapLibre
/// or product-route coupling. Fixture catalogs supply counts/freshness.
@immutable
class DSLayerItem {
  /// Stable layer identity within the panel catalog.
  final String id;

  /// Primary label shown on the row.
  final String label;

  /// Whether this layer is enabled when the panel is uncontrolled.
  ///
  /// Ignored for enable state when [DSLayerControlPanel.enabledLayerIds] is
  /// non-null (parent-owned).
  final bool enabled;

  /// Optional item count badge (e.g. entity count on feed).
  final int? count;

  /// Optional freshness band for the status indicator.
  final DSLayerFreshness? freshness;

  /// Optional relative-time label (e.g. `"12s ago"`).
  final String? freshnessLabel;

  /// When true, enabling the layer invokes [DSLayerControlPanel.onConsentRequired]
  /// instead of auto-enabling (parent completes consent, then enables).
  final bool requiresConsent;

  /// When true, the layer toggle is non-interactive.
  final bool disabled;

  /// Optional leading icon.
  final IconData? icon;

  /// Optional secondary subtitle under the label.
  final String? subtitle;

  const DSLayerItem({
    required this.id,
    required this.label,
    this.enabled = false,
    this.count,
    this.freshness,
    this.freshnessLabel,
    this.requiresConsent = false,
    this.disabled = false,
    this.icon,
    this.subtitle,
  });

  DSLayerItem copyWith({
    String? id,
    String? label,
    bool? enabled,
    int? count,
    DSLayerFreshness? freshness,
    String? freshnessLabel,
    bool? requiresConsent,
    bool? disabled,
    IconData? icon,
    String? subtitle,
    bool clearCount = false,
    bool clearFreshness = false,
    bool clearFreshnessLabel = false,
    bool clearIcon = false,
    bool clearSubtitle = false,
  }) {
    return DSLayerItem(
      id: id ?? this.id,
      label: label ?? this.label,
      enabled: enabled ?? this.enabled,
      count: clearCount ? null : (count ?? this.count),
      freshness: clearFreshness ? null : (freshness ?? this.freshness),
      freshnessLabel: clearFreshnessLabel
          ? null
          : (freshnessLabel ?? this.freshnessLabel),
      requiresConsent: requiresConsent ?? this.requiresConsent,
      disabled: disabled ?? this.disabled,
      icon: clearIcon ? null : (icon ?? this.icon),
      subtitle: clearSubtitle ? null : (subtitle ?? this.subtitle),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DSLayerItem &&
        other.id == id &&
        other.label == label &&
        other.enabled == enabled &&
        other.count == count &&
        other.freshness == freshness &&
        other.freshnessLabel == freshnessLabel &&
        other.requiresConsent == requiresConsent &&
        other.disabled == disabled &&
        other.icon == icon &&
        other.subtitle == subtitle;
  }

  @override
  int get hashCode => Object.hash(
    id,
    label,
    enabled,
    count,
    freshness,
    freshnessLabel,
    requiresConsent,
    disabled,
    icon,
    subtitle,
  );
}

/// Named group of [DSLayerItem] rows for [DSLayerControlPanel].
@immutable
class DSLayerGroup {
  /// Stable group identity.
  final String id;

  /// Group header label.
  final String label;

  /// Layers in this group (order preserved).
  final List<DSLayerItem> layers;

  /// When true and expansion is uncontrolled, the group starts expanded.
  final bool initiallyExpanded;

  /// Optional leading icon on the group header.
  final IconData? icon;

  const DSLayerGroup({
    required this.id,
    required this.label,
    this.layers = const <DSLayerItem>[],
    this.initiallyExpanded = true,
    this.icon,
  });

  /// Sum of non-null layer counts (for header badge).
  int get totalCount {
    var sum = 0;
    var any = false;
    for (final layer in layers) {
      if (layer.count != null) {
        any = true;
        sum += layer.count!;
      }
    }
    return any ? sum : 0;
  }

  /// Whether any layer reports a count.
  bool get hasCounts => layers.any((l) => l.count != null);

  DSLayerGroup copyWith({
    String? id,
    String? label,
    List<DSLayerItem>? layers,
    bool? initiallyExpanded,
    IconData? icon,
    bool clearIcon = false,
  }) {
    return DSLayerGroup(
      id: id ?? this.id,
      label: label ?? this.label,
      layers: layers ?? this.layers,
      initiallyExpanded: initiallyExpanded ?? this.initiallyExpanded,
      icon: clearIcon ? null : (icon ?? this.icon),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DSLayerGroup &&
        other.id == id &&
        other.label == label &&
        other.initiallyExpanded == initiallyExpanded &&
        other.icon == icon &&
        _listEquals(other.layers, layers);
  }

  @override
  int get hashCode =>
      Object.hash(id, label, Object.hashAll(layers), initiallyExpanded, icon);
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
// Organism
// =============================================================================

/// ASW Observatory Organism — Layer Control Panel
///
/// Grouped layer toggles with optional counts, freshness indicators, a master
/// all-on/all-off toggle, and consent-gate callbacks for privacy-sensitive
/// layers. Fixture catalog only — no MapLibre, no live feeds.
///
/// ## Enable model
///
/// - **Controlled**: pass [enabledLayerIds]; parent owns the set and updates
///   via [onEnabledLayersChanged] / [onLayerChanged].
/// - **Uncontrolled** (default): seed from each [DSLayerItem.enabled] and
///   manage internally.
///
/// ## Consent
///
/// Layers with [DSLayerItem.requiresConsent] `true` that are currently off do
/// **not** auto-enable. Toggling them on fires [onConsentRequired]; the parent
/// completes the consent flow and then enables the layer. Turning off always
/// works without consent.
///
/// ## Master toggle
///
/// - Off → disables every non-[DSLayerItem.disabled] layer.
/// - On → enables every non-disabled layer that does **not** require consent
///   (or is already on). Consent-gated off layers fire [onConsentRequired]
///   and stay off until parent enables them.
class DSLayerControlPanel extends StatefulWidget {
  /// Layer groups (order preserved).
  final List<DSLayerGroup> groups;

  /// Panel title shown in the header. Defaults to `"Layers"`.
  final String title;

  /// Controlled enable set. When non-null, parent owns enable state.
  final Set<String>? enabledLayerIds;

  /// Fired with the full next enable set after any toggle (master or row).
  final ValueChanged<Set<String>>? onEnabledLayersChanged;

  /// Fired for a single layer enable change (after consent gate).
  final void Function(String layerId, bool enabled)? onLayerChanged;

  /// Fired when the master toggle is used. `true` = all-on intent, `false` =
  /// all-off. Always reports the **intent**, even when some consent layers
  /// remain off after all-on.
  final ValueChanged<bool>? onMasterToggle;

  /// Fired when the user attempts to enable a consent-gated layer.
  final ValueChanged<String>? onConsentRequired;

  /// Whether to show the header master toggle. Defaults to true.
  final bool showMasterToggle;

  /// Whether to wrap content in [DSGlassPanel]. Defaults to true.
  final bool wrapInGlass;

  /// Controlled expansion set for groups. When non-null, parent owns it.
  final Set<String>? expandedGroupIds;

  /// Seed for uncontrolled group expansion (defaults to each group's
  /// [DSLayerGroup.initiallyExpanded]).
  final Set<String>? initiallyExpandedGroupIds;

  /// Fired when group expansion changes.
  final ValueChanged<Set<String>>? onExpandedGroupIdsChanged;

  /// When true and [groups] is empty, shows a compact empty placeholder.
  final bool showEmptyPlaceholder;

  /// Empty-state message.
  final String emptyLabel;

  /// Optional semantic label for the panel container.
  final String semanticLabel;

  const DSLayerControlPanel({
    super.key,
    required this.groups,
    this.title = 'Layers',
    this.enabledLayerIds,
    this.onEnabledLayersChanged,
    this.onLayerChanged,
    this.onMasterToggle,
    this.onConsentRequired,
    this.showMasterToggle = true,
    this.wrapInGlass = true,
    this.expandedGroupIds,
    this.initiallyExpandedGroupIds,
    this.onExpandedGroupIdsChanged,
    this.showEmptyPlaceholder = true,
    this.emptyLabel = 'No layers',
    this.semanticLabel = 'Layer control panel',
  });

  /// Whether enable state is parent-controlled.
  bool get isEnableControlled => enabledLayerIds != null;

  /// Whether group expansion is parent-controlled.
  bool get isExpansionControlled => expandedGroupIds != null;

  // --- Stable keys / semantics helpers ---

  static const Key panelRegionKey = Key('ds-layer-control-panel');
  static const Key masterToggleKey = Key('ds-layer-control-master');
  static const Key emptyPlaceholderKey = Key('ds-layer-control-empty');

  static Key groupHeaderKey(String groupId) =>
      Key('ds-layer-control-group-$groupId');

  static Key layerRowKey(String layerId) =>
      Key('ds-layer-control-layer-$layerId');

  static Key layerToggleKey(String layerId) =>
      Key('ds-layer-control-toggle-$layerId');

  static String masterSemanticLabel({required bool allEnabled}) =>
      allEnabled ? 'Disable all layers' : 'Enable all layers';

  static String layerToggleSemanticLabel(
    String label, {
    required bool enabled,
    required bool disabled,
    required bool requiresConsent,
  }) {
    if (disabled) return '$label, disabled';
    final state = enabled ? 'enabled' : 'disabled';
    final consent = requiresConsent && !enabled ? ', requires consent' : '';
    return '$label, $state$consent';
  }

  static String groupHeaderSemanticLabel(
    String label, {
    required bool expanded,
  }) => expanded ? '$label, expanded' : '$label, collapsed';

  /// Maps [DSLayerFreshness] to a status-dot color.
  static Color freshnessColor(DSLayerFreshness freshness) {
    switch (freshness) {
      case DSLayerFreshness.live:
        return DSColors.statusSuccess;
      case DSLayerFreshness.recent:
        return DSColors.accentCyan;
      case DSLayerFreshness.aging:
        return DSColors.statusWarning;
      case DSLayerFreshness.stale:
        return DSColors.statusError;
      case DSLayerFreshness.unknown:
        return DSColors.textTertiary;
    }
  }

  /// Default tooltip / label for a freshness band.
  static String freshnessDefaultLabel(DSLayerFreshness freshness) {
    switch (freshness) {
      case DSLayerFreshness.live:
        return 'Live';
      case DSLayerFreshness.recent:
        return 'Recent';
      case DSLayerFreshness.aging:
        return 'Aging';
      case DSLayerFreshness.stale:
        return 'Stale';
      case DSLayerFreshness.unknown:
        return 'Unknown';
    }
  }

  @override
  State<DSLayerControlPanel> createState() => _DSLayerControlPanelState();
}

class _DSLayerControlPanelState extends State<DSLayerControlPanel> {
  late Set<String> _uncontrolledEnabled;
  late Set<String> _uncontrolledExpanded;

  @override
  void initState() {
    super.initState();
    _uncontrolledEnabled = _seedEnabledFromGroups(widget.groups);
    _uncontrolledExpanded = _seedExpanded(widget);
  }

  @override
  void didUpdateWidget(covariant DSLayerControlPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isEnableControlled &&
        oldWidget.groups != widget.groups &&
        oldWidget.isEnableControlled) {
      // Switched into uncontrolled — re-seed from models.
      _uncontrolledEnabled = _seedEnabledFromGroups(widget.groups);
    }
    if (!widget.isExpansionControlled &&
        oldWidget.initiallyExpandedGroupIds !=
            widget.initiallyExpandedGroupIds &&
        oldWidget.isExpansionControlled) {
      _uncontrolledExpanded = _seedExpanded(widget);
    }
  }

  static Set<String> _seedEnabledFromGroups(List<DSLayerGroup> groups) {
    final next = <String>{};
    for (final group in groups) {
      for (final layer in group.layers) {
        if (layer.enabled) next.add(layer.id);
      }
    }
    return next;
  }

  static Set<String> _seedExpanded(DSLayerControlPanel widget) {
    if (widget.initiallyExpandedGroupIds != null) {
      return {...widget.initiallyExpandedGroupIds!};
    }
    return {
      for (final g in widget.groups)
        if (g.initiallyExpanded) g.id,
    };
  }

  Set<String> get _enabled {
    return widget.enabledLayerIds ?? _uncontrolledEnabled;
  }

  Set<String> get _expanded {
    return widget.expandedGroupIds ?? _uncontrolledExpanded;
  }

  Iterable<DSLayerItem> get _allLayers sync* {
    for (final g in widget.groups) {
      yield* g.layers;
    }
  }

  List<DSLayerItem> get _toggleableLayers =>
      _allLayers.where((l) => !l.disabled).toList(growable: false);

  bool get _allEnabled {
    final toggleable = _toggleableLayers;
    if (toggleable.isEmpty) return false;
    final enabled = _enabled;
    return toggleable.every((l) => enabled.contains(l.id));
  }

  bool get _anyEnabled {
    final enabled = _enabled;
    return _toggleableLayers.any((l) => enabled.contains(l.id));
  }

  void _commitEnabled(Set<String> next) {
    if (!widget.isEnableControlled) {
      setState(() => _uncontrolledEnabled = next);
    }
    widget.onEnabledLayersChanged?.call(Set<String>.unmodifiable(next));
  }

  void _setLayerEnabled(DSLayerItem layer, bool wantEnabled) {
    if (layer.disabled) return;

    final currentlyOn = _enabled.contains(layer.id);

    if (wantEnabled && !currentlyOn && layer.requiresConsent) {
      // Consent gate — do not auto-enable.
      widget.onConsentRequired?.call(layer.id);
      return;
    }

    if (wantEnabled == currentlyOn) return;

    final next = Set<String>.from(_enabled);
    if (wantEnabled) {
      next.add(layer.id);
    } else {
      next.remove(layer.id);
    }
    _commitEnabled(next);
    widget.onLayerChanged?.call(layer.id, wantEnabled);
  }

  void _masterToggle() {
    final goOn = !_allEnabled;
    final next = Set<String>.from(_enabled);

    if (goOn) {
      for (final layer in _toggleableLayers) {
        if (layer.requiresConsent && !next.contains(layer.id)) {
          widget.onConsentRequired?.call(layer.id);
          continue;
        }
        if (!next.contains(layer.id)) {
          next.add(layer.id);
          widget.onLayerChanged?.call(layer.id, true);
        }
      }
    } else {
      for (final layer in _toggleableLayers) {
        if (next.remove(layer.id)) {
          widget.onLayerChanged?.call(layer.id, false);
        }
      }
    }

    _commitEnabled(next);
    widget.onMasterToggle?.call(goOn);
  }

  void _toggleGroupExpanded(String groupId) {
    final next = Set<String>.from(_expanded);
    if (next.contains(groupId)) {
      next.remove(groupId);
    } else {
      next.add(groupId);
    }
    if (!widget.isExpansionControlled) {
      setState(() => _uncontrolledExpanded = next);
    }
    widget.onExpandedGroupIdsChanged?.call(Set<String>.unmodifiable(next));
  }

  @override
  Widget build(BuildContext context) {
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PanelHeader(
          title: widget.title,
          showMasterToggle:
              widget.showMasterToggle && _toggleableLayers.isNotEmpty,
          allEnabled: _allEnabled,
          anyEnabled: _anyEnabled,
          onMasterToggle: _masterToggle,
        ),
        const SizedBox(height: DSSpacing.sm),
        Expanded(
          child: widget.groups.isEmpty
              ? (widget.showEmptyPlaceholder
                    ? _EmptyPlaceholder(label: widget.emptyLabel)
                    : const SizedBox.shrink())
              : ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: widget.groups.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: DSSpacing.sm),
                  itemBuilder: (context, index) {
                    final group = widget.groups[index];
                    final expanded = _expanded.contains(group.id);
                    return _LayerGroupSection(
                      group: group,
                      expanded: expanded,
                      enabledIds: _enabled,
                      onToggleExpanded: () => _toggleGroupExpanded(group.id),
                      onLayerToggle: _setLayerEnabled,
                    );
                  },
                ),
        ),
      ],
    );

    final wrapped = widget.wrapInGlass
        ? DSGlassPanel.elevated(
            padding: const EdgeInsets.all(DSSpacing.sm),
            child: body,
          )
        : body;

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: widget.semanticLabel,
      child: KeyedSubtree(
        key: DSLayerControlPanel.panelRegionKey,
        child: wrapped,
      ),
    );
  }
}

// =============================================================================
// Subwidgets
// =============================================================================

class _PanelHeader extends StatelessWidget {
  final String title;
  final bool showMasterToggle;
  final bool allEnabled;
  final bool anyEnabled;
  final VoidCallback onMasterToggle;

  const _PanelHeader({
    required this.title,
    required this.showMasterToggle,
    required this.allEnabled,
    required this.anyEnabled,
    required this.onMasterToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: DSText.labelLarge(title, color: DSColors.textPrimary)),
        if (showMasterToggle) ...[
          DSText.labelSmall(
            allEnabled ? 'All on' : (anyEnabled ? 'Mixed' : 'All off'),
            color: DSColors.textTertiary,
          ),
          const SizedBox(width: DSSpacing.xs),
          Semantics(
            key: DSLayerControlPanel.masterToggleKey,
            button: true,
            toggled: allEnabled,
            label: DSLayerControlPanel.masterSemanticLabel(
              allEnabled: allEnabled,
            ),
            excludeSemantics: true,
            child: _CompactSwitch(
              value: allEnabled,
              onChanged: (_) => onMasterToggle(),
            ),
          ),
        ],
      ],
    );
  }
}

class _EmptyPlaceholder extends StatelessWidget {
  final String label;

  const _EmptyPlaceholder({required this.label});

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: DSLayerControlPanel.emptyPlaceholderKey,
      child: Center(
        child: DSText.labelMedium(label, color: DSColors.textTertiary),
      ),
    );
  }
}

class _LayerGroupSection extends StatelessWidget {
  final DSLayerGroup group;
  final bool expanded;
  final Set<String> enabledIds;
  final VoidCallback onToggleExpanded;
  final void Function(DSLayerItem layer, bool enabled) onLayerToggle;

  const _LayerGroupSection({
    required this.group,
    required this.expanded,
    required this.enabledIds,
    required this.onToggleExpanded,
    required this.onLayerToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _GroupHeader(
          group: group,
          expanded: expanded,
          onToggle: onToggleExpanded,
        ),
        if (expanded) ...[
          const SizedBox(height: DSSpacing.xs),
          if (group.layers.isEmpty)
            const Padding(
              padding: EdgeInsets.only(
                left: DSSpacing.lg,
                top: DSSpacing.xs,
                bottom: DSSpacing.xs,
              ),
              child: DSText.labelSmall(
                'No layers in group',
                color: DSColors.textTertiary,
              ),
            )
          else
            for (final layer in group.layers)
              _LayerRow(
                layer: layer,
                enabled: enabledIds.contains(layer.id),
                onToggle: (value) => onLayerToggle(layer, value),
              ),
        ],
      ],
    );
  }
}

class _GroupHeader extends StatefulWidget {
  final DSLayerGroup group;
  final bool expanded;
  final VoidCallback onToggle;

  const _GroupHeader({
    required this.group,
    required this.expanded,
    required this.onToggle,
  });

  @override
  State<_GroupHeader> createState() => _GroupHeaderState();
}

class _GroupHeaderState extends State<_GroupHeader> {
  late final FocusNode _focusNode;
  bool _hovered = false;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode(debugLabel: 'layer-group-${widget.group.id}');
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final group = widget.group;
    final highlight = _hovered || _focused;
    final label = DSLayerControlPanel.groupHeaderSemanticLabel(
      group.label,
      expanded: widget.expanded,
    );

    return Semantics(
      key: DSLayerControlPanel.groupHeaderKey(group.id),
      button: true,
      expanded: widget.expanded,
      label: label,
      excludeSemantics: true,
      child: Focus(
        focusNode: _focusNode,
        onFocusChange: (focused) => setState(() => _focused = focused),
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent &&
              (event.logicalKey == LogicalKeyboardKey.enter ||
                  event.logicalKey == LogicalKeyboardKey.space)) {
            widget.onToggle();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: widget.onToggle,
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: DSMotion.fast,
              curve: DSMotion.standard,
              constraints: const BoxConstraints(minHeight: 40),
              padding: const EdgeInsets.symmetric(
                horizontal: DSSpacing.xs,
                vertical: DSSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: highlight ? DSColors.obsidianHover : Colors.transparent,
                borderRadius: BorderRadius.circular(DSRadii.sm),
                border: Border.all(
                  color: _focused
                      ? DSColors.accentCyan.withValues(alpha: 0.45)
                      : Colors.transparent,
                ),
              ),
              child: Row(
                children: [
                  AnimatedRotation(
                    turns: widget.expanded ? 0.25 : 0,
                    duration: DSMotion.fast,
                    child: DSIcon(
                      Icons.chevron_right,
                      size: 18,
                      color: highlight
                          ? DSColors.accentCyan
                          : DSColors.textSecondary,
                    ),
                  ),
                  if (group.icon != null) ...[
                    const SizedBox(width: DSSpacing.xs),
                    DSIcon(
                      group.icon!,
                      size: 16,
                      color: DSColors.textSecondary,
                    ),
                  ],
                  const SizedBox(width: DSSpacing.xs),
                  Expanded(
                    child: DSText.labelMedium(
                      group.label,
                      color: DSColors.textPrimary,
                    ),
                  ),
                  if (group.hasCounts)
                    DSBadge.count(
                      group.totalCount,
                      color: DSColors.accentCyan,
                      semanticLabel: '${group.label} count ${group.totalCount}',
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LayerRow extends StatelessWidget {
  final DSLayerItem layer;
  final bool enabled;
  final ValueChanged<bool> onToggle;

  const _LayerRow({
    required this.layer,
    required this.enabled,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final interactive = !layer.disabled;
    final labelColor = layer.disabled
        ? DSColors.textDisabled
        : enabled
        ? DSColors.textPrimary
        : DSColors.textSecondary;

    return KeyedSubtree(
      key: DSLayerControlPanel.layerRowKey(layer.id),
      child: Padding(
        padding: const EdgeInsets.only(
          left: DSSpacing.sm,
          top: DSSpacing.xxs,
          bottom: DSSpacing.xxs,
        ),
        child: Row(
          children: [
            if (layer.icon != null) ...[
              DSIcon(layer.icon!, size: 16, color: labelColor),
              const SizedBox(width: DSSpacing.xs),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DSText.labelMedium(layer.label, color: labelColor),
                  if (layer.subtitle != null)
                    DSText.labelSmall(
                      layer.subtitle!,
                      color: DSColors.textTertiary,
                    ),
                ],
              ),
            ),
            if (layer.freshness != null) ...[
              _FreshnessPill(
                freshness: layer.freshness!,
                label: layer.freshnessLabel,
              ),
              const SizedBox(width: DSSpacing.xs),
            ],
            if (layer.count != null) ...[
              DSBadge.count(
                layer.count!,
                color: enabled ? DSColors.accentCyan : DSColors.textTertiary,
                semanticLabel: '${layer.label} count ${layer.count}',
              ),
              const SizedBox(width: DSSpacing.xs),
            ],
            if (layer.requiresConsent && !enabled)
              Padding(
                padding: const EdgeInsets.only(right: DSSpacing.xs),
                child: DSBadge(
                  label: 'Consent',
                  color: DSColors.accentViolet,
                  size: DSBadgeSize.small,
                  semanticLabel: '${layer.label} requires consent',
                ),
              ),
            Semantics(
              key: DSLayerControlPanel.layerToggleKey(layer.id),
              button: true,
              enabled: interactive,
              toggled: enabled,
              label: DSLayerControlPanel.layerToggleSemanticLabel(
                layer.label,
                enabled: enabled,
                disabled: layer.disabled,
                requiresConsent: layer.requiresConsent,
              ),
              excludeSemantics: true,
              child: _CompactSwitch(
                value: enabled,
                onChanged: interactive ? onToggle : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FreshnessPill extends StatelessWidget {
  final DSLayerFreshness freshness;
  final String? label;

  const _FreshnessPill({required this.freshness, this.label});

  @override
  Widget build(BuildContext context) {
    final color = DSLayerControlPanel.freshnessColor(freshness);
    final text = label ?? DSLayerControlPanel.freshnessDefaultLabel(freshness);

    return Tooltip(
      message: text,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          DSStatusDot(
            color: color,
            size: 6,
            animated: freshness == DSLayerFreshness.live,
          ),
          const SizedBox(width: DSSpacing.xxs),
          DSText.labelSmall(text, color: color),
        ],
      ),
    );
  }
}

/// Compact themed switch with cyan active track (obsidian glass aesthetic).
class _CompactSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const _CompactSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: FittedBox(
        fit: BoxFit.contain,
        child: Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: DSColors.obsidianDeep,
          activeTrackColor: DSColors.accentCyan,
          inactiveThumbColor: DSColors.textSecondary,
          inactiveTrackColor: DSColors.obsidianActive,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}
