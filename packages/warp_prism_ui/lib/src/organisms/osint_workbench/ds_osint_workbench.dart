import 'package:flutter/material.dart';

import '../../atoms/ds_badge.dart';
import '../../atoms/ds_glass_panel.dart';
import '../../atoms/ds_icon.dart';
import '../../atoms/ds_text.dart';
import '../../molecules/ds_search_bar.dart';
import '../../molecules/ds_state_surface.dart';
import '../../tokens/tokens.dart';

// =============================================================================
// Models
// =============================================================================

/// Registered recon tool tab for [DSOsintWorkbench].
///
/// Harvest **mode contract** only (Osiris `OsintPanel` tabs / ShadowBroker
/// `ReconPanel`) — not a structural port of ~1k LOC megafiles. Domain one-offs
/// (Shodan-only panels, etc.) stay as fixture content under a generic tool id.
@immutable
class DSOsintTool {
  /// Stable tool identity used as the tab registry key (e.g. `"dns"`, `"ip"`).
  final String id;

  /// Human-readable tab label.
  final String label;

  /// Optional leading icon for the tool tab.
  final IconData? icon;

  /// Optional short description for a11y / header chrome.
  final String? description;

  /// Query field placeholder when this tool is active.
  final String queryPlaceholder;

  /// Optional accent for the active tab / result badges.
  final Color? color;

  const DSOsintTool({
    required this.id,
    required this.label,
    this.icon,
    this.description,
    this.queryPlaceholder = 'Enter query…',
    this.color,
  });

  DSOsintTool copyWith({
    String? id,
    String? label,
    IconData? icon,
    String? description,
    String? queryPlaceholder,
    Color? color,
    bool clearIcon = false,
    bool clearDescription = false,
    bool clearColor = false,
  }) {
    return DSOsintTool(
      id: id ?? this.id,
      label: label ?? this.label,
      icon: clearIcon ? null : (icon ?? this.icon),
      description: clearDescription ? null : (description ?? this.description),
      queryPlaceholder: queryPlaceholder ?? this.queryPlaceholder,
      color: clearColor ? null : (color ?? this.color),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DSOsintTool &&
        other.id == id &&
        other.label == label &&
        other.icon == icon &&
        other.description == description &&
        other.queryPlaceholder == queryPlaceholder &&
        other.color == color;
  }

  @override
  int get hashCode =>
      Object.hash(id, label, icon, description, queryPlaceholder, color);
}

/// Single label/value field inside a structured [DSOsintResult].
@immutable
class DSOsintResultField {
  /// Field label (e.g. `"A"`, `"Org"`, `"Country"`).
  final String label;

  /// Field value (mono-friendly fixture string).
  final String value;

  const DSOsintResultField({required this.label, required this.value});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DSOsintResultField &&
        other.label == label &&
        other.value == value;
  }

  @override
  int get hashCode => Object.hash(label, value);
}

/// Structured recon result card for [DSOsintWorkbench].
///
/// Optional [latitude]/[longitude] enable the map-handoff action when
/// [DSOsintWorkbench.onMapHandoff] is provided.
@immutable
class DSOsintResult {
  /// Stable result identity within a query response.
  final String id;

  /// Primary title (entity, IP, domain, etc.).
  final String title;

  /// Optional secondary line.
  final String? subtitle;

  /// Result kind for badges (e.g. `"dns"`, `"ip"`, `"geo"`).
  final String resultType;

  /// Structured key/value rows.
  final List<DSOsintResultField> fields;

  /// Optional WGS84 latitude for map handoff.
  final double? latitude;

  /// Optional WGS84 longitude for map handoff.
  final double? longitude;

  /// Optional preferred camera zoom when handed off to a map stage.
  final double? zoom;

  /// Opaque fixture metadata bag.
  final Map<String, Object?> metadata;

  const DSOsintResult({
    required this.id,
    required this.title,
    this.subtitle,
    required this.resultType,
    this.fields = const <DSOsintResultField>[],
    this.latitude,
    this.longitude,
    this.zoom,
    this.metadata = const <String, Object?>{},
  });

  /// Whether spatial coordinates are present for map handoff.
  bool get hasGeo => latitude != null && longitude != null;

