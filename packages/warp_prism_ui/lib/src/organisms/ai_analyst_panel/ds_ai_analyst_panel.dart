import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../atoms/atoms.dart';
import '../../molecules/ds_state_surface.dart';
import '../../tokens/tokens.dart';
import '../markdown_renderer/ds_markdown_renderer.dart';

// =============================================================================
// Models
// =============================================================================

/// Speaker role for a [DSAiAnalystTurn].
///
/// Chat/intel panel roles only — not terminal session lines
/// ([PrismAgentShellPanel]) and not log severity ([DSLogViewer]).
enum DSAiAnalystRole {
  /// Human / operator prompt.
  user,

  /// Fixture analyst / model response.
  assistant,

  /// System / policy / harness notice.
  system,
}

/// Lifecycle status of a single conversation turn.
enum DSAiAnalystTurnStatus {
  /// Fully resolved content.
  complete,

  /// Placeholder while a scripted reply is simulated.
  streaming,

  /// Fixture/error adapter failure for this turn.
  error,
}

/// One conversation turn in [DSAiAnalystPanel].
///
/// Contract:
/// - [id] unique within a panel/controller instance.
/// - [role] drives alignment, badge color, and semantics.
/// - [content] prose (markdown-capable for assistant turns).
/// - [timestamp] optional fixture/host time.
/// - [status] complete / streaming placeholder / error.
@immutable
class DSAiAnalystTurn {
  /// Stable unique id within a conversation.
  final String id;

  /// Speaker role.
  final DSAiAnalystRole role;

  /// Turn body (markdown-capable for assistant).
  final String content;

  /// Optional event time (fixture or host-provided).
  final DateTime? timestamp;

  /// Turn lifecycle status.
  final DSAiAnalystTurnStatus status;

  /// Optional display name override (e.g. analyst persona).
  final String? authorLabel;

  const DSAiAnalystTurn({
    required this.id,
    required this.role,
    this.content = '',
    this.timestamp,
    this.status = DSAiAnalystTurnStatus.complete,
    this.authorLabel,
  });

  /// Convenience complete text turn.
  factory DSAiAnalystTurn.text({
    required String id,
    required DSAiAnalystRole role,
    required String content,
    DateTime? timestamp,
    String? authorLabel,
  }) {
    return DSAiAnalystTurn(
      id: id,
      role: role,
      content: content,
      timestamp: timestamp,
      authorLabel: authorLabel,
    );
  }

  /// Human-readable role name for badges / semantics.
  String get roleLabel => switch (role) {
    DSAiAnalystRole.user => 'User',
    DSAiAnalystRole.assistant => 'Assistant',
    DSAiAnalystRole.system => 'System',
  };

  /// Effective author string (persona or role label).
  String get displayAuthor => authorLabel ?? roleLabel;

  /// Whether this turn is still awaiting a scripted reply body.
  bool get isStreaming => status == DSAiAnalystTurnStatus.streaming;

  /// Whether this turn represents an error.
  bool get isError => status == DSAiAnalystTurnStatus.error;

  /// Whether content is present and non-empty.
  bool get hasContent => content.trim().isNotEmpty;

