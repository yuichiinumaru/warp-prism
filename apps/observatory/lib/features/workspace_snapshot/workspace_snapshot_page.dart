/// Workspace Snapshot page — the main surface for Task 0019 + Task 0020.
///
/// Loads the workspace snapshot from the configured root path and renders
/// all discovered assets using DS primitives with enhanced features:
/// - Global search bar with debounced filtering
/// - Filter chips for asset kind, task lane, and provenance
/// - Content tab with metric tiles, derived metrics, and asset lists
/// - Graph tab with containment and operational projections
/// - Asset detail inspector on card click or graph node click
/// - Deep-link support for individual assets
///
/// All features are read-only. No mutation hooks or script invocation.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';
import '../../../data/models/task_contracts.dart';
import '../../../data/models/workspace_graph.dart';
import 'workspace_snapshot_provider.dart';
import 'widgets/agent_list_panel.dart';
import 'widgets/skill_list_panel.dart';
import 'widgets/workflow_list_panel.dart';
import 'widgets/task_lane_panel.dart';
import 'widgets/changelog_list_panel.dart';
import 'widgets/workspace_search_bar.dart';
import 'widgets/workspace_filter_chips.dart';
import 'widgets/workspace_graph_panel.dart';
import 'widgets/workspace_detail_inspector.dart';
import 'widgets/workspace_derived_metrics.dart';

/// The workspace snapshot page.
///
/// Shows:
/// - Workspace root path and scan status in the topbar
/// - Search bar and filter chips
/// - Metric tiles for agents, skills, workflows, tasks, changelog
/// - Derived metrics (blocked tasks, review queue, governance warnings, etc.)
/// - Tab switcher: Content view / Graph view
/// - Detail inspector panel (opens on card click, graph node click, or deep-link)
/// - Loading/error/empty states
class WorkspaceSnapshotPage extends ConsumerWidget {
  final String? assetId;

  const WorkspaceSnapshotPage({super.key, this.assetId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshotAsync = ref.watch(workspaceSnapshotProvider);
    final rootPath = ref.watch(workspaceRootProvider);

    // Handle deep-link: pre-select asset if id is provided
    if (assetId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        selectAsset(ref, assetId!);
      });
    }

    final selectedAsset = ref.watch(selectedAssetIdProvider);

