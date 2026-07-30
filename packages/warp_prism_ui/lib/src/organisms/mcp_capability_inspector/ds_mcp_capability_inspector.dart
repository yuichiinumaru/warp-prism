import 'package:flutter/material.dart';

import '../../atoms/atoms.dart';
import '../../molecules/ds_interactive_surface.dart';
import '../../molecules/ds_state_surface.dart';
import '../../tokens/tokens.dart';
import '../ds_detail_inspector.dart';
import '../split_pane/ds_split_pane.dart';
import '../tab_bar/ds_tab.dart';
import '../tab_bar/ds_tab_bar.dart';
import '../tab_bar/ds_tab_controller.dart';

// =============================================================================
// Enums + capability flags
// =============================================================================

/// MCP capability section kinds surfaced by [DSMcpCapabilityInspector].
///
/// Matches MCP server capability negotiation (tools / resources / prompts)
/// plus optional stub sections for roots and ping. Fixture-first only —
/// no live JSON-RPC client in this package.
enum DSMcpCapabilityKind {
  /// `tools/list` style capability.
  tools,

  /// `resources/list` style capability.
  resources,

  /// `prompts/list` style capability.
  prompts,

  /// Optional roots stub (list only — no live FS).
  roots,

  /// Optional ping stub (connection health chrome — fixture status only).
  ping,
}

extension DSMcpCapabilityKindX on DSMcpCapabilityKind {
  /// Short tab label.
  String get label => switch (this) {
    DSMcpCapabilityKind.tools => 'Tools',
    DSMcpCapabilityKind.resources => 'Resources',
    DSMcpCapabilityKind.prompts => 'Prompts',
    DSMcpCapabilityKind.roots => 'Roots',
    DSMcpCapabilityKind.ping => 'Ping',
  };

  /// Stable tab / selection id.
  String get id => name;

  /// Material icon for section chrome.
  IconData get icon => switch (this) {
    DSMcpCapabilityKind.tools => Icons.build_outlined,
    DSMcpCapabilityKind.resources => Icons.folder_open_outlined,
    DSMcpCapabilityKind.prompts => Icons.chat_bubble_outline,
    DSMcpCapabilityKind.roots => Icons.account_tree_outlined,
    DSMcpCapabilityKind.ping => Icons.network_check,
  };

  /// Detail-inspector kind token (asset-kind coloring).
  String get assetKind => switch (this) {
    DSMcpCapabilityKind.tools => 'skill',
    DSMcpCapabilityKind.resources => 'workflow',
    DSMcpCapabilityKind.prompts => 'agent',
    DSMcpCapabilityKind.roots => 'task',
    DSMcpCapabilityKind.ping => 'changelog',
  };
}

/// Capability negotiation flags that gate visible inspector sections.
///
/// Sections with `false` flags are **hidden** (capability-gating), not merely
/// empty. Empty lists under an enabled flag still show the section with an
/// empty-state surface.
@immutable
class DSMcpCapabilities {
  /// Server advertises tools list.
  final bool tools;

  /// Server advertises resources list.
  final bool resources;

  /// Server advertises prompts list.
  final bool prompts;

  /// Optional roots stub capability.
  final bool roots;

  /// Optional ping stub capability.
  final bool ping;

  const DSMcpCapabilities({
    this.tools = false,
    this.resources = false,
    this.prompts = false,
    this.roots = false,
    this.ping = false,
  });

  /// Full tools + resources + prompts (gallery default).
  const DSMcpCapabilities.standard({
    this.tools = true,
    this.resources = true,
    this.prompts = true,
    this.roots = false,
    this.ping = false,
  });

  /// No negotiated capabilities.
  const DSMcpCapabilities.none()
    : tools = false,
      resources = false,
      prompts = false,
      roots = false,
      ping = false;

  /// Ordered enabled kinds (stable tab order).
  List<DSMcpCapabilityKind> get enabledKinds {
    return [
      if (tools) DSMcpCapabilityKind.tools,
      if (resources) DSMcpCapabilityKind.resources,
      if (prompts) DSMcpCapabilityKind.prompts,
      if (roots) DSMcpCapabilityKind.roots,
      if (ping) DSMcpCapabilityKind.ping,
    ];
  }

  /// True when no capability flags are set.
  bool get isEmpty => enabledKinds.isEmpty;

  /// Whether [kind] is advertised.
  bool allows(DSMcpCapabilityKind kind) => switch (kind) {
    DSMcpCapabilityKind.tools => tools,
    DSMcpCapabilityKind.resources => resources,
    DSMcpCapabilityKind.prompts => prompts,
    DSMcpCapabilityKind.roots => roots,
    DSMcpCapabilityKind.ping => ping,
  };

  DSMcpCapabilities copyWith({
    bool? tools,
    bool? resources,
    bool? prompts,
    bool? roots,
    bool? ping,
  }) {
    return DSMcpCapabilities(
      tools: tools ?? this.tools,
      resources: resources ?? this.resources,
      prompts: prompts ?? this.prompts,
      roots: roots ?? this.roots,
      ping: ping ?? this.ping,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DSMcpCapabilities &&
        other.tools == tools &&
        other.resources == resources &&
        other.prompts == prompts &&
        other.roots == roots &&
        other.ping == ping;
  }

  @override
  int get hashCode => Object.hash(tools, resources, prompts, roots, ping);
}

// =============================================================================
// Item models
// =============================================================================

/// Fixture tool entry (`tools/list` style).
@immutable
class DSMcpToolItem {
  /// Stable unique id within the inspector.
  final String id;

  /// Tool name (e.g. `list_directory`).
  final String name;

  /// Optional human description.
  final String? description;

