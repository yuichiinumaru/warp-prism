/// Composer organism model (Task 1866, F-18 — EXPERIMENTAL).
///
/// Pure descriptors + deterministic helpers + the in-memory draft store +
/// seeded fixtures for the reusable message composer organism.
///
/// What this model owns: draft text with an explicit caret offset, @mention
/// descriptors with query extraction, emoji/format insertion helpers,
/// attachment lifecycle states (picked → uploading → ready, with fail/park
/// branches), and parked-draft persistence **in memory only** with restore.
///
/// What this model never does: no backend, no durable store (drafts live in
/// a caller-visible in-memory map; durable persistence stays product-local —
/// no SQLite, no IO imports per layer contracts B4/B5), no domain types
/// (comments / annotations / operator notes stay consumer-side; Prism takes
/// injected descriptors), no wall-clock, no timers, no randomness.
///
/// Anchors (Warpblade comments, Tempest annotations, Command-center operator
/// notes) are forthcoming product surfaces — this seam ships EXPERIMENTAL
/// and promotes on second-host adoption. No host proof is claimed here.
///
/// Lifecycle: EXPERIMENTAL. Intentionally **not** exported from any barrel
/// and without a `Prism*` alias until the promotion task wires the public
/// surface (layer-contracts §9).
library;

/// Lifecycle position of one composer attachment.
///
/// `parked` is the donor H8 `parked` map carried into Prism vocabulary:
/// files picked while the composer box existed whose box was destroyed
/// before upload finished. The next composer on the same draft key takes
/// them back as they were (restored as [picked], never auto-uploaded).
enum DSComposerAttachmentState {
  /// Chosen, not yet uploading. Determinate, non-terminal.
  picked,

  /// Upload in flight. Progress arrives injected (caller-driven fake);
  /// the model never advances it.
  uploading,

  /// Upload complete. Sendable.
  ready,

  /// Upload failed. Carries the caller-provided sanitized reason.
  failed,

  /// Parked across box destruction. Restored verbatim, never auto-uploaded.
  parked,
}

/// Fail-closed presentation helpers for [DSComposerAttachmentState].
extension DSComposerAttachmentStateInfo on DSComposerAttachmentState {
  /// True only for [DSComposerAttachmentState.ready]. Only ready
  /// attachments are attached to the send payload.
  bool get isSendable => this == DSComposerAttachmentState.ready;

  /// True while the attachment still needs caller action or time
  /// (picked / uploading / parked). Failed is terminal-with-retry.
  bool get isPending => switch (this) {
    DSComposerAttachmentState.picked ||
    DSComposerAttachmentState.uploading ||
    DSComposerAttachmentState.parked => true,
    DSComposerAttachmentState.ready ||
    DSComposerAttachmentState.failed => false,
  };

  /// Screen-reader fragment for this state. Claims nothing beyond the
  /// state; progress and reasons are appended by the owner.
  String get semanticLabel => switch (this) {
    DSComposerAttachmentState.picked => 'Attachment picked, waiting to upload',
    DSComposerAttachmentState.uploading => 'Attachment uploading',
    DSComposerAttachmentState.ready => 'Attachment ready to send',
    DSComposerAttachmentState.failed => 'Attachment failed',
    DSComposerAttachmentState.parked =>
      'Attachment parked, restored with draft',
  };
}

/// One composer attachment descriptor.
///
/// Consumer-owned bytes stay consumer-side — Prism owns the lifecycle slot
/// chrome, never the payload. [progress] is clamped to `0.0..1.0` at
/// construction; [errorDetail] is caller-provided sanitized copy only
/// (never exception strings or daemon internals).
class DSComposerAttachment {
  /// Stable id within one composer session (caller-provided).
  final String id;

  /// Human-readable file label (caller-provided, e.g. `take-03.wav`).
  final String label;

  /// Lifecycle position.
  final DSComposerAttachmentState state;

  /// Fractional upload completion. Meaningful only for [uploading].
  final double progress;

  /// Caller-provided failure reason. Meaningful only for [failed].
  final String? errorDetail;

  /// Creates an attachment. [progress] is clamped to `0.0..1.0`.
  const DSComposerAttachment({
    required this.id,
    required this.label,
    this.state = DSComposerAttachmentState.picked,
    double progress = 0.0,
    this.errorDetail,
  }) : progress = progress < 0.0 ? 0.0 : (progress > 1.0 ? 1.0 : progress);

  /// Returns a copy with overridden fields.
  DSComposerAttachment copyWith({
    String? id,
    String? label,
    DSComposerAttachmentState? state,
    double? progress,
    String? errorDetail,
    bool clearErrorDetail = false,
  }) {
    return DSComposerAttachment(
      id: id ?? this.id,
      label: label ?? this.label,
      state: state ?? this.state,
      progress: progress ?? this.progress,
      errorDetail: clearErrorDetail ? null : (errorDetail ?? this.errorDetail),
    );
  }

