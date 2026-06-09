/// Workspace asset detail inspector.
///
/// Opens on card click, graph node click, or deep-link navigation.
/// Uses [DSDetailInspector] to render identity, metadata, relationships,
/// and related assets for the selected workspace asset.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/task_contracts.dart';
import '../../../../data/models/workspace_graph.dart';
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
      return DSStateSurface.empty(
        icon: Icons.touch_app_outlined,
        title: 'No asset selected',
        subtitle: 'Click a card or graph node to inspect',
      );
    }

    final incoming = ref.watch(selectedAssetIncomingProvider);
    final outgoing = ref.watch(selectedAssetOutgoingProvider);

    final taskMeta =
        asset.frontmatter['_taskMetadata'] as TaskMetadata?;

    final sections = <DSDetailSection>[
      // Identity section
      DSDetailSection(
        title: 'Identity',
        icon: Icons.fingerprint,
        child: Column(
          children: [
            DSPropertyRow(label: 'ID', value: asset.id),
            DSPropertyRow(label: 'Kind', value: asset.kind.name),
            DSPropertyRow(label: 'Path', value: asset.path),
            DSPropertyRow(
              label: 'Provenance',
              value: asset.canonicality.name,
            ),
            if (asset.description.isNotEmpty)
              DSPropertyRow(label: 'Description', value: asset.description),
          ],
        ),
      ),

      // Metadata section (frontmatter fields)
      if (asset.frontmatter.isNotEmpty)
        DSDetailSection(
          title: 'Metadata',
          icon: Icons.data_object,
          count: asset.frontmatter.length,
          child: Column(
            children: asset.frontmatter.entries
                .where((e) => !e.key.startsWith('_'))
                .take(10)
                .map((e) => DSPropertyRow(
                      label: e.key,
                      value: _formatValue(e.value),
                    ))
                .toList(),
          ),
        ),

      // Tags and triggers
      if (asset.tags.isNotEmpty || asset.triggers.isNotEmpty)
        DSDetailSection(
          title: 'Tags & Triggers',
          icon: Icons.label_outline,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (asset.tags.isNotEmpty) ...[
                DSText.labelSmall('Tags', color: DSColors.textTertiary),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: asset.tags
                      .map((t) => DSChip(label: t, size: DSChipSize.small))
                      .toList(),
                ),
              ],
              if (asset.triggers.isNotEmpty) ...[
                const SizedBox(height: DSSpacing.sm),
                DSText.labelSmall('Triggers', color: DSColors.textTertiary),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: asset.triggers
                      .map((t) => DSChip(label: t, size: DSChipSize.small))
                      .toList(),
                ),
              ],
            ],
          ),
        ),

      // Task-specific metadata
      if (asset.kind == AssetKind.task && taskMeta != null)
        DSDetailSection(
          title: 'Task Details',
          icon: Icons.task_alt,
          child: Column(
            children: [
              DSPropertyRow(
                label: 'Lane',
                value: taskMeta.lane.directoryPrefix,
              ),
              DSPropertyRow(
                label: 'Priority',
                value: taskMeta.priority,
              ),
              DSPropertyRow(label: 'Owner', value: taskMeta.owner),
              DSPropertyRow(
                label: 'Proof',
                value: taskMeta.proofState.name,
              ),
              if (taskMeta.reviewScore != null)
                DSPropertyRow(
                  label: 'Review',
                  value: taskMeta.reviewScore!.toStringAsFixed(1),
                ),
            ],
          ),
        ),

      // Relationships section
      DSDetailSection(
        title: 'Relationships',
        icon: Icons.hub,
        count: incoming.length + outgoing.length,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (outgoing.isNotEmpty) ...[
              DSText.labelSmall(
                'Outgoing (${outgoing.length})',
                color: DSColors.textTertiary,
              ),
              const SizedBox(height: 4),
              ...outgoing.take(10).map((edge) => _EdgeRow(
                    edge: edge,
                    direction: '→',
                    onTap: () => selectAsset(ref, edge.targetId),
                  )),
            ],
            if (incoming.isNotEmpty) ...[
              const SizedBox(height: DSSpacing.sm),
              DSText.labelSmall(
                'Incoming (${incoming.length})',
                color: DSColors.textTertiary,
              ),
              const SizedBox(height: 4),
              ...incoming.take(10).map((edge) => _EdgeRow(
                    edge: edge,
                    direction: '←',
                    onTap: () => selectAsset(ref, edge.sourceId),
                  )),
            ],
            if (incoming.isEmpty && outgoing.isEmpty)
              DSText.bodySmall(
                'No relationships',
                color: DSColors.textTertiary,
              ),
          ],
        ),
      ),
    ];

    return DSDetailInspector(
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
    if (value is Map) return value.entries.map((e) => '${e.key}: ${e.value}').join(', ');
    return value.toString();
  }
}

/// Row showing an edge with its kind and navigation.
class _EdgeRow extends StatelessWidget {
  final WorkspaceEdge edge;
  final String direction;
  final VoidCallback? onTap;

  const _EdgeRow({
    required this.edge,
    required this.direction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final targetId =
        direction == '→' ? edge.targetId : edge.sourceId;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: DSLinkRow(
        label: '$direction ${edge.kind.name}: $targetId',
        icon: DSIcons.link,
        color: _edgeKindColor(edge.kind),
        onTap: onTap,
      ),
    );
  }

  static Color _edgeKindColor(EdgeKind kind) {
    switch (kind) {
      case EdgeKind.contains:
        return DSColors.accentViolet;
      case EdgeKind.routesTo:
        return DSColors.accentCyan;
      case EdgeKind.dependsOn:
        return DSColors.statusWarning;
      case EdgeKind.references:
        return DSColors.textSecondary;
      case EdgeKind.changedBy:
        return DSColors.statusSuccess;
      case EdgeKind.proves:
        return DSColors.accentGold;
      case EdgeKind.uses:
        return DSColors.statusInfo;
    }
  }
}
