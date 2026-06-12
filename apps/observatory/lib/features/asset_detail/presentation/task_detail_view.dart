/// Task detail view for the universal asset inspector.
///
/// Renders a forensic case file:
/// 1. Identity — lane-neutral header (Task NNNN + slug)
/// 2. Contract — lane, priority, owner, proof state, review score
/// 3. Dependencies — task depends-on links
/// 4. Validation Commands — verification commands as code blocks
/// 5. Evidence — completion evidence, exit conditions
/// 6. Related Skills & Workflows — linked skills/workflows
/// 7. Lifecycle — created, updated, started, completed dates
library;

import 'package:flutter/material.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';
import '../domain/asset_detail_descriptor.dart';
import 'detail_section_builder.dart';

/// Renders a task's forensic detail using the [DSDetailInspector].
class TaskDetailView extends StatelessWidget {
  final AssetDetailDescriptor descriptor;
  final VoidCallback? onClose;

  const TaskDetailView({super.key, required this.descriptor, this.onClose});

  @override
  Widget build(BuildContext context) {
    final asset = descriptor.asset;
    final fm = asset.frontmatter;

    // Build subtitle: lane-neutral identity
    final lane = fm['lane']?.toString() ?? fm['status']?.toString() ?? '';
    final priority = fm['priority']?.toString() ?? '';
    final subtitleParts = <String>[
      if (lane.isNotEmpty) 'Lane: $lane',
      if (priority.isNotEmpty) 'Priority: $priority',
    ];

    final sections = <DSDetailSection>[
      // Shared sections (Identity with lane-neutral header)
      ...toDSSections(descriptor.sharedSections),
      // Kind-specific forensic panels
      ...toDSSections(descriptor.kindSections),
      // Incoming/outgoing relationships
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
      title: '${asset.id} — ${asset.name}',
      kind: 'task',
      subtitle: subtitleParts.isNotEmpty ? subtitleParts.join('  •  ') : null,
      sections: sections,
      onClose: onClose,
    );
  }
}