    return Scaffold(
      backgroundColor: DSColors.obsidianDeep,
      body: Column(
        children: [
          // Topbar with workspace root and scan status
          _WorkspaceTopbar(
            rootPath: rootPath,
            isLoading: snapshotAsync.isLoading,
            hasError: snapshotAsync.hasError,
          ),

          // Main content
          Expanded(
            child: snapshotAsync.when(
              loading: () => const DSStateSurface.loading(
                title: 'Scanning workspace...',
                subtitle: 'Reading .agents/ and docs/ directories',
              ),
              error: (error, stack) => DSStateSurface.error(
                title: 'Failed to scan workspace',
                subtitle: error.toString(),
                onAction: () =>
                    ref.read(workspaceSnapshotProvider.notifier).reload(),
              ),
              data: (snapshot) {
                if (snapshot.totalAssets == 0) {
                  return DSStateSurface.empty(
                    icon: Icons.folder_open_outlined,
                    title: 'Empty workspace',
                    subtitle: 'No assets found in $rootPath',
                    actionLabel: 'Rescan',
                    onAction: () => ref
                        .read(workspaceSnapshotProvider.notifier)
                        .reload(),
                  );
                }

                return Row(
                  children: [
                    // Main content area
                    Expanded(
                      child: _SnapshotBody(snapshot: snapshot),
                    ),

                    // Detail inspector (if asset selected)
                    if (selectedAsset != null)
                      SizedBox(
                        width: 400,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(
                                color: DSColors.borderSubtle,
                                width: 1,
                              ),
                            ),
                          ),
                          child: const WorkspaceDetailInspector(),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Topbar showing workspace root path and scan status.
class _WorkspaceTopbar extends StatelessWidget {
  final String rootPath;
  final bool isLoading;
  final bool hasError;

  const _WorkspaceTopbar({
    required this.rootPath,
    required this.isLoading,
    required this.hasError,
  });

  @override
  Widget build(BuildContext context) {
    return DSTopbar(
      title: 'Workspace Snapshot',
      breadcrumbs: [rootPath],
      actions: [
        if (isLoading)
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else if (hasError)
          const DSStatusDot.error(tooltip: 'Scan failed')
        else
          const DSStatusDot.success(tooltip: 'Scan complete'),
      ],
    );
  }
}

/// Body with search, filters, tabs, and content.
class _SnapshotBody extends ConsumerStatefulWidget {
  final dynamic snapshot;

  const _SnapshotBody({required this.snapshot});

  @override
  ConsumerState<_SnapshotBody> createState() => _SnapshotBodyState();
}

class _SnapshotBodyState extends ConsumerState<_SnapshotBody>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(
            DSSpacing.lg, DSSpacing.md, DSSpacing.lg, 0,
          ),
          child: Row(
            children: [
              Expanded(child: const WorkspaceSearchBar()),
              const SizedBox(width: DSSpacing.md),
              // Rescan button
              IconButton(
                icon: DSIcon.small(Icons.refresh, color: DSColors.textTertiary),
                onPressed: () =>
                    ref.read(workspaceSnapshotProvider.notifier).reload(),
                tooltip: 'Rescan workspace',
              ),
            ],
          ),
        ),

        // Filter chips
        const Padding(
          padding: EdgeInsets.fromLTRB(
            DSSpacing.lg, DSSpacing.sm, DSSpacing.lg, 0,
          ),
          child: WorkspaceFilterChips(),
        ),

        const SizedBox(height: DSSpacing.md),

        // Tab bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: DSSpacing.lg),
          child: Row(
            children: [
              _TabButton(
                label: 'Content',
                icon: Icons.list_outlined,
                isActive: _tabController.index == 0,
                onTap: () => _tabController.animateTo(0),
              ),
              const SizedBox(width: DSSpacing.xs),
              _TabButton(
                label: 'Graph',
                icon: Icons.account_tree_outlined,
                isActive: _tabController.index == 1,
                onTap: () => _tabController.animateTo(1),
              ),
            ],
          ),
        ),

        const SizedBox(height: DSSpacing.sm),

        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Content tab
              _ContentTab(snapshot: widget.snapshot),
              // Graph tab
              const Padding(
                padding: EdgeInsets.all(DSSpacing.lg),
                child: WorkspaceGraphPanel(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Tab button for switching between content and graph views.
class _TabButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? DSColors.accentCyan : DSColors.textTertiary;
    final bgColor = isActive
        ? DSColors.accentCyan.withOpacity(0.15)
        : DSColors.transparent;

    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DSSpacing.md,
            vertical: DSSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(DSRadii.chip),
            border: Border.all(
              color: isActive
                  ? DSColors.accentCyan.withOpacity(0.3)
                  : DSColors.borderSubtle,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              DSIcon.small(icon, color: color),
              const SizedBox(width: 6),
              DSText.labelMedium(label, color: color),
            ],
          ),
        ),
      ),
    );
  }
}

/// Content tab: metric tiles + derived metrics + asset lists.
class _ContentTab extends ConsumerWidget {
  final dynamic snapshot;

  const _ContentTab({required this.snapshot});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredAssets = ref.watch(filteredAssetsProvider);
    final query = ref.watch(debouncedSearchQueryProvider);
    final kindFilters = ref.watch(kindFilterProvider);
    final laneFilters = ref.watch(laneFilterProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(DSSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Metric tiles row
          _MetricTilesRow(snapshot: snapshot),

          const SizedBox(height: DSSpacing.lg),

          // Derived metrics
          DSText.labelMedium(
            'DERIVED METRICS',
            color: DSColors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.sm),
          const WorkspaceDerivedMetrics(),

          const SizedBox(height: DSSpacing.lg),

          // Lane summary
          _LaneSummary(snapshot: snapshot),

          const SizedBox(height: DSSpacing.xl),

          // Filtered content
          if (query.isNotEmpty || kindFilters.isNotEmpty || laneFilters.isNotEmpty) ...[
            _FilteredResults(assets: filteredAssets),
          ] else ...[
            // Full content sections
            _FullContentSections(snapshot: snapshot),
          ],

          // Scan metadata footer
          const SizedBox(height: DSSpacing.xl),
          _ScanMetadataFooter(snapshot: snapshot),
        ],
      ),
    );
  }
}

