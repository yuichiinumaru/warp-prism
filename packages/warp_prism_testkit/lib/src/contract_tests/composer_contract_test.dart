import 'package:meta/meta.dart';
import 'package:test/test.dart';

import '../fakes/fake_composer_model.dart';

/// Reusable contract compliance suite for composer draft/attachment models
/// (Task 1866, F-18).
///
/// Verifies the composer laws headlessly: draft/caret restore round-trips
/// through the in-memory store, the attachment lifecycle (picked →
/// uploading → ready, with fail/retry/remove and park/restore branches),
/// determinism (no async, repeatable snapshots), and the screen-reader
/// announcement contract (state changes announce; progress and state are
/// never colour-only).
///
/// Lifecycle: EXPERIMENTAL (see `.project/architecture/layer-contracts.md`).
@experimental
void verifyComposerModelContract({
  required FakeComposerModel Function({
    required FakeComposerDraftStore store,
    required String draftKey,
    List<String> mentionCandidates,
  })
  createModel,
  String description = 'Composer Model Contract Compliance',
}) {
  group(description, () {
    group('draft and caret restore', () {
      test('empty store restores nothing', () {
        final model = createModel(
          store: FakeComposerDraftStore(),
          draftKey: 'conv-1',
        );
        expect(model.restore(), isFalse);
        expect(model.text, isEmpty);
        expect(model.caret, equals(0));
      });

      test('parked text and caret restore verbatim', () {
        final store = FakeComposerDraftStore();
        final writer = createModel(store: store, draftKey: 'conv-1');
        writer.setTextAndCaret('Reviewing take 04', 9);
        writer.park();

        final reader = createModel(store: store, draftKey: 'conv-1');
        expect(reader.restore(), isTrue);
        expect(reader.text, equals('Reviewing take 04'));
        expect(reader.caret, equals(9));
      });

      test('caret is clamped into the text on restore', () {
        final store = FakeComposerDraftStore();
        store.parkDraft(
          'conv-1',
          const FakeComposerDraft(text: 'hi', caretOffset: 99),
        );
        final model = createModel(store: store, draftKey: 'conv-1');
        expect(model.restore(), isTrue);
        expect(model.caret, equals(2));
      });

      test('empty draft clears the key instead of storing', () {
        final store = FakeComposerDraftStore();
        final model = createModel(store: store, draftKey: 'conv-1');
        model.setTextAndCaret('', 0);
        model.park();
        expect(store.hasDraft('conv-1'), isFalse);
      });

      test('draft keys are isolated per conversation', () {
        final store = FakeComposerDraftStore();
        final first = createModel(store: store, draftKey: 'conv-1');
        first.setTextAndCaret('first draft', 11);
        first.park();
        final second = createModel(store: store, draftKey: 'conv-2');
        expect(second.restore(), isFalse);
        expect(second.text, isEmpty);
        final reread = createModel(store: store, draftKey: 'conv-1');
        expect(reread.restore(), isTrue);
        expect(reread.text, equals('first draft'));
      });

      test('overwriting a key replaces the parked draft', () {
        final store = FakeComposerDraftStore();
        final first = createModel(store: store, draftKey: 'conv-1');
        first.setTextAndCaret('old', 3);
        first.park();
        final second = createModel(store: store, draftKey: 'conv-1');
        second.restore();
        second.setTextAndCaret('new', 3);
        second.park();
        final reread = createModel(store: store, draftKey: 'conv-1');
        expect(reread.restore(), isTrue);
        expect(reread.text, equals('new'));
      });
    });

    group('mention resolution is deterministic', () {
      test('no token open returns null', () {
        final model = createModel(
          store: FakeComposerDraftStore(),
          draftKey: 'conv-1',
          mentionCandidates: const ['ada', 'grace'],
        );
        model.setTextAndCaret('hello world', 11);
        expect(model.mentionQuery(), isNull);
      });

      test('open token returns the query after at', () {
        final model = createModel(
          store: FakeComposerDraftStore(),
          draftKey: 'conv-1',
          mentionCandidates: const ['ada', 'grace'],
        );
        model.setTextAndCaret('ping @ad', 8);
        expect(model.mentionQuery(), equals('ad'));
        expect(model.filterMentions('ad'), equals(['ada']));
      });

      test('bare at returns the full candidate list', () {
        final model = createModel(
          store: FakeComposerDraftStore(),
          draftKey: 'conv-1',
          mentionCandidates: const ['ada', 'grace'],
        );
        model.setTextAndCaret('ping @', 6);
        expect(model.mentionQuery(), equals(''));
        expect(model.filterMentions(''), equals(['ada', 'grace']));
      });

      test('email-like tokens do not open mentions', () {
        final model = createModel(
          store: FakeComposerDraftStore(),
          draftKey: 'conv-1',
          mentionCandidates: const ['ada'],
        );
        model.setTextAndCaret('mail ada@host', 13);
        expect(model.mentionQuery(), isNull);
      });

      test('insertMention replaces the token and moves the caret', () {
        final model = createModel(
          store: FakeComposerDraftStore(),
          draftKey: 'conv-1',
          mentionCandidates: const ['ada'],
        );
        model.setTextAndCaret('ping @ad', 8);
        model.insertMention('ada');
        expect(model.text, equals('ping @ada '));
        expect(model.caret, equals('ping @ada '.length));
        expect(model.mentionQuery(), isNull);
      });

      test('insertMention without an open token throws', () {
        final model = createModel(
          store: FakeComposerDraftStore(),
          draftKey: 'conv-1',
        );
        model.setTextAndCaret('hello', 5);
        expect(() => model.insertMention('ada'), throwsStateError);
      });
    });

    group('attachment lifecycle', () {
      FakeComposerModel uploadingModel() {
        final model = createModel(
          store: FakeComposerDraftStore(),
          draftKey: 'conv-1',
        );
        model.attach(const FakeComposerAttachment(id: 'a1', label: 'take.wav'));
        model.startUpload('a1');
        return model;
      }

      test('duplicate ids are rejected', () {
        final model = createModel(
          store: FakeComposerDraftStore(),
          draftKey: 'conv-1',
        );
        model.attach(const FakeComposerAttachment(id: 'a1', label: 'take.wav'));
        expect(
          () => model.attach(
            const FakeComposerAttachment(id: 'a1', label: 'other.wav'),
          ),
          throwsStateError,
        );
      });

      test('progress is clamped and attachment-scoped', () {
        final model = uploadingModel();
        model.setProgress('a1', 2.5);
        expect(model.attachments.single.progress, equals(1.0));
        model.setProgress('a1', -0.5);
        expect(model.attachments.single.progress, equals(0.0));
      });

      test('progress on a non-uploading attachment throws', () {
        final model = createModel(
          store: FakeComposerDraftStore(),
          draftKey: 'conv-1',
        );
        model.attach(const FakeComposerAttachment(id: 'a1', label: 'take.wav'));
        expect(() => model.setProgress('a1', 0.5), throwsStateError);
      });

      test('uploading to ready carries full progress and sendability', () {
        final model = uploadingModel();
        model.setProgress('a1', 0.5);
        model.markReady('a1');
        final attachment = model.attachments.single;
        expect(attachment.state, equals(FakeComposerAttachmentState.ready));
        expect(attachment.progress, equals(1.0));
        expect(attachment.state.isSendable, isTrue);
        expect(model.canSend, isTrue);
        expect(model.buildPayload().attachmentIds, equals(['a1']));
      });

      test('fail carries the caller reason and retry recovers', () {
        final model = uploadingModel();
        model.fail('a1', reason: 'Chunk 3 rejected');
        var attachment = model.attachments.single;
        expect(attachment.state, equals(FakeComposerAttachmentState.failed));
        expect(attachment.errorDetail, equals('Chunk 3 rejected'));
        expect(model.canSend, isFalse);
        model.retry('a1');
        attachment = model.attachments.single;
        expect(attachment.state, equals(FakeComposerAttachmentState.uploading));
        expect(attachment.progress, equals(0.0));
        expect(attachment.errorDetail, isNull);
      });

      test('retry on a non-failed attachment throws', () {
        final model = uploadingModel();
        expect(() => model.retry('a1'), throwsStateError);
      });

      test('remove drops the descriptor and announces removal', () {
        final model = uploadingModel();
        model.remove('a1');
        expect(model.attachments, isEmpty);
        expect(model.announcements.last, contains('Attachment removed'));
      });

      test('unknown ids throw on every transition', () {
        final model = createModel(
          store: FakeComposerDraftStore(),
          draftKey: 'conv-1',
        );
        expect(() => model.startUpload('nope'), throwsStateError);
        expect(() => model.setProgress('nope', 0.5), throwsStateError);
        expect(() => model.markReady('nope'), throwsStateError);
        expect(() => model.fail('nope'), throwsStateError);
        expect(() => model.retry('nope'), throwsStateError);
        expect(() => model.remove('nope'), throwsStateError);
      });

      test('in-flight attachments park and restore as picked', () {
        final store = FakeComposerDraftStore();
        final writer = createModel(store: store, draftKey: 'conv-1');
        writer.setTextAndCaret('draft', 5);
        writer.attach(
          const FakeComposerAttachment(id: 'a1', label: 'take.wav'),
        );
        writer.startUpload('a1');
        writer.setProgress('a1', 0.5);
        writer.park();

        final reader = createModel(store: store, draftKey: 'conv-1');
        expect(reader.restore(), isTrue);
        final attachment = reader.attachments.single;
        expect(attachment.state, equals(FakeComposerAttachmentState.picked));
      });

      test('ready attachments survive park and restore verbatim', () {
        final store = FakeComposerDraftStore();
        final writer = createModel(store: store, draftKey: 'conv-1');
        writer.setTextAndCaret('draft', 5);
        writer.attach(
          const FakeComposerAttachment(id: 'a1', label: 'notes.md'),
        );
        writer.startUpload('a1');
        writer.markReady('a1');
        writer.park();

        final reader = createModel(store: store, draftKey: 'conv-1');
        expect(reader.restore(), isTrue);
        expect(
          reader.attachments.single.state,
          equals(FakeComposerAttachmentState.ready),
        );
        expect(reader.canSend, isTrue);
      });
    });

    group('determinism: no async, repeatable snapshots', () {
      FakeComposerModel scriptedModel(FakeComposerDraftStore store) {
        final model = createModel(
          store: store,
          draftKey: 'conv-1',
          mentionCandidates: const ['ada'],
        );
        model.setTextAndCaret('ping @ad', 8);
        model.insertMention('ada');
        model.attach(const FakeComposerAttachment(id: 'a1', label: 'take.wav'));
        model.startUpload('a1');
        model.setProgress('a1', 0.5);
        return model;
      }

      test('identical scripts produce identical snapshots', () {
        final first = scriptedModel(FakeComposerDraftStore());
        final second = scriptedModel(FakeComposerDraftStore());
        expect(second.snapshot(), equals(first.snapshot()));
      });

      test('snapshot pins text, caret, and attachment encodings', () {
        final model = scriptedModel(FakeComposerDraftStore());
        final snapshot = model.snapshot();
        expect(snapshot, contains('ping @ada '));
        expect(snapshot, contains('a1:take.wav:uploading:0.500'));
      });
    });

    group('screen-reader announcements', () {
      test('state transitions append announcement fragments', () {
        final model = createModel(
          store: FakeComposerDraftStore(),
          draftKey: 'conv-1',
        );
        model.attach(const FakeComposerAttachment(id: 'a1', label: 'take.wav'));
        expect(model.announcements.last, contains('waiting to upload'));
        model.startUpload('a1');
        model.setProgress('a1', 0.5);
        expect(model.announcements.last, contains('50 percent'));
        model.markReady('a1');
        expect(model.announcements.last, contains('ready to send'));
      });

      test('failure announcements carry the caller reason', () {
        final model = createModel(
          store: FakeComposerDraftStore(),
          draftKey: 'conv-1',
        );
        model.attach(const FakeComposerAttachment(id: 'a1', label: 'take.wav'));
        model.startUpload('a1');
        model.fail('a1', reason: 'Chunk 3 rejected');
        expect(model.announcements.last, contains('Attachment failed'));
        expect(model.announcements.last, contains('Chunk 3 rejected'));
      });

      test('announcements never claim success for indeterminate words', () {
        final model = createModel(
          store: FakeComposerDraftStore(),
          draftKey: 'conv-1',
        );
        model.attach(const FakeComposerAttachment(id: 'a1', label: 'take.wav'));
        model.startUpload('a1');
        for (final announcement in model.announcements) {
          expect(announcement.toLowerCase(), isNot(contains('succeed')));
        }
      });
    });
  });
}

void main() {}
