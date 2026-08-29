import 'package:flutter/material.dart';

import '../../atoms/atoms.dart';
import '../../molecules/ds_interactive_surface.dart';
import '../../molecules/ds_state_surface.dart';
import '../../tokens/tokens.dart';
import '../code_block/ds_code_block.dart';
import '../split_pane/ds_split_pane.dart';
import '../timing_waterfall/ds_timing_waterfall.dart';

// =============================================================================
// Models
// =============================================================================

/// Detail tab keys for [DSTrafficInspector].
enum DSTrafficDetailTab {
  /// Method / URL / status / duration overview.
  overview,

  /// Request + response headers as plain text.
  headers,

  /// Request + response body fixtures.
  body,

  /// Optional embedded [DSTimingWaterfall] for the selected request.
  timing,
}

/// Immutable traffic request model for [DSTrafficInspector].
///
/// Fixture-only — no live MITM, proxy capture, or network dependencies.
@immutable
class DSTrafficRequest {
  /// Stable unique id (mock request id).
  final String id;

  /// HTTP method (GET, POST, …).
  final String method;

  /// Request path or URL (fixture string).
  final String url;

  /// HTTP status code (0 = pending / unknown).
  final int statusCode;

  /// Total duration in milliseconds.
  final int durationMs;

  /// Optional provider / route label.
  final String? provider;

  /// Request headers as plain text fixture.
  final String requestHeaders;

  /// Response headers as plain text fixture.
  final String responseHeaders;

  /// Request body fixture (may be empty).
  final String requestBody;

  /// Response body fixture (may be empty).
  final String responseBody;

  /// Optional timing spans for embedded waterfall.
  final List<DSTimingSpan> timingSpans;

  /// Optional wall-clock label for list meta.
  final String? timestampLabel;

  const DSTrafficRequest({
    required this.id,
    required this.method,
    required this.url,
    required this.statusCode,
    required this.durationMs,
    this.provider,
    this.requestHeaders = '',
    this.responseHeaders = '',
    this.requestBody = '',
    this.responseBody = '',
    this.timingSpans = const [],
    this.timestampLabel,
  });

  /// Formatted duration label.
  String get durationLabel {
    if (durationMs < 1000) return '${durationMs}ms';
    final seconds = durationMs / 1000.0;
    return '${seconds.toStringAsFixed(seconds >= 10 ? 0 : 1)}s';
  }

  /// Status class for color accents.
  bool get isSuccess => statusCode >= 200 && statusCode < 300;
  bool get isClientError => statusCode >= 400 && statusCode < 500;
  bool get isServerError => statusCode >= 500;
  bool get isPending => statusCode <= 0;

  Color get statusColor {
    if (isPending) return DSColors.textTertiary;
    if (isSuccess) return DSColors.statusSuccess;
    if (isClientError) return DSColors.statusWarning;
    if (isServerError) return DSColors.statusError;
    return DSColors.statusInfo;
  }

  /// List-row semantic label.
  String get semanticLabel {
    final status = isPending ? 'pending' : '$statusCode';
    return '$method $url, status $status, $durationLabel';
  }

