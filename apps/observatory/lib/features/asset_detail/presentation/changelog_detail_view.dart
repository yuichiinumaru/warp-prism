/// Changelog detail view for the universal asset inspector.
///
/// Renders changelog entries as canonical ledger artifacts first,
/// generated projections second:
/// 1. Identity — entry name, ID, path, provenance
/// 2. Ledger Source — canonical vs generated, date, project, type
/// 3. Related Task — the task that motivated this change
/// 4. Affected Assets — impact areas and related skills
/// 5. Impact Story — Why, Changed, Evidence body sections
library;

import 'package:flutter/material.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';
import '../domain/asset_detail_descriptor.dart';
import 'detail_section_builder.dart';

/// Renders a changelog entry's detail using the [DSDetailInspector].
class ChangelogDetailView extends StatelessWidget {
  final AssetDetailDescriptor descriptor;
  final VoidCallback? onClose;

  const ChangelogDetailView({
    super.key,
    required this.descriptor,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final asset = descriptor.asset;

    final sections = <DSDetailSection>[
      // Shared sections (Identity)
      ...toDSSections(descriptor.sharedSections),
      // Kind-specific changelog panels
      ...toDSSections(descriptor.kindSections),
      // Incoming/outgoing links
      if (descriptor.incomingLinks.isNotEmpty)
        buildLinksSection(
          'Referenced By',
          descriptor.incomingLinks,
          isIncoming: true,
        ),
      if (descriptor.outgoingLinks.isNotEmpty)
        buildLinksSection(
          'References',
          descriptor.outgoingLinks,
          isIncoming: false,
        ),
    ];

    return DSDetailInspector(
      title: asset.name,
      kind: asset.kind.name,
      subtitle: asset.description.isNotEmpty ? asset.description : null,
      sections: sections,
      onClose: onClose,
    );
  }
}
