/// Shared selection controller for the Map feature.
///
/// Provides a single source of truth for asset selection across the
/// catalog panel and graph panel. Both panels write to this controller;
/// the inspector panel reads from it. This avoids divergent selection
/// state between subviews.
///
/// The controller is intentionally thin: it delegates state mutation
/// to [MapWorkspaceProvider] and adds only the asset-resolution logic
/// needed by the inspector.
library;

import '../../data/models/workspace_graph.dart';
import 'map_workspace_provider.dart';

/// Controls asset selection for the Map surface.
///
/// Both catalog card taps and graph node taps converge on the same
/// [selectAsset] method. The inspector reads [selectedAsset] to
/// render detail sections.
class MapSelectionController {
  final MapWorkspaceProvider _provider;

  MapSelectionController(this._provider);

  /// The currently selected asset id (null = nothing selected).
  String? get selectedAssetId => _provider.state.selectedAssetId;

  /// Whether an asset is currently selected.
  bool get hasSelection => _provider.state.hasSelection;

  /// Select an asset by id.
  ///
  /// Called from both the catalog panel (card tap) and the graph
  /// panel (node tap). Both origins produce the same result: a
  /// single selected asset in shared state.
  void selectAsset(String assetId) {
    _provider.selectAsset(assetId);
  }

  /// Deselect the current asset.
  ///
  /// Returns the inspector to the "no asset selected" state.
  void deselectAsset() {
    _provider.deselectAsset();
  }

  /// Resolve the full [WorkspaceAsset] for the current selection.
  ///
  /// Returns null if nothing is selected or if the selected id
  /// does not match any asset in the catalog (e.g., after a tab
  /// change that clears selection).
  WorkspaceAsset? get selectedAsset {
    final id = selectedAssetId;
    if (id == null) return null;
    try {
      return _provider.state.catalogAssets.firstWhere((a) => a.id == id);
    } on StateError {
      return null;
    }
  }

  /// Build inspector sections for the currently selected asset.
  ///
  /// Returns an empty list if nothing is selected. The sections
  /// cover identity, canonicality/governance, relationships,
  /// triggers (for skills), and operational hints.
  List<MapInspectorSection> buildInspectorSections() {
    final asset = selectedAsset;
    if (asset == null) return const [];
    return _assetToSections(asset);
  }

  /// Convert a [WorkspaceAsset] into inspector sections.
  static List<MapInspectorSection> _assetToSections(WorkspaceAsset asset) {
    final sections = <MapInspectorSection>[];

    // Identity section
    sections.add(MapInspectorSection(
      title: 'Identity',
      rows: [
        MapInspectorRow(label: 'ID', value: asset.id),
        MapInspectorRow(label: 'Kind', value: asset.kind.name),
        MapInspectorRow(label: 'Path', value: asset.path),
        if (asset.description.isNotEmpty)
          MapInspectorRow(label: 'Description', value: asset.description),
      ],
    ));

    // Governance / Canonicality section
    sections.add(MapInspectorSection(
      title: 'Governance',
      rows: [
        MapInspectorRow(
          label: 'Canonicality',
          value: _canonicalityLabel(asset.canonicality),
        ),
        if (asset.tags.isNotEmpty)
          MapInspectorRow(label: 'Tags', value: asset.tags.join(', ')),
      ],
    ));

    // Relationships section
    if (asset.edges.isNotEmpty) {
      final outgoing = asset.edges.where((e) => e.sourceId == asset.id).toList();
      final incoming = asset.edges.where((e) => e.targetId == asset.id).toList();

      final relRows = <MapInspectorRow>[];
      for (final edge in outgoing) {
        relRows.add(MapInspectorRow(
          label: edge.kind.name,
          value: '→ ${edge.targetId}',
        ));
      }
      for (final edge in incoming) {
        relRows.add(MapInspectorRow(
          label: edge.kind.name,
          value: '← ${edge.sourceId}',
        ));
      }

      sections.add(MapInspectorSection(
        title: 'Relationships',
        count: asset.edges.length,
        rows: relRows,
      ));
    }

    // Triggers section (skills only)
    if (asset.triggers.isNotEmpty) {
      sections.add(MapInspectorSection(
        title: 'Triggers',
        count: asset.triggers.length,
        rows: asset.triggers
            .map((t) => MapInspectorRow(label: 'Trigger', value: t))
            .toList(),
      ));
    }

    // Operational hints from frontmatter
    final operationalRows = <MapInspectorRow>[];
    if (asset.frontmatter.containsKey('owner')) {
      operationalRows.add(MapInspectorRow(
        label: 'Owner',
        value: asset.frontmatter['owner'].toString(),
      ));
    }
    if (asset.frontmatter.containsKey('status')) {
      operationalRows.add(MapInspectorRow(
        label: 'Status',
        value: asset.frontmatter['status'].toString(),
      ));
    }
    if (operationalRows.isNotEmpty) {
      sections.add(MapInspectorSection(
        title: 'Operational',
        rows: operationalRows,
      ));
    }

    return sections;
  }

  static String _canonicalityLabel(Canonicality c) {
    switch (c) {
      case Canonicality.parentCanonical:
        return 'canonical';
      case Canonicality.childLocal:
        return 'child-local';
      case Canonicality.generated:
        return 'generated';
      case Canonicality.appendOnly:
        return 'append-only';
      case Canonicality.archive:
        return 'archive';
      case Canonicality.mock:
        return 'mock';
    }
  }
}

/// A section in the Map inspector panel.
class MapInspectorSection {
  final String title;
  final int? count;
  final List<MapInspectorRow> rows;

  const MapInspectorSection({
    required this.title,
    this.count,
    required this.rows,
  });
}

/// A single row in an inspector section.
class MapInspectorRow {
  final String label;
  final String value;

  const MapInspectorRow({required this.label, required this.value});
}
