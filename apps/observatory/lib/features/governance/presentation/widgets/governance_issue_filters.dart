/// Governance issue filters widget.
///
/// Provides category and severity filtering for governance issue groups.
/// Filtering is local to presentational state — all finding derivation
/// stays in the diagnostics service layer.
library;

import 'package:flutter/material.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';
import 'package:warp_prism_observatory/data/models/governance_diagnostics.dart';

/// Active filter state for governance issue panels.
@immutable
class GovernanceFilterState {
  /// Selected categories to show (empty = show all).
  final Set<DiagnosticCategory> selectedCategories;

  /// Selected severities to show (empty = show all).
  final Set<DiagnosticSeverity> selectedSeverities;

  const GovernanceFilterState({
    this.selectedCategories = const {},
    this.selectedSeverities = const {},
  });

  /// Whether any filter is active.
  bool get isActive =>
      selectedCategories.isNotEmpty || selectedSeverities.isNotEmpty;

  /// Whether a diagnostic matches the current filters.
  bool matches(GovernanceDiagnostic diagnostic) {
    if (selectedCategories.isNotEmpty &&
        !selectedCategories.contains(diagnostic.category)) {
      return false;
    }
    if (selectedSeverities.isNotEmpty &&
        !selectedSeverities.contains(diagnostic.severity)) {
      return false;
    }
    return true;
  }

  GovernanceFilterState copyWith({
    Set<DiagnosticCategory>? selectedCategories,
    Set<DiagnosticSeverity>? selectedSeverities,
    bool clearCategories = false,
    bool clearSeverities = false,
  }) {
    return GovernanceFilterState(
      selectedCategories: clearCategories
          ? const {}
          : (selectedCategories ?? this.selectedCategories),
      selectedSeverities: clearSeverities
          ? const {}
          : (selectedSeverities ?? this.selectedSeverities),
    );
  }
}

/// Filter bar for governance issue panels.
///
/// Renders toggleable filter chips for categories and severities.
class GovernanceIssueFilters extends StatelessWidget {
  final GovernanceFilterState filterState;
  final ValueChanged<GovernanceFilterState> onFilterChanged;

  const GovernanceIssueFilters({
    super.key,
    required this.filterState,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PrismText.labelSmall('CATEGORY', color: PrismColors.textTertiary),
        const SizedBox(height: PrismSpacing.xs),
        Wrap(
          spacing: PrismSpacing.xs,
          runSpacing: PrismSpacing.xs,
          children: [
            _FilterChip(
              label: 'Orphans',
              icon: Icons.link_off,
              isActive: filterState.selectedCategories.contains(
                DiagnosticCategory.orphanAsset,
              ),
              color: PrismColors.statusWarning,
              onTap: () => _toggleCategory(DiagnosticCategory.orphanAsset),
            ),
            _FilterChip(
              label: 'Stale',
              icon: Icons.link_off,
              isActive: filterState.selectedCategories.contains(
                DiagnosticCategory.staleReference,
              ),
              color: PrismColors.statusError,
              onTap: () => _toggleCategory(DiagnosticCategory.staleReference),
            ),
            _FilterChip(
              label: 'Proof Gaps',
              icon: Icons.fact_check,
              isActive: filterState.selectedCategories.contains(
                DiagnosticCategory.proofGap,
              ),
              color: PrismColors.statusError,
              onTap: () => _toggleCategory(DiagnosticCategory.proofGap),
            ),
            _FilterChip(
              label: 'Ledger Gaps',
              icon: Icons.history_edu_outlined,
              isActive: filterState.selectedCategories.contains(
                DiagnosticCategory.missingDependency,
              ),
              color: PrismColors.statusWarning,
              onTap: () =>
                  _toggleCategory(DiagnosticCategory.missingDependency),
            ),
          ],
        ),
        const SizedBox(height: PrismSpacing.sm),
        const PrismText.labelSmall('SEVERITY', color: PrismColors.textTertiary),
        const SizedBox(height: PrismSpacing.xs),
        Wrap(
          spacing: PrismSpacing.xs,
          runSpacing: PrismSpacing.xs,
          children: [
            _FilterChip(
              label: 'Error',
              icon: Icons.error_outline,
              isActive: filterState.selectedSeverities.contains(
                DiagnosticSeverity.error,
              ),
              color: PrismColors.statusError,
              onTap: () => _toggleSeverity(DiagnosticSeverity.error),
            ),
            _FilterChip(
              label: 'Warning',
              icon: Icons.warning_amber_outlined,
              isActive: filterState.selectedSeverities.contains(
                DiagnosticSeverity.warning,
              ),
              color: PrismColors.statusWarning,
              onTap: () => _toggleSeverity(DiagnosticSeverity.warning),
            ),
            _FilterChip(
              label: 'Info',
              icon: Icons.info_outline,
              isActive: filterState.selectedSeverities.contains(
                DiagnosticSeverity.info,
              ),
              color: PrismColors.statusInfo,
              onTap: () => _toggleSeverity(DiagnosticSeverity.info),
            ),
          ],
        ),
        if (filterState.isActive) ...[
          const SizedBox(height: PrismSpacing.sm),
          GestureDetector(
            onTap: () => onFilterChanged(const GovernanceFilterState()),
            child: const MouseRegion(
              cursor: SystemMouseCursors.click,
              child: PrismText.labelSmall(
                'Clear all filters',
                color: PrismColors.accentCyan,
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _toggleCategory(DiagnosticCategory category) {
    final current = Set<DiagnosticCategory>.from(
      filterState.selectedCategories,
    );
    if (current.contains(category)) {
      current.remove(category);
    } else {
      current.add(category);
    }
    onFilterChanged(filterState.copyWith(selectedCategories: current));
  }

  void _toggleSeverity(DiagnosticSeverity severity) {
    final current = Set<DiagnosticSeverity>.from(
      filterState.selectedSeverities,
    );
    if (current.contains(severity)) {
      current.remove(severity);
    } else {
      current.add(severity);
    }
    onFilterChanged(filterState.copyWith(selectedSeverities: current));
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final Color color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: PrismSpacing.sm,
            vertical: PrismSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: isActive
                ? color.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(PrismRadii.sm),
            border: Border.all(
              color: isActive
                  ? color.withValues(alpha: 0.4)
                  : PrismColors.borderSubtle,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PrismIcon.small(
                icon,
                color: isActive ? color : PrismColors.textTertiary,
              ),
              const SizedBox(width: PrismSpacing.xs),
              PrismText.labelSmall(
                label,
                color: isActive ? color : PrismColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
