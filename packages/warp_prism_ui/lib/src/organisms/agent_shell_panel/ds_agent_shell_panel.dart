import 'package:flutter/material.dart';
import '../../atoms/atoms.dart';
import '../../molecules/molecules.dart';
import '../../tokens/tokens.dart';

/// Type of transcript line in the agent shell.
enum DSAgentShellLineType {
  /// Standard process stdout output.
  stdout,

  /// Error process stderr output.
  stderr,

  /// User input / command prompt representation in transcript.
  input,

  /// System notification / state transition.
  system,
}

/// Representation of a single line in the read-only transcript.
@immutable
class DSAgentShellLine {
  /// Stable unique id within a console/transcript session.
  final String id;

  /// Display text message.
  final String text;

  /// Stream / channel category.
  final DSAgentShellLineType type;

  /// Optional timestamp for this line.
  final DateTime? timestamp;

  const DSAgentShellLine({
    required this.id,
    required this.text,
    this.type = DSAgentShellLineType.stdout,
    this.timestamp,
  });

  /// Helper to generate semantic label for accessibility.
  String get semanticLabel {
    final t = timestamp != null ? ' at ${_formatTime(timestamp!)}' : '';
    switch (type) {
      case DSAgentShellLineType.stdout:
        return 'Standard output$t: $text';
      case DSAgentShellLineType.stderr:
        return 'System error$t: $text';
      case DSAgentShellLineType.input:
        return 'Command prompt input$t: $text';
      case DSAgentShellLineType.system:
        return 'State transition$t: $text';
    }
  }

  static String _formatTime(DateTime ts) {
    final h = ts.hour.toString().padLeft(2, '0');
    final m = ts.minute.toString().padLeft(2, '0');
    final s = ts.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DSAgentShellLine &&
        other.id == id &&
        other.text == text &&
        other.type == type &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode => Object.hash(id, text, type, timestamp);
}

/// Controller managing a list of [DSAgentShellLine] for [DSAgentShellPanel].
class DSAgentShellPanelController extends ChangeNotifier {
  List<DSAgentShellLine> _lines;

  DSAgentShellPanelController({List<DSAgentShellLine>? initialLines})
    : _lines = List<DSAgentShellLine>.from(
        initialLines ?? const <DSAgentShellLine>[],
      );

  /// Returns an unmodifiable list of current transcript lines.
  List<DSAgentShellLine> get lines => List.unmodifiable(_lines);

  /// Appends a new single transcript line.
  void appendLine(DSAgentShellLine line) {
    _lines = [..._lines, line];
    notifyListeners();
  }

  /// Appends multiple transcript lines at once.
  void appendLines(Iterable<DSAgentShellLine> newLines) {
    final batch = newLines.toList();
    if (batch.isEmpty) return;
    _lines = [..._lines, ...batch];
    notifyListeners();
  }

  /// Clears the transcript history.
  void clear() {
    if (_lines.isEmpty) return;
    _lines = const <DSAgentShellLine>[];
    notifyListeners();
  }
}

/// ASW Observatory Organism — Agent Shell Panel Transcript
///
/// A read-only terminal-like view presenting chronological agent session
/// output lines without interactive text editors or remote PTY execution.
///
/// Under-the-hood this renders a scrollable list styled according to the
/// design system Obsidian glass aesthetics.
class DSAgentShellPanel extends StatefulWidget {
  /// Controller managing the transcript line stream.
  final DSAgentShellPanelController controller;

  /// Semantic accessibility label for the transcript container.
  final String semanticLabel;

  /// Custom empty state title.
  final String emptyLabel;

  /// Custom empty state details.
  final String emptySubtitle;

  /// Title rendered in the header toolbar when visible.
  final String title;

  /// Subtitle rendered next to or under the title (e.g. "session-active").
  final String? subtitle;

  /// Show the header toolbar; defaults to true.
  final bool showHeader;

  /// Optional callback to clear the panel output.
  final VoidCallback? onClear;