  /// Whether the tool is enabled in the fixture (display only).
  final bool enabled;

  /// Optional compact input-schema summary (not live schema fetch).
  final String? inputSchemaSummary;

  /// Optional free-form meta rows for the detail pane.
  final Map<String, String>? metadata;

  const DSMcpToolItem({
    required this.id,
    required this.name,
    this.description,
    this.enabled = true,
    this.inputSchemaSummary,
    this.metadata,
  });

  /// Screen-reader label.
  String get semanticLabel {
    final state = enabled ? 'enabled' : 'disabled';
    final desc = description;
    if (desc != null && desc.isNotEmpty) {
      return 'Tool $name, $state: $desc';
    }
    return 'Tool $name, $state';
  }

  DSMcpToolItem copyWith({
    String? id,
    String? name,
    String? description,
    bool? enabled,
    String? inputSchemaSummary,
    Map<String, String>? metadata,
  }) {
    return DSMcpToolItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      enabled: enabled ?? this.enabled,
      inputSchemaSummary: inputSchemaSummary ?? this.inputSchemaSummary,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DSMcpToolItem &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.enabled == enabled &&
        other.inputSchemaSummary == inputSchemaSummary;
  }

  @override
  int get hashCode =>
      Object.hash(id, name, description, enabled, inputSchemaSummary);
}

/// Fixture resource entry (`resources/list` style).
@immutable
class DSMcpResourceItem {
  /// Stable unique id.
  final String id;

  /// Resource URI (fixture string, not fetched).
  final String uri;

  /// Display name.
  final String name;

  /// Optional description.
  final String? description;

  /// Optional MIME type.
  final String? mimeType;

  /// Optional free-form meta rows.
  final Map<String, String>? metadata;

  const DSMcpResourceItem({
    required this.id,
    required this.uri,
    required this.name,
    this.description,
    this.mimeType,
    this.metadata,
  });

  String get semanticLabel {
    final mime = mimeType;
    if (mime != null && mime.isNotEmpty) {
      return 'Resource $name, $uri, $mime';
    }
    return 'Resource $name, $uri';
  }

  DSMcpResourceItem copyWith({
    String? id,
    String? uri,
    String? name,
    String? description,
    String? mimeType,
    Map<String, String>? metadata,
  }) {
    return DSMcpResourceItem(
      id: id ?? this.id,
      uri: uri ?? this.uri,
      name: name ?? this.name,
      description: description ?? this.description,
      mimeType: mimeType ?? this.mimeType,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DSMcpResourceItem &&
        other.id == id &&
        other.uri == uri &&
        other.name == name &&
        other.description == description &&
        other.mimeType == mimeType;
  }

  @override
  int get hashCode => Object.hash(id, uri, name, description, mimeType);
}

/// Fixture prompt entry (`prompts/list` style).
@immutable
class DSMcpPromptItem {
  /// Stable unique id.
  final String id;

  /// Prompt name.
  final String name;

  /// Optional description.
  final String? description;

  /// Optional argument names advertised by the prompt.
  final List<String>? argumentNames;

  /// Optional free-form meta rows.
  final Map<String, String>? metadata;

  const DSMcpPromptItem({
    required this.id,
    required this.name,
    this.description,
    this.argumentNames,
    this.metadata,
  });

  String get semanticLabel {
    final args = argumentNames;
    if (args != null && args.isNotEmpty) {
      return 'Prompt $name, arguments: ${args.join(', ')}';
    }
    return 'Prompt $name';
  }

  DSMcpPromptItem copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? argumentNames,
    Map<String, String>? metadata,
  }) {
    return DSMcpPromptItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      argumentNames: argumentNames ?? this.argumentNames,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DSMcpPromptItem &&
        other.id == id &&
        other.name == name &&
        other.description == description;
  }

  @override
  int get hashCode => Object.hash(id, name, description);
}

/// Fixture roots stub entry (list-only, no live filesystem).
@immutable
class DSMcpRootItem {
  final String id;
  final String uri;
  final String name;
  final String? description;

  const DSMcpRootItem({
    required this.id,
    required this.uri,
    required this.name,
    this.description,
  });

  String get semanticLabel => 'Root $name, $uri';
}

/// Fixture ping result (display-only connection chrome).
@immutable
class DSMcpPingResult {
  final String id;
  final String label;
  final String status;
  final Duration? latency;
  final String? detail;

  const DSMcpPingResult({
    required this.id,
    required this.label,
    required this.status,
    this.latency,
    this.detail,
  });

  String? get latencyLabel {
    final d = latency;
    if (d == null) return null;
    if (d.inMilliseconds < 1000) return '${d.inMilliseconds}ms';
    return '${(d.inMilliseconds / 1000).toStringAsFixed(1)}s';
  }

  String get semanticLabel {
    final lat = latencyLabel;
    if (lat != null) return 'Ping $label: $status, $lat';
    return 'Ping $label: $status';
  }
}

/// Selection payload from [DSMcpCapabilityInspector].
@immutable
class DSMcpCapabilitySelection {
  /// Capability section the selection belongs to.
  final DSMcpCapabilityKind kind;

  /// Selected item id within that section.
  final String id;

  const DSMcpCapabilitySelection({required this.kind, required this.id});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DSMcpCapabilitySelection &&
        other.kind == kind &&
        other.id == id;
  }

  @override
  int get hashCode => Object.hash(kind, id);
}

// =============================================================================
// Organism
// =============================================================================

