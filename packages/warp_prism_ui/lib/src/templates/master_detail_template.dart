/// Master-detail template for workspace pages
/// Used by Map, Operate, History, and Governance workspaces.
///
/// Responsive behavior (uses DSBreakpoints):
///   >= 1200px: side-by-side master and detail
///   800-1199px: master with overlay detail
///   < 800px: full-screen detail (replaces master)
library;

import 'package:flutter/material.dart';
import '../molecules/molecules.dart';
import '../atoms/atoms.dart';
import '../tokens/tokens.dart';
import '../organisms/organisms.dart';

/// A template that provides master-detail layout with sidebar.
///
/// Responsive detail behavior:
///   >= 1200px: side-by-side split pane (master left, detail right)
///   800-1199px: overlay drawer from right with scrim and close
///   < 800px: full-screen detail with back navigation in AppBar
///
/// Close/back contract:
///   - [onDetailClose] is called on every breakpoint when the user
///     dismisses the detail (close button, scrim tap, back arrow).
///   - Consumer surfaces must update their selection state in response.
class MasterDetailTemplate extends StatefulWidget {
  /// The sidebar navigation items
  final List<DSSidebarItem> sidebarItems;

  /// Currently selected sidebar item index
  final int selectedIndex;

  /// Callback when sidebar item is selected
  final void Function(int) onSidebarItemSelected;

  /// The title shown in the topbar
  final String title;

  /// Optional search query
  final String? searchQuery;

  /// Callback when search changes
  final void Function(String)? onSearchChanged;

  /// Optional filter chips
  final List<String>? filters;

  /// Currently selected filters
  final Set<String>? selectedFilters;

  /// Callback when filter selection changes
  final void Function(Set<String>)? onFiltersChanged;

  /// The master panel content (list/grid/graph)
  final Widget masterContent;

  /// The detail panel content (inspector)
  final Widget? detailContent;

  /// Whether to show the detail panel
  final bool showDetail;

  /// Optional breadcrumbs
  final List<String>? breadcrumbs;

  /// Optional actions for the topbar
  final List<Widget>? actions;

  /// Called when the detail panel should close (close button, scrim tap,
  /// back arrow). Consumer surfaces use this to clear selection state.
  final VoidCallback? onDetailClose;

  /// Optional title for the detail panel (shown in narrow-mode AppBar).
  final String? detailTitle;

  /// Optional kind label for the detail panel (shown in narrow-mode AppBar).
  final String? detailKind;

  const MasterDetailTemplate({
    super.key,
    required this.sidebarItems,
    required this.selectedIndex,
    required this.onSidebarItemSelected,
    required this.title,
    this.searchQuery,
    this.onSearchChanged,
    this.filters,
    this.selectedFilters,
    this.onFiltersChanged,
    required this.masterContent,
    this.detailContent,
    this.showDetail = false,
    this.breadcrumbs,
    this.actions,
    this.onDetailClose,
    this.detailTitle,
    this.detailKind,
  });

  @override
  State<MasterDetailTemplate> createState() => _MasterDetailTemplateState();
}

class _MasterDetailTemplateState extends State<MasterDetailTemplate> {
  @override
  Widget build(BuildContext context) {
    return DSShell(
      sidebar: DSSidebar(
        items: widget.sidebarItems,
        selectedId: widget.sidebarItems[widget.selectedIndex].id,
        expanded: true,
        onItemTap: (id) {
          final index = widget.sidebarItems.indexWhere((item) => item.id == id);
          if (index != -1) {
            widget.onSidebarItemSelected(index);
          }
        },
      ),
      topbar: DSTopbar(
        title: widget.title,
        breadcrumbs: widget.breadcrumbs,
        showSearch: widget.onSearchChanged != null,
        searchBar: widget.onSearchChanged == null
            ? null
            : DSSearchBar(
                value: widget.searchQuery,
                onChanged: widget.onSearchChanged,
                showFilter: false,
              ),
        actions: widget.actions,
      ),
      content: _buildBody(),
    );
  }

