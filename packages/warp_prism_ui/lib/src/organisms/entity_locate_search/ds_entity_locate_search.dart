import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../atoms/ds_badge.dart';
import '../../atoms/ds_glass_panel.dart';
import '../../atoms/ds_icon.dart';
import '../../atoms/ds_text.dart';
import '../../molecules/ds_filter_chip_group.dart';
import '../../molecules/ds_search_bar.dart';
import '../../molecules/ds_state_surface.dart';
import '../../tokens/tokens.dart';

// =============================================================================
// Models
// =============================================================================

/// Named searchable corpus for [DSEntityLocateSearch].
///
/// Fixture-friendly multi-corpus index. Each corpus holds [entries] that the
/// organism matches by query. No live geocoder or network required.
@immutable
class DSLocateCorpus {
  /// Stable corpus identity (e.g. `"agents"`, `"places"`).
  final String id;

  /// Human-readable corpus label shown on chips and result rows.
  final String label;

  /// Optional leading icon for corpus chrome.
  final IconData? icon;

  /// Optional accent for badges / chips.
  final Color? color;

  /// Searchable entries in this corpus.
  final List<DSLocateEntry> entries;

  const DSLocateCorpus({
    required this.id,
    required this.label,
    this.icon,
    this.color,
    this.entries = const <DSLocateEntry>[],
  });

  DSLocateCorpus copyWith({
    String? id,
    String? label,
    IconData? icon,
    Color? color,
    List<DSLocateEntry>? entries,
    bool clearIcon = false,
    bool clearColor = false,
  }) {
    return DSLocateCorpus(
      id: id ?? this.id,
      label: label ?? this.label,
      icon: clearIcon ? null : (icon ?? this.icon),
      color: clearColor ? null : (color ?? this.color),
      entries: entries ?? this.entries,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DSLocateCorpus &&
        other.id == id &&
        other.label == label &&
        other.icon == icon &&
        other.color == color &&
        _listEquals(other.entries, entries);
  }

  @override
  int get hashCode =>
      Object.hash(id, label, icon, color, Object.hashAll(entries));
}

/// Single searchable entity/place entry within a [DSLocateCorpus].
///
/// Spatial fields ([latitude], [longitude], [zoom]) are optional so non-map
/// entity corpora (agents, skills) remain valid without coordinates.
@immutable
class DSLocateEntry {
  /// Stable entity identity within its corpus.
  final String id;

  /// Primary display label.
  final String label;

  /// Optional secondary line (type, owner, region, etc.).
  final String? sublabel;

  /// Domain entity kind (e.g. `"agent"`, `"place"`, `"skill"`).
  ///
  /// This is **not** a command palette command id — it identifies an entity
  /// for locate / fly-to / selection payloads.
  final String entityType;

  /// Optional WGS84 latitude for map fly-to.
  final double? latitude;

  /// Optional WGS84 longitude for map fly-to.
  final double? longitude;

  /// Optional preferred camera zoom when locating on a map stage.
  final double? zoom;

  /// Optional leading icon override.
  final IconData? icon;

  /// Extra free-text included in query matching (tags, aliases, owners).
  final String? searchText;

  /// Opaque fixture metadata bag (read-only consumers).
  final Map<String, Object?> metadata;

  const DSLocateEntry({
    required this.id,
    required this.label,
    this.sublabel,
    required this.entityType,
    this.latitude,
    this.longitude,
    this.zoom,
    this.icon,
    this.searchText,
    this.metadata = const <String, Object?>{},
  });

  /// Whether this entry carries spatial coordinates.
  bool get hasCoordinates => latitude != null && longitude != null;

  /// Combined haystack used by the default matcher.
  String get matchHaystack {
    final parts = <String>[
      id,
      label,
      if (sublabel != null) sublabel!,
      entityType,
      if (searchText != null) searchText!,
    ];
    return parts.join(' ').toLowerCase();
  }

