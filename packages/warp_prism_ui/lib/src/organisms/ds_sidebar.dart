import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../tokens/tokens.dart';
import '../atoms/atoms.dart';

/// ASW Observatory Organism - Sidebar
///
/// Navigation sidebar with workspace areas.
/// Supports keyboard navigation (arrow keys, Enter/Space to activate).
class DSSidebar extends StatelessWidget {
  final List<DSSidebarItem> items;
  final String? selectedId;
  final ValueChanged<String>? onItemTap;
  final Widget? header;
  final Widget? footer;
  final bool expanded;

  const DSSidebar({
    super.key,
    required this.items,
    this.selectedId,
    this.onItemTap,
    this.header,
    this.footer,
    this.expanded = true,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Navigation sidebar',
      explicitChildNodes: true,
      child: Container(
        width: expanded ? DSSpacing.sidebarExpanded : DSSpacing.sidebarCollapsed,
        decoration: BoxDecoration(
          color: DSColors.obsidianBase,
          border: Border(
            right: BorderSide(color: DSColors.borderSubtle, width: 1),
          ),
        ),
        child: Column(
          children: [
            // Header
            if (header != null) ...[
              header!,
              const DSDivider.subtle(),
            ] else ...[
              _DefaultHeader(expanded: expanded),
              const DSDivider.subtle(),
            ],
            
            // Navigation items
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: DSSpacing.sm),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final isSelected = item.id == selectedId;
                  
                  if (item.isDivider) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: DSSpacing.md,
                        vertical: DSSpacing.sm,
                      ),
                      child: expanded
                          ? DSText.labelSmall(
                              item.label ?? '',
                              color: DSColors.textTertiary,
                            )
                          : const DSDivider.subtle(),
                    );
                  }
                  
                  return _SidebarItemWidget(
                    item: item,
                    isSelected: isSelected,
                    expanded: expanded,
                    onTap: () => onItemTap?.call(item.id),
                  );
                },
              ),
            ),
            
            // Footer
            if (footer != null) ...[
              const DSDivider.subtle(),
              footer!,
            ],
          ],
        ),
      ),
    );
  }
}

class _DefaultHeader extends StatelessWidget {
  final bool expanded;

  const _DefaultHeader({required this.expanded});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'ASW Observatory logo and title',
      header: true,
      child: Container(
        height: DSSpacing.topbarHeight,
        padding: EdgeInsets.symmetric(
          horizontal: expanded ? DSSpacing.lg : DSSpacing.sm,
        ),
        child: Row(
          children: [
            // Logo
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    DSColors.accentCyan,
                    DSColors.accentViolet,
                  ],
                ),
                borderRadius: BorderRadius.circular(DSRadii.sm),
              ),
              child: const Center(
                child: DSIcon(
                  Icons.hub,
                  color: DSColors.white,
                  size: 18,
                ),
              ),
            ),
            if (expanded) ...[
              const SizedBox(width: DSSpacing.sm),
              const Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DSText.labelLarge('ASW Observatory', color: DSColors.textPrimary),
                    DSText.labelSmall('Agent Workspace', color: DSColors.textTertiary),
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

class _SidebarItemWidget extends StatefulWidget {
  final DSSidebarItem item;
  final bool isSelected;
  final bool expanded;
  final VoidCallback? onTap;

  const _SidebarItemWidget({
    required this.item,
    required this.isSelected,
    required this.expanded,
    this.onTap,
  });

  @override
  State<_SidebarItemWidget> createState() => _SidebarItemWidgetState();
}

class _SidebarItemWidgetState extends State<_SidebarItemWidget> {
  bool _isHovered = false;
  bool _isFocused = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.item.color ?? DSColors.accentCyan;
    final bgColor = widget.isSelected
        ? color.withOpacity(0.15)
        : (_isFocused
            ? DSColors.obsidianActive
            : (_isHovered ? DSColors.obsidianHover : DSColors.transparent));
    final textColor = widget.isSelected
        ? color
        : (_isHovered || _isFocused ? DSColors.textPrimary : DSColors.textSecondary);
    final iconColor = widget.isSelected
        ? color
        : (_isHovered || _isFocused ? DSColors.textPrimary : DSColors.textTertiary);

    final semanticLabel = widget.item.label ?? '';
    final semanticHint = widget.isSelected ? 'Currently selected' : 'Double-tap to navigate';

    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      button: true,
      selected: widget.isSelected,
      enabled: true,
      child: Focus(
        focusNode: _focusNode,
        onFocusChange: (focused) => setState(() => _isFocused = focused),
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.enter ||
                event.logicalKey == LogicalKeyboardKey.space) {
              widget.onTap?.call();
              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: widget.onTap,
            child: AnimatedContainer(
              duration: DSMotion.fast,
              margin: EdgeInsets.symmetric(
                horizontal: widget.expanded ? DSSpacing.sm : DSSpacing.xs,
                vertical: 2,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: widget.expanded ? DSSpacing.md : 0,
                vertical: DSSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(DSRadii.md),
                border: widget.isSelected
                    ? Border.all(color: color.withOpacity(0.3), width: 1)
                    : (_isFocused
                        ? Border.all(color: DSColors.accentCyan.withOpacity(0.5), width: 2)
                        : null),
              ),
              child: Row(
                mainAxisAlignment: widget.expanded
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.center,
                children: [
                  DSIcon(
                    widget.item.icon,
                    color: iconColor,
                    iconSize: DSIconSize.medium,
                  ),
                  if (widget.expanded) ...[
                    const SizedBox(width: DSSpacing.sm),
                    Expanded(
                      child: DSText.labelMedium(
                        widget.item.label ?? '',
                        color: textColor,
                      ),
                    ),
                    if (widget.item.badge != null)
                      DSBadge.count(
                        widget.item.badge!,
                        color: color,
                        size: DSBadgeSize.small,
                      ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DSSidebarItem {
  final String id;
  final String? label;
  final IconData icon;
  final Color? color;
  final int? badge;
  final bool isDivider;

  const DSSidebarItem({
    required this.id,
    this.label,
    this.icon = Icons.circle,
    this.color,
    this.badge,
    this.isDivider = false,
  });

  DSSidebarItem.divider({this.label})
      : id = 'divider_${label ?? DateTime.now().millisecondsSinceEpoch}',
        icon = Icons.circle,
        color = null,
        badge = null,
        isDivider = true;
}