/// ASW Observatory Organism — MCP Capability Inspector
///
/// Capability-gated multi-pane inspector for MCP **tools / resources /
/// prompts** (plus optional roots/ping stubs). Fixture-first CyberCore ops
/// surface (EPIC-16 C-08).
///
/// ## Capability gating
///
/// [capabilities] drives which tabs appear. Disabled flags **hide** sections;
/// empty lists under an enabled flag still show the tab with an empty surface.
///
/// ## Selection
///
/// - Uncontrolled (default): seed from [initialSelection]; organism owns it.
/// - Controlled: pass [selectedKind] + [selectedItemId] each rebuild.
///
/// **Not** a live MCP JSON-RPC client. No network, no ALLOW/BLOCK mutation
/// panels, no invoke side effects (optional mock invoke chrome is disabled).
class DSMcpCapabilityInspector extends StatefulWidget {
  /// Negotiated capability flags (gates tabs).
  final DSMcpCapabilities capabilities;

  /// Fixture tools (shown only when [DSMcpCapabilities.tools] is true).
  final List<DSMcpToolItem> tools;

  /// Fixture resources.
  final List<DSMcpResourceItem> resources;

  /// Fixture prompts.
  final List<DSMcpPromptItem> prompts;

  /// Optional roots stub rows.
  final List<DSMcpRootItem> roots;

  /// Optional ping stub results.
  final List<DSMcpPingResult> pingResults;

  /// Controlled selected capability kind.
  final DSMcpCapabilityKind? selectedKind;

  /// Controlled selected item id (within [selectedKind]).
  final String? selectedItemId;

  /// Seed selection for uncontrolled mode.
  final DSMcpCapabilitySelection? initialSelection;

  /// Fired when the user selects a row (null when cleared / empty).
  final ValueChanged<DSMcpCapabilitySelection?>? onSelectionChanged;

  /// Fired when the active capability tab changes.
  final ValueChanged<DSMcpCapabilityKind>? onCapabilityChanged;

  /// Panel title.
  final String title;

  /// Optional subtitle (e.g. server name).
  final String? subtitle;

  /// Optional connection status badge label (fixture display only).
  final String? connectionStatus;

  /// Semantic label for the inspector region.
  final String semanticLabel;

  /// Empty-capabilities title.
  final String emptyCapabilitiesTitle;

  /// Empty-capabilities subtitle.
  final String emptyCapabilitiesSubtitle;

  /// When true, host layout uses [DSSplitPane]; otherwise fixed list width.
  final bool useSplitPane;

  /// List pane width when not using split pane.
  final double listWidth;

  /// Initial split ratio for list (leading) pane.
  final double splitInitialRatio;

  /// Whether to wrap the panel in glass chrome.
  final bool wrapInGlass;

  /// Show a disabled mock "Invoke" chrome on tool detail (no side effects).
  final bool showMockInvokeChrome;

  const DSMcpCapabilityInspector({
    super.key,
    required this.capabilities,
    this.tools = const [],
    this.resources = const [],
    this.prompts = const [],
    this.roots = const [],
    this.pingResults = const [],
    this.selectedKind,
    this.selectedItemId,
    this.initialSelection,
    this.onSelectionChanged,
    this.onCapabilityChanged,
    this.title = 'MCP Capabilities',
    this.subtitle,
    this.connectionStatus,
    this.semanticLabel = 'MCP capability inspector',
    this.emptyCapabilitiesTitle = 'No capabilities',
    this.emptyCapabilitiesSubtitle =
        'Fixture server advertises no MCP capabilities',
    this.useSplitPane = true,
    this.listWidth = 280,
    this.splitInitialRatio = 0.38,
    this.wrapInGlass = true,
    this.showMockInvokeChrome = true,
  });

  /// Stable keys for tests and semantic tooling.
  static const Key panelKey = Key('ds-mcp-capability-inspector');
  static const Key tabBarKey = Key('ds-mcp-capability-inspector-tabs');
  static const Key listKey = Key('ds-mcp-capability-inspector-list');
  static const Key detailKey = Key('ds-mcp-capability-inspector-detail');
  static const Key emptyKey = Key('ds-mcp-capability-inspector-empty');
  static const Key noSelectionKey = Key(
    'ds-mcp-capability-inspector-no-selection',
  );

  /// Row key by capability kind + item id.
  static Key rowKey(DSMcpCapabilityKind kind, String itemId) =>
      Key('ds-mcp-capability-row-${kind.id}-$itemId');

  /// Tab key by capability kind.
  static Key tabKey(DSMcpCapabilityKind kind) =>
      Key('ds-mcp-capability-tab-${kind.id}');

  @override
  State<DSMcpCapabilityInspector> createState() =>
      _DSMcpCapabilityInspectorState();
}

class _DSMcpCapabilityInspectorState extends State<DSMcpCapabilityInspector> {
  DSTabController? _tabController;
  DSMcpCapabilityKind? _uncontrolledKind;
  String? _uncontrolledItemId;
  String _tabFingerprint = '';

  bool get _isControlled =>
      widget.selectedKind != null || widget.selectedItemId != null;

  @override
  void initState() {
    super.initState();
    _seedUncontrolledSelection();
    _rebuildTabsIfNeeded(force: true);
  }