  DSLocateEntry copyWith({
    String? id,
    String? label,
    String? sublabel,
    String? entityType,
    double? latitude,
    double? longitude,
    double? zoom,
    IconData? icon,
    String? searchText,
    Map<String, Object?>? metadata,
    bool clearSublabel = false,
    bool clearLatitude = false,
    bool clearLongitude = false,
    bool clearZoom = false,
    bool clearIcon = false,
    bool clearSearchText = false,
  }) {
    return DSLocateEntry(
      id: id ?? this.id,
      label: label ?? this.label,
      sublabel: clearSublabel ? null : (sublabel ?? this.sublabel),
      entityType: entityType ?? this.entityType,
      latitude: clearLatitude ? null : (latitude ?? this.latitude),
      longitude: clearLongitude ? null : (longitude ?? this.longitude),
      zoom: clearZoom ? null : (zoom ?? this.zoom),
      icon: clearIcon ? null : (icon ?? this.icon),
      searchText: clearSearchText ? null : (searchText ?? this.searchText),
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DSLocateEntry &&
        other.id == id &&
        other.label == label &&
        other.sublabel == sublabel &&
        other.entityType == entityType &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.zoom == zoom &&
        other.icon == icon &&
        other.searchText == searchText;
  }

  @override
  int get hashCode => Object.hash(
    id,
    label,
    sublabel,
    entityType,
    latitude,
    longitude,
    zoom,
    icon,
    searchText,
  );
}

/// Locate selection payload emitted by [DSEntityLocateSearch.onLocate].
///
/// **False-gap vs [DSCommand] / command palette:**
/// - Command palette executes a [DSCommand] by **command id** (navigate / run).
/// - This payload identifies an **entity/place** for map fly-to or asset focus
///   via [entityId], [entityType], [corpusId], and optional spatial fields.
/// - Do **not** treat [entityId] as a command registry key.
@immutable
class DSLocateResult {
  /// Selected entry identity (entity id, not a command id).
  final String entityId;

  /// Primary label.
  final String label;

  /// Optional secondary line.
  final String? sublabel;

  /// Corpus the entry was found in.
  final String corpusId;

  /// Human corpus label at selection time.
  final String corpusLabel;

  /// Domain entity kind for consumers (agent, place, …).
  final String entityType;

  /// Optional latitude for fly-to.
  final double? latitude;

  /// Optional longitude for fly-to.
  final double? longitude;

  /// Optional preferred zoom.
  final double? zoom;

  /// Optional icon.
  final IconData? icon;

  /// Optional corpus accent color.
  final Color? corpusColor;

  /// Opaque metadata from the source entry.
  final Map<String, Object?> metadata;

  const DSLocateResult({
    required this.entityId,
    required this.label,
    this.sublabel,
    required this.corpusId,
    required this.corpusLabel,
    required this.entityType,
    this.latitude,
    this.longitude,
    this.zoom,
    this.icon,
    this.corpusColor,
    this.metadata = const <String, Object?>{},
  });

  /// Whether spatial coordinates are present for map locate.
  bool get hasCoordinates => latitude != null && longitude != null;

  /// Build a result from a corpus + entry pair.
  factory DSLocateResult.fromCorpusEntry({
    required DSLocateCorpus corpus,
    required DSLocateEntry entry,
  }) {
    return DSLocateResult(
      entityId: entry.id,
      label: entry.label,
      sublabel: entry.sublabel,
      corpusId: corpus.id,
      corpusLabel: corpus.label,
      entityType: entry.entityType,
      latitude: entry.latitude,
      longitude: entry.longitude,
      zoom: entry.zoom,
      icon: entry.icon ?? corpus.icon,
      corpusColor: corpus.color,
      metadata: entry.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DSLocateResult &&
        other.entityId == entityId &&
        other.label == label &&
        other.sublabel == sublabel &&
        other.corpusId == corpusId &&
        other.corpusLabel == corpusLabel &&
        other.entityType == entityType &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.zoom == zoom &&
        other.icon == icon &&
        other.corpusColor == corpusColor;
  }

  @override
  int get hashCode => Object.hash(
    entityId,
    label,
    sublabel,
    corpusId,
    corpusLabel,
    entityType,
    latitude,
    longitude,
    zoom,
    icon,
    corpusColor,
  );
}

// =============================================================================
// Organism
// =============================================================================

/// ASW Observatory Organism — Entity Locate Search
///
/// Multi-corpus entity/place locate bar: type a query, scan fixture corpora,
/// select a result to emit a **locate** payload (entity id + type + optional
/// lat/lng). Composes [DSSearchBar] + corpus chips + result rows.
///
/// ## False-gap vs [DSCommandPalette]
///
/// | Concern | [DSCommandPalette] | [DSEntityLocateSearch] |
/// | --- | --- | --- |
/// | Intent | Execute commands | Locate entities/places |
/// | Payload | [DSCommand] (`id`, `onExecute`, `route`) | [DSLocateResult] (`entityId`, `entityType`, coords) |
/// | Index | Command registry | Multi-corpus fixture entries |
/// | UX | Modal overlay + categories | Inline bar + results list |
///
/// Do **not** collapse this into the command palette — map/entity locate is a
/// dedicated ADS surface (EPIC-15 O-05 / Task 1506).
///
/// Host layout contract: the results pane uses [Expanded], so the parent must
/// provide a **bounded height** (e.g. `SizedBox(height: …)` or a flex child with
/// a max extent). Unbounded parents (unconstrained `Column` / vertical
/// `ListView` children) will throw a layout exception.
///
/// Fixture/read-only: no live geocoder, no MapLibre, no product-route coupling.
class DSEntityLocateSearch extends StatefulWidget {
  /// Fixture corpora to search (≥2 recommended for multi-corpus demos).
  final List<DSLocateCorpus> corpora;

