/// Governance overview page — composed governance surface.
///
/// Renders boundary class counts, risk stories, issue groups (with
/// category/severity filters), fan-in hotspots, and review-pressure
/// analytics from diagnostics. Warnings and hotspots expose drill-down
/// hooks to the universal asset detail route. This page is explicitly
/// read-only.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';
import 'package:warp_prism_observatory/data/models/governance_diagnostics.dart';
import 'widgets/fan_in_hotspots_panel.dart';
import 'widgets/governance_boundary_legend.dart';
import 'widgets/governance_drilldown_controller.dart';
import 'widgets/governance_issue_filters.dart';
import 'widgets/governance_issue_group.dart';
import 'widgets/governance_story_summary.dart';
import 'widgets/review_pressure_panel.dart';

/// Summary of canonicality boundary metrics from diagnostics.
@immutable
class CanonicalityBoundarySummary {
  /// Counts per canonicality class (key → count).
  final Map<String, int> counts;

  /// Total assets across all classes.
  final int totalAssets;

  /// Governance diagnostics (warnings/errors).
  final List<GovernanceDiagnostic> diagnostics;

  /// Optional pre-ranked fan-in hotspots. When empty, derived from
  /// [diagnostics] via [FanInHotspot.fromDiagnostics].
  final List<FanInHotspot> hotspots;

  const CanonicalityBoundarySummary({
    required this.counts,
    required this.totalAssets,
    this.diagnostics = const [],
    this.hotspots = const [],
  });

  /// Whether any data is available.
  bool get isEmpty => totalAssets == 0 && diagnostics.isEmpty;

  /// Hotspots to render (explicit list or derived from diagnostics).
  List<FanInHotspot> get resolvedHotspots => hotspots.isNotEmpty
      ? hotspots
      : FanInHotspot.fromDiagnostics(diagnostics);
}

/// The main Governance overview page.
///
/// Consumes a [CanonicalityBoundarySummary] from the diagnostics
/// service (via [GovernancePageShell] in production) and renders:
/// - Read-only banner
/// - Risk story summary derived from live diagnostics
/// - Summary metric tiles + boundary legend
/// - Category/severity filters + issue groups with drill-down
/// - Fan-in hotspots and review-pressure analytics
/// - Diagnostics list (if any)
class GovernanceOverviewPage extends StatefulWidget {
  /// Boundary metrics from the diagnostics service.
  /// If null, starts with empty state (for router instantiation
  /// before a provider wires real data).
  final CanonicalityBoundarySummary? summary;

  /// Optional external drill-down handler. Defaults to GoRouter
  /// navigation for navigable targets; unresolved targets show a
  /// non-blocking snackbar fallback.
  final void Function(GovernanceDrilldownTarget target)? onDrilldown;

  const GovernanceOverviewPage({super.key, this.summary, this.onDrilldown});

  @override
  State<GovernanceOverviewPage> createState() => _GovernanceOverviewPageState();
}

class _GovernanceOverviewPageState extends State<GovernanceOverviewPage> {
  GovernanceFilterState _filterState = const GovernanceFilterState();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Read-only disclaimer
        const GovernanceReadOnlyBanner(),

        // Content
        Expanded(
          child: (widget.summary == null || widget.summary!.isEmpty)
              ? _buildEmptyState()
              : _buildContent(context),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const PrismStateSurface.empty(
      icon: PrismIcons.governance,
      title: 'No governance data',
      subtitle: 'Boundary metrics will appear after workspace diagnostics run',
    );
  }

