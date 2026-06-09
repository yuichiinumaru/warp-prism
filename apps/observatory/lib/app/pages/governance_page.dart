import 'package:flutter/material.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// Placeholder page for the Governance workspace.
/// To be replaced by the real Governance screen in EPIC-08.
class GovernancePage extends StatelessWidget {
  const GovernancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DSIcon(Icons.gavel_outlined, color: DSColors.accentCyan, size: 48),
          const SizedBox(height: DSSpacing.lg),
          DSText.headingMedium('Governance', color: DSColors.textPrimary),
          const SizedBox(height: DSSpacing.sm),
          DSText.bodyMedium(
            'Provenance & staleness — coming soon',
            color: DSColors.textTertiary,
          ),
        ],
      ),
    );
  }
}
