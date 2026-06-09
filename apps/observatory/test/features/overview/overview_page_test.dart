/// Widget tests for the Overview page.
///
/// Verifies that the page renders metric tiles and the story panel
/// from pre-computed [OverviewMetrics] — data-driven, not hardcoded.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_observatory/data/models/data_models.dart';
import 'package:warp_prism_observatory/features/overview/overview_metrics.dart';
import 'package:warp_prism_observatory/features/overview/overview_page.dart';

/// Helper: build a minimal OverviewMetrics for testing.
OverviewMetrics _testMetrics({
  int agents = 2,
  int skills = 1,
  int subSkills = 3,
  int workflows = 2,
  int changelog = 3,
  Map<TaskLane, int>? tasksByLane,
  int blockers = 0,
  int reviewQueue = 1,
  int govWarnings = 0,
  int totalAssets = 12,
  int totalEdges = 8,
}) {
  final laneMap = tasksByLane ?? {
    TaskLane.planning: 0,
    TaskLane.open: 1,
    TaskLane.doing: 2,
    TaskLane.review: 1,
    TaskLane.completed: 1,
  };
  return OverviewMetrics(
    agentCount: agents,
    skillCount: skills,
    subSkillCount: subSkills,
    workflowCount: workflows,
    changelogEntryCount: changelog,
    tasksByLane: laneMap,
    activeBlockers: blockers,
    reviewQueueCount: reviewQueue,
    governanceWarningCount: govWarnings,
    currentStoryTitle: 'Test story',
    currentStoryInsights: const [
      OverviewStoryInsight(text: 'Insight 1', value: '5'),
      OverviewStoryInsight(text: 'Insight 2', severity: OverviewInsightSeverity.warning),
    ],
    totalAssets: totalAssets,
    totalEdges: totalEdges,
  );
}

Widget _wrapInApp(Widget child) {
  return MaterialApp(
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

void main() {
  group('OverviewPage widget', () {
    testWidgets('renders totals section with metric tiles', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        OverviewPage(metrics: _testMetrics()),
      ));

      // Should render the Totals heading
      expect(find.text('Totals'), findsOneWidget);

      // Should render metric tile labels
      expect(find.text('Agents'), findsOneWidget);
      expect(find.text('Skills'), findsOneWidget);
      expect(find.text('Workflows'), findsOneWidget);
      expect(find.text('Changelog'), findsOneWidget);
      expect(find.text('Total Assets'), findsOneWidget);
    });

    testWidgets('renders tasks by lane section', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        OverviewPage(metrics: _testMetrics()),
      ));

      expect(find.text('Tasks by Lane'), findsOneWidget);
      expect(find.text('Planning'), findsOneWidget);
      expect(find.text('Open'), findsOneWidget);
      expect(find.text('Doing'), findsOneWidget);
      expect(find.text('Review'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
    });

    testWidgets('renders operational risk section', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        OverviewPage(metrics: _testMetrics()),
      ));

      expect(find.text('Operational Risk'), findsOneWidget);
      expect(find.text('Active Blockers'), findsOneWidget);
      expect(find.text('Review Queue'), findsOneWidget);
      expect(find.text('Gov Warnings'), findsOneWidget);
    });

    testWidgets('renders current story panel', (tester) async {
      await tester.pumpWidget(_wrapInApp(
        OverviewPage(metrics: _testMetrics()),
      ));

      expect(find.text('Current Story'), findsOneWidget);
      expect(find.text('Insight 1'), findsOneWidget);
      expect(find.text('Insight 2'), findsOneWidget);
    });

    testWidgets('renders zero-data state correctly', (tester) async {
      final zeroMetrics = _testMetrics(
        agents: 0, skills: 0, subSkills: 0, workflows: 0,
        changelog: 0, blockers: 0, reviewQueue: 0,
        govWarnings: 0, totalAssets: 0, totalEdges: 0,
        tasksByLane: {
          TaskLane.planning: 0,
          TaskLane.open: 0,
          TaskLane.doing: 0,
          TaskLane.review: 0,
          TaskLane.completed: 0,
        },
      );

      await tester.pumpWidget(_wrapInApp(
        OverviewPage(metrics: zeroMetrics),
      ));

      // Should still render all sections
      expect(find.text('Totals'), findsOneWidget);
      expect(find.text('Tasks by Lane'), findsOneWidget);
      expect(find.text('Operational Risk'), findsOneWidget);
      expect(find.text('Current Story'), findsOneWidget);

      // Zero values should display
      expect(find.text('0'), findsWidgets);
    });
  });
}
