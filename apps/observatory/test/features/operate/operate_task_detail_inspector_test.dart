/// Widget tests for the Operate task detail inspector.
///
/// Verifies:
/// - Card selection updates the inspector with metadata, commands, evidence
/// - Empty state renders when no task is selected
/// - Evidence rows and verification commands are visible
/// - Related skills/workflows are inspectable
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_observatory/data/models/task_contracts.dart';
import 'package:warp_prism_observatory/features/operate/task_projection.dart';
import 'package:warp_prism_observatory/features/operate/operate_task_detail_panel.dart';
import 'package:warp_prism_observatory/features/operate/operate_task_detail_mapper.dart';

/// Build a representative [TaskProjection] fixture.
TaskProjection _testTask({
  String id = '0612',
  String title = 'Operate Task Detail Inspector',
  TaskLane lane = TaskLane.doing,
  String priority = 'P1',
  String owner = 'builder-agent',
  ProofState proofState = ProofState.partial,
  List<String> dependsOn = const ['0610', '0611'],
  List<String> verificationCommands = const [
    'flutter test test/features/operate/operate_task_detail_inspector_test.dart',
    'flutter analyze',
  ],
  List<String> linkedSkills = const ['agent-wiki'],
  List<String> linkedWorkflows = const ['build-orchestrator'],
  List<ExitCondition> exitConditions = const [
    ExitCondition(text: 'Mapper exists', isComplete: true),
    ExitCondition(text: 'Panel renders', isComplete: false),
  ],
  String? completionEvidenceSummary,
  String bodyMarkdown = '## Objective\nImplement the Operate-specific task inspector.',
}) {
  return TaskProjection(
    id: id,
    title: title,
    lane: lane,
    priority: priority,
    owner: owner,
    proofState: proofState,
    dependsOn: dependsOn,
    verificationCommands: verificationCommands,
    linkedSkills: linkedSkills,
    linkedWorkflows: linkedWorkflows,
    exitConditions: exitConditions,
    completionEvidenceSummary: completionEvidenceSummary,
    bodyMarkdown: bodyMarkdown,
    created: DateTime(2026, 6, 7),
    updated: DateTime(2026, 6, 7),
    filePath: 'docs/tasks/02-doing/0612-warp-prism-operate-task-detail-inspector.md',
  );
}

Widget _wrapInApp(Widget child) {
  return MaterialApp(
    home: Scaffold(body: SizedBox(width: 800, height: 900, child: child)),
  );
}

void main() {
  group('OperateTaskDetailPanel', () {
    testWidgets('renders task identity as header', (tester) async {
      final task = _testTask();
      await tester.pumpWidget(_wrapInApp(
        OperateTaskDetailPanel(task: task),
      ));

      // Header shows task id and title
      expect(find.textContaining('0612'), findsWidgets);
      expect(find.textContaining('Operate Task Detail Inspector'), findsOneWidget);
      expect(find.textContaining('doing'), findsOneWidget);
    });

    testWidgets('renders metadata section with lane, priority, owner', (tester) async {
      final task = _testTask();
      await tester.pumpWidget(_wrapInApp(
        OperateTaskDetailPanel(task: task),
      ));

      expect(find.text('Metadata'), findsOneWidget);
      expect(find.text('P1'), findsOneWidget);
      expect(find.text('builder-agent'), findsOneWidget);
      expect(find.text('partial'), findsOneWidget);
    });

    testWidgets('renders verification commands', (tester) async {
      final task = _testTask();
      await tester.pumpWidget(_wrapInApp(
        OperateTaskDetailPanel(task: task),
      ));

      expect(find.text('Verification Commands'), findsOneWidget);
      expect(find.textContaining('flutter test'), findsOneWidget);
      expect(find.textContaining('flutter analyze'), findsOneWidget);
    });

    testWidgets('renders dependencies section', (tester) async {
      final task = _testTask();
      await tester.pumpWidget(_wrapInApp(
        OperateTaskDetailPanel(task: task),
      ));

      expect(find.text('Dependencies & Blockers'), findsOneWidget);
      expect(find.text('0610'), findsOneWidget);
      expect(find.text('0611'), findsOneWidget);
    });

    testWidgets('renders evidence rows', (tester) async {
      final task = _testTask();
      await tester.pumpWidget(_wrapInApp(
        OperateTaskDetailPanel(task: task),
      ));

      expect(find.text('Completion Evidence'), findsOneWidget);
      expect(find.text('Evidence Status'), findsOneWidget);
    });

    testWidgets('renders exit conditions with checked state', (tester) async {
      final task = _testTask();
      await tester.pumpWidget(_wrapInApp(
        OperateTaskDetailPanel(task: task),
      ));

      expect(find.text('Exit Conditions'), findsOneWidget);
      expect(find.text('Mapper exists'), findsOneWidget);
      expect(find.text('Panel renders'), findsOneWidget);
    });

    testWidgets('renders related skills and workflows', (tester) async {
      final task = _testTask();
      await tester.pumpWidget(_wrapInApp(
        OperateTaskDetailPanel(task: task),
      ));

      expect(find.text('Related Skills & Workflows'), findsOneWidget);
      expect(find.text('agent-wiki'), findsOneWidget);
      expect(find.text('build-orchestrator'), findsOneWidget);
    });

    testWidgets('renders body summary section', (tester) async {
      final task = _testTask();
      await tester.pumpWidget(_wrapInApp(
        OperateTaskDetailPanel(task: task),
      ));

      expect(find.text('Body Summary'), findsOneWidget);
      expect(find.textContaining('Implement the Operate-specific'), findsOneWidget);
    });

    testWidgets('close button triggers onClose callback', (tester) async {
      var closed = false;
      final task = _testTask();
      await tester.pumpWidget(_wrapInApp(
        OperateTaskDetailPanel(
          task: task,
          onClose: () => closed = true,
        ),
      ));

      // Find and tap the close button
      final closeBtn = find.byTooltip('Close');
      expect(closeBtn, findsOneWidget);
      await tester.tap(closeBtn);
      expect(closed, isTrue);
    });
  });

  group('OperateTaskDetailEmpty', () {
    testWidgets('renders empty state message', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        const OperateTaskDetailEmpty(),
      ));

      expect(find.text('No task selected'), findsOneWidget);
      expect(find.textContaining('Select a task card'), findsOneWidget);
    });
  });

  group('buildTaskDetailSections', () {
    test('returns 7 sections for a complete task', () {
      final task = _testTask();
      final sections = buildTaskDetailSections(task);
      expect(sections.length, 7);
      expect(sections[0].title, 'Metadata');
      expect(sections[1].title, 'Dependencies & Blockers');
      expect(sections[2].title, 'Exit Conditions');
      expect(sections[3].title, 'Verification Commands');
      expect(sections[4].title, 'Completion Evidence');
      expect(sections[5].title, 'Related Skills & Workflows');
      expect(sections[6].title, 'Body Summary');
    });

    test('handles task with no dependencies', () {
      final task = _testTask(dependsOn: []);
      final sections = buildTaskDetailSections(task);
      // Should not crash, deps section shows "No dependencies declared"
      expect(sections[1].count, 0);
    });

    test('handles task with no commands or evidence', () {
      final task = _testTask(
        verificationCommands: [],
        completionEvidenceSummary: null,
      );
      final sections = buildTaskDetailSections(task);
      expect(sections[3].count, 0);
    });
  });
}