/// Filtered results when search or filters are active.
class _FilteredResults extends StatelessWidget {
  final List<WorkspaceAsset> assets;

  const _FilteredResults({required this.assets});

  @override
  Widget build(BuildContext context) {
    if (assets.isEmpty) {
      return const DSStateSurface.empty(
        icon: Icons.search_off_outlined,
        title: 'No matching assets',
        subtitle: 'Try adjusting your search or filters',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DSText.labelMedium(
          '${assets.length} RESULTS',
          color: DSColors.textSecondary,
        ),
        const SizedBox(height: DSSpacing.sm),
        ...assets.map((asset) => Padding(
              padding: const EdgeInsets.only(bottom: DSSpacing.sm),
              child: DSAssetCard(
                name: asset.name,
                kind: asset.kind.name,
                description:
                    asset.description.isNotEmpty ? asset.description : null,
                canonicality: asset.canonicality.name,
                tags: asset.tags.isNotEmpty ? asset.tags : null,
                edgeCount: asset.edges.length,
                onTap: () {
                  final container = ProviderScope.containerOf(context);
                  container.read(selectedAssetIdProvider.notifier).state =
                      asset.id;
                },
              ),
            )),
      ],
    );
  }
}

/// Full content sections when no search/filter is active.
class _FullContentSections extends StatelessWidget {
  final dynamic snapshot;

  const _FullContentSections({required this.snapshot});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Agents section
        if (snapshot.agents.isNotEmpty) ...[
          _SectionHeader(
            icon: DSIcons.agent,
            title: 'Agents',
            count: snapshot.agents.length,
          ),
          const SizedBox(height: DSSpacing.sm),
          AgentListPanel(agents: snapshot.agents),
          const SizedBox(height: DSSpacing.xl),
        ],

        // Skills section
        if (snapshot.skills.isNotEmpty) ...[
          _SectionHeader(
            icon: DSIcons.skill,
            title: 'Skills',
            count: snapshot.skills.length,
          ),
          const SizedBox(height: DSSpacing.sm),
          SkillListPanel(skills: snapshot.skills),
          const SizedBox(height: DSSpacing.xl),
        ],

        // Workflows section
        if (snapshot.workflows.isNotEmpty) ...[
          _SectionHeader(
            icon: DSIcons.workflow,
            title: 'Workflows',
            count: snapshot.workflows.length,
          ),
          const SizedBox(height: DSSpacing.sm),
          WorkflowListPanel(workflows: snapshot.workflows),
          const SizedBox(height: DSSpacing.xl),
        ],

        // Tasks section
        if (snapshot.tasks.isNotEmpty) ...[
          _SectionHeader(
            icon: DSIcons.task,
            title: 'Tasks',
            count: snapshot.tasks.length,
          ),
          const SizedBox(height: DSSpacing.sm),
          TaskLanePanel(tasks: snapshot.tasks),
          const SizedBox(height: DSSpacing.xl),
        ],

        // Changelog section
        if (snapshot.changelogEntries.isNotEmpty) ...[
          _SectionHeader(
            icon: DSIcons.changelog,
            title: 'Changelog',
            count: snapshot.changelogEntries.length,
          ),
          const SizedBox(height: DSSpacing.sm),
          ChangelogListPanel(
            changelogEntries: snapshot.changelogEntries,
          ),
        ],
      ],
    );
  }
}