  DSTrafficRequest copyWith({
    String? id,
    String? method,
    String? url,
    int? statusCode,
    int? durationMs,
    String? provider,
    String? requestHeaders,
    String? responseHeaders,
    String? requestBody,
    String? responseBody,
    List<DSTimingSpan>? timingSpans,
    String? timestampLabel,
    bool clearProvider = false,
    bool clearTimestamp = false,
  }) {
    return DSTrafficRequest(
      id: id ?? this.id,
      method: method ?? this.method,
      url: url ?? this.url,
      statusCode: statusCode ?? this.statusCode,
      durationMs: durationMs ?? this.durationMs,
      provider: clearProvider ? null : (provider ?? this.provider),
      requestHeaders: requestHeaders ?? this.requestHeaders,
      responseHeaders: responseHeaders ?? this.responseHeaders,
      requestBody: requestBody ?? this.requestBody,
      responseBody: responseBody ?? this.responseBody,
      timingSpans: timingSpans ?? this.timingSpans,
      timestampLabel: clearTimestamp
          ? null
          : (timestampLabel ?? this.timestampLabel),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DSTrafficRequest &&
        other.id == id &&
        other.method == method &&
        other.url == url &&
        other.statusCode == statusCode &&
        other.durationMs == durationMs &&
        other.provider == provider &&
        other.requestHeaders == requestHeaders &&
        other.responseHeaders == responseHeaders &&
        other.requestBody == requestBody &&
        other.responseBody == responseBody &&
        other.timestampLabel == timestampLabel &&
        _listEquals(other.timingSpans, timingSpans);
  }

  @override
  int get hashCode => Object.hash(
    id,
    method,
    url,
    statusCode,
    durationMs,
    provider,
    requestHeaders,
    responseHeaders,
    requestBody,
    responseBody,
    timestampLabel,
    Object.hashAll(timingSpans),
  );

  static bool _listEquals<T>(List<T> a, List<T> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

// =============================================================================
// Organism
// =============================================================================

/// ASW Observatory Organism — Traffic Inspector
///
/// Request list + detail MVP (OmniRoute C-10). Fixture-first CyberCore ops
/// surface — **no live MITM**, proxy backends, or network capture deps.
///
/// Contract:
/// - [requests] drive the list; empty → empty surface (no crash).
/// - Selection (controlled or uncontrolled) drives detail panes.
/// - Detail tabs: overview / headers / body / optional timing waterfall.
/// - May embed [DSTimingWaterfall] when the selected request has spans.
class DSTrafficInspector extends StatefulWidget {
  /// Fixture request list.
  final List<DSTrafficRequest> requests;

  /// Controlled selection id. When non-null, parent owns selection.
  final String? selectedId;

  /// Seed selection for uncontrolled mode.
  final String? initialSelectedId;

  /// Fired when the user selects a request.
  final ValueChanged<DSTrafficRequest?>? onSelectionChanged;

  /// Panel title.
  final String title;

  /// Optional subtitle.
  final String? subtitle;

  /// Region semantic label.
  final String semanticLabel;

  /// List region semantic label.
  final String listSemanticLabel;

  /// Detail region semantic label.
  final String detailSemanticLabel;

  /// Empty-list title.
  final String emptyTitle;

  /// Empty-list subtitle.
  final String emptySubtitle;

  /// No-selection title.
  final String noSelectionTitle;

  /// No-selection subtitle.
  final String noSelectionSubtitle;

  /// Use [DSSplitPane] for list/detail.
  final bool useSplitPane;

  /// Fixed list width when not using split pane.
  final double listWidth;

  /// Split ratio for list pane.
  final double splitInitialRatio;

  /// Wrap panel in glass chrome.
  final bool wrapInGlass;

  /// Initial detail tab.
  final DSTrafficDetailTab initialDetailTab;

  /// When true, show timing tab and embed waterfall for selected request.
  final bool showTimingTab;

  /// Max height for body code blocks.
  final double? bodyMaxHeight;

  const DSTrafficInspector({
    super.key,
    required this.requests,
    this.selectedId,
    this.initialSelectedId,
    this.onSelectionChanged,
    this.title = 'Traffic',
    this.subtitle,
    this.semanticLabel = 'Traffic inspector',
    this.listSemanticLabel = 'Request list',
    this.detailSemanticLabel = 'Request detail',
    this.emptyTitle = 'No traffic',
    this.emptySubtitle = 'Fixture requests will appear here',
    this.noSelectionTitle = 'No selection',
    this.noSelectionSubtitle = 'Select a request to inspect',
    this.useSplitPane = true,
    this.listWidth = 300,
    this.splitInitialRatio = 0.36,
    this.wrapInGlass = true,
    this.initialDetailTab = DSTrafficDetailTab.overview,
    this.showTimingTab = true,
    this.bodyMaxHeight = 240,
  });

  static const Key panelKey = Key('ds-traffic-inspector');
  static const Key listKey = Key('ds-traffic-inspector-list');
  static const Key detailKey = Key('ds-traffic-inspector-detail');
  static const Key emptyKey = Key('ds-traffic-inspector-empty');
  static const Key noSelectionKey = Key('ds-traffic-inspector-no-selection');
  static const Key tabBarKey = Key('ds-traffic-inspector-tabs');

  static Key rowKey(String requestId) =>
      Key('ds-traffic-inspector-row-$requestId');

  static Key tabKey(DSTrafficDetailTab tab) =>
      Key('ds-traffic-inspector-tab-${tab.name}');

  @override
  State<DSTrafficInspector> createState() => _DSTrafficInspectorState();
}

class _DSTrafficInspectorState extends State<DSTrafficInspector> {
  String? _uncontrolledSelectedId;
  late DSTrafficDetailTab _detailTab;

  @override
  void initState() {
    super.initState();
    _uncontrolledSelectedId = _resolveInitialSelection();
    _detailTab = widget.initialDetailTab;
  }

  @override
  void didUpdateWidget(DSTrafficInspector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedId != null) return;

    final ids = widget.requests.map((r) => r.id).toSet();
    if (_uncontrolledSelectedId != null &&
        !ids.contains(_uncontrolledSelectedId)) {
      _uncontrolledSelectedId = _resolveInitialSelection();
    } else if (_uncontrolledSelectedId == null && widget.requests.isNotEmpty) {
      _uncontrolledSelectedId = _resolveInitialSelection();
    }
  }

  String? _resolveInitialSelection() {
    if (widget.requests.isEmpty) return null;
    final seed = widget.initialSelectedId;
    if (seed != null && widget.requests.any((r) => r.id == seed)) {
      return seed;
    }
    return widget.requests.first.id;
  }

  String? get _effectiveSelectedId =>
      widget.selectedId ?? _uncontrolledSelectedId;

  DSTrafficRequest? get _selectedRequest {
    final id = _effectiveSelectedId;
    if (id == null) return null;
    for (final r in widget.requests) {
      if (r.id == id) return r;
    }
    return null;
  }

  void _select(DSTrafficRequest request) {
    if (widget.selectedId == null) {
      setState(() => _uncontrolledSelectedId = request.id);
    }
    widget.onSelectionChanged?.call(request);
  }

  void _setTab(DSTrafficDetailTab tab) {
    if (_detailTab == tab) return;
    setState(() => _detailTab = tab);
  }

  @override
  Widget build(BuildContext context) {
    final body = widget.requests.isEmpty
        ? _buildEmptyWorkbench()
        : _buildListAndDetail();

    final content = Semantics(
      container: true,
      explicitChildNodes: true,
      label: widget.semanticLabel,
      child: Column(
        key: DSTrafficInspector.panelKey,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _InspectorHeader(
            title: widget.title,
            subtitle: widget.subtitle,
            count: widget.requests.length,
          ),
          const DSDivider.subtle(),
          Expanded(child: body),
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

  Widget _buildEmptyWorkbench() {
    return Center(
      key: DSTrafficInspector.emptyKey,
      child: Padding(
        padding: const EdgeInsets.all(DSSpacing.lg),
        child: DSStateSurface.empty(
          icon: Icons.route_outlined,
          title: widget.emptyTitle,
          subtitle: widget.emptySubtitle,
          compact: true,
        ),
      ),
    );
  }

  Widget _buildListAndDetail() {
    final list = _RequestListPane(
      requests: widget.requests,
      selectedId: _effectiveSelectedId,
      semanticLabel: widget.listSemanticLabel,
      onSelect: _select,
    );

    final detail = _RequestDetailPane(
      request: _selectedRequest,
      tab: _detailTab,
      showTimingTab: widget.showTimingTab,
      semanticLabel: widget.detailSemanticLabel,
      noSelectionTitle: widget.noSelectionTitle,
      noSelectionSubtitle: widget.noSelectionSubtitle,
      bodyMaxHeight: widget.bodyMaxHeight,
      onTabSelected: _setTab,
    );

    if (widget.useSplitPane) {
      return DSSplitPane(
        axis: Axis.horizontal,
        initialRatio: widget.splitInitialRatio,
        leadingMinExtent: 180,
        trailingMinExtent: 220,
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
  final int count;

  const _InspectorHeader({
    required this.title,
    required this.subtitle,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      label: '$title, $count requests',
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
                color: DSColors.accentViolet.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(DSRadii.md),
              ),
              child: const DSIcon.small(
                Icons.lan_outlined,
                color: DSColors.accentViolet,
              ),
            ),
            const SizedBox(width: DSSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DSText.labelLarge(title, color: DSColors.textPrimary),
                  if (subtitle != null && subtitle!.isNotEmpty)
                    DSText.bodySmall(
                      subtitle!,
                      color: DSColors.textTertiary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            DSBadge(label: '$count', color: DSColors.accentViolet),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// List pane
// =============================================================================

class _RequestListPane extends StatelessWidget {
  final List<DSTrafficRequest> requests;
  final String? selectedId;
  final String semanticLabel;
  final ValueChanged<DSTrafficRequest> onSelect;

  const _RequestListPane({
    required this.requests,
    required this.selectedId,
    required this.semanticLabel,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: '$semanticLabel: ${requests.length} requests',
      child: ListView.builder(
        key: DSTrafficInspector.listKey,
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final request = requests[index];
          final selected = request.id == selectedId;
          return _RequestListRow(
            request: request,
            selected: selected,
            onSelect: onSelect,
          );
        },
      ),
    );
  }
}

class _RequestListRow extends StatelessWidget {
  final DSTrafficRequest request;
  final bool selected;
  final ValueChanged<DSTrafficRequest> onSelect;

  const _RequestListRow({
    required this.request,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return DSInteractiveSurface(
      semanticLabel: request.semanticLabel,
      selected: selected,
      excludeChildSemantics: true,
      onTap: () => onSelect(request),
      child: Container(
        key: DSTrafficInspector.rowKey(request.id),
        padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.md,
          vertical: DSSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected
              ? DSColors.obsidianActive.withValues(alpha: 0.7)
              : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: selected ? DSColors.accentBlue : Colors.transparent,
              width: 2,
            ),
            bottom: const BorderSide(color: DSColors.borderSubtle, width: 1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                DSBadge(
                  label: request.method,
                  color: DSColors.accentBlue,
                  size: DSBadgeSize.small,
                ),
                const SizedBox(width: DSSpacing.sm),
                DSText.labelSmall(
                  request.isPending ? '—' : '${request.statusCode}',
                  color: request.statusColor,
                ),
                const Spacer(),
                DSText.labelSmall(
                  request.durationLabel,
                  color: DSColors.textTertiary,
                ),
              ],
            ),
            const SizedBox(height: DSSpacing.xs),
            DSText.bodySmall(
              request.url,
              color: selected ? DSColors.textPrimary : DSColors.textSecondary,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (request.provider != null) ...[
              const SizedBox(height: DSSpacing.xxs),
              DSText.labelSmall(
                request.provider!,
                color: DSColors.textTertiary,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Detail pane
// =============================================================================

class _RequestDetailPane extends StatelessWidget {
  final DSTrafficRequest? request;
  final DSTrafficDetailTab tab;
  final bool showTimingTab;
  final String semanticLabel;
  final String noSelectionTitle;
  final String noSelectionSubtitle;
  final double? bodyMaxHeight;
  final ValueChanged<DSTrafficDetailTab> onTabSelected;

  const _RequestDetailPane({
    required this.request,
    required this.tab,
    required this.showTimingTab,
    required this.semanticLabel,
    required this.noSelectionTitle,
    required this.noSelectionSubtitle,
    required this.bodyMaxHeight,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (request == null) {
      return Center(
        key: DSTrafficInspector.noSelectionKey,
        child: Padding(
          padding: const EdgeInsets.all(DSSpacing.lg),
          child: DSStateSurface.empty(
            icon: Icons.inbox_outlined,
            title: noSelectionTitle,
            subtitle: noSelectionSubtitle,
            compact: true,
          ),
        ),
      );
    }

    final r = request!;
    final effectiveTab = (!showTimingTab && tab == DSTrafficDetailTab.timing)
        ? DSTrafficDetailTab.overview
        : tab;

    return Semantics(
      container: true,
      label: semanticLabel,
      child: Column(
        key: DSTrafficInspector.detailKey,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DetailTabBar(
            active: effectiveTab,
            showTimingTab: showTimingTab,
            onTabSelected: onTabSelected,
          ),
          const DSDivider.subtle(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(DSSpacing.lg),
              child: _buildTabBody(r, effectiveTab),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBody(DSTrafficRequest r, DSTrafficDetailTab tab) {
    switch (tab) {
      case DSTrafficDetailTab.overview:
        return _OverviewFields(request: r);
      case DSTrafficDetailTab.headers:
        return _HeadersBody(request: r);
      case DSTrafficDetailTab.body:
        return _BodiesBody(request: r, maxHeight: bodyMaxHeight);
      case DSTrafficDetailTab.timing:
        return _TimingBody(request: r);
    }
  }
}

class _DetailTabBar extends StatelessWidget {
  final DSTrafficDetailTab active;
  final bool showTimingTab;
  final ValueChanged<DSTrafficDetailTab> onTabSelected;

  const _DetailTabBar({
    required this.active,
    required this.showTimingTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = <DSTrafficDetailTab>[
      DSTrafficDetailTab.overview,
      DSTrafficDetailTab.headers,
      DSTrafficDetailTab.body,
      if (showTimingTab) DSTrafficDetailTab.timing,
    ];

    return Semantics(
      container: true,
      label: 'Detail tabs',
      child: SingleChildScrollView(
        key: DSTrafficInspector.tabBarKey,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.md,
          vertical: DSSpacing.sm,
        ),
        child: Row(
          children: [
            for (final t in tabs) ...[
              _TabChip(
                tab: t,
                selected: active == t,
                onTap: () => onTabSelected(t),
              ),
              const SizedBox(width: DSSpacing.sm),
            ],
          ],
        ),
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  final DSTrafficDetailTab tab;
  final bool selected;
  final VoidCallback onTap;

  const _TabChip({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  String get _label => switch (tab) {
    DSTrafficDetailTab.overview => 'Overview',
    DSTrafficDetailTab.headers => 'Headers',
    DSTrafficDetailTab.body => 'Body',
    DSTrafficDetailTab.timing => 'Timing',
  };

  @override
  Widget build(BuildContext context) {
    return DSInteractiveSurface(
      semanticLabel: '$_label tab',
      selected: selected,
      onTap: onTap,
      child: Container(
        key: DSTrafficInspector.tabKey(tab),
        padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.md,
          vertical: DSSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected
              ? DSColors.accentBlue.withValues(alpha: 0.15)
              : DSColors.obsidianHover,
          borderRadius: BorderRadius.circular(DSRadii.md),
          border: Border.all(
            color: selected ? DSColors.accentBlue : DSColors.borderSubtle,
          ),
        ),
        child: DSText.labelSmall(
          _label,
          color: selected ? DSColors.accentBlue : DSColors.textSecondary,
        ),
      ),
    );
  }
}

class _OverviewFields extends StatelessWidget {
  final DSTrafficRequest request;

  const _OverviewFields({required this.request});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldRow(label: 'Request ID', value: request.id),
        _FieldRow(label: 'Method', value: request.method),
        _FieldRow(label: 'URL', value: request.url),
        _FieldRow(
          label: 'Status',
          value: request.isPending ? 'pending' : '${request.statusCode}',
          valueColor: request.statusColor,
        ),
        _FieldRow(label: 'Duration', value: request.durationLabel),
        if (request.provider != null)
          _FieldRow(label: 'Provider', value: request.provider!),
        if (request.timestampLabel != null)
          _FieldRow(label: 'Timestamp', value: request.timestampLabel!),
      ],
    );
  }
}

class _FieldRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _FieldRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DSSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: DSText.labelSmall(label, color: DSColors.textTertiary),
          ),
          Expanded(
            child: DSText.bodySmall(
              value,
              color: valueColor ?? DSColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeadersBody extends StatelessWidget {
  final DSTrafficRequest request;

  const _HeadersBody({required this.request});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const DSText.labelMedium(
          'Request headers',
          color: DSColors.textSecondary,
        ),
        const SizedBox(height: DSSpacing.sm),
        DSCodeBlock(
          source: request.requestHeaders.isEmpty
              ? '// no request headers'
              : request.requestHeaders,
          language: 'text',
          showLineNumbers: false,
          maxHeight: 160,
        ),
        const SizedBox(height: DSSpacing.lg),
        const DSText.labelMedium(
          'Response headers',
          color: DSColors.textSecondary,
        ),
        const SizedBox(height: DSSpacing.sm),
        DSCodeBlock(
          source: request.responseHeaders.isEmpty
              ? '// no response headers'
              : request.responseHeaders,
          language: 'text',
          showLineNumbers: false,
          maxHeight: 160,
        ),
      ],
    );
  }
}

class _BodiesBody extends StatelessWidget {
  final DSTrafficRequest request;
  final double? maxHeight;

  const _BodiesBody({required this.request, required this.maxHeight});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const DSText.labelMedium('Request body', color: DSColors.textSecondary),
        const SizedBox(height: DSSpacing.sm),
        DSCodeBlock(
          source: request.requestBody.isEmpty
              ? '// empty request body'
              : request.requestBody,
          language: 'json',
          showLineNumbers: true,
          maxHeight: maxHeight,
        ),
        const SizedBox(height: DSSpacing.lg),
        const DSText.labelMedium(
          'Response body',
          color: DSColors.textSecondary,
        ),
        const SizedBox(height: DSSpacing.sm),
        DSCodeBlock(
          source: request.responseBody.isEmpty
              ? '// empty response body'
              : request.responseBody,
          language: 'json',
          showLineNumbers: true,
          maxHeight: maxHeight,
        ),
      ],
    );
  }
}

class _TimingBody extends StatelessWidget {
  final DSTrafficRequest request;

  const _TimingBody({required this.request});

  @override
  Widget build(BuildContext context) {
    if (request.timingSpans.isEmpty) {
      return const DSStateSurface.empty(
        icon: Icons.timeline_outlined,
        title: 'No timing spans',
        subtitle: 'This fixture request has no embedded waterfall data',
        compact: true,
      );
    }

    return DSTimingWaterfall(
      title: 'Request timing',
      semanticLabel: 'Request ${request.id} timing',
      spans: request.timingSpans,
      wrapInGlass: false,
    );
  }
}

// =============================================================================
// Fixtures (gallery + tests) — mock request IDs only
// =============================================================================

/// Multi-request fixture set for gallery demos.
List<DSTrafficRequest> dsTrafficInspectorFixtureRequests() {
  final spans = dsTimingWaterfallFixtureSpans();
  return [
    DSTrafficRequest(
      id: 'req-chat-001',
      method: 'POST',
      url: '/v1/chat/completions',
      statusCode: 200,
      durationMs: 645,
      provider: 'openai / main-prod',
      timestampLabel: '12:04:18.120Z',
      requestHeaders:
          'content-type: application/json\nauthorization: Bearer sk-***\nx-request-id: req-chat-001',
      responseHeaders:
          'content-type: application/json\nx-request-id: req-chat-001\ncf-cache-status: DYNAMIC',
      requestBody:
          '{\n  "model": "gpt-4o",\n  "messages": [{"role": "user", "content": "ping"}]\n}',
      responseBody:
          '{\n  "id": "chatcmpl-fixture",\n  "choices": [{"message": {"role": "assistant", "content": "pong"}}]\n}',
      timingSpans: spans,
    ),
    const DSTrafficRequest(
      id: 'req-models-002',
      method: 'GET',
      url: '/v1/models',
      statusCode: 200,
      durationMs: 88,
      provider: 'openai / main-prod',
      timestampLabel: '12:04:19.010Z',
      requestHeaders: 'accept: application/json\nx-request-id: req-models-002',
      responseHeaders: 'content-type: application/json',
      requestBody: '',
      responseBody: '{\n  "data": [{"id": "gpt-4o"}, {"id": "gpt-4o-mini"}]\n}',
      timingSpans: [
        DSTimingSpan(id: 'm-dns', name: 'DNS', startMs: 0, durationMs: 8),
        DSTimingSpan(id: 'm-ttfb', name: 'TTFB', startMs: 8, durationMs: 60),
        DSTimingSpan(
          id: 'm-download',
          name: 'Download',
          startMs: 68,
          durationMs: 20,
        ),
      ],
    ),
    const DSTrafficRequest(
      id: 'req-embed-003',
      method: 'POST',
      url: '/v1/embeddings',
      statusCode: 429,
      durationMs: 1200,
      provider: 'openai / batch',
      timestampLabel: '12:04:20.500Z',
      requestHeaders: 'content-type: application/json',
      responseHeaders: 'content-type: application/json\nretry-after: 2',
      requestBody:
          '{\n  "model": "text-embedding-3-small",\n  "input": "fixture"\n}',
      responseBody:
          '{\n  "error": {"type": "rate_limit_error", "message": "fixture rate limit"}\n}',
      timingSpans: [
        DSTimingSpan(
          id: 'e-connect',
          name: 'Connect',
          startMs: 0,
          durationMs: 40,
        ),
        DSTimingSpan(
          id: 'e-wait',
          name: 'Queue wait',
          startMs: 40,
          durationMs: 1100,
        ),
        DSTimingSpan(
          id: 'e-resp',
          name: 'Response',
          startMs: 1140,
          durationMs: 60,
        ),
      ],
    ),
    const DSTrafficRequest(
      id: 'req-health-004',
      method: 'GET',
      url: '/healthz',
      statusCode: 500,
      durationMs: 42,
      provider: 'local-mock',
      timestampLabel: '12:04:21.000Z',
      requestHeaders: 'accept: text/plain',
      responseHeaders: 'content-type: application/json',
      responseBody: '{\n  "status": "error",\n  "detail": "fixture boom"\n}',
    ),
  ];
}

/// Compact two-request fixture for widget tests.
List<DSTrafficRequest> dsTrafficInspectorMinimalFixture() {
  return const [
    DSTrafficRequest(
      id: 'req-a',
      method: 'GET',
      url: '/v1/ping',
      statusCode: 200,
      durationMs: 50,
      provider: 'fixture-a',
      requestHeaders: 'accept: application/json',
      responseHeaders: 'content-type: application/json',
      responseBody: '{"ok":true}',
      timingSpans: [
        DSTimingSpan(id: 'a-dns', name: 'DNS', startMs: 0, durationMs: 10),
        DSTimingSpan(id: 'a-ttfb', name: 'TTFB', startMs: 10, durationMs: 40),
      ],
    ),
    DSTrafficRequest(
      id: 'req-b',
      method: 'POST',
      url: '/v1/echo',
      statusCode: 400,
      durationMs: 120,
      provider: 'fixture-b',
      requestHeaders: 'content-type: application/json',
      responseHeaders: 'content-type: application/json',
      requestBody: '{"msg":"hi"}',
      responseBody: '{"error":"bad request"}',
    ),
  ];
}
