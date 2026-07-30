import 'package:flutter/material.dart';

import '../../atoms/atoms.dart';
import '../../molecules/ds_interactive_surface.dart';
import '../../molecules/ds_state_surface.dart';
import '../../tokens/tokens.dart';
import '../code_block/ds_code_block.dart';
import '../split_pane/ds_split_pane.dart';

// =============================================================================
// Models
// =============================================================================

/// Severity / stream class for a single [DSExecutionLine].
///
/// Distinct from [DSLogSeverity] (observatory event stream) — these levels
/// model **workflow execution** console channels (stdout/stderr + ops markers).
enum DSExecutionLineLevel {
  /// Process stdout fixture.
  stdout,

  /// Process stderr fixture.
  stderr,

  /// Informational console marker (step start, etc.).
  info,

  /// Non-fatal warning during a run.
  warning,

  /// Failure / exception fixture line.
  error,

  /// System / orchestrator chrome (run boundaries).
  system,
}

/// UI metadata for [DSExecutionLineLevel].
extension DSExecutionLineLevelUI on DSExecutionLineLevel {
  /// Accent color for the line gutter.
  Color get color {
    switch (this) {
      case DSExecutionLineLevel.stdout:
        return DSColors.textSecondary;
      case DSExecutionLineLevel.stderr:
        return DSColors.statusError;
      case DSExecutionLineLevel.info:
        return DSColors.statusInfo;
      case DSExecutionLineLevel.warning:
        return DSColors.statusWarning;
      case DSExecutionLineLevel.error:
        return DSColors.statusError;
      case DSExecutionLineLevel.system:
        return DSColors.accentCyan;
    }
  }

  /// Short uppercase channel label.
  String get label {
    switch (this) {
      case DSExecutionLineLevel.stdout:
        return 'OUT';
      case DSExecutionLineLevel.stderr:
        return 'ERR';
      case DSExecutionLineLevel.info:
        return 'INFO';
      case DSExecutionLineLevel.warning:
        return 'WARN';
      case DSExecutionLineLevel.error:
        return 'ERROR';
      case DSExecutionLineLevel.system:
        return 'SYS';
    }
  }
}

/// Lifecycle status for a fixture execution run group.
enum DSExecutionRunStatus {
  /// Queued / not started.
  pending,

  /// Currently streaming fixture lines.
  running,

  /// Completed successfully.
  success,

  /// Completed with failure.
  failed,
}

/// UI metadata for [DSExecutionRunStatus].
extension DSExecutionRunStatusUI on DSExecutionRunStatus {
  Color get color {
    switch (this) {
      case DSExecutionRunStatus.pending:
        return DSColors.textTertiary;
      case DSExecutionRunStatus.running:
        return DSColors.statusRunning;
      case DSExecutionRunStatus.success:
        return DSColors.statusSuccess;
      case DSExecutionRunStatus.failed:
        return DSColors.statusError;
    }
  }

  String get label {
    switch (this) {
      case DSExecutionRunStatus.pending:
        return 'pending';
      case DSExecutionRunStatus.running:
        return 'running';
      case DSExecutionRunStatus.success:
        return 'success';
      case DSExecutionRunStatus.failed:
        return 'failed';
    }
  }
}

/// Immutable fixture line for [DSExecutionConsole].
///
/// **No shell / PTY payload** — [message] is display text only.
@immutable
class DSExecutionLine {
  /// Stable unique id within a console session.
  final String id;

  /// Display message (fixture text — not executed).
  final String message;

  /// Stream / severity channel.
  final DSExecutionLineLevel level;

  /// Optional run group this line belongs to.
  final String? runGroupId;

  /// Optional source label (step name, agent id).
  final String? source;

  /// Optional wall-clock label (HH:mm:ss style fixture string).
  final String? timestampLabel;

  const DSExecutionLine({
    required this.id,
    required this.message,
    this.level = DSExecutionLineLevel.stdout,
    this.runGroupId,
    this.source,
    this.timestampLabel,
  });

  /// Semantic label for a11y.
  String get semanticLabel {
    final src = source != null ? ' $source' : '';
    return '${level.label}$src: $message';
  }

  DSExecutionLine copyWith({
    String? id,
    String? message,
    DSExecutionLineLevel? level,
    String? runGroupId,
    String? source,
    String? timestampLabel,
    bool clearRunGroupId = false,
    bool clearSource = false,
    bool clearTimestamp = false,
  }) {
    return DSExecutionLine(
      id: id ?? this.id,
      message: message ?? this.message,
      level: level ?? this.level,
      runGroupId: clearRunGroupId ? null : (runGroupId ?? this.runGroupId),
      source: clearSource ? null : (source ?? this.source),
      timestampLabel: clearTimestamp
          ? null
          : (timestampLabel ?? this.timestampLabel),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DSExecutionLine &&
        other.id == id &&
        other.message == message &&
        other.level == level &&
        other.runGroupId == runGroupId &&
        other.source == source &&
        other.timestampLabel == timestampLabel;
  }

  @override
  int get hashCode =>
      Object.hash(id, message, level, runGroupId, source, timestampLabel);
}

/// Optional run group metadata for sticky section headers + structured output.
@immutable
class DSExecutionRunGroup {
  /// Stable group id referenced by [DSExecutionLine.runGroupId].
  final String id;

