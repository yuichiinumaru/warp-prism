/// Converts [DetailSection] from the descriptor into [DSDetailSection]
/// for the [DSDetailInspector] organism.
library;

import 'package:flutter/material.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';
import '../domain/asset_detail_descriptor.dart';

/// Converts a descriptor [DetailSection] into a DS [DSDetailSection].
DSDetailSection toDSSection(DetailSection section) {
  return DSDetailSection(
    title: section.title,
    icon: _iconForHint(section.iconHint, section.key),
    count: section.count,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Property rows
        ...section.properties.map(
          (p) => DSPropertyRow(label: p.label, value: p.value),
        ),

        // Code blocks
        if (section.codeBlocks.isNotEmpty) ...[
          if (section.properties.isNotEmpty &&
              section.properties.first.value != 'No verification commands')
            const SizedBox(height: DSSpacing.xs),
          ...section.codeBlocks.map(
            (cmd) => Padding(
              padding: const EdgeInsets.only(bottom: DSSpacing.xs),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(DSSpacing.sm),
                decoration: BoxDecoration(
                  color: DSColors.obsidianDeep,
                  borderRadius: BorderRadius.circular(DSRadii.sm),
                  border: Border.all(color: DSColors.borderSubtle),
                ),
                child: DSText.code(cmd, color: DSColors.accentCyan),
              ),
            ),
          ),
        ],

        // Link rows
        if (section.links.isNotEmpty) ...[
          if (section.properties.isNotEmpty)
            const SizedBox(height: DSSpacing.sm),
          Wrap(
            spacing: DSSpacing.xs,
            runSpacing: DSSpacing.xs,
            children: section.links
                .map(
                  (link) => DSLinkRow(
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

/// Builds [DSDetailSection] list from a descriptor's sections.
List<DSDetailSection> toDSSections(List<DetailSection> sections) {
  return sections.map(toDSSection).toList();
}

/// Builds the link section for incoming/outgoing links.
DSDetailSection buildLinksSection(
  String title,
  List<DetailLink> links, {
  bool isIncoming = true,
}) {
  return DSDetailSection(
    title: title,
    icon: isIncoming ? Icons.call_received : Icons.call_made,
    count: links.length,
    child: links.isEmpty
        ? DSText.bodySmall(
            isIncoming ? 'No incoming links' : 'No outgoing links',
            color: DSColors.textTertiary,
          )
        : Wrap(
            spacing: DSSpacing.xs,
            runSpacing: DSSpacing.xs,
            children: links
                .map(
                  (link) => DSLinkRow(
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
      return DSIcons.task;
    case 'skill':
      return DSIcons.skill;
    case 'workflow':
      return DSIcons.workflow;
    case 'agent':
      return DSIcons.agent;
    case 'changelog':
      return DSIcons.changelog;
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
      return DSIcons.link;
  }
}

/// Maps link kind to accent color.
Color _colorForKind(String kind) {
  switch (kind) {
    case 'task':
      return DSColors.assetTask;
    case 'skill':
      return DSColors.assetSkill;
    case 'workflow':
      return DSColors.assetWorkflow;
    case 'agent':
      return DSColors.assetAgent;
    case 'changelog':
      return DSColors.assetChangelog;
    case 'dependsOn':
      return DSColors.statusWarning;
    case 'impact':
      return DSColors.statusInfo;
    default:
      return DSColors.textSecondary;
  }
}
