/// Governance risk-story summary widget.
///
/// Renders a concise narrative panel that combines boundary counts,
/// issue diagnostics, and hotspot analytics into human-readable
/// risk stories. All prose is derived from live diagnostic data,
/// not static fixtures.
library;

import 'package:flutter/material.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';
import 'package:warp_prism_observatory/data/models/governance_diagnostics.dart';
import 'fan_in_hotspots_panel.dart';
import 'governance_drilldown_controller.dart';

// ---------------------------------------------------------------------------
// Story Data Contracts
// ---------------------------------------------------------------------------

/// A single governance risk story — a concise narrative insight.
@immutable
class GovernanceRiskStory {
  /// Short title (e.g., 'Proof integrity at risk').
  final String title;

  /// Narrative sentence combining counts and implications.
  final String narrative;

  /// Severity of this story.
  final GovernanceStorySeverity severity;

  /// Asset IDs involved (for drill-down).
  final List<String> involvedAssetIds;

  /// Optional detail expansion text.
  final String? detail;

  const GovernanceRiskStory({
    required this.title,
    required this.narrative,
    required this.severity,
    this.involvedAssetIds = const [],
    this.detail,
  });
}

/// Severity for governance stories (distinct from diagnostic severity,
/// focused on narrative risk level).
enum GovernanceStorySeverity {
  /// All clear — positive narrative.
  healthy,

  /// Minor concern — informational.
  info,

  /// Moderate risk — should be reviewed.
  warning,

  /// Significant risk — needs attention.
  critical,
}

// ---------------------------------------------------------------------------
// Story Derivation
// ---------------------------------------------------------------------------

/// Derives governance risk stories from live diagnostic data.
///
/// Combines boundary counts, diagnostic categories, and hotspot
/// information into concise narratives. Each story is traceable
/// back to specific diagnostics — no static prose.
List<GovernanceRiskStory> deriveGovernanceRiskStories({
  required List<GovernanceDiagnostic> diagnostics,
  required Map<String, int> boundaryCounts,
  required int totalAssets,
  List<FanInHotspot> hotspots = const [],
}) {
  final stories = <GovernanceRiskStory>[];

  // ---- Boundary Health Story ----
  if (totalAssets > 0) {
    final canonical = boundaryCounts['parentCanonical'] ?? 0;
    final ratio = totalAssets > 0 ? canonical / totalAssets : 0.0;
    if (ratio < 0.5 && totalAssets > 2) {
      stories.add(
        GovernanceRiskStory(
          title: 'Canonical coverage below 50%',
          narrative:
              '$canonical of $totalAssets assets are canonical sources '
              'of truth. Consider reviewing non-canonical surfaces for '
              'consolidation or archival.',
          severity: GovernanceStorySeverity.warning,
        ),
      );
    } else if (totalAssets > 0) {
      stories.add(
        GovernanceRiskStory(
          title: 'Boundary overview',
          narrative:
              '$canonical of $totalAssets assets are canonical. '
              'Workspace boundary health is within normal range.',
          severity: GovernanceStorySeverity.healthy,
        ),
      );
    }
  }

  // ---- Proof Gap Story ----
  final proofGaps = diagnostics
      .where((d) => d.category == DiagnosticCategory.proofGap)
      .toList();
  if (proofGaps.isNotEmpty) {
    final errors = proofGaps
        .where((d) => d.severity == DiagnosticSeverity.error)
        .length;
    final warnings = proofGaps.length - errors;
    final assetIds = proofGaps.map((d) => d.assetId).toList();

    final severity = errors > 0
        ? GovernanceStorySeverity.critical
        : GovernanceStorySeverity.warning;

    stories.add(
      GovernanceRiskStory(
        title: 'Proof integrity at risk',
        narrative: proofGaps.length == 1
            ? '1 task lacks required proof for its lane position.'
            : '${proofGaps.length} tasks lack required proof '
                  '($errors missing, $warnings partial). '
                  'Claims of completion cannot be verified.',
        severity: severity,
        involvedAssetIds: assetIds,
      ),
    );
  }

  // ---- Orphan Assets Story ----
  final orphans = diagnostics
      .where((d) => d.category == DiagnosticCategory.orphanAsset)
      .toList();
  if (orphans.isNotEmpty) {
    stories.add(
      GovernanceRiskStory(
        title: 'Orphan assets detected',
        narrative: orphans.length == 1
            ? '1 asset is isolated in the graph with no connections.'
            : '${orphans.length} assets are isolated in the graph. '
                  'These invisible nodes cannot be reached by workflows '
                  'that depend on connectivity.',
        severity: GovernanceStorySeverity.warning,
        involvedAssetIds: orphans.map((d) => d.assetId).toList(),
      ),
    );
  }

  // ---- Stale References Story ----
  final staleRefs = diagnostics
      .where((d) => d.category == DiagnosticCategory.staleReference)
      .toList();
  if (staleRefs.isNotEmpty) {
    stories.add(
      GovernanceRiskStory(
        title: 'Broken references found',
        narrative: staleRefs.length == 1
            ? '1 edge points to a non-existent target.'
            : '${staleRefs.length} edges point to assets that no longer '
                  'exist. These broken links indicate outdated metadata.',
        severity: GovernanceStorySeverity.critical,
        involvedAssetIds: staleRefs.map((d) => d.assetId).toList(),
      ),
    );
  }

  // ---- Fan-In Hotspot Story ----
  if (hotspots.isNotEmpty) {
    final top = hotspots.first;
    stories.add(
      GovernanceRiskStory(
        title: 'Structural hotspots',
        narrative: hotspots.length == 1
            ? '${top.assetName} has ${top.incomingEdgeCount} incoming '
                  'references (threshold: ${top.threshold}). '
                  'Changes to this asset will cascade widely.'
            : '${hotspots.length} assets exceed fan-in thresholds. '
                  '${top.assetName} leads with ${top.incomingEdgeCount} '
                  'incoming references.',
        severity: top.incomingEdgeCount >= top.threshold * 2
            ? GovernanceStorySeverity.critical
            : GovernanceStorySeverity.warning,
        involvedAssetIds: hotspots.map((h) => h.assetId).toList(),
      ),
    );
  }

  // If no issues at all, add a healthy summary
  if (stories.isEmpty ||
      stories.every((s) => s.severity == GovernanceStorySeverity.healthy)) {
    if (diagnostics.isEmpty && totalAssets > 0) {
      stories.insert(
        0,
        GovernanceRiskStory(
          title: 'Governance is clean',
          narrative:
              'No diagnostics detected. All $totalAssets assets '
              'are within governance thresholds.',
          severity: GovernanceStorySeverity.healthy,
        ),
      );
    }
  }

  return stories;
}