  Widget _buildContent(BuildContext context) {
    final s = widget.summary!;
    final hotspots = s.resolvedHotspots;
    final stories = deriveGovernanceRiskStories(
      diagnostics: s.diagnostics,
      boundaryCounts: s.counts,
      totalAssets: s.totalAssets,
      hotspots: hotspots,
    );

    // Presentational filter only — never re-derives findings.
    final filteredDiagnostics = _filterState.isActive
        ? s.diagnostics.where(_filterState.matches).toList()
        : s.diagnostics;
    final issueGroups = buildIssueGroups(
      filteredDiagnostics,
    ).where((g) => g.issues.isNotEmpty).toList();

    final pressureIndicators = ReviewPressureIndicator.fromDiagnostics(
      s.diagnostics,
    );

    final handleDrilldown =
        widget.onDrilldown ?? (target) => _defaultDrilldown(context, target);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(PrismSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Risk storytelling — top of composed surface
          GovernanceStorySummary(
            stories: stories,
            onDrilldown: handleDrilldown,
          ),
          const SizedBox(height: PrismSpacing.xxl),

          // Summary section
          _buildSummarySection(),
          const SizedBox(height: PrismSpacing.xxl),

          // Legend with counts
          GovernanceBoundaryLegend(counts: s.counts),
          const SizedBox(height: PrismSpacing.xxl),

          // Count cards grid
          _buildCountCards(),
          const SizedBox(height: PrismSpacing.xxl),

          // Issue filters + groups with drill-down
          if (s.diagnostics.isNotEmpty) ...[
            const PrismText.labelLarge(
              'ISSUE PANELS',
              color: PrismColors.textSecondary,
            ),
            const SizedBox(height: PrismSpacing.md),
            GovernanceIssueFilters(
              filterState: _filterState,
              onFilterChanged: (next) {
                setState(() => _filterState = next);
              },
            ),
            const SizedBox(height: PrismSpacing.md),
            if (issueGroups.isEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: PrismSpacing.md),
                child: PrismText.bodySmall(
                  'No issues match the current filters.',
                  color: PrismColors.textTertiary,
                ),
              )
            else
              ...issueGroups.map(
                (group) => Padding(
                  padding: const EdgeInsets.only(bottom: PrismSpacing.md),
                  child: GovernanceIssueGroup(
                    group: group,
                    onDrilldown: handleDrilldown,
                  ),
                ),
              ),
            const SizedBox(height: PrismSpacing.lg),
          ],

          // Fan-in hotspots with drill-down
          FanInHotspotsPanel(hotspots: hotspots, onDrilldown: handleDrilldown),
          const SizedBox(height: PrismSpacing.xxl),

          // Review queue pressure analytics (Task 0812)
          ReviewPressurePanel(indicators: pressureIndicators),
          const SizedBox(height: PrismSpacing.xxl),

          // Diagnostics section (if any)
          if (s.diagnostics.isNotEmpty) ...[
            _buildDiagnosticsSection(handleDrilldown),
          ],
        ],
      ),
    );
  }

  void _defaultDrilldown(
    BuildContext context,
    GovernanceDrilldownTarget target,
  ) {
    if (!target.isNavigable) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(
          content: Text(
            'Asset detail unavailable for ${target.assetId.isEmpty ? '(empty id)' : target.assetId}',
          ),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    context.go(target.routePath);
  }

  Widget _buildSummarySection() {
    final s = widget.summary!;
    final canonicalCount = s.counts['parentCanonical'] ?? 0;
    final generatedCount = s.counts['generated'] ?? 0;
    final nonCanonical = s.totalAssets - canonicalCount;

    return Container(
      padding: const EdgeInsets.all(PrismSpacing.lg),
      decoration: BoxDecoration(
        color: PrismColors.obsidianElevated,
        borderRadius: BorderRadius.circular(PrismRadii.lg),
        border: Border.all(color: PrismColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PrismText.labelLarge(
            'BOUNDARY OVERVIEW',
            color: PrismColors.textSecondary,
          ),
          const SizedBox(height: PrismSpacing.md),
          Row(
            children: [
              _MetricTile(
                label: 'Total Assets',
                value: s.totalAssets.toString(),
                color: PrismColors.textPrimary,
              ),
              const SizedBox(width: PrismSpacing.lg),
              _MetricTile(
                label: 'Canonical',
                value: canonicalCount.toString(),
                color: PrismColors.governanceCanonical,
              ),
              const SizedBox(width: PrismSpacing.lg),
              _MetricTile(
                label: 'Non-Canonical',
                value: nonCanonical.toString(),
                color: PrismColors.statusWarning,
              ),
              const SizedBox(width: PrismSpacing.lg),
              _MetricTile(
                label: 'Generated',
                value: generatedCount.toString(),
                color: PrismColors.governanceGenerated,
              ),
            ],
          ),
          const SizedBox(height: PrismSpacing.md),
          PrismText.bodySmall(
            '$canonicalCount of ${s.totalAssets} assets are canonical sources of truth. '
            '$nonCanonical are derived, local, or auxiliary surfaces.',
            color: PrismColors.textTertiary,
          ),
        ],
      ),
    );
  }

  Widget _buildCountCards() {
    const classes = [
      _ClassCardData(
        'parentCanonical',
        'Canonical',
        PrismColors.governanceCanonical,
        PrismIcons.canonical,
      ),
      _ClassCardData(
        'childLocal',
        'Child-Local',
        PrismColors.governanceLocal,
        PrismIcons.local,
      ),
      _ClassCardData(
        'generated',
        'Generated',
        PrismColors.governanceGenerated,
        PrismIcons.generated,
      ),
      _ClassCardData(
        'appendOnly',
        'Append-Only',
        PrismColors.governanceAppendOnly,
        PrismIcons.appendOnly,
      ),
      _ClassCardData(
        'archive',
        'Archive',
        PrismColors.governanceArchive,
        PrismIcons.archive,
      ),
      _ClassCardData(
        'mock',
        'Mock',
        PrismColors.governanceMock,
        PrismIcons.mock,
      ),
    ];

    return Wrap(
      spacing: PrismSpacing.md,
      runSpacing: PrismSpacing.md,
      children: classes.map((cls) {
        final count = widget.summary!.counts[cls.key] ?? 0;
        return _CountCard(data: cls, count: count);
      }).toList(),
    );
  }

  Widget _buildDiagnosticsSection(
    void Function(GovernanceDrilldownTarget target) handleDrilldown,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PrismText.labelLarge(
          'DIAGNOSTICS',
          color: PrismColors.textSecondary,
        ),
        const SizedBox(height: PrismSpacing.md),
        ...widget.summary!.diagnostics.map(
          (d) => Padding(
            padding: const EdgeInsets.only(bottom: PrismSpacing.xs),
            child: _DiagnosticRow(diagnostic: d, onDrilldown: handleDrilldown),
          ),
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PrismText.numeric(value, color: color),
        const SizedBox(height: 2),
        PrismText.labelSmall(label, color: PrismColors.textTertiary),
      ],
    );
  }
}