  @override
  void didUpdateWidget(DSMcpCapabilityInspector oldWidget) {
    super.didUpdateWidget(oldWidget);
    _rebuildTabsIfNeeded();
    if (!_isControlled) {
      _validateUncontrolledSelection();
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _seedUncontrolledSelection() {
    final kinds = widget.capabilities.enabledKinds;
    if (kinds.isEmpty) {
      _uncontrolledKind = null;
      _uncontrolledItemId = null;
      return;
    }

    final seed = widget.initialSelection;
    if (seed != null &&
        widget.capabilities.allows(seed.kind) &&
        _itemExists(seed.kind, seed.id)) {
      _uncontrolledKind = seed.kind;
      _uncontrolledItemId = seed.id;
      return;
    }

    final firstKind = kinds.first;
    _uncontrolledKind = firstKind;
    _uncontrolledItemId = _firstItemId(firstKind);
  }

  void _validateUncontrolledSelection() {
    final kinds = widget.capabilities.enabledKinds;
    if (kinds.isEmpty) {
      if (_uncontrolledKind != null || _uncontrolledItemId != null) {
        setState(() {
          _uncontrolledKind = null;
          _uncontrolledItemId = null;
        });
      }
      return;
    }

    var kind = _uncontrolledKind;
    if (kind == null || !widget.capabilities.allows(kind)) {
      kind = kinds.first;
      _uncontrolledKind = kind;
      _uncontrolledItemId = _firstItemId(kind);
      return;
    }

    final id = _uncontrolledItemId;
    if (id != null && !_itemExists(kind, id)) {
      _uncontrolledItemId = _firstItemId(kind);
    }
  }

  String _capabilitiesFingerprint() {
    final kinds = widget.capabilities.enabledKinds;
    final counts = kinds.map((k) => '${k.id}:${_countFor(k)}').join('|');
    return counts;
  }

  void _rebuildTabsIfNeeded({bool force = false}) {
    final fingerprint = _capabilitiesFingerprint();
    if (!force && fingerprint == _tabFingerprint && _tabController != null) {
      return;
    }
    _tabFingerprint = fingerprint;

    final kinds = widget.capabilities.enabledKinds;
    final previous = _tabController;
    final previousId = previous?.activeTab?.id;

    if (kinds.isEmpty) {
      previous?.dispose();
      _tabController = null;
      return;
    }

    final initialIndex = () {
      if (previousId != null) {
        final idx = kinds.indexWhere((k) => k.id == previousId);
        if (idx >= 0) return idx;
      }
      final active = _effectiveKind;
      if (active != null) {
        final idx = kinds.indexOf(active);
        if (idx >= 0) return idx;
      }
      return 0;
    }();

    final controller = DSTabController(
      tabs: [
        for (final kind in kinds)
          DSTab(
            id: kind.id,
            label: kind.label,
            icon: kind.icon,
            badgeCount: _countFor(kind) > 0 ? _countFor(kind) : null,
            // Content is rendered outside DSTabView via active kind;
            // placeholder keeps DSTab contract satisfied.
            content: (_) => const SizedBox.shrink(),
          ),
      ],
      activeIndex: initialIndex,
    );
    controller.addListener(_onTabControllerChanged);

    previous?.removeListener(_onTabControllerChanged);
    previous?.dispose();
    _tabController = controller;
  }

  void _onTabControllerChanged() {
    final activeId = _tabController?.activeTab?.id;
    if (activeId == null) return;
    final kind = DSMcpCapabilityKind.values.firstWhere(
      (k) => k.id == activeId,
      orElse: () => DSMcpCapabilityKind.tools,
    );
    if (_effectiveKind == kind) {
      setState(() {});
      return;
    }
    _activateKind(kind);
  }

  int _countFor(DSMcpCapabilityKind kind) => switch (kind) {
    DSMcpCapabilityKind.tools => widget.tools.length,
    DSMcpCapabilityKind.resources => widget.resources.length,
    DSMcpCapabilityKind.prompts => widget.prompts.length,
    DSMcpCapabilityKind.roots => widget.roots.length,
    DSMcpCapabilityKind.ping => widget.pingResults.length,
  };

  String? _firstItemId(DSMcpCapabilityKind kind) => switch (kind) {
    DSMcpCapabilityKind.tools =>
      widget.tools.isEmpty ? null : widget.tools.first.id,
    DSMcpCapabilityKind.resources =>
      widget.resources.isEmpty ? null : widget.resources.first.id,
    DSMcpCapabilityKind.prompts =>
      widget.prompts.isEmpty ? null : widget.prompts.first.id,
    DSMcpCapabilityKind.roots =>
      widget.roots.isEmpty ? null : widget.roots.first.id,
    DSMcpCapabilityKind.ping =>
      widget.pingResults.isEmpty ? null : widget.pingResults.first.id,
  };

  bool _itemExists(DSMcpCapabilityKind kind, String id) => switch (kind) {
    DSMcpCapabilityKind.tools => widget.tools.any((t) => t.id == id),
    DSMcpCapabilityKind.resources => widget.resources.any((r) => r.id == id),
    DSMcpCapabilityKind.prompts => widget.prompts.any((p) => p.id == id),
    DSMcpCapabilityKind.roots => widget.roots.any((r) => r.id == id),
    DSMcpCapabilityKind.ping => widget.pingResults.any((p) => p.id == id),
  };

  DSMcpCapabilityKind? get _effectiveKind {
    if (widget.selectedKind != null) {
      final k = widget.selectedKind!;
      if (widget.capabilities.allows(k)) return k;
    }
    return _uncontrolledKind;
  }

  String? get _effectiveItemId {
    if (widget.selectedItemId != null) return widget.selectedItemId;
    return _uncontrolledItemId;
  }

  void _activateKind(DSMcpCapabilityKind kind) {
    if (!widget.capabilities.allows(kind)) return;

    final firstId = _firstItemId(kind);
    if (!_isControlled) {
      setState(() {
        _uncontrolledKind = kind;
        _uncontrolledItemId = firstId;
      });
    } else {
      setState(() {});
    }

    widget.onCapabilityChanged?.call(kind);
    if (firstId != null) {
      widget.onSelectionChanged?.call(
        DSMcpCapabilitySelection(kind: kind, id: firstId),
      );
    } else {
      widget.onSelectionChanged?.call(null);
    }

    final controller = _tabController;
    if (controller != null && controller.activeTab?.id != kind.id) {
      controller.selectById(kind.id);
    }
  }

  void _selectItem(DSMcpCapabilityKind kind, String id) {
    if (!_isControlled) {
      setState(() {
        _uncontrolledKind = kind;
        _uncontrolledItemId = id;
      });
    }
    widget.onSelectionChanged?.call(
      DSMcpCapabilitySelection(kind: kind, id: id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final kinds = widget.capabilities.enabledKinds;
    final content = Semantics(
      container: true,
      explicitChildNodes: true,
      label: kinds.isEmpty
          ? '${widget.semanticLabel}: empty'
          : '${widget.semanticLabel}: ${kinds.map((k) => k.label).join(', ')}',
      child: Column(
        key: DSMcpCapabilityInspector.panelKey,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _InspectorHeader(
            title: widget.title,
            subtitle: widget.subtitle,
            connectionStatus: widget.connectionStatus,
            capabilityCount: kinds.length,
          ),
          const DSDivider.subtle(),
          if (kinds.isEmpty)
            Expanded(child: _buildEmptyCapabilities())
          else ...[
            _buildTabBar(),
            const DSDivider.subtle(),
            Expanded(child: _buildListAndDetail()),
          ],
        ],
      ),
    );

    if (!widget.wrapInGlass) {
      return ColoredBox(color: DSColors.obsidianBase, child: content);
    }

    return DSGlassPanelSimple(
      backgroundColor: DSColors.obsidianBase.withValues(alpha: 0.95),
      borderColor: DSColors.borderSubtle,
      padding: EdgeInsets.zero,
      child: content,
    );
  }

  Widget _buildEmptyCapabilities() {
    return Center(
      key: DSMcpCapabilityInspector.emptyKey,
      child: Padding(
        padding: const EdgeInsets.all(DSSpacing.lg),
        child: DSStateSurface.empty(
          icon: Icons.extension_off_outlined,
          title: widget.emptyCapabilitiesTitle,
          subtitle: widget.emptyCapabilitiesSubtitle,
          compact: true,
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    final controller = _tabController;
    if (controller == null) return const SizedBox.shrink();

    // Sync controller to effective kind when controlled from outside.
    final kind = _effectiveKind;
    if (kind != null && controller.activeTab?.id != kind.id) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _tabController?.activeTab?.id != kind.id) {
          _tabController?.selectById(kind.id);
        }
      });
    }

    return Semantics(
      label: 'MCP capability sections',
      child: KeyedSubtree(
        key: DSMcpCapabilityInspector.tabBarKey,
        child: SizedBox(
          height: 44,
          child: DSTabBar(controller: controller, showScrollFades: false),
        ),
      ),
    );
  }

  Widget _buildListAndDetail() {
    final kind = _effectiveKind ?? widget.capabilities.enabledKinds.first;
    final list = _CapabilityListPane(
      kind: kind,
      tools: widget.tools,
      resources: widget.resources,
      prompts: widget.prompts,
      roots: widget.roots,
      pingResults: widget.pingResults,
      selectedItemId: _effectiveItemId,
      onSelect: (id) => _selectItem(kind, id),
    );
    final detail = _CapabilityDetailPane(
      kind: kind,
      selectedItemId: _effectiveItemId,
      tools: widget.tools,
      resources: widget.resources,
      prompts: widget.prompts,
      roots: widget.roots,
      pingResults: widget.pingResults,
      showMockInvokeChrome: widget.showMockInvokeChrome,
    );

    if (widget.useSplitPane) {
      return DSSplitPane(
        axis: Axis.horizontal,
        initialRatio: widget.splitInitialRatio,
        leadingMinExtent: 160,
        trailingMinExtent: 200,
        leading: list,
        trailing: detail,
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(width: widget.listWidth, child: list),
        const DSDivider.subtle(vertical: true),
        Expanded(child: detail),
      ],
    );
  }
}

// =============================================================================
// Header
// =============================================================================

class _InspectorHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? connectionStatus;
  final int capabilityCount;

  const _InspectorHeader({
    required this.title,
    required this.subtitle,
    required this.connectionStatus,
    required this.capabilityCount,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      label:
          '$title, $capabilityCount capabilities'
          '${connectionStatus != null ? ', $connectionStatus' : ''}',
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.lg,
          vertical: DSSpacing.md,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(DSSpacing.sm),
              decoration: BoxDecoration(
                color: DSColors.accentGold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(DSRadii.md),
              ),
              child: const DSIcon.small(
                Icons.extension_outlined,
                color: DSColors.accentGold,
              ),
            ),
            const SizedBox(width: DSSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DSText.headingSmall(title, color: DSColors.textPrimary),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: DSSpacing.xxs),
                    DSText.bodySmall(
                      subtitle!,
                      color: DSColors.textSecondary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (connectionStatus != null && connectionStatus!.isNotEmpty) ...[
              const SizedBox(width: DSSpacing.sm),
              DSBadge(
                label: connectionStatus!,
                color: connectionStatus == 'connected'
                    ? DSColors.statusSuccess
                    : DSColors.statusWarning,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// List pane
// =============================================================================

class _CapabilityListPane extends StatelessWidget {
  final DSMcpCapabilityKind kind;
  final List<DSMcpToolItem> tools;
  final List<DSMcpResourceItem> resources;
  final List<DSMcpPromptItem> prompts;
  final List<DSMcpRootItem> roots;
  final List<DSMcpPingResult> pingResults;
  final String? selectedItemId;
  final ValueChanged<String> onSelect;

  const _CapabilityListPane({
    required this.kind,
    required this.tools,
    required this.resources,
    required this.prompts,
    required this.roots,
    required this.pingResults,
    required this.selectedItemId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final rows = _rows();
    return Semantics(
      container: true,
      label: '${kind.label} list, ${rows.length} items',
      child: Column(
        key: DSMcpCapabilityInspector.listKey,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: DSSpacing.md,
              vertical: DSSpacing.sm,
            ),
            child: DSText.labelSmall(
              kind.label.toUpperCase(),
              color: DSColors.textTertiary,
            ),
          ),
          Expanded(
            child: rows.isEmpty
                ? Center(
                    child: DSStateSurface.empty(
                      icon: kind.icon,
                      title: 'No ${kind.label.toLowerCase()}',
                      subtitle: 'Fixture list is empty for this capability',
                      compact: true,
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.only(
                      left: DSSpacing.sm,
                      right: DSSpacing.sm,
                      bottom: DSSpacing.md,
                    ),
                    itemCount: rows.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: DSSpacing.xs),
                    itemBuilder: (context, index) {
                      final row = rows[index];
                      final selected = row.id == selectedItemId;
                      return DSInteractiveSurface(
                        key: DSMcpCapabilityInspector.rowKey(kind, row.id),
                        semanticLabel: row.semanticLabel,
                        selected: selected,
                        onTap: () => onSelect(row.id),
                        excludeChildSemantics: true,
                        child: _ListRowChrome(
                          title: row.title,
                          subtitle: row.subtitle,
                          trailing: row.trailing,
                          selected: selected,
                          leadingColor: row.leadingColor,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  List<_ListRowData> _rows() {
    switch (kind) {
      case DSMcpCapabilityKind.tools:
        return [
          for (final t in tools)
            _ListRowData(
              id: t.id,
              title: t.name,
              subtitle: t.description,
              trailing: t.enabled ? null : 'off',
              leadingColor: t.enabled
                  ? DSColors.accentCyan
                  : DSColors.textDisabled,
              semanticLabel: t.semanticLabel,
            ),
        ];
      case DSMcpCapabilityKind.resources:
        return [
          for (final r in resources)
            _ListRowData(
              id: r.id,
              title: r.name,
              subtitle: r.uri,
              trailing: r.mimeType,
              leadingColor: DSColors.accentViolet,
              semanticLabel: r.semanticLabel,
            ),
        ];
      case DSMcpCapabilityKind.prompts:
        return [
          for (final p in prompts)
            _ListRowData(
              id: p.id,
              title: p.name,
              subtitle: p.description,
              trailing: (p.argumentNames != null && p.argumentNames!.isNotEmpty)
                  ? '${p.argumentNames!.length} args'
                  : null,
              leadingColor: DSColors.accentGold,
              semanticLabel: p.semanticLabel,
            ),
        ];
      case DSMcpCapabilityKind.roots:
        return [
          for (final r in roots)
            _ListRowData(
              id: r.id,
              title: r.name,
              subtitle: r.uri,
              leadingColor: DSColors.statusInfo,
              semanticLabel: r.semanticLabel,
            ),
        ];
      case DSMcpCapabilityKind.ping:
        return [
          for (final p in pingResults)
            _ListRowData(
              id: p.id,
              title: p.label,
              subtitle: p.status,
              trailing: p.latencyLabel,
              leadingColor: p.status == 'ok'
                  ? DSColors.statusSuccess
                  : DSColors.statusWarning,
              semanticLabel: p.semanticLabel,
            ),
        ];
    }
  }
}

class _ListRowData {
  final String id;
  final String title;
  final String? subtitle;
  final String? trailing;
  final Color leadingColor;
  final String semanticLabel;

  const _ListRowData({
    required this.id,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.leadingColor,
    required this.semanticLabel,
  });
}

class _ListRowChrome extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? trailing;
  final bool selected;
  final Color leadingColor;

  const _ListRowChrome({
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.selected,
    required this.leadingColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 48),
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: selected
            ? DSColors.accentCyan.withValues(alpha: 0.08)
            : DSColors.obsidianElevated,
        borderRadius: BorderRadius.circular(DSRadii.sm),
        border: Border.all(
          color: selected
              ? DSColors.accentCyan.withValues(alpha: 0.55)
              : DSColors.borderSubtle.withValues(alpha: 0.5),
          width: selected ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: leadingColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: DSSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                DSText.labelMedium(
                  title,
                  color: DSColors.textPrimary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: DSSpacing.xxs),
                  DSText.labelSmall(
                    subtitle!,
                    color: DSColors.textTertiary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null && trailing!.isNotEmpty) ...[
            const SizedBox(width: DSSpacing.sm),
            DSText.labelSmall(
              trailing!,
              color: DSColors.textDisabled,
              maxLines: 1,
            ),
          ],
        ],
      ),
    );
  }
}

// =============================================================================
// Detail pane
// =============================================================================

class _CapabilityDetailPane extends StatelessWidget {
  final DSMcpCapabilityKind kind;
  final String? selectedItemId;
  final List<DSMcpToolItem> tools;
  final List<DSMcpResourceItem> resources;
  final List<DSMcpPromptItem> prompts;
  final List<DSMcpRootItem> roots;
  final List<DSMcpPingResult> pingResults;
  final bool showMockInvokeChrome;

  const _CapabilityDetailPane({
    required this.kind,
    required this.selectedItemId,
    required this.tools,
    required this.resources,
    required this.prompts,
    required this.roots,
    required this.pingResults,
    required this.showMockInvokeChrome,
  });

  @override
  Widget build(BuildContext context) {
    final id = selectedItemId;
    if (id == null) {
      return const Center(
        key: DSMcpCapabilityInspector.noSelectionKey,
        child: DSStateSurface.empty(
          icon: Icons.info_outline,
          title: 'No selection',
          subtitle: 'Select an item to inspect',
          compact: true,
        ),
      );
    }

    final sections = _buildSections(id);
    if (sections == null) {
      return const Center(
        key: DSMcpCapabilityInspector.noSelectionKey,
        child: DSStateSurface.empty(
          icon: Icons.info_outline,
          title: 'No selection',
          subtitle: 'Item not found in fixture list',
          compact: true,
        ),
      );
    }

    return Semantics(
      container: true,
      label: '${kind.label} detail',
      child: KeyedSubtree(
        key: DSMcpCapabilityInspector.detailKey,
        child: DSDetailInspector(
          title: sections.title,
          kind: kind.assetKind,
          subtitle: sections.subtitle,
          sections: sections.sections,
          headerActions: sections.headerActions,
        ),
      ),
    );
  }

  _DetailPayload? _buildSections(String id) {
    switch (kind) {
      case DSMcpCapabilityKind.tools:
        DSMcpToolItem? tool;
        for (final t in tools) {
          if (t.id == id) {
            tool = t;
            break;
          }
        }
        if (tool == null) return null;
        return _DetailPayload(
          title: tool.name,
          subtitle: tool.description,
          headerActions: showMockInvokeChrome
              ? const Tooltip(
                  message:
                      'Fixture only — invoke is mock chrome (no side effects)',
                  child: Opacity(
                    opacity: 0.45,
                    child: AbsorbPointer(
                      child: DSBadge(
                        label: 'Invoke (mock)',
                        color: DSColors.textDisabled,
                      ),
                    ),
                  ),
                )
              : null,
          sections: [
            DSDetailSection(
              title: 'Tool',
              icon: Icons.build_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DSPropertyRow(label: 'ID', value: tool.id),
                  DSPropertyRow(label: 'Name', value: tool.name),
                  DSPropertyRow(
                    label: 'Enabled',
                    value: tool.enabled ? 'true' : 'false',
                    valueColor: tool.enabled
                        ? DSColors.statusSuccess
                        : DSColors.textDisabled,
                  ),
                  if (tool.inputSchemaSummary != null)
                    DSPropertyRow(
                      label: 'Schema',
                      value: tool.inputSchemaSummary!,
                    ),
                  if (tool.description != null)
                    DSPropertyRow(
                      label: 'Description',
                      value: tool.description!,
                    ),
                  ..._metaRows(tool.metadata),
                ],
              ),
            ),
          ],
        );

      case DSMcpCapabilityKind.resources:
        DSMcpResourceItem? resource;
        for (final r in resources) {
          if (r.id == id) {
            resource = r;
            break;
          }
        }
        if (resource == null) return null;
        return _DetailPayload(
          title: resource.name,
          subtitle: resource.uri,
          sections: [
            DSDetailSection(
              title: 'Resource',
              icon: Icons.folder_open_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DSPropertyRow(label: 'ID', value: resource.id),
                  DSPropertyRow(label: 'Name', value: resource.name),
                  DSPropertyRow(label: 'URI', value: resource.uri),
                  if (resource.mimeType != null)
                    DSPropertyRow(label: 'MIME', value: resource.mimeType!),
                  if (resource.description != null)
                    DSPropertyRow(
                      label: 'Description',
                      value: resource.description!,
                    ),
                  ..._metaRows(resource.metadata),
                ],
              ),
            ),
          ],
        );

      case DSMcpCapabilityKind.prompts:
        DSMcpPromptItem? prompt;
        for (final p in prompts) {
          if (p.id == id) {
            prompt = p;
            break;
          }
        }
        if (prompt == null) return null;
        return _DetailPayload(
          title: prompt.name,
          subtitle: prompt.description,
          sections: [
            DSDetailSection(
              title: 'Prompt',
              icon: Icons.chat_bubble_outline,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DSPropertyRow(label: 'ID', value: prompt.id),
                  DSPropertyRow(label: 'Name', value: prompt.name),
                  if (prompt.argumentNames != null &&
                      prompt.argumentNames!.isNotEmpty)
                    DSPropertyRow(
                      label: 'Arguments',
                      value: prompt.argumentNames!.join(', '),
                    ),
                  if (prompt.description != null)
                    DSPropertyRow(
                      label: 'Description',
                      value: prompt.description!,
                    ),
                  ..._metaRows(prompt.metadata),
                ],
              ),
            ),
          ],
        );

      case DSMcpCapabilityKind.roots:
        DSMcpRootItem? root;
        for (final r in roots) {
          if (r.id == id) {
            root = r;
            break;
          }
        }
        if (root == null) return null;
        return _DetailPayload(
          title: root.name,
          subtitle: root.uri,
          sections: [
            DSDetailSection(
              title: 'Root',
              icon: Icons.account_tree_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DSPropertyRow(label: 'ID', value: root.id),
                  DSPropertyRow(label: 'Name', value: root.name),
                  DSPropertyRow(label: 'URI', value: root.uri),
                  if (root.description != null)
                    DSPropertyRow(
                      label: 'Description',
                      value: root.description!,
                    ),
                ],
              ),
            ),
          ],
        );

      case DSMcpCapabilityKind.ping:
        DSMcpPingResult? ping;
        for (final p in pingResults) {
          if (p.id == id) {
            ping = p;
            break;
          }
        }
        if (ping == null) return null;
        return _DetailPayload(
          title: ping.label,
          subtitle: ping.status,
          sections: [
            DSDetailSection(
              title: 'Ping',
              icon: Icons.network_check,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DSPropertyRow(label: 'ID', value: ping.id),
                  DSPropertyRow(label: 'Label', value: ping.label),
                  DSPropertyRow(label: 'Status', value: ping.status),
                  if (ping.latencyLabel != null)
                    DSPropertyRow(label: 'Latency', value: ping.latencyLabel!),
                  if (ping.detail != null)
                    DSPropertyRow(label: 'Detail', value: ping.detail!),
                  const DSPropertyRow(
                    label: 'Note',
                    value: 'Fixture ping only — no live MCP transport',
                  ),
                ],
              ),
            ),
          ],
        );
    }
  }

