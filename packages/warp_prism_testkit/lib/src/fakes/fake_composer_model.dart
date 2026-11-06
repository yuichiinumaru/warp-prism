import 'package:meta/meta.dart';

/// Pure-Dart driver for the composer draft/attachment vocabulary
/// (Task 1866, F-18).
///
/// Models one composer session headlessly: draft text with an explicit
/// caret offset, @mention resolution against injected candidate labels,
/// deterministic format/emoji insertion, the attachment lifecycle
/// (picked → uploading → ready, with fail/retry/remove and park/restore
/// branches), in-memory parked-draft persistence, and the screen-reader
/// announcement log.
///
/// Drafts are in-memory only; durable persistence stays product-local.
/// No timers, no wall-clock, no randomness — every transition is
/// synchronous and repeatable.
///
/// Lifecycle: EXPERIMENTAL (see `.project/architecture/layer-contracts.md`).
@experimental
enum FakeComposerAttachmentState {
  /// Chosen, not yet uploading. Determinate, non-terminal.
  picked,

  /// Upload in flight. Progress arrives injected; the model never advances.
  uploading,

  /// Upload complete. Sendable.
  ready,

  /// Upload failed. Carries the caller-provided sanitized reason.
  failed,

  /// Parked across box destruction. Restored verbatim, never auto-uploaded.
  parked,
}

/// Fail-closed presentation contract for [FakeComposerAttachmentState].
@experimental
extension FakeComposerAttachmentStateSemantics on FakeComposerAttachmentState {
  /// True only for [FakeComposerAttachmentState.ready].
  bool get isSendable => this == FakeComposerAttachmentState.ready;

  /// Screen-reader fragment for this state. Claims nothing beyond the state.
  String get semanticLabel => switch (this) {
    FakeComposerAttachmentState.picked =>
      'Attachment picked, waiting to upload',
    FakeComposerAttachmentState.uploading => 'Attachment uploading',
    FakeComposerAttachmentState.ready => 'Attachment ready to send',
    FakeComposerAttachmentState.failed => 'Attachment failed',
    FakeComposerAttachmentState.parked =>
      'Attachment parked, restored with draft',
  };
}

/// One composer attachment descriptor (bytes stay consumer-side).
@experimental
@immutable
class FakeComposerAttachment {
  /// Stable id within one composer session.
  final String id;

  /// Human-readable file label (caller-provided).
  final String label;

  /// Lifecycle position.
  final FakeComposerAttachmentState state;

  /// Fractional upload completion, clamped to `0.0..1.0`.
  final double progress;

  /// Caller-provided failure reason. Meaningful only for [failed].
  final String? errorDetail;

  /// Creates an attachment. [progress] is clamped to `0.0..1.0`.
  const FakeComposerAttachment({
    required this.id,
    required this.label,
    this.state = FakeComposerAttachmentState.picked,
    double progress = 0.0,
    this.errorDetail,
  }) : progress = progress < 0.0 ? 0.0 : (progress > 1.0 ? 1.0 : progress);

  /// Returns a copy with overridden fields.
  FakeComposerAttachment copyWith({
    String? id,
    String? label,
    FakeComposerAttachmentState? state,
    double? progress,
    String? errorDetail,
    bool clearErrorDetail = false,
  }) {
    return FakeComposerAttachment(
      id: id ?? this.id,
      label: label ?? this.label,
      state: state ?? this.state,
      progress: progress ?? this.progress,
      errorDetail: clearErrorDetail ? null : (errorDetail ?? this.errorDetail),
    );
  }

  /// Screen-reader announcement: label, state, and (for uploading) the
  /// fixed percent or (for failed) the caller reason.
  String get announcement {
    final buffer = StringBuffer('$label. ${state.semanticLabel}.');
    if (state == FakeComposerAttachmentState.uploading) {
      buffer.write(' ${(progress.clamp(0.0, 1.0) * 100).round()} percent.');
    }
    final reason = errorDetail;
    if (state == FakeComposerAttachmentState.failed &&
        reason != null &&
        reason.trim().isNotEmpty) {
      buffer.write(' ${reason.trim()}.');
    }
    return buffer.toString();
  }

  @override
  bool operator ==(Object other) =>
      other is FakeComposerAttachment &&
      other.id == id &&
      other.label == label &&
      other.state == state &&
      other.progress == progress &&
      other.errorDetail == errorDetail;

  @override
  int get hashCode => Object.hash(id, label, state, progress, errorDetail);

  @override
  String toString() =>
      'FakeComposerAttachment($id, $label, $state, '
      '${(progress * 100).round()}%)';
}

/// One parked draft: text plus the caret offset plus the attachment
/// descriptors as they were. In-memory only.
@experimental
@immutable
class FakeComposerDraft {
  /// Draft body.
  final String text;

  /// Caret offset restored verbatim (clamped to [text] on restore).
  final int caretOffset;

  /// Attachment descriptors as they were when parked.
  final List<FakeComposerAttachment> attachments;

  const FakeComposerDraft({
    this.text = '',
    this.caretOffset = 0,
    this.attachments = const [],
  });

