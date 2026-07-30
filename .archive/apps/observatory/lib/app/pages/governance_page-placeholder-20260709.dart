import 'package:flutter/material.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// Placeholder page for the Governance workspace.
/// To be replaced by the real Governance screen in EPIC-08.
class GovernancePage extends StatelessWidget {
  const GovernancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PrismIcon(
            Icons.gavel_outlined,
            color: PrismColors.accentCyan,
            size: 48,
          ),
          SizedBox(height: PrismSpacing.lg),
          PrismText.headingMedium('Governance', color: PrismColors.textPrimary),
          SizedBox(height: PrismSpacing.sm),
          PrismText.bodyMedium(
            'Provenance & staleness — coming soon',
            color: PrismColors.textTertiary,
          ),
        ],
      ),
    );
  }
}
