import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../atoms/ds_glass_panel.dart';
import '../../atoms/ds_icon.dart';
import '../../tokens/tokens.dart';

/// ASW Observatory Organism — Map HUD Workspace
///
/// Full-bleed **stage + multi-region HUD** layout for map-first / canvas-first
/// ops desktops. Distinct from [DSShell]: this is not nav-first app chrome.
///
/// Regions:
/// - [stage] — required full-bleed content slot (placeholder map, graph, etc.)
/// - [leftHud] / [rightHud] — optional glass rails
/// - [bottomChrome] / [topChrome] — optional edge chrome clusters
///
/// Visibility:
/// - [hudVisible] when non-null is **controlled** by the parent
/// - when null, the organism manages hide/restore internally (default visible)
/// - [onToggleHudVisibility] reports the **new** visibility value
/// - hide/restore never disposes [stage]
///
/// No MapLibre, no product-route coupling — fixture/gallery host only.
class DSMapHudWorkspace extends StatefulWidget {
  /// Full-bleed stage child (map/canvas/placeholder). Always kept in the tree.
  final Widget stage;

  /// Optional left rail HUD content.
  final Widget? leftHud;

  /// Optional right strip HUD content.
  final Widget? rightHud;

  /// Optional bottom chrome (ticker, coord bar, status).
  final Widget? bottomChrome;

  /// Optional top chrome cluster (ops controls, locate bar).
  final Widget? topChrome;

  /// Controlled HUD visibility. When null, visibility is unmanaged internally
  /// and defaults to `true`.
  final bool? hudVisible;

  /// Called with the **new** visibility when the user toggles HUD chrome.
  final ValueChanged<bool>? onToggleHudVisibility;

  /// Whether to render the built-in hide/restore control. Defaults to true.
  final bool showHudToggle;

  /// Width of the left HUD rail in logical pixels.
  final double leftHudWidth;

  /// Width of the right HUD strip in logical pixels.
  final double rightHudWidth;

  /// Height of the bottom chrome band in logical pixels.
  final double bottomChromeHeight;

  /// Height of the top chrome band in logical pixels.
  final double topChromeHeight;

  /// Edge inset between viewport bounds and HUD panels.
  final double hudInset;

  /// When true (default), wrap each provided HUD slot in [DSGlassPanel].
  final bool wrapHudInGlass;

  const DSMapHudWorkspace({
    super.key,
    required this.stage,
    this.leftHud,
    this.rightHud,
    this.bottomChrome,
    this.topChrome,
    this.hudVisible,
    this.onToggleHudVisibility,
    this.showHudToggle = true,
    this.leftHudWidth = 280,
    this.rightHudWidth = 320,
    this.bottomChromeHeight = 72,
    this.topChromeHeight = 56,
    this.hudInset = DSSpacing.md,
    this.wrapHudInGlass = true,
  });

  /// Stable keys for tests and semantic tooling.
  static const Key stageRegionKey = Key('ds-map-hud-stage');
  static const Key leftHudRegionKey = Key('ds-map-hud-left');
  static const Key rightHudRegionKey = Key('ds-map-hud-right');
  static const Key bottomChromeRegionKey = Key('ds-map-hud-bottom');
  static const Key topChromeRegionKey = Key('ds-map-hud-top');
  static const Key hudToggleKey = Key('ds-map-hud-toggle');

  /// Semantic label when chrome is visible (action hides it).
  static const String hideHudSemanticLabel = 'Hide HUD chrome';

  /// Semantic label when chrome is hidden (action restores it).
  static const String restoreHudSemanticLabel = 'Restore HUD chrome';

  /// Workspace container semantic label.
  static const String workspaceSemanticLabel = 'Map HUD workspace';

  @override
  State<DSMapHudWorkspace> createState() => _DSMapHudWorkspaceState();
}

class _DSMapHudWorkspaceState extends State<DSMapHudWorkspace> {
  bool _internalHudVisible = true;
  final FocusNode _toggleFocusNode = FocusNode(debugLabel: 'map-hud-toggle');
  bool _toggleHovered = false;
  bool _toggleFocused = false;

  bool get _effectiveHudVisible => widget.hudVisible ?? _internalHudVisible;

  @override
  void dispose() {
    _toggleFocusNode.dispose();
    super.dispose();
  }