  /// Header label (e.g. "Run #12 · ingest-pipeline").
  final String label;

  /// Lifecycle status for the run.
  final DSExecutionRunStatus status;

  /// Optional structured output fixture (JSON / text) for the output panel.
  final String? structuredOutput;

  /// Optional language hint for [DSCodeBlock] (json, text, yaml, …).
  final String? outputLanguage;

  /// Optional subtitle / step summary under the header.
  final String? subtitle;

  const DSExecutionRunGroup({
    required this.id,
    required this.label,
    this.status = DSExecutionRunStatus.pending,
    this.structuredOutput,
    this.outputLanguage,
    this.subtitle,
  });

  DSExecutionRunGroup copyWith({
    String? id,
    String? label,
    DSExecutionRunStatus? status,
    String? structuredOutput,
    String? outputLanguage,
    String? subtitle,
    bool clearStructuredOutput = false,
    bool clearOutputLanguage = false,
    bool clearSubtitle = false,
  }) {
    return DSExecutionRunGroup(
      id: id ?? this.id,
      label: label ?? this.label,
      status: status ?? this.status,
      structuredOutput: clearStructuredOutput
          ? null
          : (structuredOutput ?? this.structuredOutput),
      outputLanguage: clearOutputLanguage
          ? null
          : (outputLanguage ?? this.outputLanguage),
      subtitle: clearSubtitle ? null : (subtitle ?? this.subtitle),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DSExecutionRunGroup &&
        other.id == id &&
        other.label == label &&
        other.status == status &&
        other.structuredOutput == structuredOutput &&
        other.outputLanguage == outputLanguage &&
        other.subtitle == subtitle;
  }

  @override
  int get hashCode => Object.hash(
    id,
    label,
    status,
    structuredOutput,
    outputLanguage,
    subtitle,
  );
}

// =============================================================================
// Controller — append-only fixture stream
// =============================================================================

/// Imperative handle for [DSExecutionConsole] fixture line streaming.
///
/// Simulates an append-only execution stream via [appendLine] / [appendLines].
/// **Does not execute shell commands, open PTYs, or run workflows.**
class DSExecutionConsoleController extends ChangeNotifier {
  List<DSExecutionLine> _lines;
  List<DSExecutionRunGroup> _runGroups;
  String? _selectedRunGroupId;
  String? _structuredOutputOverride;

  DSExecutionConsoleController({
    List<DSExecutionLine>? initialLines,
    List<DSExecutionRunGroup>? runGroups,
    this._selectedRunGroupId,
    this._structuredOutputOverride,
  }) : _lines = List<DSExecutionLine>.of(
         initialLines ?? const <DSExecutionLine>[],
       ),
       _runGroups = List<DSExecutionRunGroup>.of(
         runGroups ?? const <DSExecutionRunGroup>[],
       );

  /// Ordered console lines (oldest → newest recommended).
  List<DSExecutionLine> get lines => List.unmodifiable(_lines);

  /// Known run groups for headers + structured output.
  List<DSExecutionRunGroup> get runGroups => List.unmodifiable(_runGroups);

  /// Selected run group id (drives structured output panel).
  String? get selectedRunGroupId => _selectedRunGroupId;

  /// Host override for structured output (wins over group fixture).
  String? get structuredOutputOverride => _structuredOutputOverride;

  /// Whether the line buffer is empty.
  bool get isEmpty => _lines.isEmpty;

  /// Line count.
  int get lineCount => _lines.length;

  /// Resolve structured output for the selected (or first) run group.
  String? get effectiveStructuredOutput {
    if (_structuredOutputOverride != null) {
      return _structuredOutputOverride;
    }
    final group = _selectedGroup;
    return group?.structuredOutput;
  }

  /// Language hint for the effective structured output.
  String? get effectiveOutputLanguage {
    final group = _selectedGroup;
    return group?.outputLanguage ?? 'json';
  }

  DSExecutionRunGroup? get _selectedGroup {
    final id = _selectedRunGroupId;
    if (id != null) {
      for (final g in _runGroups) {
        if (g.id == id) return g;
      }
    }
    if (_runGroups.isNotEmpty) return _runGroups.first;
    return null;
  }

