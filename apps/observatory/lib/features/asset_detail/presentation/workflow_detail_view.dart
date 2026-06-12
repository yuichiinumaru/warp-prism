/// Workflow detail view for the universal asset inspector.
///
/// Renders:
/// 1. Identity — name, description, path, provenance
/// 2. Trigger — trigger type, event, inputs
/// 3. Stages — ordered stage list with descriptions
/// 4. Branches & Error Handling — branch rules, retry policy, fallbacks
/// 5. Related Assets — linked skills and agents
/// 6. Performance — avg duration, success rate, timeout
library;

import 'package:flutter/material.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';
import '../domain/asset_detail_descriptor.dart';
import 'detail_section_builder.dart';

/// Renders a workflow's detail using the [DSDetailInspector].
class WorkflowDetailView extends StatelessWidget {
  final AssetDetailDescriptor descriptor;
  final VoidCallback? onClose;

  const WorkflowDetailView({super.key, required this.descriptor, this.onClose});

  @override
  Widget build(BuildContext context) {
    final asset = descriptor.asset;

    final sections = <DSDetailSection>[
      // Shared sections (Identity)
      ...toDSSections(descriptor.sharedSections),
      // Kind-specific workflow panels
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
