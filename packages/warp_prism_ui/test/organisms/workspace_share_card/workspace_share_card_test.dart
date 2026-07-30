import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

void main() {
  Widget harness({
    required PrismWorkspaceShareSummary summary,
    ValueChanged<String>? onShare,
    String? title = 'Workspace Handoff',
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: PrismWorkspaceShareCard(
            summary: summary,
            onShare: onShare,
            title: title,
          ),
        ),
      ),
    );
  }

  group('PrismWorkspaceShareCard', () {
    const testSummary = PrismWorkspaceShareSummary(
      workspaceId: 'ws-123',
      workspaceName: 'Test Workspace',
      activePresetName: 'Preset Alpha',
      activeLayers: ['Layer 1', 'Layer 2'],
      cameraCenter: 'Lat: 10, Lng: 20',
      cameraZoom: 5.5,
      agentCount: 3,
      taskCount: 7,
      shareUrl: 'https://test.share/ws-123',
    );

    testWidgets('renders all summary fields and values', (tester) async {
      await tester.pumpWidget(harness(summary: testSummary));

      expect(find.byType(PrismWorkspaceShareCard), findsOneWidget);
      expect(find.text('Workspace Handoff'), findsOneWidget);
      expect(find.text('Workspace'), findsOneWidget);
      expect(find.text('Test Workspace'), findsOneWidget);
      expect(find.text('Preset Alpha'), findsOneWidget);
      expect(find.text('Layer 1, Layer 2'), findsOneWidget);
      expect(find.text('Lat: 10, Lng: 20'), findsOneWidget);
      expect(find.text('5.5'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('7'), findsOneWidget);
      expect(find.text('https://test.share/ws-123'), findsOneWidget);
    });

    testWidgets('triggers copy action and invokes callback', (tester) async {
      String? sharedUrl;
      await tester.pumpWidget(
        harness(summary: testSummary, onShare: (url) => sharedUrl = url),
      );

      // Click the Copy button
      expect(find.byType(ElevatedButton), findsOneWidget);
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Confirms callback is triggered
      expect(sharedUrl, 'https://test.share/ws-123');

      // The button text changes to 'Copied'
      expect(find.text('Copied'), findsOneWidget);
    });

    testWidgets('verifies accessibility labels on copy button', (tester) async {
      await tester.pumpWidget(harness(summary: testSummary));

      final copyButtonSemantics = tester.getSemantics(
        find.bySemanticsLabel('Copy workspace share link'),
      );
      expect(copyButtonSemantics.flagsCollection.isButton, isTrue);
      expect(copyButtonSemantics.label, 'Copy workspace share link');
    });

    testWidgets('copy button enforces >=48x48 touch target', (tester) async {
      await tester.pumpWidget(harness(summary: testSummary));

      final button = find.byType(ElevatedButton);
      expect(button, findsOneWidget);
      final size = tester.getSize(button);
      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));
    });

    testWidgets('verifies accessibility labels on copy button after clicked', (
      tester,
    ) async {
      await tester.pumpWidget(harness(summary: testSummary));

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final copiedButtonSemantics = tester.getSemantics(
        find.byType(ElevatedButton),
      );
      expect(copiedButtonSemantics.flagsCollection.isButton, isTrue);
      expect(copiedButtonSemantics.label, 'Copied');
    });
  });
}
