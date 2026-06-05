import 'package:flutter/material.dart';
import '../tokens/tokens.dart';
import '../atoms/atoms.dart';

/// ASW Observatory Molecule - Evidence Row
/// 
/// Row displaying verification evidence for tasks
class DSEvidenceRow extends StatelessWidget {
  final String label;
  final String? value;
  final DSEvidenceState state;
  final IconData? icon;
  final VoidCallback? onTap;

  const DSEvidenceRow({
    super.key,
    required this.label,
    this.value,
    required this.state,
    this.icon,
    this.onTap,
  });

  Color get _stateColor {
    switch (state) {
      case DSEvidenceState.verified: return DSColors.statusSuccess;
      case DSEvidenceState.partial: return DSColors.statusWarning;
      case DSEvidenceState.missing: return DSColors.statusError;
      case DSEvidenceState.pending: return DSColors.textTertiary;
    }
  }

  IconData get _stateIcon {
    switch (state) {
      case DSEvidenceState.verified: return Icons.check_circle;
      case DSEvidenceState.partial: return Icons.remove_circle;
      case DSEvidenceState.missing: return Icons.cancel;
      case DSEvidenceState.pending: return Icons.schedule;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DSSpacing.md,
            vertical: DSSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: DSColors.obsidianElevated,
            borderRadius: BorderRadius.circular(DSRadii.sm),
            border: Border.all(
              color: _stateColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // State indicator
              Icon(_stateIcon, size: 16, color: _stateColor),
              const SizedBox(width: DSSpacing.sm),
              
              // Icon if provided
              if (icon != null) ...[
                DSIcon.small(icon!, color: DSColors.textTertiary),
                const SizedBox(width: DSSpacing.sm),
              ],
              
              // Label
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DSText.labelMedium(label),
                    if (value != null) ...[
                      const SizedBox(height: 2),
                      DSText.bodySmall(
                        value!,
                        color: DSColors.textSecondary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              
              // Arrow if interactive
              if (onTap != null)
                DSIcon.small(Icons.chevron_right, color: DSColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}

enum DSEvidenceState {
  verified,
  partial,
  missing,
  pending,
}

/// Compact evidence indicator for inline use
class DSEvidenceIndicator extends StatelessWidget {
  final DSEvidenceState state;
  final String? label;

  const DSEvidenceIndicator({
    super.key,
    required this.state,
    this.label,
  });

  Color get _color {
    switch (state) {
      case DSEvidenceState.verified: return DSColors.statusSuccess;
      case DSEvidenceState.partial: return DSColors.statusWarning;
      case DSEvidenceState.missing: return DSColors.statusError;
      case DSEvidenceState.pending: return DSColors.textTertiary;
    }
  }

  IconData get _icon {
    switch (state) {
      case DSEvidenceState.verified: return Icons.verified;
      case DSEvidenceState.partial: return Icons.pending;
      case DSEvidenceState.missing: return Icons.error;
      case DSEvidenceState.pending: return Icons.schedule;
    }
  }

  String get _defaultLabel {
    switch (state) {
      case DSEvidenceState.verified: return 'Verified';
      case DSEvidenceState.partial: return 'Partial';
      case DSEvidenceState.missing: return 'Missing';
      case DSEvidenceState.pending: return 'Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(_icon, size: 14, color: _color),
        const SizedBox(width: 4),
        Text(
          label ?? _defaultLabel,
          style: DSTypography.labelSmall.copyWith(color: _color),
        ),
      ],
    );
  }
}