  DSAiAnalystTurn copyWith({
    String? id,
    DSAiAnalystRole? role,
    String? content,
    DateTime? timestamp,
    DSAiAnalystTurnStatus? status,
    String? authorLabel,
    bool clearTimestamp = false,
    bool clearAuthorLabel = false,
  }) {
    return DSAiAnalystTurn(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: clearTimestamp ? null : (timestamp ?? this.timestamp),
      status: status ?? this.status,
      authorLabel: clearAuthorLabel ? null : (authorLabel ?? this.authorLabel),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DSAiAnalystTurn &&
        other.id == id &&
        other.role == role &&
        other.content == content &&
        other.timestamp == timestamp &&
        other.status == status &&
        other.authorLabel == authorLabel;
  }

  @override
  int get hashCode =>
      Object.hash(id, role, content, timestamp, status, authorLabel);
}

/// Async (or sync) fixture reply producer for [DSAiAnalystController].
///
/// Given the latest user message and conversation history (including the new
/// user turn), returns assistant body text. Throw to produce an error turn.
///
/// **No network / no API keys** — implementations must be pure fixtures.
typedef DSAiAnalystReplyAdapter =
    FutureOr<String> Function(
      String userMessage,
      List<DSAiAnalystTurn> history,
    );

// =============================================================================
// Fixtures
// =============================================================================

/// Default deterministic fixture reply adapter (keyword script).
///
/// - Contains `error` / `fail` → throws (error turn).
/// - Contains `brief` / `overview` → markdown briefing.
/// - Contains `health` → provider health summary.
/// - Otherwise echoes a fixture acknowledgment.
///
/// Pure local string matching — no HTTP, no keys.
String dsAiAnalystDefaultFixtureReply(
  String userMessage,
  List<DSAiAnalystTurn> history,
) {
  final q = userMessage.toLowerCase().trim();
  if (q.contains('error') || q.contains('fail')) {
    throw StateError('Fixture error: simulated analyst failure');
  }
  if (q.contains('brief') || q.contains('overview')) {
    return '**Fixture briefing**\n\n'
        '- Workspace snapshot: healthy\n'
        '- Open tasks: fixture count only\n'
        '- Live model calls: **disabled**\n\n'
        '_ADS fixture reply — no API keys._';
  }
  if (q.contains('health')) {
    return 'Provider health looks **healthy** in fixtures.\n\n'
        '- OpenAI / main-prod: healthy\n'
        '- Anthropic / claude-prod: degraded (fixture)\n\n'
        'No live pings were issued.';
  }
  final priorUsers = history
      .where((t) => t.role == DSAiAnalystRole.user)
      .length;
  return 'Acknowledged ($priorUsers): "$userMessage".\n\n'
      'This is a **fixture-only** reply — no live model keys or network.';
}

/// Multi-turn fixture conversation for gallery + tests (no network).
List<DSAiAnalystTurn> dsAiAnalystFixtureTurns({DateTime? anchor}) {
  final t0 = anchor ?? DateTime.utc(2026, 7, 10, 16, 0, 0);
  return [
    DSAiAnalystTurn(
      id: 'ai-sys-1',
      role: DSAiAnalystRole.system,
      timestamp: t0,
      content:
          'AI Analyst session — fixture harness only. No live model calls.',
    ),
    DSAiAnalystTurn(
      id: 'ai-user-1',
      role: DSAiAnalystRole.user,
      timestamp: t0.add(const Duration(seconds: 8)),
      authorLabel: 'Operator',
      content: 'Give me a brief workspace overview.',
    ),
    DSAiAnalystTurn(
      id: 'ai-asst-1',
      role: DSAiAnalystRole.assistant,
      timestamp: t0.add(const Duration(seconds: 20)),
      authorLabel: 'Prism Analyst',
      content:
          '**Fixture briefing**\n\n'
          '- Workspace snapshot: healthy\n'
          '- Open tasks: fixture count only\n'
          '- Live model calls: **disabled**\n\n'
          '_ADS fixture reply — no API keys._',
    ),
    DSAiAnalystTurn(
      id: 'ai-user-2',
      role: DSAiAnalystRole.user,
      timestamp: t0.add(const Duration(minutes: 1)),
      authorLabel: 'Operator',
      content: 'Check provider health.',
    ),
    DSAiAnalystTurn(
      id: 'ai-asst-2',
      role: DSAiAnalystRole.assistant,
      timestamp: t0.add(const Duration(minutes: 1, seconds: 15)),
      authorLabel: 'Prism Analyst',
      content:
          'Provider health looks **healthy** in fixtures.\n\n'
          '- OpenAI / main-prod: healthy\n'
          '- Anthropic / claude-prod: degraded (fixture)\n\n'
          'No live pings were issued.',
    ),
  ];
}

/// Single-turn error fixture for demos/tests.
DSAiAnalystTurn dsAiAnalystErrorFixtureTurn({
  String id = 'ai-err-1',
  DateTime? timestamp,
}) {
  return DSAiAnalystTurn(
    id: id,
    role: DSAiAnalystRole.assistant,
    timestamp: timestamp ?? DateTime.utc(2026, 7, 10, 16, 5, 0),
    authorLabel: 'Prism Analyst',
    status: DSAiAnalystTurnStatus.error,
    content: 'Fixture error: simulated analyst failure',
  );
}

// =============================================================================
// Controller
// =============================================================================

/// Imperative handle for [DSAiAnalystPanel] conversation state.
///
/// Owns the turn list, send lifecycle, and optional streaming simulation.
/// Inject a custom [replyAdapter] for scripted replies; default is
/// [dsAiAnalystDefaultFixtureReply].
///
/// **No network client or API key paths.**
class DSAiAnalystController extends ChangeNotifier {
  /// Scripted reply producer (fixture-only).
  final DSAiAnalystReplyAdapter replyAdapter;

