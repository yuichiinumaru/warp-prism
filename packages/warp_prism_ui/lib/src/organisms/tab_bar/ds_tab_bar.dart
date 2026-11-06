import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../atoms/atoms.dart';
import '../../theme/ds_theme.dart';
import '../../tokens/tokens.dart';
import 'ds_tab.dart';
import 'ds_tab_controller.dart';

/// ASW Observatory Organism — Tab Bar
///
/// A horizontal, scrollable tab bar with closeable tabs, badge indicators,
/// and glass-panel styling.
///
/// Features:
/// - Scrollable overflow with gradient fade indicators
/// - Close (X) button on closeable tabs
/// - Badge count pill per tab
/// - Active/inactive/hover states with obsidian glass aesthetic
/// - Keyboard accessible: Tab to focus, Enter/Space to activate, arrow keys
///   to navigate between tabs
///
/// Contract:
/// - A [DSTabController] must be provided via the [controller] parameter.
/// - Tab headers are rendered from [controller.tabs].
/// - Active tab highlight uses [DSColors.accentBlue] with glass tint.
class DSTabBar extends StatefulWidget {
  /// The tab controller managing tab state.
  final DSTabController controller;

  /// Called when a tab's close button is tapped.
  /// Receives the tab's [DSTab.id].
  /// The controller's `close` method should be called by the consumer
  /// to actually remove the tab.
  final ValueChanged<String>? onClose;

  /// Background color override. Defaults to obsidianBase.
  final Color? backgroundColor;

  /// Whether the tab bar shows scroll-fade indicators at edges.
  final bool showScrollFades;

  const DSTabBar({
    super.key,
    required this.controller,
    this.onClose,
    this.backgroundColor,
    this.showScrollFades = true,
  });

  @override
  State<DSTabBar> createState() => _DSTabBarState();
}