  /// Empty draft (nothing to restore).
  bool get isEmpty => text.isEmpty && caretOffset == 0 && attachments.isEmpty;
}

/// In-memory parked-draft store: synchronous map keyed by caller draft key.
///
/// Parking converts in-flight attachments (`picked`, `uploading`) to
/// `parked` and keeps terminal descriptors (`ready`, `failed`) verbatim;
/// restoring converts `parked` back to `picked` and clamps the caret.
@experimental
class FakeComposerDraftStore {
  final Map<String, FakeComposerDraft> _drafts = {};

  /// Parks [draft] under [key]. An empty draft clears the key instead.
  void parkDraft(String key, FakeComposerDraft draft) {
    if (draft.isEmpty) {
      _drafts.remove(key);
      return;
    }
    _drafts[key] = FakeComposerDraft(
      text: draft.text,
      caretOffset: draft.caretOffset,
      attachments: [
        for (final attachment in draft.attachments)
          switch (attachment.state) {
            FakeComposerAttachmentState.picked ||
            FakeComposerAttachmentState.uploading => attachment.copyWith(
              state: FakeComposerAttachmentState.parked,
            ),
            FakeComposerAttachmentState.ready ||
            FakeComposerAttachmentState.failed ||
            FakeComposerAttachmentState.parked => attachment,
          },
      ],
    );
  }

  /// Restores the draft parked under [key], or `null` when absent.
  FakeComposerDraft? restoreDraft(String key) {
    final stored = _drafts[key];
    if (stored == null) return null;
    return FakeComposerDraft(
      text: stored.text,
      caretOffset: stored.caretOffset.clamp(0, stored.text.length),
      attachments: [
        for (final attachment in stored.attachments)
          attachment.state == FakeComposerAttachmentState.parked
              ? attachment.copyWith(state: FakeComposerAttachmentState.picked)
              : attachment,
      ],
    );
  }

  /// Discards the draft parked under [key], if any.
  void discardDraft(String key) => _drafts.remove(key);

  /// True when a draft is parked under [key].
  bool hasDraft(String key) => _drafts.containsKey(key);
}

/// In-memory deterministic composer driver for testing.
///
/// Owns draft text + caret, mention candidates (plain labels), the
/// attachment list, the parked-draft store, and the screen-reader
/// announcement log. Every transition is synchronous; illegal transitions
/// throw [StateError].
///
/// Lifecycle: EXPERIMENTAL (see `.project/architecture/layer-contracts.md`).
@experimental
class FakeComposerModel {
  FakeComposerModel({
    required this.store,
    required this.draftKey,
    List<String> mentionCandidates = const [],
  }) : _mentionCandidates = List.of(mentionCandidates);

  /// In-memory parked-draft store (caller-owned lifetime).
  final FakeComposerDraftStore store;

  /// Key this composer parks under.
  final String draftKey;

  final List<String> _mentionCandidates;
  final List<FakeComposerAttachment> _attachments = [];
  final List<String> _announcements = [];

  String _text = '';
  int _caret = 0;

  /// Current draft body.
  String get text => _text;

  /// Current collapsed caret offset.
  int get caret => _caret;

  /// Ordered attachment snapshots (unmodifiable).
  List<FakeComposerAttachment> get attachments =>
      List.unmodifiable(_attachments);

  /// Screen-reader announcement log (append-only, deterministic).
  List<String> get announcements => List.unmodifiable(_announcements);

  /// True when a send would carry content: non-blank text or at least one
  /// `ready` attachment.
  bool get canSend =>
      _text.trim().isNotEmpty ||
      _attachments.any((a) => a.state == FakeComposerAttachmentState.ready);

  /// Replaces the body and places a collapsed caret at [caret].
  void setTextAndCaret(String value, int caret) {
    _text = value;
    _caret = caret.clamp(0, value.length);
  }

  /// Inserts [insertion] at the caret.
  void insertAtCaret(String insertion) {
    _text =
        '${_text.substring(0, _caret)}$insertion'
        '${_text.substring(_caret)}';
    _caret += insertion.length;
  }

