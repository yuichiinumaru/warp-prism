/// Derived metric tiles for the workspace snapshot page.
///
/// Shows computed metrics beyond raw counts: blocked tasks, review queue,
/// tasks without verification, skills with no triggers, orphan workflows,
/// and governance warnings.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';
import '../workspace_snapshot_provider.dart';

/// Derived metrics section for the workspace snapshot page.
///
/// Displays metric tiles for computed values derived from the snapshot data.
class WorkspaceDerivedMetrics extends ConsumerWidget {
  const WorkspaceDerivedMetrics({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshotAsync = ref.watch(workspaceSnapshotProvider);

    return snapshotAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (snapshot) {
        return Wrap(
          spacing: PrismSpacing.md,
          runSpacing: PrismSpacing.md,
          children: [
            PrismMetricTile(
              label: 'Blocked Tasks',
              value: '${snapshot.blockedTaskCount}',
              icon: Icons.block_outlined,
              color: snapshot.blockedTaskCount > 0
                  ? PrismColors.statusError
                  : PrismColors.statusSuccess,
            ),
            PrismMetricTile(
              label: 'Review Queue',
              value: '${snapshot.reviewQueueCount}',
              icon: Icons.rate_review_outlined,
              color: snapshot.reviewQueueCount > 0
                  ? PrismColors.statusWarning
                  : PrismColors.statusSuccess,
            ),
            PrismMetricTile(
              label: 'No Verification',
              value: '${snapshot.tasksWithoutVerification}',
              icon: Icons.warning_amber_outlined,
              color: snapshot.tasksWithoutVerification > 0
                  ? PrismColors.statusWarning
                  : PrismColors.statusSuccess,
            ),
            PrismMetricTile(
              label: 'No Triggers',
              value: '${snapshot.skillsWithNoTriggers}',
              icon: Icons.notifications_off_outlined,
              color: snapshot.skillsWithNoTriggers > 0
                  ? PrismColors.statusInfo
                  : PrismColors.statusSuccess,
            ),
            PrismMetricTile(
              label: 'Orphan Workflows',
              value: '${snapshot.orphanWorkflowCount}',
              icon: Icons.link_off_outlined,
              color: snapshot.orphanWorkflowCount > 0
                  ? PrismColors.statusWarning
                  : PrismColors.statusSuccess,
            ),
            PrismMetricTile(
              label: 'Gov Warnings',
              value: '${snapshot.governanceWarningCount}',
              icon: Icons.gavel_outlined,
              color: snapshot.governanceWarningCount > 0
                  ? PrismColors.statusError
                  : PrismColors.statusSuccess,
            ),
          ],
        );
      },
    );
  }
}
