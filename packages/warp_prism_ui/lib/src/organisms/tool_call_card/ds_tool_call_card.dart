import 'package:flutter/material.dart';

import '../../atoms/atoms.dart';
import '../../tokens/tokens.dart';
import '../code_block/ds_code_block.dart';

/// Lifecycle state of a fixture tool invocation card.
///
/// Display-only — does **not** execute tools or call MCP.
enum DSToolCallStatus {
  /// Invocation queued / not started.
  pending,

  /// Invocation in progress (fixture stream simulation only).
  running,

  /// Completed with a result body.
  success,

  /// Completed with an error body.
  error,
}

/// Immutable model for a single tool-call card (DeepChat-style tool block).
///
/// Contract:
/// - [id] stable within a host list / transcript.
/// - [toolName] required display name (function / tool id).
/// - [argsSummary] short one-line preview in the header (may be null).
/// - [argsBody] full args payload shown when expanded (JSON / text).
/// - [resultBody] success payload when [status] is [DSToolCallStatus.success].
/// - [errorBody] error payload when [status] is [DSToolCallStatus.error].
/// - No network, no tool execution in this package.
@immutable
class DSToolCallData {
  /// Stable unique id within a host list / transcript.
  final String id;

  /// Tool / function display name.
  final String toolName;

  /// Short one-line args preview for the collapsed header.
  final String? argsSummary;

  /// Full args payload (shown when expanded).
  final String? argsBody;

  /// Result payload for successful invocations.
  final String? resultBody;

  /// Error payload for failed invocations.
  final String? errorBody;

  /// Current lifecycle status.
  final DSToolCallStatus status;

  /// Optional duration label source (fixture timing).
  final Duration? duration;

  /// Optional language hint for args body monospace rendering.
  final String? argsLanguage;

  /// Optional language hint for result body monospace rendering.
  final String? resultLanguage;

  const DSToolCallData({
    required this.id,
    required this.toolName,
    this.argsSummary,
    this.argsBody,
    this.resultBody,
    this.errorBody,
    this.status = DSToolCallStatus.pending,
    this.duration,
    this.argsLanguage,
    this.resultLanguage,
  });

  /// Whether expanded chrome has any body content to show.
  bool get hasExpandableBody =>
      (argsBody != null && argsBody!.isNotEmpty) ||
      (resultBody != null && resultBody!.isNotEmpty) ||
      (errorBody != null && errorBody!.isNotEmpty);

  /// Human-readable status label.
  String get statusLabel => switch (status) {
    DSToolCallStatus.pending => 'Pending',
    DSToolCallStatus.running => 'Running',
    DSToolCallStatus.success => 'Success',
    DSToolCallStatus.error => 'Error',
  };

  /// Canonical status color for badge / border accents.
  Color get statusColor => switch (status) {
    DSToolCallStatus.pending => DSColors.statusPending,
    DSToolCallStatus.running => DSColors.statusRunning,
    DSToolCallStatus.success => DSColors.statusSuccess,
    DSToolCallStatus.error => DSColors.statusError,
  };

  /// Formatted duration for header meta (null when unset).
  String? get durationLabel {
    final d = duration;
    if (d == null) return null;
    if (d.inMilliseconds < 1000) return '${d.inMilliseconds}ms';
    final seconds = d.inMilliseconds / 1000.0;
    return '${seconds.toStringAsFixed(seconds >= 10 ? 0 : 1)}s';
  }

  DSToolCallData copyWith({
    String? id,
    String? toolName,
    String? argsSummary,
    String? argsBody,
    String? resultBody,
    String? errorBody,
    DSToolCallStatus? status,
    Duration? duration,
    String? argsLanguage,
    String? resultLanguage,
    bool clearArgsSummary = false,
    bool clearArgsBody = false,
    bool clearResultBody = false,
    bool clearErrorBody = false,
    bool clearDuration = false,
    bool clearArgsLanguage = false,
    bool clearResultLanguage = false,
  }) {
    return DSToolCallData(
      id: id ?? this.id,
      toolName: toolName ?? this.toolName,
      argsSummary: clearArgsSummary ? null : (argsSummary ?? this.argsSummary),
      argsBody: clearArgsBody ? null : (argsBody ?? this.argsBody),
      resultBody: clearResultBody ? null : (resultBody ?? this.resultBody),
      errorBody: clearErrorBody ? null : (errorBody ?? this.errorBody),
      status: status ?? this.status,
      duration: clearDuration ? null : (duration ?? this.duration),
      argsLanguage: clearArgsLanguage
          ? null
          : (argsLanguage ?? this.argsLanguage),
      resultLanguage: clearResultLanguage
          ? null
          : (resultLanguage ?? this.resultLanguage),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DSToolCallData &&
        other.id == id &&
        other.toolName == toolName &&
        other.argsSummary == argsSummary &&
        other.argsBody == argsBody &&
        other.resultBody == resultBody &&
        other.errorBody == errorBody &&
        other.status == status &&
        other.duration == duration &&
        other.argsLanguage == argsLanguage &&
        other.resultLanguage == resultLanguage;
  }

  @override
  int get hashCode => Object.hash(
    id,
    toolName,
    argsSummary,
    argsBody,
    resultBody,
    errorBody,
    status,
    duration,
    argsLanguage,
    resultLanguage,
  );
}

/// ASW Observatory Organism — Tool Call Card
///
/// Glass-panel card for a single agent **tool invocation** (DeepChat-style
/// tool block): tool name, args summary, expandable args/result/error body.
///
/// ## Boundary (false-gap guard)
///
/// | This organism | Not this organism |
/// | --- | --- |
/// | Fixture tool-call chrome (name/args/result) | Live MCP / tool execution |
/// | Expandable card for transcript embedding | Full TraceDialog / subagent tree |
/// | Display-only status ring | [DSLogViewer] severity stream |
///
/// ## Contract
///
/// - Controlled expand via [expanded] + [onExpandedChanged], or uncontrolled
///   with [initiallyExpanded] when [expanded] is null.
/// - Expand control is always labeled for accessibility.
/// - No network, no tool execution, no mutation controls.
class DSToolCallCard extends StatefulWidget {
  /// Tool invocation model.
  final DSToolCallData data;

