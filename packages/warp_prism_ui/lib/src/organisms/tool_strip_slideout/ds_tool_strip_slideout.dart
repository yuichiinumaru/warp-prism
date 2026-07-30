import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../atoms/ds_glass_panel.dart';
import '../../atoms/ds_icon.dart';
import '../../atoms/ds_text.dart';
import '../../tokens/tokens.dart';

/// A single tool entry for [DSToolStripSlideout].
///
/// Fixture-friendly: [builder] supplies panel body content only — no live
/// backends or product-route coupling.
class DSToolStripItem {
  /// Stable tool identity used for exclusive selection.
  final String id;

  /// Icon shown on the vertical strip.
  final IconData icon;

  /// Human-readable name — also the Semantics label for the strip button.
  final String label;

  /// Builds the slideout body when this tool is active.
  final WidgetBuilder builder;

  /// Optional tooltip; defaults to [label] when null.
  final String? tooltip;

  const DSToolStripItem({
    required this.id,
    required this.icon,
    required this.label,
    required this.builder,
    this.tooltip,
  });
}

/// ASW Observatory Organism — Tool Strip Slideout
///
/// Vertical **icon tool strip** + exclusive **glass slideout body**. Opening
/// tool B closes tool A. Collapse returns to strip-only (no body).
///
/// Selection:
/// - Uncontrolled (default): leave [activeToolId] null; organism owns selection
///   via internal state (starts collapsed).
/// - Controlled: pass [activeToolId] on every rebuild (open id, or `null` after
///   a prior non-null so [didUpdateWidget] can clear). Prefer pairing with
///   [onActiveToolChanged] and lifting state to the parent.
/// - [onActiveToolChanged] reports the **new** active id (`null` = collapsed)
///
/// No live recon backends — fixture tools only (gallery / HUD host).
class DSToolStripSlideout extends StatefulWidget {
  /// Ordered tool entries rendered on the strip (top → bottom).
  final List<DSToolStripItem> tools;

  /// Controlled active tool id. When null and parent has never driven a
  /// non-null id, selection is unmanaged internally (default collapsed).
  ///
  /// When non-null, that tool is open. When parent later passes `null`,
  /// [didUpdateWidget] syncs internal state so the panel collapses.
  final String? activeToolId;

  /// Called with the **new** active tool id when the user selects or collapses.
  final ValueChanged<String?>? onActiveToolChanged;

  /// Which edge the strip anchors to. Defaults to [AxisDirection.right]
  /// (slideout opens toward the interior / left of the strip).
  final AxisDirection side;

  /// Width of the icon strip in logical pixels.
  final double stripWidth;

  /// Width of the open slideout body in logical pixels.
  final double panelWidth;

  /// Whether to wrap the slideout body in [DSGlassPanel]. Defaults to true.
  final bool wrapPanelInGlass;

  /// Whether to show a close control in the panel header. Defaults to true.
  final bool showCloseButton;

  /// Optional header trailing slot (beside the tool title / close).
  final Widget? panelHeaderTrailing;

  const DSToolStripSlideout({
    super.key,
    required this.tools,
    this.activeToolId,
    this.onActiveToolChanged,
    this.side = AxisDirection.right,
    this.stripWidth = 56,
    this.panelWidth = 320,
    this.wrapPanelInGlass = true,
    this.showCloseButton = true,
    this.panelHeaderTrailing,
  }) : assert(
         side == AxisDirection.left || side == AxisDirection.right,
         'DSToolStripSlideout only supports left/right sides',
       );

  /// Stable keys for tests and semantic tooling.
  static const Key stripRegionKey = Key('ds-tool-strip');
  static const Key panelRegionKey = Key('ds-tool-strip-panel');
  static const Key closeButtonKey = Key('ds-tool-strip-close');

  /// Key for an individual tool button by [toolId].
  static Key toolButtonKey(String toolId) => Key('ds-tool-strip-btn-$toolId');

  /// Workspace container semantic label.
  static const String stripSemanticLabel = 'Tool strip';

  /// Semantic label for the panel close control.
  static const String closeSemanticLabel = 'Close tool panel';

  /// Semantic label for a tool button (includes selected when active).
  static String toolSemanticLabel(String label, {required bool selected}) =>
      selected ? '$label, selected' : label;

  @override
  State<DSToolStripSlideout> createState() => _DSToolStripSlideoutState();
}