  /// Called when the user selects a result (row tap or locate action).
  ///
  /// Receives a [DSLocateResult] entity/spatial payload — **not** a command id.
  final ValueChanged<DSLocateResult>? onLocate;

  /// Called whenever the query text changes (trimmed value).
  final ValueChanged<String>? onQueryChanged;

  /// Called when the clear control empties the query.
  final VoidCallback? onClear;

  /// Controlled query. When non-null, parent owns the query string.
  final String? query;

  /// Seed query for uncontrolled mode.
  final String initialQuery;

  /// Placeholder for the search field.
  final String placeholder;

  /// Parent-driven loading flag (e.g. async fixture index).
  final bool isLoading;

  /// Optional debounce before applying the query to results.
  ///
  /// When non-zero, the organism shows an internal loading pulse while waiting.
  /// Use [Duration.zero] (default) for synchronous fixture matching.
  final Duration searchDelay;

  /// Max results after ranking (across all active corpora).
  final int maxResults;

  /// Controlled set of active corpus ids. Null → all corpora active.
  final Set<String>? activeCorpusIds;

  /// Seed active corpora for uncontrolled chip state. Empty → all active.
  final Set<String> initialActiveCorpusIds;

  /// Called when corpus chip selection changes.
  final ValueChanged<Set<String>>? onActiveCorporaChanged;

  /// Show corpus filter chips under the search field.
  final bool showCorpusChips;

  /// Whether to wrap the panel in [DSGlassPanel.elevated].
  final bool wrapInGlass;

  /// Auto-focus the search field on mount.
  final bool autofocus;

  /// Keep the results list visible even with an empty query (shows idle hint).
  final bool alwaysShowResultsPane;

  /// Empty-query idle title.
  final String idleTitle;

  /// Empty-query idle subtitle.
  final String idleSubtitle;

  /// No-match empty title.
  final String noResultsTitle;

  /// No-match empty subtitle.
  final String noResultsSubtitle;

  /// Loading title.
  final String loadingTitle;

  /// Results footer template — use `{count}` placeholder.
  final String resultsFooterTemplate;

  const DSEntityLocateSearch({
    super.key,
    required this.corpora,
    this.onLocate,
    this.onQueryChanged,
    this.onClear,
    this.query,
    this.initialQuery = '',
    this.placeholder = 'Locate entity or place…',
    this.isLoading = false,
    this.searchDelay = Duration.zero,
    this.maxResults = 12,
    this.activeCorpusIds,
    this.initialActiveCorpusIds = const <String>{},
    this.onActiveCorporaChanged,
    this.showCorpusChips = true,
    this.wrapInGlass = true,
    this.autofocus = false,
    this.alwaysShowResultsPane = true,
    this.idleTitle = 'Type to locate',
    this.idleSubtitle = 'Search across fixture corpora',
    this.noResultsTitle = 'No matching entities',
    this.noResultsSubtitle = 'Try another query or enable more corpora',
    this.loadingTitle = 'Searching corpora…',
    this.resultsFooterTemplate = '{count} RESULT(S) — SELECT TO LOCATE',
  });

  // ---------------------------------------------------------------------------
  // Keys + semantics (tests / a11y)
  // ---------------------------------------------------------------------------