  DSOsintResult copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? resultType,
    List<DSOsintResultField>? fields,
    double? latitude,
    double? longitude,
    double? zoom,
    Map<String, Object?>? metadata,
    bool clearSubtitle = false,
    bool clearLatitude = false,
    bool clearLongitude = false,
    bool clearZoom = false,
  }) {
    return DSOsintResult(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: clearSubtitle ? null : (subtitle ?? this.subtitle),
      resultType: resultType ?? this.resultType,
      fields: fields ?? this.fields,
      latitude: clearLatitude ? null : (latitude ?? this.latitude),
      longitude: clearLongitude ? null : (longitude ?? this.longitude),
      zoom: clearZoom ? null : (zoom ?? this.zoom),
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DSOsintResult &&
        other.id == id &&
        other.title == title &&
        other.subtitle == subtitle &&
        other.resultType == resultType &&
        _listEquals(other.fields, fields) &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.zoom == zoom;
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    subtitle,
    resultType,
    Object.hashAll(fields),
    latitude,
    longitude,
    zoom,
  );
}

/// Session-local query history entry retained by [DSOsintWorkbench].
@immutable
class DSOsintHistoryEntry {
  /// Stable history row identity.
  final String id;

  /// Tool id used for the query.
  final String toolId;

  /// Tool label snapshot at submit time.
  final String toolLabel;

  /// Submitted query text.
  final String query;

  /// Number of structured results returned.
  final int resultCount;

  /// Optional timestamp for display ordering.
  final DateTime? submittedAt;

  const DSOsintHistoryEntry({
    required this.id,
    required this.toolId,
    required this.toolLabel,
    required this.query,
    this.resultCount = 0,
    this.submittedAt,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DSOsintHistoryEntry &&
        other.id == id &&
        other.toolId == toolId &&
        other.toolLabel == toolLabel &&
        other.query == query &&
        other.resultCount == resultCount &&
        other.submittedAt == submittedAt;
  }

  @override
  int get hashCode =>
      Object.hash(id, toolId, toolLabel, query, resultCount, submittedAt);
}

/// Map handoff payload emitted by [DSOsintWorkbench.onMapHandoff].
///
/// Fixture/read-only: no MapLibre engine; consumers (later map stage) receive
/// geo coordinates only.
@immutable
class DSOsintMapHandoff {
  /// Source result id.
  final String resultId;

  /// Source tool id.
  final String toolId;

  /// Query that produced the result.
  final String query;

  /// Display title from the result.
  final String title;

  /// WGS84 latitude.
  final double latitude;

  /// WGS84 longitude.
  final double longitude;

  /// Optional preferred zoom.
  final double? zoom;

  /// Result type / kind.
  final String resultType;

  /// Opaque metadata from the source result.
  final Map<String, Object?> metadata;

  const DSOsintMapHandoff({
    required this.resultId,
    required this.toolId,
    required this.query,
    required this.title,
    required this.latitude,
    required this.longitude,
    this.zoom,
    required this.resultType,
    this.metadata = const <String, Object?>{},
  });

  /// Build a handoff from a geo-capable [DSOsintResult].
  factory DSOsintMapHandoff.fromResult({
    required DSOsintResult result,
    required String toolId,
    required String query,
  }) {
    assert(result.hasGeo, 'Map handoff requires latitude and longitude');
    return DSOsintMapHandoff(
      resultId: result.id,
      toolId: toolId,
      query: query,
      title: result.title,
      latitude: result.latitude!,
      longitude: result.longitude!,
      zoom: result.zoom,
      resultType: result.resultType,
      metadata: result.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DSOsintMapHandoff &&
        other.resultId == resultId &&
        other.toolId == toolId &&
        other.query == query &&
        other.title == title &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.zoom == zoom &&
        other.resultType == resultType;
  }

  @override
  int get hashCode => Object.hash(
    resultId,
    toolId,
    query,
    title,
    latitude,
    longitude,
    zoom,
    resultType,
  );
}

/// In-memory fixture resolver: `(toolId, query) → structured results`.
///
/// No live recon APIs, no API keys. Used by gallery, tests, and demos.
typedef DSOsintFixtureResolver =
    List<DSOsintResult> Function(String toolId, String query);

// =============================================================================
// Fixture catalog
// =============================================================================

/// Shared fixture tools + in-memory resolvers for gallery and tests.
///
/// Deliberately **not** a structural clone of Osiris `OsintPanel.tsx` (~1k LOC)
/// or ShadowBroker `ReconPanel` megafiles — harvests tab + query + results +
/// history + map-handoff **contracts** only.
abstract final class DSOsintFixtures {
  /// Default ≥2 tool tabs for demos (DNS + IP geo).
  static List<DSOsintTool> defaultTools() => const [
    DSOsintTool(
      id: 'dns',
      label: 'DNS',
      icon: Icons.dns_outlined,
      description: 'Fixture DNS lookup',
      queryPlaceholder: 'Domain or hostname…',
      color: DSColors.accentCyan,
    ),
    DSOsintTool(
      id: 'ip',
      label: 'IP',
      icon: Icons.lan_outlined,
      description: 'Fixture IP / geo lookup',
      queryPlaceholder: 'IPv4 or hostname…',
      color: DSColors.accentViolet,
    ),
    DSOsintTool(
      id: 'whois',
      label: 'WHOIS',
      icon: Icons.badge_outlined,
      description: 'Fixture WHOIS summary',
      queryPlaceholder: 'Domain for WHOIS…',
      color: DSColors.accentGold,
    ),
  ];

