import 'package:flutter/material.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';
import '../../data/fixtures/fixtures.dart';

/// CyberCore Governance route — diagnostics & compliance.
///
/// Displays governance diagnostics using PrismStoryPanel, PrismMetricTile,
/// and PrismDataTable from warp_prism_ui.
/// All data is loaded from fixtures.
class GovernancePage extends StatefulWidget {
  const GovernancePage({super.key});

  @override
  State<GovernancePage> createState() => _GovernancePageState();
}

class _GovernancePageState extends State<GovernancePage> {
  GovernanceDiagnostics? _diagnostics;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final diagnostics = await FixtureLoader.loadGovernanceDiagnostics();
      if (mounted) {
        setState(() {
          _diagnostics = diagnostics;
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
        title: 'Loading governance...',
        subtitle: 'Computing diagnostics from fixture data',
      );
    }

    if (_error != null) {
      return PrismStateSurface.error(
        title: 'Failed to load governance',
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

    final diag = _diagnostics!;
    final hasIssues = diag.totalIssues > 0;

    return PrismErrorBoundary(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(PrismSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Summary story panel
            PrismStoryPanel(
              title: 'Governance Overview',
              subtitle:
                  'Compliance diagnostics — ${diag.totalIssues} issue${diag.totalIssues == 1 ? '' : 's'} detected',
              icon: Icons.gavel_outlined,
              accentColor: hasIssues
                  ? PrismColors.statusWarning
                  : PrismColors.statusSuccess,
              insights: [
                PrismStoryInsight(
                  text:
                      '${diag.orphanWorkflows.length} orphan workflow${diag.orphanWorkflows.length == 1 ? '' : 's'}',
                  detail: diag.orphanWorkflows.isEmpty
                      ? 'All workflows have agent or skill references'
                      : 'Unreferenced: ${diag.orphanWorkflows.join(', ')}',
                  value: '${diag.orphanWorkflows.length}',
                  color: diag.orphanWorkflows.isNotEmpty
                      ? PrismColors.statusWarning
                      : PrismColors.statusSuccess,
                ),
                PrismStoryInsight(
                  text:
                      '${diag.noTriggerSkills.length} skill${diag.noTriggerSkills.length == 1 ? '' : 's'} without triggers',
                  detail: diag.noTriggerSkills.isEmpty
                      ? 'All skills have trigger definitions'
                      : 'Missing: ${diag.noTriggerSkills.join(', ')}',
                  value: '${diag.noTriggerSkills.length}',
                  color: diag.noTriggerSkills.isNotEmpty
                      ? PrismColors.statusWarning
                      : PrismColors.statusSuccess,
                ),
                PrismStoryInsight(
                  text:
                      '${diag.unverifiedTasks.length} unverified high-priority task${diag.unverifiedTasks.length == 1 ? '' : 's'}',
                  detail: diag.unverifiedTasks.isEmpty
                      ? 'All high-priority tasks have proof'
                      : diag.unverifiedTasks
                            .map((t) => '${t.taskId} (${t.priority})')
                            .join(', '),
                  value: '${diag.unverifiedTasks.length}',
                  color: diag.unverifiedTasks.isNotEmpty
                      ? PrismColors.statusError
                      : PrismColors.statusSuccess,
                ),
                PrismStoryInsight(
                  text:
                      '${diag.fanInHotspots.length} fan-in hotspot${diag.fanInHotspots.length == 1 ? '' : 's'}',
                  detail: diag.fanInHotspots.isEmpty
                      ? 'No skill has excessive incoming references'
                      : diag.fanInHotspots
                            .map(
                              (h) =>
                                  '${h.skillName} (${h.referenceCount} refs)',
                            )
                            .join(', '),
                  value: '${diag.fanInHotspots.length}',
                  color: diag.fanInHotspots.isNotEmpty
                      ? PrismColors.statusWarning
                      : PrismColors.statusSuccess,
                ),
              ],
            ),

            const SizedBox(height: PrismSpacing.lg),

            // Canonicality boundary metrics
            const PrismText.headingMedium(
              'Canonicality Boundary',
              color: PrismColors.textPrimary,
            ),
            const SizedBox(height: PrismSpacing.md),

            Wrap(
              spacing: PrismSpacing.md,
              runSpacing: PrismSpacing.md,
              children: diag.canonicalityBoundary.entries.map((entry) {
                return PrismMetricTile(
                  label: entry.key,
                  value: '${entry.value}',
                  icon: _canonicalityIcon(entry.key),
                  color: _canonicalityColor(entry.key),
                );
              }).toList(),
            ),

            const SizedBox(height: PrismSpacing.lg),

            // Fan-in hotspots
            if (diag.fanInHotspots.isNotEmpty) ...[
              const PrismText.headingMedium(
                'Fan-in Hotspots',
                color: PrismColors.textPrimary,
              ),
              const SizedBox(height: PrismSpacing.md),
              PrismDataTable(
                columns: const [
                  PrismDataColumn(id: 'skill', label: 'Skill', sortable: true),
                  PrismDataColumn(
                    id: 'refs',
                    label: 'References',
                    sortable: true,
                    width: 120,
                  ),
                  PrismDataColumn(id: 'risk', label: 'Risk', width: 100),
                ],
                rows: diag.fanInHotspots.map((hotspot) {
                  return PrismDataRow(
                    id: hotspot.skillName,
                    cells: {
                      'skill': hotspot.skillName,
                      'refs': hotspot.referenceCount,
                      'risk': hotspot.referenceCount >= 6 ? 'High' : 'Medium',
                    },
                  );
                }).toList(),
                showPagination: false,
              ),
              const SizedBox(height: PrismSpacing.lg),
            ],

            // Unverified high-priority tasks
            if (diag.unverifiedTasks.isNotEmpty) ...[
              const PrismText.headingMedium(
                'Unverified High-Priority Tasks',
                color: PrismColors.textPrimary,
              ),
              const SizedBox(height: PrismSpacing.md),
              PrismDataTable(
                columns: const [
                  PrismDataColumn(id: 'taskId', label: 'Task ID', width: 100),
                  PrismDataColumn(id: 'title', label: 'Title'),
                  PrismDataColumn(
                    id: 'priority',
                    label: 'Priority',
                    width: 100,
                  ),
                  PrismDataColumn(id: 'status', label: 'Status', width: 100),
                ],
                rows: diag.unverifiedTasks.map((task) {
                  return PrismDataRow(
                    id: task.taskId,
                    cells: {
                      'taskId': task.taskId,
                      'title': task.title,
                      'priority': task.priority,
                      'status': PrismOperationalState.unverified,
                    },
                  );
                }).toList(),
                showPagination: false,
              ),
            ],

            // All clear state
            if (!hasIssues) ...[
              const SizedBox(height: PrismSpacing.lg),
              const PrismStateSurface.empty(
                icon: Icons.verified_outlined,
                title: 'All systems compliant',
                subtitle: 'No governance issues detected in the workspace',
                accentColor: PrismColors.statusSuccess,
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _canonicalityIcon(String boundary) {
    switch (boundary) {
      case 'parentCanonical':
        return Icons.verified_outlined;
      case 'childLocal':
        return Icons.home_outlined;
      case 'mock':
        return Icons.science_outlined;
      default:
        return Icons.circle_outlined;
    }
  }

  Color _canonicalityColor(String boundary) {
    switch (boundary) {
      case 'parentCanonical':
        return PrismColors.statusSuccess;
      case 'childLocal':
        return PrismColors.accentCyan;
      case 'mock':
        return PrismColors.textTertiary;
      default:
        return PrismColors.textSecondary;
    }
  }
}
