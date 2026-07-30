import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// Application shell that wires the design system's responsive shell organisms
/// with sidebar navigation, topbar, and an optional inspector region.
///
/// Used by [GoRouter]'s [ShellRoute] to wrap all product pages in a
/// consistent chrome with persistent sidebar + topbar.
///
/// Responsive layout contract (references [PrismBreakpoints]):
///   >= 1200px (wide):     full expanded sidebar + topbar + content + inspector
///   800-1199px (medium):  full expanded sidebar + topbar + content (no inspector)
///   600-799px (narrow):   collapsed sidebar + topbar + content
///   < 600px (compact):    no sidebar, bottom navigation + topbar + content
class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  /// Navigation items shared across sidebar and bottom navigation.
  static const navItems = [
    PrismSidebarItem(
      id: 'overview',
      label: 'Overview',
      icon: Icons.dashboard_outlined,
    ),
    PrismSidebarItem(id: 'map', label: 'Map', icon: Icons.hub_outlined),
    PrismSidebarItem(
      id: 'operate',
      label: 'Operate',
      icon: Icons.play_circle_outline,
    ),
    PrismSidebarItem(
      id: 'history',
      label: 'History',
      icon: Icons.history_outlined,
    ),
    PrismSidebarItem(
      id: 'governance',
      label: 'Governance',
      icon: Icons.gavel_outlined,
    ),
  ];

  static const _routeByIndex = <int, String>{
    0: '/overview',
    1: '/map',
    2: '/operate',
    3: '/history',
    4: '/governance',
  };

  static const _titleByIndex = <int, String>{
    0: 'Overview',
    1: 'Map',
    2: 'Operate',
    3: 'History',
    4: 'Governance',
  };

  void _onNavItemTap(String id) {
    final entry = _routeByIndex.entries.firstWhere(
      (e) => navItems[e.key].id == id,
      orElse: () => const MapEntry(0, '/overview'),
    );
    navigationShell.goBranch(
      entry.key,
      initialLocation: entry.key == navigationShell.currentIndex,
    );
  }

  /// Builds a collapsed (icon-only) sidebar for narrow layouts.
  Widget _buildCollapsedSidebar() {
    return PrismSidebar(
      items: navItems,
      selectedId: navItems[navigationShell.currentIndex].id,
      onItemTap: _onNavItemTap,
      expanded: false,
    );
  }

  /// Builds bottom navigation items for the compact layout fallback.
  List<BottomNavigationBarItem> _buildBottomNavItems() {
    return navItems
        .map(
          (item) => BottomNavigationBarItem(
            icon: Icon(item.icon),
            label: item.label ?? '',
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = navigationShell.currentIndex;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isCompact = screenWidth < PrismBreakpoints.narrow;

    // Compact layout: no sidebar, bottom navigation instead.
    if (isCompact) {
      return _CompactShell(
        currentIndex: currentIndex,
        title: _titleByIndex[currentIndex] ?? 'ASW Observatory',
        bottomNavItems: _buildBottomNavItems(),
        onBottomNavTap: (index) {
          _onNavItemTap(navItems[index].id);
        },
        content: navigationShell,
      );
    }

    // Medium and wide layouts use the responsive shell from the DS.
    return PrismShellResponsive(
      sidebar: PrismSidebar(
        items: navItems,
        selectedId: navItems[currentIndex].id,
        onItemTap: _onNavItemTap,
      ),
      collapsedSidebar: _buildCollapsedSidebar(),
      topbar: PrismTopbar(
        title: _titleByIndex[currentIndex] ?? 'ASW Observatory',
      ),
      content: navigationShell,
      // Inspector is a shell concern. Feature surfaces can request it
      // via state management; for now the shell defers inspector display.
      showInspector: false,
    );
  }
}

/// Compact shell variant for narrow viewports (< 600px).
///
/// Hides the sidebar entirely and presents a [BottomNavigationBar]
/// for primary navigation. This is the credible small-layout fallback
/// that keeps the app navigable without desktop chrome.
class _CompactShell extends StatelessWidget {
  final int currentIndex;
  final String title;
  final List<BottomNavigationBarItem> bottomNavItems;
  final ValueChanged<int> onBottomNavTap;
  final Widget content;

  const _CompactShell({
    required this.currentIndex,
    required this.title,
    required this.bottomNavItems,
    required this.onBottomNavTap,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PrismColors.obsidianDeep,
      appBar: AppBar(
        title: PrismText.headingMedium(title),
        backgroundColor: PrismColors.obsidianBase,
        foregroundColor: PrismColors.textPrimary,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: PrismColors.borderSubtle),
        ),
      ),
      body: content,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onBottomNavTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: PrismColors.obsidianBase,
        selectedItemColor: PrismColors.accentCyan,
        unselectedItemColor: PrismColors.textTertiary,
        selectedLabelStyle: PrismTypography.labelSmall,
        unselectedLabelStyle: PrismTypography.labelSmall,
        items: bottomNavItems,
      ),
    );
  }
}