  /// Screen-reader announcement for this attachment: label, state, and
  /// (for uploading) the fixed percent or (for failed) the caller reason.
  /// Progress and state are never colour-only.
  String get announcement {
    final buffer = StringBuffer('$label. ${state.semanticLabel}.');
    if (state == DSComposerAttachmentState.uploading) {
      buffer.write(' ${(progress.clamp(0.0, 1.0) * 100).round()} percent.');
    }
    final reason = errorDetail;
    if (state == DSComposerAttachmentState.failed &&
        reason != null &&
        reason.trim().isNotEmpty) {
      buffer.write(' ${reason.trim()}.');
    }
    return buffer.toString();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DSComposerAttachment &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          label == other.label &&
          state == other.state &&
          progress == other.progress &&
          errorDetail == other.errorDetail;

  @override
  int get hashCode => Object.hash(id, label, state, progress, errorDetail);

  @override
  String toString() =>
      'DSComposerAttachment($id, $label, $state, ${(progress * 100).round()}%)';
}

/// One @mention candidate descriptor.
///
/// Injected by the consumer (Warpblade members, Tempest annotators,
/// Command-center operators stay product-local models; Prism receives only
/// these descriptors and resolves queries against them headlessly).
class DSComposerMention {
  /// Stable candidate id (consumer-provided).
  final String id;

  /// Display label inserted into the draft (without the `@` prefix).
  final String displayLabel;

  /// Optional secondary detail (handle, role). Rendered verbatim.
  final String? detail;

  const DSComposerMention({
    required this.id,
    required this.displayLabel,
    this.detail,
  });

  /// Token inserted into the draft when this candidate is picked.
  String get insertionToken => '@$displayLabel ';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DSComposerMention &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          displayLabel == other.displayLabel &&
          detail == other.detail;

  @override
  int get hashCode => Object.hash(id, displayLabel, detail);

  @override
  String toString() => 'DSComposerMention($id, $displayLabel)';
}

/// Inline format operations offered by the composer format bar.
enum DSComposerFormat {
  /// Wraps the selection in `**…**`.
  bold,

  /// Wraps the selection in `*…*`.
  italic,

  /// Wraps the selection in `~~…~~`.
  strikethrough,

  /// Wraps the selection in `` `…` ``.
  code,

  /// Wraps the selection in a fenced ` ``` ` block.
  codeBlock,

  /// Prefixes each selected line with `> `.
  quote,

