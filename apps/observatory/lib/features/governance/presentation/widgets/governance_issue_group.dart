/// Governance issue group widget.
///
/// Renders grouped governance findings (orphans, stale references,
/// proof gaps, changelog-without-task) with human-readable explanations.
/// Each issue shows asset title, category, severity, and explanation.
library;

import 'package:flutter/material.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';
import 'package:warp_prism_observatory/data/models/governance_diagnostics.dart';
import 'governance_drilldown_controller.dart';

/// A group of governance issues sharing the same category.
@immutable
class GovernanceIssueGroupData {
  final DiagnosticCategory category;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<GovernanceDiagnostic> issues;

  const GovernanceIssueGroupData({
    required this.category,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.issues,
  });

  int get count => issues.length;

  int get errorCount =>
      issues.where((i) => i.severity == DiagnosticSeverity.error).length;

  int get warningCount =>
      issues.where((i) => i.severity == DiagnosticSeverity.warning).length;
}

/// The four Task 0811 risk-panel categories, in display order.
const List<DiagnosticCategory> kGovernanceRiskPanelCategories = [
  DiagnosticCategory.orphanAsset,
  DiagnosticCategory.staleReference,
  DiagnosticCategory.proofGap,
  DiagnosticCategory.missingDependency,
];

/// Pre-built issue group data for the four required risk-panel categories:
/// orphaning, staleness, proof gaps, and changelog/ledger-link gaps.
List<GovernanceIssueGroupData> buildIssueGroups(
  List<GovernanceDiagnostic> diagnostics,
) {
  return [
    GovernanceIssueGroupData(
      category: DiagnosticCategory.orphanAsset,
      title: 'Orphan Assets',
      description:
          'Assets with no incoming or outgoing edges — isolated in the graph '
          'and invisible to workflows that depend on connectivity.',
      icon: Icons.link_off,
      color: PrismColors.statusWarning,
      issues: diagnostics
          .where((d) => d.category == DiagnosticCategory.orphanAsset)
          .toList(),
    ),
    GovernanceIssueGroupData(
      category: DiagnosticCategory.staleReference,
      title: 'Stale References',
      description:
          'Edges pointing to assets that no longer exist. These broken links '
          'indicate outdated metadata that needs cleanup.',
      icon: Icons.link_off,
      color: PrismColors.statusError,
      issues: diagnostics
          .where((d) => d.category == DiagnosticCategory.staleReference)
          .toList(),
    ),
    GovernanceIssueGroupData(
      category: DiagnosticCategory.proofGap,
      title: 'Proof Gaps',
      description:
          'Tasks in review or completed lanes without required proof or '
          'evidence. Claims of completion cannot be verified — consistent '
          'with Operate surface proof-risk language.',
      icon: Icons.fact_check,
      color: PrismColors.statusError,
      issues: diagnostics
          .where((d) => d.category == DiagnosticCategory.proofGap)
          .toList(),
    ),
    GovernanceIssueGroupData(
      category: DiagnosticCategory.missingDependency,
      title: 'Changelog Without Task',
      description:
          'Ledger entries with no linked task. Changelog evidence cannot be '
          'traced to the work that motivated the change.',
      icon: Icons.history_edu_outlined,
      color: PrismColors.statusWarning,
      issues: diagnostics
          .where((d) => d.category == DiagnosticCategory.missingDependency)
          .toList(),
    ),
  ];
}

/// Renders a list of governance issue groups.
///
/// Each group is collapsible and shows issue count, severity breakdown,
/// and individual issue rows with explanations.
class GovernanceIssueGroup extends StatelessWidget {
  final GovernanceIssueGroupData group;

  /// Optional drill-down handler for issue asset IDs.
  final void Function(GovernanceDrilldownTarget target)? onDrilldown;

