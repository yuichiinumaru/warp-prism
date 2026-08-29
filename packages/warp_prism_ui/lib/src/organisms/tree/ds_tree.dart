import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../atoms/atoms.dart';
import '../../tokens/tokens.dart';
import 'ds_tree_node.dart';

/// ASW Observatory Organism — Hierarchical Tree
///
/// Content control for nested navigation (namespaces, MCP tools, provider
/// trees). Supports expand/collapse, single selection, optional status dots
/// and trailing meta, with keyboard focus for expand controls and rows.
///
/// **Not** app chrome. Do not confuse with [DSSidebar], which is a flat
/// navigation list for the application frame.
///
/// ## Expansion model
///
/// - **Controlled**: pass [expandedIds]; parent owns the set and must update
///   it via [onExpandedIdsChanged].
/// - **Uncontrolled** (default): omit [expandedIds]; the tree seeds from
///   [initiallyExpandedIds] (or empty) and manages expansion internally.
///
/// ## Keyboard
///
/// Visible rows are focusable. Practical desktop keys:
/// - **Enter / Space** on a row selects the node.
/// - **Enter / Space** on the caret toggles expansion.
/// - **Arrow Right** expands (when expandable + collapsed).
/// - **Arrow Left** collapses (when expanded).
/// - **Arrow Up / Down** roves focus across the flattened visible row order
///   (depth-first of expanded branches).
///
/// ## Visual contract
///
/// - Indent by depth using [indentPerLevel] (default [DSSpacing.lg]).
/// - Selected row uses the blue action wash + left accent rail (`accentBlue` alpha) —
///   not OmniRoute teal hardcode.
/// - Glass-friendly: transparent over parent panels; no heavy fills.
class DSTree extends StatefulWidget {
  /// Root-level nodes.
  final List<DSTreeNode> nodes;

  /// Currently selected node id (controlled). Null = none selected.
  final String? selectedId;

  /// Fired when a node row is activated (tap / Enter / Space).
  final ValueChanged<DSTreeNode>? onNodeSelected;

  /// Controlled expansion set. When non-null, the tree does not mutate
  /// expansion itself and relies on [onExpandedIdsChanged].
  final Set<String>? expandedIds;

  /// Seed for uncontrolled expansion. Ignored when [expandedIds] is set.
  final Set<String>? initiallyExpandedIds;

  /// Called when expansion changes (controlled or uncontrolled).
  final ValueChanged<Set<String>>? onExpandedIdsChanged;

  /// Horizontal indent per nesting level.
  final double indentPerLevel;

  /// Optional semantic label for the tree container.
  final String semanticLabel;

  /// When true and [nodes] is empty, shows a compact empty placeholder.
  final bool showEmptyPlaceholder;

  /// Empty-state message when [showEmptyPlaceholder] is true.
  final String emptyLabel;

  const DSTree({
    super.key,
    required this.nodes,
    this.selectedId,
    this.onNodeSelected,
    this.expandedIds,
    this.initiallyExpandedIds,
    this.onExpandedIdsChanged,
    this.indentPerLevel = DSSpacing.lg,
    this.semanticLabel = 'Tree',
    this.showEmptyPlaceholder = true,
    this.emptyLabel = 'No items',
  });

  bool get isExpansionControlled => expandedIds != null;

  @override
  State<DSTree> createState() => _DSTreeState();
}

class _DSTreeState extends State<DSTree> {
  late Set<String> _uncontrolledExpanded;
  final Map<String, FocusNode> _rowFocusNodes = <String, FocusNode>{};

  @override
  void initState() {
    super.initState();
    _uncontrolledExpanded = {
      ...(widget.initiallyExpandedIds ?? const <String>{}),
    };
  }

  @override
  void dispose() {
    for (final node in _rowFocusNodes.values) {
      node.dispose();
    }
    _rowFocusNodes.clear();
    super.dispose();
  }

