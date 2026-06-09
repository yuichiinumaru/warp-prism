/// Agent detail view for the universal asset inspector.
///
/// Renders:
/// 1. Identity — name, description, path, provenance
/// 2. Operational Metadata — model, provider, status, capabilities
/// 3. Tools — declared tool names
/// 4. Skill Affinity — skills this agent uses
/// 5. Workflow Affinity — workflows this agent enters
/// 6. Usage Context — role, context, triggers
library;

import 'package:flutter/material.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';
import '../domain/asset_detail_descriptor.dart';
import 'detail_section_builder.dart';

/// Renders an agent's detail using the [DSDetailInspector].
class AgentDetailView extends StatelessWidget {
  final AssetDetailDescriptor descriptor;
  final VoidCallback? onClose;

  const AgentDetailView({
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
      // Kind-specific operational and relational panels
      ...toDSSections(descriptor.kindSections),
      // Incoming/outgoing links
      if (descriptor.incomingLinks.isNotEmpty)
        buildLinksSection(
          'Incoming References',
          descriptor.incomingLinks,
          isIncoming: true,
        ),
      if (descriptor.outgoingLinks.isNotEmpty)
        buildLinksSection(
          'Outgoing Dependencies',
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
