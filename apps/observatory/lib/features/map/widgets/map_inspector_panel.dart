/// Inspector panel for the Map surface.
///
/// **Unit-adapter only (Task 0513 path-to-100):** production Map routes
/// mount universal [AssetDetailView] via [AssetDetailConsumer] and do
/// **not** embed this panel. Keep [MapInspectorPanel] for focused unit
/// tests that exercise [MapSelectionController] section building without
/// the descriptor pipeline. Prefer production smoke via AssetDetailConsumer.
///
/// Renders the selected asset's detail sections using the
/// [PrismDetailInspector] organism. When no asset is selected,
/// shows an explicit "no selection" state.
library;

import 'package:flutter/material.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';
import '../map_selection_controller.dart';
import 'map_state_panel.dart';

/// Inspector panel for the Map workspace.
///
/// Displays asset details when an asset is selected, or an explicit
/// "no selection" empty state. The panel is purely presentational —
/// it reads sections from [MapSelectionController].
class MapInspectorPanel extends StatelessWidget {
  /// The selection controller providing asset data.
  final MapSelectionController controller;

  /// Called when the user closes the inspector.
  final VoidCallback? onClose;

  const MapInspectorPanel({super.key, required this.controller, this.onClose});

  @override
  Widget build(BuildContext context) {
    final asset = controller.selectedAsset;

    // No-selection state: explicit MapSurfaceState, not a silent blank.
    if (asset == null) {
      return ColoredBox(
        color: PrismColors.obsidianBase,
        child: const MapStatePanel(state: MapSurfaceState.noSelection),
      );
    }

    // Build sections from the selected asset.
    final sections = controller.buildInspectorSections();

    return PrismDetailInspector(
      title: asset.name,
      kind: asset.kind.name,
      subtitle: asset.description.isNotEmpty ? asset.description : null,
      sections: sections.map((s) => _toDetailSection(s)).toList(),
      onClose: onClose ?? controller.deselectAsset,
    );
  }

  /// Convert a [MapInspectorSection] to a [PrismDetailSection].
  PrismDetailSection _toDetailSection(MapInspectorSection section) {
    return PrismDetailSection(
      title: section.title,
      count: section.count,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: section.rows
            .map((row) => PrismPropertyRow(label: row.label, value: row.value))
            .toList(),
      ),
    );
  }
}