  /// Delay before completing a streaming placeholder (zero skips wait).
  final Duration streamSimulationDelay;

  /// When true, append a streaming placeholder before the fixture reply.
  final bool simulateStreaming;

  /// Optional author label for assistant turns.
  final String assistantAuthorLabel;

  /// Optional author label for user turns.
  final String userAuthorLabel;

  /// Clock override for deterministic timestamps in tests.
  final DateTime Function()? now;

  List<DSAiAnalystTurn> _turns;
  bool _busy = false;
  bool _disposed = false;
  int _seq = 0;
  Object? _lastError;

  DSAiAnalystController({
    List<DSAiAnalystTurn>? initialTurns,
    DSAiAnalystReplyAdapter? replyAdapter,
    this.streamSimulationDelay = const Duration(milliseconds: 350),
    this.simulateStreaming = true,
    this.assistantAuthorLabel = 'Prism Analyst',
    this.userAuthorLabel = 'Operator',
    this.now,
  }) : replyAdapter = replyAdapter ?? dsAiAnalystDefaultFixtureReply,
       _turns = List<DSAiAnalystTurn>.of(
         initialTurns ?? const <DSAiAnalystTurn>[],
       ) {
    _seq = _turns.length;
  }

  /// Ordered conversation turns (oldest → newest).
  List<DSAiAnalystTurn> get turns => List.unmodifiable(_turns);

  /// True while a send/reply cycle is in flight.
  bool get isBusy => _busy;

  /// Whether [dispose] has been called.
  bool get isDisposed => _disposed;

  /// Last error object from a failed send (if any).
  Object? get lastError => _lastError;

  /// Whether the transcript is empty.
  bool get isEmpty => _turns.isEmpty;

  void _safeNotify() {
    if (_disposed) return;
    notifyListeners();
  }

  /// Replace the full turn list (e.g. host reload / tests).
  void setTurns(List<DSAiAnalystTurn> turns) {
    if (_disposed) return;
    _turns = List<DSAiAnalystTurn>.of(turns);
    _seq = _turns.length;
    _lastError = null;
    _safeNotify();
  }

  /// Append a pre-built turn without invoking the reply adapter.
  void appendTurn(DSAiAnalystTurn turn) {
    if (_disposed) return;
    _turns = [..._turns, turn];
    _safeNotify();
  }

  /// Clear all turns.
  void clear() {
    if (_disposed) return;
    _turns = <DSAiAnalystTurn>[];
    _lastError = null;
    _busy = false;
    _safeNotify();
  }

  String _nextId(String prefix) {
    _seq += 1;
    return '$prefix-$_seq';
  }

  DateTime _now() => now?.call() ?? DateTime.now().toUtc();