  /// Minimal two-tool registry for unit tests.
  static List<DSOsintTool> minimalTools() => const [
    DSOsintTool(
      id: 'dns',
      label: 'DNS',
      icon: Icons.dns_outlined,
      queryPlaceholder: 'Domain…',
      color: DSColors.accentCyan,
    ),
    DSOsintTool(
      id: 'ip',
      label: 'IP',
      icon: Icons.lan_outlined,
      queryPlaceholder: 'IP address…',
      color: DSColors.accentViolet,
    ),
  ];

  /// In-memory fixture resolver — mock rows only, never network.
  static List<DSOsintResult> resolve(String toolId, String query) {
    final q = query.trim();
    if (q.isEmpty) return const <DSOsintResult>[];

    // Explicit empty-result probe for tests/demos.
    if (q.toLowerCase() == 'empty' || q == 'zzzz-no-match') {
      return const <DSOsintResult>[];
    }

    switch (toolId) {
      case 'dns':
        return [
          DSOsintResult(
            id: 'dns-$q-a',
            title: q,
            subtitle: 'A / AAAA fixture records',
            resultType: 'dns',
            fields: const [
              DSOsintResultField(label: 'A', value: '93.184.216.34'),
              DSOsintResultField(label: 'AAAA', value: '2606:2800:220:1::248'),
              DSOsintResultField(label: 'TTL', value: '300'),
              DSOsintResultField(label: 'Source', value: 'fixture-dns'),
            ],
          ),
          DSOsintResult(
            id: 'dns-$q-ns',
            title: 'NS · $q',
            subtitle: 'Authoritative nameservers (fixture)',
            resultType: 'dns',
            fields: const [
              DSOsintResultField(label: 'NS', value: 'a.iana-servers.net'),
              DSOsintResultField(label: 'NS', value: 'b.iana-servers.net'),
            ],
          ),
        ];
      case 'ip':
        return [
          DSOsintResult(
            id: 'ip-$q',
            title: q,
            subtitle: 'Geo + ASN fixture',
            resultType: 'ip',
            latitude: 37.3861,
            longitude: -122.0839,
            zoom: 10,
            fields: const [
              DSOsintResultField(label: 'ASN', value: 'AS15169'),
              DSOsintResultField(label: 'Org', value: 'GOOGLE'),
              DSOsintResultField(label: 'Country', value: 'US'),
              DSOsintResultField(label: 'City', value: 'Mountain View'),
              DSOsintResultField(label: 'Source', value: 'fixture-ip'),
            ],
            metadata: const {'asn': 'AS15169'},
          ),
        ];
      case 'whois':
        return [
          DSOsintResult(
            id: 'whois-$q',
            title: q,
            subtitle: 'WHOIS summary (fixture)',
            resultType: 'whois',
            fields: const [
              DSOsintResultField(
                label: 'Registrar',
                value: 'Fixture Registrar',
              ),
              DSOsintResultField(label: 'Created', value: '1997-08-13'),
              DSOsintResultField(label: 'Expires', value: '2028-08-12'),
              DSOsintResultField(
                label: 'Status',
                value: 'clientTransferProhibited',
              ),
            ],
          ),
        ];
      default:
        return [
          DSOsintResult(
            id: 'generic-$toolId-$q',
            title: q,
            subtitle: 'Generic fixture result for tool $toolId',
            resultType: toolId,
            fields: [
              DSOsintResultField(label: 'Tool', value: toolId),
              DSOsintResultField(label: 'Query', value: q),
              const DSOsintResultField(label: 'Source', value: 'fixture'),
            ],
          ),
        ];
    }
  }
}

// =============================================================================
// Organism
// =============================================================================

/// ASW Observatory Organism — OSINT / Recon Workbench
///
/// Tabbed recon workbench: **tool tab registry → query submit → structured
/// results → session history → optional map handoff**. Fixture datasets only;
/// no live OSINT APIs, no API keys, no MapLibre.
///
/// ## Contract (harvest mode, not megafile structure)
///
/// | Surface | Role |
/// | --- | --- |
/// | Tool tabs | Registry of recon modes ([DSOsintTool]) |
/// | Query + submit | Operator lookup input |
/// | Results | Structured cards ([DSOsintResult] + fields) |
/// | History | Session-local list; re-run on select |
/// | Map handoff | Optional [onMapHandoff] when result [DSOsintResult.hasGeo] |
///
/// Explicitly **skips** structural clones of Osiris `OsintPanel.tsx` (~1k LOC)
/// and ShadowBroker `ReconPanel`/`ReconResults` megafiles — EPIC-15 O-08 /
/// Task 1510 harvests the mode contract only.
///
/// Compose later with `PrismConnectorPanel` chrome for domain connectors; do
/// not invent Shodan/SCM one-off organisms here.
class DSOsintWorkbench extends StatefulWidget {
  /// Tool tab registry (≥2 required for multi-tool demos).
  final List<DSOsintTool> tools;

