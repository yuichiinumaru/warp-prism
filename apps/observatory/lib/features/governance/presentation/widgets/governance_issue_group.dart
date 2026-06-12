/// Governance issue group widget.
///
/// Renders grouped governance findings (orphans, stale references,
/// proof gaps, changelog-without-task) with human-readable explanations.
/// Each issue shows asset title, category, severity, and explanation.
library;

import 'package:flutter/material.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';
import 'package:warp_prism_observatory/data/models/governance_diagnostics.dart';

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

/// Pre-built issue group data for the four required categories.
List<GovernanceIssueGroupData> buildIssueGroups(
  List<GovernanceDiagnostic> diagnostics,
) {
  final groups = <GovernanceIssueGroupData>[
    GovernanceIssueGroupData(
      category: DiagnosticCategory.orphanAsset,
      title: 'Orphan Assets',
      description:
          'Assets with no incoming or outgoing edges — isolated in the graph '
          'and invisible to workflows that depend on connectivity.',
      icon: Icons.link_off,
      color: DSColors.statusWarning,
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
      color: DSColors.statusError,
      issues: diagnostics
          .where((d) => d.category == DiagnosticCategory.staleReference)
          .toList(),
    ),
    GovernanceIssueGroupData(
      category: DiagnosticCategory.proofGap,
      title: 'Proof Gaps',
      description:
          'Tasks in review or completed lanes without required proof or '
          'evidence. Claims of completion cannot be verified.',
      icon: Icons.fact_check,
      color: DSColors.statusError,
      issues: diagnostics
          .where((d) => d.category == DiagnosticCategory.proofGap)
          .toList(),
    ),
    GovernanceIssueGroupData(
      category: DiagnosticCategory.brokenEdge,
      title: 'High Fan-In Hotspots',
      description:
          'Assets receiving many incoming edges, indicating over-centralized '
          'dependencies or hotspot risk.',
      icon: Icons.warning_amber_outlined,
      color: DSColors.statusWarning,
      issues: diagnostics
          .where((d) => d.category == DiagnosticCategory.brokenEdge)
          .toList(),
    ),
  ];

  return groups;
}

/// Renders a list of governance issue groups.
///
/// Each group is collapsible and shows issue count, severity breakdown,
/// and individual issue rows with explanations.
class GovernanceIssueGroup extends StatelessWidget {
  final GovernanceIssueGroupData group;

  const GovernanceIssueGroup({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DSColors.obsidianElevated,
        borderRadius: BorderRadius.circular(DSRadii.lg),
        border: Border.all(color: DSColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Group header
          _GroupHeader(group: group),

          const DSDivider.subtle(),

          // Group description
          Padding(
            padding: const EdgeInsets.fromLTRB(
              DSSpacing.lg,
              0,
              DSSpacing.lg,
              DSSpacing.sm,
            ),
            child: DSText.bodySmall(
              group.description,
              color: DSColors.textTertiary,
            ),
          ),

          // Issue rows
          if (group.issues.isEmpty)
            Padding(
              padding: const EdgeInsets.all(DSSpacing.lg),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 16,
                    color: DSColors.statusSuccess,
                  ),
                  const SizedBox(width: DSSpacing.sm),
                  DSText.bodySmall(
                    'No ${group.title.toLowerCase()} found — system is clean',
                    color: DSColors.statusSuccess,
                  ),
                ],
              ),
            )
          else
            ...group.issues.map((issue) => _IssueRow(issue: issue)),

          const SizedBox(height: DSSpacing.sm),
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
      padding: const EdgeInsets.all(DSSpacing.lg),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: group.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(DSRadii.md),
            ),
            child: DSIcon(group.icon, color: group.color),
          ),
          const SizedBox(width: DSSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DSText.headingSmall(group.title),
                const SizedBox(height: 2),
                DSText.bodySmall(
                  '${group.count} issue${group.count == 1 ? '' : 's'}',
                  color: DSColors.textSecondary,
                ),
              ],
            ),
          ),
          // Severity breakdown
          if (group.errorCount > 0)
            _SeverityBadge(
              count: group.errorCount,
              label: 'error',
              color: DSColors.statusError,
            ),
          if (group.warningCount > 0) ...[
            if (group.errorCount > 0) const SizedBox(width: DSSpacing.xs),
            _SeverityBadge(
              count: group.warningCount,
              label: 'warn',
              color: DSColors.statusWarning,
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
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(DSRadii.sm),
      ),
      child: DSText.labelSmall('$count $label', color: color),
    );
  }
}

class _IssueRow extends StatelessWidget {
  final GovernanceDiagnostic issue;

  const _IssueRow({required this.issue});

  @override
  Widget build(BuildContext context) {
    final severityColor = switch (issue.severity) {
      DiagnosticSeverity.info => DSColors.statusInfo,
      DiagnosticSeverity.warning => DSColors.statusWarning,
      DiagnosticSeverity.error => DSColors.statusError,
      DiagnosticSeverity.critical => DSColors.statusError,
    };

    final severityIcon = switch (issue.severity) {
      DiagnosticSeverity.info => Icons.info_outline,
      DiagnosticSeverity.warning => Icons.warning_amber_outlined,
      DiagnosticSeverity.error => Icons.error_outline,
      DiagnosticSeverity.critical => Icons.dangerous_outlined,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.lg,
        vertical: DSSpacing.xs,
      ),
      child: Container(
        padding: const EdgeInsets.all(DSSpacing.sm),
        decoration: BoxDecoration(
          color: DSColors.obsidianBase,
          borderRadius: BorderRadius.circular(DSRadii.sm),
          border: Border(left: BorderSide(color: severityColor, width: 3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(severityIcon, size: 16, color: severityColor),
            const SizedBox(width: DSSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DSText.labelSmall(issue.assetId, color: severityColor),
                  const SizedBox(height: 2),
                  DSText.bodySmall(
                    issue.message,
                    color: DSColors.textSecondary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