  List<Widget> _metaRows(Map<String, String>? metadata) {
    if (metadata == null || metadata.isEmpty) return const [];
    return [
      for (final entry in metadata.entries)
        DSPropertyRow(label: entry.key, value: entry.value),
    ];
  }
}

class _DetailPayload {
  final String title;
  final String? subtitle;
  final List<DSDetailSection> sections;
  final Widget? headerActions;

  const _DetailPayload({
    required this.title,
    this.subtitle,
    required this.sections,
    this.headerActions,
  });
}

// =============================================================================
// Fixtures (gallery + tests) — no live MCP, no secrets
// =============================================================================

/// Full fixture: tools + resources + prompts (gallery default).
DSMcpCapabilities dsMcpCapabilityInspectorStandardCapabilities() {
  return const DSMcpCapabilities.standard();
}

/// Tools + resources only (prompts gated off) — gating tests.
DSMcpCapabilities dsMcpCapabilityInspectorToolsResourcesOnly() {
  return const DSMcpCapabilities(tools: true, resources: true, prompts: false);
}

/// Empty capability set.
DSMcpCapabilities dsMcpCapabilityInspectorEmptyCapabilities() {
  return const DSMcpCapabilities.none();
}

/// Fixture tools (≥2).
List<DSMcpToolItem> dsMcpCapabilityInspectorFixtureTools() {
  return const [
    DSMcpToolItem(
      id: 'tool-list-dir',
      name: 'list_directory',
      description: 'List files and folders under a path',
      enabled: true,
      inputSchemaSummary: '{ path: string }',
      metadata: {'server': 'filesystem'},
    ),
    DSMcpToolItem(
      id: 'tool-read-file',
      name: 'read_file',
      description: 'Read text content from a file',
      enabled: true,
      inputSchemaSummary: '{ path: string, encoding?: string }',
    ),
    DSMcpToolItem(
      id: 'tool-write-file',
      name: 'write_file',
      description: 'Write text content to a file (mutation deferred)',
      enabled: false,
      inputSchemaSummary: '{ path: string, content: string }',
    ),
    DSMcpToolItem(
      id: 'tool-search',
      name: 'search_files',
      description: 'Search file names by glob pattern',
      enabled: true,
      inputSchemaSummary: '{ pattern: string }',
    ),
  ];
}