  /// Replace the full line buffer.
  void setLines(List<DSExecutionLine> lines) {
    _lines = List<DSExecutionLine>.of(lines);
    notifyListeners();
  }

  /// Replace run group metadata.
  void setRunGroups(List<DSExecutionRunGroup> groups) {
    _runGroups = List<DSExecutionRunGroup>.of(groups);
    if (_selectedRunGroupId != null &&
        !_runGroups.any((g) => g.id == _selectedRunGroupId)) {
      _selectedRunGroupId = _runGroups.isEmpty ? null : _runGroups.first.id;
    }
    notifyListeners();
  }

  /// Append a single fixture line (stream simulation).
  void appendLine(DSExecutionLine line) {
    _lines = [..._lines, line];
    notifyListeners();
  }

  /// Append multiple fixture lines.
  void appendLines(Iterable<DSExecutionLine> lines) {
    final batch = lines.toList(growable: false);
    if (batch.isEmpty) return;
    _lines = [..._lines, ...batch];
    notifyListeners();
  }

  /// Clear all lines (does not clear run groups).
  void clearLines() {
    if (_lines.isEmpty) return;
    _lines = <DSExecutionLine>[];
    notifyListeners();
  }

  /// Clear lines + groups + selection.
  void clear() {
    _lines = <DSExecutionLine>[];
    _runGroups = <DSExecutionRunGroup>[];
    _selectedRunGroupId = null;
    _structuredOutputOverride = null;
    notifyListeners();
  }

  /// Select a run group (updates structured output panel source).
  void selectRunGroup(String? id) {
    if (_selectedRunGroupId == id) return;
    _selectedRunGroupId = id;
    notifyListeners();
  }

  /// Host-provided structured output fixture (wins over group field).
  void setStructuredOutputOverride(String? output) {
    if (_structuredOutputOverride == output) return;
    _structuredOutputOverride = output;
    notifyListeners();
  }
}

// =============================================================================
// Organism
// =============================================================================

/// ASW Observatory Organism — Execution Console (EPIC-16 C-12)
///
/// Streamed / fixture execution log console with optional **run grouping** and
/// a structured **output panel** slot (Sim Studio execution terminal pattern).
///
/// ## Boundary (false-gap guard)
///
/// | This organism | Not this organism |
/// | --- | --- |
/// | Run-grouped execution log + output slot | EPIC-15 `PrismTerminalWorkspace` multi-module terminal shell |
/// | Fixture stream via controller append | EPIC-15 `PrismAgentShellPanel` session transcript |
/// | Workflow step / stdout console chrome | [DSLogViewer] severity-filtered observatory event stream |
/// | Fixture text only | PTY / xterm.js / real shell or workflow execution |
///
/// ## Contract
///
/// - Prefer [controller] for append-only “stream” simulation; or pass static
///   [lines] / [runGroups] for pure display.
/// - [outputPanel] is a host slot; when null and structured output is available,
///   a default [DSCodeBlock] is shown.
/// - Parent must provide a **bounded height**.
/// - **MUST NOT** accept shell commands or execute workflows.
class DSExecutionConsole extends StatefulWidget {
  /// Optional external controller for append-stream demos/tests.
  final DSExecutionConsoleController? controller;

  /// Static lines when no [controller] is provided.
  final List<DSExecutionLine> lines;

  /// Optional run groups for sticky section headers + structured output.
  final List<DSExecutionRunGroup> runGroups;

  /// Controlled selected run group id.
  final String? selectedRunGroupId;

  /// Seed selection for uncontrolled mode.
  final String? initialSelectedRunGroupId;

  /// Fired when the user selects a run group header.
  final ValueChanged<String?>? onRunGroupSelected;

  /// Optional host-built structured output panel (wins over default code block).
  final Widget? outputPanel;

  /// When true, show the trailing structured-output pane.
  final bool showOutputPanel;

  /// Use [DSSplitPane] for logs | output when [showOutputPanel] is true.
  final bool useSplitPane;

  /// Split ratio for the log pane (0–1).
  final double splitInitialRatio;

  /// Auto-scroll to the latest line when the buffer grows.
  final bool autoScroll;

  /// Panel title.
  final String title;

  /// Optional subtitle.
  final String? subtitle;

  /// Region semantic label.
  final String semanticLabel;

  /// Log region semantic label.
  final String logSemanticLabel;

  /// Output region semantic label.
  final String outputSemanticLabel;

  /// Empty-state title.
  final String emptyTitle;

  /// Empty-state subtitle.
  final String emptySubtitle;

  /// Wrap panel in glass chrome.
  final bool wrapInGlass;

  /// Max height for default structured-output code block.
  final double? outputMaxHeight;

