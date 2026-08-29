import 'package:flutter/material.dart';

import '../../atoms/ds_divider.dart';
import '../../atoms/ds_glass_panel.dart';
import '../../atoms/ds_icon.dart';
import '../../atoms/ds_text.dart';
import '../../tokens/tokens.dart';
import '../ds_detail_inspector.dart';

// =============================================================================
// Models
// =============================================================================

/// Typed entity selection for [DSEntityIntelPanel].
///
/// Fixture-friendly and domain-agnostic: [type] is the dossier registry key
/// (e.g. `"agent"`, `"region"`, `"skill"`). Product consumers later map map
/// selection / asset detail into this shape — the organism never owns routes.
@immutable
class DSEntitySelection {
  /// Stable entity identity within the current catalog/corpus.
  final String id;

  /// Registry type key used to resolve a dossier body builder.
  final String type;

  /// Primary title shown in the panel header.
  final String title;

  /// Optional secondary line under the title.
  final String? subtitle;

  /// Visual kind for color/icon (defaults to [type] when null).
  ///
  /// Prefer asset-kind strings known to [DSColors.forAssetKind] /
  /// [DSIcons.forAssetKind] when available.
  final String? kind;

  /// Optional fixture attribute bag for body builders (pure data).
  final Map<String, Object?> attributes;

  const DSEntitySelection({
    required this.id,
    required this.type,
    required this.title,
    this.subtitle,
    this.kind,
    this.attributes = const <String, Object?>{},
  });

  /// Kind used for chrome coloring/icons.
  String get displayKind => kind ?? type;

  DSEntitySelection copyWith({
    String? id,
    String? type,
    String? title,
    String? subtitle,
    String? kind,
    Map<String, Object?>? attributes,
    bool clearSubtitle = false,
    bool clearKind = false,
  }) {
    return DSEntitySelection(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      subtitle: clearSubtitle ? null : (subtitle ?? this.subtitle),
      kind: clearKind ? null : (kind ?? this.kind),
      attributes: attributes ?? this.attributes,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DSEntitySelection &&
        other.id == id &&
        other.type == type &&
        other.title == title &&
        other.subtitle == subtitle &&
        other.kind == kind &&
        _mapEquals(other.attributes, attributes);
  }

  @override
  int get hashCode => Object.hash(
    id,
    type,
    title,
    subtitle,
    kind,
    Object.hashAll(attributes.entries.map((e) => Object.hash(e.key, e.value))),
  );
}

/// Body builder for a registered dossier type.
///
/// Receives the current [DSEntitySelection] so bodies can read id/title/
/// attributes without closing over unstable parent state.
typedef DSEntityIntelBodyBuilder =
    Widget Function(BuildContext context, DSEntitySelection selection);

/// Optional rich registration for a dossier type (label + icon + builder).
///
/// Prefer this when type chips need human labels beyond the raw [type] key.
/// For minimal registries, pass a bare [Map] of builders to
/// [DSEntityIntelPanel.bodyBuilders].
@immutable
class DSEntityIntelDossier {
  /// Registry type key (matches [DSEntitySelection.type]).
  final String type;

  /// Human-readable type label for the header chip (defaults to [type]).
  final String? label;

  /// Optional leading icon for the type chip.
  final IconData? icon;

  /// Body builder invoked when selection type matches [type].
  final DSEntityIntelBodyBuilder builder;

  const DSEntityIntelDossier({
    required this.type,
    required this.builder,
    this.label,
    this.icon,
  });
}

// =============================================================================
// Organism
// =============================================================================

/// ASW Observatory Organism — Entity Intel Panel
///
/// Pluggable **dossier registry** host: given a [selection], resolve a body
/// builder by [DSEntitySelection.type]. Harvest mode contract only — not a
/// structural port of NewsFeed / OsintPanel megafiles.
///
/// ## Registry
///
/// Provide either:
/// - [bodyBuilders] — `type → builder` map (minimal), and/or
/// - [dossiers] — rich registrations with type labels/icons.
///
/// When both are provided, [dossiers] win for overlapping type keys.
///
/// ## States
///
/// | Selection | Registry | Surface |
/// | --- | --- | --- |
/// | `null` | — | Empty / no-selection placeholder |
/// | non-null | type registered | Header chrome + dossier body |
/// | non-null | type unregistered | Unknown-type placeholder |
///
/// ## Composition
///
/// Header chrome follows the [DSDetailInspector] pattern (kind chip, title,
/// close, optional pin). The pluggable body is a free slot (not forced into
/// [DSDetailSection] list scrolling) so consumers can host rich content.
/// Optional [composeDetailInspector] wraps a registered body in a single-section
/// [DSDetailInspector] when section semantics are preferred.
///
/// Fixture/read-only ADS surface — no product-route coupling, no live backends.
class DSEntityIntelPanel extends StatelessWidget {
  /// Current selection. `null` shows the empty/no-selection state.
  final DSEntitySelection? selection;

