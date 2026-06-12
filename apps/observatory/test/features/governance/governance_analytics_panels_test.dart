/// Widget tests for governance analytics panels (Task 0812).
///
/// Verifies:
/// - Fan-in hotspot panel renders ranked hotspots with explanatory copy
/// - Review pressure panel renders queue indicators by lane
/// - Healthy empty states render when no warnings exist
/// - Ranking order is correct (highest fan-in first)
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_observatory/data/models/governance_diagnostics.dart';
import 'package:warp_prism_observatory/features/governance/presentation/widgets/fan_in_hotspots_panel.dart';
import 'package:warp_prism_observatory/features/governance/presentation/widgets/review_pressure_panel.dart';

GovernanceDiagnostic _fanInDiag({
  String assetId = 'skill:hub',
  String assetName = 'hub-skill',
  String assetKind = 'skill',
  int incomingEdgeCount = 5,
  int threshold = 3,
  DiagnosticSeverity severity = DiagnosticSeverity.warning,
}) {
  return GovernanceDiagnostic(
    assetId: assetId,
    severity: severity,
    category: DiagnosticCategory.brokenEdge,
    message: 'High fan-in hotspot',
    context: {
      'targetId': assetId,
      'incomingEdgeCount': incomingEdgeCount,
      'threshold': threshold,
      'assetName': assetName,
      'assetKind': assetKind,
      'assetPath': 'lib/skills/$assetName.md',
    },
    computedAt: DateTime(2026, 6, 7),
  );
}

GovernanceDiagnostic _proofGapDiag({
  String assetId = 'task:0612',
  String taskTitle = 'Implement Inspector',
  String taskLane = '03-review',
  DiagnosticSeverity severity = DiagnosticSeverity.error,
}) {
  return GovernanceDiagnostic(
    assetId: assetId,
    severity: severity,
    category: DiagnosticCategory.proofGap,
    message: 'Task has no proof',
    context: {
      'taskId': assetId,
      'taskTitle': taskTitle,
      'taskLane': taskLane,
      'proofState': 'none',
    },
    computedAt: DateTime(2026, 6, 7),
  );
}

Widget _wrapInApp(Widget child) {
  return MaterialApp(
    home: Scaffold(body: SizedBox(width: 1200, height: 900, child: child)),
  );
}