  /// Resolves the `@mention` query token immediately before the caret.
  ///
  /// Returns the query after `@` (possibly empty), or `null` when no
  /// mention token is open at the caret.
  String? mentionQuery() {
    final before = _text.substring(0, _caret);
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

  /// Filters the injected candidates against [query] (case-insensitive
  /// substring). An empty query returns every candidate in order.
  List<String> filterMentions(String query) {
    if (query.isEmpty) return List.of(_mentionCandidates);
    final lowered = query.toLowerCase();
    return _mentionCandidates
        .where((c) => c.toLowerCase().contains(lowered))
        .toList(growable: false);
  }

  /// Replaces the open `@query` token before the caret with `@candidate `.
  ///
  /// Throws [StateError] when no mention token is open at the caret.
  void insertMention(String candidate) {
    final query = mentionQuery();
    if (query == null) {
      throw StateError(
        'FakeComposerModel: no open mention token at caret $_caret.',
      );
    }
    final at = _caret - query.length - 1;
    final token = '@$candidate ';
    _text = '${_text.substring(0, at)}$token${_text.substring(_caret)}';
    _caret = at + token.length;
  }

  /// Adds an attachment descriptor. Throws [StateError] on duplicate id.
  void attach(FakeComposerAttachment attachment) {
    if (_attachments.any((a) => a.id == attachment.id)) {
      throw StateError(
        'FakeComposerModel: duplicate attachment id ${attachment.id}.',
      );
    }
    _attachments.add(attachment);
    _announcements.add(attachment.announcement);
  }

  FakeComposerAttachment _require(String id) {
    for (final attachment in _attachments) {
      if (attachment.id == id) return attachment;
    }
    throw StateError('FakeComposerModel: unknown attachment id $id.');
  }

  void _replace(FakeComposerAttachment next) {
    final index = _attachments.indexWhere((a) => a.id == next.id);
    _attachments[index] = next;
  }

  /// Marks a `picked` or `failed` attachment `uploading` at zero progress.
  void startUpload(String id) {
    final current = _require(id);
    if (current.state != FakeComposerAttachmentState.picked &&
        current.state != FakeComposerAttachmentState.failed) {
      throw StateError(
        'FakeComposerModel: cannot start upload from ${current.state} '
        '(${current.id}).',
      );
    }
    final next = current.copyWith(
      state: FakeComposerAttachmentState.uploading,
      progress: 0.0,
      clearErrorDetail: true,
    );
    _replace(next);
    _announcements.add(next.announcement);
  }

  /// Sets injected upload progress for an `uploading` attachment.
  void setProgress(String id, double value) {
    final current = _require(id);
    if (current.state != FakeComposerAttachmentState.uploading) {
      throw StateError(
        'FakeComposerModel: progress requires uploading state '
        '(${current.id} is ${current.state}).',
      );
    }
    final next = current.copyWith(progress: value);
    _replace(next);
    _announcements.add(next.announcement);
  }

  /// Marks an `uploading` attachment `ready`.
  void markReady(String id) {
    final current = _require(id);
    if (current.state != FakeComposerAttachmentState.uploading) {
      throw StateError(
        'FakeComposerModel: ready requires uploading state '
        '(${current.id} is ${current.state}).',
      );
    }
    final next = current.copyWith(
      state: FakeComposerAttachmentState.ready,
      progress: 1.0,
    );
    _replace(next);
    _announcements.add(next.announcement);
  }

  /// Marks an attachment `failed` with a caller-provided sanitized reason.
  void fail(String id, {String? reason}) {
    final current = _require(id);
    final next = current.copyWith(
      state: FakeComposerAttachmentState.failed,
      errorDetail: reason,
    );
    _replace(next);
    _announcements.add(next.announcement);
  }

  /// Retries a `failed` attachment: back to `uploading` at zero progress.
  void retry(String id) {
    final current = _require(id);
    if (current.state != FakeComposerAttachmentState.failed) {
      throw StateError(
        'FakeComposerModel: retry requires failed state '
        '(${current.id} is ${current.state}).',
      );
    }
    final next = current.copyWith(
      state: FakeComposerAttachmentState.uploading,
      progress: 0.0,
      clearErrorDetail: true,
    );
    _replace(next);
    _announcements.add(next.announcement);
  }

  /// Removes an attachment descriptor.
  void remove(String id) {
    final current = _require(id);
    _attachments.removeWhere((a) => a.id == id);
    _announcements.add('${current.label}. Attachment removed.');
  }

  /// Outgoing payload preview: trimmed body plus the ids of `ready`
  /// attachments. Never carries bytes.
  ({String text, List<String> attachmentIds}) buildPayload() {
    return (
      text: _text.trim(),
      attachmentIds: [
        for (final attachment in _attachments)
          if (attachment.state == FakeComposerAttachmentState.ready)
            attachment.id,
      ],
    );
  }

  /// Parks the current draft (text + caret + attachments) under [draftKey].
  void park() {
    store.parkDraft(
      draftKey,
      FakeComposerDraft(
        text: _text,
        caretOffset: _caret,
        attachments: List.of(_attachments),
      ),
    );
  }

  /// Restores the draft parked under [draftKey], if any. Returns true when
  /// a draft was found. Parked attachments come back as `picked`; the
  /// caret is clamped into the text.
  bool restore() {
    final draft = store.restoreDraft(draftKey);
    if (draft == null || draft.isEmpty) return false;
    _text = draft.text;
    _caret = draft.caretOffset;
    _attachments
      ..clear()
      ..addAll(draft.attachments);
    _announcements.add('Draft restored.');
    return true;
  }

  /// Deterministic snapshot for repeatability assertions: text, caret, and
  /// the ordered attachment encodings joined verbatim.
  String snapshot() {
    final parts = [
      _text,
      _caret.toString(),
      for (final attachment in _attachments)
        '${attachment.id}:${attachment.label}:${attachment.state.name}:'
            '${attachment.progress.toStringAsFixed(3)}:'
            '${attachment.errorDetail ?? ''}',
    ];
    return parts.join('|');
  }
}