class _DSToolStripSlideoutState extends State<DSToolStripSlideout> {
  String? _internalActiveId;

  /// Parent is considered to own selection when [activeToolId] is non-null,
  /// or after a controlled open has been cleared via prop sync.
  bool _parentDriven = false;

  String? get _effectiveActiveId {
    if (_parentDriven || widget.activeToolId != null) {
      return widget.activeToolId;
    }
    return _internalActiveId;
  }

  @override
  void didUpdateWidget(covariant DSToolStripSlideout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activeToolId != oldWidget.activeToolId) {
      if (widget.activeToolId != null) {
        _parentDriven = true;
      }
      // Sync internal so uncontrolled residual never re-opens a collapsed
      // controlled panel.
      _internalActiveId = widget.activeToolId;
    }
  }

  void _selectTool(String? nextId) {
    if (nextId != null && !widget.tools.any((t) => t.id == nextId)) {
      return;
    }

    final controlled = _parentDriven || widget.activeToolId != null;
    if (!controlled) {
      setState(() => _internalActiveId = nextId);
    } else {
      // Controlled: parent owns the next frame via activeToolId rebuild.
      // Mark driven so a subsequent activeToolId: null collapses correctly.
      _parentDriven = true;
    }
    widget.onActiveToolChanged?.call(nextId);
  }

  void _onToolTapped(DSToolStripItem tool) {
    final current = _effectiveActiveId;
    if (current == tool.id) {
      // Re-tap active tool → collapse to strip-only.
      _selectTool(null);
    } else {
      // Open this tool (exclusive — previous closes implicitly).
      _selectTool(tool.id);
    }
  }

  void _closePanel() => _selectTool(null);

  DSToolStripItem? get _activeTool {
    final id = _effectiveActiveId;
    if (id == null) return null;
    for (final tool in widget.tools) {
      if (tool.id == id) return tool;
    }
    return null;
  }

  bool get _isPanelOpen => _activeTool != null;

  @override
  Widget build(BuildContext context) {
    final isRight = widget.side == AxisDirection.right;
    final panel = _isPanelOpen ? _buildPanel(_activeTool!) : null;
    final strip = _buildStrip();

    final children = isRight
        ? <Widget>[if (panel != null) panel, strip]
        : <Widget>[strip, if (panel != null) panel];

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: DSToolStripSlideout.stripSemanticLabel,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  Widget _buildStrip() {
    return KeyedSubtree(
      key: DSToolStripSlideout.stripRegionKey,
      child: DSGlassPanel.elevated(
        padding: const EdgeInsets.symmetric(
          vertical: DSSpacing.sm,
          horizontal: DSSpacing.xs,
        ),
        child: SizedBox(
          width: widget.stripWidth - DSSpacing.xs * 2,
          child: widget.tools.isEmpty
              ? const SizedBox.shrink()
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < widget.tools.length; i++) ...[
                      if (i > 0) const SizedBox(height: DSSpacing.xs),
                      _ToolStripButton(
                        tool: widget.tools[i],
                        selected: _effectiveActiveId == widget.tools[i].id,
                        onTap: () => _onToolTapped(widget.tools[i]),
                      ),
                    ],
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildPanel(DSToolStripItem tool) {
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PanelHeader(
          title: tool.label,
          showClose: widget.showCloseButton,
          trailing: widget.panelHeaderTrailing,
          onClose: _closePanel,
        ),
        const SizedBox(height: DSSpacing.sm),
        Expanded(child: tool.builder(context)),
      ],
    );

    final wrapped = widget.wrapPanelInGlass
        ? DSGlassPanel.elevated(
            padding: const EdgeInsets.all(DSSpacing.sm),
            child: body,
          )
        : body;

    return KeyedSubtree(
      key: DSToolStripSlideout.panelRegionKey,
      child: AnimatedContainer(
        duration: DSMotion.panelDuration,
        curve: DSMotion.panelCurve,
        width: widget.panelWidth,
        margin: widget.side == AxisDirection.right
            ? const EdgeInsets.only(right: DSSpacing.sm)
            : const EdgeInsets.only(left: DSSpacing.sm),
        child: wrapped,
      ),
    );
  }
}

class _PanelHeader extends StatelessWidget {
  final String title;
  final bool showClose;
  final Widget? trailing;
  final VoidCallback onClose;

  const _PanelHeader({
    required this.title,
    required this.showClose,
    required this.trailing,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: DSText.labelLarge(title, color: DSColors.textPrimary)),
        if (trailing != null) ...[
          trailing!,
          const SizedBox(width: DSSpacing.xs),
        ],
        if (showClose)
          Semantics(
            key: DSToolStripSlideout.closeButtonKey,
            button: true,
            enabled: true,
            label: DSToolStripSlideout.closeSemanticLabel,
            excludeSemantics: true,
            child: _IconHitTarget(
              icon: Icons.close,
              onTap: onClose,
              tooltip: DSToolStripSlideout.closeSemanticLabel,
            ),
          ),
      ],
    );
  }
}

