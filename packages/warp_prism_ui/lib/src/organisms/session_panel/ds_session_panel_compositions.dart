import 'package:flutter/material.dart';

import '../../atoms/atoms.dart';
import '../../molecules/ds_action_gate.dart';
import '../../molecules/molecules.dart';
import '../../tokens/ds_action_authority.dart';
import '../../tokens/tokens.dart';
import '../data_table/ds_data_table.dart';
import '../ds_detail_inspector.dart';
import '../ds_status_grid.dart';
import '../ds_timeline.dart';
import '../execution_console/execution_console.dart';
import '../log_viewer/log_viewer.dart';
import '../provider_health_matrix/provider_health_matrix.dart';
import '../split_pane/split_pane.dart';
import '../virtual_scroll/virtual_scroll.dart';

// =============================================================================
// SESSION / PANEL CONVERGENCE COMPOSITIONS (Task 1883, F-16 — EXPERIMENTAL)
// =============================================================================
//
// REUSE-only compositions over existing Prism vocabulary. No new table, list,
// grid, board, or tree primitive is declared here: SessionList/Detail compose
// [DSDataTable]/[DSVirtualList]/[DSStatusGrid]/[DSDetailInspector];
// EventStreamView composes [DSLogViewer]/[DSTimeline]/[DSExecutionConsole];
// Project/Media panels compose [DSPropertyRow] plus the mono pattern;
// Tempest screens compose [DSSearchBar]/[DSFilterChipGroup]/[DSAssetCard]/
// [DSStatusDot]/[DSMetricTile]/[DSStateSurface]/[DSSelect]/[DSAccordion];
// DropZoneCard lives in `ds_drop_zone_card.dart` ([DSDropZoneCard]) as the single
// authorized extension. Verification badges compose [DSStatusDot] +
// [DSBadge]; verification/probe metadata stays product-local and credentials
// never cross this seam.
//
// Lifecycle: EXPERIMENTAL. Intentionally NOT exported from any barrel and
// without `Prism*` aliases until a promotion task wires the public surface.
//
// Parent-bounded-height contract: [DSSessionListView], [DSEventStreamView],
// [DSSessionDetailView], and [DSTempestSeparateView] contain internally
// scrolling organisms ([DSDataTable], [DSLogViewer], [DSTimeline],
// [DSExecutionConsole], [DSDetailInspector], [DSVirtualList]) and therefore
// require a bounded height from the parent (see [DSExecutionConsole]: "Parent
// must provide a bounded height"). The remaining views size intrinsically and
// are safe inside unbounded scroll views.

// =============================================================================
// SESSION MODELS
// =============================================================================

/// Caller-owned session record projected onto Prism chrome.
///
/// The record carries presentation inputs only (labels, states, authority
/// outcomes). Session domain logic, probe metadata, and credentials stay
/// product-local.
@immutable
class DSSessionRecord {
  /// Stable session identity (rendered mono, never a credential).
  final String id;

  /// Human-readable session title.
  final String title;

  /// Current operational state.
  final DSOperationalState state;

  /// Pre-formatted update label (caller formats; no wall-clock here).
  final String updatedLabel;

  /// Whether the session carries verification proof.
  final bool verified;

  /// F-01 capability outcome for the primary open action.
  final DSActionAuthority authority;

  /// Reason accompanying [authority] (required unless [authority] is allow).
  final String? authorityReason;

  const DSSessionRecord({
    required this.id,
    required this.title,
    required this.state,
    required this.updatedLabel,
    this.verified = false,
    this.authority = DSActionAuthority.allow,
    this.authorityReason,
  });
}

/// Caller-owned Tempest library item projected onto Prism chrome.
@immutable
class DSTempestLibraryItem {
  /// Stable item identity.
  final String id;

  /// Display name.
  final String name;

  /// Asset kind label (drives [DSAssetCard] chrome).
  final String kind;

  /// Optional one-line description (kept short for grid cells).
  final String? description;

  /// Optional tag chips (kept to ≤2 for grid cells).
  final List<String>? tags;

  /// Filter bucket value (e.g. `loop`, `oneshot`, `stem`).
  final String filterValue;

  const DSTempestLibraryItem({
    required this.id,
    required this.name,
    required this.kind,
    this.description,
    this.tags,
    required this.filterValue,
  });
}

/// Caller-owned model metric projected onto [DSMetricTile].
@immutable
class DSTempestModelMetric {
  /// Metric label.
  final String label;

  /// Pre-formatted value (caller formats; no domain math here).
  final String value;

  /// Optional trend indicator.
  final DSTrend? trend;

  /// Optional health state (overrides accent when set).
  final DSMetricTileHealth? health;

  const DSTempestModelMetric({
    required this.label,
    required this.value,
    this.trend,
    this.health,
  });
}

