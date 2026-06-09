import 'package:flutter/material.dart';
import '../tokens/tokens.dart';

/// ASW Observatory Organism - Shell
///
/// Main application shell with sidebar, topbar, and content area.
class DSShell extends StatelessWidget {
  final Widget sidebar;
  final Widget? topbar;
  final Widget content;
  final Widget? inspector;
  final bool showInspector;

  const DSShell({
    super.key,
    required this.sidebar,
    this.topbar,
    required this.content,
    this.inspector,
    this.showInspector = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: DSColors.obsidianDeep,
      child: Row(
        children: [
          // Sidebar
          sidebar,
          
          // Main content area
          Expanded(
            child: Column(
              children: [
                // Topbar
                if (topbar != null) topbar!,
                
                // Content
                Expanded(
                  child: Row(
                    children: [
                      // Main content
                      Expanded(child: content),
                      
                      // Inspector panel
                      if (showInspector && inspector != null) ...[
                        Container(
                          width: 1,
                          color: DSColors.borderSubtle,
                        ),
                        SizedBox(
                          width: DSSpacing.inspectorWidth,
                          child: inspector,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Responsive shell that adapts to screen size using DSBreakpoints.
///
/// Width contract:
///   >= 1200px (wide):     full sidebar + inspector side-by-side
///   800-1199px (medium):  full sidebar, overlay inspector drawer with scrim
///   600-799px (narrow):   collapsed sidebar, full-screen detail when inspector shown
///   < 600px:              no sidebar, content only
///
/// Inspector/detail close contract:
///   - [onInspectorClose] is called when the user dismisses the detail
///     (close button, scrim tap, back arrow).
///   - On medium layouts, a scrim overlay appears behind the drawer.
///   - On narrow layouts, the inspector replaces content as full-screen
///     with a back arrow in the topbar.
class DSShellResponsive extends StatelessWidget {
  final Widget sidebar;
  final Widget collapsedSidebar;
  final Widget? topbar;
  final Widget content;
  final Widget? inspector;
  final bool showInspector;

  /// Called when the inspector/detail should close.
  final VoidCallback? onInspectorClose;

  const DSShellResponsive({
    super.key,
    required this.sidebar,
    required this.collapsedSidebar,
    this.topbar,
    required this.content,
    this.inspector,
    this.showInspector = false,
    this.onInspectorClose,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isWide = width >= DSBreakpoints.masterDetailSideBySide;
        final showFullSidebar = width >= DSBreakpoints.sidebarCollapse;
        final showAnySidebar = width >= DSBreakpoints.narrow;
        final isNarrow = width < DSBreakpoints.sidebarCollapse;
        final hasInspector = showInspector && inspector != null;
        
        // Narrow + inspector: full-screen detail replaces content
        if (isNarrow && hasInspector) {
          return Container(
            color: DSColors.obsidianDeep,
            child: Row(
              children: [
                if (showAnySidebar) collapsedSidebar,
                Expanded(child: inspector!),
              ],
            ),
          );
        }
        
        return Container(
          color: DSColors.obsidianDeep,
          child: Row(
            children: [
              // Sidebar - hidden below narrow breakpoint
              if (showAnySidebar) showFullSidebar ? sidebar : collapsedSidebar,
              
              // Main content area
              Expanded(
                child: Column(
                  children: [
                    // Topbar
                    if (topbar != null) topbar!,
                    
                    // Content
                    Expanded(
                      child: Stack(
                        children: [
                          // Main content
                          Row(
                            children: [
                              // Primary content
                              Expanded(child: content),
                              
                              // Inspector panel (only on wide screens — side-by-side)
                              if (isWide && hasInspector) ...[
                                Container(
                                  width: 1,
                                  color: DSColors.borderSubtle,
                                ),
                                SizedBox(
                                  width: DSSpacing.inspectorWidth,
                                  child: inspector!,
                                ),
                              ],
                            ],
                          ),
                          
                          // Medium layout: overlay drawer with scrim
                          if (!isWide && !isNarrow && hasInspector) ...[
                            // Scrim
                            Positioned.fill(
                              child: GestureDetector(
                                onTap: onInspectorClose,
                                child: Container(
                                  color: DSColors.obsidianDeep.withOpacity(0.4),
                                ),
                              ),
                            ),
                            // Drawer from the right
                            Positioned(
                              right: 0,
                              top: 0,
                              bottom: 0,
                              width: DSSpacing.inspectorWidth,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: DSColors.obsidianElevated,
                                  border: Border(
                                    left: BorderSide(
                                      color: DSColors.borderSubtle,
                                    ),
                                  ),
                                  boxShadow: DSShadows.elevation3,
                                ),
                                child: inspector!,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