/// Row of metric tiles showing asset counts.
class _MetricTilesRow extends StatelessWidget {
  final dynamic snapshot;

  const _MetricTilesRow({required this.snapshot});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: DSSpacing.md,
      runSpacing: DSSpacing.md,
      children: [
        DSMetricTile(
          label: 'Agents',
          value: '${snapshot.agents.length}',
          icon: Icons.smart_toy_outlined,
          color: DSColors.accentCyan,
        ),
        DSMetricTile(
          label: 'Skills',
          value: '${snapshot.skills.length}',
          icon: Icons.build_outlined,
          color: DSColors.accentViolet,
        ),
        DSMetricTile(
          label: 'Workflows',
          value: '${snapshot.workflows.length}',
          icon: Icons.account_tree_outlined,
          color: DSColors.statusSuccess,
        ),
        DSMetricTile(
          label: 'Tasks',
          value: '${snapshot.tasks.length}',
          icon: Icons.task_outlined,
          color: DSColors.statusWarning,
        ),
        DSMetricTile(
          label: 'Changelog',
          value: '${snapshot.changelogEntries.length}',
          icon: Icons.history_outlined,
          color: DSColors.statusInfo,
        ),
        DSMetricTile(
          label: 'Total',
          value: '${snapshot.totalAssets}',
          icon: Icons.dashboard_outlined,
          color: DSColors.textPrimary,
        ),
      ],
    );
  }
}

/// Lane summary showing task counts per lane.
class _LaneSummary extends StatelessWidget {
  final dynamic snapshot;

  const _LaneSummary({required this.snapshot});

  @override
  Widget build(BuildContext context) {
    final tasksByLane = snapshot.tasksByLane as Map<TaskLane, int>;
    final nonEmptyLanes =
        tasksByLane.entries.where((e) => e.value > 0).toList();

    if (nonEmptyLanes.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DSText.labelMedium('TASK LANES', color: DSColors.textSecondary),
        const SizedBox(height: DSSpacing.sm),
        Wrap(
          spacing: DSSpacing.sm,
          runSpacing: DSSpacing.sm,
          children: nonEmptyLanes.map((entry) {
            return DSMetricTileCompact(
              label: entry.key.directoryPrefix,
              value: '${entry.value}',
              color: DSColors.forLane(entry.key.directoryPrefix),
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Section header with icon, title, and count.
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final int count;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DSIcon(icon, color: DSColors.accentCyan, size: 24),
        const SizedBox(width: DSSpacing.sm),
        DSText.headingSmall(title, color: DSColors.textPrimary),
        const SizedBox(width: DSSpacing.sm),
        DSChip(label: '$count', size: DSChipSize.small),
      ],
    );
  }
}

/// Footer showing scan metadata.
class _ScanMetadataFooter extends StatelessWidget {
  final dynamic snapshot;

  const _ScanMetadataFooter({required this.snapshot});

  @override
  Widget build(BuildContext context) {
    final meta = snapshot.metadata;
    return DSGlassPanelSimple(
      padding: const EdgeInsets.all(DSSpacing.md),
      child: Row(
        children: [
          DSIcon.small(Icons.info_outline, color: DSColors.textTertiary),
          const SizedBox(width: DSSpacing.sm),
          Expanded(
            child: DSText.bodySmall(
              'Scanned ${meta.filesScanned} files from ${meta.rootPath}'
              '${meta.parseErrors > 0 ? ' (${meta.parseErrors} parse errors)' : ''}',
              color: DSColors.textTertiary,
            ),
          ),
          DSText.labelSmall(
            _formatTime(meta.scannedAt),
            color: DSColors.textTertiary,
          ),
        ],
      ),
    );
  }

  static String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}:'
        '${dt.second.toString().padLeft(2, '0')}';
  }
}
