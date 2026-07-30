import 'package:flutter/material.dart';
import '../../atoms/atoms.dart';
import '../../molecules/molecules.dart';
import '../../tokens/tokens.dart';
import '../split_pane/ds_split_pane.dart';
import '../tab_bar/tab_bar.dart';
import 'ds_terminal_workspace_models.dart';

export 'ds_terminal_workspace_models.dart';

// =============================================================================
// Organism Widget
// =============================================================================

/// ASW Observatory Organism — Terminal Workspace
///
/// A sovereign console shell that layouts multiple mock terminal panes,
/// supporting pane focus switching, multiple layouts (horizontal/vertical split, tabs),
/// custom text command entries, and clearance actions.
///
/// Under-the-hood this uses [DSSplitPane], [DSTabBar], and other atomic components
/// to follow the design system Obsidian glass aesthetics.
///
/// **Non-port constraint**: fixture shell only — no xterm.js, no real PTY.
class DSTerminalWorkspace extends StatefulWidget {
  /// State controller managing active panes, focus, and layout selection.
  final DSTerminalWorkspaceController controller;

  /// Custom callback triggered when a mock command is entered in a pane.
  final void Function(String paneId, String command)? onCommandSubmitted;

  /// Optional title displayed in the workspace header panel. Defaults to 'Console Workspace'.
  final String title;

  /// Optional callback to add a new pane.
  final VoidCallback? onAddPane;

  const DSTerminalWorkspace({
    super.key,
    required this.controller,
    this.onCommandSubmitted,
    this.title = 'Console Workspace',
    this.onAddPane,
  });

  @override
  State<DSTerminalWorkspace> createState() => _DSTerminalWorkspaceState();
}

class _DSTerminalWorkspaceState extends State<DSTerminalWorkspace> {
  final Map<String, ScrollController> _scrollControllers = {};
  final Map<String, TextEditingController> _textControllers = {};
  final Map<String, FocusNode> _inputFocusNodes = {};

  /// Last history length auto-scrolled per pane — prevents thrashing user
  /// scroll position on unrelated rebuilds (focus, layout mode, theme).
  final Map<String, int> _lastAutoScrolledHistoryLength = {};

