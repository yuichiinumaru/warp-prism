import 'package:flutter/material.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// Placeholder page for the History workspace (changelog timeline).
/// To be replaced by the real History screen in EPIC-07.
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DSIcon(Icons.history_outlined, color: DSColors.accentCyan, size: 48),
          const SizedBox(height: DSSpacing.lg),
          DSText.headingMedium('History', color: DSColors.textPrimary),
          const SizedBox(height: DSSpacing.sm),
          DSText.bodyMedium(
            'Changelog timeline — coming soon',
            color: DSColors.textTertiary,
          ),
        ],
      ),
    );
  }
}
