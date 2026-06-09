import 'package:flutter/material.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';
import '../../data/fixtures/fixtures.dart';

/// CyberCore Dashboard route — system health overview.
///
/// Displays aggregated workspace metrics using PrismMetricTile,
/// PrismStatusGrid, and PrismStoryPanel components from warp_prism_ui.
/// All data is loaded from fixtures — no live API calls.
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  DashboardSummary? _summary;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final summary = await FixtureLoader.loadDashboardSummary();
      if (mounted) {
        setState(() {
          _summary = summary;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const PrismStateSurface.loading(
        title: 'Loading dashboard...',
        subtitle: 'Aggregating workspace metrics from fixtures',
      );
    }

    if (_error != null) {
      return PrismStateSurface.error(
        title: 'Failed to load dashboard',
        subtitle: _error,
        onAction: () {
          setState(() {
            _loading = true;
            _error = null;
          });
          _loadData();
        },
      );
    }

    final summary = _summary!;

    return PrismErrorBoundary(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(DSSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Health overview story panel
            PrismStoryPanel(
              title: 'System Health',
              subtitle: 'CyberCore workspace overview — fixture-backed read-only mirror',
              icon: Icons.health_and_safety_outlined,
              accentColor: DSColors.accentCyan,
              insights: [
                PrismStoryInsight(
                  text: '${summary.agentMetrics.total} agents registered',
                  detail: '${summary.agentMetrics.healthy} healthy, ${summary.agentMetrics.degraded} degraded',
                  value: '${summary.agentMetrics.total}',
                  color: DSColors.statusSuccess,
                ),
                PrismStoryInsight(
                  text: '${summary.skillMetrics.total} capabilities catalogued',
                  detail: '${summary.skillMetrics.withTriggers} with triggers, ${summary.skillMetrics.noTriggers} without',
                  value: '${summary.skillMetrics.total}',
                  color: DSColors.accentViolet,
                ),
                PrismStoryInsight(
                  text: '${summary.workflowMetrics.total} workflow definitions',
                  detail: '${summary.workflowMetrics.active} active, ${summary.workflowMetrics.orphaned} orphaned',
                  value: '${summary.workflowMetrics.total}',
                  color: DSColors.accentGold,
                ),
                PrismStoryInsight(
                  text: '${summary.executionMetrics.totalTasks} tasks across 5 lanes',
                  detail: '${summary.executionMetrics.completed} completed, ${summary.executionMetrics.doing} in progress',
                  value: '${summary.executionMetrics.totalTasks}',
                  color: DSColors.accentCyan,
                ),
                PrismStoryInsight(
                  text: '${summary.recentActivity.total} audit events recorded',
                  detail: '${summary.recentActivity.lastWeek} in the last week',
                  value: '${summary.recentActivity.lastWeek}',
                  color: DSColors.textSecondary,
                ),
              ],
            ),

            const SizedBox(height: DSSpacing.lg),

            // Metric tiles grid
            const PrismText.headingMedium(
              'Key Metrics',
              color: DSColors.textPrimary,
            ),
            const SizedBox(height: DSSpacing.md),

            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 900
                    ? 4
                    : (constraints.maxWidth > 600 ? 3 : 2);
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: DSSpacing.md,
                  crossAxisSpacing: DSSpacing.md,
                  childAspectRatio: 1.4,
                  children: [
                    PrismMetricTile(
                      label: 'Agents',
                      value: '${summary.agentMetrics.total}',
                      icon: Icons.smart_toy_outlined,
                      health: summary.agentMetrics.degraded > 0
                          ? PrismMetricTileHealth.degraded
                          : PrismMetricTileHealth.healthy,
                      subtitle: '${summary.agentMetrics.healthy} healthy',
                    ),
                    PrismMetricTile(
                      label: 'Skills',
                      value: '${summary.skillMetrics.total}',
                      icon: Icons.extension_outlined,
                      health: summary.skillMetrics.noTriggers > 0
                          ? PrismMetricTileHealth.degraded
                          : PrismMetricTileHealth.healthy,
                      subtitle: '${summary.skillMetrics.withTriggers} with triggers',
                    ),
                    PrismMetricTile(
                      label: 'Workflows',
                      value: '${summary.workflowMetrics.total}',
                      icon: Icons.account_tree_outlined,
                      health: summary.workflowMetrics.orphaned > 0
                          ? PrismMetricTileHealth.degraded
                          : PrismMetricTileHealth.healthy,
                      subtitle: '${summary.workflowMetrics.orphaned} orphaned',
                    ),
                    PrismMetricTile(
                      label: 'Tasks',
                      value: '${summary.executionMetrics.totalTasks}',
                      icon: Icons.task_outlined,
                      health: PrismMetricTileHealth.healthy,
                      subtitle: '${summary.executionMetrics.completed} completed',
                    ),
                    PrismMetricTile(
                      label: 'Audit Events',
                      value: '${summary.recentActivity.total}',
                      icon: Icons.shield_outlined,
                      subtitle: '${summary.recentActivity.lastWeek} this week',
                    ),
                    PrismMetricTile(
                      label: 'In Progress',
                      value: '${summary.executionMetrics.doing}',
                      icon: Icons.trending_up,
                      color: DSColors.accentGold,
                      subtitle: 'Active execution',
                    ),
                    PrismMetricTile(
                      label: 'In Review',
                      value: '${summary.executionMetrics.review}',
                      icon: Icons.rate_review_outlined,
                      color: DSColors.accentCyan,
                      subtitle: 'Awaiting approval',
                    ),
                    PrismMetricTile(
                      label: 'Planned',
                      value: '${summary.executionMetrics.planning + summary.executionMetrics.open}',
                      icon: Icons.schedule_outlined,
                      color: DSColors.textTertiary,
                      subtitle: 'Planning + open',
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: DSSpacing.lg),

            // Activity type breakdown
            const PrismText.headingMedium(
              'Activity Breakdown',
              color: DSColors.textPrimary,
            ),
            const SizedBox(height: DSSpacing.md),

            Wrap(
              spacing: DSSpacing.sm,
              runSpacing: DSSpacing.sm,
              children: summary.recentActivity.types.entries.map((entry) {
                final color = _typeColor(entry.key);
                return PrismMetricTileCompact(
                  label: entry.key,
                  value: '${entry.value}',
                  color: color,
                );
              }).toList(),
            ),

            const SizedBox(height: DSSpacing.lg),

            // Status grid for entity health
            const PrismText.headingMedium(
              'Entity Health Grid',
              color: DSColors.textPrimary,
            ),
            const SizedBox(height: DSSpacing.md),

            PrismStatusGrid(
              items: [
                PrismHealthCardData(
                  serviceName: 'Agent Registry',
                  operationalState: summary.agentMetrics.degraded > 0
                      ? PrismOperationalState.degraded
                      : PrismOperationalState.healthy,
                  uptimePercent: summary.agentMetrics.healthy / summary.agentMetrics.total,
                  trendData: [0.8, 0.85, 0.9, 0.88, 0.92],
                ),
                PrismHealthCardData(
                  serviceName: 'Skill Catalog',
                  operationalState: summary.skillMetrics.noTriggers > 0
                      ? PrismOperationalState.degraded
                      : PrismOperationalState.healthy,
                  uptimePercent: summary.skillMetrics.withTriggers / summary.skillMetrics.total,
                  trendData: [0.7, 0.75, 0.8, 0.82, 0.85],
                ),
                PrismHealthCardData(
                  serviceName: 'Workflow Engine',
                  operationalState: summary.workflowMetrics.orphaned > 0
                      ? PrismOperationalState.stale
                      : PrismOperationalState.healthy,
                  uptimePercent: summary.workflowMetrics.active / summary.workflowMetrics.total,
                  trendData: [0.6, 0.65, 0.7, 0.72, 0.75],
                ),
                PrismHealthCardData(
                  serviceName: 'Task Execution',
                  operationalState: PrismOperationalState.running,
                  uptimePercent: summary.executionMetrics.completed / summary.executionMetrics.totalTasks,
                  trendData: [0.5, 0.55, 0.6, 0.65, 0.7],
                ),
                const PrismHealthCardData(
                  serviceName: 'Audit Trail',
                  operationalState: PrismOperationalState.healthy,
                  uptimePercent: 1.0,
                  trendData: [0.95, 0.96, 0.97, 0.98, 0.99],
                ),
              ],
              maxCrossAxisExtent: 280,
            ),
          ],
        ),
      ),
    );
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'feature':
        return DSColors.accentCyan;
      case 'fix':
        return DSColors.statusWarning;
      case 'refactor':
        return DSColors.accentViolet;
      case 'docs':
        return DSColors.textSecondary;
      case 'chore':
        return DSColors.textTertiary;
      default:
        return DSColors.textSecondary;
    }
  }
}
