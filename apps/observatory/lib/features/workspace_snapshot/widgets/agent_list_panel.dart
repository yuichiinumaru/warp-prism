/// Agent list panel for the workspace snapshot page.
///
/// Displays discovered agents using [PrismAssetCard] primitives.
/// Cards are tappable to open the detail inspector.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warp_prism_observatory/data/models/workspace_graph.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';
import '../workspace_snapshot_provider.dart';

/// Renders a scrollable list of agent assets.
class AgentListPanel extends ConsumerWidget {
  final List<WorkspaceAsset> agents;

  const AgentListPanel({super.key, required this.agents});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (agents.isEmpty) {
      return const PrismStateSurface.empty(
        icon: Icons.smart_toy_outlined,
        title: 'No agents found',
        subtitle: 'Place agent .md files in .agents/agents/',
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: agents.length,
      itemBuilder: (context, index) {
        final agent = agents[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: PrismSpacing.sm),
          child: PrismAssetCard(
            name: agent.name,
            kind: agent.kind.name,
            description: agent.description.isNotEmpty
                ? agent.description
                : null,
            canonicality: agent.canonicality.name,
            tags: agent.tags.isNotEmpty ? agent.tags : null,
            edgeCount: agent.edges.length,
            onTap: () => selectAsset(ref, agent.id),
          ),
        );
      },
    );
  }
}
