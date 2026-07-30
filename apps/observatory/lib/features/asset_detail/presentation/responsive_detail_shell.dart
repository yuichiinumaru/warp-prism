/// Responsive detail shell for universal asset detail integration.
///
/// Renders the detail content using breakpoint-appropriate UX:
///   >= 1200px (wide):     split-pane — master left, detail right
///   800-1199px (medium):  overlay drawer from the right with scrim
///   < 800px (narrow):     full-screen detail with back/close in AppBar
///
/// Consumer surfaces (Map, Operate, History, Governance) delegate
/// to this widget instead of building their own responsive detail
/// layout. Selection state lives in [AssetSelectionController] —
/// this widget is purely presentational.
///
/// **Deep-link contract (intentional):** Canonical `/assets/:assetId`
/// routes render a focused full-page [AssetDetailView] outside this
/// shell. In-shell breakpoints apply only to workspace surfaces that
/// embed [AssetDetailConsumer] / [ResponsiveDetailShell] (Map, Operate,
/// History). Deep-link and in-shell paths share the same universal
/// descriptor + [AssetDetailView] content contract.
library;

import 'package:flutter/material.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// Wraps master + detail content with breakpoint-aware layout.
///
/// When [showDetail] is false, renders only [masterContent].
/// When true, renders both master and detail with the appropriate
/// responsive behavior for the current width.
class ResponsiveDetailShell extends StatefulWidget {
  /// The main content area (catalog, board, timeline, etc.).
  final Widget masterContent;

  /// The detail panel content (inspector).
  final Widget detailContent;

  /// Whether the detail panel is currently visible.
  final bool showDetail;

  /// Called when the user closes the detail panel (close button, back
  /// navigation, or scrim tap on medium layouts).
  final VoidCallback? onDetailClose;

  /// Optional title shown in the narrow-mode AppBar.
  final String? detailTitle;

  /// Optional kind label shown in the narrow-mode AppBar subtitle.
  final String? detailKind;

  const ResponsiveDetailShell({
    super.key,
    required this.masterContent,
    required this.detailContent,
    this.showDetail = false,
    this.onDetailClose,
    this.detailTitle,
    this.detailKind,
  });

  @override
  State<ResponsiveDetailShell> createState() => _ResponsiveDetailShellState();
}

class _ResponsiveDetailShellState extends State<ResponsiveDetailShell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _overlayController;
  late final Animation<Offset> _overlaySlide;

  @override
  void initState() {
    super.initState();
    _overlayController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _overlaySlide = Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _overlayController,
            curve: Curves.easeOutCubic,
          ),
        );

    if (widget.showDetail) {
      _overlayController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(ResponsiveDetailShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showDetail && !oldWidget.showDetail) {
      _overlayController.forward();
    } else if (!widget.showDetail && oldWidget.showDetail) {
      _overlayController.reverse();
    }
  }

  @override
  void dispose() {
    _overlayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showDetail) {
      return widget.masterContent;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        if (width >= PrismBreakpoints.masterDetailSideBySide) {
          return _buildSplitPane();
        } else if (width >= PrismBreakpoints.sidebarCollapse) {
          return _buildOverlay(context);
        } else {
          return _buildFullScreen(context);
        }
      },
    );
  }

  /// Wide layout: side-by-side split pane.
  Widget _buildSplitPane() {
    return Row(
      children: [
        Expanded(flex: 3, child: widget.masterContent),
        Container(width: 1, color: PrismColors.borderSubtle),
        Expanded(flex: 2, child: widget.detailContent),
      ],
    );
  }

  /// Medium layout: overlay drawer from the right with scrim.
  Widget _buildOverlay(BuildContext context) {
    return Stack(
      children: [
        // Master content (dimmed by scrim)
        widget.masterContent,

        // Scrim (tap to close) — explicit button semantics for a11y.
        Positioned.fill(
          child: Semantics(
            label: 'Dismiss detail overlay',
            button: true,
            excludeSemantics: true,
            child: GestureDetector(
              onTap: widget.onDetailClose,
              behavior: HitTestBehavior.opaque,
              child: AnimatedBuilder(
                animation: _overlayController,
                builder: (context, child) {
                  return ColoredBox(
                    color: PrismColors.obsidianDeep.withValues(
                      alpha: 0.5 * _overlayController.value,
                    ),
                  );
                },
              ),
            ),
          ),
        ),

        // Drawer from the right
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          child: SlideTransition(
            position: _overlaySlide,
            child: SizedBox(
              width: PrismSpacing.detailOverlayWidth,
              child: Material(
                elevation: 8,
                color: PrismColors.obsidianElevated,
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      left: BorderSide(color: PrismColors.borderSubtle),
                    ),
                  ),
                  child: widget.detailContent,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Narrow layout: full-screen detail with back navigation.
  Widget _buildFullScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: PrismColors.obsidianDeep,
      appBar: AppBar(
        backgroundColor: PrismColors.obsidianBase,
        foregroundColor: PrismColors.textPrimary,
        elevation: 0,
        leading: Semantics(
          label: 'Close detail and return',
          button: true,
          child: IconButton(
            icon: const PrismIcon(Icons.arrow_back),
            onPressed: widget.onDetailClose,
            tooltip: 'Back',
            autofocus: true,
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.detailTitle != null)
              PrismText.headingMedium(widget.detailTitle!),
            if (widget.detailKind != null)
              PrismText.labelSmall(
                widget.detailKind!.toUpperCase(),
                color: PrismColors.textTertiary,
              ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: PrismColors.borderSubtle),
        ),
      ),
      body: widget.detailContent,
    );
  }
}
