import 'package:flutter/material.dart';
import '../../tokens/tokens.dart';
import '../../atoms/atoms.dart';
import '../../molecules/molecules.dart';
import 'ds_log_entry_model.dart';
import 'ds_log_entry_widget.dart';
import 'ds_log_filter_bar.dart';
import 'ds_log_severity.dart';

/// ASW Observatory Organism — Log Viewer
///
/// Scrollable, filterable, searchable log/event streaming viewer.
///
/// Features:
/// - Severity coloring (debug / info / warning / error / critical)
/// - Source filtering (by component, agent, task)
/// - Text search within log messages
/// - Auto-scroll to latest entry with pause on manual scroll-up
/// - Expandable entries for stack traces and metadata
/// - Virtualized rendering via [ListView.builder] for 10K+ entries
///
/// Usage:
/// ```dart
/// DSLogViewer(
///   entries: logEntries,
///   onEntryTap: (id) => print('Tapped $id'),
/// )
/// ```
class DSLogViewer extends StatefulWidget {
  /// All log entries to display (unfiltered).
  final List<DSLogEntry> entries;

  /// Callback when a log entry is tapped.
  final ValueChanged<String>? onEntryTap;

  /// Whether to show the filter bar.
  final bool showFilters;

  /// Whether to auto-scroll to the latest entry.
  final bool autoScroll;

  /// Show absolute timestamps instead of HH:mm:ss.
  final bool showAbsoluteTime;

  const DSLogViewer({
    super.key,
    required this.entries,
    this.onEntryTap,
    this.showFilters = true,
    this.autoScroll = true,
    this.showAbsoluteTime = false,
  });

  @override
  State<DSLogViewer> createState() => _DSLogViewerState();
}

class _DSLogViewerState extends State<DSLogViewer> {
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';
  final Set<DSLogSeverity> _activeSeverities = {};
  final Set<String> _activeSources = {};
  final Set<String> _expandedIds = {};
  bool _autoScroll = true;
  bool _userScrolledUp = false;

  /// Suppresses pause-on-scroll while we programmatically jump/animate to bottom.
  bool _programmaticScroll = false;

  @override
  void initState() {
    super.initState();
    _autoScroll = widget.autoScroll;
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_programmaticScroll) return;

    final position = _scrollController.position;
    // If user scrolls up from the bottom, pause auto-scroll.
    if (position.pixels < position.maxScrollExtent - 20) {
      if (!_userScrolledUp && _autoScroll) {
        setState(() {
          _userScrolledUp = true;
          _autoScroll = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _programmaticScroll = true;
    _scrollController
        .animateTo(
          _scrollController.position.maxScrollExtent,
          duration: DSMotion.normal,
          curve: DSMotion.enter,
        )
        .whenComplete(() {
          _programmaticScroll = false;
        });
  }

  void _resumeAutoScroll() {
    setState(() {
      _autoScroll = true;
      _userScrolledUp = false;
    });
    _scrollToBottom();
  }

  List<DSLogEntry> get _filteredEntries {
    return widget.entries.where((entry) {
      // Severity filter
      if (_activeSeverities.isNotEmpty &&
          !_activeSeverities.contains(entry.severity)) {
        return false;
      }
      // Source filter
      if (_activeSources.isNotEmpty && !_activeSources.contains(entry.source)) {
        return false;
      }
      // Text search
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return entry.message.toLowerCase().contains(query) ||
            entry.source.toLowerCase().contains(query) ||
            entry.severity.label.toLowerCase().contains(query) ||
            (entry.detail?.toLowerCase().contains(query) ?? false);
      }
      return true;
    }).toList();
  }

  List<String> get _availableSources {
    return widget.entries.map((e) => e.source).toSet().toList()..sort();
  }

  @override
  void didUpdateWidget(DSLogViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Auto-scroll when new entries arrive and auto-scroll is enabled.
    if (_autoScroll && widget.entries.length > oldWidget.entries.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredEntries;

    return Semantics(
      label: 'Log viewer showing ${filtered.length} entries',
      explicitChildNodes: true,
      child: Column(
        children: [
          // Filter bar
          if (widget.showFilters) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                DSSpacing.lg,
                DSSpacing.sm,
                DSSpacing.lg,
                0,
              ),
              child: DSLogFilterBar(
                searchQuery: _searchQuery,
                onSearchChanged: (q) => setState(() => _searchQuery = q),
                activeSeverities: _activeSeverities,
                onSeverityToggle: (s) {
                  setState(() {
                    if (_activeSeverities.contains(s)) {
                      _activeSeverities.remove(s);
                    } else {
                      _activeSeverities.add(s);
                    }
                  });
                },
                availableSources: _availableSources,
                activeSources: _activeSources,
                onSourceToggle: (src) {
                  setState(() {
                    if (_activeSources.contains(src)) {
                      _activeSources.remove(src);
                    } else {
                      _activeSources.add(src);
                    }
                  });
                },
              ),
            ),
            const SizedBox(height: DSSpacing.sm),
            const DSDivider.subtle(),
          ],

          // Log count + auto-scroll controls
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: DSSpacing.lg,
              vertical: DSSpacing.xs,
            ),
            child: Row(
              children: [
                DSText.labelSmall(
                  '${filtered.length} / ${widget.entries.length} entries',
                  color: DSColors.textTertiary,
                ),
                const Spacer(),
                if (_userScrolledUp)
                  Semantics(
                    label: 'Resume auto-scroll to latest',
                    button: true,
                    enabled: true,
                    child: Material(
                      type: MaterialType.transparency,
                      child: InkWell(
                        onTap: _resumeAutoScroll,
                        borderRadius: BorderRadius.circular(DSRadii.chip),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            minWidth: kMinInteractiveDimension,
                            minHeight: kMinInteractiveDimension,
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(
                              horizontal: DSSpacing.sm,
                            ),
                            decoration: BoxDecoration(
                              color: DSColors.accentBlue.withValues(
                                alpha: 0.15,
                              ),
                              borderRadius: BorderRadius.circular(DSRadii.chip),
                              border: Border.all(color: DSColors.focusRing),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ExcludeSemantics(
                                  child: DSIcon.small(
                                    DSIcons.expand,
                                    color: DSColors.accentBlue,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                DSText.labelSmall(
                                  'Latest',
                                  color: DSColors.accentBlue,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Log entries
          Expanded(
            child: filtered.isEmpty
                ? DSStateSurface.empty(
                    icon: DSIcons.list,
                    title: 'No log entries',
                    subtitle:
                        _searchQuery.isNotEmpty ||
                            _activeSeverities.isNotEmpty ||
                            _activeSources.isNotEmpty
                        ? 'Try adjusting filters'
                        : 'Logs will appear here as they are recorded',
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(bottom: DSSpacing.lg),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final entry = filtered[index];
                      final isExpanded = _expandedIds.contains(entry.id);
                      return DSLogEntryWidget(
                        entry: entry,
                        expanded: isExpanded,
                        showAbsoluteTime: widget.showAbsoluteTime,
                        onToggleExpand: () {
                          setState(() {
                            if (isExpanded) {
                              _expandedIds.remove(entry.id);
                            } else {
                              _expandedIds.add(entry.id);
                            }
                          });
                          widget.onEntryTap?.call(entry.id);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