/// Fixture resources (≥2).
List<DSMcpResourceItem> dsMcpCapabilityInspectorFixtureResources() {
  return const [
    DSMcpResourceItem(
      id: 'res-readme',
      uri: 'file:///workspace/README.md',
      name: 'README',
      description: 'Project readme fixture',
      mimeType: 'text/markdown',
    ),
    DSMcpResourceItem(
      id: 'res-config',
      uri: 'file:///workspace/config.json',
      name: 'config.json',
      description: 'Local configuration snapshot',
      mimeType: 'application/json',
    ),
    DSMcpResourceItem(
      id: 'res-logs',
      uri: 'file:///workspace/logs/session.log',
      name: 'session.log',
      mimeType: 'text/plain',
    ),
  ];
}

/// Fixture prompts (≥1).
List<DSMcpPromptItem> dsMcpCapabilityInspectorFixturePrompts() {
  return const [
    DSMcpPromptItem(
      id: 'prompt-summarize',
      name: 'summarize_workspace',
      description: 'Summarize the current workspace state',
      argumentNames: ['depth', 'focus'],
    ),
    DSMcpPromptItem(
      id: 'prompt-review',
      name: 'code_review',
      description: 'Review a fixture file path for issues',
      argumentNames: ['path'],
    ),
  ];
}

