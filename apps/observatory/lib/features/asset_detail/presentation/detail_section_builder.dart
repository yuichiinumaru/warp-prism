/// Converts [DetailSection] from the descriptor into [PrismDetailSection]
/// for the [PrismDetailInspector] organism.
library;

import 'package:flutter/material.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';
import '../domain/asset_detail_descriptor.dart';

/// Converts a descriptor [DetailSection] into a DS [PrismDetailSection].
PrismDetailSection toDSSection(DetailSection section) {
  return PrismDetailSection(
    title: section.title,
    icon: _iconForHint(section.iconHint, section.key),
    count: section.count,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Property rows
        ...section.properties.map(
          (p) => PrismPropertyRow(label: p.label, value: p.value),
        ),

        // Code blocks
        if (section.codeBlocks.isNotEmpty) ...[
          if (section.properties.isNotEmpty &&
              section.properties.first.value != 'No verification commands')
            const SizedBox(height: PrismSpacing.xs),
          ...section.codeBlocks.map(
            (cmd) => Padding(
              padding: const EdgeInsets.only(bottom: PrismSpacing.xs),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(PrismSpacing.sm),
                decoration: BoxDecoration(
                  color: PrismColors.obsidianDeep,
                  borderRadius: BorderRadius.circular(PrismRadii.sm),
                  border: Border.all(color: PrismColors.borderSubtle),
                ),
                child: PrismText.code(cmd, color: PrismColors.accentCyan),
              ),
            ),
          ),
        ],

        // Link rows
        if (section.links.isNotEmpty) ...[
          if (section.properties.isNotEmpty)
            const SizedBox(height: PrismSpacing.sm),
          Wrap(
            spacing: PrismSpacing.xs,
            runSpacing: PrismSpacing.xs,
            children: section.links
                .map(
                  (link) => PrismLinkRow(
                    label: link.label,
                    icon: _iconForKind(link.kind),
                    color: _colorForKind(link.kind),
                  ),
                )
                .toList(),
          ),
        ],
      ],
    ),
  );
}

/// Builds [PrismDetailSection] list from a descriptor's sections.
List<PrismDetailSection> toDSSections(List<DetailSection> sections) {
  return sections.map(toDSSection).toList();
}

/// Builds the link section for incoming/outgoing links.
PrismDetailSection buildLinksSection(
  String title,
  List<DetailLink> links, {
  bool isIncoming = true,
}) {
  return PrismDetailSection(
    title: title,
    icon: isIncoming ? Icons.call_received : Icons.call_made,
    count: links.length,
    child: links.isEmpty
        ? PrismText.bodySmall(
            isIncoming ? 'No incoming links' : 'No outgoing links',
            color: PrismColors.textTertiary,
          )
        : Wrap(
            spacing: PrismSpacing.xs,
            runSpacing: PrismSpacing.xs,
            children: links
                .map(
                  (link) => PrismLinkRow(
                    label: '${isIncoming ? '←' : '→'} ${link.label}',
                    icon: _iconForKind(link.kind),
                    color: _colorForKind(link.kind),
                  ),
                )
                .toList(),
          ),
  );
}

/// Maps section key to icon.
IconData _iconForHint(String? hint, String key) {
  if (hint != null) {
    switch (hint) {
      case 'fingerprint':
        return Icons.fingerprint;
      case 'data_object':
        return Icons.data_object;
      case 'terminal':
        return Icons.terminal;
    }
  }
  switch (key) {
    case 'identity':
      return Icons.fingerprint;
    case 'role':
      return Icons.psychology_outlined;
    case 'substructure':
      return Icons.account_tree_outlined;
    case 'incoming':
      return Icons.call_received;
    case 'usage':
      return Icons.play_circle_outline;
    case 'governance':
      return Icons.shield_outlined;
    case 'contract':
      return Icons.description;
    case 'dependencies':
      return Icons.link;
    case 'validation':
      return Icons.terminal;
    case 'evidence':
      return Icons.fact_check;
    case 'lifecycle':
      return Icons.timeline;
    case 'related':
      return Icons.extension;
    case 'operational':
      return Icons.settings_outlined;
    case 'tools':
      return Icons.build_outlined;
    case 'skill_affinity':
      return Icons.psychology_outlined;
    case 'workflow_affinity':
      return Icons.account_tree_outlined;
    case 'trigger':
      return Icons.bolt_outlined;
    case 'stages':
      return Icons.stairs_outlined;
    case 'branches':
      return Icons.fork_right;
    case 'performance':
      return Icons.speed;
    case 'ledger':
      return Icons.book_outlined;
    case 'related_task':
      return Icons.task_outlined;
    case 'affected':
      return Icons.track_changes;
    case 'story':
      return Icons.auto_stories;
    case 'metadata':
      return Icons.data_object;
    case 'tags':
      return Icons.label_outline;
    default:
      return Icons.info_outline;
  }
}

/// Maps link kind to icon.
IconData _iconForKind(String kind) {
  switch (kind) {
    case 'task':
      return PrismIcons.task;
    case 'skill':
      return PrismIcons.skill;
    case 'workflow':
      return PrismIcons.workflow;
    case 'agent':
      return PrismIcons.agent;
    case 'changelog':
      return PrismIcons.changelog;
    case 'dependsOn':
      return Icons.link;
    case 'references':
      return Icons.link;
    case 'uses':
      return Icons.play_circle_outline;
    case 'contains':
      return Icons.folder_outlined;
    case 'routesTo':
      return Icons.alt_route;
    case 'changedBy':
      return Icons.change_history;
    case 'proves':
      return Icons.verified_outlined;
    default:
      return PrismIcons.link;
  }
}

/// Maps link kind to accent color.
Color _colorForKind(String kind) {
  switch (kind) {
    case 'task':
      return PrismColors.assetTask;
    case 'skill':
      return PrismColors.assetSkill;
    case 'workflow':
      return PrismColors.assetWorkflow;
    case 'agent':
      return PrismColors.assetAgent;
    case 'changelog':
      return PrismColors.assetChangelog;
    case 'dependsOn':
      return PrismColors.statusWarning;
    case 'impact':
      return PrismColors.statusInfo;
    default:
      return PrismColors.textSecondary;
  }
}