  @override
  void didUpdateWidget(DSTree oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If switching into uncontrolled mode, re-seed only when the seed changes.
    if (!widget.isExpansionControlled &&
        oldWidget.initiallyExpandedIds != widget.initiallyExpandedIds &&
        oldWidget.isExpansionControlled) {
      _uncontrolledExpanded = {
        ...(widget.initiallyExpandedIds ?? const <String>{}),
      };
    }
  }

  Set<String> get _expanded {
    return widget.expandedIds ?? _uncontrolledExpanded;
  }

  void _setExpanded(String id, bool expand) {
    final next = Set<String>.from(_expanded);
    if (expand) {
      next.add(id);
    } else {
      next.remove(id);
    }
    if (!widget.isExpansionControlled) {
      setState(() => _uncontrolledExpanded = next);
    }
    widget.onExpandedIdsChanged?.call(Set<String>.unmodifiable(next));
  }

  void _toggleExpanded(DSTreeNode node) {
    if (!node.isExpandable) return;
    final isOpen = _expanded.contains(node.id);
    _setExpanded(node.id, !isOpen);
  }

  List<_FlatTreeRow> _flatten() {
    final rows = <_FlatTreeRow>[];
    void walk(List<DSTreeNode> nodes, int depth) {
      for (final node in nodes) {
        final expanded = _expanded.contains(node.id);
        rows.add(_FlatTreeRow(node: node, depth: depth, expanded: expanded));
        if (node.isExpandable && expanded && node.hasChildren) {
          walk(node.children, depth + 1);
        }
      }
    }

    walk(widget.nodes, 0);
    return rows;
  }

  FocusNode _focusNodeFor(String id) {
    return _rowFocusNodes.putIfAbsent(
      id,
      () => FocusNode(debugLabel: 'tree-row-$id'),
    );
  }

  void _scheduleFocusNodeSync(List<_FlatTreeRow> rows) {
    final visible = rows.map((r) => r.node.id).toSet();
    // Dispose off the build path so FocusNodes are never torn down mid-layout.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final stale = _rowFocusNodes.keys
          .where((id) => !visible.contains(id))
          .toList(growable: false);
      for (final id in stale) {
        _rowFocusNodes.remove(id)?.dispose();
      }
    });
  }

  void _moveRowFocus(String currentId, int delta) {
    final rows = _flatten();
    final index = rows.indexWhere((r) => r.node.id == currentId);
    if (index < 0) return;
    final next = index + delta;
    if (next < 0 || next >= rows.length) return;
    final target = _focusNodeFor(rows[next].node.id);
    target.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.nodes.isEmpty) {
      if (!widget.showEmptyPlaceholder) {
        return Semantics(
          label: widget.semanticLabel,
          child: const SizedBox.shrink(),
        );
      }
      return Semantics(
        label: '${widget.semanticLabel}. ${widget.emptyLabel}',
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: DSSpacing.md,
            vertical: DSSpacing.sm,
          ),
          child: DSText.bodySmall(
            widget.emptyLabel,
            color: DSColors.textTertiary,
          ),
        ),
      );
    }

    final rows = _flatten();
    _scheduleFocusNodeSync(rows);

    return Semantics(
      label: widget.semanticLabel,
      container: true,
      explicitChildNodes: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final row in rows)
            _TreeRow(
              key: ValueKey<String>('tree-row-${row.node.id}'),
              node: row.node,
              depth: row.depth,
              expanded: row.expanded,
              selected: widget.selectedId == row.node.id,
              indentPerLevel: widget.indentPerLevel,
              focusNode: _focusNodeFor(row.node.id),
              onSelect: widget.onNodeSelected == null
                  ? null
                  : () => widget.onNodeSelected!(row.node),
              onToggleExpand: row.node.isExpandable
                  ? () => _toggleExpanded(row.node)
                  : null,
              onExpandRequest: row.node.isExpandable && !row.expanded
                  ? () => _setExpanded(row.node.id, true)
                  : null,
              onCollapseRequest: row.node.isExpandable && row.expanded
                  ? () => _setExpanded(row.node.id, false)
                  : null,
              onMoveFocus: (delta) => _moveRowFocus(row.node.id, delta),
            ),
        ],
      ),
    );
  }
}

