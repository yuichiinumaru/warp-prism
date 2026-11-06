// Widget tests for the bounded-repair molecule (Task 1871, F-04).
//
// Proves the RepairDialog shape: approval mode renders as an option,
// per-reply undo renders only when offered AND enabled, and the approve
// action resolves through Task 1868's authority with a tooltip reason.
// Run: flutter test packages/warp_prism_ui/test/molecules/bounded_repair_dialog_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/src/molecules/ds_action_gate.dart';
import 'package:warp_prism_ui/src/molecules/ds_bounded_repair.dart';
import 'package:warp_prism_ui/src/tokens/ds_action_authority.dart';

Widget wrapInApp(Widget child) {
  return MaterialApp(
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

void main() {
  group('review_1871 bounded repair dialog shape', () {
    testWidgets('renders title, approval mode, and reply rows', (tester) async {
      await tester.pumpWidget(
        wrapInApp(
          DSBoundedRepair(
            title: 'Repair proposal',
            subtitle: '3 replies',
            replies: [
              DSRepairReply(replyLabel: 'Restart daemon', onUndo: () {}),
              DSRepairReply(
                replyLabel: 'Replay queue',
                detail: 'drops duplicates',
                onUndo: () {},
              ),
            ],
            approveAuthority: DSActionAuthority.allow,
            onApprove: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Repair proposal'), findsOneWidget);
      expect(find.text('Confirm each'), findsOneWidget);
      expect(find.text('Restart daemon'), findsOneWidget);
      expect(find.text('Replay queue'), findsOneWidget);
      expect(find.byType(DSActionGate), findsOneWidget);
    });

    testWidgets('all approval modes render their label', (tester) async {
      for (final mode in DSRepairApprovalMode.values) {
        await tester.pumpWidget(
          wrapInApp(
            DSBoundedRepair(
              title: 'Repair',
              replies: [DSRepairReply(replyLabel: 'Fix', onUndo: () {})],
              approvalMode: mode,
              approveAuthority: DSActionAuthority.allow,
              onApprove: () {},
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text(mode.label), findsOneWidget);
        expect(find.text(mode.description), findsOneWidget);
      }
    });

    testWidgets('undo renders per reply only when offered and enabled', (
      tester,
    ) async {
      var undone = 0;
      await tester.pumpWidget(
        wrapInApp(
          DSBoundedRepair(
            title: 'Repair',
            replies: [
              DSRepairReply(replyLabel: 'Undoable', onUndo: () => undone++),
              const DSRepairReply(replyLabel: 'No undo callback'),
              DSRepairReply(
                replyLabel: 'Undo unavailable',
                undoAvailable: false,
                onUndo: () => undone += 100,
              ),
            ],
            approveAuthority: DSActionAuthority.allow,
            onApprove: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Exactly one undo button: offered AND enabled AND has a callback.
      expect(find.text('Undo'), findsOneWidget);
      await tester.tap(find.text('Undo'));
      await tester.pump();
      expect(undone, 1);
    });

    testWidgets('undoPerReply master switch hides all undo buttons', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapInApp(
          DSBoundedRepair(
            title: 'Repair',
            undoPerReply: false,
            replies: [DSRepairReply(replyLabel: 'Fix', onUndo: () {})],
            approveAuthority: DSActionAuthority.allow,
            onApprove: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Undo'), findsNothing);
    });

    testWidgets('denied approve refuses with reason, never dispatches', (
      tester,
    ) async {
      var approved = 0;
      String? refused;
      await tester.pumpWidget(
        wrapInApp(
          DSBoundedRepair(
            title: 'Repair',
            replies: [DSRepairReply(replyLabel: 'Fix', onUndo: () {})],
            approveAuthority: DSActionAuthority.deny,
            approveReason: 'Unknown evidence: Sync status',
            onApprove: () => approved++,
            onRefused: (reason) => refused = reason,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Approve repair'), findsOneWidget);
      expect(find.text('Unknown evidence: Sync status'), findsOneWidget);
      await tester.tap(find.text('Approve repair'));
      await tester.pump();
      expect(approved, 0);
      expect(refused, 'Unknown evidence: Sync status');
    });

    testWidgets('allowed approve dispatches', (tester) async {
      var approved = 0;
      await tester.pumpWidget(
        wrapInApp(
          DSBoundedRepair(
            title: 'Repair',
            replies: [DSRepairReply(replyLabel: 'Fix', onUndo: () {})],
            approveAuthority: DSActionAuthority.allow,
            onApprove: () => approved++,
            onCancel: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Approve repair'));
      await tester.pump();
      expect(approved, 1);
    });
  });
}
