import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Speaker role for a single turn in [DSAgentTranscript].
///
/// **Boundary**: chat multi-role turns only. Not terminal/session line roles
/// (EPIC-15 agent shell) and not log severity ( [DSLogViewer] ).
enum DSAgentRole {
  /// Human / operator prompt.
  user,

  /// Model / agent response.
  assistant,

  /// System / policy / harness notice.
  system,
}

/// Typed content block inside a [DSAgentMessage].
///
/// Start with [text]; [think] and [plan] are stub-rendered placeholders so
/// Task 1605 (tool-call / status) and richer reasoning UI can land later.
/// Use [custom] for pre-built widgets (e.g. future tool-call cards).
enum DSAgentMessageBlockType {
  /// Primary prose (optionally markdown-rendered by the transcript).
  text,

  /// Reasoning / chain-of-thought placeholder (collapsed chrome by default).
  think,

  /// Multi-step plan placeholder.
  plan,

  /// Escape hatch: embed an arbitrary widget (extension for Task 1605+).
  custom,
}

/// One typed block inside a [DSAgentMessage].
@immutable
class DSAgentMessageBlock {
  /// Discriminator for the block renderer.
  final DSAgentMessageBlockType type;

  /// Text payload for [text], [think], and [plan] blocks.
  final String? text;

  /// Prebuilt child for [custom] blocks (tool-call cards, status strips, …).
  final Widget? child;

  /// Optional label override (e.g. "Thinking", "Plan step 1").
  final String? label;

  /// Primary text / markdown content block.
  const DSAgentMessageBlock.text(String this.text, {this.label})
    : type = DSAgentMessageBlockType.text,
      child = null;

  /// Reasoning / think stub block.
  const DSAgentMessageBlock.think(String this.text, {this.label})
    : type = DSAgentMessageBlockType.think,
      child = null;

  /// Plan stub block.
  const DSAgentMessageBlock.plan(String this.text, {this.label})
    : type = DSAgentMessageBlockType.plan,
      child = null;

  /// Custom widget slot (extension point for Task 1605 tool-call cards, etc.).
  const DSAgentMessageBlock.custom(Widget this.child, {this.label})
    : type = DSAgentMessageBlockType.custom,
      text = null;

  /// Whether this block carries non-empty text.
  bool get hasText => text != null && text!.isNotEmpty;

  /// Whether this block carries a custom child widget.
  bool get hasChild => child != null;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DSAgentMessageBlock &&
        other.type == type &&
        other.text == text &&
        other.label == label &&
        // Widget identity is intentional for custom slots.
        identical(other.child, child);
  }

  @override
  int get hashCode => Object.hash(type, text, label, child);
}

/// Immutable multi-block message (one conversation turn).
///
/// Contract:
/// - [id] unique within a transcript instance.
/// - [role] drives alignment, badge color, and semantics.
/// - [blocks] non-empty for meaningful turns; empty is tolerated (renders
///   role chrome only).
/// - [timestamp] optional; shown only when the transcript enables timestamps.
/// - [authorLabel] optional display name override (defaults to role label).
@immutable
class DSAgentMessage {
  /// Stable unique id within a transcript.
  final String id;

  /// Speaker role.
  final DSAgentRole role;

  /// Ordered content blocks for this turn.
  final List<DSAgentMessageBlock> blocks;

  /// Optional event time (fixture or host-provided).
  final DateTime? timestamp;

  /// Optional display name override (e.g. agent persona).
  final String? authorLabel;

  const DSAgentMessage({
    required this.id,
    required this.role,
    this.blocks = const <DSAgentMessageBlock>[],
    this.timestamp,
    this.authorLabel,
  });

  /// Convenience: single text block message.
  factory DSAgentMessage.text({
    required String id,
    required DSAgentRole role,
    required String text,
    DateTime? timestamp,
    String? authorLabel,
  }) {
    return DSAgentMessage(
      id: id,
      role: role,
      timestamp: timestamp,
      authorLabel: authorLabel,
      blocks: [DSAgentMessageBlock.text(text)],
    );
  }