  /// In-memory fixture resolver. Defaults to [DSOsintFixtures.resolve].
  final DSOsintFixtureResolver? resolver;

  /// Optional map handoff when a result carries geo coordinates.
  final ValueChanged<DSOsintMapHandoff>? onMapHandoff;

  /// Called after a successful submit with `(toolId, query, results)`.
  final void Function(String toolId, String query, List<DSOsintResult> results)?
  onQuerySubmitted;

  /// Called when the active tool tab changes.
  final ValueChanged<String>? onToolChanged;

  /// Called when a history entry is selected (before re-run).
  final ValueChanged<DSOsintHistoryEntry>? onHistorySelected;

  /// Controlled active tool id. Null → uncontrolled (internal state).
  final String? activeToolId;

  /// Seed active tool when uncontrolled. Empty → first tool.
  final String initialToolId;

  /// Seed query text for uncontrolled mode.
  final String initialQuery;

  /// Controlled results (parent-owned). When non-null, submit still calls
  /// [onQuerySubmitted] but does not replace internal results from resolver
  /// unless [useInternalResolver] is true (default).
  final List<DSOsintResult>? results;

  /// Parent-driven loading flag.
  final bool isLoading;

  /// Whether to wrap the panel in [DSGlassPanel.elevated].
  final bool wrapInGlass;

  /// Show the session history rail.
  final bool showHistory;

  /// Max history entries retained (newest first).
  final int maxHistory;

  /// History rail width.
  final double historyWidth;

  /// Panel title in header chrome.
  final String panelTitle;

  /// Idle empty title (no submit yet).
  final String idleTitle;

  /// Idle empty subtitle.
  final String idleSubtitle;

  /// Empty-results title after a submit with zero hits.
  final String emptyResultsTitle;

  /// Empty-results subtitle.
  final String emptyResultsSubtitle;

  /// Loading title.
  final String loadingTitle;

  /// Submit button label.
  final String submitLabel;

  /// Map handoff button label.
  final String mapHandoffLabel;

  const DSOsintWorkbench({
    super.key,
    required this.tools,
    this.resolver,
    this.onMapHandoff,
    this.onQuerySubmitted,
    this.onToolChanged,
    this.onHistorySelected,
    this.activeToolId,
    this.initialToolId = '',
    this.initialQuery = '',
    this.results,
    this.isLoading = false,
    this.wrapInGlass = true,
    this.showHistory = true,
    this.maxHistory = 20,
    this.historyWidth = 160,
    this.panelTitle = 'OSINT workbench',
    this.idleTitle = 'Submit a recon query',
    this.idleSubtitle = 'Fixture tools only — no live OSINT APIs or API keys',
    this.emptyResultsTitle = 'No results',
    this.emptyResultsSubtitle = 'Try another query or tool tab',
    this.loadingTitle = 'Running fixture recon…',
    this.submitLabel = 'Run',
    this.mapHandoffLabel = 'Map',
  }) : assert(
         tools.length >= 2,
         'At least two tool tabs are required (multi-tab workbench contract)',
       );

  // ---------------------------------------------------------------------------
  // Keys + semantics (tests / a11y)
  // ---------------------------------------------------------------------------

  /// Root panel key.
  static const Key panelKey = Key('ds-osint-workbench');

  /// Tool tabs row key.
  static const Key toolTabsKey = Key('ds-osint-workbench-tool-tabs');

  /// Query field host key.
  static const Key queryFieldKey = Key('ds-osint-workbench-query');

  /// Submit control key.
  static const Key submitButtonKey = Key('ds-osint-workbench-submit');

