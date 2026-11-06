@Tags(['golden'])
library;

// Golden tests for the composer organism (Task 1866, F-18 — EXPERIMENTAL).
//
// Deterministic capture only: every case pins a fixed store-seeded draft,
// fixed attachment states with fixed progress, and fixed mention/emoji
// fixtures. No timers, no wall-clock, no animation: progress arrives
// injected and renders as static chrome. Parked drafts are excluded from
// golden capture (they assert restoration behavior, never frozen pixels).
//
// Run from packages/warp_prism_ui/:
//   flutter test --update-goldens test/goldens/ds_composer_1866_golden_test.dart
//   flutter test test/goldens/ds_composer_1866_golden_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/src/organisms/composer/ds_composer.dart';
import 'package:warp_prism_ui/src/organisms/composer/ds_composer_model.dart';
import 'package:warp_prism_ui/src/tokens/tokens.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

Widget _inApp(Widget child) {
  return MaterialApp(
    theme: PrismTheme.dark(),
    home: Scaffold(
      backgroundColor: DSColors.obsidianBase,
      body: Center(child: SizedBox(width: 560, child: child)),
    ),
  );
}

DSComposerController _seededController() {
  final controller = DSComposerController(
    store: DSComposerDraftStore(),
    draftKey: 'golden-conv',
    initialText: 'Reviewing take 04 with @ada',
    initialAttachments: const [
      DSComposerAttachment(
        id: 'att-ready-1',
        label: 'notes.md',
        state: DSComposerAttachmentState.ready,
      ),
    ],
  );
  controller.mentionCandidates = DSComposerFake.referenceMentions();
  controller.text.selection = const TextSelection.collapsed(offset: 8);
  return controller;
}

void main() {
  group('DSComposer golden — fixed draft states', () {
    testWidgets('renders empty composer', (tester) async {
      await tester.pumpWidget(_inApp(const DSComposer()));
      await expectLater(
        find.byType(DSComposer),
        matchesGoldenFile('goldens/composer_1866_empty.png'),
      );
    });

    testWidgets('renders seeded draft with caret and ready chip', (
      tester,
    ) async {
      final controller = _seededController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(_inApp(DSComposer(controller: controller)));
      await expectLater(
        find.byType(DSComposer),
        matchesGoldenFile('goldens/composer_1866_draft.png'),
      );
    });

    testWidgets('renders uploading attachment at fixed progress', (
      tester,
    ) async {
      final controller = DSComposerController(
        store: DSComposerDraftStore(),
        draftKey: 'golden-conv',
        initialText: 'Uploading stems',
        initialAttachments: const [
          DSComposerAttachment(
            id: 'att-up-1',
            label: 'stems-04.zip',
            state: DSComposerAttachmentState.uploading,
            progress: 0.5,
          ),
        ],
      );
      addTearDown(controller.dispose);
      await tester.pumpWidget(_inApp(DSComposer(controller: controller)));
      await expectLater(
        find.byType(DSComposer),
        matchesGoldenFile('goldens/composer_1866_uploading.png'),
      );
    });

    testWidgets('renders failed attachment with the error summary', (
      tester,
    ) async {
      final controller = DSComposerController(
        store: DSComposerDraftStore(),
        draftKey: 'golden-conv',
        initialText: 'Upload failed',
        initialAttachments: const [
          DSComposerAttachment(
            id: 'att-fail-1',
            label: 'render-04.mp4',
            state: DSComposerAttachmentState.failed,
            errorDetail: 'Chunk 3 rejected by the ingest gate',
          ),
        ],
      );
      addTearDown(controller.dispose);
      await tester.pumpWidget(_inApp(DSComposer(controller: controller)));
      await expectLater(
        find.byType(DSComposer),
        matchesGoldenFile('goldens/composer_1866_failed.png'),
      );
    });
  });
}