  /// Human-readable role name for badges / semantics.
  String get roleLabel => switch (role) {
    DSAgentRole.user => 'User',
    DSAgentRole.assistant => 'Assistant',
    DSAgentRole.system => 'System',
  };

  /// Effective author string (persona or role label).
  String get displayAuthor => authorLabel ?? roleLabel;

  /// Whether any block has text content.
  bool get hasContent => blocks.any((b) => b.hasText || b.hasChild);

  DSAgentMessage copyWith({
    String? id,
    DSAgentRole? role,
    List<DSAgentMessageBlock>? blocks,
    DateTime? timestamp,
    String? authorLabel,
    bool clearTimestamp = false,
    bool clearAuthorLabel = false,
  }) {
    return DSAgentMessage(
      id: id ?? this.id,
      role: role ?? this.role,
      blocks: blocks ?? this.blocks,
      timestamp: clearTimestamp ? null : (timestamp ?? this.timestamp),
      authorLabel: clearAuthorLabel ? null : (authorLabel ?? this.authorLabel),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DSAgentMessage &&
        other.id == id &&
        other.role == role &&
        listEquals(other.blocks, blocks) &&
        other.timestamp == timestamp &&
        other.authorLabel == authorLabel;
  }

  @override
  int get hashCode =>
      Object.hash(id, role, Object.hashAll(blocks), timestamp, authorLabel);
}

/// Shared fixture conversation for gallery + tests (no network).
///
/// Scripted multi-role session: system → user → assistant (think + text) →
/// user → assistant (plan + text). Read-only demo data only.
List<DSAgentMessage> dsAgentTranscriptFixtureMessages({DateTime? anchor}) {
  final t0 = anchor ?? DateTime.utc(2026, 7, 10, 14, 0, 0);
  return [
    DSAgentMessage(
      id: 'msg-sys-1',
      role: DSAgentRole.system,
      timestamp: t0,
      blocks: const [
        DSAgentMessageBlock.text(
          'Session started. Fixture harness — no live model calls.',
        ),
      ],
    ),
    DSAgentMessage(
      id: 'msg-user-1',
      role: DSAgentRole.user,
      timestamp: t0.add(const Duration(seconds: 12)),
      authorLabel: 'Operator',
      blocks: const [
        DSAgentMessageBlock.text(
          'Summarize provider health for OpenAI production accounts.',
        ),
      ],
    ),
    DSAgentMessage(
      id: 'msg-asst-1',
      role: DSAgentRole.assistant,
      timestamp: t0.add(const Duration(seconds: 28)),
      authorLabel: 'Prism Analyst',
      blocks: const [
        DSAgentMessageBlock.think(
          'Need account list, latency SLO, and error rate from fixtures.',
        ),
        DSAgentMessageBlock.text(
          '**OpenAI / main-prod** looks healthy.\n\n'
          '- Latency p95: `182ms`\n'
          '- Error rate: `0.1%`\n'
          '- Models: `gpt-4o`, `o1-mini`\n\n'
          'No critical alerts in the last 15 minutes.',
        ),
      ],
    ),
    DSAgentMessage(
      id: 'msg-user-2',
      role: DSAgentRole.user,
      timestamp: t0.add(const Duration(minutes: 1, seconds: 5)),
      authorLabel: 'Operator',
      blocks: const [
        DSAgentMessageBlock.text(
          'Draft a short remediation plan if Anthropic degrades.',
        ),
      ],
    ),
    DSAgentMessage(
      id: 'msg-asst-2',
      role: DSAgentRole.assistant,
      timestamp: t0.add(const Duration(minutes: 1, seconds: 40)),
      authorLabel: 'Prism Analyst',
      blocks: const [
        DSAgentMessageBlock.plan(
          '1. Confirm degraded status on claude-prod\n'
          '2. Fail over chat routes to OpenAI main-prod\n'
          '3. Page on-call if error rate > 2%',
        ),
        DSAgentMessageBlock.text(
          'Plan ready. This is a **fixture-only** transcript — no actions '
          'were executed against live infrastructure.',
        ),
      ],
    ),
  ];
}
