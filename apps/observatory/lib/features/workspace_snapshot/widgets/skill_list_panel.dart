/// Skill list panel for the workspace snapshot page.
///
/// Displays discovered skills and sub-skills using [PrismAssetCard] primitives.
/// Cards are tappable to open the detail inspector.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warp_prism_observatory/data/models/workspace_graph.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';
import '../workspace_snapshot_provider.dart';

/// Renders a scrollable list of skill and sub-skill assets.
class SkillListPanel extends ConsumerWidget {
  final List<WorkspaceAsset> skills;

  const SkillListPanel({super.key, required this.skills});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (skills.isEmpty) {
      return const PrismStateSurface.empty(
        icon: Icons.build_outlined,
        title: 'No skills found',
        subtitle: 'Place SKILL.md files in .agents/skills/*/',
      );
    }

    // Separate top-level skills from sub-skills
    final topSkills = skills.where((s) => s.kind == AssetKind.skill).toList();
    final subSkills = skills
        .where((s) => s.kind == AssetKind.subskill)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top-level skills
        if (topSkills.isNotEmpty) ...[
          PrismText.labelMedium(
            'SKILLS (${topSkills.length})',
            color: PrismColors.textSecondary,
          ),
          const SizedBox(height: PrismSpacing.sm),
          ...topSkills.map(
            (skill) => Padding(
              padding: const EdgeInsets.only(bottom: PrismSpacing.sm),
              child: PrismAssetCard(
                name: skill.name,
                kind: skill.kind.name,
                description: skill.description.isNotEmpty
                    ? skill.description
                    : null,
                canonicality: skill.canonicality.name,
                tags: skill.tags.isNotEmpty ? skill.tags : null,
                edgeCount: skill.edges.length,
                onTap: () => selectAsset(ref, skill.id),
              ),
            ),
          ),
        ],

        // Sub-skills
        if (subSkills.isNotEmpty) ...[
          const SizedBox(height: PrismSpacing.md),
          PrismText.labelMedium(
            'SUB-SKILLS (${subSkills.length})',
            color: PrismColors.textSecondary,
          ),
          const SizedBox(height: PrismSpacing.sm),
          ...subSkills.map(
            (skill) => Padding(
              padding: const EdgeInsets.only(bottom: PrismSpacing.sm),
              child: PrismAssetCard(
                name: skill.name,
                kind: skill.kind.name,
                description: skill.description.isNotEmpty
                    ? skill.description
                    : null,
                canonicality: skill.canonicality.name,
                tags: skill.tags.isNotEmpty ? skill.tags : null,
                edgeCount: skill.edges.length,
                onTap: () => selectAsset(ref, skill.id),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