/// Optional roots stub fixture.
List<DSMcpRootItem> dsMcpCapabilityInspectorFixtureRoots() {
  return const [
    DSMcpRootItem(
      id: 'root-workspace',
      uri: 'file:///workspace',
      name: 'workspace',
      description: 'Primary fixture workspace root',
    ),
  ];
}

/// Optional ping stub fixture.
List<DSMcpPingResult> dsMcpCapabilityInspectorFixturePing() {
  return const [
    DSMcpPingResult(
      id: 'ping-1',
      label: 'server-ping',
      status: 'ok',
      latency: Duration(milliseconds: 12),
      detail: 'Fixture round-trip only',
    ),
  ];
}

/// Compact tools+resources fixture for minimal tests.
({
  DSMcpCapabilities capabilities,
  List<DSMcpToolItem> tools,
  List<DSMcpResourceItem> resources,
})
dsMcpCapabilityInspectorMinimalFixture() {
  return (
    capabilities: const DSMcpCapabilities(tools: true, resources: true),
    tools: const [
      DSMcpToolItem(
        id: 't1',
        name: 'echo',
        description: 'Echo fixture tool',
        enabled: true,
      ),
      DSMcpToolItem(
        id: 't2',
        name: 'disabled_tool',
        description: 'Disabled fixture tool',
        enabled: false,
      ),
    ],
    resources: const [
      DSMcpResourceItem(
        id: 'r1',
        uri: 'file:///a.txt',
        name: 'a.txt',
        mimeType: 'text/plain',
      ),
      DSMcpResourceItem(
        id: 'r2',
        uri: 'file:///b.json',
        name: 'b.json',
        mimeType: 'application/json',
      ),
    ],
  );
}
