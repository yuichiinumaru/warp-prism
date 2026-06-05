import 'package:flutter/material.dart';
import '../tokens/tokens.dart';
import '../atoms/atoms.dart';

/// ASW Observatory Molecule - Task Card
/// 
/// Card for displaying task in lane board or list
class DSTaskCard extends StatelessWidget {
  final int id;
  final String title;
  final String lane;
  final String? priority;
  final String? owner;
  final String? proofState;
  final int? reviewScore;
  final List<String>? linkedSkills;
  final int? dependencyCount;
  final bool selected;
  final VoidCallback? onTap;

  const DSTaskCard({
    super.key,
    required this.id,
    required this.title,
    required this.lane,
    this.priority,
    this.owner,
    this.proofState,
    this.reviewScore,
    this.linkedSkills,
    this.dependencyCount,
    this.selected = false,
    this.onTap,
  });

  Color get _laneColor => DSColors.forLane(lane);
  
  Color get _proofColor {
    switch (proofState?.toLowerCase()) {
      case 'complete': return DSColors.statusSuccess;
      case 'partial': return DSColors.statusWarning;
      case 'missing': return DSColors.statusError;
      default: return DSColors.textTertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = selected
        ? _laneColor.withOpacity(0.1)
        : DSColors.obsidianElevated;
    final borderColor = selected
        ? _laneColor.withOpacity(0.5)
        : DSColors.borderSubtle;

    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: DSMotion.fast,
          padding: const EdgeInsets.all(DSSpacing.insetCardCompact),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(DSRadii.card),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // Task ID
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _laneColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(DSRadii.xs),
                    ),
                    child: DSText.code(
                      '#$id',
                      color: _laneColor,
                    ),
                  ),
                  const SizedBox(width: DSSpacing.xs),
                  
                  // Priority
                  if (priority != null) ...[
                    _PriorityBadge(priority: priority!),
                    const SizedBox(width: DSSpacing.xs),
                  ],
                  
                  const Spacer(),
                  
                  // Proof state indicator
                  if (proofState != null)
                    DSStatusDot(
                      color: _proofColor,
                      tooltip: 'Proof: $proofState',
                    ),
                ],
              ),
              
              const SizedBox(height: DSSpacing.sm),
              
              // Title
              DSText.bodyMedium(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: DSSpacing.sm),
              
              // Footer row
              Row(
                children: [
                  // Owner
                  if (owner != null) ...[
                    DSIcon.small(Icons.person_outline, color: DSColors.textTertiary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: DSText.labelSmall(
                        owner!,
                        color: DSColors.textTertiary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  
                  // Dependency count
                  if (dependencyCount != null && dependencyCount! > 0) ...[
                    const SizedBox(width: DSSpacing.sm),
                    DSIcon.small(DSIcons.link, color: DSColors.textTertiary),
                    const SizedBox(width: 2),
                    DSText.labelSmall(
                      dependencyCount.toString(),
                      color: DSColors.textTertiary,
                    ),
                  ],
                  
                  // Review score
                  if (reviewScore != null) ...[
                    const SizedBox(width: DSSpacing.sm),
                    _ReviewScore(score: reviewScore!),
                  ],
                ],
              ),
              
              // Linked skills
              if (linkedSkills != null && linkedSkills!.isNotEmpty) ...[
                const SizedBox(height: DSSpacing.sm),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: linkedSkills!.take(2).map((skill) => DSChip(
                    label: skill,
                    size: DSChipSize.small,
                    color: DSColors.assetSkill,
                  )).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  final String priority;

  const _PriorityBadge({required this.priority});

  Color get _color {
    switch (priority.toUpperCase()) {
      case 'P0': return DSColors.statusError;
      case 'P1': return DSColors.statusWarning;
      case 'P2': return DSColors.statusInfo;
      default: return DSColors.textTertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(DSRadii.xs),
      ),
      child: Text(
        priority.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: _color,
        ),
      ),
    );
  }
}

class _ReviewScore extends StatelessWidget {
  final int score;

  const _ReviewScore({required this.score});

  Color get _color {
    if (score >= 80) return DSColors.statusSuccess;
    if (score >= 60) return DSColors.statusWarning;
    return DSColors.statusError;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(DSRadii.xs),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, size: 10, color: _color),
          const SizedBox(width: 2),
          Text(
            score.toString(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: _color,
            ),
          ),
        ],
      ),
    );
  }
}
