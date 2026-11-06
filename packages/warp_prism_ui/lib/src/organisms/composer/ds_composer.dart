/// Composer organism (Task 1866, F-18 — EXPERIMENTAL).
///
/// Reusable message composer converged from the donor H8 reference
/// (autogrow textarea, Enter-to-send, @mentions, emoji, format bar,
/// attachment lifecycle, parked drafts): autogrow input, injected mention
/// descriptors with inline suggestions, injected emoji palette, deterministic
/// format helpers, attachment chips with a fail-closed error summary, and
/// in-memory parked-draft persistence with restore.
///
/// What this organism owns: draft text + caret, mention resolution against
/// injected descriptors, format/emoji insertion at the caret, the
/// attachment lifecycle slot chrome (progress arrives injected; the widget
/// never advances it), and park/restore against the injected
/// [DSComposerDraftStore].
///
/// What this organism never does: no backend, no durable store (drafts are
/// in-memory; durable persistence is product-local — no SQLite, no IO
/// imports per B4/B5), no domain types (comments / annotations / operator
/// notes stay consumer-side; Prism takes injected descriptors), no timers,
/// no wall-clock, no randomness, no animation drivers. Upload progress and
/// elapsed time arrive as caller data; the widget never advances them.
///
/// Anchors (Warpblade comments, Tempest annotations, Command-center
/// operator notes) are forthcoming product surfaces — this seam ships
/// EXPERIMENTAL and promotes on second-host adoption. No host proof is
/// claimed here.
///
/// Focus contract: optional injected [FocusNode] (created internally when
/// absent), [autofocus], focus is kept across mention/emoji/format
/// insertion, and caret position survives park/restore and rebuild.
///
/// Lifecycle: EXPERIMENTAL. Intentionally **not** exported from any barrel
/// and without a `Prism*` alias until the promotion task wires the public
/// surface (layer-contracts §9).
library;

import 'package:flutter/material.dart';

import '../../atoms/atoms.dart';
import '../../molecules/ds_interactive_surface.dart';
import '../../molecules/ds_state_surface.dart';
import '../../tokens/tokens.dart';
import 'ds_composer_model.dart';

/// Controller for [DSComposer]: text + caret plus attachment lifecycle.
///
/// Owns the [TextEditingController]. Park/restore round-trips through the
/// injected in-memory [store] under [draftKey]; every attachment transition
/// records a screen-reader [announcement] (progress and state are never
/// colour-only). All transitions are synchronous and deterministic.
class DSComposerController extends ChangeNotifier {
  /// Creates a controller over [store] under [draftKey].
  DSComposerController({
    required this.store,
    required this.draftKey,
    String initialText = '',
    List<DSComposerAttachment> initialAttachments = const [],
  }) : _attachments = List.of(initialAttachments) {
    if (initialText.isNotEmpty) {
      text.text = initialText;
    }
  }

  /// In-memory parked-draft store (caller-owned lifetime).
  final DSComposerDraftStore store;

  /// Key this composer parks under (conversation id, caller-provided).
  final String draftKey;

  /// Editable draft body. Caret is [TextEditingController.selection].
  final TextEditingController text = TextEditingController();

  /// Mention candidates the send payload resolves against.
  List<DSComposerMention> mentionCandidates = const [];

  List<DSComposerAttachment> _attachments;

  /// Current attachment descriptors (unmodifiable snapshot).
  List<DSComposerAttachment> get attachments => List.unmodifiable(_attachments);

  String? _lastAnnouncement;
  int _announcementVersion = 0;

  /// Latest screen-reader announcement, if any transition produced one.
  String? get announcement => _lastAnnouncement;

  /// Monotonic version bumped on every announced transition, so the widget
  /// can re-render the live region deterministically.
  int get announcementVersion => _announcementVersion;

  /// Collapsed caret offset, clamped into the text.
  int get caret {
    final selection = text.selection;
    final offset = selection.isValid
        ? selection.extentOffset
        : text.text.length;
    return offset.clamp(0, text.text.length);
  }