  /// Host override for structured output (display only).
  final String? structuredOutputOverride;

  const DSExecutionConsole({
    super.key,
    this.controller,
    this.lines = const [],
    this.runGroups = const [],
    this.selectedRunGroupId,
    this.initialSelectedRunGroupId,
    this.onRunGroupSelected,
    this.outputPanel,
    this.showOutputPanel = true,
    this.useSplitPane = true,
    this.splitInitialRatio = 0.62,
    this.autoScroll = true,
    this.title = 'Execution',
    this.subtitle,
    this.semanticLabel = 'Execution console',
    this.logSemanticLabel = 'Execution log',
    this.outputSemanticLabel = 'Structured output',
    this.emptyTitle = 'No execution lines',
    this.emptySubtitle = 'Fixture stream lines will appear here',
    this.wrapInGlass = true,
    this.outputMaxHeight = 320,
    this.structuredOutputOverride,
  });

  static const Key panelKey = Key('ds-execution-console');
  static const Key logKey = Key('ds-execution-console-log');
  static const Key outputKey = Key('ds-execution-console-output');
  static const Key emptyKey = Key('ds-execution-console-empty');
  static const Key lineListKey = Key('ds-execution-console-line-list');

  static Key lineKey(String lineId) => Key('ds-execution-console-line-$lineId');

  static Key groupHeaderKey(String groupId) =>
      Key('ds-execution-console-group-$groupId');

  @override
  State<DSExecutionConsole> createState() => _DSExecutionConsoleState();
}

class _DSExecutionConsoleState extends State<DSExecutionConsole> {
  DSExecutionConsoleController? _ownedController;
  late final ScrollController _scrollController;
  String? _uncontrolledSelectedId;
  bool _autoScroll = true;
  bool _userScrolledUp = false;
  bool _programmaticScroll = false;

  DSExecutionConsoleController get _active {
    return widget.controller ?? _ownedController!;
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    _autoScroll = widget.autoScroll;
    if (widget.controller == null) {
      _ownedController = DSExecutionConsoleController(
        initialLines: widget.lines,
        runGroups: widget.runGroups,
        selectedRunGroupId: widget.initialSelectedRunGroupId,
        structuredOutputOverride: widget.structuredOutputOverride,
      );
    }
    _uncontrolledSelectedId = _resolveInitialSelection();
    _active.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(DSExecutionConsole oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onControllerChanged);
      _ownedController?.removeListener(_onControllerChanged);

      if (widget.controller == null) {
        _ownedController ??= DSExecutionConsoleController(
          initialLines: widget.lines,
          runGroups: widget.runGroups,
          selectedRunGroupId: widget.initialSelectedRunGroupId,
          structuredOutputOverride: widget.structuredOutputOverride,
        );
      } else {
        _ownedController?.dispose();
        _ownedController = null;
      }
      _active.addListener(_onControllerChanged);
    } else if (widget.controller == null) {
      // Sync static props into owned controller when not using external handle.
      if (widget.lines != oldWidget.lines) {
        _ownedController!.setLines(widget.lines);
      }
      if (widget.runGroups != oldWidget.runGroups) {
        _ownedController!.setRunGroups(widget.runGroups);
      }
      if (widget.structuredOutputOverride !=
          oldWidget.structuredOutputOverride) {
        _ownedController!.setStructuredOutputOverride(
          widget.structuredOutputOverride,
        );
      }
    }

    if (widget.selectedRunGroupId == null) {
      final ids = _effectiveRunGroups.map((g) => g.id).toSet();
      if (_uncontrolledSelectedId != null &&
          !ids.contains(_uncontrolledSelectedId)) {
        _uncontrolledSelectedId = _resolveInitialSelection();
      }
    }

    if (widget.autoScroll != oldWidget.autoScroll && widget.autoScroll) {
      _autoScroll = true;
      _userScrolledUp = false;
    }
  }