  void _toggleHud() {
    final next = !_effectiveHudVisible;
    if (widget.hudVisible == null) {
      setState(() => _internalHudVisible = next);
    }
    widget.onToggleHudVisibility?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    final visible = _effectiveHudVisible;
    final inset = widget.hudInset;

    final topLeft = widget.leftHud != null
        ? inset + widget.leftHudWidth + inset
        : inset;
    final topRight = widget.rightHud != null
        ? inset + widget.rightHudWidth + inset
        : inset;
    // Leave room for the toggle when top chrome is present.
    final topRightWithToggle = widget.showHudToggle
        ? topRight + 48 + inset
        : topRight;

    final railTop = widget.topChrome != null
        ? inset + widget.topChromeHeight + inset
        : inset;
    final railBottom = widget.bottomChrome != null
        ? inset + widget.bottomChromeHeight + inset
        : inset;

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: DSMapHudWorkspace.workspaceSemanticLabel,
      child: ColoredBox(
        color: DSColors.obsidianDeep,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Full-bleed stage — always mounted so hide never disposes it.
            Positioned.fill(
              child: KeyedSubtree(
                key: DSMapHudWorkspace.stageRegionKey,
                child: widget.stage,
              ),
            ),

            if (visible) ...[
              if (widget.topChrome != null)
                Positioned(
                  key: DSMapHudWorkspace.topChromeRegionKey,
                  top: inset,
                  left: topLeft,
                  right: topRightWithToggle,
                  height: widget.topChromeHeight,
                  child: _hudChrome(child: widget.topChrome!),
                ),
              if (widget.leftHud != null)
                Positioned(
                  key: DSMapHudWorkspace.leftHudRegionKey,
                  left: inset,
                  top: railTop,
                  bottom: railBottom,
                  width: widget.leftHudWidth,
                  child: _hudChrome(child: widget.leftHud!),
                ),
              if (widget.rightHud != null)
                Positioned(
                  key: DSMapHudWorkspace.rightHudRegionKey,
                  right: inset,
                  top: railTop,
                  bottom: railBottom,
                  width: widget.rightHudWidth,
                  child: _hudChrome(child: widget.rightHud!),
                ),
              if (widget.bottomChrome != null)
                Positioned(
                  key: DSMapHudWorkspace.bottomChromeRegionKey,
                  left: inset,
                  right: inset,
                  bottom: inset,
                  height: widget.bottomChromeHeight,
                  child: _hudChrome(child: widget.bottomChrome!),
                ),
            ],

            if (widget.showHudToggle)
              Positioned(
                top: inset,
                right: inset,
                child: _buildToggle(visible: visible),
              ),
          ],
        ),
      ),
    );
  }

  Widget _hudChrome({required Widget child}) {
    if (!widget.wrapHudInGlass) {
      return child;
    }
    return DSGlassPanel.elevated(
      padding: const EdgeInsets.all(DSSpacing.sm),
      child: child,
    );
  }

  Widget _buildToggle({required bool visible}) {
    final label = visible
        ? DSMapHudWorkspace.hideHudSemanticLabel
        : DSMapHudWorkspace.restoreHudSemanticLabel;
    final icon = visible
        ? Icons.visibility_off_outlined
        : Icons.visibility_outlined;
    final bg = _toggleFocused || _toggleHovered
        ? DSColors.obsidianActive
        : DSColors.glassOverlay.withValues(alpha: 0.7);
    final iconColor = _toggleFocused || _toggleHovered
        ? DSColors.accentCyan
        : DSColors.textSecondary;

    return Semantics(
      key: DSMapHudWorkspace.hudToggleKey,
      button: true,
      enabled: true,
      label: label,
      // Keep a single a11y node; drop Icon/Focus subtree labels.
      excludeSemantics: true,
      child: Focus(
        focusNode: _toggleFocusNode,
        onFocusChange: (focused) => setState(() => _toggleFocused = focused),
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent &&
              (event.logicalKey == LogicalKeyboardKey.enter ||
                  event.logicalKey == LogicalKeyboardKey.space)) {
            _toggleHud();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: MouseRegion(
          onEnter: (_) => setState(() => _toggleHovered = true),
          onExit: (_) => setState(() => _toggleHovered = false),
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: _toggleHud,
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: DSMotion.fast,
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              padding: const EdgeInsets.all(DSSpacing.sm),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(DSRadii.md),
                border: Border.all(
                  color: _toggleFocused
                      ? DSColors.accentCyan.withValues(alpha: 0.6)
                      : DSColors.borderSubtle,
                ),
              ),
              alignment: Alignment.center,
              child: ExcludeSemantics(
                child: DSIcon(icon, color: iconColor, size: 20),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