  Widget _buildBody() {
    final content = _buildFilterableContent(widget.masterContent);

    if (!widget.showDetail || widget.detailContent == null) {
      return content;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        if (width >= DSBreakpoints.masterDetailSideBySide) {
          // Side-by-side layout — detail with close button in header
          return Row(
            children: [
              Expanded(flex: 3, child: content),
              Container(width: 1, color: DSColors.borderSubtle),
              Expanded(flex: 2, child: widget.detailContent!),
            ],
          );
        } else if (width >= DSBreakpoints.sidebarCollapse) {
          // Overlay drawer with scrim — tap scrim or press close to dismiss
          return Stack(
            children: [
              content,
              // Scrim
              Positioned.fill(
                child: GestureDetector(
                  onTap: widget.onDetailClose,
                  child: Container(
                    color: DSColors.obsidianDeep.withValues(alpha: 0.4),
                  ),
                ),
              ),
              // Drawer
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: DSSpacing.detailOverlayWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: DSColors.obsidianElevated,
                    border: const Border(
                      left: BorderSide(color: DSColors.borderSubtle),
                    ),
                    boxShadow: DSShadows.elevation3,
                  ),
                  child: widget.detailContent!,
                ),
              ),
            ],
          );
        } else {
          // Full-screen detail with explicit back navigation
          return Scaffold(
            backgroundColor: DSColors.obsidianDeep,
            appBar: AppBar(
              backgroundColor: DSColors.obsidianBase,
              foregroundColor: DSColors.textPrimary,
              elevation: 0,
              leading: Semantics(
                label: 'Close detail and return',
                button: true,
                child: IconButton(
                  icon: const DSIcon(Icons.arrow_back),
                  onPressed: widget.onDetailClose,
                  tooltip: 'Back',
                  autofocus: true,
                ),
              ),
              title: widget.detailTitle != null
                  ? DSText.headingMedium(widget.detailTitle!)
                  : null,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(height: 1, color: DSColors.borderSubtle),
              ),
            ),
            body: widget.detailContent!,
          );
        }
      },
    );
  }

  Widget _buildFilterableContent(Widget child) {
    final filters = widget.filters;
    if (filters == null || filters.isEmpty) {
      return child;
    }

    final selected = widget.selectedFilters ?? const <String>{};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            DSSpacing.lg,
            DSSpacing.md,
            DSSpacing.lg,
            0,
          ),
          child: DSFilterChipGroup(
            options: filters
                .map((filter) => DSFilterOption(value: filter, label: filter))
                .toList(),
            selected: selected,
            onToggle: (value) {
              if (widget.onFiltersChanged == null) {
                return;
              }

              final next = Set<String>.from(selected);
              if (next.contains(value)) {
                next.remove(value);
              } else {
                next.add(value);
              }
              widget.onFiltersChanged!(next);
            },
          ),
        ),
        const SizedBox(height: DSSpacing.md),
        Expanded(child: child),
      ],
    );
  }
}

/// A template for full-screen canvas views (Map workspace graph)
class CanvasTemplate extends StatelessWidget {
  /// The sidebar navigation items
  final List<DSSidebarItem> sidebarItems;

  /// Currently selected sidebar item index
  final int selectedIndex;

  /// Callback when sidebar item is selected
  final void Function(int) onSidebarItemSelected;

  /// The title shown in the topbar
  final String title;

  /// Optional search query
  final String? searchQuery;

  /// Callback when search changes
  final void Function(String)? onSearchChanged;

  /// The canvas content (typically a graph)
  final Widget canvas;

  /// Optional overlay panel (e.g., node inspector)
  final Widget? overlayPanel;

  /// Whether to show the overlay panel
  final bool showOverlay;

  /// Optional floating controls
  final List<Widget>? floatingControls;

  /// Optional actions for the topbar
  final List<Widget>? actions;