  /// Results list key.
  static const Key resultsListKey = Key('ds-osint-workbench-results');

  /// Empty / idle surface key.
  static const Key emptyStateKey = Key('ds-osint-workbench-empty');

  /// Loading surface key.
  static const Key loadingStateKey = Key('ds-osint-workbench-loading');

  /// History list key.
  static const Key historyListKey = Key('ds-osint-workbench-history');

  /// History empty key.
  static const Key historyEmptyKey = Key('ds-osint-workbench-history-empty');

  /// Tool tab key by tool id.
  static Key toolTabKey(String toolId) =>
      Key('ds-osint-workbench-tool-$toolId');

  /// History row key by entry id.
  static Key historyRowKey(String entryId) =>
      Key('ds-osint-workbench-history-$entryId');

  /// Result card key by result id.
  static Key resultCardKey(String resultId) =>
      Key('ds-osint-workbench-result-$resultId');

  /// Map handoff action key by result id.
  static Key mapHandoffKey(String resultId) =>
      Key('ds-osint-workbench-map-handoff-$resultId');

  /// Root region semantic label.
  static const String panelSemanticLabel = 'OSINT recon workbench';

  /// Tool tabs semantic label.
  static const String toolTabsSemanticLabel = 'Recon tool tabs';

  /// Submit semantic label.
  static const String submitSemanticLabel = 'Submit recon query';

  /// History list semantic label.
  static const String historySemanticLabel = 'Query history';

  /// Results list semantic label.
  static const String resultsSemanticLabel = 'Structured recon results';

  /// Loading semantic label.
  static const String loadingSemanticLabel = 'Running fixture recon';

  /// Empty results semantic label.
  static const String emptySemanticLabel = 'No recon results';

  /// Tool tab semantic label.
  static String toolTabSemanticLabel(DSOsintTool tool) =>
      'Recon tool ${tool.label}';

  /// History row semantic label.
  static String historyRowSemanticLabel(DSOsintHistoryEntry entry) =>
      'History ${entry.toolLabel}: ${entry.query}, ${entry.resultCount} results';

  /// Result card semantic label.
  static String resultSemanticLabel(DSOsintResult result) {
    final geo = result.hasGeo
        ? ', coordinates ${result.latitude}, ${result.longitude}'
        : '';
    return 'Result ${result.title}, ${result.resultType}$geo';
  }

  /// Map handoff semantic label.
  static String mapHandoffSemanticLabel(DSOsintResult result) =>
      'Hand off ${result.title} to map';

  @override
  State<DSOsintWorkbench> createState() => _DSOsintWorkbenchState();
}

class _DSOsintWorkbenchState extends State<DSOsintWorkbench> {
  late String _internalToolId;
  late String _internalQuery;
  final List<DSOsintHistoryEntry> _history = <DSOsintHistoryEntry>[];
  List<DSOsintResult> _internalResults = const <DSOsintResult>[];
  bool _hasSubmitted = false;
  String _lastSubmittedQuery = '';
  int _historySeq = 0;

  bool get _toolControlled => widget.activeToolId != null;

  String get _activeToolId {
    if (_toolControlled) return widget.activeToolId!;
    return _internalToolId;
  }

  DSOsintTool get _activeTool {
    final id = _activeToolId;
    for (final tool in widget.tools) {
      if (tool.id == id) return tool;
    }
    return widget.tools.first;
  }

  List<DSOsintResult> get _results => widget.results ?? _internalResults;

  DSOsintFixtureResolver get _resolver =>
      widget.resolver ?? DSOsintFixtures.resolve;

  @override
  void initState() {
    super.initState();
    _internalToolId = widget.initialToolId.isNotEmpty
        ? widget.initialToolId
        : widget.tools.first.id;
    // Ensure seed tool exists in registry.
    if (!widget.tools.any((t) => t.id == _internalToolId)) {
      _internalToolId = widget.tools.first.id;
    }
    _internalQuery = widget.initialQuery;
  }

  @override
  void didUpdateWidget(covariant DSOsintWorkbench oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_toolControlled &&
        widget.activeToolId != oldWidget.activeToolId &&
        widget.activeToolId != null) {
      // Parent owns tool; no local mirror needed.
    }
    if (widget.tools.isNotEmpty &&
        !widget.tools.any((t) => t.id == _activeToolId)) {
      final fallback = widget.tools.first.id;
      if (!_toolControlled) {
        setState(() => _internalToolId = fallback);
      }
    }
  }

