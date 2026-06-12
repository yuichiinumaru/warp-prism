import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../tokens/tokens.dart';
import '../atoms/atoms.dart';

/// ASW Observatory Molecule - Task Card
///
/// Card for displaying task in lane board or list.
/// Supports keyboard focus and activation.
class DSTaskCard extends StatefulWidget {
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

  @override
  State<DSTaskCard> createState() => _DSTaskCardState();
}

class _DSTaskCardState extends State<DSTaskCard> {
  bool _isFocused = false;
  final FocusNode _focusNode = FocusNode();

  Color get _laneColor => DSColors.forLane(widget.lane);

  Color get _proofColor {
    switch (widget.proofState?.toLowerCase()) {
      case 'complete':
        return DSColors.statusSuccess;
      case 'partial':
        return DSColors.statusWarning;
      case 'missing':
        return DSColors.statusError;
      default:
        return DSColors.textTertiary;
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.selected
        ? _laneColor.withOpacity(0.1)
        : DSColors.obsidianElevated;
    final borderColor = widget.selected
        ? _laneColor.withOpacity(0.5)
        : DSColors.borderSubtle;

    // Build semantic label summarizing the card
    final parts = <String>[
      'Task ${widget.id}',
      widget.title,
      'lane ${widget.lane}',
    ];
    if (widget.priority != null) parts.add('priority ${widget.priority}');
    if (widget.owner != null) parts.add('owner ${widget.owner}');
    if (widget.proofState != null) parts.add('proof ${widget.proofState}');

    return Semantics(
      label: parts.join(', '),
      button: true,
      selected: widget.selected,
      child: Focus(
        focusNode: _focusNode,
        onFocusChange: (focused) => setState(() => _isFocused = focused),
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.enter ||
                event.logicalKey == LogicalKeyboardKey.space) {
              widget.onTap?.call();
              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        child: GestureDetector(
          onTap: widget.onTap,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: AnimatedContainer(
              duration: DSMotion.fast,
              padding: const EdgeInsets.all(DSSpacing.insetCardCompact),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(DSRadii.card),
                border: Border.all(
                  color: _isFocused
                      ? DSColors.accentCyan.withOpacity(0.5)
                      : borderColor,
                  width: _isFocused ? 2 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row
                  Row(
                    children: [
                      // Task ID
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _laneColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(DSRadii.xs),
                        ),
                        child: DSText.code('#${widget.id}', color: _laneColor),
                      ),
                      const SizedBox(width: DSSpacing.xs),

                      // Priority
                      if (widget.priority != null) ...[
                        _PriorityBadge(priority: widget.priority!),
                        const SizedBox(width: DSSpacing.xs),
                      ],

                      const Spacer(),

                      // Proof state indicator
                      if (widget.proofState != null)
                        DSStatusDot(
                          color: _proofColor,
                          tooltip: 'Proof: ${widget.proofState}',
                        ),
                    ],
                  ),

                  const SizedBox(height: DSSpacing.sm),

                  // Title
                  DSText.bodyMedium(
                    widget.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: DSSpacing.sm),

                  // Footer row
                  Row(
                    children: [
                      // Owner
                      if (widget.owner != null) ...[
                        DSIcon.small(
                          Icons.person_outline,
                          color: DSColors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: DSText.labelSmall(
                            widget.owner!,
                            color: DSColors.textTertiary,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],

                      // Dependency count
                      if (widget.dependencyCount != null &&
                          widget.dependencyCount! > 0) ...[
                        const SizedBox(width: DSSpacing.sm),
                        DSIcon.small(
                          DSIcons.link,
                          color: DSColors.textTertiary,
                        ),
                        const SizedBox(width: 2),
                        DSText.labelSmall(
                          widget.dependencyCount.toString(),
                          color: DSColors.textTertiary,
                        ),
                      ],

                      // Review score
                      if (widget.reviewScore != null) ...[
                        const SizedBox(width: DSSpacing.sm),
                        _ReviewScore(score: widget.reviewScore!),
                      ],
                    ],
                  ),

                  // Linked skills
                  if (widget.linkedSkills != null &&
                      widget.linkedSkills!.isNotEmpty) ...[
                    const SizedBox(height: DSSpacing.sm),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: widget.linkedSkills!
                          .take(2)
                          .map(
                            (skill) => DSChip(
                              label: skill,
                              size: DSChipSize.small,
                              color: DSColors.assetSkill,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
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
      case 'P0':
        return DSColors.statusError;
      case 'P1':
        return DSColors.statusWarning;
      case 'P2':
        return DSColors.statusInfo;
      default:
        return DSColors.textTertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Priority $priority',
      child: Container(
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
    return Semantics(
      label: 'Review score $score',
      child: Container(
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
      ),
    );
  }
}
