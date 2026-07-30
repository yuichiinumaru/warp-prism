/// Workspace filter chips.
///
/// Renders filter chip rows for asset kind, task lane, and provenance
/// classification. Uses [PrismFilterChipGroup] primitives.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warp_prism_observatory/data/models/workspace_graph.dart';
import 'package:warp_prism_observatory/data/models/task_contracts.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';
import '../workspace_snapshot_provider.dart';

/// Row of filter chips for the workspace snapshot page.
///
/// Three chip groups: asset kind, task lane, and provenance.
class WorkspaceFilterChips extends ConsumerWidget {
  const WorkspaceFilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshotAsync = ref.watch(workspaceSnapshotProvider);

    return snapshotAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (snapshot) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Asset kind filters
            _KindFilterChips(
              snapshot: snapshot,
              selected: ref.watch(kindFilterProvider),
              onToggle: (kind) {
                final current = ref.read(kindFilterProvider);
                final updated = Set<AssetKind>.from(current);
                if (updated.contains(kind)) {
                  updated.remove(kind);
                } else {
                  updated.add(kind);
                }
                ref.read(kindFilterProvider.notifier).state = updated;
              },
            ),
            const SizedBox(height: PrismSpacing.sm),
            // Task lane filters
            _LaneFilterChips(
              snapshot: snapshot,
              selected: ref.watch(laneFilterProvider),
              onToggle: (lane) {
                final current = ref.read(laneFilterProvider);
                final updated = Set<TaskLane>.from(current);
                if (updated.contains(lane)) {
                  updated.remove(lane);
                } else {
                  updated.add(lane);
                }
                ref.read(laneFilterProvider.notifier).state = updated;
              },
            ),
            const SizedBox(height: PrismSpacing.sm),
            // Provenance filters
            _ProvenanceFilterChips(
              snapshot: snapshot,
              selected: ref.watch(canonicalityFilterProvider),
              onToggle: (canon) {
                final current = ref.read(canonicalityFilterProvider);
                final updated = Set<Canonicality>.from(current);
                if (updated.contains(canon)) {
                  updated.remove(canon);
                } else {
                  updated.add(canon);
                }
                ref.read(canonicalityFilterProvider.notifier).state = updated;
              },
            ),
          ],
        );
      },
    );
  }
}

class _KindFilterChips extends StatelessWidget {
  final dynamic snapshot;
  final Set<AssetKind> selected;
  final void Function(AssetKind) onToggle;

  const _KindFilterChips({
    required this.snapshot,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final options = <PrismFilterOption>[
      PrismFilterOption(
        value: 'agent',
        label: 'Agents',
        icon: PrismIcons.agent,
        color: PrismColors.assetAgent,
        count: snapshot.agents.length,
      ),
      PrismFilterOption(
        value: 'skill',
        label: 'Skills',
        icon: PrismIcons.skill,
        color: PrismColors.assetSkill,
        count: snapshot.skills.length,
      ),
      PrismFilterOption(
        value: 'workflow',
        label: 'Workflows',
        icon: PrismIcons.workflow,
        color: PrismColors.assetWorkflow,
        count: snapshot.workflows.length,
      ),
      PrismFilterOption(
        value: 'task',
        label: 'Tasks',
        icon: PrismIcons.task,
        color: PrismColors.assetTask,
        count: snapshot.tasks.length,
      ),
      PrismFilterOption(
        value: 'changelog',
        label: 'Changelog',
        icon: PrismIcons.changelog,
        color: PrismColors.assetChangelog,
        count: snapshot.changelogEntries.length,
      ),
    ];

    return PrismFilterChipGroup(
      options: options,
      selected: selected.map((k) => k.name).toSet(),
      onToggle: (value) {
        final kind = AssetKind.values.firstWhere(
          (k) => k.name == value,
          orElse: () => AssetKind.agent,
        );
        onToggle(kind);
      },
    );
  }
}

class _LaneFilterChips extends StatelessWidget {
  final dynamic snapshot;
  final Set<TaskLane> selected;
  final void Function(TaskLane) onToggle;

  const _LaneFilterChips({
    required this.snapshot,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final tasksByLane = snapshot.tasksByLane as Map<TaskLane, int>;
    final options = TaskLane.values
        .map(
          (lane) => PrismFilterOption(
            value: lane.directoryPrefix,
            label: lane.directoryPrefix,
            color: PrismColors.forLane(lane.directoryPrefix),
            count: tasksByLane[lane] ?? 0,
          ),
        )
        .toList();

    return PrismFilterChipGroup(
      options: options,
      selected: selected.map((l) => l.directoryPrefix).toSet(),
      onToggle: (value) {
        final lane = TaskLaneParsing.fromDirectoryPrefix(value);
        onToggle(lane);
      },
    );
  }
}

class _ProvenanceFilterChips extends StatelessWidget {
  final dynamic snapshot;
  final Set<Canonicality> selected;
  final void Function(Canonicality) onToggle;

  const _ProvenanceFilterChips({
    required this.snapshot,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    // Count assets by canonicality
    final counts = <Canonicality, int>{};
    for (final canon in Canonicality.values) {
      counts[canon] = 0;
    }
    for (final asset in snapshot.allAssets) {
      counts[asset.canonicality] = (counts[asset.canonicality] ?? 0) + 1;
    }

    final options = Canonicality.values
        .where((c) => (counts[c] ?? 0) > 0)
        .map(
          (canon) => PrismFilterOption(
            value: canon.name,
            label: canon.name,
            color: PrismColors.forCanonicity(canon.name),
            count: counts[canon],
          ),
        )
        .toList();

    return PrismFilterChipGroup(
      options: options,
      selected: selected.map((c) => c.name).toSet(),
      onToggle: (value) {
        final canon = Canonicality.values.firstWhere(
          (c) => c.name == value,
          orElse: () => Canonicality.parentCanonical,
        );
        onToggle(canon);
      },
    );
  }
}
