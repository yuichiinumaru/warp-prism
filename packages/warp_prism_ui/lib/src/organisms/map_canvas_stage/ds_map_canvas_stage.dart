import 'package:flutter/material.dart';

import '../../tokens/tokens.dart';
import 'ds_map_canvas_stage_controller.dart';
import 'map_stage_contracts.dart';
import 'map_stage_placeholder_widgets.dart';

export 'ds_map_canvas_stage_controller.dart';
export 'map_stage_contracts.dart';

// =============================================================================
// Widget — placeholder stage (no MapLibre)
// =============================================================================

/// ASW Observatory Organism — Map Canvas Stage (**contract + placeholder**).
///
/// Hosts:
/// - **Layer registry** via [DSMapCanvasStageController]
/// - **Selection bus** (select / clear events)
/// - **Popup factory** slot ([popupBuilder]) for selected feature chrome
/// - **Fixture placeholder renderer** (grid + markers) — **not** MapLibre
///
/// ## Non-port constraint
///
/// **Do not** treat this as a MapLibre / react-map-gl / force-graph port.
/// Real map engines must be integrated later as adapters that speak this
/// contract. EPIC-15 scope is contract + fake stage for gallery/tests only.
///
/// ## Composition
///
/// Prefer mounting as [DSMapHudWorkspace.stage]. Soft-depends Task 1501; the
/// contract types and fake stage are unit-testable without a HUD host.
class DSMapCanvasStage extends StatefulWidget {
  /// Optional external controller. When null, an internal controller is
  /// created from [initialLayers] / [initialFeatures].
  final DSMapCanvasStageController? controller;

  /// Seed layers when no [controller] is provided.
  final List<DSMapStageLayerEntry>? initialLayers;

  /// Seed features when no [controller] is provided.
  final List<DSMapStageFeature>? initialFeatures;

  /// Popup factory for the selected feature. Defaults to a glass title card.
  final DSMapStagePopupBuilder? popupBuilder;

  /// Selection-bus side channel (in addition to controller listeners).
  final ValueChanged<DSMapStageSelectionEvent>? onSelectionChanged;

  /// Whether tapping empty stage area clears selection. Default true.
  final bool clearOnBackgroundTap;

  /// Whether to paint the fixture grid background. Default true.
  final bool showGrid;

  /// Optional status strip showing visible layer count + selection.
  final bool showStatusStrip;

  /// Stage container semantic label.
  final String semanticLabel;

  /// Semantic label for the default popup dismiss control.
  final String dismissPopupSemanticLabel;

  /// Semantic label for the background clear target.
  final String clearBackgroundSemanticLabel;

  const DSMapCanvasStage({
    super.key,
    this.controller,
    this.initialLayers,
    this.initialFeatures,
    this.popupBuilder,
    this.onSelectionChanged,
    this.clearOnBackgroundTap = true,
    this.showGrid = true,
    this.showStatusStrip = true,
    this.semanticLabel = stageSemanticLabel,
    this.dismissPopupSemanticLabel = 'Dismiss feature popup',
    this.clearBackgroundSemanticLabel = 'Clear map selection',
  });

  /// Stable keys for tests and semantic tooling.
  static const Key stageRegionKey = Key('ds-map-canvas-stage');
  static const Key statusStripKey = Key('ds-map-canvas-stage-status');
  static const Key clearSelectionKey = Key('ds-map-canvas-stage-clear');
  static const Key popupHostKey = Key('ds-map-canvas-stage-popup');
  static const Key popupDismissKey = Key('ds-map-canvas-stage-popup-dismiss');
  static const Key backgroundClearKey = Key('ds-map-canvas-stage-bg-clear');

  /// Marker key for a fixture feature.
  static Key featureMarkerKey(String featureId) =>
      Key('ds-map-canvas-stage-feature-$featureId');

  /// Container semantic label.
  static const String stageSemanticLabel = 'Map canvas stage';

  /// Marker semantic label helper.
  static String featureSemanticLabel(String label) => 'Map feature: $label';

  @override
  State<DSMapCanvasStage> createState() => _DSMapCanvasStageState();
}

class _DSMapCanvasStageState extends State<DSMapCanvasStage> {
  DSMapCanvasStageController? _ownedController;
  late DSMapCanvasStageController _controller;

  @override
  void initState() {
    super.initState();
    _bindController(listen: true);
  }

