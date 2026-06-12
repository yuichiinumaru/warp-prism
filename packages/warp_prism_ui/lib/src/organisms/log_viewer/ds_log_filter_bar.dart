import 'package:flutter/material.dart';
import '../../tokens/tokens.dart';
import '../../molecules/molecules.dart';
import 'ds_log_severity.dart';

/// Filter bar for [DSLogViewer].
///
/// Provides:
/// - Text search input (delegates to [DSSearchBar])
/// - Severity chip filters (debug / info / warning / error / critical)
/// - Source chip filters (dynamic, derived from log entry sources)
class DSLogFilterBar extends StatelessWidget {
  final String searchQuery;
  final ValueChanged<String>? onSearchChanged;
  final Set<DSLogSeverity> activeSeverities;
  final ValueChanged<DSLogSeverity>? onSeverityToggle;
  final List<String> availableSources;
  final Set<String> activeSources;
  final ValueChanged<String>? onSourceToggle;

  const DSLogFilterBar({
    super.key,
    this.searchQuery = '',
    this.onSearchChanged,
    this.activeSeverities = const {},
    this.onSeverityToggle,
    this.availableSources = const [],
    this.activeSources = const {},
    this.onSourceToggle,
  });

  @override
  Widget build(BuildContext context) {
    final activeFilterCount = activeSeverities.length + activeSources.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Search bar
        DSSearchBar(
          placeholder: 'Search log entries...',
          value: searchQuery,
          onChanged: onSearchChanged,
          onClear: () => onSearchChanged?.call(''),
          showFilter: false,
          activeFilterCount: activeFilterCount > 0 ? activeFilterCount : null,
        ),
        const SizedBox(height: DSSpacing.sm),

        // Severity filters
        DSFilterChipGroup(
          options: DSLogSeverity.values
              .map(
                (s) => DSFilterOption(
                  value: s.label,
                  label: s.label,
                  icon: s.icon,
                  color: s.color,
                ),
              )
              .toList(),
          selected: activeSeverities.map((s) => s.label).toSet(),
          onToggle: (label) {
            final severity = DSLogSeverity.values.firstWhere(
              (s) => s.label == label,
            );
            onSeverityToggle?.call(severity);
          },
          showCount: false,
        ),

        // Source filters (only if sources available)
        if (availableSources.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.xs),
          DSFilterChipGroup(
            options: availableSources
                .map(
                  (src) => DSFilterOption(
                    value: src,
                    label: src,
                    color: DSColors.accentViolet,
                  ),
                )
                .toList(),
            selected: activeSources,
            onToggle: onSourceToggle,
            showCount: false,
          ),
        ],
      ],
    );
  }
}