  /// Root panel key.
  static const Key panelKey = Key('ds-entity-locate-search');

  /// Search field host key.
  static const Key searchFieldKey = Key('ds-entity-locate-search-field');

  /// Results list key.
  static const Key resultsListKey = Key('ds-entity-locate-search-results');

  /// Empty / idle / no-match surface key.
  static const Key emptyStateKey = Key('ds-entity-locate-search-empty');

  /// Loading surface key.
  static const Key loadingStateKey = Key('ds-entity-locate-search-loading');

  /// Corpus chips row key.
  static const Key corpusChipsKey = Key('ds-entity-locate-search-corpus-chips');

  /// Results footer key.
  static const Key footerKey = Key('ds-entity-locate-search-footer');

  /// Result row key by entity id + corpus id.
  static Key resultRowKey(String corpusId, String entityId) =>
      Key('ds-entity-locate-search-result-$corpusId-$entityId');

  /// Locate action key on a result row.
  static Key locateActionKey(String corpusId, String entityId) =>
      Key('ds-entity-locate-search-locate-$corpusId-$entityId');

  /// Root region semantic label.
  static const String panelSemanticLabel = 'Entity locate search';

  /// Search field semantic label (matches default [placeholder] via [DSSearchBar]).
  static const String searchFieldSemanticLabel = 'Locate entity or place…';

  /// Results list semantic label.
  static const String resultsSemanticLabel = 'Locate results';

  /// Loading semantic label.
  static const String loadingSemanticLabel = 'Searching locate corpora';

  /// Empty / no-match semantic label prefix (title appended in Semantics).
  static const String emptySemanticLabel = 'No locate results';

  /// Build a result row semantic label.
  static String resultSemanticLabel(DSLocateResult result) {
    final coords = result.hasCoordinates
        ? ', coordinates ${result.latitude}, ${result.longitude}'
        : '';
    return 'Locate ${result.label}, ${result.corpusLabel}, '
        '${result.entityType}$coords';
  }

  /// Locate action semantic label.
  static String locateActionSemanticLabel(DSLocateResult result) =>
      'Locate ${result.label}';

  /// Filter corpora by query + active corpus set (pure helper for tests).
  static List<DSLocateResult> matchResults({
    required List<DSLocateCorpus> corpora,
    required String query,
    Set<String>? activeCorpusIds,
    int maxResults = 12,
  }) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const <DSLocateResult>[];

    final active = activeCorpusIds == null || activeCorpusIds.isEmpty
        ? null
        : activeCorpusIds;
    final tokens = trimmed
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty)
        .toList(growable: false);

    final out = <DSLocateResult>[];
    for (final corpus in corpora) {
      if (active != null && !active.contains(corpus.id)) continue;
      for (final entry in corpus.entries) {
        final hay = entry.matchHaystack;
        final corpusHay = '${corpus.id} ${corpus.label}'.toLowerCase();
        final combined = '$hay $corpusHay';
        final matches = tokens.every(combined.contains);
        if (!matches) continue;
        out.add(DSLocateResult.fromCorpusEntry(corpus: corpus, entry: entry));
        if (out.length >= maxResults) return out;
      }
    }
    return out;
  }

  @override
  State<DSEntityLocateSearch> createState() => _DSEntityLocateSearchState();
}

class _DSEntityLocateSearchState extends State<DSEntityLocateSearch> {
  late String _internalQuery;
  late Set<String> _internalActiveCorpora;
  String _appliedQuery = '';
  bool _debounceLoading = false;
  Timer? _debounceTimer;

  bool get _queryControlled => widget.query != null;

  bool get _corporaControlled => widget.activeCorpusIds != null;

  String get _query => _queryControlled ? widget.query! : _internalQuery;

  Set<String> get _activeCorpora {
    if (_corporaControlled) {
      final controlled = widget.activeCorpusIds!;
      if (controlled.isEmpty) {
        return widget.corpora.map((c) => c.id).toSet();
      }
      return controlled;
    }
    if (_internalActiveCorpora.isEmpty) {
      return widget.corpora.map((c) => c.id).toSet();
    }
    return _internalActiveCorpora;
  }

  bool get _showLoading => widget.isLoading || _debounceLoading;

  @override
  void initState() {
    super.initState();
    _internalQuery = widget.initialQuery;
    _internalActiveCorpora = Set<String>.from(widget.initialActiveCorpusIds);
    _appliedQuery = _query;
  }

