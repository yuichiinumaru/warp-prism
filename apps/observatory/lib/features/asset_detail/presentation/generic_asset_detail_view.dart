/// Generic asset detail view for secondary/unsupported asset kinds.
///
/// Used for: subskill, script, reference, rule, and any unknown kinds.
/// Shows identity, metadata, and tags — but explicitly marks the view
/// as partial-support with a visible banner instead of pretending
/// full fidelity.
library;

import 'package:flutter/material.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';
import 'package:warp_prism_observatory/data/models/workspace_graph.dart';
import '../domain/asset_detail_descriptor.dart';
import 'detail_section_builder.dart';

/// Renders a generic/fallback detail using the [PrismDetailInspector].
///
/// Shows a partial-support banner when the descriptor is a fallback,
/// making it explicit that this kind has limited detail support.
class GenericAssetDetailView extends StatelessWidget {
  final AssetDetailDescriptor descriptor;
  final VoidCallback? onClose;

  const GenericAssetDetailView({
    super.key,
    required this.descriptor,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final asset = descriptor.asset;

    final sections = <PrismDetailSection>[
      // Shared sections (Identity, Metadata, Tags)
      ...toDSSections(descriptor.sharedSections),
      // Any kind-specific sections (likely empty for fallback)
      ...toDSSections(descriptor.kindSections),
      // Incoming/outgoing links
      if (descriptor.incomingLinks.isNotEmpty)
        buildLinksSection(
          'Incoming Links',
          descriptor.incomingLinks,
          isIncoming: true,
        ),
      if (descriptor.outgoingLinks.isNotEmpty)
        buildLinksSection(
          'Outgoing Links',
          descriptor.outgoingLinks,
          isIncoming: false,
        ),
    ];

    return PrismDetailInspector(
      title: asset.name,
      kind: asset.kind.name,
      subtitle: _buildSubtitle(asset, descriptor),
      headerActions: descriptor.isFallback
          ? _PartialSupportBanner(
              message:
                  descriptor.fallbackMessage ??
                  '${asset.kind.name} assets have limited detail support.',
            )
          : null,
      sections: sections,
      onClose: onClose,
    );
  }

  String _buildSubtitle(
    WorkspaceAsset asset,
    AssetDetailDescriptor descriptor,
  ) {
    final parts = <String>[
      asset.kind.name,
      if (asset.description.isNotEmpty) asset.description,
    ];
    return parts.join(' — ');
  }
}

/// Visual banner indicating partial support for this asset kind.
class _PartialSupportBanner extends StatelessWidget {
  final String message;

  const _PartialSupportBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PrismSpacing.sm,
        vertical: PrismSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: PrismColors.statusWarning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(PrismRadii.sm),
        border: Border.all(
          color: PrismColors.statusWarning.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.info_outline,
            size: 14,
            color: PrismColors.statusWarning,
          ),
          const SizedBox(width: PrismSpacing.xs),
          Flexible(
            child: PrismText.labelSmall(
              message,
              color: PrismColors.statusWarning,
            ),
          ),
        ],
      ),
    );
  }
}
