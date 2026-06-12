/// Governance overview page — canonicality boundaries overview.
///
/// Renders boundary class counts and legend from diagnostics,
/// distinguishing source-of-truth assets from generated or
/// read-only projections. This page is explicitly read-only.
library;

import 'package:flutter/material.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';
import 'package:warp_prism_observatory/data/models/governance_diagnostics.dart';
import 'widgets/governance_boundary_legend.dart';

/// Summary of canonicality boundary metrics from diagnostics.
@immutable
class CanonicalityBoundarySummary {
  /// Counts per canonicality class (key → count).
  final Map<String, int> counts;

  /// Total assets across all classes.
  final int totalAssets;

  /// Governance diagnostics (warnings/errors).
  final List<GovernanceDiagnostic> diagnostics;

  const CanonicalityBoundarySummary({
    required this.counts,
    required this.totalAssets,
    this.diagnostics = const [],
  });

  /// Whether any data is available.
  bool get isEmpty => totalAssets == 0;
}

/// The main Governance overview page.
///
/// Consumes a [CanonicalityBoundarySummary] from the diagnostics
/// service and renders:
/// - Read-only banner
/// - Summary metric tiles
/// - Canonicality boundary legend with counts
/// - Diagnostics list (if any)
class GovernanceOverviewPage extends StatelessWidget {
  /// Boundary metrics from the diagnostics service.
  /// If null, starts with empty state (for router instantiation
  /// before a provider wires real data).
  final CanonicalityBoundarySummary? summary;

  const GovernanceOverviewPage({super.key, this.summary});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Read-only disclaimer
        const GovernanceReadOnlyBanner(),

        // Content
        Expanded(
          child: (summary == null || summary!.isEmpty)
              ? _buildEmptyState()
              : _buildContent(),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return DSStateSurface.empty(
      icon: DSIcons.governance,
      title: 'No governance data',
      subtitle: 'Boundary metrics will appear after workspace diagnostics run',
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DSSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary section
          _buildSummarySection(),
          const SizedBox(height: DSSpacing.xxl),

          // Legend with counts
          GovernanceBoundaryLegend(counts: summary!.counts),
          const SizedBox(height: DSSpacing.xxl),

          // Count cards grid
          _buildCountCards(),
          const SizedBox(height: DSSpacing.xxl),

          // Diagnostics section (if any)
          if (summary!.diagnostics.isNotEmpty) ...[_buildDiagnosticsSection()],
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    final s = summary!;
    final canonicalCount = s.counts['parentCanonical'] ?? 0;
    final generatedCount = s.counts['generated'] ?? 0;
    final nonCanonical = s.totalAssets - canonicalCount;

    return Container(
      padding: const EdgeInsets.all(DSSpacing.lg),
      decoration: BoxDecoration(
        color: DSColors.obsidianElevated,
        borderRadius: BorderRadius.circular(DSRadii.lg),
        border: Border.all(color: DSColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DSText.labelLarge('BOUNDARY OVERVIEW', color: DSColors.textSecondary),
          const SizedBox(height: DSSpacing.md),
          Row(
            children: [
              _MetricTile(
                label: 'Total Assets',
                value: s.totalAssets.toString(),
                color: DSColors.textPrimary,
              ),
              const SizedBox(width: DSSpacing.lg),
              _MetricTile(
                label: 'Canonical',
                value: canonicalCount.toString(),
                color: DSColors.governanceCanonical,
              ),
              const SizedBox(width: DSSpacing.lg),
              _MetricTile(
                label: 'Non-Canonical',
                value: nonCanonical.toString(),
                color: DSColors.statusWarning,
              ),
              const SizedBox(width: DSSpacing.lg),
              _MetricTile(
                label: 'Generated',
                value: generatedCount.toString(),
                color: DSColors.governanceGenerated,
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.md),
          DSText.bodySmall(
            '$canonicalCount of ${s.totalAssets} assets are canonical sources of truth. '
            '$nonCanonical are derived, local, or auxiliary surfaces.',
            color: DSColors.textTertiary,
          ),
        ],
      ),
    );
  }

  Widget _buildCountCards() {
    final classes = [
      _ClassCardData(
        'parentCanonical',
        'Canonical',
        DSColors.governanceCanonical,
        DSIcons.canonical,
      ),
      _ClassCardData(
        'childLocal',
        'Child-Local',
        DSColors.governanceLocal,
        DSIcons.local,
      ),
      _ClassCardData(
        'generated',
        'Generated',
        DSColors.governanceGenerated,
        DSIcons.generated,
      ),
      _ClassCardData(
        'appendOnly',
        'Append-Only',
        DSColors.governanceAppendOnly,
        DSIcons.appendOnly,
      ),
      _ClassCardData(
        'archive',
        'Archive',
        DSColors.governanceArchive,
        DSIcons.archive,
      ),
      _ClassCardData('mock', 'Mock', DSColors.governanceMock, DSIcons.mock),
    ];

    return Wrap(
      spacing: DSSpacing.md,
      runSpacing: DSSpacing.md,
      children: classes.map((cls) {
        final count = summary!.counts[cls.key] ?? 0;
        return _CountCard(data: cls, count: count);
      }).toList(),
    );
  }

  Widget _buildDiagnosticsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DSText.labelLarge('DIAGNOSTICS', color: DSColors.textSecondary),
        const SizedBox(height: DSSpacing.md),
        ...summary!.diagnostics.map(
          (d) => Padding(
            padding: const EdgeInsets.only(bottom: DSSpacing.xs),
            child: _DiagnosticRow(diagnostic: d),
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
        DSText.numeric(value, color: color),
        const SizedBox(height: 2),
        DSText.labelSmall(label, color: DSColors.textTertiary),
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
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: DSColors.obsidianElevated,
        borderRadius: BorderRadius.circular(DSRadii.md),
        border: Border.all(color: data.color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DSIcon.small(data.icon, color: data.color),
          const SizedBox(height: DSSpacing.sm),
          DSText.numeric(count.toString(), color: data.color),
          const SizedBox(height: 2),
          DSText.labelSmall(data.label, color: DSColors.textTertiary),
        ],
      ),
    );
  }
}

class _DiagnosticRow extends StatelessWidget {
  final GovernanceDiagnostic diagnostic;

  const _DiagnosticRow({required this.diagnostic});

  @override
  Widget build(BuildContext context) {
    final severityColor = switch (diagnostic.severity) {
      DiagnosticSeverity.info => DSColors.statusInfo,
      DiagnosticSeverity.warning => DSColors.statusWarning,
      DiagnosticSeverity.error => DSColors.statusError,
      DiagnosticSeverity.critical => DSColors.statusError,
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: DSColors.obsidianElevated,
        borderRadius: BorderRadius.circular(DSRadii.sm),
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
          const SizedBox(width: DSSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DSText.labelSmall(
                  '${diagnostic.assetId} — ${diagnostic.category.name}',
                  color: severityColor,
                ),
                DSText.bodySmall(
                  diagnostic.message,
                  color: DSColors.textSecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
