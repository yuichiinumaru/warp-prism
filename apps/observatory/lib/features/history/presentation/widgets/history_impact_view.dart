/// Impact Story view for the History workspace.
///
/// Shows the causality chain: changelog -> task -> skill/workflow
/// for each entry. Exposes partial paths explicitly when references
/// are missing (no fabricated chains).
library;

import 'package:flutter/material.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';
import '../history_controller.dart';

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
      return DSStateSurface.empty(
        icon: Icons.account_tree_outlined,
        title: 'No impact paths',
        subtitle:
            'Impact chains will appear once changelog entries have task and skill links',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(DSSpacing.lg),
      itemCount: nodes.length,
      itemBuilder: (context, index) {
        final node = nodes[index];
        return Padding(
          padding: EdgeInsets.only(
            bottom: index < nodes.length - 1 ? DSSpacing.sm : 0,
          ),
          child: _ImpactPathCard(
            node: node,
            onTap: onEntryTap != null
                ? () => onEntryTap!(node.entry.id)
                : null,
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

    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: onTap != null
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        child: Container(
          padding: const EdgeInsets.all(DSSpacing.md),
          decoration: BoxDecoration(
            color: DSColors.obsidianElevated,
            borderRadius: BorderRadius.circular(DSRadii.md),
            border: Border.all(
              color: isSelected
                  ? DSColors.accentCyan.withOpacity(0.5)
                  : DSColors.borderSubtle,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Changelog entry node
              _PathNode(
                icon: Icons.description_outlined,
                label: entry.id,
                sublabel:
                    '${entry.project} · ${entry.type.name}',
                color: DSColors.accentCyan,
              ),

              // Arrow connector
              _PathConnector(
                isGap: !hasTask,
                gapMessage: !hasTask ? 'No linked task' : null,
              ),

              // Task node
              if (hasTask)
                _PathNode(
                  icon: DSIcons.task,
                  label: 'Task ${entry.task}',
                  sublabel: 'Motivated this change',
                  color: DSColors.statusSuccess,
                )
              else
                _GapNode(label: 'No task linked to this entry'),

              // Arrow connector to skills
              if (hasTask)
                _PathConnector(
                  isGap: !hasSkills,
                  gapMessage: !hasSkills ? 'No skill/workflow links' : null,
                ),

              // Skills/workflows node
              if (hasTask && hasSkills)
                Wrap(
                  spacing: DSSpacing.xs,
                  runSpacing: DSSpacing.xs,
                  children: node.resolvedSkills
                      .map((s) => _PathNode(
                            icon: DSIcons.skill,
                            label: s,
                            sublabel: 'Skill touched',
                            color: DSColors.statusWarning,
                            compact: true,
                          ))
                      .toList(),
                )
              else if (hasTask && !hasSkills)
                _GapNode(label: 'No skills/workflows linked'),

              // Path completeness indicator
              const SizedBox(height: DSSpacing.sm),
              Row(
                children: [
                  Icon(
                    node.hasCompletePath
                        ? Icons.check_circle_outline
                        : Icons.info_outline,
                    size: 14,
                    color: node.hasCompletePath
                        ? DSColors.statusSuccess
                        : DSColors.statusWarning,
                  ),
                  const SizedBox(width: DSSpacing.xs),
                  DSText.labelSmall(
                    node.hasCompletePath
                        ? 'Complete impact path'
                        : 'Partial impact path — some links missing',
                    color: node.hasCompletePath
                        ? DSColors.statusSuccess
                        : DSColors.statusWarning,
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

/// A node in the impact path visualization.
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
        horizontal: DSSpacing.sm,
        vertical: compact ? DSSpacing.xs : DSSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(DSRadii.sm),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
        children: [
          DSIcon.small(icon, color: color),
          const SizedBox(width: DSSpacing.xs),
          if (compact)
            DSText.labelSmall(label, color: color)
          else
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DSText.labelMedium(label, color: color),
                  DSText.bodySmall(sublabel, color: DSColors.textTertiary),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Vertical connector between path nodes.
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
                ? DSColors.statusWarning.withOpacity(0.4)
                : DSColors.borderSubtle,
          ),
          if (gapMessage != null) ...[
            const SizedBox(width: DSSpacing.xs),
            DSText.labelSmall(
              gapMessage!,
              color: DSColors.statusWarning,
            ),
          ],
        ],
      ),
    );
  }
}

/// Renders a gap node when a link is missing.
class _GapNode extends StatelessWidget {
  final String label;

  const _GapNode({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.sm,
        vertical: DSSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: DSColors.statusWarning.withOpacity(0.08),
        borderRadius: BorderRadius.circular(DSRadii.sm),
        border: Border.all(
          color: DSColors.statusWarning.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.link_off, size: 14, color: DSColors.statusWarning),
          const SizedBox(width: DSSpacing.xs),
          DSText.labelSmall(label, color: DSColors.statusWarning),
        ],
      ),
    );
  }
}
