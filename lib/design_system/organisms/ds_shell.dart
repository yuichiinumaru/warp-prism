import 'package:flutter/material.dart';
import '../tokens/tokens.dart';
import '../atoms/atoms.dart';

/// ASW Observatory Organism - Shell
/// 
/// Main application shell with sidebar, topbar, and content area
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

/// Responsive shell that adapts to screen size
class DSShellResponsive extends StatelessWidget {
  final Widget sidebar;
  final Widget collapsedSidebar;
  final Widget? topbar;
  final Widget content;
  final Widget? inspector;
  final bool showInspector;
  final double breakpoint;

  const DSShellResponsive({
    super.key,
    required this.sidebar,
    required this.collapsedSidebar,
    this.topbar,
    required this.content,
    this.inspector,
    this.showInspector = false,
    this.breakpoint = 1200,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= breakpoint;
        final showFullSidebar = constraints.maxWidth >= 800;
        
        return Container(
          color: DSColors.obsidianDeep,
          child: Row(
            children: [
              // Sidebar
              showFullSidebar ? sidebar : collapsedSidebar,
              
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
                          
                          // Inspector panel (only on wide screens)
                          if (isWide && showInspector && inspector != null) ...[
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
      },
    );
  }
}