  const CanvasTemplate({
    super.key,
    required this.sidebarItems,
    required this.selectedIndex,
    required this.onSidebarItemSelected,
    required this.title,
    this.searchQuery,
    this.onSearchChanged,
    required this.canvas,
    this.overlayPanel,
    this.showOverlay = false,
    this.floatingControls,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return DSShell(
      sidebar: DSSidebar(
        items: sidebarItems,
        selectedId: sidebarItems[selectedIndex].id,
        onItemTap: (id) {
          final index = sidebarItems.indexWhere((item) => item.id == id);
          if (index != -1) {
            onSidebarItemSelected(index);
          }
        },
      ),
      topbar: DSTopbar(
        title: title,
        showSearch: onSearchChanged != null,
        searchBar: onSearchChanged == null
            ? null
            : DSSearchBar(
                value: searchQuery,
                onChanged: onSearchChanged,
                showFilter: false,
              ),
        actions: actions,
      ),
      content: Stack(
        children: [
          // Full-bleed canvas
          Positioned.fill(child: canvas),

          // Floating controls (zoom, layout, etc.)
          if (floatingControls != null)
            Positioned(
              left: DSSpacing.lg,
              bottom: DSSpacing.lg,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: floatingControls!
                    .map(
                      (control) => Padding(
                        padding: const EdgeInsets.only(bottom: DSSpacing.sm),
                        child: control,
                      ),
                    )
                    .toList(),
              ),
            ),

          // Overlay panel (inspector) - hidden below narrow breakpoint
          if (showOverlay && overlayPanel != null)
            Positioned(
              right: DSSpacing.lg,
              top: DSSpacing.lg,
              bottom: DSSpacing.lg,
              width: DSSpacing.inspectorWidth,
              child: Container(
                decoration: BoxDecoration(
                  color: DSColors.obsidianElevated.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(DSRadii.lg),
                  border: Border.all(color: DSColors.borderSubtle),
                  boxShadow: DSShadows.elevation3,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(DSRadii.lg),
                  child: overlayPanel!,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A template for timeline-based views (History workspace)
///
/// Responsive behavior (uses DSBreakpoints):
///   >= 1000px: side-by-side timeline + detail
///   < 1000px: timeline only (detail shown via navigation)
class TimelineTemplate extends StatelessWidget {
  /// The sidebar navigation items
  final List<DSSidebarItem> sidebarItems;

  /// Currently selected sidebar item index
  final int selectedIndex;

  /// Callback when sidebar item is selected
  final void Function(int) onSidebarItemSelected;

  /// The title shown in the topbar
  final String title;

  /// Optional search query
  final String? searchQuery;

  /// Callback when search changes
  final void Function(String)? onSearchChanged;

  /// Optional filter chips
  final List<String>? filters;

  /// Currently selected filters
  final Set<String>? selectedFilters;

  /// Callback when filter selection changes
  final void Function(Set<String>)? onFiltersChanged;

  /// Timeline entries
  final List<DSTimelineEntry> entries;

  /// Callback when entry is selected
  final void Function(DSTimelineEntry)? onEntrySelected;

  /// Currently selected entry
  final DSTimelineEntry? selectedEntry;

  /// Detail panel for selected entry
  final Widget? detailPanel;

  /// Optional actions for the topbar
  final List<Widget>? actions;

  const TimelineTemplate({
    super.key,
    required this.sidebarItems,
    required this.selectedIndex,
    required this.onSidebarItemSelected,
    required this.title,
    this.searchQuery,
    this.onSearchChanged,
    this.filters,
    this.selectedFilters,
    this.onFiltersChanged,
    required this.entries,
    this.onEntrySelected,
    this.selectedEntry,
    this.detailPanel,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return DSShell(
      sidebar: DSSidebar(
        items: sidebarItems,
        selectedId: sidebarItems[selectedIndex].id,
        onItemTap: (id) {
          final index = sidebarItems.indexWhere((item) => item.id == id);
          if (index != -1) {
            onSidebarItemSelected(index);
          }
        },
      ),
      topbar: DSTopbar(
        title: title,
        showSearch: onSearchChanged != null,
        searchBar: onSearchChanged == null
            ? null
            : DSSearchBar(value: searchQuery, onChanged: onSearchChanged),
        actions: actions,
      ),
      content: LayoutBuilder(
        builder: (context, constraints) {
          final showDetail = selectedEntry != null && detailPanel != null;
          final isWide = constraints.maxWidth >= DSBreakpoints.timelineDetail;

          final timeline = DSTimeline(
            entries: entries,
            selectedId: selectedEntry?.id,
            onEntryTap: (id) {
              DSTimelineEntry? match;
              for (final entry in entries) {
                if (entry.id == id) {
                  match = entry;
                  break;
                }
              }
              if (match != null) {
                onEntrySelected?.call(match);
              }
            },
            filterBar: (filters == null || filters!.isEmpty)
                ? null
                : DSFilterChipGroup(
                    options: filters!
                        .map(
                          (filter) =>
                              DSFilterOption(value: filter, label: filter),
                        )
                        .toList(),
                    selected: selectedFilters ?? const <String>{},
                    onToggle: (value) {
                      if (onFiltersChanged == null) {
                        return;
                      }

                      final next = Set<String>.from(
                        selectedFilters ?? const <String>{},
                      );
                      if (next.contains(value)) {
                        next.remove(value);
                      } else {
                        next.add(value);
                      }
                      onFiltersChanged!(next);
                    },
                  ),
          );

          if (showDetail && isWide) {
            return Row(
              children: [
                Expanded(flex: 2, child: timeline),
                Container(width: 1, color: DSColors.borderSubtle),
                Expanded(flex: 3, child: detailPanel!),
              ],
            );
          }

          return timeline;
        },
      ),
    );
  }
}
