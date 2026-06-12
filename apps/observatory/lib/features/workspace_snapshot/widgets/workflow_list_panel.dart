/// Workflow list panel for the workspace snapshot page.
///
/// Displays discovered workflows using [DSAssetCard] primitives.
/// Cards are tappable to open the detail inspector.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warp_prism_observatory/data/models/workspace_graph.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';
import '../workspace_snapshot_provider.dart';

/// Renders a scrollable list of workflow assets.
class WorkflowListPanel extends ConsumerWidget {
  final List<WorkspaceAsset> workflows;

  const WorkflowListPanel({super.key, required this.workflows});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (workflows.isEmpty) {
      return const DSStateSurface.empty(
        icon: Icons.account_tree_outlined,
        title: 'No workflows found',
        subtitle: 'Place workflow .md files in .agents/workflows/',
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: workflows.length,
      itemBuilder: (context, index) {
        final wf = workflows[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: DSSpacing.sm),
          child: DSAssetCard(
            name: wf.name,
            kind: wf.kind.name,
            description: wf.description.isNotEmpty ? wf.description : null,
            canonicality: wf.canonicality.name,
            tags: wf.tags.isNotEmpty ? wf.tags : null,
            edgeCount: wf.edges.length,
            onTap: () => selectAsset(ref, wf.id),
          ),
        );
      },
    );
  }
}