  const GovernanceIssueGroup({
    super.key,
    required this.group,
    this.onDrilldown,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: PrismColors.obsidianElevated,
        borderRadius: BorderRadius.circular(PrismRadii.lg),
        border: Border.all(color: PrismColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _GroupHeader(group: group),
          const PrismDivider.subtle(),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              PrismSpacing.lg,
              0,
              PrismSpacing.lg,
              PrismSpacing.sm,
            ),
            child: PrismText.bodySmall(
              group.description,
              color: PrismColors.textTertiary,
            ),
          ),
          if (group.issues.isEmpty)
            Padding(
              padding: const EdgeInsets.all(PrismSpacing.lg),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    size: 16,
                    color: PrismColors.statusSuccess,
                  ),
                  const SizedBox(width: PrismSpacing.sm),
                  PrismText.bodySmall(
                    'No ${group.title.toLowerCase()} found — system is clean',
                    color: PrismColors.statusSuccess,
                  ),
                ],
              ),
            )
          else
            ...group.issues.map(
              (issue) => _IssueRow(issue: issue, onDrilldown: onDrilldown),
            ),
          const SizedBox(height: PrismSpacing.sm),
        ],
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  final GovernanceIssueGroupData group;

  const _GroupHeader({required this.group});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(PrismSpacing.lg),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: group.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(PrismRadii.md),
            ),
            child: PrismIcon(group.icon, color: group.color),
          ),
          const SizedBox(width: PrismSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PrismText.headingSmall(group.title),
                const SizedBox(height: 2),
                PrismText.bodySmall(
                  '${group.count} issue${group.count == 1 ? '' : 's'}',
                  color: PrismColors.textSecondary,
                ),
              ],
            ),
          ),
          if (group.errorCount > 0)
            _SeverityBadge(
              count: group.errorCount,
              label: 'error',
              color: PrismColors.statusError,
            ),
          if (group.warningCount > 0) ...[
            if (group.errorCount > 0) const SizedBox(width: PrismSpacing.xs),
            _SeverityBadge(
              count: group.warningCount,
              label: 'warn',
              color: PrismColors.statusWarning,
            ),
          ],
        ],
      ),
    );
  }
}

class _SeverityBadge extends StatelessWidget {
  final int count;
  final String label;
  final Color color;

  const _SeverityBadge({
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(PrismRadii.sm),
      ),
      child: PrismText.labelSmall('$count $label', color: color),
    );
  }
}

class _IssueRow extends StatelessWidget {
  final GovernanceDiagnostic issue;
  final void Function(GovernanceDrilldownTarget target)? onDrilldown;

  const _IssueRow({required this.issue, this.onDrilldown});

  @override
  Widget build(BuildContext context) {
    final severityColor = switch (issue.severity) {
      DiagnosticSeverity.info => PrismColors.statusInfo,
      DiagnosticSeverity.warning => PrismColors.statusWarning,
      DiagnosticSeverity.error => PrismColors.statusError,
      DiagnosticSeverity.critical => PrismColors.statusError,
    };

    final severityIcon = switch (issue.severity) {
      DiagnosticSeverity.info => Icons.info_outline,
      DiagnosticSeverity.warning => Icons.warning_amber_outlined,
      DiagnosticSeverity.error => Icons.error_outline,
      DiagnosticSeverity.critical => Icons.dangerous_outlined,
    };

    final target = resolveDiagnosticDrilldown(issue);
    final canDrill = target != null && onDrilldown != null;
    final assetTitle =
        issue.context['assetName']?.toString() ??
        issue.context['taskTitle']?.toString() ??
        issue.assetId;

    final row = Container(
      padding: const EdgeInsets.all(PrismSpacing.sm),
      decoration: BoxDecoration(
        color: PrismColors.obsidianBase,
        borderRadius: BorderRadius.circular(PrismRadii.sm),
        border: Border(left: BorderSide(color: severityColor, width: 3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(severityIcon, size: 16, color: severityColor),
          const SizedBox(width: PrismSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PrismText.labelSmall(assetTitle, color: severityColor),
                const SizedBox(height: 2),
                PrismText.bodySmall(
                  '${issue.category.name} · ${issue.severity.name}',
                  color: PrismColors.textTertiary,
                ),
                const SizedBox(height: 2),
                PrismText.bodySmall(
                  issue.message,
                  color: PrismColors.textSecondary,
                ),
                if (canDrill) ...[
                  const SizedBox(height: 4),
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PrismIcon.small(
                        Icons.open_in_new,
                        color: PrismColors.accentCyan,
                      ),
                      SizedBox(width: PrismSpacing.xs),
                      PrismText.labelSmall(
                        'Open detail',
                        color: PrismColors.accentCyan,
                      ),
                    ],
                  ),
                ] else if (target == null && issue.assetId.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  const PrismText.labelSmall(
                    'Detail unavailable',
                    color: PrismColors.textTertiary,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PrismSpacing.lg,
        vertical: PrismSpacing.xs,
      ),
      child: canDrill
          ? Semantics(
              button: true,
              label: 'Open asset detail for ${issue.assetId}',
              child: InkWell(
                onTap: () => onDrilldown!(target),
                borderRadius: BorderRadius.circular(PrismRadii.sm),
                child: row,
              ),
            )
          : row,
    );
  }
}