  /// Append a user message and produce a scripted assistant reply.
  ///
  /// Empty / whitespace-only messages are ignored. Concurrent sends while
  /// [isBusy] are ignored. Safe after [dispose]: in-flight awaits exit without
  /// mutating state or calling [notifyListeners].
  Future<void> send(String message) async {
    final trimmed = message.trim();
    if (_disposed || trimmed.isEmpty || _busy) return;

    _busy = true;
    _lastError = null;
    final userTurn = DSAiAnalystTurn(
      id: _nextId('user'),
      role: DSAiAnalystRole.user,
      content: trimmed,
      timestamp: _now(),
      authorLabel: userAuthorLabel,
    );
    _turns = [..._turns, userTurn];
    _safeNotify();

    String? streamId;
    if (simulateStreaming) {
      streamId = _nextId('asst');
      _turns = [
        ..._turns,
        DSAiAnalystTurn(
          id: streamId,
          role: DSAiAnalystRole.assistant,
          content: '',
          timestamp: _now(),
          status: DSAiAnalystTurnStatus.streaming,
          authorLabel: assistantAuthorLabel,
        ),
      ];
      _safeNotify();

      if (streamSimulationDelay > Duration.zero) {
        await Future<void>.delayed(streamSimulationDelay);
      }
      if (_disposed) return;
    }

    try {
      if (_disposed) return;
      final reply = await Future.sync(
        () => replyAdapter(trimmed, List.unmodifiable(_turns)),
      );
      if (_disposed) return;
      final body = reply.toString();
      final complete = DSAiAnalystTurn(
        id: streamId ?? _nextId('asst'),
        role: DSAiAnalystRole.assistant,
        content: body,
        timestamp: _now(),
        status: DSAiAnalystTurnStatus.complete,
        authorLabel: assistantAuthorLabel,
      );
      if (streamId != null) {
        _turns = [
          for (final t in _turns)
            if (t.id == streamId) complete else t,
        ];
      } else {
        _turns = [..._turns, complete];
      }
    } catch (e) {
      if (_disposed) return;
      _lastError = e;
      final errTurn = DSAiAnalystTurn(
        id: streamId ?? _nextId('asst'),
        role: DSAiAnalystRole.assistant,
        content: e is StateError ? e.message : e.toString(),
        timestamp: _now(),
        status: DSAiAnalystTurnStatus.error,
        authorLabel: assistantAuthorLabel,
      );
      if (streamId != null) {
        _turns = [
          for (final t in _turns)
            if (t.id == streamId) errTurn else t,
        ];
      } else {
        _turns = [..._turns, errTurn];
      }
    } finally {
      if (!_disposed) {
        _busy = false;
        _safeNotify();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _busy = false;
    super.dispose();
  }
}

// =============================================================================
// Organism
// =============================================================================

/// ASW Observatory Organism — AI Analyst Panel
///
/// Fixture-first **chat / intel turns** panel for CyberCore AI analyst demos.
/// Hosts a multi-turn transcript, composer bar, optional streaming placeholder,
/// and a deterministic fixture reply adapter.
///
/// ## Boundary (false-gap guard)
///
/// | This organism | Not this organism |
/// | --- | --- |
/// | Fixture chat + composer + scripted reply | Live Gemini / LLM clients or API keys |
/// | Intel analyst conversation chrome | [DSAgentTranscript] read-only multi-block chat (compose-able) |
/// | Streaming **simulation** only | Real token streaming transports |
/// | EPIC-15 O-15 / Task 1511 | [PrismAgentShellPanel] terminal/session shell |
///
/// ## Contract
///
/// - Parent should provide a **bounded height** (Column + Expanded list).
/// - Empty [initialTurns] / empty controller shows an empty surface.
/// - [onTurnsChanged] fires on every transcript mutation (including streaming
/// intermediate updates) so hosts can mirror state without polling.
/// - No network, no API keys, no product route coupling.
class DSAiAnalystPanel extends StatefulWidget {
  /// Optional external controller. When null, an internal controller is owned
  /// from [initialTurns] + [replyAdapter].
  final DSAiAnalystController? controller;

  /// Seed turns when no external [controller] is provided.
  final List<DSAiAnalystTurn>? initialTurns;

  /// Fixture reply adapter used by the internal controller.
  final DSAiAnalystReplyAdapter? replyAdapter;

  /// Stream simulation delay for the internal controller.
  final Duration streamSimulationDelay;

  /// Whether the internal controller shows a streaming placeholder.
  final bool simulateStreaming;

  /// Panel header title.
  final String title;

  /// Optional subtitle under the title.
  final String? subtitle;

  /// Empty-state title.
  final String emptyTitle;

  /// Empty-state subtitle.
  final String emptySubtitle;

  /// Composer placeholder.
  final String composerHint;

  /// Semantic label for the panel container.
  final String semanticLabel;

  /// Semantic label for the send control.
  final String sendSemanticLabel;

  /// Whether to wrap content in [DSGlassPanel.elevated].
  final bool wrapInGlass;

  /// Whether assistant content uses [DSMarkdownRenderer].
  final bool renderMarkdown;

  /// Whether to show timestamps on turns.
  final bool showTimestamps;

  /// Whether the composer is enabled.
  final bool composerEnabled;

  /// Optional close affordance.
  final VoidCallback? onClose;

  /// Fired on every transcript mutation (streaming intermediate + final).
  final ValueChanged<List<DSAiAnalystTurn>>? onTurnsChanged;

  /// Optional header trailing actions (before close).
  final Widget? headerActions;

  /// Policy banner under the header (fixture-only notice).
  final String? policyBanner;

  const DSAiAnalystPanel({
    super.key,
    this.controller,
    this.initialTurns,
    this.replyAdapter,
    this.streamSimulationDelay = const Duration(milliseconds: 350),
    this.simulateStreaming = true,
    this.title = 'AI Analyst',
    this.subtitle,
    this.emptyTitle = 'No conversation yet',
    this.emptySubtitle =
        'Ask a fixture question — replies are scripted, not live.',
    this.composerHint = 'Ask the fixture analyst…',
    this.semanticLabel = panelSemanticLabel,
    this.sendSemanticLabel = sendControlSemanticLabel,
    this.wrapInGlass = true,
    this.renderMarkdown = true,
    this.showTimestamps = true,
    this.composerEnabled = true,
    this.onClose,
    this.onTurnsChanged,
    this.headerActions,
    this.policyBanner = fixturePolicyBanner,
  });

  // --- Stable keys / semantics ---

  static const Key panelKey = Key('ds-ai-analyst-panel');
  static const Key headerKey = Key('ds-ai-analyst-header');
  static const Key transcriptKey = Key('ds-ai-analyst-transcript');
  static const Key emptyStateKey = Key('ds-ai-analyst-empty');
  static const Key composerKey = Key('ds-ai-analyst-composer');
  static const Key composerFieldKey = Key('ds-ai-analyst-composer-field');
  static const Key sendButtonKey = Key('ds-ai-analyst-send');
  static const Key streamingKey = Key('ds-ai-analyst-streaming');
  static const Key policyBannerKey = Key('ds-ai-analyst-policy');
  static const Key closeButtonKey = Key('ds-ai-analyst-close');

  static const String panelSemanticLabel = 'AI analyst panel';
  static const String sendControlSemanticLabel = 'Send message to AI analyst';
  static const String composerFieldSemanticLabel = 'AI analyst message input';
  static const String streamingSemanticLabel = 'Analyst is preparing a reply';
  static const String fixturePolicyBanner =
      'Fixture-only — no live model keys or network.';

  @override
  State<DSAiAnalystPanel> createState() => _DSAiAnalystPanelState();
}

class _DSAiAnalystPanelState extends State<DSAiAnalystPanel> {
  DSAiAnalystController? _owned;
  late DSAiAnalystController _active;
  final TextEditingController _composer = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final FocusNode _composerFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _bindController();
  }

  @override
  void didUpdateWidget(DSAiAnalystPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _unbind();
      _bindController();
    }
  }