  /// Wraps the selection as `[…]()`, caret placed inside the parens.
  link,
}

/// Extracts the `@mention` query token immediately before [caret].
///
/// Returns the query text after `@` (possibly empty, meaning "show all"),
/// or `null` when no mention token is open at the caret. Matching is
/// deterministic: the nearest `@` before the caret whose preceding char is
/// start-of-text or whitespace, with only `[A-Za-z0-9_.-]` between it and
/// the caret.
String? extractMentionQuery(String text, int caret) {
  final safeCaret = caret.clamp(0, text.length);
  final before = text.substring(0, safeCaret);
  final at = before.lastIndexOf('@');
  if (at < 0) return null;
  if (at > 0) {
    final previous = before[at - 1];
    if (previous != ' ' &&
        previous != '\n' &&
        previous != '\t' &&
        previous != '(') {
      return null;
    }
  }
  final query = before.substring(at + 1);
  if (query.contains(' ') || query.contains('\n') || query.contains('\t')) {
    return null;
  }
  if (!RegExp(r'^[A-Za-z0-9_.-]*$').hasMatch(query)) return null;
  return query;
}

/// Filters injected mention [candidates] against [query] (case-insensitive
/// substring on [DSComposerMention.displayLabel]). An empty query returns
/// every candidate in order; the widget caps visible rows.
List<DSComposerMention> filterComposerMentions(
  List<DSComposerMention> candidates,
  String query,
) {
  if (query.isEmpty) return List.of(candidates);
  final lowered = query.toLowerCase();
  return candidates
      .where((c) => c.displayLabel.toLowerCase().contains(lowered))
      .toList(growable: false);
}

/// Applies [format] to the `[start, end)` range of [text].
///
/// Returns the new text plus the caret range selecting the formatted region
/// (so the operation is repeatable and testable headlessly). Offsets are
/// clamped; an inverted range throws [RangeError]. A collapsed range
/// inserts empty markers and places the caret between them.
({String text, int caretStart, int caretEnd}) applyComposerFormat({
  required String text,
  required int start,
  required int end,
  required DSComposerFormat format,
}) {
  final safeStart = start.clamp(0, text.length);
  final safeEnd = end.clamp(0, text.length);
  if (safeStart > safeEnd) {
    throw RangeError('Composer format range is inverted: $start > $end.');
  }
  final before = text.substring(0, safeStart);
  final selected = text.substring(safeStart, safeEnd);
  final after = text.substring(safeEnd);

  ({String text, int caretStart, int caretEnd}) wrap(
    String open,
    String close,
  ) {
    final next = '$before$open$selected$close$after';
    return (
      text: next,
      caretStart: safeStart + open.length,
      caretEnd: safeStart + open.length + selected.length,
    );
  }

  switch (format) {
    case DSComposerFormat.bold:
      return wrap('**', '**');
    case DSComposerFormat.italic:
      return wrap('*', '*');
    case DSComposerFormat.strikethrough:
      return wrap('~~', '~~');
    case DSComposerFormat.code:
      return wrap('`', '`');
    case DSComposerFormat.codeBlock:
      return wrap('```\n', '\n```');
    case DSComposerFormat.quote:
      if (selected.isEmpty) {
        final lineStart = before.lastIndexOf('\n') + 1;
        final head = text.substring(0, lineStart);
        final tail = text.substring(lineStart);
        final next = '$head> $tail';
        final caret = safeStart + 2;
        return (text: next, caretStart: caret, caretEnd: caret);
      }
      final quoted = selected.split('\n').map((line) => '> $line').join('\n');
      final next = '$before$quoted$after';
      return (
        text: next,
        caretStart: safeStart,
        caretEnd: safeStart + quoted.length,
      );
    case DSComposerFormat.link:
      if (selected.isEmpty) {
        const open = '[';
        const close = ']()';
        final next = '$before$open$close$after';
        final caret = safeStart + open.length;
        return (text: next, caretStart: caret, caretEnd: caret);
      }
      final next = '$before[$selected]()$after';
      final caret = safeStart + selected.length + 3;
      return (text: next, caretStart: caret, caretEnd: caret);
  }
}

/// Inserts [emoji] at [caret], returning the new text and collapsed caret.
///
/// The emoji palette is caller-injected ([DSComposerFake.referenceEmojis]);
/// Prism inserts the grapheme verbatim and never interprets it.
({String text, int caret}) insertComposerEmoji({
  required String text,
  required int caret,
  required String emoji,
}) {
  final safeCaret = caret.clamp(0, text.length);
  final next =
      '${text.substring(0, safeCaret)}$emoji${text.substring(safeCaret)}';
  final nextCaret = safeCaret + emoji.length;
  return (text: next, caret: nextCaret);
}

/// One parked composer draft: text plus the caret offset plus the
/// attachment descriptors as they were. In-memory only — durable
/// persistence stays product-local.
class DSComposerDraft {
  /// Draft body.
  final String text;

  /// Caret offset restored verbatim (clamped to [text] on restore).
  final int caretOffset;

  /// Attachment descriptors as they were when parked.
  final List<DSComposerAttachment> attachments;

  const DSComposerDraft({
    this.text = '',
    this.caretOffset = 0,
    this.attachments = const [],
  });

  /// Empty draft (nothing to restore).
  bool get isEmpty => text.isEmpty && caretOffset == 0 && attachments.isEmpty;

