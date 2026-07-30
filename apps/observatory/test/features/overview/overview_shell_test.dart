/// Widget tests for OverviewPageShell provider wiring.
///
/// Verifies the shell renders data-driven metrics (not simulated empty
/// data) and correctly handles forced loading/error/metrics states.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_observatory/app/pages/overview_page.dart';
import 'package:warp_prism_observatory/data/models/data_models.dart';
import 'package:warp_prism_observatory/features/overview/overview_metrics.dart';

OverviewMetrics _metrics({
  int agents = 3,
  int skills = 2,
  int subSkills = 4,
  int workflows = 1,
  int changelog = 2,
  int blockers = 1,
  int reviewQueue = 2,
  int govWarnings = 1,
  int totalAssets = 15,
  int totalEdges = 6,
}) {
  return OverviewMetrics(
    agentCount: agents,
    skillCount: skills,
    subSkillCount: subSkills,
    workflowCount: workflows,
    changelogEntryCount: changelog,
    tasksByLane: const {
      TaskLane.planning: 0,
      TaskLane.open: 2,
      TaskLane.doing: 1,
      TaskLane.review: 2,
      TaskLane.completed: 1,
    },
    activeBlockers: blockers,
    reviewQueueCount: reviewQueue,
    governanceWarningCount: govWarnings,
    currentStoryTitle: 'Provider-wired story',
    currentStoryInsights: const [
      OverviewStoryInsight(text: 'Derived from repository state', value: '1'),
    ],
    totalAssets: totalAssets,
    totalEdges: totalEdges,
  );
}

Widget _wrap(Widget child) {
  return ProviderScope(
    child: MaterialApp(home: Scaffold(body: child)),
  );
}

void main() {
  group('OverviewPageShell', () {
    testWidgets('renders forced metrics without simulating empty data', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(OverviewPageShell(forcedMetrics: _metrics())),
      );

      expect(find.text('Totals'), findsOneWidget);
      expect(find.text('Agents'), findsOneWidget);
      expect(find.text('3'), findsWidgets); // agentCount
      expect(find.text('Active Blockers'), findsOneWidget);
      expect(find.text('Current Story'), findsOneWidget);
      expect(find.text('Derived from repository state'), findsOneWidget);
    });

    testWidgets('renders forced loading state', (tester) async {
      await tester.pumpWidget(
        _wrap(const OverviewPageShell(forceLoading: true)),
      );

      expect(find.text('Loading workspace...'), findsOneWidget);
      expect(find.text('Totals'), findsNothing);
    });

    testWidgets('renders forced error state', (tester) async {
      await tester.pumpWidget(
        _wrap(const OverviewPageShell(forcedError: 'mock load failure')),
      );

      expect(find.text('Failed to load workspace'), findsOneWidget);
      expect(find.textContaining('mock load failure'), findsOneWidget);
      expect(find.text('Totals'), findsNothing);
    });

    testWidgets('zero-metrics forced state still renders dashboard structure', (
      tester,
    ) async {
      final zero = _metrics(
        agents: 0,
        skills: 0,
        subSkills: 0,
        workflows: 0,
        changelog: 0,
        blockers: 0,
        reviewQueue: 0,
        govWarnings: 0,
        totalAssets: 0,
        totalEdges: 0,
      );

      await tester.pumpWidget(_wrap(OverviewPageShell(forcedMetrics: zero)));

      expect(find.text('Totals'), findsOneWidget);
      expect(find.text('Tasks by Lane'), findsOneWidget);
      expect(find.text('Operational Risk'), findsOneWidget);
      expect(find.text('Current Story'), findsOneWidget);
      expect(find.text('0'), findsWidgets);
    });
  });
}