  void _bindController() {
    if (widget.controller != null) {
      _owned = null;
      _active = widget.controller!;
    } else {
      _owned = DSAiAnalystController(
        initialTurns: widget.initialTurns,
        replyAdapter: widget.replyAdapter,
        streamSimulationDelay: widget.streamSimulationDelay,
        simulateStreaming: widget.simulateStreaming,
      );
      _active = _owned!;
    }
    _active.addListener(_onControllerChanged);
  }

  void _unbind() {
    _active.removeListener(_onControllerChanged);
    _owned?.dispose();
    _owned = null;
  }

  void _onControllerChanged() {
    if (!mounted) return;
    setState(() {});
    widget.onTurnsChanged?.call(_active.turns);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scroll.hasClients) return;
      final reduceMotion = MediaQuery.disableAnimationsOf(context);
      if (reduceMotion) {
        _scroll.jumpTo(_scroll.position.maxScrollExtent);
        return;
      }
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _unbind();
    _composer.dispose();
    _scroll.dispose();
    _composerFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!widget.composerEnabled || _active.isBusy) return;
    final text = _composer.text;
    if (text.trim().isEmpty) return;
    _composer.clear();
    await _active.send(text);
  }

  @override
  Widget build(BuildContext context) {
    final turns = _active.turns;
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Header(
          title: widget.title,
          subtitle:
              widget.subtitle ??
              (widget.policyBanner != null ? null : 'Fixture analyst'),
          onClose: widget.onClose,
          headerActions: widget.headerActions,
          busy: _active.isBusy,
        ),
        if (widget.policyBanner != null) ...[
          const DSDivider.subtle(),
          _PolicyBanner(text: widget.policyBanner!),
        ],
        const DSDivider.subtle(),
        Expanded(
          child: turns.isEmpty ? _buildEmpty() : _buildTranscript(turns),
        ),
        const DSDivider.subtle(),
        _ComposerBar(
          enabled: widget.composerEnabled && !_active.isBusy,
          busy: _active.isBusy,
          controller: _composer,
          focusNode: _composerFocus,
          hint: widget.composerHint,
          sendSemanticLabel: widget.sendSemanticLabel,
          onSend: _submit,
        ),
      ],
    );

    final wrapped = widget.wrapInGlass
        ? DSGlassPanel.elevated(padding: EdgeInsets.zero, child: content)
        : ColoredBox(color: DSColors.obsidianDeep, child: content);

    return Semantics(
      key: DSAiAnalystPanel.panelKey,
      container: true,
      explicitChildNodes: true,
      label: widget.semanticLabel,
      child: wrapped,
    );
  }

  Widget _buildEmpty() {
    return Semantics(
      key: DSAiAnalystPanel.emptyStateKey,
      label: widget.emptyTitle,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(DSSpacing.lg),
          child: DSStateSurface.empty(
            icon: Icons.psychology_outlined,
            title: widget.emptyTitle,
            subtitle: widget.emptySubtitle,
            compact: true,
          ),
        ),
      ),
    );
  }

  Widget _buildTranscript(List<DSAiAnalystTurn> turns) {
    return ListView.builder(
      key: DSAiAnalystPanel.transcriptKey,
      controller: _scroll,
      padding: const EdgeInsets.all(DSSpacing.lg),
      itemCount: turns.length,
      itemBuilder: (context, index) {
        final turn = turns[index];
        return Padding(
          key: Key('ds-ai-analyst-turn-${turn.id}'),
          padding: const EdgeInsets.only(bottom: DSSpacing.md),
          child: _TurnBubble(
            turn: turn,
            turnIndex: index + 1,
            showTimestamp: widget.showTimestamps,
            renderMarkdown: widget.renderMarkdown,
          ),
        );
      },
    );
  }
}

