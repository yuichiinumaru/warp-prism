/// Tests for governance drilldown and storytelling (Task 0813).
///
/// Covers:
/// - Drill-down from diagnostics to asset detail route targets
/// - Drill-down from hotspots to asset detail route targets
/// - Unresolved-ID fallback (empty, unknown, missing asset ID)
/// - Risk-story derivation from boundary counts + diagnostics + hotspots
/// - Story rendering in the summary widget
/// - Composed page wiring: issue/hotspot/story drill-down hooks
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_observatory/data/models/governance_diagnostics.dart';
import 'package:warp_prism_observatory/features/governance/presentation/governance_overview_page.dart';
import 'package:warp_prism_observatory/features/governance/presentation/widgets/governance_drilldown_controller.dart';
import 'package:warp_prism_observatory/features/governance/presentation/widgets/governance_story_summary.dart';
import 'package:warp_prism_observatory/features/governance/presentation/widgets/fan_in_hotspots_panel.dart';
import 'package:warp_prism_observatory/features/governance/presentation/widgets/governance_issue_group.dart';

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

GovernanceDiagnostic _diag({
  String assetId = 'task:0612',
  DiagnosticSeverity severity = DiagnosticSeverity.warning,
  DiagnosticCategory category = DiagnosticCategory.orphanAsset,
  String message = 'Test diagnostic message',
}) {
  return GovernanceDiagnostic(
    assetId: assetId,
    severity: severity,
    category: category,
    message: message,
    computedAt: DateTime(2026, 6, 7),
  );
}

List<GovernanceDiagnostic> _mixedDiagnostics() => [
  _diag(
    assetId: 'skill:orphan-skill',
    category: DiagnosticCategory.orphanAsset,
    severity: DiagnosticSeverity.warning,
    message: 'Skill has no incoming or outgoing edges',
  ),
  _diag(
    assetId: 'workflow:broken-ref',
    category: DiagnosticCategory.staleReference,
    severity: DiagnosticSeverity.error,
    message: 'References non-existent target',
  ),
  _diag(
    assetId: 'task:0612',
    category: DiagnosticCategory.proofGap,
    severity: DiagnosticSeverity.error,
    message: 'Task in completed lane but has no proof',
  ),
  _diag(
    assetId: 'task:0613',
    category: DiagnosticCategory.proofGap,
    severity: DiagnosticSeverity.warning,
    message: 'Task in completed lane but only partial proof',
  ),
  _diag(
    assetId: 'skill:hub-skill',
    category: DiagnosticCategory.highFanIn,
    severity: DiagnosticSeverity.warning,
    message: 'Asset has 8 incoming edges',
    // Fan-in context used by FanInHotspot.fromDiagnostics when present.
  ),
];

List<FanInHotspot> _testHotspots() => [
  const FanInHotspot(
    assetId: 'skill:hub-skill',
    assetName: 'Hub Skill',
    assetKind: 'skill',
    incomingEdgeCount: 8,
    threshold: 3,
    severity: DiagnosticSeverity.warning,
  ),
  const FanInHotspot(
    assetId: 'agent:central-agent',
    assetName: 'Central Agent',
    assetKind: 'agent',
    incomingEdgeCount: 5,
    threshold: 3,
    severity: DiagnosticSeverity.warning,
  ),
];

