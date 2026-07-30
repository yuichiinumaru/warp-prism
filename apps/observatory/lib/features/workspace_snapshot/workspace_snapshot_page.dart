/// Workspace Snapshot page — the main surface for Task 0019 + Task 0020.
///
/// Loads the workspace snapshot from the configured root path and renders
/// all discovered assets using Prism primitives with enhanced features:
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
import 'package:warp_prism_observatory/data/models/task_contracts.dart';
import 'package:warp_prism_observatory/data/models/workspace_graph.dart';
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
///
/// Deep-link [assetId] selection is applied once (init / assetId change), never
/// re-scheduled on every rebuild, so closing the inspector stays closed.
class WorkspaceSnapshotPage extends ConsumerStatefulWidget {
  final String? assetId;

  const WorkspaceSnapshotPage({super.key, this.assetId});

  @override
  ConsumerState<WorkspaceSnapshotPage> createState() =>
      _WorkspaceSnapshotPageState();
}

class _WorkspaceSnapshotPageState extends ConsumerState<WorkspaceSnapshotPage> {
  /// Last deep-link id for which selection was applied (one-shot per id).
  String? _appliedDeepLinkId;

  @override
  void initState() {
    super.initState();
    _scheduleDeepLinkSelection(widget.assetId);
  }

  @override
  void didUpdateWidget(covariant WorkspaceSnapshotPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.assetId != oldWidget.assetId) {
      // New route target: allow one application for the new id.
      if (widget.assetId != _appliedDeepLinkId) {
        _scheduleDeepLinkSelection(widget.assetId);
      }
    }
  }

  void _scheduleDeepLinkSelection(String? assetId) {
    if (assetId == null || assetId.isEmpty) return;
    if (_appliedDeepLinkId == assetId) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_appliedDeepLinkId == assetId) return;
      _appliedDeepLinkId = assetId;
      selectAsset(ref, assetId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final snapshotAsync = ref.watch(workspaceSnapshotProvider);
    final rootPath = ref.watch(workspaceRootProvider);
    final selectedAsset = ref.watch(selectedAssetIdProvider);

    return Scaffold(
      backgroundColor: PrismColors.obsidianDeep,
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
              loading: () => const PrismStateSurface.loading(
                title: 'Scanning workspace...',
                subtitle: 'Reading .agents/ and docs/ directories',
              ),
              error: (error, stack) => PrismStateSurface.error(
                title: 'Failed to scan workspace',
                subtitle: error.toString(),
                onAction: () =>
                    ref.read(workspaceSnapshotProvider.notifier).reload(),
              ),
              data: (snapshot) {
                if (snapshot.totalAssets == 0) {
                  return PrismStateSurface.empty(
                    icon: Icons.folder_open_outlined,
                    title: 'Empty workspace',
                    subtitle: 'No assets found in $rootPath',
                    actionLabel: 'Rescan',
                    onAction: () =>
                        ref.read(workspaceSnapshotProvider.notifier).reload(),
                  );
                }

                return Row(
                  children: [
                    // Main content area
                    Expanded(child: _SnapshotBody(snapshot: snapshot)),

                    // Detail inspector (if asset selected)
                    if (selectedAsset != null)
                      SizedBox(
                        width: 400,
                        child: Container(
                          decoration: const BoxDecoration(
                            border: Border(
                              left: BorderSide(
                                color: PrismColors.borderSubtle,
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
    return PrismTopbar(
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
          const PrismStatusDot.error(tooltip: 'Scan failed')
        else
          const PrismStatusDot.success(tooltip: 'Scan complete'),
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
            PrismSpacing.lg,
            PrismSpacing.md,
            PrismSpacing.lg,
            0,
          ),
          child: Row(
            children: [
              const Expanded(child: WorkspaceSearchBar()),
              const SizedBox(width: PrismSpacing.md),
              // Rescan button
              IconButton(
                icon: const PrismIcon.small(
                  Icons.refresh,
                  color: PrismColors.textTertiary,
                ),
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
            PrismSpacing.lg,
            PrismSpacing.sm,
            PrismSpacing.lg,
            0,
          ),
          child: WorkspaceFilterChips(),
        ),

        const SizedBox(height: PrismSpacing.md),

        // Tab bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: PrismSpacing.lg),
          child: Row(
            children: [
              _TabButton(
                label: 'Content',
                icon: Icons.list_outlined,
                isActive: _tabController.index == 0,
                onTap: () => _tabController.animateTo(0),
              ),
              const SizedBox(width: PrismSpacing.xs),
              _TabButton(
                label: 'Graph',
                icon: Icons.account_tree_outlined,
                isActive: _tabController.index == 1,
                onTap: () => _tabController.animateTo(1),
              ),
            ],
          ),
        ),

        const SizedBox(height: PrismSpacing.sm),

        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Content tab
              _ContentTab(snapshot: widget.snapshot),
              // Graph tab
              const Padding(
                padding: EdgeInsets.all(PrismSpacing.lg),
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
    final color = isActive ? PrismColors.accentCyan : PrismColors.textTertiary;
    final bgColor = isActive
        ? PrismColors.accentCyan.withValues(alpha: 0.15)
        : PrismColors.transparent;

    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: PrismSpacing.md,
            vertical: PrismSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(PrismRadii.chip),
            border: Border.all(
              color: isActive
                  ? PrismColors.accentCyan.withValues(alpha: 0.3)
                  : PrismColors.borderSubtle,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PrismIcon.small(icon, color: color),
              const SizedBox(width: 6),
              PrismText.labelMedium(label, color: color),
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
      padding: const EdgeInsets.all(PrismSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Metric tiles row
          _MetricTilesRow(snapshot: snapshot),

          const SizedBox(height: PrismSpacing.lg),

          // Derived metrics
          const PrismText.labelMedium(
            'DERIVED METRICS',
            color: PrismColors.textSecondary,
          ),
          const SizedBox(height: PrismSpacing.sm),
          const WorkspaceDerivedMetrics(),

          const SizedBox(height: PrismSpacing.lg),

          // Lane summary
          _LaneSummary(snapshot: snapshot),

          const SizedBox(height: PrismSpacing.xl),

          // Filtered content
          if (query.isNotEmpty ||
              kindFilters.isNotEmpty ||
              laneFilters.isNotEmpty) ...[
            _FilteredResults(assets: filteredAssets),
          ] else ...[
            // Full content sections
            _FullContentSections(snapshot: snapshot),
          ],

          // Scan metadata footer
          const SizedBox(height: PrismSpacing.xl),
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
      return const PrismStateSurface.empty(
        icon: Icons.search_off_outlined,
        title: 'No matching assets',
        subtitle: 'Try adjusting your search or filters',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PrismText.labelMedium(
          '${assets.length} RESULTS',
          color: PrismColors.textSecondary,
        ),
        const SizedBox(height: PrismSpacing.sm),
        ...assets.map(
          (asset) => Padding(
            padding: const EdgeInsets.only(bottom: PrismSpacing.sm),
            child: PrismAssetCard(
              name: asset.name,
              kind: asset.kind.name,
              description: asset.description.isNotEmpty
                  ? asset.description
                  : null,
              canonicality: asset.canonicality.name,
              tags: asset.tags.isNotEmpty ? asset.tags : null,
              edgeCount: asset.edges.length,
              onTap: () {
                final container = ProviderScope.containerOf(context);
                container.read(selectedAssetIdProvider.notifier).state =
                    asset.id;
              },
            ),
          ),
        ),
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
            icon: PrismIcons.agent,
            title: 'Agents',
            count: snapshot.agents.length,
          ),
          const SizedBox(height: PrismSpacing.sm),
          AgentListPanel(agents: snapshot.agents),
          const SizedBox(height: PrismSpacing.xl),
        ],

        // Skills section
        if (snapshot.skills.isNotEmpty) ...[
          _SectionHeader(
            icon: PrismIcons.skill,
            title: 'Skills',
            count: snapshot.skills.length,
          ),
          const SizedBox(height: PrismSpacing.sm),
          SkillListPanel(skills: snapshot.skills),
          const SizedBox(height: PrismSpacing.xl),
        ],

        // Workflows section
        if (snapshot.workflows.isNotEmpty) ...[
          _SectionHeader(
            icon: PrismIcons.workflow,
            title: 'Workflows',
            count: snapshot.workflows.length,
          ),
          const SizedBox(height: PrismSpacing.sm),
          WorkflowListPanel(workflows: snapshot.workflows),
          const SizedBox(height: PrismSpacing.xl),
        ],

        // Tasks section
        if (snapshot.tasks.isNotEmpty) ...[
          _SectionHeader(
            icon: PrismIcons.task,
            title: 'Tasks',
            count: snapshot.tasks.length,
          ),
          const SizedBox(height: PrismSpacing.sm),
          TaskLanePanel(tasks: snapshot.tasks),
          const SizedBox(height: PrismSpacing.xl),
        ],

        // Changelog section
        if (snapshot.changelogEntries.isNotEmpty) ...[
          _SectionHeader(
            icon: PrismIcons.changelog,
            title: 'Changelog',
            count: snapshot.changelogEntries.length,
          ),
          const SizedBox(height: PrismSpacing.sm),
          ChangelogListPanel(changelogEntries: snapshot.changelogEntries),
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
      spacing: PrismSpacing.md,
      runSpacing: PrismSpacing.md,
      children: [
        PrismMetricTile(
          label: 'Agents',
          value: '${snapshot.agents.length}',
          icon: Icons.smart_toy_outlined,
          color: PrismColors.accentCyan,
        ),
        PrismMetricTile(
          label: 'Skills',
          value: '${snapshot.skills.length}',
          icon: Icons.build_outlined,
          color: PrismColors.accentViolet,
        ),
        PrismMetricTile(
          label: 'Workflows',
          value: '${snapshot.workflows.length}',
          icon: Icons.account_tree_outlined,
          color: PrismColors.statusSuccess,
        ),
        PrismMetricTile(
          label: 'Tasks',
          value: '${snapshot.tasks.length}',
          icon: Icons.task_outlined,
          color: PrismColors.statusWarning,
        ),
        PrismMetricTile(
          label: 'Changelog',
          value: '${snapshot.changelogEntries.length}',
          icon: Icons.history_outlined,
          color: PrismColors.statusInfo,
        ),
        PrismMetricTile(
          label: 'Total',
          value: '${snapshot.totalAssets}',
          icon: Icons.dashboard_outlined,
          color: PrismColors.textPrimary,
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
    final nonEmptyLanes = tasksByLane.entries
        .where((e) => e.value > 0)
        .toList();

    if (nonEmptyLanes.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PrismText.labelMedium('TASK LANES', color: PrismColors.textSecondary),
        const SizedBox(height: PrismSpacing.sm),
        Wrap(
          spacing: PrismSpacing.sm,
          runSpacing: PrismSpacing.sm,
          children: nonEmptyLanes.map((entry) {
            return PrismMetricTileCompact(
              label: entry.key.directoryPrefix,
              value: '${entry.value}',
              color: PrismColors.forLane(entry.key.directoryPrefix),
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
        PrismIcon(icon, color: PrismColors.accentCyan, size: 24),
        const SizedBox(width: PrismSpacing.sm),
        PrismText.headingSmall(title, color: PrismColors.textPrimary),
        const SizedBox(width: PrismSpacing.sm),
        PrismChip(label: '$count', size: PrismChipSize.small),
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
    return PrismGlassPanelSimple(
      padding: const EdgeInsets.all(PrismSpacing.md),
      child: Row(
        children: [
          const PrismIcon.small(Icons.info_outline, color: PrismColors.textTertiary),
          const SizedBox(width: PrismSpacing.sm),
          Expanded(
            child: PrismText.bodySmall(
              'Scanned ${meta.filesScanned} files from ${meta.rootPath}'
              '${meta.parseErrors > 0 ? ' (${meta.parseErrors} parse errors)' : ''}',
              color: PrismColors.textTertiary,
            ),
          ),
          PrismText.labelSmall(
            _formatTime(meta.scannedAt),
            color: PrismColors.textTertiary,
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
