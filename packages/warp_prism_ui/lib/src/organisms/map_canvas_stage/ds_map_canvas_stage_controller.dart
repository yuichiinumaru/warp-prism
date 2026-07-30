import 'package:flutter/material.dart';

import '../../tokens/tokens.dart';
import 'map_stage_contracts.dart';

// =============================================================================
// Fixtures
// =============================================================================

/// Deterministic fixture catalog for gallery + tests (no MapLibre, no network).
abstract final class DSMapCanvasStageFixtures {
  /// Default basemap + agents + alerts layer registry.
  static List<DSMapStageLayerEntry> defaultLayers() => const [
    DSMapStageLayerEntry(
      id: 'basemap',
      label: 'Basemap grid',
      visible: true,
      zIndex: 0,
      color: DSColors.accentCyanDim,
      icon: Icons.grid_on_outlined,
      subtitle: 'Fixture grid (not tiles)',
    ),
    DSMapStageLayerEntry(
      id: 'agents',
      label: 'Agents',
      visible: true,
      zIndex: 10,
      color: DSColors.accentCyan,
      icon: Icons.smart_toy_outlined,
      subtitle: '3 fixture agents',
    ),
    DSMapStageLayerEntry(
      id: 'alerts',
      label: 'Alerts',
      visible: true,
      zIndex: 20,
      color: DSColors.accentGold,
      icon: Icons.warning_amber_outlined,
      subtitle: '1 fixture alert',
    ),
  ];

  /// Default fixture features bound to [defaultLayers].
  static List<DSMapStageFeature> defaultFeatures() => const [
    DSMapStageFeature(
      id: 'agent-alpha',
      layerId: 'agents',
      label: 'Agent Alpha',
      position: Offset(0.28, 0.35),
      properties: {'kind': 'agent', 'status': 'healthy'},
      icon: Icons.smart_toy_outlined,
    ),
    DSMapStageFeature(
      id: 'agent-bravo',
      layerId: 'agents',
      label: 'Agent Bravo',
      position: Offset(0.62, 0.48),
      properties: {'kind': 'agent', 'status': 'running'},
      icon: Icons.smart_toy_outlined,
    ),
    DSMapStageFeature(
      id: 'agent-charlie',
      layerId: 'agents',
      label: 'Agent Charlie',
      position: Offset(0.45, 0.72),
      properties: {'kind': 'agent', 'status': 'stale'},
      icon: Icons.smart_toy_outlined,
    ),
    DSMapStageFeature(
      id: 'alert-1',
      layerId: 'alerts',
      label: 'Perimeter alert',
      position: Offset(0.72, 0.28),
      properties: {'kind': 'alert', 'severity': 'warning'},
      icon: Icons.warning_amber_outlined,
    ),
  ];
}

// =============================================================================
// Controller — layer registry + selection bus
// =============================================================================

/// Imperative handle for [DSMapCanvasStage] layer registry, feature set, and
/// selection bus.
///
/// ## Layer registry
///
/// - [addLayer] / [removeLayer] / [setLayerVisibility] / [toggleLayerVisibility]
/// - Visibility gates which features paint and accept pointer hit-tests
///
/// ## Selection bus
///
/// - [selectFeature] / [clearSelection]
/// - [addSelectionListener] for multi-subscriber composition (HUD, tests)
/// - [selectedFeature] / [selectedFeatureId] for host readback
///
/// ## Non-port constraint
///
/// This controller is **engine-agnostic**. It does not load tiles, spawn
/// workers, or depend on MapLibre / react-map-gl. Future adapters should map
/// engine events into these APIs rather than forking the contract.
class DSMapCanvasStageController extends ChangeNotifier {
  final List<DSMapStageLayerEntry> _layers = <DSMapStageLayerEntry>[];
  final List<DSMapStageFeature> _features = <DSMapStageFeature>[];
  final List<DSMapStageSelectionListener> _selectionListeners =
      <DSMapStageSelectionListener>[];

  String? _selectedFeatureId;

  DSMapCanvasStageController({
    List<DSMapStageLayerEntry>? initialLayers,
    List<DSMapStageFeature>? initialFeatures,
    String? initialSelectedFeatureId,
  }) {
    if (initialLayers != null) {
      _layers.addAll(initialLayers);
    }
    if (initialFeatures != null) {
      _features.addAll(initialFeatures);
    }
    if (initialSelectedFeatureId != null &&
        _features.any((f) => f.id == initialSelectedFeatureId)) {
      _selectedFeatureId = initialSelectedFeatureId;
    }
  }

  // ---------------------------------------------------------------------------
  // Layer registry
  // ---------------------------------------------------------------------------

  /// Ordered layer registry snapshot (registration order).
  List<DSMapStageLayerEntry> get layers => List.unmodifiable(_layers);

  /// Lookup a layer by id, or null.
  DSMapStageLayerEntry? layerById(String id) {
    for (final layer in _layers) {
      if (layer.id == id) return layer;
    }
    return null;
  }

  /// Whether [layerId] is registered and currently visible.
  bool isLayerVisible(String layerId) {
    final layer = layerById(layerId);
    return layer?.visible ?? false;
  }

  /// Register a layer. Replaces an existing entry with the same [layer.id].
  void addLayer(DSMapStageLayerEntry layer) {
    final index = _layers.indexWhere((l) => l.id == layer.id);
    if (index >= 0) {
      _layers[index] = layer;
    } else {
      _layers.add(layer);
    }
    notifyListeners();
  }

