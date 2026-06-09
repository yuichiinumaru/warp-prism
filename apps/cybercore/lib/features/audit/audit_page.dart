import 'package:flutter/material.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';
import '../../data/fixtures/fixtures.dart';

/// CyberCore Audit route — audit trail timeline.
///
/// Displays changelog entries as a timeline using PrismTimeline
/// from warp_prism_ui. All data is loaded from fixtures.
class AuditPage extends StatefulWidget {
  const AuditPage({super.key});

  @override
  State<AuditPage> createState() => _AuditPageState();
}

class _AuditPageState extends State<AuditPage> {
  List<AuditEvent>? _events;
  bool _loading = true;
  String? _error;
  String? _filterType;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final events = await FixtureLoader.loadAuditTrail();
      if (mounted) {
        setState(() {
          _events = events;
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

  List<AuditEvent> get _filteredEvents {
    if (_events == null) return [];
    if (_filterType == null) return _events!;
    return _events!.where((e) => e.type == _filterType).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const PrismStateSurface.loading(
        title: 'Loading audit trail...',
        subtitle: 'Fetching audit events from fixtures',
      );
    }

    if (_error != null) {
      return PrismStateSurface.error(
        title: 'Failed to load audit trail',
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

    final filtered = _filteredEvents;

    return PrismErrorBoundary(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with type filter
          Padding(
            padding: const EdgeInsets.fromLTRB(
              DSSpacing.lg, DSSpacing.md, DSSpacing.lg, 0,
            ),
            child: Row(
              children: [
                const PrismText.headingMedium(
                  'Audit Trail',
                  color: DSColors.textPrimary,
                ),
                const SizedBox(width: DSSpacing.md),
                PrismBadge.count(
                  _events!.length,
                  color: DSColors.accentCyan,
                ),
                const Spacer(),
                const PrismText.bodySmall(
                  'Read-only — append-only timeline',
                  color: DSColors.textTertiary,
                ),
              ],
            ),
          ),

          // Type filter chips
          Padding(
            padding: const EdgeInsets.fromLTRB(
              DSSpacing.lg, DSSpacing.md, DSSpacing.lg, 0,
            ),
            child: PrismFilterChipGroup(
              options: _buildFilterOptions(),
              selected: _filterType != null ? {_filterType!} : {},
              onToggle: (value) {
                setState(() {
                  _filterType = _filterType == value ? null : value;
                });
              },
            ),
          ),

          // Timeline
          Expanded(
            child: PrismTimeline(
              entries: filtered.map((e) => PrismTimelineEntry(
                id: e.id,
                date: e.displayDate,
                title: e.body ?? '${e.type}: ${e.task}',
                type: e.type,
                project: e.project,
                taskId: e.task,
                impacts: e.skills,
              )).toList(),
              showFilters: false,
            ),
          ),
        ],
      ),
    );
  }

  List<PrismFilterOption> _buildFilterOptions() {
    final typeCounts = <String, int>{};
    for (final event in _events!) {
      typeCounts[event.type] = (typeCounts[event.type] ?? 0) + 1;
    }

    return typeCounts.entries.map((entry) {
      return PrismFilterOption(
        value: entry.key,
        label: entry.key,
        count: entry.value,
        color: _typeColor(entry.key),
      );
    }).toList();
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