  /// Minimal type → body builder registry.
  final Map<String, DSEntityIntelBodyBuilder> bodyBuilders;

  /// Optional rich dossier registrations (override [bodyBuilders] on key clash).
  final List<DSEntityIntelDossier> dossiers;

  /// Close affordance. When null, close button is hidden.
  final VoidCallback? onClose;

  /// Pin toggle. When null and [showPin] is false, pin is hidden.
  final ValueChanged<bool>? onPinChanged;

  /// Whether the panel is currently pinned (controlled).
  final bool pinned;

  /// Force-show pin control even when [onPinChanged] is null (visual only).
  final bool showPin;

  /// Whether to wrap content in [DSGlassPanel.elevated]. Defaults to true.
  final bool wrapInGlass;

  /// When true and a dossier is resolved, host body inside [DSDetailInspector]
  /// as a single "Dossier" section. Defaults to false (free body slot).
  final bool composeDetailInspector;

  /// Panel title used in empty/unknown chrome when no selection title applies.
  final String panelTitle;

  /// Empty-state title (null selection).
  final String emptyTitle;

  /// Empty-state body message.
  final String emptyMessage;

  /// Unknown-type title.
  final String unknownTitle;

  /// Unknown-type body message. Use `{type}` placeholder for the type key.
  final String unknownMessage;

  /// Optional semantic label for the panel container.
  final String semanticLabel;

  /// Optional trailing header actions (after pin, before close).
  final Widget? headerActions;

  const DSEntityIntelPanel({
    super.key,
    this.selection,
    this.bodyBuilders = const <String, DSEntityIntelBodyBuilder>{},
    this.dossiers = const <DSEntityIntelDossier>[],
    this.onClose,
    this.onPinChanged,
    this.pinned = false,
    this.showPin = false,
    this.wrapInGlass = true,
    this.composeDetailInspector = false,
    this.panelTitle = 'Entity intel',
    this.emptyTitle = 'No selection',
    this.emptyMessage = 'Select an entity to open its dossier.',
    this.unknownTitle = 'Unknown type',
    this.unknownMessage = 'No dossier registered for type "{type}".',
    this.semanticLabel = panelSemanticLabel,
    this.headerActions,
  });

  // --- Stable keys / semantics ---

  static const Key panelKey = Key('ds-entity-intel-panel');
  static const Key headerKey = Key('ds-entity-intel-header');
  static const Key bodyKey = Key('ds-entity-intel-body');
  static const Key emptyStateKey = Key('ds-entity-intel-empty');
  static const Key unknownStateKey = Key('ds-entity-intel-unknown');
  static const Key closeButtonKey = Key('ds-entity-intel-close');
  static const Key pinButtonKey = Key('ds-entity-intel-pin');
  static const Key typeChipKey = Key('ds-entity-intel-type-chip');

  static const String panelSemanticLabel = 'Entity intel panel';
  static const String closeSemanticLabel = 'Close intel panel';
  static const String pinSemanticLabel = 'Pin intel panel';
  static const String unpinSemanticLabel = 'Unpin intel panel';
  static const String emptySemanticLabel = 'No entity selected';
  static const String unknownSemanticLabel = 'Unknown entity type';

  /// Whether pin affordance is shown.
  bool get _pinVisible => showPin || onPinChanged != null;