  @override
  void dispose() {
    _active.removeListener(_onControllerChanged);
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _ownedController?.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (!mounted) return;
    setState(() {});
    if (_autoScroll) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _scrollToBottom();
      });
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _programmaticScroll) return;
    final position = _scrollController.position;
    if (position.pixels < position.maxScrollExtent - 20) {
      if (!_userScrolledUp && _autoScroll) {
        setState(() {
          _userScrolledUp = true;
          _autoScroll = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _programmaticScroll = true;
    _scrollController
        .animateTo(
          _scrollController.position.maxScrollExtent,
          duration: DSMotion.normal,
          curve: DSMotion.enter,
        )
        .whenComplete(() {
          _programmaticScroll = false;
        });
  }

  void _resumeAutoScroll() {
    setState(() {
      _autoScroll = true;
      _userScrolledUp = false;
    });
    _scrollToBottom();
  }

  List<DSExecutionLine> get _effectiveLines =>
      widget.controller != null ? _active.lines : _active.lines;

  List<DSExecutionRunGroup> get _effectiveRunGroups => _active.runGroups;

  String? _resolveInitialSelection() {
    final groups = widget.controller != null
        ? widget.controller!.runGroups
        : widget.runGroups;
    if (groups.isEmpty) return widget.initialSelectedRunGroupId;
    final seed =
        widget.initialSelectedRunGroupId ??
        widget.controller?.selectedRunGroupId;
    if (seed != null && groups.any((g) => g.id == seed)) return seed;
    return groups.first.id;
  }

  String? get _effectiveSelectedId =>
      widget.selectedRunGroupId ??
      widget.controller?.selectedRunGroupId ??
      _uncontrolledSelectedId;

  void _selectGroup(String groupId) {
    if (widget.selectedRunGroupId == null && widget.controller == null) {
      setState(() => _uncontrolledSelectedId = groupId);
    }
    widget.controller?.selectRunGroup(groupId);
    widget.onRunGroupSelected?.call(groupId);
  }

  DSExecutionRunGroup? get _selectedGroup {
    final id = _effectiveSelectedId;
    if (id == null) return null;
    for (final g in _effectiveRunGroups) {
      if (g.id == id) return g;
    }
    return null;
  }

  String? get _effectiveStructuredOutput {
    if (widget.structuredOutputOverride != null) {
      return widget.structuredOutputOverride;
    }
    if (widget.controller != null) {
      return widget.controller!.effectiveStructuredOutput;
    }
    return _selectedGroup?.structuredOutput ??
        _ownedController?.effectiveStructuredOutput;
  }

  String? get _effectiveOutputLanguage {
    return _selectedGroup?.outputLanguage ??
        widget.controller?.effectiveOutputLanguage ??
        'json';
  }

  @override
  Widget build(BuildContext context) {
    final lines = _effectiveLines;
    final content = Column(
      key: DSExecutionConsole.panelKey,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ConsoleHeader(
          title: widget.title,
          subtitle: widget.subtitle,
          lineCount: lines.length,
          showResumeScroll: _userScrolledUp,
          onResumeScroll: _resumeAutoScroll,
        ),
        const DSDivider.subtle(),
        Expanded(child: _buildBody(lines)),
      ],
    );

    final Widget inner;
    if (!widget.wrapInGlass) {
      inner = ColoredBox(color: DSColors.obsidianBase, child: content);
    } else {
      inner = DSGlassPanelSimple(
        backgroundColor: DSColors.obsidianBase.withValues(alpha: 0.95),
        borderColor: DSColors.borderSubtle,
        padding: EdgeInsets.zero,
        child: content,
      );
    }

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: widget.semanticLabel,
      child: inner,
    );
  }

  Widget _buildBody(List<DSExecutionLine> lines) {
    final logPane = _buildLogPane(lines);

    if (!widget.showOutputPanel) {
      return logPane;
    }

    final outputPane = _buildOutputPane();

    if (widget.useSplitPane) {
      return DSSplitPane(
        axis: Axis.horizontal,
        initialRatio: widget.splitInitialRatio,
        leadingMinExtent: 200,
        trailingMinExtent: 160,
        leading: logPane,
        trailing: outputPane,
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(flex: 3, child: logPane),
        const DSDivider.subtle(vertical: true),
        Expanded(flex: 2, child: outputPane),
      ],
    );
  }

  Widget _buildLogPane(List<DSExecutionLine> lines) {
    return Semantics(
      container: true,
      label: '${widget.logSemanticLabel}: ${lines.length} lines',
      child: Column(
        key: DSExecutionConsole.logKey,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: lines.isEmpty
                ? Center(
                    key: DSExecutionConsole.emptyKey,
                    child: Padding(
                      padding: const EdgeInsets.all(DSSpacing.lg),
                      child: DSStateSurface.empty(
                        icon: Icons.terminal_outlined,
                        title: widget.emptyTitle,
                        subtitle: widget.emptySubtitle,
                        compact: true,
                      ),
                    ),
                  )
                : _ExecutionLineList(
                    lines: lines,
                    runGroups: _effectiveRunGroups,
                    selectedGroupId: _effectiveSelectedId,
                    scrollController: _scrollController,
                    onGroupSelected: _selectGroup,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutputPane() {
    if (widget.outputPanel != null) {
      return Semantics(
        container: true,
        label: widget.outputSemanticLabel,
        child: KeyedSubtree(
          key: DSExecutionConsole.outputKey,
          child: widget.outputPanel!,
        ),
      );
    }

    final output = _effectiveStructuredOutput;
    final group = _selectedGroup;

    return Semantics(
      container: true,
      label: widget.outputSemanticLabel,
      child: Column(
        key: DSExecutionConsole.outputKey,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: DSSpacing.lg,
              vertical: DSSpacing.md,
            ),
            child: Row(
              children: [
                const DSIcon.small(
                  Icons.data_object_outlined,
                  color: DSColors.accentViolet,
                ),
                const SizedBox(width: DSSpacing.sm),
                Expanded(
                  child: DSText.labelMedium(
                    group != null
                        ? 'Output · ${group.label}'
                        : 'Structured output',
                    color: DSColors.textSecondary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const DSDivider.subtle(),
          Expanded(
            child: output == null || output.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(DSSpacing.lg),
                      child: DSStateSurface.empty(
                        icon: Icons.output_outlined,
                        title: 'No structured output',
                        subtitle: group == null
                            ? 'Select a run group with fixture output'
                            : 'This run has no structured output fixture',
                        compact: true,
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(DSSpacing.md),
                    child: DSCodeBlock(
                      source: output,
                      language: _effectiveOutputLanguage,
                      showLineNumbers: true,
                      maxHeight: widget.outputMaxHeight,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Header
// =============================================================================

class _ConsoleHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final int lineCount;
  final bool showResumeScroll;
  final VoidCallback onResumeScroll;

  const _ConsoleHeader({
    required this.title,
    required this.subtitle,
    required this.lineCount,
    required this.showResumeScroll,
    required this.onResumeScroll,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      label: '$title, $lineCount lines',
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
                color: DSColors.accentCyan.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(DSRadii.md),
              ),
              child: const DSIcon.small(
                Icons.terminal_outlined,
                color: DSColors.accentCyan,
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
            if (showResumeScroll) ...[
              Semantics(
                label: 'Resume auto-scroll to latest',
                button: true,
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    onTap: onResumeScroll,
                    borderRadius: BorderRadius.circular(DSRadii.chip),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minWidth: kMinInteractiveDimension,
                        minHeight: kMinInteractiveDimension,
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(
                          horizontal: DSSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: DSColors.accentCyan.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(DSRadii.chip),
                          border: Border.all(
                            color: DSColors.accentCyan.withValues(alpha: 0.3),
                          ),
                        ),
                        child: const DSText.labelSmall(
                          'Latest',
                          color: DSColors.accentCyan,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: DSSpacing.sm),
            ],
            DSBadge(label: '$lineCount', color: DSColors.accentCyan),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Line list with optional sticky group headers
// =============================================================================

class _ExecutionLineList extends StatelessWidget {
  final List<DSExecutionLine> lines;
  final List<DSExecutionRunGroup> runGroups;
  final String? selectedGroupId;
  final ScrollController scrollController;
  final ValueChanged<String> onGroupSelected;

  const _ExecutionLineList({
    required this.lines,
    required this.runGroups,
    required this.selectedGroupId,
    required this.scrollController,
    required this.onGroupSelected,
  });

  Map<String, DSExecutionRunGroup> get _groupById {
    return {for (final g in runGroups) g.id: g};
  }

  /// Build ordered sections: known groups (in declaration order) then ungrouped.
  List<_LineSection> _sections() {
    final byGroup = <String?, List<DSExecutionLine>>{};
    for (final line in lines) {
      byGroup.putIfAbsent(line.runGroupId, () => []).add(line);
    }

    final sections = <_LineSection>[];
    final seen = <String>{};

    for (final group in runGroups) {
      final groupLines = byGroup[group.id] ?? const <DSExecutionLine>[];
      if (groupLines.isEmpty && byGroup.isNotEmpty) {
        // Still show header for declared groups that have no lines yet.
        sections.add(_LineSection(group: group, lines: const []));
        seen.add(group.id);
        continue;
      }
      if (groupLines.isNotEmpty || runGroups.isNotEmpty) {
        sections.add(_LineSection(group: group, lines: groupLines));
        seen.add(group.id);
      }
    }

    // Lines whose group id is unknown or null.
    for (final entry in byGroup.entries) {
      final key = entry.key;
      if (key != null && seen.contains(key)) continue;
      if (key != null && !seen.contains(key)) {
        final synthetic =
            _groupById[key] ??
            DSExecutionRunGroup(
              id: key,
              label: key,
              status: DSExecutionRunStatus.running,
            );
        sections.add(_LineSection(group: synthetic, lines: entry.value));
        seen.add(key);
      }
    }

    final ungrouped = byGroup[null];
    if (ungrouped != null && ungrouped.isNotEmpty) {
      sections.add(_LineSection(group: null, lines: ungrouped));
    }

    // If we somehow produced nothing but have lines, fall back to flat list.
    if (sections.isEmpty && lines.isNotEmpty) {
      sections.add(_LineSection(group: null, lines: lines));
    }

    return sections;
  }

  @override
  Widget build(BuildContext context) {
    final sections = _sections();
    final hasGroups = sections.any((s) => s.group != null);

    if (!hasGroups) {
      return ListView.builder(
        key: DSExecutionConsole.lineListKey,
        controller: scrollController,
        padding: const EdgeInsets.only(bottom: DSSpacing.lg),
        itemCount: lines.length,
        itemBuilder: (context, index) {
          final line = lines[index];
          return _ExecutionLineRow(line: line);
        },
      );
    }

    return CustomScrollView(
      key: DSExecutionConsole.lineListKey,
      controller: scrollController,
      slivers: [
        for (final section in sections)
          if (section.group == null)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) =>
                    _ExecutionLineRow(line: section.lines[index]),
                childCount: section.lines.length,
              ),
            )
          else
            // Sticky group header + lines for this run.
            SliverMainAxisGroup(
              slivers: [
                // Non-pinned header keeps layout simple and reliable in tests;
                // visual chrome still acts as a section label. True pin would
                // fight multi-group scroll extent in short viewports.
                // Composition note: sticky-looking section labels via elevated header.
                SliverToBoxAdapter(
                  child: _RunGroupHeader(
                    group: section.group!,
                    selected: section.group!.id == selectedGroupId,
                    lineCount: section.lines.length,
                    onTap: () => onGroupSelected(section.group!.id),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        _ExecutionLineRow(line: section.lines[index]),
                    childCount: section.lines.length,
                  ),
                ),
              ],
            ),
      ],
    );
  }
}

class _LineSection {
  final DSExecutionRunGroup? group;
  final List<DSExecutionLine> lines;

  const _LineSection({required this.group, required this.lines});
}

class _RunGroupHeader extends StatelessWidget {
  final DSExecutionRunGroup group;
  final bool selected;
  final int lineCount;
  final VoidCallback onTap;

  const _RunGroupHeader({
    required this.group,
    required this.selected,
    required this.lineCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return DSInteractiveSurface(
      semanticLabel:
          'Run group ${group.label}, ${group.status.label}, $lineCount lines',
      selected: selected,
      onTap: onTap,
      child: Container(
        key: DSExecutionConsole.groupHeaderKey(group.id),
        padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.md,
          vertical: DSSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected
              ? DSColors.obsidianActive.withValues(alpha: 0.85)
              : DSColors.obsidianElevated.withValues(alpha: 0.95),
          border: Border(
            left: BorderSide(
              color: selected ? DSColors.accentCyan : group.status.color,
              width: 2,
            ),
            bottom: const BorderSide(color: DSColors.borderSubtle),
          ),
        ),
        child: Row(
          children: [
            DSBadge(
              label: group.status.label.toUpperCase(),
              color: group.status.color,
              size: DSBadgeSize.small,
            ),
            const SizedBox(width: DSSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DSText.labelMedium(
                    group.label,
                    color: DSColors.textPrimary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (group.subtitle != null && group.subtitle!.isNotEmpty)
                    DSText.labelSmall(
                      group.subtitle!,
                      color: DSColors.textTertiary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            DSText.labelSmall('$lineCount', color: DSColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

class _ExecutionLineRow extends StatelessWidget {
  final DSExecutionLine line;

  const _ExecutionLineRow({required this.line});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: line.semanticLabel,
      child: Container(
        key: DSExecutionConsole.lineKey(line.id),
        constraints: const BoxConstraints(minHeight: 36),
        padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.md,
          vertical: DSSpacing.xs,
        ),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: line.level.color, width: 2),
            bottom: const BorderSide(color: DSColors.borderSubtle, width: 0.5),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (line.timestampLabel != null) ...[
              SizedBox(
                width: 64,
                child: DSText.labelSmall(
                  line.timestampLabel!,
                  color: DSColors.textTertiary,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: DSSpacing.sm),
            ],
            SizedBox(
              width: 40,
              child: DSText.labelSmall(
                line.level.label,
                color: line.level.color,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: DSSpacing.sm),
            if (line.source != null) ...[
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 96),
                child: DSText.labelSmall(
                  line.source!,
                  color: DSColors.textTertiary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: DSSpacing.sm),
            ],
            Expanded(
              child: DSText.bodySmall(
                line.message,
                color:
                    line.level == DSExecutionLineLevel.error ||
                        line.level == DSExecutionLineLevel.stderr
                    ? DSColors.statusError
                    : DSColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Fixtures (gallery + tests) — mock IDs only, no shell execution
// =============================================================================

/// Multi-group fixture run for gallery demos (Sim Studio-style steps).
List<DSExecutionRunGroup> dsExecutionConsoleFixtureRunGroups() {
  return const [
    DSExecutionRunGroup(
      id: 'run-load',
      label: 'Run · load-fixtures',
      status: DSExecutionRunStatus.success,
      subtitle: 'step 1/3',
      structuredOutput: '{\n  "loaded": 42,\n  "durationMs": 180\n}',
      outputLanguage: 'json',
    ),
    DSExecutionRunGroup(
      id: 'run-transform',
      label: 'Run · transform',
      status: DSExecutionRunStatus.success,
      subtitle: 'step 2/3',
      structuredOutput: '{\n  "nodes": 12,\n  "edges": 18\n}',
      outputLanguage: 'json',
    ),
    DSExecutionRunGroup(
      id: 'run-publish',
      label: 'Run · publish',
      status: DSExecutionRunStatus.running,
      subtitle: 'step 3/3',
      structuredOutput: '{\n  "status": "streaming",\n  "published": 3\n}',
      outputLanguage: 'json',
    ),
  ];
}

/// Grouped fixture lines for gallery demos.
List<DSExecutionLine> dsExecutionConsoleFixtureLines() {
  return const [
    DSExecutionLine(
      id: 'line-1',
      runGroupId: 'run-load',
      level: DSExecutionLineLevel.system,
      source: 'orchestrator',
      timestampLabel: '12:01:02',
      message: 'Starting load-fixtures',
    ),
    DSExecutionLine(
      id: 'line-2',
      runGroupId: 'run-load',
      level: DSExecutionLineLevel.stdout,
      source: 'loader',
      timestampLabel: '12:01:03',
      message: 'Read 42 mock records from fixture corpus',
    ),
    DSExecutionLine(
      id: 'line-3',
      runGroupId: 'run-load',
      level: DSExecutionLineLevel.info,
      source: 'loader',
      timestampLabel: '12:01:03',
      message: 'Validation complete — 0 warnings',
    ),
    DSExecutionLine(
      id: 'line-4',
      runGroupId: 'run-transform',
      level: DSExecutionLineLevel.system,
      source: 'orchestrator',
      timestampLabel: '12:01:04',
      message: 'Starting transform',
    ),
    DSExecutionLine(
      id: 'line-5',
      runGroupId: 'run-transform',
      level: DSExecutionLineLevel.stdout,
      source: 'graph',
      timestampLabel: '12:01:05',
      message: 'Built DAG: 12 nodes, 18 edges',
    ),
    DSExecutionLine(
      id: 'line-6',
      runGroupId: 'run-transform',
      level: DSExecutionLineLevel.warning,
      source: 'graph',
      timestampLabel: '12:01:05',
      message: 'Skipped 1 orphan edge (fixture)',
    ),
    DSExecutionLine(
      id: 'line-7',
      runGroupId: 'run-publish',
      level: DSExecutionLineLevel.system,
      source: 'orchestrator',
      timestampLabel: '12:01:06',
      message: 'Starting publish',
    ),
    DSExecutionLine(
      id: 'line-8',
      runGroupId: 'run-publish',
      level: DSExecutionLineLevel.stdout,
      source: 'publisher',
      timestampLabel: '12:01:07',
      message: 'Published projection slice 1/3',
    ),
    DSExecutionLine(
      id: 'line-9',
      runGroupId: 'run-publish',
      level: DSExecutionLineLevel.stdout,
      source: 'publisher',
      timestampLabel: '12:01:08',
      message: 'Published projection slice 2/3',
    ),
  ];
}

/// Compact two-group fixture for widget tests.
({List<DSExecutionRunGroup> groups, List<DSExecutionLine> lines})
dsExecutionConsoleMinimalFixture() {
  return (
    groups: const [
      DSExecutionRunGroup(
        id: 'g1',
        label: 'Run A',
        status: DSExecutionRunStatus.success,
        structuredOutput: '{"ok": true}',
        outputLanguage: 'json',
      ),
      DSExecutionRunGroup(
        id: 'g2',
        label: 'Run B',
        status: DSExecutionRunStatus.failed,
        structuredOutput: '{"ok": false, "error": "fixture"}',
        outputLanguage: 'json',
      ),
    ],
    lines: const [
      DSExecutionLine(
        id: 'l1',
        runGroupId: 'g1',
        level: DSExecutionLineLevel.stdout,
        message: 'step-a complete',
      ),
      DSExecutionLine(
        id: 'l2',
        runGroupId: 'g1',
        level: DSExecutionLineLevel.info,
        message: 'metrics flushed',
      ),
      DSExecutionLine(
        id: 'l3',
        runGroupId: 'g2',
        level: DSExecutionLineLevel.error,
        message: 'step-b failed (fixture)',
      ),
    ],
  );
}