// ---------------------------------------------------------------------------
// Story Summary Widget
// ---------------------------------------------------------------------------

/// Renders a panel of governance risk stories with drill-down support.
///
/// Each story shows a severity indicator, title, narrative, and optional
/// drill-down link to affected assets.
class GovernanceStorySummary extends StatelessWidget {
  /// The risk stories to render.
  final List<GovernanceRiskStory> stories;

  /// Called when the user taps a story's drill-down link.
  /// Receives the [GovernanceDrilldownTarget] for the first affected asset.
  final void Function(GovernanceDrilldownTarget target)? onDrilldown;

  const GovernanceStorySummary({
    super.key,
    required this.stories,
    this.onDrilldown,
  });

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
          // Header
          Padding(
            padding: const EdgeInsets.all(DSSpacing.lg),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: DSColors.accentCyan.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(DSRadii.md),
                  ),
                  child: DSIcon(Icons.auto_stories, color: DSColors.accentCyan),
                ),
                const SizedBox(width: DSSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DSText.headingSmall('Risk Stories'),
                      const SizedBox(height: 2),
                      DSText.bodySmall(
                        'Concise narratives derived from governance diagnostics',
                        color: DSColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const DSDivider.subtle(),

          // Stories
          if (stories.isEmpty)
            _buildEmptyState()
          else
            ...stories.map(
              (story) => _StoryRow(story: story, onDrilldown: onDrilldown),
            ),

          const SizedBox(height: DSSpacing.sm),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(DSSpacing.lg),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 16,
            color: DSColors.statusSuccess,
          ),
          const SizedBox(width: DSSpacing.sm),
          Expanded(
            child: DSText.bodySmall(
              'No governance data available yet. Risk stories will appear '
              'after workspace diagnostics run.',
              color: DSColors.statusSuccess,
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryRow extends StatelessWidget {
  final GovernanceRiskStory story;
  final void Function(GovernanceDrilldownTarget target)? onDrilldown;

  const _StoryRow({required this.story, this.onDrilldown});

  @override
  Widget build(BuildContext context) {
    final color = _severityColor(story.severity);
    final icon = _severityIcon(story.severity);

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
          border: Border(left: BorderSide(color: color, width: 3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row
            Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: DSSpacing.sm),
                Expanded(child: DSText.labelMedium(story.title, color: color)),
                if (story.severity != GovernanceStorySeverity.healthy)
                  _StorySeverityBadge(label: story.severity.name, color: color),
              ],
            ),
            const SizedBox(height: DSSpacing.xs),
            // Narrative
            DSText.bodySmall(story.narrative, color: DSColors.textSecondary),

            // Drill-down link
            if (story.involvedAssetIds.isNotEmpty && onDrilldown != null) ...[
              const SizedBox(height: DSSpacing.xs),
              GestureDetector(
                onTap: () {
                  final target = GovernanceDrilldownTarget(
                    assetId: story.involvedAssetIds.first,
                    routePath: '/assets/${story.involvedAssetIds.first}',
                    sourceLabel: story.title,
                  );
                  onDrilldown!(target);
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DSIcon.small(
                        Icons.open_in_new,
                        color: DSColors.accentCyan,
                      ),
                      const SizedBox(width: DSSpacing.xs),
                      DSText.labelSmall(
                        story.involvedAssetIds.length == 1
                            ? 'View ${story.involvedAssetIds.first}'
                            : 'View ${story.involvedAssetIds.length} assets',
                        color: DSColors.accentCyan,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _severityColor(GovernanceStorySeverity severity) {
    switch (severity) {
      case GovernanceStorySeverity.healthy:
        return DSColors.statusSuccess;
      case GovernanceStorySeverity.info:
        return DSColors.statusInfo;
      case GovernanceStorySeverity.warning:
        return DSColors.statusWarning;
      case GovernanceStorySeverity.critical:
        return DSColors.statusError;
    }
  }

  IconData _severityIcon(GovernanceStorySeverity severity) {
    switch (severity) {
      case GovernanceStorySeverity.healthy:
        return Icons.check_circle_outline;
      case GovernanceStorySeverity.info:
        return Icons.info_outline;
      case GovernanceStorySeverity.warning:
        return Icons.warning_amber_outlined;
      case GovernanceStorySeverity.critical:
        return Icons.error_outline;
    }
  }
}

class _StorySeverityBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StorySeverityBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(DSRadii.sm),
      ),
      child: DSText.labelSmall(label, color: color),
    );
  }
}
