import 'package:flutter/material.dart';
import '../ds_shell.dart';
import '../ds_sidebar_sections.dart';
import '../split_pane/ds_split_pane.dart';

/// Shell focus slot (ADS projection of the IDS slot vocabulary).
///
/// Mirrors IDS `ShellSlot` as plain presentation data so this organism stays
/// dependency-light (no `warp_prism_interaction` import in `lib/`). The
/// equivalence proof (IDS slot ⇔ this enum order) lives in the widget test.
enum DSShellSlot { sidebar, content, inspector }

/// Focus-return token (ADS projection of the IDS token).
///
/// Derived by the product from the last committed IDS layout and handed to
/// the router; the router performs only the mechanics (focus request +
/// scroll edge application). Never invented inside the widget.
@immutable
class DSFocusReturnToken {
  /// Pane to restore focus to. Empty means "no target — do not invent one".
  final String paneId;

  /// Slot hosting the pane at commit time.
  final DSShellSlot slot;

  const DSFocusReturnToken({
    required this.paneId,
    this.slot = DSShellSlot.content,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DSFocusReturnToken &&
          other.paneId == paneId &&
          other.slot == slot);

  @override
  int get hashCode => Object.hash(paneId, slot);
}

/// Layout snapshot the router renders: which panes exist per slot.
@immutable
class DSShellRouterLayout {
  /// Sidebar content (typically [DSSidebarSections]).
  final Widget sidebar;

  /// Content panes keyed by pane id. At least one entry required.
  final Map<String, Widget> contentPanes;

  /// Active content pane id.
  final String activeContentPane;

  /// Optional inspector widget (detail slot).
  final Widget? inspector;

  /// Whether the inspector slot is shown.
  final bool showInspector;

  /// Optional trailing content pane for the split (null = single pane).
  final String? trailingContentPane;

  const DSShellRouterLayout({
    required this.sidebar,
    required this.contentPanes,
    required this.activeContentPane,
    this.inspector,
    this.showInspector = false,
    this.trailingContentPane,
  });
}

/// IDS shell-slot router organism (ADS, EXPERIMENTAL).
///
/// Composes [DSShell] + [DSSplitPane] + sidebar sections with deterministic
/// focus restoration: whenever [focusToken] changes to a non-empty pane, the
/// router post-frames a focus request to that pane's registered [FocusNode]
/// and reports via [onFocusRestored]. Mechanics stay ADS (FocusNode,
/// FocusTraversalGroup, ScrollController); IDS owns only the token semantics.
///
/// Determinism: no transition-animation-dependent state; layout switches are
/// instant (`DSMotion.instant`-grade, no animated timers).
///
/// Lifecycle: EXPERIMENTAL. No barrel export, no `Prism*` alias; import this
/// file directly from `src/` while experimental.
class DSShellRouter extends StatefulWidget {
  /// Layout snapshot to render.
  final DSShellRouterLayout layout;

  /// Focus-return token derived from the last committed IDS layout.
  final DSFocusReturnToken focusToken;

  /// Sidebar sections model backing the sidebar slot (documentation aid;
  /// the rendered sidebar comes from [layout.sidebar]).
  final List<DSSidebarSection> sidebarSections;

  /// Scroll edge to apply alongside focus (opaque caller offset).
  final double? scrollEdgeOffset;

  /// Called after the router restores focus to [focusToken.paneId].
  final ValueChanged<String>? onFocusRestored;

  /// Topbar widget forwarded to [DSShell].
  final Widget? topbar;

  const DSShellRouter({
    super.key,
    required this.layout,
    required this.focusToken,
    this.sidebarSections = const [],
    this.scrollEdgeOffset,
    this.onFocusRestored,
    this.topbar,
  });

  @override
  State<DSShellRouter> createState() => _DSShellRouterState();
}

class _DSShellRouterState extends State<DSShellRouter> {
  final Map<String, FocusNode> _paneNodes = {};
  final Map<String, ScrollController> _paneScrollers = {};
  String? _restoredForToken;

