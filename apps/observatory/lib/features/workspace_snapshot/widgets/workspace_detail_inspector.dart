/// Workspace asset detail inspector.
///
/// Opens on card click, graph node click, or deep-link navigation.
/// Uses [PrismDetailInspector] to render identity, metadata, relationships,
/// and related assets for the selected workspace asset.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warp_prism_observatory/data/models/task_contracts.dart';
import 'package:warp_prism_observatory/data/models/workspace_graph.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';
import '../workspace_snapshot_provider.dart';

/// Detail inspector panel for the workspace snapshot page.
///
/// Shows identity, metadata, relationships, and related assets for
/// the currently selected [WorkspaceAsset].
class WorkspaceDetailInspector extends ConsumerWidget {
  const WorkspaceDetailInspector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asset = ref.watch(selectedAssetProvider);

    if (asset == null) {
      return const PrismStateSurface.empty(
        icon: Icons.touch_app_outlined,
        title: 'No asset selected',
        subtitle: 'Click a card or graph node to inspect',
      );
    }

    final incoming = ref.watch(selectedAssetIncomingProvider);
    final outgoing = ref.watch(selectedAssetOutgoingProvider);

    final taskMeta = asset.frontmatter['_taskMetadata'] as TaskMetadata?;

    final sections = <PrismDetailSection>[
      // Identity section
      PrismDetailSection(
        title: 'Identity',
        icon: Icons.fingerprint,
        child: Column(
          children: [
            PrismPropertyRow(label: 'ID', value: asset.id),
            PrismPropertyRow(label: 'Kind', value: asset.kind.name),
            PrismPropertyRow(label: 'Path', value: asset.path),
            PrismPropertyRow(
              label: 'Provenance',
              value: asset.canonicality.name,
            ),
            if (asset.description.isNotEmpty)
              PrismPropertyRow(label: 'Description', value: asset.description),
          ],
        ),
      ),

      // Metadata section (frontmatter fields)
      if (asset.frontmatter.isNotEmpty)
        PrismDetailSection(
          title: 'Metadata',
          icon: Icons.data_object,
          count: asset.frontmatter.length,
          child: Column(
            children: asset.frontmatter.entries
                .where((e) => !e.key.startsWith('_'))
                .take(10)
                .map(
                  (e) => PrismPropertyRow(
                    label: e.key,
                    value: _formatValue(e.value),
                  ),
                )
                .toList(),
          ),
        ),

      // Tags and triggers
      if (asset.tags.isNotEmpty || asset.triggers.isNotEmpty)
        PrismDetailSection(
          title: 'Tags & Triggers',
          icon: Icons.label_outline,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (asset.tags.isNotEmpty) ...[
                const PrismText.labelSmall('Tags', color: PrismColors.textTertiary),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: asset.tags
                      .map(
                        (t) => PrismChip(label: t, size: PrismChipSize.small),
                      )
                      .toList(),
                ),
              ],
              if (asset.triggers.isNotEmpty) ...[
                const SizedBox(height: PrismSpacing.sm),
                const PrismText.labelSmall(
                  'Triggers',
                  color: PrismColors.textTertiary,
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: asset.triggers
                      .map(
                        (t) => PrismChip(label: t, size: PrismChipSize.small),
                      )
                      .toList(),
                ),
              ],
            ],
          ),
        ),

      // Task-specific metadata
      if (asset.kind == AssetKind.task && taskMeta != null)
        PrismDetailSection(
          title: 'Task Details',
          icon: Icons.task_alt,
          child: Column(
            children: [
              PrismPropertyRow(
                label: 'Lane',
                value: taskMeta.lane.directoryPrefix,
              ),
              PrismPropertyRow(label: 'Priority', value: taskMeta.priority),
              PrismPropertyRow(label: 'Owner', value: taskMeta.owner),
              PrismPropertyRow(label: 'Proof', value: taskMeta.proofState.name),
              if (taskMeta.reviewScore != null)
                PrismPropertyRow(
                  label: 'Review',
                  value: taskMeta.reviewScore!.toStringAsFixed(1),
                ),
            ],
          ),
        ),

      // Relationships section
      PrismDetailSection(
        title: 'Relationships',
        icon: Icons.hub,
        count: incoming.length + outgoing.length,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (outgoing.isNotEmpty) ...[
              PrismText.labelSmall(
                'Outgoing (${outgoing.length})',
                color: PrismColors.textTertiary,
              ),
              const SizedBox(height: 4),
              ...outgoing
                  .take(10)
                  .map(
                    (edge) => _EdgeRow(
                      edge: edge,
                      direction: '→',
                      onTap: () => selectAsset(ref, edge.targetId),
                    ),
                  ),
            ],
            if (incoming.isNotEmpty) ...[
              const SizedBox(height: PrismSpacing.sm),
              PrismText.labelSmall(
                'Incoming (${incoming.length})',
                color: PrismColors.textTertiary,
              ),
              const SizedBox(height: 4),
              ...incoming
                  .take(10)
                  .map(
                    (edge) => _EdgeRow(
                      edge: edge,
                      direction: '←',
                      onTap: () => selectAsset(ref, edge.sourceId),
                    ),
                  ),
            ],
            if (incoming.isEmpty && outgoing.isEmpty)
              const PrismText.bodySmall(
                'No relationships',
                color: PrismColors.textTertiary,
              ),
          ],
        ),
      ),
    ];

    return PrismDetailInspector(
      title: asset.name,
      kind: asset.kind.name,
      subtitle: asset.description.isNotEmpty ? asset.description : null,
      sections: sections,
      onClose: () => clearSelection(ref),
    );
  }

  static String _formatValue(dynamic value) {
    if (value == null) return 'null';
    if (value is List) return value.join(', ');
    if (value is Map) {
      return value.entries.map((e) => '${e.key}: ${e.value}').join(', ');
    }
    return value.toString();
  }
}

/// Row showing an edge with its kind and navigation.
class _EdgeRow extends StatelessWidget {
  final WorkspaceEdge edge;
  final String direction;
  final VoidCallback? onTap;

  const _EdgeRow({required this.edge, required this.direction, this.onTap});

  @override
  Widget build(BuildContext context) {
    final targetId = direction == '→' ? edge.targetId : edge.sourceId;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: PrismLinkRow(
        label: '$direction ${edge.kind.name}: $targetId',
        icon: PrismIcons.link,
        color: _edgeKindColor(edge.kind),
        onTap: onTap,
      ),
    );
  }

  static Color _edgeKindColor(EdgeKind kind) {
    switch (kind) {
      case EdgeKind.contains:
        return PrismColors.accentViolet;
      case EdgeKind.routesTo:
        return PrismColors.accentCyan;
      case EdgeKind.dependsOn:
        return PrismColors.statusWarning;
      case EdgeKind.references:
        return PrismColors.textSecondary;
      case EdgeKind.changedBy:
        return PrismColors.statusSuccess;
      case EdgeKind.proves:
        return PrismColors.accentGold;
      case EdgeKind.uses:
        return PrismColors.statusInfo;
    }
  }
}