  /// Controlled expanded state. When null, the card manages its own state
  /// seeded by [initiallyExpanded].
  final bool? expanded;

  /// Seed for uncontrolled mode.
  final bool initiallyExpanded;

  /// Called when the user toggles expand/collapse.
  final ValueChanged<bool>? onExpandedChanged;

  /// Semantic label override for the card region.
  final String? semanticLabel;

  /// When true, use [DSCodeBlock] for expanded bodies; otherwise monospace text.
  final bool useCodeBlock;

  const DSToolCallCard({
    super.key,
    required this.data,
    this.expanded,
    this.initiallyExpanded = false,
    this.onExpandedChanged,
    this.semanticLabel,
    this.useCodeBlock = false,
  });

  @override
  State<DSToolCallCard> createState() => _DSToolCallCardState();
}

class _DSToolCallCardState extends State<DSToolCallCard> {
  late bool _uncontrolledExpanded;

  @override
  void initState() {
    super.initState();
    _uncontrolledExpanded = widget.initiallyExpanded;
  }

  @override
  void didUpdateWidget(covariant DSToolCallCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.expanded == null &&
        oldWidget.initiallyExpanded != widget.initiallyExpanded &&
        oldWidget.expanded != null) {
      // Host switched from controlled → uncontrolled; reseed.
      _uncontrolledExpanded = widget.initiallyExpanded;
    }
  }

  bool get _isExpanded => widget.expanded ?? _uncontrolledExpanded;

  void _toggle() {
    final next = !_isExpanded;
    if (widget.expanded == null) {
      setState(() => _uncontrolledExpanded = next);
    }
    widget.onExpandedChanged?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final expanded = _isExpanded;
    final canExpand = data.hasExpandableBody;
    final regionLabel =
        widget.semanticLabel ??
        'Tool call ${data.toolName}, ${data.statusLabel}';

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: regionLabel,
      child: DSGlassPanelSimple(
        key: Key('tool-call-card-${data.id}'),
        backgroundColor: DSColors.obsidianElevated.withValues(alpha: 0.92),
        borderColor: data.statusColor.withValues(alpha: 0.45),
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            _ToolCallHeader(
              data: data,
              expanded: expanded,
              canExpand: canExpand,
              onToggle: canExpand ? _toggle : null,
            ),
            if (expanded && canExpand)
              _ToolCallBody(data: data, useCodeBlock: widget.useCodeBlock),
          ],
        ),
      ),
    );
  }
}

class _ToolCallHeader extends StatelessWidget {
  final DSToolCallData data;
  final bool expanded;
  final bool canExpand;
  final VoidCallback? onToggle;

  const _ToolCallHeader({
    required this.data,
    required this.expanded,
    required this.canExpand,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final expandLabel = expanded
        ? 'Collapse tool call ${data.toolName}'
        : 'Expand tool call ${data.toolName}';

    final header = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: kMinInteractiveDimension),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.md,
          vertical: DSSpacing.sm,
        ),
        child: Row(
          children: [
            // Expand chevron (visual); whole row is the control when expandable.
            Icon(
              expanded ? Icons.expand_more : Icons.chevron_right,
              size: 18,
              color: canExpand ? DSColors.textSecondary : DSColors.textDisabled,
            ),
            const SizedBox(width: DSSpacing.xs),
            Icon(Icons.build_outlined, size: 16, color: data.statusColor),
            const SizedBox(width: DSSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  DSText.labelMedium(
                    data.toolName,
                    color: DSColors.textPrimary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (data.argsSummary != null &&
                      data.argsSummary!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    DSText.labelSmall(
                      data.argsSummary!,
                      color: DSColors.textTertiary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: DSSpacing.sm),
            if (data.durationLabel != null) ...[
              DSText.labelSmall(
                data.durationLabel!,
                color: DSColors.textTertiary,
              ),
              const SizedBox(width: DSSpacing.sm),
            ],
            DSBadge(
              label: data.statusLabel,
              color: data.statusColor,
              size: DSBadgeSize.small,
              semanticLabel: 'Status ${data.statusLabel}',
            ),
          ],
        ),
      ),
    );

    if (!canExpand) {
      return header;
    }

    return Semantics(
      button: true,
      expanded: expanded,
      label: expandLabel,
      excludeSemantics: true,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(onTap: onToggle, child: header),
      ),
    );
  }
}