Widget _wrapInApp(Widget child) {
  return MaterialApp(
    home: Scaffold(body: SizedBox(width: 1200, height: 900, child: child)),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('GovernanceDrilldownController', () {
    group('resolveDiagnosticDrilldown', () {
      test('resolves valid diagnostic to drilldown target', () {
        final diag = _diag(assetId: 'task:0612');
        final target = resolveDiagnosticDrilldown(diag);

        expect(target, isNotNull);
        expect(target!.assetId, 'task:0612');
        expect(target.routePath, '/assets/task%3A0612');
        expect(target.sourceLabel, contains('orphanAsset'));
        expect(target.isNavigable, isTrue);
      });

      test('preserves diagnostic category', () {
        final diag = _diag(
          assetId: 'task:0612',
          category: DiagnosticCategory.proofGap,
        );
        final target = resolveDiagnosticDrilldown(diag);

        expect(target!.category, DiagnosticCategory.proofGap);
      });

      test('returns null for empty asset ID', () {
        final diag = _diag(assetId: '');
        final target = resolveDiagnosticDrilldown(diag);

        expect(target, isNull);
      });

      test('returns null for unknown asset ID', () {
        final diag = _diag(assetId: 'unknown');
        expect(resolveDiagnosticDrilldown(diag), isNull);
      });
    });

    group('resolveHotspotDrilldown', () {
      test('resolves hotspot to drilldown target', () {
        final hotspot = _testHotspots().first;
        final target = resolveHotspotDrilldown(hotspot);

        expect(target.assetId, 'skill:hub-skill');
        expect(target.routePath, '/assets/skill%3Ahub-skill');
        expect(target.sourceLabel, contains('Fan-in hotspot'));
        expect(target.sourceLabel, contains('8 incoming'));
        expect(target.isNavigable, isTrue);
      });

      test('unresolved hotspot degrades without throwing', () {
        const hotspot = FanInHotspot(
          assetId: '',
          assetName: 'Ghost',
          assetKind: 'skill',
          incomingEdgeCount: 4,
          threshold: 3,
          severity: DiagnosticSeverity.warning,
        );
        final target = resolveHotspotDrilldown(hotspot);
        expect(target.isNavigable, isFalse);
        expect(target.sourceLabel, contains('Ghost'));
      });
    });

    group('resolveAssetIdDrilldown', () {
      test('resolves valid asset ID', () {
        final target = resolveAssetIdDrilldown('agent:test');

        expect(target, isNotNull);
        expect(target!.assetId, 'agent:test');
        expect(target.routePath, '/assets/agent%3Atest');
      });

      test('returns null for empty string', () {
        expect(resolveAssetIdDrilldown(''), isNull);
      });

      test('returns null for "unknown"', () {
        expect(resolveAssetIdDrilldown('unknown'), isNull);
      });
    });
  });

  group('Governance Risk Story Derivation', () {
    test('derives proof gap story from diagnostics', () {
      final diagnostics = [
        _diag(
          assetId: 'task:0612',
          category: DiagnosticCategory.proofGap,
          severity: DiagnosticSeverity.error,
          message: 'No proof',
        ),
        _diag(
          assetId: 'task:0613',
          category: DiagnosticCategory.proofGap,
          severity: DiagnosticSeverity.warning,
          message: 'Partial proof',
        ),
      ];

      final stories = deriveGovernanceRiskStories(
        diagnostics: diagnostics,
        boundaryCounts: {'parentCanonical': 10},
        totalAssets: 12,
      );

      final proofStory = stories
          .where((s) => s.title.contains('Proof'))
          .toList();
      expect(proofStory, isNotEmpty);
      expect(proofStory.first.narrative, contains('2'));
      expect(proofStory.first.involvedAssetIds.length, 2);
      expect(proofStory.first.severity, GovernanceStorySeverity.critical);
    });

    test('derives orphan story from diagnostics', () {
      final diagnostics = [
        _diag(
          assetId: 'skill:orphan',
          category: DiagnosticCategory.orphanAsset,
          message: 'Isolated',
        ),
      ];

      final stories = deriveGovernanceRiskStories(
        diagnostics: diagnostics,
        boundaryCounts: {},
        totalAssets: 5,
      );

      final orphanStory = stories
          .where((s) => s.title.contains('Orphan'))
          .toList();
      expect(orphanStory, isNotEmpty);
      expect(orphanStory.first.narrative, contains('1'));
      expect(orphanStory.first.involvedAssetIds, contains('skill:orphan'));
    });

    test('derives stale reference story from diagnostics', () {
      final diagnostics = [
        _diag(
          assetId: 'workflow:broken',
          category: DiagnosticCategory.staleReference,
          severity: DiagnosticSeverity.error,
          message: 'Broken ref',
        ),
      ];

      final stories = deriveGovernanceRiskStories(
        diagnostics: diagnostics,
        boundaryCounts: {},
        totalAssets: 5,
      );

      final staleStory = stories
          .where((s) => s.title.contains('Broken'))
          .toList();
      expect(staleStory, isNotEmpty);
      expect(staleStory.first.severity, GovernanceStorySeverity.critical);
    });

    test('derives fan-in hotspot story', () {
      final stories = deriveGovernanceRiskStories(
        diagnostics: [],
        boundaryCounts: {'parentCanonical': 10},
        totalAssets: 12,
        hotspots: _testHotspots(),
      );

      final hotspotStory = stories
          .where((s) => s.title.contains('hotspot'))
          .toList();
      expect(hotspotStory, isNotEmpty);
      expect(hotspotStory.first.narrative, contains('Hub Skill'));
      expect(hotspotStory.first.narrative, contains('8'));
      expect(hotspotStory.first.involvedAssetIds.length, 2);
    });

    test('derives boundary overview story', () {
      final stories = deriveGovernanceRiskStories(
        diagnostics: [],
        boundaryCounts: {'parentCanonical': 8},
        totalAssets: 10,
      );

      final boundaryStory = stories
          .where((s) => s.title.contains('Boundary'))
          .toList();
      expect(boundaryStory, isNotEmpty);
      expect(boundaryStory.first.severity, GovernanceStorySeverity.healthy);
    });

    test('derives warning when canonical coverage below 50%', () {
      final stories = deriveGovernanceRiskStories(
        diagnostics: [],
        boundaryCounts: {'parentCanonical': 2},
        totalAssets: 10,
      );

      final boundaryStory = stories
          .where((s) => s.title.contains('Canonical'))
          .toList();
      expect(boundaryStory, isNotEmpty);
      expect(boundaryStory.first.severity, GovernanceStorySeverity.warning);
    });

    test('adds healthy summary when no diagnostics', () {
      final stories = deriveGovernanceRiskStories(
        diagnostics: [],
        boundaryCounts: {'parentCanonical': 10},
        totalAssets: 10,
      );

      final hasHealthy = stories.any(
        (s) => s.severity == GovernanceStorySeverity.healthy,
      );
      expect(hasHealthy, isTrue);
    });

    test('combines multiple story types', () {
      final diagnostics = _mixedDiagnostics();

      final stories = deriveGovernanceRiskStories(
        diagnostics: diagnostics,
        boundaryCounts: {'parentCanonical': 5},
        totalAssets: 10,
        hotspots: _testHotspots(),
      );

      // Should have: boundary, proof, orphan, stale, hotspot stories
      expect(stories.length, greaterThanOrEqualTo(4));
    });
  });

  group('GovernanceStorySummary widget', () {
    testWidgets('renders story titles', (tester) async {
      final stories = [
        const GovernanceRiskStory(
          title: 'Test Story',
          narrative: 'Test narrative text',
          severity: GovernanceStorySeverity.warning,
        ),
      ];

      await tester.pumpWidget(
        _wrapInApp(GovernanceStorySummary(stories: stories)),
      );

      expect(find.text('Test Story'), findsOneWidget);
      expect(find.text('Test narrative text'), findsOneWidget);
      expect(find.text('Risk Stories'), findsOneWidget);
    });

    testWidgets('renders header', (tester) async {
      await tester.pumpWidget(
        _wrapInApp(const GovernanceStorySummary(stories: [])),
      );

      expect(find.text('Risk Stories'), findsOneWidget);
    });

    testWidgets('renders empty state when no stories', (tester) async {
      await tester.pumpWidget(
        _wrapInApp(const GovernanceStorySummary(stories: [])),
      );

      expect(find.textContaining('No governance data'), findsOneWidget);
    });

    testWidgets('renders drilldown link for story with asset IDs', (
      tester,
    ) async {
      final stories = [
        const GovernanceRiskStory(
          title: 'Proof Gap',
          narrative: '1 task lacks proof',
          severity: GovernanceStorySeverity.critical,
          involvedAssetIds: ['task:0612'],
        ),
      ];

      GovernanceDrilldownTarget? captured;
      await tester.pumpWidget(
        _wrapInApp(
          GovernanceStorySummary(
            stories: stories,
            onDrilldown: (target) => captured = target,
          ),
        ),
      );

      expect(find.textContaining('View task:0612'), findsOneWidget);

      await tester.tap(find.textContaining('View task:0612'));
      await tester.pump();
      expect(captured, isNotNull);
      expect(captured!.assetId, 'task:0612');
      expect(captured!.routePath, '/assets/task%3A0612');
      expect(captured!.isNavigable, isTrue);
    });

    testWidgets('renders multi-asset drilldown link', (tester) async {
      final stories = [
        const GovernanceRiskStory(
          title: 'Multiple Issues',
          narrative: 'Several tasks affected',
          severity: GovernanceStorySeverity.warning,
          involvedAssetIds: ['task:001', 'task:002', 'task:003'],
        ),
      ];

      await tester.pumpWidget(
        _wrapInApp(
          GovernanceStorySummary(stories: stories, onDrilldown: (_) {}),
        ),
      );

      expect(find.textContaining('View 3 assets'), findsOneWidget);
    });

    testWidgets('severity value renders for non-healthy stories', (
      tester,
    ) async {
      final stories = [
        const GovernanceRiskStory(
          title: 'Critical Issue',
          narrative: 'Something bad',
          severity: GovernanceStorySeverity.critical,
        ),
      ];

      await tester.pumpWidget(
        _wrapInApp(GovernanceStorySummary(stories: stories)),
      );

      expect(find.text('critical'), findsOneWidget);
    });

    testWidgets('renders multiple stories from fixture diagnostics', (
      tester,
    ) async {
      final stories = deriveGovernanceRiskStories(
        diagnostics: _mixedDiagnostics(),
        boundaryCounts: {'parentCanonical': 5},
        totalAssets: 10,
        hotspots: _testHotspots(),
      );

      await tester.pumpWidget(
        _wrapInApp(GovernanceStorySummary(stories: stories)),
      );

      expect(find.text('Risk Stories'), findsOneWidget);
      expect(find.textContaining('Proof integrity'), findsOneWidget);
      expect(find.textContaining('Orphan assets'), findsOneWidget);
    });
  });

  group('Issue and hotspot drill-down hooks', () {
    testWidgets('issue row fires drilldown with stable asset id', (
      tester,
    ) async {
      final groups = buildIssueGroups([
        _diag(
          assetId: 'skill:orphan-skill',
          category: DiagnosticCategory.orphanAsset,
          message: 'Isolated skill',
        ),
      ]);

      GovernanceDrilldownTarget? captured;
      await tester.pumpWidget(
        _wrapInApp(
          GovernanceIssueGroup(
            group: groups.first,
            onDrilldown: (target) => captured = target,
          ),
        ),
      );

      expect(find.textContaining('Open detail'), findsOneWidget);
      await tester.tap(find.textContaining('Open detail'));
      await tester.pump();

      expect(captured, isNotNull);
      expect(captured!.assetId, 'skill:orphan-skill');
      expect(captured!.routePath, '/assets/skill%3Aorphan-skill');
    });

    testWidgets('hotspot row fires drilldown with stable asset id', (
      tester,
    ) async {
      GovernanceDrilldownTarget? captured;
      await tester.pumpWidget(
        _wrapInApp(
          FanInHotspotsPanel(
            hotspots: _testHotspots(),
            onDrilldown: (target) => captured = target,
          ),
        ),
      );

      // First hotspot Open detail
      await tester.tap(find.textContaining('Open detail').first);
      await tester.pump();

      expect(captured, isNotNull);
      expect(captured!.assetId, 'skill:hub-skill');
      expect(captured!.routePath, '/assets/skill%3Ahub-skill');
    });

    testWidgets('empty asset id issue does not crash and has no drilldown', (
      tester,
    ) async {
      final groups = buildIssueGroups([
        _diag(assetId: '', message: 'Missing id diagnostic'),
      ]);

      var called = false;
      await tester.pumpWidget(
        _wrapInApp(
          GovernanceIssueGroup(
            group: groups.first,
            onDrilldown: (_) => called = true,
          ),
        ),
      );

      expect(find.textContaining('Open detail'), findsNothing);
      expect(called, isFalse);
    });
  });

  group('Composed GovernanceOverviewPage storytelling', () {
    testWidgets('renders risk stories from summary diagnostics', (
      tester,
    ) async {
      final summary = CanonicalityBoundarySummary(
        counts: {'parentCanonical': 5, 'generated': 2},
        totalAssets: 10,
        diagnostics: _mixedDiagnostics(),
        hotspots: _testHotspots(),
      );

      await tester.pumpWidget(
        _wrapInApp(GovernanceOverviewPage(summary: summary)),
      );

      expect(find.text('Risk Stories'), findsOneWidget);
      expect(find.textContaining('Proof integrity'), findsOneWidget);
      expect(find.text('Fan-In Hotspots'), findsOneWidget);
      expect(find.text('BOUNDARY OVERVIEW'), findsOneWidget);
    });

    testWidgets('story drilldown callback receives navigable target', (
      tester,
    ) async {
      final summary = CanonicalityBoundarySummary(
        counts: {'parentCanonical': 5},
        totalAssets: 10,
        diagnostics: [
          _diag(
            assetId: 'task:0612',
            category: DiagnosticCategory.proofGap,
            severity: DiagnosticSeverity.error,
            message: 'No proof',
          ),
        ],
      );

      GovernanceDrilldownTarget? captured;
      await tester.pumpWidget(
        _wrapInApp(
          GovernanceOverviewPage(
            summary: summary,
            onDrilldown: (target) => captured = target,
          ),
        ),
      );

      expect(find.textContaining('View task:0612'), findsOneWidget);
      await tester.tap(find.textContaining('View task:0612'));
      await tester.pump();

      expect(captured, isNotNull);
      expect(captured!.assetId, 'task:0612');
      expect(captured!.isNavigable, isTrue);
    });

    testWidgets('unresolved snackbar fallback does not throw', (tester) async {
      final summary = CanonicalityBoundarySummary(
        counts: {'parentCanonical': 1},
        totalAssets: 1,
        diagnostics: const [],
        hotspots: const [
          FanInHotspot(
            assetId: '',
            assetName: 'Ghost Hub',
            assetKind: 'skill',
            incomingEdgeCount: 9,
            threshold: 3,
            severity: DiagnosticSeverity.warning,
          ),
        ],
      );

      await tester.pumpWidget(
        _wrapInApp(GovernanceOverviewPage(summary: summary)),
      );

      // Unresolved hotspot shows non-interactive fallback, page still paints.
      expect(find.text('Ghost Hub'), findsOneWidget);
      expect(find.textContaining('Detail unavailable'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('GovernanceDrilldownTarget', () {
    test('routePath follows canonical pattern', () {
      final target = GovernanceDrilldownTarget(
        assetId: 'skill:test',
        routePath: '/assets/skill:test',
        sourceLabel: 'test',
      );

      expect(target.routePath, '/assets/skill:test');
      expect(target.routePath, startsWith('/assets/'));
    });

    test('toString includes source label', () {
      final target = GovernanceDrilldownTarget(
        assetId: 'task:001',
        routePath: '/assets/task:001',
        sourceLabel: 'proof gap',
      );

      expect(target.toString(), contains('task:001'));
      expect(target.toString(), contains('proof gap'));
    });

    test('unresolved factory marks non-navigable', () {
      final target = GovernanceDrilldownTarget.unresolved(
        attemptedId: '',
        sourceLabel: 'missing',
      );
      expect(target.isNavigable, isFalse);
      expect(target.routePath, startsWith('/assets/'));
    });
  });

  group('Graceful degradation', () {
    test('empty diagnostics produces no issue stories', () {
      final stories = deriveGovernanceRiskStories(
        diagnostics: [],
        boundaryCounts: {},
        totalAssets: 0,
      );

      expect(stories, isEmpty);
    });

    test('drilldown from diagnostic with empty assetId returns null', () {
      final diag = _diag(assetId: '');
      expect(resolveDiagnosticDrilldown(diag), isNull);
    });

    test('story with empty involvedAssetIds has no drilldown', () {
      const story = GovernanceRiskStory(
        title: 'Test',
        narrative: 'No assets',
        severity: GovernanceStorySeverity.info,
        involvedAssetIds: [],
      );

      expect(story.involvedAssetIds, isEmpty);
    });
  });
}