  /// Resolve dossier for [type], if registered.
  DSEntityIntelDossier? resolveDossier(String type) {
    for (final d in dossiers) {
      if (d.type == type) return d;
    }
    final builder = bodyBuilders[type];
    if (builder == null) return null;
    return DSEntityIntelDossier(type: type, builder: builder);
  }

  /// Whether [type] has a registered body builder.
  bool isRegistered(String type) => resolveDossier(type) != null;

  @override
  Widget build(BuildContext context) {
    final sel = selection;
    final Widget content;
    if (sel == null) {
      content = _buildEmpty();
    } else {
      final dossier = resolveDossier(sel.type);
      if (dossier == null) {
        content = _buildUnknown(sel);
      } else if (composeDetailInspector) {
        content = _buildDetailInspectorHost(context, sel, dossier);
      } else {
        content = _buildFreeHost(context, sel, dossier);
      }
    }

    final wrapped = wrapInGlass
        ? DSGlassPanel.elevated(padding: EdgeInsets.zero, child: content)
        : content;

    return Semantics(
      key: panelKey,
      container: true,
      explicitChildNodes: true,
      label: semanticLabel,
      child: wrapped,
    );
  }

  Widget _buildEmpty() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Header(
          title: panelTitle,
          kindLabel: 'INTEL',
          kindColor: DSColors.textTertiary,
          icon: DSIcons.info,
          subtitle: null,
          onClose: onClose,
          pinVisible: _pinVisible,
          pinned: pinned,
          onPinChanged: onPinChanged,
          headerActions: headerActions,
        ),
        const DSDivider.subtle(),
        Expanded(
          child: Semantics(
            key: emptyStateKey,
            label: emptySemanticLabel,
            child: _PlaceholderBody(
              icon: Icons.travel_explore_outlined,
              title: emptyTitle,
              message: emptyMessage,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUnknown(DSEntitySelection sel) {
    final kindColor = DSColors.forAssetKind(sel.displayKind);
    final message = unknownMessage.replaceAll('{type}', sel.type);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Header(
          title: sel.title,
          kindLabel: sel.type.toUpperCase(),
          kindColor: kindColor,
          icon: DSIcons.forAssetKind(sel.displayKind),
          subtitle: sel.subtitle,
          onClose: onClose,
          pinVisible: _pinVisible,
          pinned: pinned,
          onPinChanged: onPinChanged,
          headerActions: headerActions,
          showTypeChip: true,
        ),
        const DSDivider.subtle(),
        Expanded(
          child: Semantics(
            key: unknownStateKey,
            label: '$unknownSemanticLabel: ${sel.type}',
            child: _PlaceholderBody(
              icon: Icons.help_outline,
              title: unknownTitle,
              message: message,
              accent: DSColors.statusWarning,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFreeHost(
    BuildContext context,
    DSEntitySelection sel,
    DSEntityIntelDossier dossier,
  ) {
    final kindColor = DSColors.forAssetKind(sel.displayKind);
    final typeLabel = (dossier.label ?? sel.type).toUpperCase();
    final icon = dossier.icon ?? DSIcons.forAssetKind(sel.displayKind);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Header(
          title: sel.title,
          kindLabel: typeLabel,
          kindColor: kindColor,
          icon: icon,
          subtitle: sel.subtitle,
          onClose: onClose,
          pinVisible: _pinVisible,
          pinned: pinned,
          onPinChanged: onPinChanged,
          headerActions: headerActions,
          showTypeChip: true,
        ),
        const DSDivider.subtle(),
        Expanded(
          child: KeyedSubtree(
            key: bodyKey,
            child: dossier.builder(context, sel),
          ),
        ),
      ],
    );
  }

  /// Compose [DSDetailInspector] as the host chrome for a registered dossier.
  Widget _buildDetailInspectorHost(
    BuildContext context,
    DSEntitySelection sel,
    DSEntityIntelDossier dossier,
  ) {
    final pin = _pinVisible
        ? _PinButton(pinned: pinned, onPinChanged: onPinChanged)
        : null;

    final actions = _mergeHeaderActions(pin, headerActions);

    return DSDetailInspector(
      title: sel.title,
      kind: sel.displayKind,
      subtitle: sel.subtitle,
      onClose: onClose,
      headerActions: actions,
      sections: [
        DSDetailSection(
          title: 'Dossier',
          icon: dossier.icon ?? DSIcons.forAssetKind(sel.displayKind),
          child: KeyedSubtree(
            key: bodyKey,
            child: dossier.builder(context, sel),
          ),
        ),
      ],
    );
  }

  Widget? _mergeHeaderActions(Widget? pin, Widget? extra) {
    if (pin == null && extra == null) return null;
    if (pin != null && extra == null) return pin;
    if (pin == null && extra != null) return extra;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        pin!,
        const SizedBox(width: DSSpacing.sm),
        extra!,
      ],
    );
  }
}

// =============================================================================
// Fixtures (gallery / tests)
// =============================================================================

/// Fixture catalog for gallery demos and widget tests.
///
/// Not product data. Demonstrates ≥2 dossier types without live backends.
class DSEntityIntelFixtures {
  DSEntityIntelFixtures._();

  /// Fixture agent selection.
  static const DSEntitySelection agent = DSEntitySelection(
    id: 'agent-recon-01',
    type: 'agent',
    title: 'recon-agent',
    subtitle: 'ASW agent · fixture',
    kind: 'agent',
    attributes: <String, Object?>{
      'role': 'recon',
      'status': 'healthy',
      'skills': 4,
    },
  );

  /// Fixture region / map selection.
  static const DSEntitySelection region = DSEntitySelection(
    id: 'region-apac-se',
    type: 'region',
    title: 'APAC · Southeast',
    subtitle: 'Region dossier · fixture',
    kind: 'reference',
    attributes: <String, Object?>{
      'bbox': '90, -15, 150, 30',
      'entities': 128,
      'risk': 'elevated',
    },
  );

  /// Fixture skill selection (third type for gallery switching demos).
  static const DSEntitySelection skill = DSEntitySelection(
    id: 'skill-parse-md',
    type: 'skill',
    title: 'parse-markdown',
    subtitle: 'Skill dossier · fixture',
    kind: 'skill',
    attributes: <String, Object?>{'version': '1.2.0', 'owner': 'builders'},
  );

  /// Sample registry covering agent + region (+ skill) dossier bodies.
  static Map<String, DSEntityIntelBodyBuilder> sampleBodyBuilders() {
    return <String, DSEntityIntelBodyBuilder>{
      'agent': buildPropertyDossier,
      'region': buildPropertyDossier,
      'skill': buildPropertyDossier,
    };
  }

  /// Rich dossier list with type labels (same three types).
  static List<DSEntityIntelDossier> sampleDossiers() {
    return const <DSEntityIntelDossier>[
      DSEntityIntelDossier(
        type: 'agent',
        label: 'Agent',
        icon: DSIcons.agent,
        builder: buildPropertyDossier,
      ),
      DSEntityIntelDossier(
        type: 'region',
        label: 'Region',
        icon: Icons.public_outlined,
        builder: buildPropertyDossier,
      ),
      DSEntityIntelDossier(
        type: 'skill',
        label: 'Skill',
        icon: DSIcons.skill,
        builder: buildPropertyDossier,
      ),
    ];
  }

  /// Default property-list body: renders [DSEntitySelection.attributes] rows
  /// plus id/type. Suitable as a gallery fixture body builder.
  static Widget buildPropertyDossier(
    BuildContext context,
    DSEntitySelection selection,
  ) {
    return ListView(
      padding: const EdgeInsets.all(DSSpacing.lg),
      children: [
        const DSText.labelLarge('Overview', color: DSColors.textSecondary),
        const SizedBox(height: DSSpacing.sm),
        DSPropertyRow(label: 'ID', value: selection.id),
        DSPropertyRow(label: 'Type', value: selection.type),
        for (final entry in selection.attributes.entries)
          DSPropertyRow(
            label: _humanizeKey(entry.key),
            value: entry.value?.toString() ?? '—',
          ),
      ],
    );
  }

  static String _humanizeKey(String key) {
    if (key.isEmpty) return key;
    return key[0].toUpperCase() + key.substring(1).replaceAll('_', ' ');
  }
}

// =============================================================================
// Private chrome
// =============================================================================

class _Header extends StatelessWidget {
  final String title;
  final String kindLabel;
  final Color kindColor;
  final IconData icon;
  final String? subtitle;
  final VoidCallback? onClose;
  final bool pinVisible;
  final bool pinned;
  final ValueChanged<bool>? onPinChanged;
  final Widget? headerActions;
  final bool showTypeChip;

  const _Header({
    required this.title,
    required this.kindLabel,
    required this.kindColor,
    required this.icon,
    required this.subtitle,
    required this.onClose,
    required this.pinVisible,
    required this.pinned,
    required this.onPinChanged,
    required this.headerActions,
    this.showTypeChip = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      key: DSEntityIntelPanel.headerKey,
      label: '$kindLabel: $title${subtitle != null ? '. $subtitle' : ''}',
      header: true,
      child: Container(
        padding: const EdgeInsets.all(DSSpacing.lg),
        color: DSColors.obsidianBase,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kindColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(DSRadii.md),
                  ),
                  child: DSIcon(icon, color: kindColor),
                ),
                const SizedBox(width: DSSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showTypeChip)
                        KeyedSubtree(
                          key: DSEntityIntelPanel.typeChipKey,
                          child: DSText.labelMedium(
                            kindLabel,
                            color: kindColor,
                          ),
                        )
                      else
                        DSText.labelMedium(kindLabel, color: kindColor),
                      const SizedBox(height: 2),
                      DSText.headingMedium(title),
                    ],
                  ),
                ),
                if (pinVisible)
                  _PinButton(pinned: pinned, onPinChanged: onPinChanged),
                if (headerActions != null) ...[
                  const SizedBox(width: DSSpacing.xs),
                  headerActions!,
                ],
                if (onClose != null)
                  // Outer Semantics owns the a11y node; excludeSemantics
                  // prevents IconButton/Tooltip from double-announcing.
                  Semantics(
                    key: DSEntityIntelPanel.closeButtonKey,
                    label: DSEntityIntelPanel.closeSemanticLabel,
                    button: true,
                    excludeSemantics: true,
                    child: IconButton(
                      icon: const DSIcon(Icons.close),
                      onPressed: onClose,
                      tooltip: DSEntityIntelPanel.closeSemanticLabel,
                    ),
                  ),
              ],
            ),
            if (subtitle != null) ...[
              const SizedBox(height: DSSpacing.sm),
              DSText.bodyMedium(subtitle!, color: DSColors.textSecondary),
            ],
          ],
        ),
      ),
    );
  }
}