  DSTabController? _tabController;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerModelChanged);
    _syncTabController();
  }

  @override
  void didUpdateWidget(DSTerminalWorkspace oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerModelChanged);
      widget.controller.addListener(_onControllerModelChanged);
      _reconcilePaneResources();
      _syncTabController();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerModelChanged);
    _tabController?.removeListener(_onTabControllerChanged);
    _tabController?.dispose();
    final knownIds = <String>{
      ..._scrollControllers.keys,
      ..._textControllers.keys,
      ..._inputFocusNodes.keys,
    };
    for (final id in knownIds) {
      _disposePaneResources(id);
    }
    super.dispose();
  }

  /// Disposes and evicts per-pane controllers for [paneId].
  void _disposePaneResources(String paneId) {
    _scrollControllers.remove(paneId)?.dispose();
    _textControllers.remove(paneId)?.dispose();
    _inputFocusNodes.remove(paneId)?.dispose();
    _lastAutoScrolledHistoryLength.remove(paneId);
  }

  /// Evicts resources for panes no longer present on the controller model.
  void _reconcilePaneResources() {
    final activeIds = widget.controller.panes.map((p) => p.id).toSet();
    final knownIds = <String>{
      ..._scrollControllers.keys,
      ..._textControllers.keys,
      ..._inputFocusNodes.keys,
      ..._lastAutoScrolledHistoryLength.keys,
    };
    for (final id in knownIds) {
      if (!activeIds.contains(id)) {
        _disposePaneResources(id);
      }
    }
  }

  /// Debug surface for lifecycle tests — count of owned per-pane resource keys.
  @visibleForTesting
  int get debugOwnedPaneResourceCount => _scrollControllers.length;

  void _onControllerModelChanged() {
    if (!mounted) return;
    _reconcilePaneResources();
    setState(() {
      _syncTabController();
    });
  }

  void _onTabControllerChanged() {
    if (_tabController == null) return;
    final activeTabId = _tabController!.activeTab?.id;
    if (activeTabId != null) {
      widget.controller.focusPane(activeTabId);
    }
  }

  void _syncTabController() {
    final panes = widget.controller.panes;
    if (panes.isEmpty) {
      _tabController?.removeListener(_onTabControllerChanged);
      _tabController?.dispose();
      _tabController = null;
      return;
    }

    final activeIndex = panes.indexWhere(
      (p) => p.id == widget.controller.focusedPaneId,
    );
    final clampedActiveIndex = activeIndex == -1 ? 0 : activeIndex;

    final dsTabs = panes.map((pane) {
      return DSTab(
        id: pane.id,
        label: pane.title,
        icon: pane.icon ?? Icons.terminal_outlined,
        badgeCount: pane.badgeCount,
        closable: true,
        content: (context) => _buildTerminalPaneBody(pane),
      );
    }).toList();

    if (_tabController == null) {
      _tabController = DSTabController(
        tabs: dsTabs,
        activeIndex: clampedActiveIndex,
      );
      _tabController!.addListener(_onTabControllerChanged);
    } else {
      // Prevent notifying listeners circularly.
      _tabController!.removeListener(_onTabControllerChanged);
      _tabController!.setTabs(dsTabs, activeIndex: clampedActiveIndex);
      _tabController!.addListener(_onTabControllerChanged);
    }
  }

  @override
  Widget build(BuildContext context) {
    final panes = widget.controller.panes;

    return Semantics(
      label: widget.title,
      child: Container(
        decoration: BoxDecoration(
          color: DSColors.obsidianDeep,
          borderRadius: BorderRadius.circular(DSRadii.lg),
          border: Border.all(color: DSColors.borderSubtle),
          boxShadow: DSShadows.elevation2,
        ),
        child: Column(
          children: [
            // Workspace Header Toolbar
            _buildWorkspaceHeader(),

            // Workspace Main Area
            Expanded(
              child: panes.isEmpty
                  ? _buildEmptyState()
                  : _buildPanesLayout(panes),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkspaceHeader() {
    final mode = widget.controller.layoutMode;

    return Container(
      height: DSSpacing.topbarHeight,
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md),
      decoration: const BoxDecoration(
        color: DSColors.obsidianBase,
        border: Border(bottom: BorderSide(color: DSColors.borderSubtle)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.terminal_outlined,
            size: 20,
            color: DSColors.accentCyan,
          ),
          const SizedBox(width: DSSpacing.sm),
          DSText.headingSmall(widget.title, color: DSColors.textPrimary),
          const Spacer(),

          // Add Terminal Button
          if (widget.onAddPane != null) ...[
            Semantics(
              label: 'Add terminal pane',
              button: true,
              child: IconButton(
                icon: const Icon(Icons.add, size: 20),
                color: DSColors.textSecondary,
                onPressed: widget.onAddPane,
                tooltip: 'Add Pane',
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              ),
            ),
            const SizedBox(width: DSSpacing.xs),
          ],

          // Tabs Mode Selector Button
          Semantics(
            label: 'Switch to tabbed layout',
            button: true,
            selected: mode == DSTerminalLayoutMode.tabs,
            child: IconButton(
              icon: const Icon(Icons.tab_outlined, size: 20),
              color: mode == DSTerminalLayoutMode.tabs
                  ? DSColors.accentCyan
                  : DSColors.textTertiary,
              onPressed: () =>
                  widget.controller.setLayoutMode(DSTerminalLayoutMode.tabs),
              tooltip: 'Tabbed View',
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            ),
          ),

          // Horizontal Split Selector Button
          Semantics(
            label: 'Switch to horizontal split layout',
            button: true,
            selected: mode == DSTerminalLayoutMode.splitHorizontal,
            child: IconButton(
              icon: const Icon(Icons.splitscreen_outlined, size: 20),
              color: mode == DSTerminalLayoutMode.splitHorizontal
                  ? DSColors.accentCyan
                  : DSColors.textTertiary,
              onPressed: () => widget.controller.setLayoutMode(
                DSTerminalLayoutMode.splitHorizontal,
              ),
              tooltip: 'Split Horizontal',
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            ),
          ),

          // Vertical Split Selector Button
          Semantics(
            label: 'Switch to vertical split layout',
            button: true,
            selected: mode == DSTerminalLayoutMode.splitVertical,
            child: IconButton(
              // Rotate by 90 degrees or use vertical split screen icon
              icon: const RotatedBox(
                quarterTurns: 1,
                child: Icon(Icons.splitscreen_outlined, size: 20),
              ),
              color: mode == DSTerminalLayoutMode.splitVertical
                  ? DSColors.accentCyan
                  : DSColors.textTertiary,
              onPressed: () => widget.controller.setLayoutMode(
                DSTerminalLayoutMode.splitVertical,
              ),
              tooltip: 'Split Vertical',
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return DSStateSurface.empty(
      icon: Icons.terminal_outlined,
      title: 'No console panes',
      subtitle: 'Open a new terminal pane to begin monitoring workspaces.',
      actionLabel: widget.onAddPane != null ? 'Create Console' : null,
      onAction: widget.onAddPane,
    );
  }

  Widget _buildPanesLayout(List<DSTerminalPane> panes) {
    final mode = widget.controller.layoutMode;

    if (mode == DSTerminalLayoutMode.tabs && _tabController != null) {
      return Column(
        children: [
          DSTabBar(
            controller: _tabController!,
            onClose: (id) => widget.controller.closePane(id),
          ),
          Expanded(child: DSTabView(controller: _tabController!)),
        ],
      );
    }

    final axis = mode == DSTerminalLayoutMode.splitVertical
        ? Axis.vertical
        : Axis.horizontal;
    return _buildRecursiveSplit(panes, axis);
  }

  Widget _buildRecursiveSplit(List<DSTerminalPane> panesList, Axis axis) {
    if (panesList.isEmpty) return const SizedBox.shrink();
    if (panesList.length == 1) {
      return _buildTerminalPaneShell(panesList.first);
    }

    return DSSplitPane(
      axis: axis,
      initialRatio: 1.0 / panesList.length,
      leading: _buildTerminalPaneShell(panesList.first),
      trailing: _buildRecursiveSplit(panesList.sublist(1), axis),
    );
  }

  Widget _buildTerminalPaneShell(DSTerminalPane pane) {
    final isFocused = widget.controller.focusedPaneId == pane.id;

    return Focus(
      onFocusChange: (focused) {
        if (focused) {
          widget.controller.focusPane(pane.id);
        }
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) {
          widget.controller.focusPane(pane.id);
          _inputFocusNodes[pane.id]?.requestFocus();
        },
        child: Container(
          decoration: BoxDecoration(
            color: DSColors.obsidianBase,
            border: Border.all(
              color: isFocused
                  ? DSColors.accentCyan.withValues(alpha: 0.4)
                  : DSColors.borderSubtle,
              width: 1,
            ),
          ),
          child: Column(
            children: [
              // Individual Pane Titlebar
              _buildPaneTitleBar(pane, isFocused),

              // Pane Inner Body
              Expanded(child: _buildTerminalPaneBody(pane)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaneTitleBar(DSTerminalPane pane, bool isFocused) {
    // Content row is exactly 48dp; hairline separator sits outside so
    // BoxDecoration border insets cannot shrink chrome below WCAG targets.
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ColoredBox(
          color: isFocused
              ? DSColors.accentCyan.withValues(alpha: 0.05)
              : DSColors.obsidianElevated,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: DSSpacing.sm),
            child: SizedBox(
              height: 48,
              child: Row(
                children: [
                  Icon(
                    pane.icon ?? Icons.terminal_outlined,
                    size: 14,
                    color: isFocused
                        ? DSColors.accentCyan
                        : DSColors.textTertiary,
                  ),
                  const SizedBox(width: DSSpacing.xs),
                  Expanded(
                    child: DSText.labelSmall(
                      pane.title,
                      color: isFocused
                          ? DSColors.accentCyan
                          : DSColors.textSecondary,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Clear history button (WCAG 2.5.5 min 48×48 target)
                  Semantics(
                    label: 'Clear console output for ${pane.title}',
                    button: true,
                    child: SizedBox.square(
                      dimension: 48,
                      child: IconButton(
                        icon: const Icon(Icons.delete_outline, size: 16),
                        color: DSColors.textTertiary,
                        onPressed: () =>
                            widget.controller.clearHistory(pane.id),
                        tooltip: 'Clear Output',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints.tightFor(
                          width: 48,
                          height: 48,
                        ),
                        style: IconButton.styleFrom(
                          minimumSize: const Size(48, 48),
                          maximumSize: const Size(48, 48),
                          padding: EdgeInsets.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.standard,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: DSSpacing.xs),

                  // Close Pane button (WCAG 2.5.5 min 48×48 target)
                  Semantics(
                    label: 'Close console pane ${pane.title}',
                    button: true,
                    child: SizedBox.square(
                      dimension: 48,
                      child: IconButton(
                        icon: const Icon(Icons.close, size: 16),
                        color: DSColors.textTertiary,
                        onPressed: () => widget.controller.closePane(pane.id),
                        tooltip: 'Close Pane',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints.tightFor(
                          width: 48,
                          height: 48,
                        ),
                        style: IconButton.styleFrom(
                          minimumSize: const Size(48, 48),
                          maximumSize: const Size(48, 48),
                          padding: EdgeInsets.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.standard,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const ColoredBox(
          color: DSColors.borderSubtle,
          child: SizedBox(height: 1, width: double.infinity),
        ),
      ],
    );
  }

  Widget _buildTerminalPaneBody(DSTerminalPane pane) {
    final scrollController = _scrollControllers.putIfAbsent(
      pane.id,
      ScrollController.new,
    );
    final textController = _textControllers.putIfAbsent(
      pane.id,
      TextEditingController.new,
    );
    final focusNode = _inputFocusNodes.putIfAbsent(pane.id, FocusNode.new);
    final paneId = pane.id;
    final historyLength = pane.history.length;
    final previousLength = _lastAutoScrolledHistoryLength[paneId];

    // Auto-scroll only when history *grows* (new log lines). Never thrash
    // user scroll on focus/layout rebuilds. Re-lookup + mounted for dispose
    // races after close.
    if (previousLength == null || historyLength > previousLength) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final liveScroll = _scrollControllers[paneId];
        if (liveScroll == null || !liveScroll.hasClients) return;
        // Record only after a successful client attach so a failed frame can
        // retry if history is still longer than last committed length.
        _lastAutoScrolledHistoryLength[paneId] = historyLength;
        liveScroll.animateTo(
          liveScroll.position.maxScrollExtent,
          duration: DSMotion.normal,
          curve: DSMotion.standard,
        );
      });
    } else if (historyLength < (previousLength)) {
      // History cleared or shortened — reset tracker without animating.
      _lastAutoScrolledHistoryLength[paneId] = historyLength;
    }

    return Column(
      children: [
        // Log stream list area
        Expanded(
          child: pane.history.isEmpty
              ? _buildPaneEmptyState()
              : Semantics(
                  label: '${pane.title} output logs',
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(DSSpacing.sm),
                    itemCount: pane.history.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 2.0),
                        child: Text(
                          pane.history[index],
                          style: DSTypography.codeSmall.copyWith(
                            color: DSColors.textSecondary,
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),

        // Terminal input row
        _buildTerminalInputRow(pane, textController, focusNode),
      ],
    );
  }

  Widget _buildPaneEmptyState() {
    return const Center(
      child: DSText.bodySmall(
        'Console log stream empty. Type below to trigger mock outputs.',
        color: DSColors.textTertiary,
      ),
    );
  }

  Widget _buildTerminalInputRow(
    DSTerminalPane pane,
    TextEditingController textController,
    FocusNode focusNode,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.sm,
        vertical: DSSpacing.xs,
      ),
      decoration: const BoxDecoration(
        color: DSColors.obsidianDeep,
        border: Border(top: BorderSide(color: DSColors.borderSubtle)),
      ),
      child: Row(
        children: [
          const DSText(
            '> ',
            variant: DSTextVariant.codeMedium,
            color: DSColors.accentCyan,
          ),
          Expanded(
            child: Semantics(
              label: 'Command line input for ${pane.title}',
              textField: true,
              child: Focus(
                onFocusChange: (focused) {
                  if (focused) {
                    widget.controller.focusPane(pane.id);
                  }
                },
                child: TextField(
                  controller: textController,
                  focusNode: focusNode,
                  style: DSTypography.codeMedium.copyWith(
                    color: DSColors.textPrimary,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Enter tactile command...',
                    hintStyle: TextStyle(
                      color: DSColors.textTertiary,
                      fontSize: 13,
                    ),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 6.0),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                  ),
                  onSubmitted: (value) {
                    final command = value.trim();
                    if (command.isNotEmpty) {
                      widget.onCommandSubmitted?.call(pane.id, command);
                      textController.clear();
                    }
                    focusNode.requestFocus();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