  /// Remove a layer by id. Features stay registered but become non-visible
  /// when their layer is gone. Selection clears if the selected feature's
  /// layer was removed.
  void removeLayer(String layerId) {
    final removed = _layers.any((l) => l.id == layerId);
    if (!removed) return;
    _layers.removeWhere((l) => l.id == layerId);
    final selected = selectedFeature;
    if (selected != null && selected.layerId == layerId) {
      _clearSelectionInternal(emit: true);
    } else {
      notifyListeners();
    }
  }

  /// Set visibility for [layerId]. No-op when layer is missing.
  void setLayerVisibility(String layerId, bool visible) {
    final index = _layers.indexWhere((l) => l.id == layerId);
    if (index < 0) return;
    final current = _layers[index];
    if (current.visible == visible) return;
    _layers[index] = current.copyWith(visible: visible);
    final selected = selectedFeature;
    if (!visible && selected != null && selected.layerId == layerId) {
      _clearSelectionInternal(emit: true);
    } else {
      notifyListeners();
    }
  }

  /// Toggle visibility for [layerId].
  void toggleLayerVisibility(String layerId) {
    final layer = layerById(layerId);
    if (layer == null) return;
    setLayerVisibility(layerId, !layer.visible);
  }

  /// Replace the entire layer registry.
  void setLayers(List<DSMapStageLayerEntry> layers) {
    _layers
      ..clear()
      ..addAll(layers);
    final selected = selectedFeature;
    if (selected != null && !isLayerVisible(selected.layerId)) {
      _clearSelectionInternal(emit: true);
    } else {
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // Features
  // ---------------------------------------------------------------------------

  /// Full feature catalog snapshot.
  List<DSMapStageFeature> get features => List.unmodifiable(_features);

  /// Features whose layer is registered and visible, sorted by layer zIndex
  /// then registration order.
  List<DSMapStageFeature> get visibleFeatures {
    final zByLayer = <String, int>{
      for (final layer in _layers) layer.id: layer.zIndex,
    };
    final visibleLayerIds = {
      for (final layer in _layers)
        if (layer.visible) layer.id,
    };
    final filtered = _features
        .where((f) => visibleLayerIds.contains(f.layerId))
        .toList(growable: false);
    return List<DSMapStageFeature>.of(filtered)..sort((a, b) {
      final za = zByLayer[a.layerId] ?? 0;
      final zb = zByLayer[b.layerId] ?? 0;
      final zCmp = za.compareTo(zb);
      if (zCmp != 0) return zCmp;
      return 0;
    });
  }

  /// Lookup a feature by id, or null.
  DSMapStageFeature? featureById(String id) {
    for (final feature in _features) {
      if (feature.id == id) return feature;
    }
    return null;
  }

  /// Register or replace a feature.
  void addFeature(DSMapStageFeature feature) {
    final index = _features.indexWhere((f) => f.id == feature.id);
    if (index >= 0) {
      _features[index] = feature;
    } else {
      _features.add(feature);
    }
    notifyListeners();
  }

  /// Remove a feature by id; clears selection when it was selected.
  void removeFeature(String featureId) {
    final existed = _features.any((f) => f.id == featureId);
    if (!existed) return;
    _features.removeWhere((f) => f.id == featureId);
    if (_selectedFeatureId == featureId) {
      _clearSelectionInternal(emit: true);
    } else {
      notifyListeners();
    }
  }

  /// Replace the entire feature catalog.
  void setFeatures(List<DSMapStageFeature> features) {
    _features
      ..clear()
      ..addAll(features);
    if (_selectedFeatureId != null &&
        !_features.any((f) => f.id == _selectedFeatureId)) {
      _clearSelectionInternal(emit: true);
    } else {
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // Selection bus
  // ---------------------------------------------------------------------------

  /// Currently selected feature id, or null.
  String? get selectedFeatureId => _selectedFeatureId;

  /// Currently selected feature, or null when cleared / missing.
  DSMapStageFeature? get selectedFeature {
    final id = _selectedFeatureId;
    if (id == null) return null;
    return featureById(id);
  }

  /// Whether a feature is selected.
  bool get hasSelection => selectedFeature != null;

  /// Subscribe to selection-bus events (select + clear).
  void addSelectionListener(DSMapStageSelectionListener listener) {
    _selectionListeners.add(listener);
  }

  /// Unsubscribe a prior [addSelectionListener] registration.
  void removeSelectionListener(DSMapStageSelectionListener listener) {
    _selectionListeners.remove(listener);
  }

  /// Select a feature by id. No-op when missing or layer hidden.
  void selectFeature(String featureId) {
    final feature = featureById(featureId);
    if (feature == null) return;
    if (!isLayerVisible(feature.layerId)) return;
    if (_selectedFeatureId == featureId) return;
    _selectedFeatureId = featureId;
    final event = DSMapStageSelectionEvent.selected(feature);
    notifyListeners();
    _emitSelection(event);
  }

  /// Clear the active selection and emit a cleared event when needed.
  void clearSelection() {
    if (_selectedFeatureId == null) return;
    _clearSelectionInternal(emit: true);
  }

  void _clearSelectionInternal({required bool emit}) {
    _selectedFeatureId = null;
    notifyListeners();
    if (emit) {
      _emitSelection(const DSMapStageSelectionEvent.cleared());
    }
  }

  void _emitSelection(DSMapStageSelectionEvent event) {
    // Copy to allow listeners to unsubscribe during emission.
    final snapshot = List<DSMapStageSelectionListener>.of(_selectionListeners);
    for (final listener in snapshot) {
      listener(event);
    }
  }

  @override
  void dispose() {
    _selectionListeners.clear();
    super.dispose();
  }
}