class _ToolStripButton extends StatefulWidget {
  final DSToolStripItem tool;
  final bool selected;
  final VoidCallback onTap;

  const _ToolStripButton({
    required this.tool,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_ToolStripButton> createState() => _ToolStripButtonState();
}

class _ToolStripButtonState extends State<_ToolStripButton> {
  late final FocusNode _focusNode;
  bool _hovered = false;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode(debugLabel: 'tool-strip-${widget.tool.id}');
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.selected;
    final highlight = selected || _hovered || _focused;
    final bg = selected
        ? DSColors.obsidianActive
        : highlight
        ? DSColors.obsidianHover
        : Colors.transparent;
    final iconColor = selected
        ? DSColors.accentCyan
        : highlight
        ? DSColors.textPrimary
        : DSColors.textSecondary;
    final borderColor = selected
        ? DSColors.accentCyan.withValues(alpha: 0.55)
        : _focused
        ? DSColors.accentCyan.withValues(alpha: 0.4)
        : DSColors.borderSubtle.withValues(alpha: 0.0);

    final label = DSToolStripSlideout.toolSemanticLabel(
      widget.tool.label,
      selected: selected,
    );

    return Semantics(
      key: DSToolStripSlideout.toolButtonKey(widget.tool.id),
      button: true,
      enabled: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: Tooltip(
        message: widget.tool.tooltip ?? widget.tool.label,
        waitDuration: const Duration(milliseconds: 400),
        child: Focus(
          focusNode: _focusNode,
          onFocusChange: (focused) => setState(() => _focused = focused),
          onKeyEvent: (node, event) {
            if (event is KeyDownEvent &&
                (event.logicalKey == LogicalKeyboardKey.enter ||
                    event.logicalKey == LogicalKeyboardKey.space)) {
              widget.onTap();
              return KeyEventResult.handled;
            }
            return KeyEventResult.ignored;
          },
          child: MouseRegion(
            onEnter: (_) => setState(() => _hovered = true),
            onExit: (_) => setState(() => _hovered = false),
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: widget.onTap,
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: DSMotion.fast,
                curve: DSMotion.standard,
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(DSRadii.md),
                  border: Border.all(color: borderColor),
                ),
                alignment: Alignment.center,
                child: ExcludeSemantics(
                  child: DSIcon(widget.tool.icon, color: iconColor, size: 22),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact icon hit target for panel chrome (close, etc.).
class _IconHitTarget extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  const _IconHitTarget({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  @override
  State<_IconHitTarget> createState() => _IconHitTargetState();
}

class _IconHitTargetState extends State<_IconHitTarget> {
  bool _hovered = false;
  bool _focused = false;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode(debugLabel: 'tool-strip-icon-hit');
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final highlight = _hovered || _focused;
    return Tooltip(
      message: widget.tooltip,
      child: Focus(
        focusNode: _focusNode,
        onFocusChange: (focused) => setState(() => _focused = focused),
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent &&
              (event.logicalKey == LogicalKeyboardKey.enter ||
                  event.logicalKey == LogicalKeyboardKey.space)) {
            widget.onTap();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: widget.onTap,
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: DSMotion.fast,
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              decoration: BoxDecoration(
                color: highlight ? DSColors.obsidianHover : Colors.transparent,
                borderRadius: BorderRadius.circular(DSRadii.sm),
                border: Border.all(
                  color: _focused
                      ? DSColors.accentCyan.withValues(alpha: 0.5)
                      : Colors.transparent,
                ),
              ),
              alignment: Alignment.center,
              child: DSIcon(
                widget.icon,
                color: highlight ? DSColors.accentCyan : DSColors.textSecondary,
                size: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