  @override
  void didUpdateWidget(covariant DSEntityLocateSearch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_queryControlled && widget.query != oldWidget.query) {
      _scheduleApply(widget.query ?? '');
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _scheduleApply(String raw) {
    final next = raw;
    _debounceTimer?.cancel();

    if (widget.searchDelay <= Duration.zero) {
      if (!mounted) return;
      setState(() {
        _debounceLoading = false;
        _appliedQuery = next;
      });
      return;
    }

    setState(() => _debounceLoading = true);
    _debounceTimer = Timer(widget.searchDelay, () {
      if (!mounted) return;
      setState(() {
        _debounceLoading = false;
        _appliedQuery = next;
      });
    });
  }

  void _onQueryChanged(String value) {
    if (!_queryControlled) {
      setState(() => _internalQuery = value);
    }
    widget.onQueryChanged?.call(value);
    _scheduleApply(value);
  }

  void _onClear() {
    if (!_queryControlled) {
      setState(() => _internalQuery = '');
    }
    widget.onClear?.call();
    widget.onQueryChanged?.call('');
    _scheduleApply('');
  }

  void _toggleCorpus(String corpusId) {
    final current = Set<String>.from(_activeCorpora);
    // Keep at least one corpus active for predictable empty/no-match UX.
    if (current.contains(corpusId)) {
      if (current.length <= 1) return;
      current.remove(corpusId);
    } else {
      current.add(corpusId);
    }

    if (!_corporaControlled) {
      setState(() => _internalActiveCorpora = current);
    }
    widget.onActiveCorporaChanged?.call(Set<String>.unmodifiable(current));
  }

  void _select(DSLocateResult result) {
    HapticFeedback.selectionClick();
    widget.onLocate?.call(result);
  }

  List<DSLocateResult> get _results {
    return DSEntityLocateSearch.matchResults(
      corpora: widget.corpora,
      query: _appliedQuery,
      activeCorpusIds: _activeCorpora,
      maxResults: widget.maxResults,
    );
  }

  @override
  Widget build(BuildContext context) {
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KeyedSubtree(
          key: DSEntityLocateSearch.searchFieldKey,
          child: DSSearchBar(
            placeholder: widget.placeholder,
            value: _query,
            onChanged: _onQueryChanged,
            onClear: _onClear,
            showFilter: false,
            autofocus: widget.autofocus,
          ),
        ),
        if (widget.showCorpusChips && widget.corpora.isNotEmpty) ...[
          const SizedBox(height: DSSpacing.sm),
          KeyedSubtree(
            key: DSEntityLocateSearch.corpusChipsKey,
            child: DSFilterChipGroup(
              options: [
                for (final corpus in widget.corpora)
                  DSFilterOption(
                    value: corpus.id,
                    label: corpus.label,
                    count: corpus.entries.length,
                    color: corpus.color,
                  ),
              ],
              selected: _activeCorpora,
              onToggle: _toggleCorpus,
              allowMultiple: true,
              showCount: true,
            ),
          ),
        ],
        const SizedBox(height: DSSpacing.sm),
        Expanded(child: _buildResultsPane()),
      ],
    );

    final panel = widget.wrapInGlass
        ? DSGlassPanel.elevated(
            padding: const EdgeInsets.all(DSSpacing.md),
            child: body,
          )
        : Padding(padding: const EdgeInsets.all(DSSpacing.md), child: body);

    return Semantics(
      key: DSEntityLocateSearch.panelKey,
      container: true,
      explicitChildNodes: true,
      label: DSEntityLocateSearch.panelSemanticLabel,
      child: panel,
    );
  }

