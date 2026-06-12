import 'package:flutter/material.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// Placeholder page for the Operate workspace (tasks, lanes).
/// To be replaced by the real Operate screen in EPIC-06.
class OperatePage extends StatelessWidget {
  const OperatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DSIcon(
            Icons.play_circle_outline,
            color: DSColors.accentCyan,
            size: 48,
          ),
          const SizedBox(height: DSSpacing.lg),
          DSText.headingMedium('Operate', color: DSColors.textPrimary),
          const SizedBox(height: DSSpacing.sm),
          DSText.bodyMedium(
            'Task lanes — coming soon',
            color: DSColors.textTertiary,
          ),
        ],
      ),
    );
  }
}