  /// Replaces the body and places a collapsed caret at [caret].
  void setTextAndCaret(String value, int caret) {
    text.text = value;
    final safe = caret.clamp(0, value.length);
    text.selection = TextSelection.collapsed(offset: safe);
    notifyListeners();
  }

  /// Notifies listeners after the owning widget performs a direct
  /// [text] value edit that bypasses [setTextAndCaret] (for example a
  /// selection-preserving format application).
  void refresh() => notifyListeners();

  /// True when a send would carry content: non-blank text or at least one
  /// `ready` attachment.
  bool get canSend =>
      text.text.trim().isNotEmpty ||
      _attachments.any((a) => a.state == DSComposerAttachmentState.ready);

  /// Builds the outgoing payload: trimmed body, resolved mention ids in
  /// candidate order, and the ids of `ready` attachments. Never carries
  /// bytes.
  DSComposerSendPayload buildPayload() {
    final body = text.text.trim();
    final mentionIds = <String>[];
    for (final candidate in mentionCandidates) {
      if (body.contains('@${candidate.displayLabel}')) {
        mentionIds.add(candidate.id);
      }
    }
    return DSComposerSendPayload(
      text: body,
      mentionIds: mentionIds,
      attachmentIds: [
        for (final attachment in _attachments)
          if (attachment.state == DSComposerAttachmentState.ready)
            attachment.id,
      ],
    );
  }

  void _announce(String message) {
    _lastAnnouncement = message;
    _announcementVersion++;
  }

  /// Adds an attachment descriptor. Throws [StateError] on duplicate id.
  void attach(DSComposerAttachment attachment) {
    if (_attachments.any((a) => a.id == attachment.id)) {
      throw StateError(
        'DSComposerController: duplicate attachment id ${attachment.id}.',
      );
    }
    _attachments.add(attachment);
    _announce(attachment.announcement);
    notifyListeners();
  }

  DSComposerAttachment _require(String id) {
    for (final attachment in _attachments) {
      if (attachment.id == id) return attachment;
    }
    throw StateError('DSComposerController: unknown attachment id $id.');
  }

  void _replace(DSComposerAttachment next) {
    final index = _attachments.indexWhere((a) => a.id == next.id);
    _attachments[index] = next;
  }

  /// Sets injected upload progress for an `uploading` attachment.
  ///
  /// Throws [StateError] when the attachment is not uploading.
  void setAttachmentProgress(String id, double value) {
    final current = _require(id);
    if (current.state != DSComposerAttachmentState.uploading) {
      throw StateError(
        'DSComposerController: progress requires uploading state '
        '(${current.id} is ${current.state}).',
      );
    }
    final next = current.copyWith(progress: value);
    _replace(next);
    _announce(next.announcement);
    notifyListeners();
  }

  /// Marks an attachment `uploading` at zero progress (attach or retry).
  void startAttachmentUpload(String id) {
    final current = _require(id);
    if (current.state != DSComposerAttachmentState.picked &&
        current.state != DSComposerAttachmentState.failed) {
      throw StateError(
        'DSComposerController: cannot start upload from ${current.state} '
        '(${current.id}).',
      );
    }
    final next = current.copyWith(
      state: DSComposerAttachmentState.uploading,
      progress: 0.0,
      clearErrorDetail: true,
    );
    _replace(next);
    _announce(next.announcement);
    notifyListeners();
  }

  /// Marks an `uploading` attachment `ready`. Throws [StateError] otherwise.
  void markAttachmentReady(String id) {
    final current = _require(id);
    if (current.state != DSComposerAttachmentState.uploading) {
      throw StateError(
        'DSComposerController: ready requires uploading state '
        '(${current.id} is ${current.state}).',
      );
    }
    final next = current.copyWith(
      state: DSComposerAttachmentState.ready,
      progress: 1.0,
    );
    _replace(next);
    _announce(next.announcement);
    notifyListeners();
  }

