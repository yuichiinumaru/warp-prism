/// Skill detail view for the universal asset inspector.
///
/// Renders 6 panels:
/// 1. Identity — name, description, triggers, tags, canonical home
/// 2. Role in the Harness — gateway, flat, review, provider, etc.
/// 3. Sub-structure — sub-skills, local workflows, references, scripts
/// 4. Incoming Links — agents/workflows/other skills that cite it
/// 5. Operational Usage — trigger phrases, entry workflow, boundary cases
/// 6. Governance — scorecard evidence, archive lineage, drift flags
library;

import 'package:flutter/material.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';
import '../domain/asset_detail_descriptor.dart';
import 'detail_section_builder.dart';

/// Renders a skill's detail using the [PrismDetailInspector].
class SkillDetailView extends StatelessWidget {
  final AssetDetailDescriptor descriptor;
  final VoidCallback? onClose;

  const SkillDetailView({super.key, required this.descriptor, this.onClose});

  @override
  Widget build(BuildContext context) {
    final asset = descriptor.asset;
    final sections = <PrismDetailSection>[
      // Shared sections (Identity)
      ...toDSSections(descriptor.sharedSections),
      // Kind-specific panels (Role, Sub-structure, Usage, Governance)
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
      subtitle: asset.description.isNotEmpty ? asset.description : null,
      sections: sections,
      onClose: onClose,
    );
  }
}