class _FlatTreeRow {
  final DSTreeNode node;
  final int depth;
  final bool expanded;

  const _FlatTreeRow({
    required this.node,
    required this.depth,
    required this.expanded,
  });
}

class _TreeRow extends StatefulWidget {
  final DSTreeNode node;
  final int depth;
  final bool expanded;
  final bool selected;
  final double indentPerLevel;
  final FocusNode focusNode;
  final VoidCallback? onSelect;
  final VoidCallback? onToggleExpand;
  final VoidCallback? onExpandRequest;
  final VoidCallback? onCollapseRequest;
  final ValueChanged<int>? onMoveFocus;

  const _TreeRow({
    super.key,
    required this.node,
    required this.depth,
    required this.expanded,
    required this.selected,
    required this.indentPerLevel,
    required this.focusNode,
    this.onSelect,
    this.onToggleExpand,
    this.onExpandRequest,
    this.onCollapseRequest,
    this.onMoveFocus,
  });

  @override
  State<_TreeRow> createState() => _TreeRowState();
}

class _TreeRowState extends State<_TreeRow> {
  bool _hovered = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final node = widget.node;
    final accent = DSColors.accentBlue;
    final bgColor = widget.selected
        ? accent.withValues(alpha: 0.12)
        : (_focused
              ? DSColors.obsidianActive
              : (_hovered ? DSColors.obsidianHover : DSColors.transparent));
    final labelColor = widget.selected
        ? accent
        : (_hovered || _focused
              ? DSColors.textPrimary
              : DSColors.textSecondary);