  /// Marks an attachment `failed` with a caller-provided sanitized reason.
  void failAttachment(String id, {String? reason}) {
    final current = _require(id);
    final next = current.copyWith(
      state: DSComposerAttachmentState.failed,
      errorDetail: reason,
    );
    _replace(next);
    _announce(next.announcement);
    notifyListeners();
  }

  /// Retries a `failed` attachment: back to `uploading` at zero progress.
  ///
  /// Throws [StateError] when the attachment is not failed.
  void retryAttachment(String id) {
    final current = _require(id);
    if (current.state != DSComposerAttachmentState.failed) {
      throw StateError(
        'DSComposerController: retry requires failed state '
        '(${current.id} is ${current.state}).',
      );
    }
    final next = current.copyWith(
      state: DSComposerAttachmentState.uploading,
      progress: 0.0,
      clearErrorDetail: true,
    );
    _replace(next);
    _announce(next.announcement);
    notifyListeners();
  }

  /// Retries every `failed` attachment. Deterministic bulk recovery for the
  /// fail-closed error summary.
  void retryAllFailed() {
    var retried = false;
    for (var i = 0; i < _attachments.length; i++) {
      final current = _attachments[i];
      if (current.state == DSComposerAttachmentState.failed) {
        _attachments[i] = current.copyWith(
          state: DSComposerAttachmentState.uploading,
          progress: 0.0,
          clearErrorDetail: true,
        );
        retried = true;
      }
    }
    if (retried) {
      _announce('Retrying failed attachments.');
      notifyListeners();
    }
  }

  /// Removes an attachment descriptor.
  void removeAttachment(String id) {
    final current = _require(id);
    _attachments.removeWhere((a) => a.id == id);
    _announce('${current.label}. Attachment removed.');
    notifyListeners();
  }

  /// Clears the body after a send: drops sent (`ready`) attachments, keeps
  /// the rest, and discards the stale parked draft.
  void clearAfterSend() {
    text.clear();
    text.selection = const TextSelection.collapsed(offset: 0);
    _attachments.removeWhere((a) => a.state == DSComposerAttachmentState.ready);
    store.discardDraft(draftKey);
    _announce('Message sent.');
    notifyListeners();
  }

  /// Parks the current draft (text + caret + attachments) under [draftKey].
  ///
  /// In-flight attachments (`picked`, `uploading`) are stored as `parked`;
  /// terminal descriptors (`ready`, `failed`) are kept verbatim.
  void park() {
    store.parkDraft(
      draftKey,
      DSComposerDraft(
        text: text.text,
        caretOffset: caret,
        attachments: List.of(_attachments),
      ),
    );
  }

  /// Restores the draft parked under [draftKey], if any.
  ///
  /// Parked attachments come back as `picked` (never auto-uploaded); the
  /// caret is clamped into the text. Returns true when a draft was found.
  bool restore() {
    final draft = store.restoreDraft(draftKey);
    if (draft == null) return false;
    if (draft.isEmpty) return false;
    setTextAndCaret(draft.text, draft.caretOffset);
    _attachments = List.of(draft.attachments);
    final parkedCount = draft.attachments
        .where((a) => a.state == DSComposerAttachmentState.parked)
        .length;
    if (parkedCount > 0) {
      _announce(
        'Draft restored with $parkedCount parked attachment'
        '${parkedCount == 1 ? '' : 's'}.',
      );
    } else {
      _announce('Draft restored.');
    }
    notifyListeners();
    return true;
  }

  @override
  void dispose() {
    text.dispose();
    super.dispose();
  }
}

/// Reusable message composer organism (Task 1866, F-18 — EXPERIMENTAL).
///
/// Autogrow input (Enter-to-send configurable), @mention autocomplete from
/// injected [mentionCandidates], emoji insertion from injected
/// [emojiOptions], a deterministic format bar, attachment lifecycle chips
/// with a fail-closed error summary, and in-memory parked-draft persistence
/// with restore under [draftKey].
///
/// Upload progress arrives injected through [DSComposerController] (the
/// caller drives the fake); the widget never runs timers, reads the
/// wall-clock, or animates.
class DSComposer extends StatefulWidget {
  /// Injected controller. When null, one is created from [store]/[draftKey]
  /// and disposed with the widget.
  final DSComposerController? controller;