  FocusNode _nodeFor(String paneId) {
    return _paneNodes.putIfAbsent(
      paneId,
      () => FocusNode(debugLabel: 'shell-router:$paneId'),
    );
  }

  ScrollController _scrollerFor(String paneId) {
    return _paneScrollers.putIfAbsent(paneId, ScrollController.new);
  }

  @override
  void dispose() {
    for (final node in _paneNodes.values) {
      node.dispose();
    }
    for (final scroller in _paneScrollers.values) {
      scroller.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(DSShellRouter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusToken != widget.focusToken) {
      _restoredForToken = null;
      _scheduleRestore();
    }
    final stale = _paneNodes.keys
        .where((paneId) => !widget.layout.contentPanes.containsKey(paneId))
        .toList(growable: false);
    for (final paneId in stale) {
      _paneNodes.remove(paneId)?.dispose();
      _paneScrollers.remove(paneId)?.dispose();
    }
  }

  @override
  void initState() {
    super.initState();
    _scheduleRestore();
  }

  void _scheduleRestore() {
    final paneId = widget.focusToken.paneId;
    if (paneId.isEmpty) return;
    if (!widget.layout.contentPanes.containsKey(paneId)) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final node = _paneNodes[paneId];
      if (node == null || !node.canRequestFocus) return;
      node.requestFocus();
      final edge = widget.scrollEdgeOffset;
      if (edge != null && _paneScrollers.containsKey(paneId)) {
        final scroller = _paneScrollers[paneId]!;
        if (scroller.hasClients) {
          final target = edge
              .clamp(0.0, scroller.position.maxScrollExtent)
              .toDouble();
          scroller.jumpTo(target);
        }
      }
      if (_restoredForToken != paneId) {
        _restoredForToken = paneId;
        widget.onFocusRestored?.call(paneId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final layout = widget.layout;
    final active =
        layout.contentPanes[layout.activeContentPane] ??
        layout.contentPanes.values.first;

    Widget content;
    final trailingId = layout.trailingContentPane;
    if (trailingId != null && layout.contentPanes.containsKey(trailingId)) {
      content = DSSplitPane(
        leading: _PannedPane(
          paneId: layout.activeContentPane,
          focusNode: _nodeFor(layout.activeContentPane),
          scroller: _scrollerFor(layout.activeContentPane),
          child: active,
        ),
        trailing: _PannedPane(
          paneId: trailingId,
          focusNode: _nodeFor(trailingId),
          scroller: _scrollerFor(trailingId),
          child: layout.contentPanes[trailingId]!,
        ),
      );
    } else {
      content = _PannedPane(
        paneId: layout.activeContentPane,
        focusNode: _nodeFor(layout.activeContentPane),
        scroller: _scrollerFor(layout.activeContentPane),
        child: active,
      );
    }

    return Semantics(
      label: 'Shell router. Active pane ${layout.activeContentPane}.',
      explicitChildNodes: true,
      child: DSShell(
        sidebar: layout.sidebar,
        topbar: widget.topbar,
        content: content,
        inspector: layout.inspector,
        showInspector: layout.showInspector && layout.inspector != null,
      ),
    );
  }
}

/// Focus + scroll host for one content pane.
///
/// Registers the pane's [FocusNode] eagerly so post-frame restoration never
/// misses, and exposes the [ScrollController] for edge application.
class _PannedPane extends StatelessWidget {
  final String paneId;
  final FocusNode focusNode;
  final ScrollController scroller;
  final Widget child;

  const _PannedPane({
    required this.paneId,
    required this.focusNode,
    required this.scroller,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: focusNode,
      child: SingleChildScrollView(
        controller: scroller,
        key: ValueKey('shell-router-scroll:$paneId'),
        child: child,
      ),
    );
  }
}
