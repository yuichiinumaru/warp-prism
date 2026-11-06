// Conformance tests for the composer organism (Task 1866, F-18,
// EXPERIMENTAL).
//
// Covers: draft/caret model round-trips, mention query/filter/insert,
// format + emoji insertion, the attachment lifecycle with fail/retry and
// park/restore, widget send/mention/format/emoji/attachment behavior,
// determinism (identical inputs render identical output), and the
// accessibility contract (semantics labels, live-region announcements,
// 48px minimum targets, focus retention).
//
// Run: flutter test packages/warp_prism_ui/test/organisms/ds_composer_1866_conformance_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/src/atoms/atoms.dart';
import 'package:warp_prism_ui/src/organisms/composer/ds_composer.dart';
import 'package:warp_prism_ui/src/organisms/composer/ds_composer_model.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );
}

DSComposerController _controller({
  String draftKey = 'conv-1',
  List<DSComposerMention> mentions = const [],
}) {
  final controller = DSComposerController(
    store: DSComposerDraftStore(),
    draftKey: draftKey,
  );
  controller.mentionCandidates = mentions;
  return controller;
}

const _mentions = [
  DSComposerMention(id: 'member-ada', displayLabel: 'ada'),
  DSComposerMention(id: 'member-grace', displayLabel: 'grace'),
];

