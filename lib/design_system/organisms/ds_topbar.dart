import 'package:flutter/material.dart';
import '../tokens/tokens.dart';
import '../atoms/atoms.dart';
import '../molecules/molecules.dart';

/// ASW Observatory Organism - Topbar
/// 
/// Top navigation bar with search, breadcrumbs, and actions
class DSTopbar extends StatelessWidget {
  final String? title;
  final List<String>? breadcrumbs;
  final Widget? leading;
  final List<Widget>? actions;
  final Widget? searchBar;
  final bool showSearch;

  const DSTopbar({
    super.key,
    this.title,
    this.breadcrumbs,
    this.leading,
    this.actions,
    this.searchBar,
    this.showSearch = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: DSSpacing.topbarHeight,
      decoration: BoxDecoration(
        color: DSColors.obsidianBase,
        border: Border(
          bottom: BorderSide(color: DSColors.borderSubtle, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.lg),
      child: Row(
        children: [
          // Leading
          if (leading != null) ...[
            leading!,
            const SizedBox(width: DSSpacing.md),
          ],
          
          // Title or breadcrumbs
          if (breadcrumbs != null && breadcrumbs!.isNotEmpty)
            _Breadcrumbs(items: breadcrumbs!)
          else if (title != null)
            DSText.headingMedium(title!),
          
          const Spacer(),
          
          // Search bar
          if (showSearch && searchBar != null) ...[
            SizedBox(
              width: 300,
              child: searchBar,
            ),
            const SizedBox(width: DSSpacing.lg),
          ],
          
          // Actions
          if (actions != null)
            Row(
              children: [
                for (int i = 0; i < actions!.length; i++) ...[
                  if (i > 0) const SizedBox(width: DSSpacing.xs),
                  actions![i],
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _Breadcrumbs extends StatelessWidget {
  final List<String> items;

  const _Breadcrumbs({required this.items});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          if (i > 0) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: DSSpacing.xs),
              child: DSIcon.small(
                Icons.chevron_right,
                color: DSColors.textTertiary,
              ),
            ),
          ],
          DSText.labelMedium(
            items[i],
            color: i == items.length - 1
                ? DSColors.textPrimary
                : DSColors.textSecondary,
          ),
        ],
      ],
    );
  }
}

/// Topbar action button
class DSTopbarAction extends StatefulWidget {
  final IconData icon;
  final String? tooltip;
  final VoidCallback? onTap;
  final bool active;
  final int? badge;

  const DSTopbarAction({
    super.key,
    required this.icon,
    this.tooltip,
    this.onTap,
    this.active = false,
    this.badge,
  });

  @override
  State<DSTopbarAction> createState() => _DSTopbarActionState();
}

class _DSTopbarActionState extends State<DSTopbarAction> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.active
        ? DSColors.accentCyan.withOpacity(0.15)
        : (_isHovered ? DSColors.obsidianHover : DSColors.transparent);
    final iconColor = widget.active
        ? DSColors.accentCyan
        : (_isHovered ? DSColors.textPrimary : DSColors.textSecondary);

    Widget button = MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: DSMotion.fast,
          width: DSSpacing.iconButtonSize,
          height: DSSpacing.iconButtonSize,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(DSRadii.md),
          ),
          child: Stack(
            children: [
              Center(
                child: DSIcon(widget.icon, color: iconColor),
              ),
              if (widget.badge != null && widget.badge! > 0)
                Positioned(
                  top: 4,
                  right: 4,
                  child: DSBadge.count(
                    widget.badge!,
                    color: DSColors.accentCyan,
                    size: DSBadgeSize.small,
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      button = Tooltip(
        message: widget.tooltip!,
        child: button,
      );
    }

    return button;
  }
}