  void _selectTool(DSOsintTool tool) {
    if (tool.id == _activeToolId) return;
    if (!_toolControlled) {
      setState(() => _internalToolId = tool.id);
    }
    widget.onToolChanged?.call(tool.id);
  }

  void _onQueryChanged(String value) {
    setState(() => _internalQuery = value);
  }

  void _submit() {
    final query = _internalQuery.trim();
    if (query.isEmpty || widget.isLoading) return;

    final tool = _activeTool;
    final results = _resolver(tool.id, query);

    setState(() {
      _hasSubmitted = true;
      _lastSubmittedQuery = query;
      if (widget.results == null) {
        _internalResults = results;
      }
      _historySeq += 1;
      final entry = DSOsintHistoryEntry(
        id: 'hist-$_historySeq',
        toolId: tool.id,
        toolLabel: tool.label,
        query: query,
        resultCount: results.length,
        submittedAt: DateTime.now(),
      );
      _history.insert(0, entry);
      if (_history.length > widget.maxHistory) {
        _history.removeRange(widget.maxHistory, _history.length);
      }
    });

    widget.onQuerySubmitted?.call(tool.id, query, results);
  }

  void _selectHistory(DSOsintHistoryEntry entry) {
    widget.onHistorySelected?.call(entry);

    // Restore tool + query and re-run fixture resolver.
    if (!_toolControlled) {
      setState(() {
        _internalToolId = entry.toolId;
        _internalQuery = entry.query;
      });
    } else {
      setState(() => _internalQuery = entry.query);
      widget.onToolChanged?.call(entry.toolId);
    }

    final results = _resolver(entry.toolId, entry.query);
    setState(() {
      _hasSubmitted = true;
      _lastSubmittedQuery = entry.query;
      if (widget.results == null) {
        _internalResults = results;
      }
    });
    widget.onQuerySubmitted?.call(entry.toolId, entry.query, results);
  }

  void _handoff(DSOsintResult result) {
    final cb = widget.onMapHandoff;
    if (cb == null || !result.hasGeo) return;
    cb(
      DSOsintMapHandoff.fromResult(
        result: result,
        toolId: _activeToolId,
        query: _lastSubmittedQuery.isNotEmpty
            ? _lastSubmittedQuery
            : _internalQuery.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(),
        const SizedBox(height: DSSpacing.sm),
        _buildToolTabs(),
        const SizedBox(height: DSSpacing.sm),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.showHistory) ...[
                SizedBox(
                  width: widget.historyWidth,
                  child: _buildHistoryRail(),
                ),
                const SizedBox(width: DSSpacing.sm),
                Container(width: 1, color: DSColors.borderSubtle),
                const SizedBox(width: DSSpacing.sm),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildQueryRow(),
                    const SizedBox(height: DSSpacing.sm),
                    Expanded(child: _buildResultsPane()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );

    final panel = widget.wrapInGlass
        ? DSGlassPanel.elevated(
            padding: const EdgeInsets.all(DSSpacing.md),
            child: body,
          )
        : Padding(padding: const EdgeInsets.all(DSSpacing.md), child: body);

    return Semantics(
      key: DSOsintWorkbench.panelKey,
      container: true,
      explicitChildNodes: true,
      label: DSOsintWorkbench.panelSemanticLabel,
      child: panel,
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const DSIcon.small(
          Icons.travel_explore_outlined,
          color: DSColors.accentCyan,
        ),
        const SizedBox(width: DSSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DSText.labelLarge(widget.panelTitle, color: DSColors.textPrimary),
              DSText.labelSmall(
                _activeTool.description ??
                    'Active tool: ${_activeTool.label} · fixtures only',
                color: DSColors.textTertiary,
              ),
            ],
          ),
        ),
        const DSBadge(
          label: 'FIXTURE',
          color: DSColors.accentGold,
          size: DSBadgeSize.small,
        ),
      ],
    );
  }