// =============================================================================
// VERIFICATION BADGE (S8 chrome: DSStatusDot + DSBadge)
// =============================================================================

/// Verification badge chrome: [DSStatusDot.operational] + [DSBadge.operational].
///
/// Presentation only. Proof evaluation stays product-local; the caller maps
/// its verification outcome onto [state]. Never animated, so headless and
/// golden contexts stay deterministic.
class DSVerificationBadge extends StatelessWidget {
  /// Operational verification state to render.
  final DSOperationalState state;

  const DSVerificationBadge({super.key, required this.state});

  /// Convenience constructor from a boolean proof flag.
  ///
  /// `true` maps to [DSOperationalState.approved]; `false` maps to
  /// [DSOperationalState.unverified] (fail-closed, never success).
  const DSVerificationBadge.verified({super.key, bool verified = true})
    : state = verified
          ? DSOperationalState.approved
          : DSOperationalState.unverified;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Verification: ${state.label}',
      explicitChildNodes: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          DSStatusDot.operational(state, animated: false),
          const SizedBox(width: DSSpacing.xs),
          DSBadge.operational(state),
        ],
      ),
    );
  }
}

// =============================================================================
// SESSION LIST → DSDataTable (+ F-01-gated rows)
// =============================================================================

/// Session list composition over [DSDataTable].
///
/// Toolbar ([DSSearchBar] + [DSFilterChipGroup]) filters the caller-provided
/// [sessions]; state cells render [DSStatusCell]; verification cells render
/// [DSVerificationBadge]; the action column renders the F-01 capability gate
/// ([DSActionGate]) so denied rows stay visible with their reason and never
/// dispatch. Requires a bounded height from the parent.
class DSSessionListView extends StatefulWidget {
  /// Session records to display.
  final List<DSSessionRecord> sessions;

  /// Fired when an allowed row action dispatches.
  final ValueChanged<String>? onOpenSession;

  /// Fired when the table selection changes.
  final ValueChanged<Set<String>>? onSelectionChanged;

  /// Fired when a denied gate is tapped (terminal-for-dispatch refusal).
  final void Function(String sessionId, String reason)? onActionRefused;

  /// Region semantic label.
  final String semanticLabel;

  /// Rows per page.
  final int pageSize;

  /// Available page-size options forwarded to the table dropdown.
  ///
  /// Must contain [pageSize]; the default keeps the 5-row compact page used
  /// by session hosts alongside the standard table options.
  final List<int> pageSizes;

  const DSSessionListView({
    super.key,
    required this.sessions,
    this.onOpenSession,
    this.onSelectionChanged,
    this.onActionRefused,
    this.semanticLabel = 'Session list',
    this.pageSize = 5,
    this.pageSizes = const [5, 10, 25, 50],
  });

  @override
  State<DSSessionListView> createState() => _DSSessionListViewState();
}

class _DSSessionListViewState extends State<DSSessionListView> {
  String _query = '';
  final Set<String> _activeFilters = <String>{};
  int _page = 0;
  late int _pageSize;
  DSSortState? _sortState;

  @override
  void initState() {
    super.initState();
    _pageSize = widget.pageSize;
  }

  List<DSFilterOption> get _stateOptions {
    final counts = <DSOperationalState, int>{};
    for (final session in widget.sessions) {
      counts[session.state] = (counts[session.state] ?? 0) + 1;
    }
    final states = counts.keys.toList()
      ..sort((a, b) => a.index.compareTo(b.index));
    return <DSFilterOption>[
      for (final state in states)
        DSFilterOption(
          value: state.name,
          label: state.label,
          icon: state.icon,
          color: state.color,
          count: counts[state],
        ),
    ];
  }

  List<DSSessionRecord> get _filtered {
    final query = _query.trim().toLowerCase();
    final out = widget.sessions.where((session) {
      if (_activeFilters.isNotEmpty &&
          !_activeFilters.contains(session.state.name)) {
        return false;
      }
      if (query.isNotEmpty &&
          !session.title.toLowerCase().contains(query) &&
          !session.id.toLowerCase().contains(query)) {
        return false;
      }
      return true;
    }).toList();
    final sort = _sortState;
    if (sort != null) {
      int compare(DSSessionRecord a, DSSessionRecord b) {
        final left = sort.columnId == 'updated' ? a.updatedLabel : a.title;
        final right = sort.columnId == 'updated' ? b.updatedLabel : b.title;
        final result = left.compareTo(right);
        return sort.direction == DSSortDirection.ascending ? result : -result;
      }

      out.sort(compare);
    }
    return out;
  }

  void _onSort(String columnId) {
    setState(() {
      if (_sortState?.columnId == columnId) {
        _sortState = _sortState!.toggle();
      } else {
        _sortState = DSSortState(columnId: columnId);
      }
      _page = 0;
    });
  }