class _ClassCardData {
  final String key;
  final String label;
  final Color color;
  final IconData icon;

  const _ClassCardData(this.key, this.label, this.color, this.icon);
}

class _CountCard extends StatelessWidget {
  final _ClassCardData data;
  final int count;

  const _CountCard({required this.data, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(PrismSpacing.md),
      decoration: BoxDecoration(
        color: PrismColors.obsidianElevated,
        borderRadius: BorderRadius.circular(PrismRadii.md),
        border: Border.all(color: data.color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PrismIcon.small(data.icon, color: data.color),
          const SizedBox(height: PrismSpacing.sm),
          PrismText.numeric(count.toString(), color: data.color),
          const SizedBox(height: 2),
          PrismText.labelSmall(data.label, color: PrismColors.textTertiary),
        ],
      ),
    );
  }
}

class _DiagnosticRow extends StatelessWidget {
  final GovernanceDiagnostic diagnostic;
  final void Function(GovernanceDrilldownTarget target)? onDrilldown;

  const _DiagnosticRow({required this.diagnostic, this.onDrilldown});

  @override
  Widget build(BuildContext context) {
    final severityColor = switch (diagnostic.severity) {
      DiagnosticSeverity.info => PrismColors.statusInfo,
      DiagnosticSeverity.warning => PrismColors.statusWarning,
      DiagnosticSeverity.error => PrismColors.statusError,
      DiagnosticSeverity.critical => PrismColors.statusError,
    };

    final target = resolveDiagnosticDrilldown(diagnostic);
    final canDrill = target != null && onDrilldown != null;

    final row = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PrismSpacing.md,
        vertical: PrismSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: PrismColors.obsidianElevated,
        borderRadius: BorderRadius.circular(PrismRadii.sm),
        border: Border(left: BorderSide(color: severityColor, width: 3)),
      ),
      child: Row(
        children: [
          Icon(
            switch (diagnostic.severity) {
              DiagnosticSeverity.info => Icons.info_outline,
              DiagnosticSeverity.warning => Icons.warning_amber_outlined,
              DiagnosticSeverity.error => Icons.error_outline,
              DiagnosticSeverity.critical => Icons.dangerous_outlined,
            },
            size: 16,
            color: severityColor,
          ),
          const SizedBox(width: PrismSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PrismText.labelSmall(
                  '${diagnostic.assetId} — ${diagnostic.category.name}',
                  color: severityColor,
                ),
                PrismText.bodySmall(
                  diagnostic.message,
                  color: PrismColors.textSecondary,
                ),
              ],
            ),
          ),
          if (canDrill)
            const PrismIcon.small(
              Icons.open_in_new,
              color: PrismColors.accentCyan,
            ),
        ],
      ),
    );

    if (!canDrill) return row;

    return Semantics(
      button: true,
      label: 'Open asset detail for ${diagnostic.assetId}',
      child: InkWell(
        onTap: () => onDrilldown!(target),
        borderRadius: BorderRadius.circular(PrismRadii.sm),
        child: row,
      ),
    );
  }
}