void main() {
  group('FanInHotspot', () {
    test('fromDiagnostics extracts and ranks hotspots', () {
      final diags = [
        _fanInDiag(incomingEdgeCount: 3),
        _fanInDiag(
          assetId: 'workflow:core',
          assetName: 'core-workflow',
          incomingEdgeCount: 8,
        ),
        _fanInDiag(
          assetId: 'skill:minor',
          assetName: 'minor-skill',
          incomingEdgeCount: 4,
        ),
      ];
      final hotspots = FanInHotspot.fromDiagnostics(diags);
      expect(hotspots.length, 3);
      expect(hotspots.first.incomingEdgeCount, 8);
      expect(hotspots.last.incomingEdgeCount, 3);
    });

    test('fromDiagnostics ignores non-fan-in diagnostics', () {
      final diags = [_fanInDiag(), _proofGapDiag()];
      final hotspots = FanInHotspot.fromDiagnostics(diags);
      expect(hotspots.length, 1);
    });

    test('riskExplanation differs based on ratio', () {
      final high = FanInHotspot(
        assetId: 'test',
        assetName: 'Test',
        assetKind: 'skill',
        incomingEdgeCount: 10,
        threshold: 3,
        severity: DiagnosticSeverity.error,
      );
      expect(high.riskExplanation, contains('critical hub'));

      final moderate = FanInHotspot(
        assetId: 'test',
        assetName: 'Test',
        assetKind: 'skill',
        incomingEdgeCount: 4,
        threshold: 3,
        severity: DiagnosticSeverity.warning,
      );
      expect(moderate.riskExplanation, contains('structural hotspot'));
    });
  });

  group('FanInHotspotsPanel', () {
    testWidgets('renders header', (tester) async {
      await tester.pumpWidget(
        _wrapInApp(FanInHotspotsPanel(hotspots: const [])),
      );
      expect(find.text('Fan-In Hotspots'), findsOneWidget);
    });

    testWidgets('renders healthy state when empty', (tester) async {
      await tester.pumpWidget(
        _wrapInApp(FanInHotspotsPanel(hotspots: const [])),
      );
      expect(find.textContaining('No fan-in hotspots'), findsOneWidget);
    });

    testWidgets('renders hotspot rows with ranking', (tester) async {
      final hotspots = [
        FanInHotspot(
          assetId: 'skill:hub',
          assetName: 'hub-skill',
          assetKind: 'skill',
          incomingEdgeCount: 8,
          threshold: 3,
          severity: DiagnosticSeverity.error,
        ),
        FanInHotspot(
          assetId: 'workflow:core',
          assetName: 'core-workflow',
          assetKind: 'workflow',
          incomingEdgeCount: 5,
          threshold: 3,
          severity: DiagnosticSeverity.warning,
        ),
      ];
      await tester.pumpWidget(
        _wrapInApp(FanInHotspotsPanel(hotspots: hotspots)),
      );
      expect(find.text('hub-skill'), findsOneWidget);
      expect(find.text('core-workflow'), findsOneWidget);
      expect(find.text('8'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('renders hotspot count badge', (tester) async {
      final hotspots = [
        FanInHotspot(
          assetId: 'skill:hub',
          assetName: 'hub-skill',
          assetKind: 'skill',
          incomingEdgeCount: 8,
          threshold: 3,
          severity: DiagnosticSeverity.error,
        ),
      ];
      await tester.pumpWidget(
        _wrapInApp(FanInHotspotsPanel(hotspots: hotspots)),
      );
      expect(find.textContaining('1 hotspot'), findsOneWidget);
    });

    testWidgets('renders risk explanation text', (tester) async {
      final hotspots = [
        FanInHotspot(
          assetId: 'skill:hub',
          assetName: 'hub-skill',
          assetKind: 'skill',
          incomingEdgeCount: 10,
          threshold: 3,
          severity: DiagnosticSeverity.error,
        ),
      ];
      await tester.pumpWidget(
        _wrapInApp(FanInHotspotsPanel(hotspots: hotspots)),
      );
      expect(find.textContaining('critical hub'), findsOneWidget);
    });
  });

  group('ReviewPressureIndicator', () {
    test('fromDiagnostics extracts proof-gap indicators', () {
      final diags = [
        _proofGapDiag(),
        _proofGapDiag(
          assetId: 'task:0613',
          taskTitle: 'Add Filters',
          taskLane: '02-doing',
          severity: DiagnosticSeverity.warning,
        ),
      ];
      final indicators = ReviewPressureIndicator.fromDiagnostics(diags);
      expect(indicators.length, 2);
      // Error severity sorts first
      expect(indicators.first.severity, DiagnosticSeverity.error);
    });

    test('fromDiagnostics ignores non-proof-gap diagnostics', () {
      final diags = [_proofGapDiag(), _fanInDiag()];
      final indicators = ReviewPressureIndicator.fromDiagnostics(diags);
      expect(indicators.length, 1);
    });

    test('explanation differs by severity', () {
      final diags = [
        _proofGapDiag(severity: DiagnosticSeverity.error),
        _proofGapDiag(
          assetId: 'task:0613',
          severity: DiagnosticSeverity.warning,
        ),
      ];
      final indicators = ReviewPressureIndicator.fromDiagnostics(diags);
      final errorInd = indicators.firstWhere(
        (i) => i.severity == DiagnosticSeverity.error,
      );
      final warnInd = indicators.firstWhere(
        (i) => i.severity == DiagnosticSeverity.warning,
      );
      expect(errorInd.explanation, contains('zero proof'));
      expect(warnInd.explanation, contains('partial proof'));
    });
  });

  group('ReviewPressureSummary', () {
    test('computes summary from indicators', () {
      final indicators = [
        ReviewPressureIndicator(
          assetId: 'task:0612',
          taskTitle: 'Test',
          lane: '03-review',
          severity: DiagnosticSeverity.error,
          explanation: 'test',
        ),
        ReviewPressureIndicator(
          assetId: 'task:0613',
          taskTitle: 'Test 2',
          lane: '03-review',
          severity: DiagnosticSeverity.warning,
          explanation: 'test',
        ),
      ];
      final summary = ReviewPressureSummary.fromIndicators(indicators);
      expect(summary.totalUnderPressure, 2);
      expect(summary.errorCount, 1);
      expect(summary.warningCount, 1);
      expect(summary.pressureByLane['03-review'], 2);
    });

    test('overviewExplanation indicates clean state when empty', () {
      const summary = ReviewPressureSummary(
        totalUnderPressure: 0,
        errorCount: 0,
        warningCount: 0,
        pressureByLane: {},
      );
      expect(summary.overviewExplanation, contains('No review pressure'));
    });

    test('overviewExplanation indicates pressure count', () {
      final summary = ReviewPressureSummary(
        totalUnderPressure: 3,
        errorCount: 2,
        warningCount: 1,
        pressureByLane: {'03-review': 2, '04-completed': 1},
      );
      expect(summary.overviewExplanation, contains('3 tasks'));
      expect(summary.overviewExplanation, contains('2 lanes'));
    });
  });

  group('ReviewPressurePanel', () {
    testWidgets('renders header', (tester) async {
      await tester.pumpWidget(
        _wrapInApp(ReviewPressurePanel(indicators: const [])),
      );
      expect(find.text('Review Queue Pressure'), findsOneWidget);
    });

    testWidgets('renders healthy state when empty', (tester) async {
      await tester.pumpWidget(
        _wrapInApp(ReviewPressurePanel(indicators: const [])),
      );
      expect(find.textContaining('No review pressure'), findsWidgets);
    });

    testWidgets('renders pressure indicators', (tester) async {
      final indicators = [
        ReviewPressureIndicator(
          assetId: 'task:0612',
          taskTitle: 'Implement Inspector',
          lane: '03-review',
          severity: DiagnosticSeverity.error,
          explanation: 'Task has zero proof in review lane.',
        ),
      ];
      await tester.pumpWidget(
        _wrapInApp(ReviewPressurePanel(indicators: indicators)),
      );
      expect(find.text('Implement Inspector'), findsOneWidget);
      expect(find.text('03-review'), findsWidgets);
      expect(find.textContaining('zero proof'), findsOneWidget);
    });

    testWidgets('renders lane breakdown chips', (tester) async {
      final indicators = [
        ReviewPressureIndicator(
          assetId: 'task:0612',
          taskTitle: 'Test',
          lane: '03-review',
          severity: DiagnosticSeverity.error,
          explanation: 'test',
        ),
        ReviewPressureIndicator(
          assetId: 'task:0613',
          taskTitle: 'Test 2',
          lane: '04-completed',
          severity: DiagnosticSeverity.warning,
          explanation: 'test',
        ),
      ];
      await tester.pumpWidget(
        _wrapInApp(ReviewPressurePanel(indicators: indicators)),
      );
      expect(find.text('03-review'), findsWidgets);
      expect(find.text('04-completed'), findsOneWidget);
    });

    testWidgets('renders overview explanation', (tester) async {
      await tester.pumpWidget(
        _wrapInApp(ReviewPressurePanel(indicators: const [])),
      );
      expect(find.textContaining('adequate proof'), findsOneWidget);
    });
  });
}