  Widget _buildResultsPane() {
    if (_showLoading) {
      return Semantics(
        label: DSEntityLocateSearch.loadingSemanticLabel,
        child: KeyedSubtree(
          key: DSEntityLocateSearch.loadingStateKey,
          child: DSStateSurface.loading(
            title: widget.loadingTitle,
            compact: true,
          ),
        ),
      );
    }

    final trimmed = _appliedQuery.trim();
    final showIdle = trimmed.isEmpty;
    final results = _results;

    if (showIdle) {
      if (!widget.alwaysShowResultsPane) {
        return const SizedBox.shrink();
      }
      return KeyedSubtree(
        key: DSEntityLocateSearch.emptyStateKey,
        child: DSStateSurface.empty(
          icon: DSIcons.search,
          title: widget.idleTitle,
          subtitle: widget.idleSubtitle,
          compact: true,
        ),
      );
    }

    if (results.isEmpty) {
      return Semantics(
        label: DSEntityLocateSearch.emptySemanticLabel,
        child: KeyedSubtree(
          key: DSEntityLocateSearch.emptyStateKey,
          child: DSStateSurface.empty(
            icon: Icons.search_off_outlined,
            title: widget.noResultsTitle,
            subtitle: widget.noResultsSubtitle,
            compact: true,
          ),
        ),
      );
    }

    final footer = widget.resultsFooterTemplate.replaceAll(
      '{count}',
      '${results.length}',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Semantics(
            label: DSEntityLocateSearch.resultsSemanticLabel,
            child: ListView.separated(
              key: DSEntityLocateSearch.resultsListKey,
              itemCount: results.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                thickness: 1,
                color: DSColors.borderSubtle.withValues(alpha: 0.6),
              ),
              itemBuilder: (context, index) {
                final result = results[index];
                return KeyedSubtree(
                  key: DSEntityLocateSearch.resultRowKey(
                    result.corpusId,
                    result.entityId,
                  ),
                  child: _LocateResultRow(
                    result: result,
                    onSelect: () => _select(result),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: DSSpacing.xs),
        KeyedSubtree(
          key: DSEntityLocateSearch.footerKey,
          child: DSText.labelSmall(footer, color: DSColors.textTertiary),
        ),
      ],
    );
  }
}

// =============================================================================
// Result row
// =============================================================================

class _LocateResultRow extends StatefulWidget {
  final DSLocateResult result;
  final VoidCallback onSelect;

  const _LocateResultRow({required this.result, required this.onSelect});

  @override
  State<_LocateResultRow> createState() => _LocateResultRowState();
}

class _LocateResultRowState extends State<_LocateResultRow> {
  bool _hovered = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final accent = result.corpusColor ?? DSColors.accentBlue;
    final bg = (_hovered || _focused)
        ? DSColors.obsidianHover
        : DSColors.transparent;

    return Semantics(
      button: true,
      label: DSEntityLocateSearch.resultSemanticLabel(result),
      child: FocusableActionDetector(
        onShowHoverHighlight: (v) => setState(() => _hovered = v),
        onShowFocusHighlight: (v) => setState(() => _focused = v),
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              widget.onSelect();
              return null;
            },
          ),
        },
        child: Material(
          color: bg,
          child: InkWell(
            onTap: widget.onSelect,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: kMinInteractiveDimension,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: DSSpacing.sm,
                  vertical: DSSpacing.sm,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: DSColors.obsidianElevated,
                        borderRadius: BorderRadius.circular(DSRadii.sm),
                        border: Border.all(
                          color: accent.withValues(alpha: 0.35),
                        ),
                      ),
                      child: DSIcon.small(
                        result.icon ?? DSIcons.search,
                        color: accent,
                      ),
                    ),
                    const SizedBox(width: DSSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DSText.labelMedium(
                            result.label,
                            color: DSColors.textPrimary,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (result.sublabel != null &&
                              result.sublabel!.isNotEmpty)
                            DSText.labelSmall(
                              result.sublabel!,
                              color: DSColors.textTertiary,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: DSSpacing.xs),
                    DSBadge(
                      label: result.corpusLabel.toUpperCase(),
                      color: accent,
                      size: DSBadgeSize.small,
                    ),
                    const SizedBox(width: DSSpacing.xs),
                    // IconButton owns button semantics via [tooltip] — no nested
                    // ExcludeSemantics / re-labeled Semantics wrapper.
                    IconButton(
                      key: DSEntityLocateSearch.locateActionKey(
                        result.corpusId,
                        result.entityId,
                      ),
                      tooltip: DSEntityLocateSearch.locateActionSemanticLabel(
                        result,
                      ),
                      icon: Icon(
                        Icons.my_location_outlined,
                        size: 18,
                        color: accent,
                      ),
                      onPressed: widget.onSelect,
                      constraints: const BoxConstraints(
                        minWidth: kMinInteractiveDimension,
                        minHeight: kMinInteractiveDimension,
                      ),
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

bool _listEquals<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
