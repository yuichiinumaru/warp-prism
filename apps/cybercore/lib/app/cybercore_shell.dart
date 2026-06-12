import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// CyberCore application shell.
///
/// Wires the design system's responsive shell organisms with sidebar
/// navigation, topbar, and content area. Used by [GoRouter]'s
/// [StatefulShellRoute] to wrap all product pages in consistent chrome.
///
/// Responsive layout contract (references [PrismBreakpoints]):
///   >= 1200px (wide):     full expanded sidebar + topbar + content
///   800-1199px (medium):  full expanded sidebar + topbar + content
///   600-799px (narrow):   collapsed sidebar + topbar + content
///   < 600px (compact):    no sidebar, bottom navigation + topbar + content
class CyberCoreShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const CyberCoreShell({super.key, required this.navigationShell});

  /// Navigation items for the CyberCore sidebar.
  static const navItems = [
    PrismSidebarItem(
      id: 'dashboard',
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      color: PrismColors.accentCyan,
    ),
    PrismSidebarItem(
      id: 'registry',
      label: 'Registry',
      icon: Icons.hub_outlined,
      color: PrismColors.accentViolet,
    ),
    PrismSidebarItem(
      id: 'tasks',
      label: 'Tasks',
      icon: Icons.play_circle_outline,
      color: PrismColors.accentGold,
    ),
    PrismSidebarItem(
      id: 'audit',
      label: 'Audit',
      icon: Icons.history_outlined,
      color: PrismColors.accentCyan,
    ),
    PrismSidebarItem(
      id: 'governance',
      label: 'Governance',
      icon: Icons.gavel_outlined,
      color: PrismColors.statusWarning,
    ),
  ];

  static const _routeByIndex = <int, String>{
    0: '/dashboard',
    1: '/registry',
    2: '/tasks',
    3: '/audit',
    4: '/governance',
  };

  static const _titleByIndex = <int, String>{
    0: 'Dashboard',
    1: 'Registry',
    2: 'Tasks',
    3: 'Audit',
    4: 'Governance',
  };

  void _onNavItemTap(String id) {
    final entry = _routeByIndex.entries.firstWhere(
      (e) => navItems[e.key].id == id,
      orElse: () => const MapEntry(0, '/dashboard'),
    );
    navigationShell.goBranch(
      entry.key,
      initialLocation: entry.key == navigationShell.currentIndex,
    );
  }

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

    if (isCompact) {
      return _CompactShell(
        currentIndex: currentIndex,
        title: _titleByIndex[currentIndex] ?? 'CyberCore',
        bottomNavItems: _buildBottomNavItems(),
        onBottomNavTap: (index) {
          _onNavItemTap(navItems[index].id);
        },
        content: navigationShell,
      );
    }

    return PrismShellResponsive(
      sidebar: PrismSidebar(
        items: navItems,
        selectedId: navItems[currentIndex].id,
        onItemTap: _onNavItemTap,
        header: const _CyberCoreHeader(expanded: true),
      ),
      collapsedSidebar: PrismSidebar(
        items: navItems,
        selectedId: navItems[currentIndex].id,
        onItemTap: _onNavItemTap,
        expanded: false,
        header: const _CyberCoreHeader(expanded: false),
      ),
      topbar: PrismTopbar(title: _titleByIndex[currentIndex] ?? 'CyberCore'),
      content: navigationShell,
      showInspector: false,
    );
  }
}

/// CyberCore branded sidebar header.
class _CyberCoreHeader extends StatelessWidget {
  final bool expanded;

  const _CyberCoreHeader({required this.expanded});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'CyberCore logo and title',
      header: true,
      child: Container(
        height: PrismSpacing.topbarHeight,
        padding: EdgeInsets.symmetric(
          horizontal: expanded ? PrismSpacing.lg : PrismSpacing.sm,
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [PrismColors.accentViolet, PrismColors.accentCyan],
                ),
                borderRadius: BorderRadius.circular(PrismRadii.sm),
              ),
              child: const Center(
                child: PrismIcon(
                  Icons.shield_outlined,
                  color: PrismColors.white,
                  size: 18,
                ),
              ),
            ),
            if (expanded) ...[
              const SizedBox(width: PrismSpacing.sm),
              const Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PrismText.labelLarge(
                      'CyberCore',
                      color: PrismColors.textPrimary,
                    ),
                    PrismText.labelSmall(
                      'Read-Only Observatory',
                      color: PrismColors.textTertiary,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Compact shell for narrow viewports (< 600px).
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