  DSActionGate _sessionGate(DSSessionRecord record) {
    switch (record.authority) {
      case DSActionAuthority.allow:
        return DSActionGate.allowed(
          actionLabel: 'Open',
          icon: Icons.open_in_new_outlined,
          onPressed: () => widget.onOpenSession?.call(record.id),
        );
      case DSActionAuthority.constrain:
        return DSActionGate.constrained(
          actionLabel: 'Open',
          reason: record.authorityReason ?? 'Limited by session policy',
          icon: Icons.open_in_new_outlined,
          onPressed: () => widget.onOpenSession?.call(record.id),
        );
      case DSActionAuthority.deny:
        return DSActionGate.denied(
          actionLabel: 'Open',
          reason: record.authorityReason ?? 'Session unavailable',
          onRefused: (reason) =>
              widget.onActionRefused?.call(record.id, reason),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessions = _filtered;
    final columns = <DSDataColumn>[
      const DSDataColumn(id: 'title', label: 'Session', sortable: true),
      DSDataColumn(
        id: 'state',
        label: 'State',
        cellRenderer: (context, value, _) =>
            DSStatusCell(state: value as DSOperationalState),
      ),
      DSDataColumn(
        id: 'updated',
        label: 'Updated',
        sortable: true,
        cellRenderer: (context, value, _) =>
            DSTimestampCell(timestamp: value as String? ?? ''),
      ),
      DSDataColumn(
        id: 'verified',
        label: 'Verified',
        cellRenderer: (context, value, _) => DSVerificationBadge.verified(
          verified: (value as DSSessionRecord).verified,
        ),
      ),
      DSDataColumn(
        id: 'action',
        label: 'Open',
        cellRenderer: (context, value, _) =>
            _sessionGate(value as DSSessionRecord),
      ),
    ];
    final rows = <DSDataRow>[
      for (final record in sessions)
        DSDataRow(
          id: record.id,
          cells: <String, dynamic>{
            'title': record.title,
            'state': record.state,
            'updated': record.updatedLabel,
            'verified': record,
            'action': record,
          },
          onTap: record.authority.mayDispatch
              ? () => widget.onOpenSession?.call(record.id)
              : null,
        ),
    ];

    return Semantics(
      label: widget.semanticLabel,
      explicitChildNodes: true,
      child: DSDataTable(
        columns: columns,
        rows: rows,
        sortState: _sortState,
        onSort: _onSort,
        selectable: true,
        onSelectionChanged: widget.onSelectionChanged,
        paginated: true,
        currentPage: _page,
        pageSize: _pageSize,
        pageSizes: widget.pageSizes,
        onPageChanged: (page) => setState(() => _page = page),
        onPageSizeChanged: (size) => setState(() {
          _pageSize = size;
          _page = 0;
        }),
        toolbar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DSSearchBar(
              placeholder: 'Search sessions...',
              value: _query,
              onChanged: (value) => setState(() {
                _query = value;
                _page = 0;
              }),
              onClear: () => setState(() {
                _query = '';
                _page = 0;
              }),
            ),
            const SizedBox(height: DSSpacing.xs),
            DSFilterChipGroup(
              options: _stateOptions,
              selected: _activeFilters,
              onToggle: (value) => setState(() {
                if (_activeFilters.contains(value)) {
                  _activeFilters.remove(value);
                } else {
                  _activeFilters.add(value);
                }
                _page = 0;
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// SESSION DETAIL → DSDetailInspector + DSPropertyRow + mono pattern
// =============================================================================

/// Session detail composition over [DSDetailInspector].
///
/// Overview section renders [DSPropertyRow] chrome; technical identities
/// render through the mono pattern ([DSTextVariant.codeSmall] in inspector
/// row metrics); verification renders [DSVerificationBadge]. Requires a
/// bounded height from the parent (inspector body scrolls).
class DSSessionDetailView extends StatelessWidget {
  /// Session under inspection.
  final DSSessionRecord session;

  /// Human-readable extra fields (label → value, insertion-ordered).
  final Map<String, String> properties;

  /// Technical extra fields rendered mono (label → value, insertion-ordered).
  final Map<String, String> monoProperties;

  /// Called when the inspector close affordance activates.
  final VoidCallback? onClose;

  const DSSessionDetailView({
    super.key,
    required this.session,
    this.properties = const <String, String>{},
    this.monoProperties = const <String, String>{},
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return DSDetailInspector(
      title: session.title,
      kind: 'session',
      subtitle: session.state.label,
      onClose: onClose,
      sections: <DSDetailSection>[
        DSDetailSection(
          title: 'Overview',
          icon: Icons.info_outlined,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DSPropertyRow(
                label: 'State',
                value: session.state.label,
                valueColor: session.state.color,
                trailing: DSStatusDot.operational(
                  session.state,
                  animated: false,
                ),
              ),
              DSPropertyRow(label: 'Updated', value: session.updatedLabel),
              _monoPropertyRow('Session ID', session.id),
              for (final entry in properties.entries)
                DSPropertyRow(label: entry.key, value: entry.value),
              for (final entry in monoProperties.entries)
                _monoPropertyRow(entry.key, entry.value),
            ],
          ),
        ),
        DSDetailSection(
          title: 'Verification',
          icon: Icons.verified_outlined,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DSVerificationBadge.verified(verified: session.verified),
              const SizedBox(height: DSSpacing.xs),
              DSText.bodySmall(
                session.verified
                    ? 'Verified in session scope.'
                    : 'Unverified — no proof yet.',
                color: DSColors.textTertiary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Mono-pattern inspector row: inspector row metrics with a
  /// [DSTextVariant.codeSmall] value for technical identities.
  Widget _monoPropertyRow(String label, String value) {
    return Semantics(
      label: '$label: $value',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: DSSpacing.xs),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 100,
              child: DSText.labelSmall(label, color: DSColors.textTertiary),
            ),
            Expanded(
              child: DSText(
                value,
                variant: DSTextVariant.codeSmall,
                color: DSColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// EVENT STREAM → DSLogViewer + DSTimeline + DSExecutionConsole
// =============================================================================

/// Event-stream composition: log viewer, timeline, and execution console as
/// [DSAccordion] sections. Requires a bounded height from the parent; each
/// section carries its own fixed viewport.
class DSEventStreamView extends StatelessWidget {
  /// Log entries for the stream section.
  final List<DSLogEntry> logEntries;

  /// Timeline entries for the history section.
  final List<DSTimelineEntry> timelineEntries;

  /// Console fixture lines for the execution section.
  final List<DSExecutionLine> consoleLines;

  /// Console run groups for sticky headers.
  final List<DSExecutionRunGroup> consoleGroups;

  /// Fired when a log entry expands.
  final ValueChanged<String>? onLogTap;

  /// Fired when a timeline entry activates.
  final ValueChanged<String>? onTimelineTap;

  /// Fired when a console run group is selected.
  final ValueChanged<String?>? onRunGroupSelected;

  /// Fixed viewport heights per section.
  final double logHeight;
  final double timelineHeight;
  final double consoleHeight;

  const DSEventStreamView({
    super.key,
    this.logEntries = const <DSLogEntry>[],
    this.timelineEntries = const <DSTimelineEntry>[],
    this.consoleLines = const <DSExecutionLine>[],
    this.consoleGroups = const <DSExecutionRunGroup>[],
    this.onLogTap,
    this.onTimelineTap,
    this.onRunGroupSelected,
    this.logHeight = 280.0,
    this.timelineHeight = 300.0,
    this.consoleHeight = 320.0,
  });

  @override
  Widget build(BuildContext context) {
    return DSAccordion(
      multiExpand: true,
      semanticLabel: 'Event stream',
      items: <DSAccordionItem>[
        DSAccordionItem(
          id: 'log',
          title: 'Log stream',
          subtitle: '${logEntries.length} entries',
          icon: Icons.list_alt_outlined,
          defaultOpen: true,
          content: SizedBox(
            height: logHeight,
            child: DSLogViewer(
              entries: logEntries,
              onEntryTap: onLogTap,
              autoScroll: false,
            ),
          ),
        ),
        DSAccordionItem(
          id: 'timeline',
          title: 'Timeline',
          subtitle: '${timelineEntries.length} entries',
          icon: Icons.history_outlined,
          content: SizedBox(
            height: timelineHeight,
            child: DSTimeline(
              entries: timelineEntries,
              showFilters: false,
              onEntryTap: onTimelineTap,
            ),
          ),
        ),
        DSAccordionItem(
          id: 'console',
          title: 'Execution console',
          subtitle: '${consoleLines.length} lines',
          icon: Icons.terminal_outlined,
          content: SizedBox(
            height: consoleHeight,
            child: DSExecutionConsole(
              lines: consoleLines,
              runGroups: consoleGroups,
              showOutputPanel: false,
              autoScroll: false,
              onRunGroupSelected: onRunGroupSelected,
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// PROJECT PANEL → DSPropertyRow + mono pattern
// =============================================================================

/// Project panel composition over [DSDetailInspector] + [DSPropertyRow].
///
/// Loading/error states render [DSStateSurface] chrome; data renders the
/// inspector with property rows and [DSVerificationBadge]. Requires a bounded
/// height from the parent.
class DSProjectPanelView extends StatelessWidget {
  /// Panel title.
  final String title;

  /// Asset kind label (default `project`).
  final String kind;

  /// Human-readable fields (label → value, insertion-ordered).
  final Map<String, String> properties;

  /// Technical fields rendered mono (label → value, insertion-ordered).
  final Map<String, String> monoProperties;

  /// Aggregate operational state.
  final DSOperationalState state;

  /// Whether verification proof is present.
  final bool verified;

  /// Loading flag (renders [DSStateSurface.loading]).
  final bool isLoading;

  /// Error detail (renders [DSStateSurface.error] when non-null).
  final String? errorMessage;

  /// Retry callback for the error state.
  final VoidCallback? onRetry;

  /// Close callback for the inspector.
  final VoidCallback? onClose;

  const DSProjectPanelView({
    super.key,
    required this.title,
    this.kind = 'project',
    this.properties = const <String, String>{},
    this.monoProperties = const <String, String>{},
    this.state = DSOperationalState.healthy,
    this.verified = false,
    this.isLoading = false,
    this.errorMessage,
    this.onRetry,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return DSStateSurface.loading(title: 'Loading $title...');
    }
    if (errorMessage != null) {
      return DSStateSurface.error(
        title: 'Failed to load $title',
        subtitle: errorMessage,
        onAction: onRetry,
      );
    }
    return DSDetailInspector(
      title: title,
      kind: kind,
      subtitle: state.label,
      onClose: onClose,
      sections: <DSDetailSection>[
        DSDetailSection(
          title: 'Properties',
          icon: Icons.info_outlined,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DSPropertyRow(
                label: 'State',
                value: state.label,
                valueColor: state.color,
                trailing: DSStatusDot.operational(state, animated: false),
              ),
              for (final entry in properties.entries)
                DSPropertyRow(label: entry.key, value: entry.value),
              for (final entry in monoProperties.entries)
                _monoPropertyRow(entry.key, entry.value),
            ],
          ),
        ),
        DSDetailSection(
          title: 'Verification',
          icon: Icons.verified_outlined,
          child: DSVerificationBadge.verified(verified: verified),
        ),
      ],
    );
  }

  Widget _monoPropertyRow(String label, String value) {
    return Semantics(
      label: '$label: $value',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: DSSpacing.xs),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 100,
              child: DSText.labelSmall(label, color: DSColors.textTertiary),
            ),
            Expanded(
              child: DSText(
                value,
                variant: DSTextVariant.codeSmall,
                color: DSColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// MEDIA PANEL → DSAssetCard + DSPropertyRow + mono pattern
// =============================================================================

/// Media panel composition: [DSAssetCard] header, [DSPropertyRow] fields, and
/// [DSVerificationBadge]. Sizes intrinsically; safe in unbounded scroll views.
class DSMediaPanelView extends StatelessWidget {
  /// Asset display name.
  final String assetName;

  /// Asset kind label.
  final String assetKind;

  /// Optional one-line description.
  final String? description;

  /// Optional tag chips.
  final List<String>? tags;

  /// Human-readable fields (label → value, insertion-ordered).
  final Map<String, String> properties;

  /// Verification state for the badge row.
  final DSOperationalState verificationState;

  /// Whether the header card renders selected.
  final bool selected;

  /// Fired when the header card activates.
  final VoidCallback? onOpen;

  const DSMediaPanelView({
    super.key,
    required this.assetName,
    required this.assetKind,
    this.description,
    this.tags,
    this.properties = const <String, String>{},
    this.verificationState = DSOperationalState.unverified,
    this.selected = false,
    this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Media panel: $assetName',
      explicitChildNodes: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DSAssetCard(
            name: assetName,
            kind: assetKind,
            description: description,
            tags: tags,
            selected: selected,
            onTap: onOpen,
          ),
          const SizedBox(height: DSSpacing.sm),
          for (final entry in properties.entries)
            DSPropertyRow(label: entry.key, value: entry.value),
          const SizedBox(height: DSSpacing.xs),
          DSVerificationBadge(state: verificationState),
        ],
      ),
    );
  }
}

// =============================================================================
// TEMPEST LIBRARY → DSSearchBar + DSFilterChipGroup + DSAssetCard grid
// =============================================================================

/// Tempest Library screen composition: search, preset chips, and an asset
/// grid over [DSVirtualGrid]. Sizes intrinsically (`shrinkWrap`); safe in
/// unbounded scroll views.
class DSTempestLibraryView extends StatefulWidget {
  /// Library items to display.
  final List<DSTempestLibraryItem> items;

  /// Currently selected item id.
  final String? selectedId;

  /// Fired when an asset card activates.
  final ValueChanged<String>? onSelected;

  /// Region semantic label.
  final String semanticLabel;

  const DSTempestLibraryView({
    super.key,
    required this.items,
    this.selectedId,
    this.onSelected,
    this.semanticLabel = 'Library',
  });

  @override
  State<DSTempestLibraryView> createState() => _DSTempestLibraryViewState();
}

class _DSTempestLibraryViewState extends State<DSTempestLibraryView> {
  String _query = '';
  final Set<String> _activeFilters = <String>{};

  List<DSFilterOption> get _filterOptions {
    final counts = <String, int>{};
    for (final item in widget.items) {
      counts[item.filterValue] = (counts[item.filterValue] ?? 0) + 1;
    }
    final values = counts.keys.toList()..sort();
    return <DSFilterOption>[
      for (final value in values)
        DSFilterOption(label: value, value: value, count: counts[value]),
    ];
  }

  List<DSTempestLibraryItem> get _filtered {
    final query = _query.trim().toLowerCase();
    return widget.items.where((item) {
      if (_activeFilters.isNotEmpty &&
          !_activeFilters.contains(item.filterValue)) {
        return false;
      }
      if (query.isNotEmpty &&
          !item.name.toLowerCase().contains(query) &&
          !item.kind.toLowerCase().contains(query)) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;
    return Semantics(
      label: widget.semanticLabel,
      explicitChildNodes: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DSSearchBar(
            placeholder: 'Search library...',
            value: _query,
            onChanged: (value) => setState(() => _query = value),
            onClear: () => setState(() => _query = ''),
          ),
          const SizedBox(height: DSSpacing.sm),
          DSFilterChipGroup(
            options: _filterOptions,
            selected: _activeFilters,
            onToggle: (value) => setState(() {
              if (_activeFilters.contains(value)) {
                _activeFilters.remove(value);
              } else {
                _activeFilters.add(value);
              }
            }),
          ),
          const SizedBox(height: DSSpacing.sm),
          if (items.isEmpty)
            DSStateSurface.empty(
              title: 'No results',
              subtitle: _query.isNotEmpty || _activeFilters.isNotEmpty
                  ? 'Try adjusting search or filters'
                  : 'Library items will appear here',
              compact: true,
            )
          else
            DSVirtualGrid(
              itemCount: items.length,
              crossAxisCount: 2,
              childAspectRatio: 1.6,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              semanticLabel: 'Library results: ${items.length} items',
              itemBuilder: (context, index) {
                final item = items[index];
                return DSAssetCard(
                  name: item.name,
                  kind: item.kind,
                  description: item.description,
                  tags: item.tags,
                  selected: item.id == widget.selectedId,
                  onTap: () => widget.onSelected?.call(item.id),
                );
              },
            ),
        ],
      ),
    );
  }
}

// =============================================================================
// TEMPEST MODELS → DSMetricTile + DSProviderHealthMatrix
// =============================================================================

/// Tempest Models screen composition: metric tiles plus the provider health
/// matrix. Sizes intrinsically; safe in unbounded scroll views. Credentials
/// and live provider pings stay product-local (fixture cells only).
class DSTempestModelsView extends StatelessWidget {
  /// Metric tiles above the matrix.
  final List<DSTempestModelMetric> metrics;

  /// Provider rows for the matrix.
  final List<DSProviderHealthProvider> providers;

  /// Currently selected cell id.
  final String? selectedCellId;

  /// Fired when a matrix cell activates.
  final ValueChanged<DSProviderHealthCell>? onCellSelected;

  /// Region semantic label.
  final String semanticLabel;

  const DSTempestModelsView({
    super.key,
    this.metrics = const <DSTempestModelMetric>[],
    required this.providers,
    this.selectedCellId,
    this.onCellSelected,
    this.semanticLabel = 'Models',
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      explicitChildNodes: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (metrics.isNotEmpty) ...[
            Wrap(
              spacing: DSSpacing.sm,
              runSpacing: DSSpacing.sm,
              children: [
                for (final metric in metrics)
                  DSMetricTile(
                    label: metric.label,
                    value: metric.value,
                    trend: metric.trend,
                    health: metric.health,
                  ),
              ],
            ),
            const SizedBox(height: DSSpacing.md),
          ],
          DSProviderHealthMatrix(
            providers: providers,
            selectedCellId: selectedCellId,
            onCellSelected: onCellSelected,
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// TEMPEST PROVIDERS → DSProviderHealthMatrix + DSStatusGrid
// =============================================================================

/// Tempest Providers screen composition: provider health matrix plus the
/// flat service status grid (embed mode, so the view sizes intrinsically).
class DSTempestProvidersView extends StatelessWidget {
  /// Provider rows for the matrix.
  final List<DSProviderHealthProvider> providers;

  /// Flat service states for the status grid.
  final List<DSHealthCardData> services;

  /// Active grid filter (null/empty = show all).
  final Set<DSOperationalState>? activeFilter;

  /// Fired when a grid filter chip toggles.
  final ValueChanged<DSOperationalState>? onFilterToggle;

  /// Fired when a service card activates.
  final ValueChanged<DSHealthCardData>? onServiceTap;

  /// Fired when a matrix cell activates.
  final ValueChanged<DSProviderHealthCell>? onCellSelected;

  /// Region semantic label.
  final String semanticLabel;

  const DSTempestProvidersView({
    super.key,
    required this.providers,
    this.services = const <DSHealthCardData>[],
    this.activeFilter,
    this.onFilterToggle,
    this.onServiceTap,
    this.onCellSelected,
    this.semanticLabel = 'Providers',
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      explicitChildNodes: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DSProviderHealthMatrix(
            providers: providers,
            onCellSelected: onCellSelected,
          ),
          const SizedBox(height: DSSpacing.md),
          DSStatusGrid(
            items: services,
            activeFilter: activeFilter,
            showFilterBar: true,
            onFilterToggle: onFilterToggle,
            onItemTap: onServiceTap,
            embedInScrollView: true,
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// TEMPEST SETTINGS → DSSelect + DSAccordion + DSStateSurface
// =============================================================================

/// Tempest Settings screen composition: profile select plus accordion
/// sections. Sizes intrinsically; safe in unbounded scroll views.
class DSTempestSettingsView extends StatelessWidget {
  /// Profile options for the select.
  final List<DSSelectItem<String>> profileOptions;

  /// Currently selected profile value.
  final String? profileValue;

  /// Fired when the profile changes.
  final ValueChanged<String?>? onProfileChanged;

  /// Accordion sections for grouped settings.
  final List<DSAccordionItem> sections;

  /// Region semantic label.
  final String semanticLabel;

  const DSTempestSettingsView({
    super.key,
    required this.profileOptions,
    this.profileValue,
    this.onProfileChanged,
    this.sections = const <DSAccordionItem>[],
    this.semanticLabel = 'Settings',
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      explicitChildNodes: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DSSelect<String>(
            label: 'Profile',
            value: profileValue,
            options: profileOptions,
            onChanged: onProfileChanged,
            helperText: 'Applies when applied by the host.',
            semanticsLabel: 'Settings profile',
          ),
          const SizedBox(height: DSSpacing.md),
          DSAccordion(
            items: sections,
            multiExpand: true,
            semanticLabel: 'Settings sections',
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// TEMPEST SEPARATE → DSFilterChipGroup + DSVirtualList of DSAssetCard
// =============================================================================

/// Tempest Separate screen composition: filter chips plus a virtualized stem
/// list. The list viewport is self-bounded ([listHeight]); no energy bar is
/// rendered here (P2 exclusion holds).
class DSTempestSeparateView extends StatefulWidget {
  /// Stem items to display.
  final List<DSTempestLibraryItem> stems;

  /// Currently selected stem id.
  final String? selectedId;

  /// Fired when a stem card activates.
  final ValueChanged<String>? onSelected;

  /// Self-bounded list viewport height.
  final double listHeight;

  /// Region semantic label.
  final String semanticLabel;

  const DSTempestSeparateView({
    super.key,
    required this.stems,
    this.selectedId,
    this.onSelected,
    this.listHeight = 360.0,
    this.semanticLabel = 'Separate',
  });

  @override
  State<DSTempestSeparateView> createState() => _DSTempestSeparateViewState();
}

class _DSTempestSeparateViewState extends State<DSTempestSeparateView> {
  final Set<String> _activeFilters = <String>{};

  List<DSFilterOption> get _filterOptions {
    final counts = <String, int>{};
    for (final stem in widget.stems) {
      counts[stem.filterValue] = (counts[stem.filterValue] ?? 0) + 1;
    }
    final values = counts.keys.toList()..sort();
    return <DSFilterOption>[
      for (final value in values)
        DSFilterOption(label: value, value: value, count: counts[value]),
    ];
  }

  List<DSTempestLibraryItem> get _filtered {
    return widget.stems.where((stem) {
      if (_activeFilters.isNotEmpty &&
          !_activeFilters.contains(stem.filterValue)) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final stems = _filtered;
    return Semantics(
      label: widget.semanticLabel,
      explicitChildNodes: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DSFilterChipGroup(
            options: _filterOptions,
            selected: _activeFilters,
            onToggle: (value) => setState(() {
              if (_activeFilters.contains(value)) {
                _activeFilters.remove(value);
              } else {
                _activeFilters.add(value);
              }
            }),
          ),
          const SizedBox(height: DSSpacing.sm),
          if (stems.isEmpty)
            const DSStateSurface.empty(
              title: 'No stems',
              subtitle: 'Stems will appear here after separation',
              compact: true,
            )
          else
            SizedBox(
              height: widget.listHeight,
              child: DSVirtualList(
                itemCount: stems.length,
                semanticLabel: 'Stems: ${stems.length} items',
                itemBuilder: (context, index) {
                  final stem = stems[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: DSSpacing.sm),
                    child: DSAssetCard(
                      name: stem.name,
                      kind: stem.kind,
                      description: stem.description,
                      tags: stem.tags,
                      selected: stem.id == widget.selectedId,
                      onTap: () => widget.onSelected?.call(stem.id),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

// =============================================================================
// TEMPEST CREATE → DSSearchBar + DSSelect + DSAccordion (+ F-01 gate)
// =============================================================================

/// Tempest Create screen composition: search, template select, option
/// accordion, and the F-01-gated create action. Sizes intrinsically; safe in
/// unbounded scroll views.
class DSTempestCreateView extends StatelessWidget {
  /// Template options for the select.
  final List<DSSelectItem<String>> templateOptions;

  /// Currently selected template value.
  final String? templateValue;

  /// Fired when the template changes.
  final ValueChanged<String?>? onTemplateChanged;

  /// Accordion sections for creation options.
  final List<DSAccordionItem> sections;

  /// Fired as the search query changes.
  final ValueChanged<String>? onSearchChanged;

  /// F-01 authority for the create action.
  final DSActionAuthority createAuthority;

  /// Reason accompanying [createAuthority] (required unless allow).
  final String? createReason;

  /// Fired when the gated create action dispatches.
  final VoidCallback? onCreate;

  /// Fired when a denied create gate is tapped.
  final ValueChanged<String>? onCreateRefused;

  /// Region semantic label.
  final String semanticLabel;

  const DSTempestCreateView({
    super.key,
    required this.templateOptions,
    this.templateValue,
    this.onTemplateChanged,
    this.sections = const <DSAccordionItem>[],
    this.onSearchChanged,
    this.createAuthority = DSActionAuthority.allow,
    this.createReason,
    this.onCreate,
    this.onCreateRefused,
    this.semanticLabel = 'Create',
  });

  DSActionGate get _createGate {
    switch (createAuthority) {
      case DSActionAuthority.allow:
        return DSActionGate.allowed(
          actionLabel: 'Create',
          icon: Icons.add_outlined,
          onPressed: onCreate,
        );
      case DSActionAuthority.constrain:
        return DSActionGate.constrained(
          actionLabel: 'Create',
          reason: createReason ?? 'Limited by creation policy',
          icon: Icons.add_outlined,
          onPressed: onCreate,
        );
      case DSActionAuthority.deny:
        return DSActionGate.denied(
          actionLabel: 'Create',
          reason: createReason ?? 'Creation unavailable',
          onRefused: onCreateRefused,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      explicitChildNodes: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DSSearchBar(
            placeholder: 'Describe what to create...',
            showFilter: false,
            onChanged: onSearchChanged,
          ),
          const SizedBox(height: DSSpacing.sm),
          DSSelect<String>(
            label: 'Template',
            value: templateValue,
            options: templateOptions,
            onChanged: onTemplateChanged,
            semanticsLabel: 'Creation template',
          ),
          const SizedBox(height: DSSpacing.sm),
          DSAccordion(
            items: sections,
            multiExpand: true,
            semanticLabel: 'Creation options',
          ),
          const SizedBox(height: DSSpacing.md),
          _createGate,
        ],
      ),
    );
  }
}

// =============================================================================
// COMMAND-CENTER MULTIPANE HOST SHAPE (sessions + event stream)
// =============================================================================

/// Command-center multipane host shape: session list beside the event stream.
///
/// Proof-lab composition for the CC W-A/W-B sessions + event-stream surface
/// (AGENTS.md §7.1 host exercise). Requires a bounded size from the parent;
/// panes resize through [DSSplitPane].
class DSSessionEventSplitHost extends StatelessWidget {
  /// Session records for the leading pane.
  final List<DSSessionRecord> sessions;

  /// Log entries for the trailing event stream.
  final List<DSLogEntry> logEntries;

  /// Timeline entries for the trailing event stream.
  final List<DSTimelineEntry> timelineEntries;

  /// Console fixture lines for the trailing event stream.
  final List<DSExecutionLine> consoleLines;

  /// Fired when a session row opens.
  final ValueChanged<String>? onOpenSession;

  /// Initial split ratio (0–1).
  final double initialRatio;

  /// Region semantic label.
  final String semanticLabel;

  const DSSessionEventSplitHost({
    super.key,
    required this.sessions,
    this.logEntries = const <DSLogEntry>[],
    this.timelineEntries = const <DSTimelineEntry>[],
    this.consoleLines = const <DSExecutionLine>[],
    this.onOpenSession,
    this.initialRatio = 0.42,
    this.semanticLabel = 'Sessions and event stream',
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      explicitChildNodes: true,
      child: DSSplitPane(
        initialRatio: initialRatio,
        leading: DSSessionListView(
          sessions: sessions,
          onOpenSession: onOpenSession,
          semanticLabel: 'Host session list',
        ),
        trailing: DSEventStreamView(
          logEntries: logEntries,
          timelineEntries: timelineEntries,
          consoleLines: consoleLines,
        ),
      ),
    );
  }
}
