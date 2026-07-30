import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// =============================================================================
// PrismMapCanvasStage contracts (EPIC-15 O-17 / Task 1512)
//
// Engine-agnostic layer registry, selection bus, and popup factory types.
// **No MapLibre / react-map-gl / webview map engine** — real engine adapters are
// out of EPIC-15 scope. Placeholder stages and future adapters share this
// language so HUDs and relation cards can compose without engine coupling.
// =============================================================================

/// One logical layer in the stage layer registry.
///
/// Domain-agnostic: basemap flags, entity feeds, overlay toggles. Visibility is
/// owned by the registry/controller; fixture features bind via [id] as
/// [DSMapStageFeature.layerId].
@immutable
class DSMapStageLayerEntry {
  /// Stable layer identity within a stage instance.
  final String id;

  /// Human-readable layer label.
  final String label;

  /// Whether features bound to this layer are rendered / interactive.
  final bool visible;

  /// Paint order hint (higher draws above lower). Default `0`.
  final int zIndex;

  /// Optional accent color for markers / legend swatches.
  final Color? color;

  /// Optional leading icon.
  final IconData? icon;

  /// Optional secondary subtitle.
  final String? subtitle;

  const DSMapStageLayerEntry({
    required this.id,
    required this.label,
    this.visible = true,
    this.zIndex = 0,
    this.color,
    this.icon,
    this.subtitle,
  });

  DSMapStageLayerEntry copyWith({
    String? id,
    String? label,
    bool? visible,
    int? zIndex,
    Color? color,
    IconData? icon,
    String? subtitle,
    bool clearColor = false,
    bool clearIcon = false,
    bool clearSubtitle = false,
  }) {
    return DSMapStageLayerEntry(
      id: id ?? this.id,
      label: label ?? this.label,
      visible: visible ?? this.visible,
      zIndex: zIndex ?? this.zIndex,
      color: clearColor ? null : (color ?? this.color),
      icon: clearIcon ? null : (icon ?? this.icon),
      subtitle: clearSubtitle ? null : (subtitle ?? this.subtitle),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DSMapStageLayerEntry &&
        other.id == id &&
        other.label == label &&
        other.visible == visible &&
        other.zIndex == zIndex &&
        other.color == color &&
        other.icon == icon &&
        other.subtitle == subtitle;
  }

  @override
  int get hashCode =>
      Object.hash(id, label, visible, zIndex, color, icon, subtitle);
}

/// Fixture/geo-agnostic feature placed on the stage canvas.
///
/// [position] is **normalized** in stage local space: `Offset(0,0)` is top-left
/// and `Offset(1,1)` is bottom-right. Real engines later map this to CRS.
@immutable
class DSMapStageFeature {
  /// Stable feature identity within a stage instance.
  final String id;

  /// Layer this feature belongs to ([DSMapStageLayerEntry.id]).
  final String layerId;

  /// Primary label for marker a11y and default popup title.
  final String label;

  /// Normalized stage position (`0..1` in both axes, top-left origin).
  final Offset position;

  /// Optional free-form properties for popup factories / consumers.
  final Map<String, Object?> properties;

  /// Optional marker icon override.
  final IconData? icon;

  const DSMapStageFeature({
    required this.id,
    required this.layerId,
    required this.label,
    required this.position,
    this.properties = const <String, Object?>{},
    this.icon,
  });

  DSMapStageFeature copyWith({
    String? id,
    String? layerId,
    String? label,
    Offset? position,
    Map<String, Object?>? properties,
    IconData? icon,
    bool clearIcon = false,
  }) {
    return DSMapStageFeature(
      id: id ?? this.id,
      layerId: layerId ?? this.layerId,
      label: label ?? this.label,
      position: position ?? this.position,
      properties: properties ?? this.properties,
      icon: clearIcon ? null : (icon ?? this.icon),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DSMapStageFeature &&
        other.id == id &&
        other.layerId == layerId &&
        other.label == label &&
        other.position == position &&
        mapEquals(other.properties, properties) &&
        other.icon == icon;
  }

  @override
  int get hashCode => Object.hash(
    id,
    layerId,
    label,
    position,
    Object.hashAll(properties.entries.map((e) => Object.hash(e.key, e.value))),
    icon,
  );
}

/// Kind of selection-bus event emitted by the stage controller.
enum DSMapStageSelectionKind {
  /// A feature became the active selection.
  selected,

  /// Selection was cleared (tap empty canvas, explicit clear, or remove).
  cleared,
}

/// Immutable selection-bus event.
///
/// Listeners (HUD panels, relation cards, tests) subscribe via
/// [DSMapCanvasStageController.addSelectionListener] or
/// [DSMapCanvasStage.onSelectionChanged].
@immutable
class DSMapStageSelectionEvent {
  /// Whether this event is a select or clear.
  final DSMapStageSelectionKind kind;

  /// Selected feature when [kind] is [DSMapStageSelectionKind.selected].
  final DSMapStageFeature? feature;

  /// Convenience id (mirrors [feature]?.id).
  final String? featureId;

  /// Convenience layer id (mirrors [feature]?.layerId).
  final String? layerId;

  const DSMapStageSelectionEvent._({
    required this.kind,
    this.feature,
    this.featureId,
    this.layerId,
  });

  /// Feature became selected.
  factory DSMapStageSelectionEvent.selected(DSMapStageFeature feature) {
    return DSMapStageSelectionEvent._(
      kind: DSMapStageSelectionKind.selected,
      feature: feature,
      featureId: feature.id,
      layerId: feature.layerId,
    );
  }

  /// Selection cleared.
  const DSMapStageSelectionEvent.cleared()
    : kind = DSMapStageSelectionKind.cleared,
      feature = null,
      featureId = null,
      layerId = null;

  /// Whether a feature is currently selected.
  bool get hasSelection =>
      kind == DSMapStageSelectionKind.selected && feature != null;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DSMapStageSelectionEvent &&
        other.kind == kind &&
        other.featureId == featureId &&
        other.layerId == layerId &&
        other.feature == feature;
  }

  @override
  int get hashCode => Object.hash(kind, featureId, layerId, feature);
}

/// Builds popup chrome for a selected stage feature.
///
/// Call [dismiss] to clear selection (host may also call
/// [DSMapCanvasStageController.clearSelection] directly).
///
/// **Not** a MapLibre popup port — pure Flutter overlay slot.
typedef DSMapStagePopupBuilder =
    Widget Function(
      BuildContext context,
      DSMapStageFeature feature,
      VoidCallback dismiss,
    );

/// Selection-bus listener signature.
typedef DSMapStageSelectionListener =
    void Function(DSMapStageSelectionEvent event);