class _PinButton extends StatelessWidget {
  final bool pinned;
  final ValueChanged<bool>? onPinChanged;

  const _PinButton({required this.pinned, required this.onPinChanged});

  @override
  Widget build(BuildContext context) {
    final label = pinned
        ? DSEntityIntelPanel.unpinSemanticLabel
        : DSEntityIntelPanel.pinSemanticLabel;

    // Outer Semantics carries toggled state; excludeSemantics prevents
    // IconButton tooltip from producing a second button node.
    return Semantics(
      key: DSEntityIntelPanel.pinButtonKey,
      label: label,
      button: true,
      toggled: pinned,
      excludeSemantics: true,
      child: IconButton(
        icon: DSIcon(
          pinned ? Icons.push_pin : Icons.push_pin_outlined,
          color: pinned ? DSColors.accentBlue : DSColors.textSecondary,
        ),
        onPressed: onPinChanged == null ? null : () => onPinChanged!(!pinned),
        tooltip: label,
      ),
    );
  }
}

class _PlaceholderBody extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Color? accent;

  const _PlaceholderBody({
    required this.icon,
    required this.title,
    required this.message,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final color = accent ?? DSColors.textTertiary;
    return ColoredBox(
      color: DSColors.obsidianBase,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(DSSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DSIcon(icon, color: color, size: 32),
              const SizedBox(height: DSSpacing.md),
              DSText.headingSmall(title, color: DSColors.textPrimary),
              const SizedBox(height: DSSpacing.sm),
              DSText.bodySmall(
                message,
                color: DSColors.textTertiary,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

bool _mapEquals(Map<String, Object?> a, Map<String, Object?> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (final entry in a.entries) {
    if (!b.containsKey(entry.key) || b[entry.key] != entry.value) {
      return false;
    }
  }
  return true;
}
