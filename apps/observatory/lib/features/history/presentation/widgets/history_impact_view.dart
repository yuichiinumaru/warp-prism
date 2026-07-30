/// Impact Story view for the History workspace.
///
/// Shows the causality chain: changelog -> task -> skill/workflow
/// for each entry. Exposes partial paths explicitly when references
/// are missing (no fabricated chains).
library;

import 'package:flutter/material.dart';
import 'package:warp_prism_observatory/features/history/presentation/history_controller.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// Renders impact-path nodes as navigable causality chains.
///
/// Each node shows:
/// 1. The changelog entry
/// 2. Its linked task (if any)
/// 3. Skills/workflows it touched (if any)
///
/// Missing hops are rendered as explicit gap indicators, not hidden.
class HistoryImpactView extends StatelessWidget {
  /// Impact-path nodes derived from the History read model.
  final List<ImpactPathNode> nodes;

  /// Callback when a node's entry is tapped.
  final ValueChanged<String>? onEntryTap;

  /// Currently selected entry ID.
  final String? selectedEntryId;

  const HistoryImpactView({
    super.key,
    required this.nodes,
    this.onEntryTap,
    this.selectedEntryId,
  });

  @override
  Widget build(BuildContext context) {
    if (nodes.isEmpty) {
      return const PrismStateSurface.empty(
        icon: Icons.account_tree_outlined,
        title: 'No impact paths',
        subtitle:
            'Impact chains will appear once changelog entries have task and skill links',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(PrismSpacing.lg),
      itemCount: nodes.length,
      itemBuilder: (context, index) {
        final node = nodes[index];
        return Padding(
          padding: EdgeInsets.only(
            bottom: index < nodes.length - 1 ? PrismSpacing.sm : 0,
          ),
          child: _ImpactPathCard(
            node: node,
            onTap: onEntryTap != null ? () => onEntryTap!(node.entry.id) : null,
            isSelected: node.entry.id == selectedEntryId,
          ),
        );
      },
    );
  }
}

class _ImpactPathCard extends StatelessWidget {
  final ImpactPathNode node;
  final VoidCallback? onTap;
  final bool isSelected;

  const _ImpactPathCard({
    required this.node,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final entry = node.entry;
    final hasTask = node.resolvedTaskId != null;
    final hasSkills = node.resolvedSkills.isNotEmpty;
    final hasWorkflows = node.resolvedWorkflows.isNotEmpty;
    final hasDownstream = hasSkills || hasWorkflows;

    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: onTap != null
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        child: Container(
          padding: const EdgeInsets.all(PrismSpacing.md),
          decoration: BoxDecoration(
            color: PrismColors.obsidianElevated,
            borderRadius: BorderRadius.circular(PrismRadii.md),
            border: Border.all(
              color: isSelected
                  ? PrismColors.accentCyan.withValues(alpha: 0.5)
                  : PrismColors.borderSubtle,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PathNode(
                icon: Icons.description_outlined,
                label: entry.id,
                sublabel: '${entry.project} · ${entry.type.name}',
                color: PrismColors.accentCyan,
              ),
              _PathConnector(
                isGap: !hasTask,
                gapMessage: !hasTask ? 'No linked task' : null,
              ),
              if (hasTask)
                _PathNode(
                  icon: PrismIcons.task,
                  label: 'Task ${entry.task}',
                  sublabel: 'Motivated this change',
                  color: PrismColors.statusSuccess,
                )
              else
                const _GapNode(label: 'No task linked to this entry'),
              if (hasTask)
                _PathConnector(
                  isGap: !hasDownstream,
                  gapMessage: !hasDownstream ? 'No skill/workflow links' : null,
                ),
              if (hasTask && hasDownstream)
                Wrap(
                  spacing: PrismSpacing.xs,
                  runSpacing: PrismSpacing.xs,
                  children: [
                    ...node.resolvedSkills.map(
                      (s) => _PathNode(
                        icon: PrismIcons.skill,
                        label: s,
                        sublabel: 'Skill touched',
                        color: PrismColors.statusWarning,
                        compact: true,
                      ),
                    ),
                    ...node.resolvedWorkflows.map(
                      (w) => _PathNode(
                        icon: Icons.account_tree_outlined,
                        label: w,
                        sublabel: 'Workflow touched',
                        color: PrismColors.statusWarning,
                        compact: true,
                      ),
                    ),
                  ],
                )
              else if (hasTask && !hasDownstream)
                const _GapNode(label: 'No skills/workflows linked'),
              const SizedBox(height: PrismSpacing.sm),
              Row(
                children: [
                  Icon(
                    node.hasCompletePath
                        ? Icons.check_circle_outline
                        : Icons.info_outline,
                    size: 14,
                    color: node.hasCompletePath
                        ? PrismColors.statusSuccess
                        : PrismColors.statusWarning,
                  ),
                  const SizedBox(width: PrismSpacing.xs),
                  PrismText.labelSmall(
                    node.hasCompletePath
                        ? 'Complete impact path'
                        : 'Partial impact path — some links missing',
                    color: node.hasCompletePath
                        ? PrismColors.statusSuccess
                        : PrismColors.statusWarning,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PathNode extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final Color color;
  final bool compact;

  const _PathNode({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.color,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: PrismSpacing.sm,
        vertical: compact ? PrismSpacing.xs : PrismSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(PrismRadii.sm),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
        children: [
          PrismIcon.small(icon, color: color),
          const SizedBox(width: PrismSpacing.xs),
          if (compact)
            PrismText.labelSmall(label, color: color)
          else
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PrismText.labelMedium(label, color: color),
                  PrismText.bodySmall(
                    sublabel,
                    color: PrismColors.textTertiary,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _PathConnector extends StatelessWidget {
  final bool isGap;
  final String? gapMessage;

  const _PathConnector({this.isGap = false, this.gapMessage});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Container(
            width: 2,
            height: 16,
            color: isGap
                ? PrismColors.statusWarning.withValues(alpha: 0.4)
                : PrismColors.borderSubtle,
          ),
          if (gapMessage != null) ...[
            const SizedBox(width: PrismSpacing.xs),
            PrismText.labelSmall(gapMessage!, color: PrismColors.statusWarning),
          ],
        ],
      ),
    );
  }
}

class _GapNode extends StatelessWidget {
  final String label;

  const _GapNode({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PrismSpacing.sm,
        vertical: PrismSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: PrismColors.statusWarning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(PrismRadii.sm),
        border: Border.all(
          color: PrismColors.statusWarning.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.link_off,
            size: 14,
            color: PrismColors.statusWarning,
          ),
          const SizedBox(width: PrismSpacing.xs),
          PrismText.labelSmall(label, color: PrismColors.statusWarning),
        ],
      ),
    );
  }
}