class _ToolCallBody extends StatelessWidget {
  final DSToolCallData data;
  final bool useCodeBlock;

  const _ToolCallBody({required this.data, required this.useCodeBlock});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: DSColors.borderSubtle, width: 1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DSSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (data.argsBody != null && data.argsBody!.isNotEmpty) ...[
              _BodySection(
                title: 'Arguments',
                body: data.argsBody!,
                accent: DSColors.accentCyan,
                useCodeBlock: useCodeBlock,
                language: data.argsLanguage ?? 'json',
              ),
            ],
            if (data.resultBody != null && data.resultBody!.isNotEmpty) ...[
              if (data.argsBody != null && data.argsBody!.isNotEmpty)
                const SizedBox(height: DSSpacing.md),
              _BodySection(
                title: 'Result',
                body: data.resultBody!,
                accent: DSColors.statusSuccess,
                useCodeBlock: useCodeBlock,
                language: data.resultLanguage ?? 'json',
              ),
            ],
            if (data.errorBody != null && data.errorBody!.isNotEmpty) ...[
              if ((data.argsBody != null && data.argsBody!.isNotEmpty) ||
                  (data.resultBody != null && data.resultBody!.isNotEmpty))
                const SizedBox(height: DSSpacing.md),
              _BodySection(
                title: 'Error',
                body: data.errorBody!,
                accent: DSColors.statusError,
                useCodeBlock: useCodeBlock,
                language: 'text',
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BodySection extends StatelessWidget {
  final String title;
  final String body;
  final Color accent;
  final bool useCodeBlock;
  final String language;

  const _BodySection({
    required this.title,
    required this.body,
    required this.accent,
    required this.useCodeBlock,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        DSText.labelSmall(title, color: accent),
        const SizedBox(height: DSSpacing.xs),
        if (useCodeBlock)
          DSCodeBlock(
            source: body,
            language: language,
            showLineNumbers: false,
            showCopyButton: false,
            maxHeight: 200,
          )
        else
          DecoratedBox(
            decoration: BoxDecoration(
              color: DSColors.obsidianDeep.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(DSRadii.md),
              border: Border.all(color: accent.withValues(alpha: 0.25)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(DSSpacing.sm),
              child: DSText.code(body, color: DSColors.textSecondary),
            ),
          ),
      ],
    );
  }
}

// =============================================================================
// Fixtures (gallery / tests) — no network
// =============================================================================

/// Shared success tool-call fixture for gallery + tests.
DSToolCallData dsToolCallSuccessFixture({String id = 'tool-health-1'}) {
  return DSToolCallData(
    id: id,
    toolName: 'provider.health_check',
    argsSummary: 'provider=openai account=main-prod',
    argsBody: '{\n  "provider": "openai",\n  "account": "main-prod"\n}',
    resultBody:
        '{\n  "status": "healthy",\n  "latency_p95_ms": 182,\n  "error_rate": 0.001\n}',
    status: DSToolCallStatus.success,
    duration: const Duration(milliseconds: 420),
    argsLanguage: 'json',
    resultLanguage: 'json',
  );
}

/// Shared error tool-call fixture for gallery + tests.
DSToolCallData dsToolCallErrorFixture({String id = 'tool-mcp-err'}) {
  return DSToolCallData(
    id: id,
    toolName: 'mcp.list_tools',
    argsSummary: 'server=filesystem',
    argsBody: '{\n  "server": "filesystem"\n}',
    errorBody: 'MCP server unreachable: connection refused (fixture)',
    status: DSToolCallStatus.error,
    duration: const Duration(milliseconds: 86),
  );
}

/// Shared running tool-call fixture (collapsed by default, no result yet).
DSToolCallData dsToolCallRunningFixture({String id = 'tool-search-run'}) {
  return DSToolCallData(
    id: id,
    toolName: 'workspace.search',
    argsSummary: 'query="provider health"',
    argsBody: '{\n  "query": "provider health",\n  "limit": 10\n}',
    status: DSToolCallStatus.running,
  );
}

/// Compact fixture list for multi-card demos.
List<DSToolCallData> dsToolCallFixtureCatalog() {
  return [
    dsToolCallSuccessFixture(),
    dsToolCallRunningFixture(),
    dsToolCallErrorFixture(),
    const DSToolCallData(
      id: 'tool-pending',
      toolName: 'artifact.export',
      argsSummary: 'format=md',
      status: DSToolCallStatus.pending,
    ),
  ];
}