  const DSAgentShellPanel({
    super.key,
    required this.controller,
    this.semanticLabel = 'Agent Session Transcript',
    this.emptyLabel = 'Shell session vacant',
    this.emptySubtitle = 'No agent transcript recorded in this session',
    this.title = 'Agent Shell',
    this.subtitle,
    this.showHeader = true,
    this.onClear,
  });

  @override
  State<DSAgentShellPanel> createState() => _DSAgentShellPanelState();
}

class _DSAgentShellPanelState extends State<DSAgentShellPanel> {
  final ScrollController _scrollController = ScrollController();
  bool _autoScroll = true;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(DSAgentShellPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    // Pause autoscroll if user scrolls up past page height threshold.
    if (position.pixels < position.maxScrollExtent - 20) {
      if (_autoScroll) {
        setState(() {
          _autoScroll = false;
        });
      }
    } else {
      if (!_autoScroll) {
        setState(() {
          _autoScroll = true;
        });
      }
    }
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
      if (_autoScroll) {
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Guard against dispose racing the scheduled frame callback.
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: DSMotion.normal,
        curve: DSMotion.standard,
      );
    });
  }

  Color _getLineColor(DSAgentShellLineType type) {
    switch (type) {
      case DSAgentShellLineType.stdout:
        return DSColors.textSecondary;
      case DSAgentShellLineType.stderr:
        return DSColors.statusError;
      case DSAgentShellLineType.input:
        return DSColors.accentCyan;
      case DSAgentShellLineType.system:
        return DSColors.accentViolet;
    }
  }

  String _formatTimestamp(DateTime ts) {
    final h = ts.hour.toString().padLeft(2, '0');
    final m = ts.minute.toString().padLeft(2, '0');
    final s = ts.second.toString().padLeft(2, '0');
    return '[$h:$m:$s] ';
  }

  @override
  Widget build(BuildContext context) {
    final lines = widget.controller.lines;

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: widget.semanticLabel,
      child: Container(
        decoration: BoxDecoration(
          color: DSColors.obsidianDeep,
          borderRadius: BorderRadius.circular(DSRadii.lg),
          border: Border.all(color: DSColors.borderSubtle),
          boxShadow: DSShadows.elevation2,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.showHeader) _buildHeader(),
            Expanded(
              child: lines.isEmpty ? _buildEmptyState() : _buildListView(lines),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: DSSpacing.topbarHeight,
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md),
      decoration: BoxDecoration(
        color: DSColors.obsidianBase,
        border: const Border(bottom: BorderSide(color: DSColors.borderSubtle)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.terminal_outlined,
            size: 20,
            color: DSColors.accentCyan,
          ),
          const SizedBox(width: DSSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DSText.headingSmall(widget.title, color: DSColors.textPrimary),
                if (widget.subtitle != null && widget.subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  DSText.labelSmall(
                    widget.subtitle!,
                    color: DSColors.textTertiary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (widget.onClear != null)
            Semantics(
              label: 'Clear transcript',
              button: true,
              child: IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                color: DSColors.textSecondary,
                tooltip: 'Clear history',
                onPressed: widget.onClear,
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DSSpacing.lg),
        child: DSStateSurface.empty(
          icon: Icons.terminal_outlined,
          title: widget.emptyLabel,
          subtitle: widget.emptySubtitle,
          compact: true,
        ),
      ),
    );
  }

  Widget _buildListView(List<DSAgentShellLine> lines) {
    return Scrollbar(
      controller: _scrollController,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(DSSpacing.md),
        itemCount: lines.length,
        itemBuilder: (context, index) {
          final line = lines[index];
          final timestampStr = line.timestamp != null
              ? _formatTimestamp(line.timestamp!)
              : '';
          final textColor = _getLineColor(line.type);

          return Semantics(
            label: line.semanticLabel,
            explicitChildNodes: true,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: SelectableText.rich(
                TextSpan(
                  children: [
                    if (timestampStr.isNotEmpty)
                      TextSpan(
                        text: timestampStr,
                        style: DSTypography.codeSmall.copyWith(
                          color: DSColors.textTertiary,
                        ),
                      ),
                    TextSpan(
                      text: line.text,
                      style: DSTypography.codeMedium.copyWith(color: textColor),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