// =============================================================================
// Private UI pieces
// =============================================================================

class _Header extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onClose;
  final Widget? headerActions;
  final bool busy;

  const _Header({
    required this.title,
    this.subtitle,
    this.onClose,
    this.headerActions,
    this.busy = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      key: DSAiAnalystPanel.headerKey,
      container: true,
      label: title,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.lg,
          vertical: DSSpacing.md,
        ),
        child: Row(
          children: [
            const Icon(
              Icons.psychology_outlined,
              size: 18,
              color: DSColors.accentCyan,
            ),
            const SizedBox(width: DSSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: DSText.labelLarge(
                          title,
                          color: DSColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: DSSpacing.sm),
                      DSBadge(
                        label: busy ? 'THINKING' : 'FIXTURE',
                        color: busy
                            ? DSColors.accentViolet
                            : DSColors.accentCyan,
                        size: DSBadgeSize.small,
                      ),
                    ],
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: DSSpacing.xxs),
                    DSText.labelSmall(subtitle!, color: DSColors.textTertiary),
                  ],
                ],
              ),
            ),
            if (headerActions != null) headerActions!,
            if (onClose != null)
              Semantics(
                button: true,
                label: 'Close AI analyst panel',
                child: IconButton(
                  key: DSAiAnalystPanel.closeButtonKey,
                  tooltip: 'Close',
                  icon: const Icon(Icons.close, size: 18),
                  color: DSColors.textSecondary,
                  onPressed: onClose,
                  constraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PolicyBanner extends StatelessWidget {
  final String text;

  const _PolicyBanner({required this.text});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      key: DSAiAnalystPanel.policyBannerKey,
      label: text,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.lg,
          vertical: DSSpacing.sm,
        ),
        child: Row(
          children: [
            const Icon(
              Icons.shield_outlined,
              size: 14,
              color: DSColors.accentGold,
            ),
            const SizedBox(width: DSSpacing.sm),
            Expanded(
              child: DSText.bodySmall(text, color: DSColors.textTertiary),
            ),
          ],
        ),
      ),
    );
  }
}

class _TurnBubble extends StatelessWidget {
  final DSAiAnalystTurn turn;
  final int turnIndex;
  final bool showTimestamp;
  final bool renderMarkdown;

  const _TurnBubble({
    required this.turn,
    required this.turnIndex,
    required this.showTimestamp,
    required this.renderMarkdown,
  });

  Alignment get _alignment => switch (turn.role) {
    DSAiAnalystRole.user => Alignment.centerRight,
    DSAiAnalystRole.assistant => Alignment.centerLeft,
    DSAiAnalystRole.system => Alignment.center,
  };