  /// Returns a copy with overridden fields.
  DSComposerDraft copyWith({
    String? text,
    int? caretOffset,
    List<DSComposerAttachment>? attachments,
  }) {
    return DSComposerDraft(
      text: text ?? this.text,
      caretOffset: caretOffset ?? this.caretOffset,
      attachments: attachments ?? this.attachments,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DSComposerDraft &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          caretOffset == other.caretOffset &&
          _attachmentsEqual(attachments, other.attachments);

  @override
  int get hashCode =>
      Object.hash(text, caretOffset, Object.hashAll(attachments));

  @override
  String toString() =>
      'DSComposerDraft(${text.length} chars @ $caretOffset, '
      '${attachments.length} attachments)';

  static bool _attachmentsEqual(
    List<DSComposerAttachment> a,
    List<DSComposerAttachment> b,
  ) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// In-memory parked-draft store (Task 1866, F-18).
///
/// Synchronous map keyed by caller draft key (conversation id). Parking
/// converts in-flight attachments (`picked`, `uploading`) to `parked` and
/// keeps terminal descriptors (`ready`, `failed`) verbatim; restoring
/// converts `parked` back to `picked` (never auto-uploads) and clamps the
/// caret into the text. No IO, no timers, fully deterministic.
class DSComposerDraftStore {
  final Map<String, DSComposerDraft> _drafts = {};

  /// Parks [draft] under [key], converting in-flight attachments to parked.
  ///
  /// An empty draft clears the key instead of storing it.
  void parkDraft(String key, DSComposerDraft draft) {
    if (draft.isEmpty) {
      _drafts.remove(key);
      return;
    }
    _drafts[key] = DSComposerDraft(
      text: draft.text,
      caretOffset: draft.caretOffset,
      attachments: [
        for (final attachment in draft.attachments)
          switch (attachment.state) {
            DSComposerAttachmentState.picked ||
            DSComposerAttachmentState.uploading => attachment.copyWith(
              state: DSComposerAttachmentState.parked,
            ),
            DSComposerAttachmentState.ready ||
            DSComposerAttachmentState.failed ||
            DSComposerAttachmentState.parked => attachment,
          },
      ],
    );
  }

  /// Restores the draft parked under [key], or `null` when no draft exists.
  ///
  /// Parked attachments come back as `picked`; the caret is clamped into
  /// the text. Restoring never mutates the stored draft.
  DSComposerDraft? restoreDraft(String key) {
    final stored = _drafts[key];
    if (stored == null) return null;
    return DSComposerDraft(
      text: stored.text,
      caretOffset: stored.caretOffset.clamp(0, stored.text.length),
      attachments: [
        for (final attachment in stored.attachments)
          attachment.state == DSComposerAttachmentState.parked
              ? attachment.copyWith(state: DSComposerAttachmentState.picked)
              : attachment,
      ],
    );
  }

  /// Discards the draft parked under [key], if any.
  void discardDraft(String key) => _drafts.remove(key);

  /// True when a draft is parked under [key].
  bool hasDraft(String key) => _drafts.containsKey(key);

  /// Parked draft keys in insertion order.
  List<String> get keys => List.unmodifiable(_drafts.keys);
}

/// Outgoing composer payload: trimmed body plus the resolved mention ids
/// plus the ids of `ready` attachments. Never carries bytes.
class DSComposerSendPayload {
  /// Trimmed draft body.
  final String text;

  /// Mention candidate ids resolved from the body, in order.
  final List<String> mentionIds;

  /// Ids of attachments in [DSComposerAttachmentState.ready].
  final List<String> attachmentIds;

  const DSComposerSendPayload({
    required this.text,
    this.mentionIds = const [],
    this.attachmentIds = const [],
  });

  @override
  String toString() =>
      'DSComposerSendPayload(${text.length} chars, '
      '${mentionIds.length} mentions, ${attachmentIds.length} attachments)';
}

/// Seeded fixtures for the composer seam (gallery + tests + demos).
///
/// Fixed caller-side content only: member descriptors, emoji palette,
/// attachment samples in every lifecycle state, and one reference draft.
/// Nothing here animates, advances, or persists.
class DSComposerFake {
  const DSComposerFake._();

  /// Fixed mention candidates (consumer-shaped descriptors, local only).
  static List<DSComposerMention> referenceMentions() => const [
    DSComposerMention(
      id: 'member-ada',
      displayLabel: 'ada',
      detail: '@ada · ops',
    ),
    DSComposerMention(
      id: 'member-grace',
      displayLabel: 'grace',
      detail: '@grace · review',
    ),
    DSComposerMention(
      id: 'member-linus',
      displayLabel: 'linus',
      detail: '@linus · annotations',
    ),
  ];

  /// Fixed emoji palette (verbatim graphemes, never interpreted).
  static List<String> referenceEmojis() => const ['👍', '🎯', '🔥', '✅', '👀'];

  /// Fixed attachment samples covering every lifecycle state.
  static List<DSComposerAttachment> referenceAttachments() => const [
    DSComposerAttachment(
      id: 'att-pick-1',
      label: 'take-04.wav',
      state: DSComposerAttachmentState.picked,
    ),
    DSComposerAttachment(
      id: 'att-up-1',
      label: 'stems-04.zip',
      state: DSComposerAttachmentState.uploading,
      progress: 0.5,
    ),
    DSComposerAttachment(
      id: 'att-ready-1',
      label: 'notes.md',
      state: DSComposerAttachmentState.ready,
    ),
    DSComposerAttachment(
      id: 'att-fail-1',
      label: 'render-04.mp4',
      state: DSComposerAttachmentState.failed,
      errorDetail: 'Chunk 3 rejected by the ingest gate',
    ),
    DSComposerAttachment(
      id: 'att-park-1',
      label: 'parked-take-02.wav',
      state: DSComposerAttachmentState.parked,
    ),
  ];

  /// Fixed reference draft (gallery + golden capture only).
  static DSComposerDraft referenceDraft() => const DSComposerDraft(
    text: 'Reviewing take 04 with @ada 👍',
    caretOffset: 30,
    attachments: [
      DSComposerAttachment(
        id: 'att-ready-1',
        label: 'notes.md',
        state: DSComposerAttachmentState.ready,
      ),
    ],
  );
}