  /// In-memory draft store used when the widget creates its controller.
  /// Ignored when [controller] is provided.
  final DSComposerDraftStore? store;

  /// Key the created controller parks under. Ignored when [controller]
  /// is provided.
  final String draftKey;

  /// Mention candidates resolved and suggested inline.
  final List<DSComposerMention> mentionCandidates;

  /// Emoji palette inserted verbatim at the caret.
  final List<String> emojiOptions;

  /// Input placeholder.
  final String placeholder;

  /// Send button label.
  final String sendLabel;

  /// When true, submitting the field sends; otherwise it inserts a newline.
  final bool sendOnEnter;

  /// When false, input and controls are disabled.
  final bool enabled;

  /// Whether the input requests focus on mount.
  final bool autofocus;

  /// Injected focus node. Created internally when absent.
  final FocusNode? focusNode;

  /// Whether the deterministic format bar is shown.
  final bool showFormatBar;

  /// Whether the attach button is shown. Tapping it calls
  /// [onAttachRequested]; the caller adds descriptors through the
  /// controller.
  final bool showAttachButton;

  /// Whether the emoji toggle is shown (requires [emojiOptions]).
  final bool showEmojiButton;

  /// Maximum autogrow lines for the input.
  final int maxLines;

  /// Compact paddings for dense hosts.
  final bool compact;

  /// Dispatch for the outgoing payload. Called only when the controller
  /// [DSComposerController.canSend].
  final ValueChanged<DSComposerSendPayload>? onSend;

  /// Called on every body edit.
  final ValueChanged<String>? onChanged;

  /// Called when the attach button is tapped. The caller adds attachment
  /// descriptors through the controller.
  final VoidCallback? onAttachRequested;

  const DSComposer({
    super.key,
    this.controller,
    this.store,
    this.draftKey = '',
    this.mentionCandidates = const [],
    this.emojiOptions = const [],
    this.placeholder = 'Write a note…',
    this.sendLabel = 'Send',
    this.sendOnEnter = true,
    this.enabled = true,
    this.autofocus = false,
    this.focusNode,
    this.showFormatBar = true,
    this.showAttachButton = true,
    this.showEmojiButton = true,
    this.maxLines = 6,
    this.compact = false,
    this.onSend,
    this.onChanged,
    this.onAttachRequested,
  });

  /// Test key for the input field.
  static const Key inputKey = Key('ds_composer_input');

  /// Test key for the send button.
  static const Key sendKey = Key('ds_composer_send');

  /// Test key prefix for mention suggestion rows.
  static String mentionKey(String id) => 'ds_composer_mention_$id';

  /// Test key prefix for attachment chips.
  static String attachmentKey(String id) => 'ds_composer_attachment_$id';

  @override
  State<DSComposer> createState() => _DSComposerState();
}

class _DSComposerState extends State<DSComposer> {
  DSComposerController? _internalController;
  late final FocusNode _focusNode;
  late bool _ownsFocusNode;
  String? _mentionQuery;
  bool _showEmojiStrip = false;
  bool _showRestoredNotice = false;
  int _restoredParkedCount = 0;

