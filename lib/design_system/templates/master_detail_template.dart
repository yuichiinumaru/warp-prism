/// Master-detail template for workspace pages
/// Used by Map, Operate, History, and Governance workspaces
library;

import 'package:flutter/material.dart';
import '../tokens/tokens.dart';
import '../organisms/organisms.dart';

/// A template that provides master-detail layout with sidebar
class MasterDetailTemplate extends StatefulWidget {
  /// The sidebar navigation items
  final List<SidebarItem> sidebarItems;
  
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
  });

  @override
  State<MasterDetailTemplate> createState() => _MasterDetailTemplateState();
}

class _MasterDetailTemplateState extends State<MasterDetailTemplate> {
  bool _sidebarCollapsed = false;
  
  @override
  Widget build(BuildContext context) {
    return DsShell(
      sidebar: DsSidebar(
        items: widget.sidebarItems,
        selectedIndex: widget.selectedIndex,
        onItemSelected: widget.onSidebarItemSelected,
        isCollapsed: _sidebarCollapsed,
        onToggleCollapse: () {
          setState(() => _sidebarCollapsed = !_sidebarCollapsed);
        },
      ),
      topbar: DsTopbar(
        title: widget.title,
        breadcrumbs: widget.breadcrumbs,
        searchQuery: widget.searchQuery,
        onSearchChanged: widget.onSearchChanged,
        filters: widget.filters,
        selectedFilters: widget.selectedFilters,
        onFiltersChanged: widget.onFiltersChanged,
        actions: widget.actions,
      ),
      body: _buildBody(),
    );
  }
  
  Widget _buildBody() {
    if (!widget.showDetail || widget.detailContent == null) {
      return widget.masterContent;
    }
    
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive breakpoints
        final isWide = constraints.maxWidth > 1200;
        final isMedium = constraints.maxWidth > 800;
        
        if (isWide) {
          // Side-by-side layout
          return Row(
            children: [
              Expanded(
                flex: 3,
                child: widget.masterContent,
              ),
              Container(
                width: 1,
                color: DsColors.border,
              ),
              Expanded(
                flex: 2,
                child: widget.detailContent!,
              ),
            ],
          );
        } else if (isMedium) {
          // Master with overlay detail
          return Stack(
            children: [
              widget.masterContent,
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: 400,
                child: Container(
                  decoration: BoxDecoration(
                    color: DsColors.surface,
                    border: Border(
                      left: BorderSide(color: DsColors.border),
                    ),
                    boxShadow: [DsShadows.xl],
                  ),
                  child: widget.detailContent!,
                ),
              ),
            ],
          );
        } else {
          // Full-screen detail with back button
          return widget.detailContent!;
        }
      },
    );
  }
}

/// A template for full-screen canvas views (Map workspace graph)
class CanvasTemplate extends StatelessWidget {
  /// The sidebar navigation items
  final List<SidebarItem> sidebarItems;
  
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
    return DsShell(
      sidebar: DsSidebar(
        items: sidebarItems,
        selectedIndex: selectedIndex,
        onItemSelected: onSidebarItemSelected,
      ),
      topbar: DsTopbar(
        title: title,
        searchQuery: searchQuery,
        onSearchChanged: onSearchChanged,
        actions: actions,
      ),
      body: Stack(
        children: [
          // Full-bleed canvas
          Positioned.fill(child: canvas),
          
          // Floating controls (zoom, layout, etc.)
          if (floatingControls != null)
            Positioned(
              left: DsSpacing.lg,
              bottom: DsSpacing.lg,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: floatingControls!
                    .map((control) => Padding(
                          padding: EdgeInsets.only(bottom: DsSpacing.sm),
                          child: control,
                        ))
                    .toList(),
              ),
            ),
          
          // Overlay panel (inspector)
          if (showOverlay && overlayPanel != null)
            Positioned(
              right: DsSpacing.lg,
              top: DsSpacing.lg,
              bottom: DsSpacing.lg,
              width: 360,
              child: Container(
                decoration: BoxDecoration(
                  color: DsColors.surface.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(DsRadii.lg),
                  border: Border.all(color: DsColors.border),
                  boxShadow: [DsShadows.xl],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(DsRadii.lg),
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
class TimelineTemplate extends StatelessWidget {
  /// The sidebar navigation items
  final List<SidebarItem> sidebarItems;
  
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
  final List<TimelineEntry> entries;
  
  /// Callback when entry is selected
  final void Function(TimelineEntry)? onEntrySelected;
  
  /// Currently selected entry
  final TimelineEntry? selectedEntry;
  
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
    return DsShell(
      sidebar: DsSidebar(
        items: sidebarItems,
        selectedIndex: selectedIndex,
        onItemSelected: onSidebarItemSelected,
      ),
      topbar: DsTopbar(
        title: title,
        searchQuery: searchQuery,
        onSearchChanged: onSearchChanged,
        filters: filters,
        selectedFilters: selectedFilters,
        onFiltersChanged: onFiltersChanged,
        actions: actions,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final showDetail = selectedEntry != null && detailPanel != null;
          final isWide = constraints.maxWidth > 1000;
          
          if (showDetail && isWide) {
            return Row(
              children: [
                Expanded(
                  flex: 2,
                  child: DsTimeline(
                    entries: entries,
                    onEntryTap: onEntrySelected,
                    selectedEntryId: selectedEntry?.id,
                  ),
                ),
                Container(width: 1, color: DsColors.border),
                Expanded(
                  flex: 3,
                  child: detailPanel!,
                ),
              ],
            );
          }
          
          return DsTimeline(
            entries: entries,
            onEntryTap: onEntrySelected,
            selectedEntryId: selectedEntry?.id,
          );
        },
      ),
    );
  }
}