  @override
  void didUpdateWidget(covariant DSMapCanvasStage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onControllerChanged);
      oldWidget.controller?.removeSelectionListener(_onSelectionFromController);
      _ownedController?.removeListener(_onControllerChanged);
      _ownedController?.removeSelectionListener(_onSelectionFromController);
      _ownedController?.dispose();
      _ownedController = null;
      _bindController(listen: true);
    }
  }

  void _bindController({required bool listen}) {
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _ownedController = DSMapCanvasStageController(
        initialLayers:
            widget.initialLayers ?? DSMapCanvasStageFixtures.defaultLayers(),
        initialFeatures:
            widget.initialFeatures ??
            DSMapCanvasStageFixtures.defaultFeatures(),
      );
      _controller = _ownedController!;
    }
    if (listen) {
      _controller.addListener(_onControllerChanged);
      _controller.addSelectionListener(_onSelectionFromController);
    }
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  void _onSelectionFromController(DSMapStageSelectionEvent event) {
    widget.onSelectionChanged?.call(event);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.removeSelectionListener(_onSelectionFromController);
    _ownedController?.dispose();
    super.dispose();
  }

  void _handleBackgroundTap() {
    if (widget.clearOnBackgroundTap) {
      _controller.clearSelection();
    }
  }

  void _handleFeatureTap(DSMapStageFeature feature) {
    _controller.selectFeature(feature.id);
  }

  @override
  Widget build(BuildContext context) {
    final selected = _controller.selectedFeature;
    final visible = _controller.visibleFeatures;
    final layers = _controller.layers;

    return Semantics(
      container: true,
      label: widget.semanticLabel,
      child: KeyedSubtree(
        key: DSMapCanvasStage.stageRegionKey,
        child: ColoredBox(
          color: DSColors.obsidianDeep,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.showStatusStrip)
                MapStageStatusStrip(
                  layers: layers,
                  selected: selected,
                  onClearSelection: _controller.clearSelection,
                  statusStripKey: DSMapCanvasStage.statusStripKey,
                  clearSelectionKey: DSMapCanvasStage.clearSelectionKey,
                ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final size = Size(
                      constraints.maxWidth,
                      constraints.maxHeight,
                    );
                    return Stack(
                      clipBehavior: Clip.hardEdge,
                      children: [
                        Positioned.fill(
                          child: KeyedSubtree(
                            key: DSMapCanvasStage.backgroundClearKey,
                            child: MapStageBackgroundClearTarget(
                              enabled: widget.clearOnBackgroundTap,
                              hasSelection: selected != null,
                              onClear: _handleBackgroundTap,
                              showGrid: widget.showGrid,
                              semanticLabel:
                                  widget.clearBackgroundSemanticLabel,
                            ),
                          ),
                        ),
                        for (final feature in visible)
                          _buildFeatureMarker(feature, size, selected?.id),
                        if (selected != null)
                          _buildPopupOverlay(selected, size),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureMarker(
    DSMapStageFeature feature,
    Size stageSize,
    String? selectedId,
  ) {
    final layer = _controller.layerById(feature.layerId);
    final accent = layer?.color ?? DSColors.accentCyan;
    final selected = feature.id == selectedId;
    return MapStageFeatureMarker(
      feature: feature,
      stageSize: stageSize,
      selected: selected,
      accent: accent,
      icon: feature.icon ?? layer?.icon ?? Icons.place_outlined,
      onTap: () => _handleFeatureTap(feature),
      semanticLabel: DSMapCanvasStage.featureSemanticLabel(feature.label),
      markerKey: DSMapCanvasStage.featureMarkerKey(feature.id),
    );
  }

  Widget _buildPopupOverlay(DSMapStageFeature feature, Size stageSize) {
    final builder = widget.popupBuilder ?? _defaultPopupBuilder;
    const popupWidth = 220.0;
    const popupHeight = 120.0;
    // Place popup near the feature, clamped into stage bounds.
    final rawLeft = feature.position.dx * stageSize.width + 20;
    final rawTop = feature.position.dy * stageSize.height - popupHeight / 2;
    final left = rawLeft.clamp(
      8.0,
      (stageSize.width - popupWidth - 8).clamp(8.0, stageSize.width),
    );
    final top = rawTop.clamp(
      8.0,
      (stageSize.height - popupHeight - 8).clamp(8.0, stageSize.height),
    );

    return Positioned(
      left: left,
      top: top,
      width: popupWidth,
      child: KeyedSubtree(
        key: DSMapCanvasStage.popupHostKey,
        child: builder(context, feature, _controller.clearSelection),
      ),
    );
  }

  Widget _defaultPopupBuilder(
    BuildContext context,
    DSMapStageFeature feature,
    VoidCallback dismiss,
  ) {
    return MapStageDefaultPopup(
      feature: feature,
      layer: _controller.layerById(feature.layerId),
      dismiss: dismiss,
      dismissSemanticLabel: widget.dismissPopupSemanticLabel,
      dismissKey: DSMapCanvasStage.popupDismissKey,
    );
  }
}