void main() {
  group('mention query extraction', () {
    test('no at returns null', () {
      expect(extractMentionQuery('hello world', 11), isNull);
    });

    test('open token returns the query', () {
      expect(extractMentionQuery('ping @ad', 8), equals('ad'));
    });

    test('bare at returns an empty query', () {
      expect(extractMentionQuery('ping @', 6), equals(''));
    });

    test('email-like tokens do not open mentions', () {
      expect(extractMentionQuery('mail ada@host', 13), isNull);
    });

    test('caret clamps into the text', () {
      expect(extractMentionQuery('ping @ad', 99), equals('ad'));
    });

    test('space after at closes the token', () {
      expect(extractMentionQuery('ping @ad more', 11), isNull);
    });
  });

  group('mention filtering', () {
    test('empty query returns every candidate in order', () {
      expect(filterComposerMentions(_mentions, ''), equals(_mentions));
    });

    test('matching is case-insensitive substring', () {
      expect(
        filterComposerMentions(_mentions, 'AD'),
        equals([_mentions.first]),
      );
    });

    test('no match returns empty', () {
      expect(filterComposerMentions(_mentions, 'zzz'), isEmpty);
    });
  });

  group('format application', () {
    test('bold wraps the selection', () {
      final result = applyComposerFormat(
        text: 'hello world',
        start: 6,
        end: 11,
        format: DSComposerFormat.bold,
      );
      expect(result.text, equals('hello **world**'));
      expect(result.caretStart, equals(8));
      expect(result.caretEnd, equals(13));
    });

    test('italic wraps the selection', () {
      final result = applyComposerFormat(
        text: 'hello world',
        start: 0,
        end: 5,
        format: DSComposerFormat.italic,
      );
      expect(result.text, equals('*hello* world'));
    });

    test('strikethrough wraps the selection', () {
      final result = applyComposerFormat(
        text: 'done task',
        start: 5,
        end: 9,
        format: DSComposerFormat.strikethrough,
      );
      expect(result.text, equals('done ~~task~~'));
    });

    test('code block fences the selection', () {
      final result = applyComposerFormat(
        text: 'fn main() {}',
        start: 0,
        end: 12,
        format: DSComposerFormat.codeBlock,
      );
      expect(result.text, equals('```\nfn main() {}\n```'));
    });

    test('quote prefixes each selected line', () {
      final result = applyComposerFormat(
        text: 'line one\nline two',
        start: 0,
        end: 17,
        format: DSComposerFormat.quote,
      );
      expect(result.text, equals('> line one\n> line two'));
    });

    test('collapsed quote inserts the marker at the line start', () {
      final result = applyComposerFormat(
        text: 'hello',
        start: 5,
        end: 5,
        format: DSComposerFormat.quote,
      );
      expect(result.text, equals('> hello'));
      expect(result.caretStart, equals(result.caretEnd));
    });

    test('link wraps the selection with an empty target', () {
      final result = applyComposerFormat(
        text: 'see docs',
        start: 4,
        end: 8,
        format: DSComposerFormat.link,
      );
      expect(result.text, equals('see [docs]()'));
      expect(result.caretStart, equals(result.caretEnd));
    });

    test('collapsed bold inserts empty markers with caret between', () {
      final result = applyComposerFormat(
        text: 'hello',
        start: 5,
        end: 5,
        format: DSComposerFormat.bold,
      );
      expect(result.text, equals('hello****'));
      expect(result.caretStart, equals(7));
      expect(result.caretEnd, equals(7));
    });

    test('inverted ranges throw', () {
      expect(
        () => applyComposerFormat(
          text: 'hello',
          start: 4,
          end: 1,
          format: DSComposerFormat.bold,
        ),
        throwsRangeError,
      );
    });
  });

  group('emoji insertion', () {
    test('inserts at the caret', () {
      final result = insertComposerEmoji(text: 'hi ', caret: 3, emoji: '👍');
      expect(result.text, equals('hi 👍'));
      expect(result.caret, equals('hi 👍'.length));
    });

    test('caret clamps into the text', () {
      final result = insertComposerEmoji(text: 'hi', caret: 99, emoji: '👀');
      expect(result.text, equals('hi👀'));
      expect(result.caret, equals(4));
    });
  });

  group('draft store', () {
    test('parked text and caret restore verbatim', () {
      final store = DSComposerDraftStore();
      store.parkDraft(
        'conv-1',
        const DSComposerDraft(text: 'Reviewing take 04', caretOffset: 9),
      );
      final restored = store.restoreDraft('conv-1');
      expect(restored?.text, equals('Reviewing take 04'));
      expect(restored?.caretOffset, equals(9));
    });

    test('caret clamps into the text on restore', () {
      final store = DSComposerDraftStore();
      store.parkDraft(
        'conv-1',
        const DSComposerDraft(text: 'hi', caretOffset: 99),
      );
      expect(store.restoreDraft('conv-1')?.caretOffset, equals(2));
    });

    test('empty drafts clear the key', () {
      final store = DSComposerDraftStore();
      store.parkDraft('conv-1', const DSComposerDraft(text: 'x'));
      store.parkDraft('conv-1', const DSComposerDraft());
      expect(store.hasDraft('conv-1'), isFalse);
    });

    test('unknown keys restore null', () {
      expect(DSComposerDraftStore().restoreDraft('missing'), isNull);
    });

    test('keys are isolated and overwrite replaces', () {
      final store = DSComposerDraftStore();
      store.parkDraft('a', const DSComposerDraft(text: 'old', caretOffset: 3));
      store.parkDraft('a', const DSComposerDraft(text: 'new', caretOffset: 3));
      expect(store.restoreDraft('a')?.text, equals('new'));
      expect(store.restoreDraft('b'), isNull);
    });

    test('in-flight attachments park and restore as picked', () {
      final store = DSComposerDraftStore();
      store.parkDraft(
        'conv-1',
        const DSComposerDraft(
          text: 'draft',
          caretOffset: 5,
          attachments: [
            DSComposerAttachment(
              id: 'a1',
              label: 'take.wav',
              state: DSComposerAttachmentState.uploading,
              progress: 0.5,
            ),
          ],
        ),
      );
      final restored = store.restoreDraft('conv-1');
      expect(
        restored?.attachments.single.state,
        equals(DSComposerAttachmentState.picked),
      );
    });

    test('discard removes the parked draft', () {
      final store = DSComposerDraftStore();
      store.parkDraft('conv-1', const DSComposerDraft(text: 'x'));
      store.discardDraft('conv-1');
      expect(store.hasDraft('conv-1'), isFalse);
    });
  });

  group('attachment descriptors', () {
    test('progress clamps to 0..1', () {
      expect(
        const DSComposerAttachment(id: 'a', label: 'x', progress: 2.5).progress,
        equals(1.0),
      );
      expect(
        const DSComposerAttachment(
          id: 'a',
          label: 'x',
          progress: -0.5,
        ).progress,
        equals(0.0),
      );
    });

    test('only ready is sendable', () {
      for (final state in DSComposerAttachmentState.values) {
        expect(
          state.isSendable,
          equals(state == DSComposerAttachmentState.ready),
          reason: '$state sendability',
        );
      }
    });

    test('uploading announcement carries the percent', () {
      const attachment = DSComposerAttachment(
        id: 'a',
        label: 'stems.zip',
        state: DSComposerAttachmentState.uploading,
        progress: 0.5,
      );
      expect(attachment.announcement, contains('stems.zip'));
      expect(attachment.announcement, contains('50 percent'));
    });

    test('failed announcement carries the caller reason', () {
      const attachment = DSComposerAttachment(
        id: 'a',
        label: 'render.mp4',
        state: DSComposerAttachmentState.failed,
        errorDetail: 'Chunk 3 rejected',
      );
      expect(attachment.announcement, contains('Attachment failed'));
      expect(attachment.announcement, contains('Chunk 3 rejected'));
    });
  });

  group('composer fake fixtures', () {
    test('fixtures are deterministic across calls', () {
      expect(
        DSComposerFake.referenceMentions().toString(),
        equals(DSComposerFake.referenceMentions().toString()),
      );
      expect(
        DSComposerFake.referenceAttachments().toString(),
        equals(DSComposerFake.referenceAttachments().toString()),
      );
    });

    test('attachment samples cover every lifecycle state', () {
      final states = DSComposerFake.referenceAttachments()
          .map((a) => a.state)
          .toSet();
      expect(states, containsAll(DSComposerAttachmentState.values));
    });

    test('reference draft carries text, caret, and one ready attachment', () {
      final draft = DSComposerFake.referenceDraft();
      expect(draft.text, isNotEmpty);
      expect(draft.caretOffset, equals(draft.text.length));
      expect(
        draft.attachments.single.state,
        equals(DSComposerAttachmentState.ready),
      );
    });
  });

  group('controller transitions', () {
    test('empty controller cannot send', () {
      final controller = _controller();
      expect(controller.canSend, isFalse);
      controller.dispose();
    });

    test('non-blank text enables send and builds the payload', () {
      final controller = _controller(mentions: _mentions);
      controller.setTextAndCaret('ping @ada review this', 21);
      expect(controller.canSend, isTrue);
      final payload = controller.buildPayload();
      expect(payload.text, equals('ping @ada review this'));
      expect(payload.mentionIds, equals(['member-ada']));
      controller.dispose();
    });

    test('ready attachment enables send without text', () {
      final controller = _controller();
      controller.attach(
        const DSComposerAttachment(id: 'a1', label: 'notes.md'),
      );
      expect(controller.canSend, isFalse);
      controller.startAttachmentUpload('a1');
      controller.markAttachmentReady('a1');
      expect(controller.canSend, isTrue);
      expect(controller.buildPayload().attachmentIds, equals(['a1']));
      controller.dispose();
    });

    test('duplicate ids and unknown ids throw', () {
      final controller = _controller();
      controller.attach(
        const DSComposerAttachment(id: 'a1', label: 'take.wav'),
      );
      expect(
        () => controller.attach(
          const DSComposerAttachment(id: 'a1', label: 'other.wav'),
        ),
        throwsStateError,
      );
      expect(
        () => controller.setAttachmentProgress('nope', 0.5),
        throwsStateError,
      );
      expect(() => controller.markAttachmentReady('nope'), throwsStateError);
      expect(() => controller.failAttachment('nope'), throwsStateError);
      expect(() => controller.retryAttachment('nope'), throwsStateError);
      expect(() => controller.removeAttachment('nope'), throwsStateError);
      controller.dispose();
    });

    test('progress requires the uploading state', () {
      final controller = _controller();
      controller.attach(
        const DSComposerAttachment(id: 'a1', label: 'take.wav'),
      );
      expect(
        () => controller.setAttachmentProgress('a1', 0.5),
        throwsStateError,
      );
      expect(() => controller.markAttachmentReady('a1'), throwsStateError);
      controller.dispose();
    });

    test('fail and retry round-trip clears the reason', () {
      final controller = _controller();
      controller.attach(
        const DSComposerAttachment(id: 'a1', label: 'take.wav'),
      );
      controller.startAttachmentUpload('a1');
      controller.failAttachment('a1', reason: 'Chunk 3 rejected');
      expect(
        controller.attachments.single.state,
        equals(DSComposerAttachmentState.failed),
      );
      expect(
        controller.attachments.single.errorDetail,
        equals('Chunk 3 rejected'),
      );
      controller.retryAttachment('a1');
      final retried = controller.attachments.single;
      expect(retried.state, equals(DSComposerAttachmentState.uploading));
      expect(retried.progress, equals(0.0));
      expect(retried.errorDetail, isNull);
      controller.dispose();
    });

    test('clearAfterSend drops ready, keeps the rest, discards parked', () {
      final store = DSComposerDraftStore();
      final controller = DSComposerController(store: store, draftKey: 'conv-1');
      controller.setTextAndCaret('shipped', 7);
      controller.attach(
        const DSComposerAttachment(id: 'ready-1', label: 'notes.md'),
      );
      controller.startAttachmentUpload('ready-1');
      controller.markAttachmentReady('ready-1');
      controller.attach(
        const DSComposerAttachment(id: 'pick-1', label: 'take.wav'),
      );
      store.parkDraft('conv-1', const DSComposerDraft(text: 'stale'));
      controller.clearAfterSend();
      expect(controller.text.text, isEmpty);
      expect(controller.attachments.map((a) => a.id), equals(['pick-1']));
      expect(store.hasDraft('conv-1'), isFalse);
      controller.dispose();
    });

    test('park and restore round-trip text, caret, and attachments', () {
      final store = DSComposerDraftStore();
      final writer = DSComposerController(store: store, draftKey: 'conv-1');
      writer.setTextAndCaret('Reviewing take 04', 9);
      writer.attach(const DSComposerAttachment(id: 'a1', label: 'take.wav'));
      writer.startAttachmentUpload('a1');
      writer.setAttachmentProgress('a1', 0.5);
      writer.park();

      final reader = DSComposerController(store: store, draftKey: 'conv-1');
      expect(reader.restore(), isTrue);
      expect(reader.text.text, equals('Reviewing take 04'));
      expect(reader.text.selection.baseOffset, equals(9));
      expect(
        reader.attachments.single.state,
        equals(DSComposerAttachmentState.picked),
      );
      writer.dispose();
      reader.dispose();
    });
  });

  group('composer widget', () {
    testWidgets('renders placeholder with send disabled when empty', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const DSComposer(placeholder: 'Write a note…')),
      );
      expect(find.text('Write a note…'), findsOneWidget);
      expect(find.byKey(DSComposer.sendKey), findsOneWidget);
      final button = tester.widget<DSButton>(find.byKey(DSComposer.sendKey));
      expect(button.enabled, isFalse);
    });

    testWidgets('typing enables send and dispatches the payload', (
      tester,
    ) async {
      DSComposerSendPayload? sent;
      await tester.pumpWidget(
        _wrap(
          DSComposer(
            mentionCandidates: _mentions,
            onSend: (payload) => sent = payload,
          ),
        ),
      );
      await tester.enterText(
        find.byKey(DSComposer.inputKey),
        'ping @ada review this',
      );
      await tester.pump();
      final button = tester.widget<DSButton>(find.byKey(DSComposer.sendKey));
      expect(button.enabled, isTrue);
      await tester.tap(find.byKey(DSComposer.sendKey));
      await tester.pump();
      expect(sent?.text, equals('ping @ada review this'));
      expect(sent?.mentionIds, equals(['member-ada']));
      expect(
        tester
            .widget<TextField>(find.byKey(DSComposer.inputKey))
            .controller
            ?.text,
        isEmpty,
      );
    });

    testWidgets('mention suggestions insert the token and keep focus', (
      tester,
    ) async {
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      await tester.pumpWidget(
        _wrap(DSComposer(mentionCandidates: _mentions, focusNode: focusNode)),
      );
      await tester.enterText(find.byKey(DSComposer.inputKey), 'ping @ad');
      await tester.pump();
      expect(
        find.byKey(Key(DSComposer.mentionKey('member-ada'))),
        findsOneWidget,
      );
      await tester.tap(find.byKey(Key(DSComposer.mentionKey('member-ada'))));
      await tester.pump();
      expect(
        tester
            .widget<TextField>(find.byKey(DSComposer.inputKey))
            .controller
            ?.text,
        equals('ping @ada '),
      );
      expect(focusNode.hasFocus, isTrue);
    });

    testWidgets('format bar wraps the selection in bold markers', (
      tester,
    ) async {
      final controller = DSComposerController(
        store: DSComposerDraftStore(),
        draftKey: 'conv-1',
      );
      addTearDown(controller.dispose);
      await tester.pumpWidget(_wrap(DSComposer(controller: controller)));
      controller.setTextAndCaret('hello world', 0);
      controller.text.selection = const TextSelection(
        baseOffset: 6,
        extentOffset: 11,
      );
      await tester.pump();
      await tester.tap(find.bySemanticsLabel('Format Bold'));
      await tester.pump();
      expect(controller.text.text, equals('hello **world**'));
    });

    testWidgets('emoji strip inserts the grapheme at the caret', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const DSComposer(emojiOptions: ['👍', '🎯'])),
      );
      await tester.enterText(find.byKey(DSComposer.inputKey), 'nice ');
      await tester.pump();
      await tester.tap(find.bySemanticsLabel('Show emoji'));
      await tester.pump();
      await tester.tap(find.bySemanticsLabel('Insert emoji 👍'));
      await tester.pump();
      expect(
        tester
            .widget<TextField>(find.byKey(DSComposer.inputKey))
            .controller
            ?.text,
        equals('nice 👍'),
      );
    });

    testWidgets('uploading attachment shows fixed percent, no animation', (
      tester,
    ) async {
      final controller = DSComposerController(
        store: DSComposerDraftStore(),
        draftKey: 'conv-1',
      );
      addTearDown(controller.dispose);
      controller.attach(
        const DSComposerAttachment(id: 'a1', label: 'stems.zip'),
      );
      controller.startAttachmentUpload('a1');
      controller.setAttachmentProgress('a1', 0.5);
      await tester.pumpWidget(_wrap(DSComposer(controller: controller)));
      await tester.pump();
      expect(find.byKey(Key(DSComposer.attachmentKey('a1'))), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
      final bar = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(bar.value, equals(0.5));
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('failed attachment shows the error summary with retry', (
      tester,
    ) async {
      final controller = DSComposerController(
        store: DSComposerDraftStore(),
        draftKey: 'conv-1',
      );
      addTearDown(controller.dispose);
      controller.attach(
        const DSComposerAttachment(id: 'a1', label: 'render.mp4'),
      );
      controller.startAttachmentUpload('a1');
      controller.failAttachment('a1', reason: 'Chunk 3 rejected');
      await tester.pumpWidget(_wrap(DSComposer(controller: controller)));
      await tester.pump();
      expect(find.text('Attachment failed'), findsOneWidget);
      expect(find.text('Chunk 3 rejected'), findsWidgets);
      await tester.tap(find.text('Retry all'));
      await tester.pump();
      expect(
        controller.attachments.single.state,
        equals(DSComposerAttachmentState.uploading),
      );
    });

    testWidgets('dispose parks and the next composer restores the draft', (
      tester,
    ) async {
      final store = DSComposerDraftStore();
      await tester.pumpWidget(
        _wrap(DSComposer(store: store, draftKey: 'conv-9')),
      );
      await tester.enterText(
        find.byKey(DSComposer.inputKey),
        'Reviewing take 04',
      );
      await tester.pump();
      // Dispose by replacing the tree, then mount a fresh composer.
      await tester.pumpWidget(_wrap(const SizedBox()));
      await tester.pumpWidget(
        _wrap(DSComposer(store: store, draftKey: 'conv-9')),
      );
      await tester.pump();
      expect(
        tester
            .widget<TextField>(find.byKey(DSComposer.inputKey))
            .controller
            ?.text,
        equals('Reviewing take 04'),
      );
      expect(find.text('Draft restored'), findsOneWidget);
    });

    testWidgets('in-flight attachments park on dispose and restore picked', (
      tester,
    ) async {
      final store = DSComposerDraftStore();
      final first = DSComposerController(store: store, draftKey: 'conv-9');
      first.attach(const DSComposerAttachment(id: 'a1', label: 'take.wav'));
      first.startAttachmentUpload('a1');
      first.setAttachmentProgress('a1', 0.5);
      await tester.pumpWidget(_wrap(DSComposer(controller: first)));
      await tester.pump();
      await tester.pumpWidget(_wrap(const SizedBox()));
      first.dispose();
      final second = DSComposerController(store: store, draftKey: 'conv-9');
      addTearDown(second.dispose);
      await tester.pumpWidget(_wrap(DSComposer(controller: second)));
      await tester.pump();
      expect(
        second.attachments.single.state,
        equals(DSComposerAttachmentState.picked),
      );
      expect(find.textContaining('parked attachment'), findsWidgets);
    });

    testWidgets('identical inputs render identical output', (tester) async {
      Widget build() => _wrap(
        const DSComposer(
          mentionCandidates: _mentions,
          emojiOptions: ['👍'],
          placeholder: 'Write a note…',
        ),
      );
      await tester.pumpWidget(build());
      final first = tester.getSize(find.byType(DSComposer));
      await tester.pumpWidget(build());
      await tester.pump();
      final second = tester.getSize(find.byType(DSComposer));
      expect(second, equals(first));
    });
  });

  group('composer accessibility contract', () {
    testWidgets('composer region carries the semantics label', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap(const DSComposer()));
      expect(find.bySemanticsLabel('Message composer'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('mention rows and format controls expose labels', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _wrap(
          const DSComposer(mentionCandidates: _mentions, emojiOptions: ['👍']),
        ),
      );
      await tester.enterText(find.byKey(DSComposer.inputKey), 'ping @ad');
      await tester.pump();
      expect(find.bySemanticsLabel('Mention ada'), findsOneWidget);
      expect(find.bySemanticsLabel('Format Bold'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('attachment state changes carry announcements', (tester) async {
      final handle = tester.ensureSemantics();
      final controller = DSComposerController(
        store: DSComposerDraftStore(),
        draftKey: 'conv-1',
      );
      addTearDown(controller.dispose);
      controller.attach(
        const DSComposerAttachment(id: 'a1', label: 'stems.zip'),
      );
      controller.startAttachmentUpload('a1');
      controller.setAttachmentProgress('a1', 0.5);
      await tester.pumpWidget(_wrap(DSComposer(controller: controller)));
      await tester.pump();
      final semantics = tester.getSemantics(find.byType(DSComposer).first);
      expect(semantics.label, contains('Message composer'));
      final chip = find.byKey(Key(DSComposer.attachmentKey('a1')));
      expect(chip, findsOneWidget);
      expect(
        find.descendant(
          of: chip,
          matching: find.bySemanticsLabel(
            'stems.zip. Attachment uploading. 50 percent.',
          ),
        ),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('composer chrome uses 48px minimum targets', (tester) async {
      await tester.pumpWidget(
        _wrap(const DSComposer(emojiOptions: ['👍'], onAttachRequested: null)),
      );
      await tester.pump();
      final boldBox = find.ancestor(
        of: find.byIcon(Icons.format_bold),
        matching: find.byType(SizedBox),
      );
      expect(boldBox, findsWidgets);
      final size = tester.getSize(boldBox.first);
      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));
    });
  });
}
