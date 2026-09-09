@Tags(['golden'])
library;

// Golden tests for PrismAgentTranscript — EPIC-16 agent transcript default.
//
// Task 1614. Fixed surface size + deterministic multi-role fixture only.
//
// Run from packages/warp_prism_ui/:
//   flutter test --update-goldens test/goldens/prism_agent_transcript_golden_test.dart
//   flutter test test/goldens/prism_agent_transcript_golden_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

Widget _inApp(Widget child) {
  return MaterialApp(
    theme: PrismTheme.dark(),
    home: Scaffold(backgroundColor: PrismColors.obsidianBase, body: child),
  );
}

/// Compact multi-role fixture — fixed UTC timestamps for golden stability.
List<PrismAgentMessage> _defaultTranscriptFixture() {
  final t0 = DateTime.utc(2026, 7, 10, 12, 0, 0);
  return [
    PrismAgentMessage(
      id: 'sys-1',
      role: PrismAgentRole.system,
      timestamp: t0,
      blocks: const [PrismAgentMessageBlock.text('System online.')],
    ),
    PrismAgentMessage(
      id: 'user-1',
      role: PrismAgentRole.user,
      timestamp: t0.add(const Duration(seconds: 5)),
      authorLabel: 'Operator',
      blocks: const [PrismAgentMessageBlock.text('Hello agent.')],
    ),
    PrismAgentMessage(
      id: 'asst-1',
      role: PrismAgentRole.assistant,
      timestamp: t0.add(const Duration(seconds: 12)),
      authorLabel: 'Prism Analyst',
      blocks: const [
        PrismAgentMessageBlock.think('Consider response tone.'),
        PrismAgentMessageBlock.text('Hello **Operator**. How can I help?'),
        PrismAgentMessageBlock.plan('1. Greet\n2. Wait for task'),
      ],
    ),
  ];
}

void main() {
  group('PrismAgentTranscript golden — default state', () {
    testWidgets('renders default multi-role PrismAgentTranscript', (
      tester,
    ) async {
      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });

      await tester.binding.setSurfaceSize(const Size(720, 520));

      await tester.pumpWidget(
        _inApp(
          PrismAgentTranscript(
            messages: _defaultTranscriptFixture(),
            showTimestamps: true,
            // Plain text avoids markdown layout variance across engines.
            renderMarkdown: false,
            semanticLabel: 'Fixture agent conversation',
          ),
        ),
      );

      // Single frame only — no pumpAndSettle (no infinite animations expected).
      await tester.pump();

      await expectLater(
        find.byType(PrismAgentTranscript),
        matchesGoldenFile('goldens/prism_agent_transcript_default.png'),
      );
    });
  });
}