  CrossAxisAlignment get _crossAxis => switch (turn.role) {
    DSAiAnalystRole.user => CrossAxisAlignment.end,
    DSAiAnalystRole.assistant => CrossAxisAlignment.start,
    DSAiAnalystRole.system => CrossAxisAlignment.center,
  };

  Color get _roleColor => switch (turn.role) {
    DSAiAnalystRole.user => DSColors.accentViolet,
    DSAiAnalystRole.assistant =>
      turn.isError ? DSColors.statusError : DSColors.accentCyan,
    DSAiAnalystRole.system => DSColors.textTertiary,
  };

  Color get _bubbleFill => switch (turn.role) {
    DSAiAnalystRole.user => DSColors.accentViolet.withValues(alpha: 0.10),
    DSAiAnalystRole.assistant =>
      turn.isError
          ? DSColors.statusError.withValues(alpha: 0.08)
          : DSColors.obsidianElevated,
    DSAiAnalystRole.system => DSColors.obsidianBase,
  };

  Color get _bubbleBorder => switch (turn.role) {
    DSAiAnalystRole.user => DSColors.accentViolet.withValues(alpha: 0.35),
    DSAiAnalystRole.assistant =>
      turn.isError
          ? DSColors.statusError.withValues(alpha: 0.45)
          : DSColors.borderSubtle,
    DSAiAnalystRole.system => DSColors.borderSubtle.withValues(alpha: 0.6),
  };

