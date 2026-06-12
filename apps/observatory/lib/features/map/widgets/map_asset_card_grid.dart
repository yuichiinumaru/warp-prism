/// Reusable grid/list of asset cards for the Map catalog.
///
/// Renders a list of [WorkspaceAsset] as [DSAssetCard] widgets in a
/// responsive Wrap layout. Provides asset-to-card adaptation so the
/// catalog shows kind, canonicality, relationship count, and trigger
/// context from the normalized data contract.
library;

import 'package:flutter/material.dart';
import 'package:warp_prism_observatory/data/models/workspace_graph.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// Renders a scrollable grid of asset cards from a list of [WorkspaceAsset].
///
/// The grid adapts card density based on available width. Each card
/// shows:
/// - **Kind**: agent, skill, workflow, etc.
/// - **Canonicality**: parent-canonical, child-local, generated, etc.
/// - **Edge count**: number of graph edges
/// - **Tags**: up to 3 tags from frontmatter
/// - **Triggers**: for skills, shows trigger count
class MapAssetCardGrid extends StatelessWidget {
  /// Assets to display as cards.
  final List<WorkspaceAsset> assets;

  /// Currently selected asset ID (null = nothing selected).
  final String? selectedAssetId;

  /// Called when an asset card is tapped.
  final ValueChanged<String>? onAssetTap;

  const MapAssetCardGrid({
    super.key,
    required this.assets,
    this.selectedAssetId,
    this.onAssetTap,
  });

  @override
  Widget build(BuildContext context) {
    if (assets.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(DSSpacing.md),
      itemCount: assets.length,
      itemBuilder: (context, index) {
        final asset = assets[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: DSSpacing.sm),
          child: _AssetCardAdapter(
            asset: asset,
            isSelected: asset.id == selectedAssetId,
            onTap: () => onAssetTap?.call(asset.id),
          ),
        );
      },
    );
  }
}

/// Adapts a [WorkspaceAsset] to the [DSAssetCard] molecule.
///
/// Extracts kind name, canonicality label, edge count, and relevant
/// tags/triggers from the normalized asset contract.
class _AssetCardAdapter extends StatelessWidget {
  final WorkspaceAsset asset;
  final bool isSelected;
  final VoidCallback? onTap;

  const _AssetCardAdapter({
    required this.asset,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Build tag list from asset tags + triggers (for skills)
    final displayTags = <String>[
      ...asset.tags.take(2),
      if (asset.kind == AssetKind.skill && asset.triggers.isNotEmpty)
        '${asset.triggers.length} trigger${asset.triggers.length == 1 ? '' : 's'}',
    ];

    // Canonicality label
    final canonicalityLabel = _canonicalityLabel(asset.canonicality);

    return DSAssetCard(
      name: asset.name,
      kind: asset.kind.name,
      description: asset.description.isNotEmpty ? asset.description : null,
      canonicality: canonicalityLabel,
      tags: displayTags.isNotEmpty ? displayTags : null,
      edgeCount: asset.edges.length,
      selected: isSelected,
      onTap: onTap,
    );
  }

  String _canonicalityLabel(Canonicality c) {
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
