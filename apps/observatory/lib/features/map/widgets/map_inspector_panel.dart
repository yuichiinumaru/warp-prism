/// Inspector panel for the Map surface.
///
/// Renders the selected asset's detail sections using the
/// [DSDetailInspector] organism. When no asset is selected,
/// shows an explicit "no selection" state. This panel is
/// feature-local — it adapts normalized [WorkspaceAsset] data
/// into inspector sections without blocking on EPIC 09's
/// universal detail page.
library;

import 'package:flutter/material.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';
import '../map_selection_controller.dart';

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

  const MapInspectorPanel({
    super.key,
    required this.controller,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final asset = controller.selectedAsset;

    // No-selection state: explicit, not a silent blank.
    if (asset == null) {
      return _NoSelectionState();
    }

    // Build sections from the selected asset.
    final sections = controller.buildInspectorSections();

    return DSDetailInspector(
      title: asset.name,
      kind: asset.kind.name,
      subtitle: asset.description.isNotEmpty ? asset.description : null,
      sections: sections.map((s) => _toDetailSection(s)).toList(),
      onClose: onClose ?? controller.deselectAsset,
    );
  }

  /// Convert a [MapInspectorSection] to a [DSDetailSection].
  DSDetailSection _toDetailSection(MapInspectorSection section) {
    return DSDetailSection(
      title: section.title,
      count: section.count,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: section.rows
            .map((row) => DSPropertyRow(
                  label: row.label,
                  value: row.value,
                ))
            .toList(),
      ),
    );
  }
}

/// Empty state shown when no asset is selected for inspection.
///
/// Distinct from loading, error, and empty corpus states.
/// Communicates clearly that the user needs to select an asset.
class _NoSelectionState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: DSColors.obsidianBase,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: DSStateSurface.empty(
            icon: Icons.touch_app_outlined,
            title: 'No asset selected',
            subtitle:
                'Select an asset from the catalog or graph to view its details, '
                'relationships, and provenance.',
            compact: true,
          ),
        ),
      ),
    );
  }
}
