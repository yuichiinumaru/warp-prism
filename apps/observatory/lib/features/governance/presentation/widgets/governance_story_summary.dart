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
    final ratio = canonical / totalAssets;
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
    } else {
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
/// Uses [PrismStoryPanel] for the shell narrative layer and adds
/// per-story drill-down links for affected assets.
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
    final accent = _panelAccent(stories);

    return PrismStoryPanel(
      title: 'Risk Stories',
      subtitle: 'Concise narratives derived from governance diagnostics',
      icon: Icons.auto_stories,
      accentColor: accent,
      insights: stories.isEmpty
          ? const [
              PrismStoryInsight(
                text: 'No governance data available yet',
                detail:
                    'Risk stories will appear after workspace diagnostics run.',
              ),
            ]
          : stories
                .map(
                  (story) => PrismStoryInsight(
                    text: story.title,
                    detail: story.narrative,
                    value: story.severity == GovernanceStorySeverity.healthy
                        ? null
                        : story.severity.name,
                    color: _severityColor(story.severity),
                  ),
                )
                .toList(),
      footer: stories.isEmpty
          ? null
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final story in stories)
                  if (story.involvedAssetIds.isNotEmpty)
                    _StoryDrilldownRow(story: story, onDrilldown: onDrilldown),
              ],
            ),
    );
  }

  Color _panelAccent(List<GovernanceRiskStory> stories) {
    if (stories.any((s) => s.severity == GovernanceStorySeverity.critical)) {
      return PrismColors.statusError;
    }
    if (stories.any((s) => s.severity == GovernanceStorySeverity.warning)) {
      return PrismColors.statusWarning;
    }
    if (stories.any((s) => s.severity == GovernanceStorySeverity.info)) {
      return PrismColors.statusInfo;
    }
    return PrismColors.accentCyan;
  }

  Color _severityColor(GovernanceStorySeverity severity) {
    switch (severity) {
      case GovernanceStorySeverity.healthy:
        return PrismColors.statusSuccess;
      case GovernanceStorySeverity.info:
        return PrismColors.statusInfo;
      case GovernanceStorySeverity.warning:
        return PrismColors.statusWarning;
      case GovernanceStorySeverity.critical:
        return PrismColors.statusError;
    }
  }
}

class _StoryDrilldownRow extends StatelessWidget {
  final GovernanceRiskStory story;
  final void Function(GovernanceDrilldownTarget target)? onDrilldown;

  const _StoryDrilldownRow({required this.story, this.onDrilldown});

  @override
  Widget build(BuildContext context) {
    final firstId = story.involvedAssetIds.first;
    final target = resolveAssetIdDrilldown(firstId);
    final label = story.involvedAssetIds.length == 1
        ? 'View $firstId'
        : 'View ${story.involvedAssetIds.length} assets';

    // Unresolved IDs degrade gracefully: show non-interactive label.
    if (target == null || onDrilldown == null) {
      return Padding(
        padding: const EdgeInsets.only(top: PrismSpacing.xs),
        child: PrismText.labelSmall(
          'Affected: $firstId (detail unavailable)',
          color: PrismColors.textTertiary,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: PrismSpacing.xs),
      child: Semantics(
        button: true,
        label: 'Open asset detail for $firstId from ${story.title}',
        child: InkWell(
          onTap: () => onDrilldown!(target),
          borderRadius: BorderRadius.circular(PrismRadii.sm),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const PrismIcon.small(
                  Icons.open_in_new,
                  color: PrismColors.accentCyan,
                ),
                const SizedBox(width: PrismSpacing.xs),
                PrismText.labelSmall(label, color: PrismColors.accentCyan),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