    final statusLabel = node.status?.semanticLabel;
    final metaPart = node.meta != null ? ', ${node.meta}' : '';
    final statusPart = statusLabel != null ? ', $statusLabel' : '';
    final selectedPart = widget.selected ? ', selected' : '';
    final expandPart = node.isExpandable
        ? (widget.expanded ? ', expanded' : ', collapsed')
        : '';
    final semanticLabel =
        '${node.label}$metaPart$statusPart$selectedPart$expandPart';

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: DSMotion.fast,
        constraints: const BoxConstraints(minHeight: 40),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border(
            left: BorderSide(
              color: widget.selected
                  ? accent.withValues(alpha: 0.85)
                  : DSColors.transparent,
              width: 3,
            ),
          ),
        ),
        padding: EdgeInsets.only(
          left: DSSpacing.sm + (widget.depth * widget.indentPerLevel),
          right: DSSpacing.md,
          top: DSSpacing.xs,
          bottom: DSSpacing.xs,
        ),
        child: Row(
          children: [
            // Expand caret is a sibling of the row button so taps never
            // compete with the selection GestureDetector.
            _ExpandCaret(
              expandable: node.isExpandable,
              expanded: widget.expanded,
              onToggle: widget.onToggleExpand,
              label: node.label,
            ),
            const SizedBox(width: DSSpacing.xs),
            Expanded(
              child: Semantics(
                label: semanticLabel,
                selected: widget.selected,
                button: widget.onSelect != null,
                enabled: widget.onSelect != null,
                excludeSemantics: true,
                child: FocusableActionDetector(
                  enabled: true,
                  focusNode: widget.focusNode,
                  onShowFocusHighlight: (focused) {
                    setState(() => _focused = focused);
                  },
                  shortcuts: <ShortcutActivator, Intent>{
                    if (widget.onSelect != null) ...{
                      const SingleActivator(LogicalKeyboardKey.enter):
                          const ActivateIntent(),
                      const SingleActivator(LogicalKeyboardKey.space):
                          const ActivateIntent(),
                    },
                    if (widget.onExpandRequest != null)
                      const SingleActivator(LogicalKeyboardKey.arrowRight):
                          const _ExpandTreeIntent(),
                    if (widget.onCollapseRequest != null)
                      const SingleActivator(LogicalKeyboardKey.arrowLeft):
                          const _CollapseTreeIntent(),
                    if (widget.onMoveFocus != null) ...{
                      const SingleActivator(LogicalKeyboardKey.arrowDown):
                          const _MoveTreeFocusIntent(1),
                      const SingleActivator(LogicalKeyboardKey.arrowUp):
                          const _MoveTreeFocusIntent(-1),
                    },
                  },
                  actions: <Type, Action<Intent>>{
                    if (widget.onSelect != null)
                      ActivateIntent: CallbackAction<ActivateIntent>(
                        onInvoke: (_) {
                          widget.onSelect?.call();
                          return null;
                        },
                      ),
                    if (widget.onExpandRequest != null)
                      _ExpandTreeIntent: CallbackAction<_ExpandTreeIntent>(
                        onInvoke: (_) {
                          widget.onExpandRequest?.call();
                          return null;
                        },
                      ),
                    if (widget.onCollapseRequest != null)
                      _CollapseTreeIntent: CallbackAction<_CollapseTreeIntent>(
                        onInvoke: (_) {
                          widget.onCollapseRequest?.call();
                          return null;
                        },
                      ),
                    if (widget.onMoveFocus != null)
                      _MoveTreeFocusIntent:
                          CallbackAction<_MoveTreeFocusIntent>(
                            onInvoke: (intent) {
                              widget.onMoveFocus?.call(intent.delta);
                              return null;
                            },
                          ),
                  },
                  child: Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      key: Key('tree-node-${node.id}'),
                      onTap: widget.onSelect,
                      // Expand/collapse is owned by the caret IconButton only
                      // (avoid onDoubleTap delaying onTap in widget tests).
                      mouseCursor: widget.onSelect != null
                          ? SystemMouseCursors.click
                          : SystemMouseCursors.basic,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 32),
                        child: Row(
                          children: [
                            if (node.icon != null) ...[
                              DSIcon(
                                node.icon!,
                                color: widget.selected
                                    ? accent
                                    : DSColors.textTertiary,
                                iconSize: DSIconSize.small,
                              ),
                              const SizedBox(width: DSSpacing.sm),
                            ],
                            if (node.status != null) ...[
                              DSStatusDot.operational(node.status!, size: 8),
                              const SizedBox(width: DSSpacing.sm),
                            ],
                            Expanded(
                              child: DSText.labelMedium(
                                node.label,
                                color: labelColor,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (node.meta != null) ...[
                              const SizedBox(width: DSSpacing.sm),
                              DSText.labelSmall(
                                node.meta!,
                                color: DSColors.textTertiary,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpandCaret extends StatelessWidget {
  final bool expandable;
  final bool expanded;
  final VoidCallback? onToggle;
  final String label;

  const _ExpandCaret({
    required this.expandable,
    required this.expanded,
    required this.onToggle,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    if (!expandable) {
      // Reserve space so leaf labels align with expandable siblings.
      return const SizedBox(width: 32, height: 32);
    }

    final actionLabel = expanded ? 'Collapse $label' : 'Expand $label';

    // Explicit Semantics so tests and SR can find Expand/Collapse by label.
    // IconButton alone may map tooltip to hint rather than label.
    return Semantics(
      label: actionLabel,
      button: true,
      enabled: onToggle != null,
      child: IconButton(
        key: Key('tree-expand-$label'),
        onPressed: onToggle,
        iconSize: 18,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        splashRadius: 16,
        tooltip: actionLabel,
        style: IconButton.styleFrom(
          foregroundColor: DSColors.textTertiary,
          hoverColor: DSColors.obsidianHover,
          minimumSize: const Size(32, 32),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        icon: AnimatedRotation(
          turns: expanded ? 0.25 : 0,
          duration: DSMotion.fast,
          child: const Icon(Icons.chevron_right),
        ),
      ),
    );
  }
}

class _ExpandTreeIntent extends Intent {
  const _ExpandTreeIntent();
}

class _CollapseTreeIntent extends Intent {
  const _CollapseTreeIntent();
}

class _MoveTreeFocusIntent extends Intent {
  final int delta;

  const _MoveTreeFocusIntent(this.delta);
}