  DSComposerController get _effectiveController =>
      widget.controller ?? _internalController!;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _internalController = DSComposerController(
        store: widget.store ?? DSComposerDraftStore(),
        draftKey: widget.draftKey,
      );
    }
    _ownsFocusNode = widget.focusNode == null;
    _focusNode = widget.focusNode ?? FocusNode();
    _effectiveController.mentionCandidates = widget.mentionCandidates;
    final restored = _effectiveController.restore();
    if (restored) {
      _showRestoredNotice = true;
      _restoredParkedCount = _effectiveController.attachments
          .where((a) => a.state == DSComposerAttachmentState.picked)
          .length;
    }
    _recomputeMentionQuery();
    _effectiveController.text.addListener(_onTextChanged);
    _effectiveController.addListener(_onControllerChanged);
    _focusNode.addListener(_onFocusChanged);
    if (widget.autofocus && widget.enabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusNode.requestFocus();
      });
    }
  }

  @override
  void didUpdateWidget(DSComposer oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldController = oldWidget.controller ?? _internalController;
    final current = _effectiveController;
    if (!identical(oldController, current)) {
      oldController?.text.removeListener(_onTextChanged);
      oldController?.removeListener(_onControllerChanged);
      current.text.addListener(_onTextChanged);
      current.addListener(_onControllerChanged);
      _recomputeMentionQuery();
    }
    current.mentionCandidates = widget.mentionCandidates;
  }

  @override
  void dispose() {
    // Parked-draft persistence (in memory only): the next composer on the
    // same draft key restores text, caret, and attachments as they were.
    _effectiveController.park();
    _effectiveController.text.removeListener(_onTextChanged);
    _effectiveController.removeListener(_onControllerChanged);
    _focusNode.removeListener(_onFocusChanged);
    _internalController?.dispose();
    if (_ownsFocusNode) _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (!mounted) return;
    setState(() {});
  }

  void _onTextChanged() {
    if (!mounted) return;
    setState(() {
      _showRestoredNotice = false;
      _recomputeMentionQuery();
    });
    widget.onChanged?.call(_effectiveController.text.text);
  }

  void _onControllerChanged() {
    if (!mounted) return;
    setState(() {});
  }

  void _recomputeMentionQuery() {
    final controller = _effectiveController;
    _mentionQuery = extractMentionQuery(controller.text.text, controller.caret);
  }

  void _insertMention(DSComposerMention candidate) {
    final controller = _effectiveController;
    final query = _mentionQuery;
    if (query == null) return;
    final caret = controller.caret;
    final at = caret - query.length - 1;
    if (at < 0) return;
    final text = controller.text.text;
    final next =
        '${text.substring(0, at)}${candidate.insertionToken}'
        '${text.substring(caret)}';
    final nextCaret = at + candidate.insertionToken.length;
    controller.setTextAndCaret(next, nextCaret);
    setState(() => _mentionQuery = null);
    if (widget.enabled) _focusNode.requestFocus();
  }

  void _applyFormat(DSComposerFormat format) {
    if (!widget.enabled) return;
    final controller = _effectiveController;
    final selection = controller.text.selection;
    final start = selection.isValid ? selection.start : controller.caret;
    final end = selection.isValid ? selection.end : controller.caret;
    final result = applyComposerFormat(
      text: controller.text.text,
      start: start,
      end: end,
      format: format,
    );
    controller.text.text = result.text;
    controller.text.selection = TextSelection(
      baseOffset: result.caretStart,
      extentOffset: result.caretEnd,
    );
    controller.refresh();
    _focusNode.requestFocus();
  }

  void _insertEmoji(String emoji) {
    if (!widget.enabled) return;
    final controller = _effectiveController;
    final result = insertComposerEmoji(
      text: controller.text.text,
      caret: controller.caret,
      emoji: emoji,
    );
    controller.setTextAndCaret(result.text, result.caret);
    if (widget.enabled) _focusNode.requestFocus();
  }

  void _send() {
    if (!widget.enabled) return;
    final controller = _effectiveController;
    if (!controller.canSend) return;
    final payload = controller.buildPayload();
    widget.onSend?.call(payload);
    setState(() {
      controller.clearAfterSend();
      _mentionQuery = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = _effectiveController;
    final pad = widget.compact ? DSSpacing.sm : DSSpacing.md;
    final query = _mentionQuery;
    final suggestions = query == null || widget.mentionCandidates.isEmpty
        ? const <DSComposerMention>[]
        : filterComposerMentions(
            widget.mentionCandidates,
            query,
          ).take(5).toList(growable: false);
    final failed = controller.attachments
        .where((a) => a.state == DSComposerAttachmentState.failed)
        .toList(growable: false);
    final announcement = controller.announcement;

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: 'Message composer',
      child: Container(
        padding: EdgeInsets.all(pad),
        decoration: BoxDecoration(
          color: DSColors.obsidianElevated,
          borderRadius: BorderRadius.circular(DSRadii.md),
          border: Border.all(color: DSColors.borderSubtle, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_showRestoredNotice) _buildRestoredNotice(controller),
            _buildInput(controller),
            if (suggestions.isNotEmpty) ...[
              SizedBox(height: widget.compact ? DSSpacing.xs : DSSpacing.sm),
              _buildSuggestions(suggestions),
            ],
            if (widget.showFormatBar && widget.enabled) ...[
              SizedBox(height: widget.compact ? DSSpacing.xs : DSSpacing.sm),
              _buildFormatBar(),
            ],
            if (_showEmojiStrip &&
                widget.showEmojiButton &&
                widget.emojiOptions.isNotEmpty) ...[
              SizedBox(height: widget.compact ? DSSpacing.xs : DSSpacing.sm),
              _buildEmojiStrip(),
            ],
            if (controller.attachments.isNotEmpty) ...[
              SizedBox(height: widget.compact ? DSSpacing.xs : DSSpacing.sm),
              Semantics(
                container: true,
                liveRegion: announcement != null,
                label: announcement ?? 'Attachments',
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final attachment in controller.attachments)
                      _buildAttachmentChip(controller, attachment),
                    if (failed.isNotEmpty) ...[
                      const SizedBox(height: DSSpacing.xs),
                      DSStateSurface.error(
                        title: failed.length == 1
                            ? 'Attachment failed'
                            : '${failed.length} attachments failed',
                        subtitle:
                            failed.first.errorDetail ??
                            'Upload did not complete.',
                        actionLabel: 'Retry all',
                        onAction: controller.retryAllFailed,
                        compact: true,
                      ),
                    ],
                  ],
                ),
              ),
            ],
            SizedBox(height: widget.compact ? DSSpacing.xs : DSSpacing.sm),
            _buildFooter(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildRestoredNotice(DSComposerController controller) {
    final parked = _restoredParkedCount;
    return Padding(
      padding: const EdgeInsets.only(bottom: DSSpacing.xs),
      child: Semantics(
        container: true,
        liveRegion: true,
        label: parked > 0
            ? 'Draft restored with $parked parked attachment'
                  '${parked == 1 ? '' : 's'}.'
            : 'Draft restored.',
        child: Row(
          children: [
            const DSIcon(
              Icons.restore,
              color: DSColors.textSecondary,
              size: 16,
            ),
            const SizedBox(width: DSSpacing.xs),
            Expanded(
              child: ExcludeSemantics(
                child: Text(
                  parked > 0
                      ? 'Draft restored · $parked parked attachment'
                            '${parked == 1 ? '' : 's'}'
                      : 'Draft restored',
                  style: DSTypography.labelSmall.copyWith(
                    color: DSColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(DSComposerController controller) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        decoration: BoxDecoration(
          color: DSColors.obsidianBase,
          borderRadius: BorderRadius.circular(DSRadii.input),
          border: Border.all(
            color: _focusNode.hasFocus
                ? DSColors.focusRing
                : DSColors.borderSubtle,
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Semantics(
                textField: true,
                label: widget.placeholder,
                child: TextField(
                  key: DSComposer.inputKey,
                  controller: controller.text,
                  focusNode: _focusNode,
                  enabled: widget.enabled,
                  minLines: 1,
                  maxLines: widget.maxLines,
                  style: DSTypography.bodyMedium.copyWith(
                    color: DSColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.placeholder,
                    hintStyle: DSTypography.bodyMedium.copyWith(
                      color: DSColors.textTertiary,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: DSSpacing.sm,
                      vertical: 12,
                    ),
                  ),
                  textInputAction: widget.sendOnEnter
                      ? TextInputAction.send
                      : TextInputAction.newline,
                  onSubmitted: (_) {
                    if (widget.sendOnEnter) _send();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestions(List<DSComposerMention> suggestions) {
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: 'Mention suggestions',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final candidate in suggestions)
            Padding(
              key: Key(DSComposer.mentionKey(candidate.id)),
              padding: const EdgeInsets.only(top: 2),
              child: DSInteractiveSurface(
                semanticLabel: 'Mention ${candidate.displayLabel}',
                padding: const EdgeInsets.symmetric(
                  horizontal: DSSpacing.sm,
                  vertical: DSSpacing.xs,
                ),
                onTap: widget.enabled ? () => _insertMention(candidate) : null,
                child: Row(
                  children: [
                    DSIcon(
                      Icons.alternate_email,
                      color: DSColors.accentBlue,
                      size: 16,
                    ),
                    const SizedBox(width: DSSpacing.xs),
                    Expanded(
                      child: Text(
                        candidate.displayLabel,
                        style: DSTypography.labelMedium.copyWith(
                          color: DSColors.textPrimary,
                        ),
                      ),
                    ),
                    if (candidate.detail != null)
                      Flexible(
                        child: Text(
                          candidate.detail!,
                          style: DSTypography.labelSmall.copyWith(
                            color: DSColors.textTertiary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFormatBar() {
    const formats = <(DSComposerFormat, IconData, String)>[
      (DSComposerFormat.bold, Icons.format_bold, 'Bold'),
      (DSComposerFormat.italic, Icons.format_italic, 'Italic'),
      (
        DSComposerFormat.strikethrough,
        Icons.format_strikethrough,
        'Strikethrough',
      ),
      (DSComposerFormat.code, Icons.code, 'Inline code'),
      (DSComposerFormat.codeBlock, Icons.data_object, 'Code block'),
      (DSComposerFormat.quote, Icons.format_quote, 'Quote'),
      (DSComposerFormat.link, Icons.link, 'Link'),
    ];
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: 'Format controls',
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final (format, icon, label) in formats)
              _FormatButton(
                icon: icon,
                semanticLabel: 'Format $label',
                onTap: () => _applyFormat(format),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmojiStrip() {
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: 'Emoji options',
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final emoji in widget.emojiOptions)
              Padding(
                padding: const EdgeInsets.only(right: 2),
                child: Semantics(
                  button: true,
                  enabled: widget.enabled,
                  label: 'Insert emoji $emoji',
                  child: SizedBox.square(
                    dimension: 48,
                    child: Material(
                      color: DSColors.transparent,
                      child: InkWell(
                        onTap: widget.enabled
                            ? () => _insertEmoji(emoji)
                            : null,
                        borderRadius: BorderRadius.circular(DSRadii.sm),
                        child: Center(
                          child: ExcludeSemantics(
                            child: Text(
                              emoji,
                              style: const TextStyle(fontSize: 22),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentChip(
    DSComposerController controller,
    DSComposerAttachment attachment,
  ) {
    final (icon, color) = switch (attachment.state) {
      DSComposerAttachmentState.picked => (
        Icons.schedule,
        DSColors.textTertiary,
      ),
      DSComposerAttachmentState.uploading => (
        Icons.cloud_upload_outlined,
        DSColors.accentBlue,
      ),
      DSComposerAttachmentState.ready => (
        Icons.check_circle_outline,
        DSColors.statusSuccess,
      ),
      DSComposerAttachmentState.failed => (
        Icons.error_outline,
        DSColors.statusError,
      ),
      DSComposerAttachmentState.parked => (
        Icons.cloud_queue,
        DSColors.statusUnknown,
      ),
    };
    return Padding(
      key: Key(DSComposer.attachmentKey(attachment.id)),
      padding: const EdgeInsets.only(top: 2),
      child: Semantics(
        container: true,
        explicitChildNodes: true,
        label: attachment.announcement,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DSSpacing.sm,
            vertical: DSSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: DSColors.obsidianBase,
            borderRadius: BorderRadius.circular(DSRadii.sm),
            border: Border.all(color: color.withValues(alpha: 0.45), width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  DSIcon(icon, color: color, size: 16),
                  const SizedBox(width: DSSpacing.xs),
                  Expanded(
                    child: Text(
                      attachment.label,
                      style: DSTypography.labelMedium.copyWith(
                        color: DSColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (attachment.state == DSComposerAttachmentState.uploading)
                    Text(
                      '${(attachment.progress.clamp(0.0, 1.0) * 100).round()}%',
                      style: DSTypography.labelSmall.copyWith(
                        color: DSColors.textSecondary,
                      ),
                    ),
                  if (attachment.state == DSComposerAttachmentState.failed)
                    _ChipAction(
                      semanticLabel: 'Retry ${attachment.label}',
                      icon: Icons.refresh,
                      onTap: () => controller.retryAttachment(attachment.id),
                    ),
                  if (attachment.state != DSComposerAttachmentState.uploading)
                    _ChipAction(
                      semanticLabel: 'Remove ${attachment.label}',
                      icon: Icons.close,
                      onTap: () => controller.removeAttachment(attachment.id),
                    ),
                ],
              ),
              if (attachment.state == DSComposerAttachmentState.uploading) ...[
                const SizedBox(height: DSSpacing.xxs),
                Semantics(
                  label:
                      '${(attachment.progress.clamp(0.0, 1.0) * 100).round()} percent complete',
                  child: ExcludeSemantics(
                    child: LinearProgressIndicator(
                      value: attachment.progress.clamp(0.0, 1.0),
                      minHeight: 6,
                      backgroundColor: DSColors.borderSubtle,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      borderRadius: BorderRadius.circular(DSRadii.xs),
                    ),
                  ),
                ),
              ],
              if (attachment.state == DSComposerAttachmentState.failed &&
                  attachment.errorDetail != null) ...[
                const SizedBox(height: 2),
                Text(
                  attachment.errorDetail!,
                  style: DSTypography.bodySmall.copyWith(
                    color: DSColors.statusError,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(DSComposerController controller) {
    return Row(
      children: [
        if (widget.showAttachButton && widget.onAttachRequested != null)
          _FormatButton(
            icon: Icons.attach_file,
            semanticLabel: 'Attach a file',
            onTap: widget.enabled ? widget.onAttachRequested! : () {},
          ),
        if (widget.showEmojiButton && widget.emojiOptions.isNotEmpty)
          _FormatButton(
            icon: Icons.emoji_emotions_outlined,
            semanticLabel: _showEmojiStrip ? 'Hide emoji' : 'Show emoji',
            onTap: widget.enabled
                ? () => setState(() => _showEmojiStrip = !_showEmojiStrip)
                : () {},
          ),
        const Spacer(),
        DSButton(
          key: DSComposer.sendKey,
          label: widget.sendLabel,
          onPressed: controller.canSend ? _send : null,
          enabled: widget.enabled && controller.canSend,
        ),
      ],
    );
  }
}

/// 48px minimum-target icon button shared by composer chrome.
class _FormatButton extends StatelessWidget {
  final IconData icon;
  final String semanticLabel;
  final VoidCallback onTap;

  const _FormatButton({
    required this.icon,
    required this.semanticLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: SizedBox.square(
        dimension: 48,
        child: Material(
          color: DSColors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(DSRadii.sm),
            child: Center(
              child: DSIcon(icon, color: DSColors.textSecondary, size: 20),
            ),
          ),
        ),
      ),
    );
  }
}

/// 48px minimum-target chip action (retry / remove).
class _ChipAction extends StatelessWidget {
  final String semanticLabel;
  final IconData icon;
  final VoidCallback onTap;

  const _ChipAction({
    required this.semanticLabel,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: SizedBox.square(
        dimension: 48,
        child: Material(
          color: DSColors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(DSRadii.sm),
            child: Center(
              child: DSIcon(icon, color: DSColors.textSecondary, size: 18),
            ),
          ),
        ),
      ),
    );
  }
}