class _DSTabBarState extends State<DSTabBar> {
  final ScrollController _scrollController = ScrollController();
  bool _canScrollLeft = false;
  bool _canScrollRight = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
    _scrollController.addListener(_onScrollChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateScrollState());
  }

  @override
  void didUpdateWidget(DSTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
      _updateScrollState();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _scrollController.removeListener(_onScrollChanged);
    _scrollController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureActiveTabVisible();
      _updateScrollState();
    });
  }

  void _onScrollChanged() {
    _updateScrollState();
  }

  void _updateScrollState() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    final canLeft = position.pixels > 0;
    final canRight = position.pixels < position.maxScrollExtent - 1;
    if (canLeft != _canScrollLeft || canRight != _canScrollRight) {
      setState(() {
        _canScrollLeft = canLeft;
        _canScrollRight = canRight;
      });
    }
  }

  /// Scrolls the active tab into view after the frame settles.
  void _ensureActiveTabVisible() {
    if (!_scrollController.hasClients) return;
    // The active tab is at index = controller.activeIndex.
    // Each tab header is approximately _kTabMinWidth wide.
    // We scroll to keep it centered if possible.
    final activeIndex = widget.controller.activeIndex;
    final tabWidth = _TabHeaderDelegate.estimatedWidth(
      widget.controller.tabs[activeIndex],
    );
    final targetOffset =
        (activeIndex * tabWidth) -
        (_scrollController.position.viewportDimension / 2) +
        (tabWidth / 2);
    _scrollController.animateTo(
      targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: DSMotion.normal,
      curve: DSMotion.standard,
    );
  }

  void _scrollLeft() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      (_scrollController.offset - 200).clamp(
        0.0,
        _scrollController.position.maxScrollExtent,
      ),
      duration: DSMotion.fast,
      curve: DSMotion.standard,
    );
  }

  void _scrollRight() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      (_scrollController.offset + 200).clamp(
        0.0,
        _scrollController.position.maxScrollExtent,
      ),
      duration: DSMotion.fast,
      curve: DSMotion.standard,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tabs = widget.controller.tabs;
    if (tabs.isEmpty) {
      return const SizedBox.shrink();
    }

    final bgColor = widget.backgroundColor ?? DSColors.obsidianBase;

    return Semantics(
      label: 'Tab bar with ${tabs.length} tabs',
      explicitChildNodes: true,
      child: Container(
        height: DSSpacing.topbarHeight,
        decoration: BoxDecoration(
          color: bgColor,
          border: const Border(
            bottom: BorderSide(color: DSColors.borderSubtle, width: 1),
          ),
        ),
        child: Row(
          children: [
            // Left scroll arrow (visible when can scroll left)
            if (widget.showScrollFades && _canScrollLeft)
              _ScrollArrow(icon: Icons.chevron_left, onTap: _scrollLeft),

            // Tab headers
            Expanded(
              child: Stack(
                children: [
                  // Tab list
                  ListView.builder(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    itemCount: tabs.length,
                    itemBuilder: (context, index) {
                      final tab = tabs[index];
                      final isActive = index == widget.controller.activeIndex;
                      return _TabHeader(
                        tab: tab,
                        isActive: isActive,
                        onTap: () => widget.controller.select(index),
                        onClose: tab.closable
                            ? () => widget.onClose?.call(tab.id)
                            : null,
                      );
                    },
                  ),

                  // Left gradient fade
                  if (widget.showScrollFades && _canScrollLeft)
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      width: 24,
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [bgColor, bgColor.withValues(alpha: 0)],
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Right gradient fade
                  if (widget.showScrollFades && _canScrollRight)
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      width: 24,
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerRight,
                              end: Alignment.centerLeft,
                              colors: [bgColor, bgColor.withValues(alpha: 0)],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Right scroll arrow (visible when can scroll right)
            if (widget.showScrollFades && _canScrollRight)
              _ScrollArrow(icon: Icons.chevron_right, onTap: _scrollRight),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// TAB HEADER
// =============================================================================

/// Individual tab header widget with hover, active, badge, and close states.
class _TabHeader extends StatefulWidget {
  final DSTab tab;
  final bool isActive;
  final VoidCallback? onTap;
  final VoidCallback? onClose;

  const _TabHeader({
    required this.tab,
    required this.isActive,
    this.onTap,
    this.onClose,
  });

  @override
  State<_TabHeader> createState() => _TabHeaderState();
}

class _TabHeaderState extends State<_TabHeader> {
  bool _isHovered = false;
  bool _isCloseHovered = false;
  bool _isFocused = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.isActive;
    final activeAccent = DSTheme.accentOf(context);
    final focusRing = DSTheme.focusRingOf(context);

    // Active: accent background + accent text
    // Hover: subtle elevated background
    // Inactive: transparent
    final bgColor = isActive
        ? activeAccent.withValues(alpha: 0.08)
        : (_isHovered ? DSColors.obsidianHover : DSColors.transparent);
    final textColor = isActive ? activeAccent : DSColors.textSecondary;
    final iconColor = isActive ? activeAccent : DSColors.textTertiary;
    final borderColor = isActive ? focusRing : DSColors.transparent;

    Widget tabWidget = Semantics(
      label: 'Tab: ${widget.tab.label}',
      button: true,
      selected: isActive,
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
            if (event.logicalKey == LogicalKeyboardKey.delete &&
                widget.onClose != null) {
              widget.onClose!.call();
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
              curve: DSMotion.standard,
              constraints: const BoxConstraints(minWidth: 80, maxWidth: 200),
              height: DSSpacing.topbarHeight,
              padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md),
              decoration: BoxDecoration(
                color: bgColor,
                border: Border(
                  bottom: BorderSide(color: borderColor, width: 2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon
                  if (widget.tab.icon != null) ...[
                    Icon(widget.tab.icon, size: 16, color: iconColor),
                    const SizedBox(width: DSSpacing.xs),
                  ],

                  // Label
                  Flexible(
                    child: Text(
                      widget.tab.label,
                      style: DSTypography.labelMedium.copyWith(
                        color: _isFocused ? DSColors.textPrimary : textColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),

                  // Badge count
                  if (widget.tab.badgeCount != null &&
                      widget.tab.badgeCount! > 0) ...[
                    const SizedBox(width: DSSpacing.xs),
                    DSBadge.count(
                      widget.tab.badgeCount!,
                      color: isActive ? activeAccent : DSColors.accentViolet,
                      size: DSBadgeSize.small,
                    ),
                  ],

                  // Close button
                  if (widget.onClose != null) ...[
                    const SizedBox(width: DSSpacing.xs),
                    _CloseButton(
                      isHovered: _isCloseHovered,
                      isActive: isActive,
                      onTap: widget.onClose!,
                      onHoverChanged: (hovered) =>
                          setState(() => _isCloseHovered = hovered),
                    ),
                  ],

                  // Focus ring indicator
                  if (_isFocused)
                    Container(
                      width: 0,
                      height: 0,
                      decoration: BoxDecoration(
                        border: Border.all(color: focusRing, width: 2),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // Focus ring decoration
    if (_isFocused) {
      tabWidget = Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: focusRing, width: 2)),
        ),
        child: tabWidget,
      );
    }

    return tabWidget;
  }
}

// =============================================================================
// CLOSE BUTTON
// =============================================================================

class _CloseButton extends StatelessWidget {
  final bool isHovered;
  final bool isActive;
  final VoidCallback onTap;
  final ValueChanged<bool> onHoverChanged;

  const _CloseButton({
    required this.isHovered,
    required this.isActive,
    required this.onTap,
    required this.onHoverChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isHovered
        ? DSColors.statusError.withValues(alpha: 0.2)
        : DSColors.transparent;
    final iconColor = isHovered
        ? DSColors.statusError
        : (isActive ? DSTheme.accentOf(context) : DSColors.textTertiary);

    return Semantics(
      label: 'Close tab',
      button: true,
      child: MouseRegion(
        onEnter: (_) => onHoverChanged(true),
        onExit: (_) => onHoverChanged(false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(DSRadii.xs),
            ),
            child: Icon(Icons.close, size: 14, color: iconColor),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// SCROLL ARROW
// =============================================================================

class _ScrollArrow extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ScrollArrow({required this.icon, required this.onTap});

  @override
  State<_ScrollArrow> createState() => _ScrollArrowState();
}

class _ScrollArrowState extends State<_ScrollArrow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Scroll tab bar',
      button: true,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            width: DSSpacing.iconButtonSizeCompact,
            color: _isHovered ? DSColors.obsidianHover : DSColors.transparent,
            child: Icon(
              widget.icon,
              size: 16,
              color: _isHovered ? DSColors.textPrimary : DSColors.textTertiary,
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// TAB HEADER DELEGATE (for width estimation)
// =============================================================================

abstract class _TabHeaderDelegate {
  /// Estimates the pixel width of a tab header for scroll calculations.
  static double estimatedWidth(DSTab tab) {
    // Icon (16) + gap (4) + label (approx 12px/char, min 60) + badge (28) +
    // close button (24) + padding (24) = generous estimate
    double width = 24; // padding
    if (tab.icon != null) width += 20;
    width += tab.label.length * 7.0 + 20; // text width estimate
    width = width.clamp(80.0, 200.0); // min/max constraints
    if (tab.badgeCount != null && tab.badgeCount! > 0) width += 32;
    if (tab.closable) width += 28;
    return width;
  }
}