  @override
  Widget build(BuildContext context) {
    final timeLabel = showTimestamp && turn.timestamp != null
        ? _formatTimestamp(turn.timestamp!)
        : null;

    final semanticsLabel = StringBuffer()
      ..write('Turn $turnIndex, ${turn.displayAuthor}');
    if (turn.isStreaming) {
      semanticsLabel.write(', streaming');
    } else if (turn.isError) {
      semanticsLabel.write(', error');
    }
    if (timeLabel != null) {
      semanticsLabel.write(', $timeLabel');
    }

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: semanticsLabel.toString(),
      child: Align(
        alignment: _alignment,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth * 0.88;
            return ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Column(
                crossAxisAlignment: _crossAxis,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _TurnMeta(
                    author: turn.displayAuthor,
                    roleLabel: turn.roleLabel,
                    roleColor: _roleColor,
                    timestampLabel: timeLabel,
                    alignEnd: turn.role == DSAiAnalystRole.user,
                    status: turn.status,
                  ),
                  const SizedBox(height: DSSpacing.xs),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: _bubbleFill,
                      borderRadius: BorderRadius.circular(DSRadii.lg),
                      border: Border.all(color: _bubbleBorder),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(DSSpacing.md),
                      child: _buildBody(context),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (turn.isStreaming) {
      final reduceMotion = MediaQuery.disableAnimationsOf(context);
      return Semantics(
        key: DSAiAnalystPanel.streamingKey,
        label: DSAiAnalystPanel.streamingSemanticLabel,
        child: Row(
          children: [
            if (reduceMotion)
              const Icon(
                Icons.hourglass_top_rounded,
                size: 14,
                color: DSColors.accentCyan,
              )
            else
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: DSColors.accentCyan,
                ),
              ),
            const SizedBox(width: DSSpacing.sm),
            Expanded(
              child: Text(
                'Analyst is preparing a reply…',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: DSTypography.bodySmall.copyWith(
                  color: DSColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (turn.isError) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline,
            size: 16,
            color: DSColors.statusError,
          ),
          const SizedBox(width: DSSpacing.sm),
          Expanded(
            child: DSText.bodyMedium(
              turn.hasContent ? turn.content : 'Analyst error',
              color: DSColors.statusError,
            ),
          ),
        ],
      );
    }

    if (!turn.hasContent) {
      return const SizedBox.shrink();
    }

    if (renderMarkdown && turn.role != DSAiAnalystRole.user) {
      return DSMarkdownRenderer(data: turn.content);
    }
    return DSText.bodyMedium(turn.content, color: DSColors.textPrimary);
  }

  static String _formatTimestamp(DateTime ts) {
    final local = ts.toLocal();
    final h = local.hour.toString().padLeft(2, '0');
    final m = local.minute.toString().padLeft(2, '0');
    final s = local.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}

class _TurnMeta extends StatelessWidget {
  final String author;
  final String roleLabel;
  final Color roleColor;
  final String? timestampLabel;
  final bool alignEnd;
  final DSAiAnalystTurnStatus status;

  const _TurnMeta({
    required this.author,
    required this.roleLabel,
    required this.roleColor,
    required this.alignEnd,
    required this.status,
    this.timestampLabel,
  });

  @override
  Widget build(BuildContext context) {
    final badgeLabel = switch (status) {
      DSAiAnalystTurnStatus.streaming => 'Streaming',
      DSAiAnalystTurnStatus.error => 'Error',
      DSAiAnalystTurnStatus.complete => roleLabel,
    };

    final icon = Icon(
      switch (status) {
        DSAiAnalystTurnStatus.error => Icons.error_outline,
        DSAiAnalystTurnStatus.streaming => Icons.hourglass_top,
        DSAiAnalystTurnStatus.complete => Icons.circle,
      },
      size: status == DSAiAnalystTurnStatus.complete ? 8 : 14,
      color: roleColor,
    );

    final authorText = Text(
      author,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: DSTypography.labelSmall.copyWith(color: DSColors.textSecondary),
    );

    final badge = DSBadge(
      label: badgeLabel,
      color: roleColor,
      size: DSBadgeSize.small,
      semanticLabel: 'Role $badgeLabel',
    );

    final timeText = timestampLabel == null
        ? null
        : Text(
            timestampLabel!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: DSTypography.labelSmall.copyWith(
              color: DSColors.textTertiary,
            ),
          );

    // Stretch to parent bubble width so Flexible can ellipsize under tight
    // constraints (narrow gallery/test hosts).
    final children = <Widget>[
      icon,
      const SizedBox(width: DSSpacing.xs),
      Flexible(child: authorText),
      const SizedBox(width: DSSpacing.sm),
      badge,
      if (timeText != null) ...[const SizedBox(width: DSSpacing.sm), timeText],
    ];

    return Row(
      mainAxisSize: MainAxisSize.max,
      children: alignEnd ? children.reversed.toList() : children,
    );
  }
}

class _ComposerBar extends StatelessWidget {
  final bool enabled;
  final bool busy;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final String sendSemanticLabel;
  final VoidCallback onSend;

  const _ComposerBar({
    required this.enabled,
    required this.busy,
    required this.controller,
    required this.focusNode,
    required this.hint,
    required this.sendSemanticLabel,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      key: DSAiAnalystPanel.composerKey,
      container: true,
      label: 'Message composer',
      child: Padding(
        padding: const EdgeInsets.all(DSSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: DSColors.obsidianElevated,
                    borderRadius: BorderRadius.circular(DSRadii.input),
                    border: Border.all(color: DSColors.borderSubtle),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DSSpacing.md,
                    ),
                    child: Semantics(
                      textField: true,
                      label: DSAiAnalystPanel.composerFieldSemanticLabel,
                      child: TextField(
                        key: DSAiAnalystPanel.composerFieldKey,
                        controller: controller,
                        focusNode: focusNode,
                        enabled: enabled,
                        minLines: 1,
                        maxLines: 4,
                        style: DSTypography.bodyMedium.copyWith(
                          color: DSColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: hint,
                          hintStyle: DSTypography.bodyMedium.copyWith(
                            color: DSColors.textTertiary,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                        ),
                        textInputAction: TextInputAction.send,
                        onSubmitted: enabled ? (_) => onSend() : null,
                        inputFormatters: const <TextInputFormatter>[],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: DSSpacing.sm),
            DecoratedBox(
              decoration: BoxDecoration(
                color: enabled
                    ? DSColors.accentCyan.withValues(alpha: 0.15)
                    : DSColors.obsidianHover,
                borderRadius: BorderRadius.circular(DSRadii.md),
                border: Border.all(
                  color: enabled
                      ? DSColors.accentCyan.withValues(alpha: 0.45)
                      : DSColors.borderSubtle,
                ),
              ),
              child: IconButton(
                key: DSAiAnalystPanel.sendButtonKey,
                tooltip: sendSemanticLabel,
                onPressed: enabled ? onSend : null,
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                icon: busy
                    ? (MediaQuery.disableAnimationsOf(context)
                          ? const Icon(
                              Icons.hourglass_top_rounded,
                              size: 18,
                              color: DSColors.accentCyan,
                            )
                          : const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: DSColors.accentCyan,
                              ),
                            ))
                    : Icon(
                        Icons.send_rounded,
                        size: 20,
                        color: enabled
                            ? DSColors.accentCyan
                            : DSColors.textTertiary,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