  Widget _buildToolTabs() {
    return Semantics(
      key: DSOsintWorkbench.toolTabsKey,
      container: true,
      label: DSOsintWorkbench.toolTabsSemanticLabel,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final tool in widget.tools) ...[
              _ToolTab(
                tool: tool,
                selected: tool.id == _activeToolId,
                onTap: () => _selectTool(tool),
              ),
              const SizedBox(width: DSSpacing.xs),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQueryRow() {
    final canSubmit = _internalQuery.trim().isNotEmpty && !widget.isLoading;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: KeyedSubtree(
            key: DSOsintWorkbench.queryFieldKey,
            child: DSSearchBar(
              placeholder: _activeTool.queryPlaceholder,
              value: _internalQuery,
              showFilter: false,
              onChanged: _onQueryChanged,
              onClear: () => setState(() => _internalQuery = ''),
            ),
          ),
        ),
        const SizedBox(width: DSSpacing.sm),
        Semantics(
          key: DSOsintWorkbench.submitButtonKey,
          button: true,
          enabled: canSubmit,
          label: DSOsintWorkbench.submitSemanticLabel,
          child: ExcludeSemantics(
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              child: Material(
                color: canSubmit
                    ? DSColors.accentCyan.withValues(alpha: 0.18)
                    : DSColors.obsidianElevated,
                borderRadius: BorderRadius.circular(DSRadii.button),
                child: InkWell(
                  onTap: canSubmit ? _submit : null,
                  borderRadius: BorderRadius.circular(DSRadii.button),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DSSpacing.md,
                      vertical: DSSpacing.sm,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.play_arrow_rounded,
                          size: 20,
                          color: canSubmit
                              ? DSColors.accentCyan
                              : DSColors.textTertiary,
                        ),
                        const SizedBox(width: DSSpacing.xs),
                        DSText.labelMedium(
                          widget.submitLabel,
                          color: canSubmit
                              ? DSColors.accentCyan
                              : DSColors.textTertiary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryRail() {
    if (_history.isEmpty) {
      return Semantics(
        label: DSOsintWorkbench.historySemanticLabel,
        child: const KeyedSubtree(
          key: DSOsintWorkbench.historyEmptyKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DSText.labelSmall('HISTORY', color: DSColors.textTertiary),
              SizedBox(height: DSSpacing.sm),
              Expanded(
                child: DSStateSurface.empty(
                  icon: Icons.history,
                  title: 'No history',
                  subtitle: 'Submitted queries appear here',
                  compact: true,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const DSText.labelSmall('HISTORY', color: DSColors.textTertiary),
        const SizedBox(height: DSSpacing.xs),
        Expanded(
          child: Semantics(
            label: DSOsintWorkbench.historySemanticLabel,
            child: ListView.builder(
              key: DSOsintWorkbench.historyListKey,
              itemCount: _history.length,
              itemBuilder: (context, index) {
                final entry = _history[index];
                return KeyedSubtree(
                  key: DSOsintWorkbench.historyRowKey(entry.id),
                  child: _HistoryRow(
                    entry: entry,
                    onTap: () => _selectHistory(entry),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultsPane() {
    if (widget.isLoading) {
      return Semantics(
        label: DSOsintWorkbench.loadingSemanticLabel,
        child: KeyedSubtree(
          key: DSOsintWorkbench.loadingStateKey,
          child: DSStateSurface.loading(
            title: widget.loadingTitle,
            compact: true,
          ),
        ),
      );
    }

    if (!_hasSubmitted) {
      return KeyedSubtree(
        key: DSOsintWorkbench.emptyStateKey,
        child: DSStateSurface.empty(
          icon: Icons.travel_explore_outlined,
          title: widget.idleTitle,
          subtitle: widget.idleSubtitle,
          compact: true,
        ),
      );
    }

    final results = _results;
    if (results.isEmpty) {
      return Semantics(
        label: DSOsintWorkbench.emptySemanticLabel,
        child: KeyedSubtree(
          key: DSOsintWorkbench.emptyStateKey,
          child: DSStateSurface.empty(
            icon: Icons.search_off_outlined,
            title: widget.emptyResultsTitle,
            subtitle: widget.emptyResultsSubtitle,
            compact: true,
          ),
        ),
      );
    }

    return Semantics(
      label: DSOsintWorkbench.resultsSemanticLabel,
      child: ListView.separated(
        key: DSOsintWorkbench.resultsListKey,
        itemCount: results.length,
        separatorBuilder: (_, __) => const SizedBox(height: DSSpacing.sm),
        itemBuilder: (context, index) {
          final result = results[index];
          return KeyedSubtree(
            key: DSOsintWorkbench.resultCardKey(result.id),
            child: _ResultCard(
              result: result,
              accent: _activeTool.color ?? DSColors.accentCyan,
              mapHandoffLabel: widget.mapHandoffLabel,
              showMapHandoff: widget.onMapHandoff != null && result.hasGeo,
              onMapHandoff: () => _handoff(result),
            ),
          );
        },
      ),
    );
  }
}

// =============================================================================
// Private chrome
// =============================================================================

class _ToolTab extends StatelessWidget {
  final DSOsintTool tool;
  final bool selected;
  final VoidCallback onTap;

  const _ToolTab({
    required this.tool,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = tool.color ?? DSColors.accentCyan;
    final bg = selected
        ? accent.withValues(alpha: 0.16)
        : DSColors.obsidianElevated;
    final border = selected
        ? accent.withValues(alpha: 0.55)
        : DSColors.borderSubtle;

    return Semantics(
      key: DSOsintWorkbench.toolTabKey(tool.id),
      button: true,
      selected: selected,
      label: DSOsintWorkbench.toolTabSemanticLabel(tool),
      child: ExcludeSemantics(
        child: Material(
          color: bg,
          borderRadius: BorderRadius.circular(DSRadii.sm),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(DSRadii.sm),
            child: Container(
              constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
              padding: const EdgeInsets.symmetric(
                horizontal: DSSpacing.sm,
                vertical: DSSpacing.xs,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(DSRadii.sm),
                border: Border.all(color: border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (tool.icon != null) ...[
                    Icon(
                      tool.icon,
                      size: 16,
                      color: selected ? accent : DSColors.textSecondary,
                    ),
                    const SizedBox(width: DSSpacing.xs),
                  ],
                  DSText.labelMedium(
                    tool.label,
                    color: selected ? accent : DSColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HistoryRow extends StatefulWidget {
  final DSOsintHistoryEntry entry;
  final VoidCallback onTap;

  const _HistoryRow({required this.entry, required this.onTap});

  @override
  State<_HistoryRow> createState() => _HistoryRowState();
}

class _HistoryRowState extends State<_HistoryRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    return Semantics(
      button: true,
      label: DSOsintWorkbench.historyRowSemanticLabel(entry),
      child: FocusableActionDetector(
        onShowHoverHighlight: (v) => setState(() => _hovered = v),
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              widget.onTap();
              return null;
            },
          ),
        },
        child: Material(
          color: _hovered ? DSColors.obsidianHover : DSColors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: DSSpacing.xs,
                  horizontal: DSSpacing.xs,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DSText.labelSmall(
                      entry.toolLabel.toUpperCase(),
                      color: DSColors.accentCyan,
                    ),
                    DSText.bodySmall(
                      entry.query,
                      color: DSColors.textPrimary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    DSText.labelSmall(
                      '${entry.resultCount} result(s)',
                      color: DSColors.textTertiary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final DSOsintResult result;
  final Color accent;
  final String mapHandoffLabel;
  final bool showMapHandoff;
  final VoidCallback onMapHandoff;

  const _ResultCard({
    required this.result,
    required this.accent,
    required this.mapHandoffLabel,
    required this.showMapHandoff,
    required this.onMapHandoff,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: DSOsintWorkbench.resultSemanticLabel(result),
      child: Container(
        padding: const EdgeInsets.all(DSSpacing.sm),
        decoration: BoxDecoration(
          color: DSColors.obsidianElevated,
          borderRadius: BorderRadius.circular(DSRadii.sm),
          border: Border.all(
            color: DSColors.borderSubtle.withValues(alpha: 0.8),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DSText.labelMedium(
                        result.title,
                        color: DSColors.textPrimary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (result.subtitle != null &&
                          result.subtitle!.isNotEmpty)
                        DSText.labelSmall(
                          result.subtitle!,
                          color: DSColors.textTertiary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                DSBadge(
                  label: result.resultType.toUpperCase(),
                  color: accent,
                  size: DSBadgeSize.small,
                ),
                if (showMapHandoff) ...[
                  const SizedBox(width: DSSpacing.xs),
                  Semantics(
                    key: DSOsintWorkbench.mapHandoffKey(result.id),
                    button: true,
                    label: DSOsintWorkbench.mapHandoffSemanticLabel(result),
                    child: ExcludeSemantics(
                      child: IconButton(
                        tooltip: mapHandoffLabel,
                        icon: Icon(Icons.map_outlined, size: 18, color: accent),
                        onPressed: onMapHandoff,
                        constraints: const BoxConstraints(
                          minWidth: 48,
                          minHeight: 48,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (result.fields.isNotEmpty) ...[
              const SizedBox(height: DSSpacing.xs),
              for (final field in result.fields)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 72,
                        child: DSText.labelSmall(
                          field.label,
                          color: DSColors.textTertiary,
                        ),
                      ),
                      Expanded(
                        child: DSText.bodySmall(
                          field.value,
                          color: DSColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
            if (result.hasGeo) ...[
              const SizedBox(height: DSSpacing.xs),
              DSText.labelSmall(
                '${result.latitude}, ${result.longitude}',
                color: DSColors.textTertiary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
