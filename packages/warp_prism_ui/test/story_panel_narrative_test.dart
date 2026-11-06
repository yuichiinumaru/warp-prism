// Story Panel Narrative Contract Test
// Task 1050: Validates PrismStoryPanel narrative contract and
// PrismStoryNarrativeInsight model + rendering.
//
// These tests verify that the narrative insight model supports the four layers
// required by the EPIC 10 demo script: insight, evidence, risk, and connection —
// and that PrismStoryPanel paints evidence / risk / connection when provided.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

void main() {
  group('PrismInsightRiskLevel enum', () {
    test('has exactly five risk levels', () {
      expect(PrismInsightRiskLevel.values.length, equals(5));
    });

    test('defines none, low, medium, high, and critical', () {
      expect(
        PrismInsightRiskLevel.values,
        contains(PrismInsightRiskLevel.none),
      );
      expect(PrismInsightRiskLevel.values, contains(PrismInsightRiskLevel.low));
      expect(
        PrismInsightRiskLevel.values,
        contains(PrismInsightRiskLevel.medium),
      );
      expect(
        PrismInsightRiskLevel.values,
        contains(PrismInsightRiskLevel.high),
      );
      expect(
        PrismInsightRiskLevel.values,
        contains(PrismInsightRiskLevel.critical),
      );
    });

    test('public alias is usable for typed construction', () {
      const level = PrismInsightRiskLevel.critical;
      const insight = PrismStoryNarrativeInsight(
        text: 'typed via Prism alias',
        riskLevel: level,
      );
      expect(insight.riskLevel, equals(PrismInsightRiskLevel.critical));
    });
  });

  group('PrismStoryInsight (base contract)', () {
    test('creates with required text only', () {
      const insight = PrismStoryInsight(text: 'Test insight');
      expect(insight.text, equals('Test insight'));
      expect(insight.detail, isNull);
      expect(insight.value, isNull);
      expect(insight.color, isNull);
    });

    test('accepts optional fields', () {
      const insight = PrismStoryInsight(
        text: '9 agents',
        detail: 'mock_workspace/.agents/agents/',
        value: '9',
      );
      expect(insight.detail, equals('mock_workspace/.agents/agents/'));
      expect(insight.value, equals('9'));
    });
  });

  group('PrismStoryNarrativeInsight (narrative contract)', () {
    test('creates with required text only, defaults risk to none', () {
      const insight = PrismStoryNarrativeInsight(text: 'Test');
      expect(insight.text, equals('Test'));
      expect(insight.riskLevel, equals(PrismInsightRiskLevel.none));
      expect(insight.evidence, isNull);
      expect(insight.connection, isNull);
    });

    test('inherits base fields from PrismStoryInsight', () {
      const insight = PrismStoryNarrativeInsight(
        text: 'What exists',
        detail: 'fixture inventory',
        value: '9',
      );
      expect(insight, isA<PrismStoryInsight>());
      expect(insight.detail, equals('fixture inventory'));
      expect(insight.value, equals('9'));
    });

    test('supports evidence field', () {
      const insight = PrismStoryNarrativeInsight(
        text: 'Router defines /map',
        evidence: 'apps/observatory/lib/app/router.dart',
      );
      expect(insight.evidence, equals('apps/observatory/lib/app/router.dart'));
    });

    test('supports all risk levels', () {
      for (final level in PrismInsightRiskLevel.values) {
        final insight = PrismStoryNarrativeInsight(
          text: 'Risk test',
          riskLevel: level,
        );
        expect(insight.riskLevel, equals(level));
      }
    });

    test('supports connection field', () {
      const insight = PrismStoryNarrativeInsight(
        text: 'Task depends on skill',
        connection: 'EdgeKind.dependsOn',
      );
      expect(insight.connection, equals('EdgeKind.dependsOn'));
    });

    test('supports all four narrative layers simultaneously', () {
      const insight = PrismStoryNarrativeInsight(
        text: 'Operate board is fixture-backed',
        detail: 'Lane projections from mock workspace tasks',
        value: '22',
        evidence: 'apps/observatory/lib/app/pages/operate_page.dart',
        riskLevel: PrismInsightRiskLevel.low,
        connection: 'shell nav → /operate → OperateWorkspaceView',
      );
      expect(insight.text, isNotEmpty); // insight layer
      expect(insight.evidence, isNotNull); // evidence layer
      expect(
        insight.riskLevel,
        equals(PrismInsightRiskLevel.low),
      ); // risk layer
      expect(insight.connection, isNotNull); // connection layer
    });
  });

  group('PrismStoryPanel narrative contract', () {
    test('accepts PrismStoryNarrativeInsight in insights list', () {
      const panel = PrismStoryPanel(
        title: 'Governance',
        insights: [
          PrismStoryNarrativeInsight(
            text: 'Diagnostics derive risk stories',
            evidence:
                'apps/observatory/lib/features/governance/presentation/widgets/governance_story_summary.dart',
            riskLevel: PrismInsightRiskLevel.medium,
            connection: 'story → GovernanceDrilldownTarget',
          ),
        ],
      );
      expect(panel.insights.length, equals(1));
      expect(panel.insights.first, isA<PrismStoryNarrativeInsight>());
    });

    test('accepts mixed base and narrative insights', () {
      const panel = PrismStoryPanel(
        title: 'Mixed',
        insights: [
          PrismStoryInsight(text: 'Base insight'),
          PrismStoryNarrativeInsight(
            text: 'Narrative insight',
            evidence: 'apps/observatory/lib/main.dart',
            riskLevel: PrismInsightRiskLevel.low,
          ),
        ],
      );
      expect(panel.insights.length, equals(2));
      expect(panel.insights.first, isA<PrismStoryInsight>());
      expect(panel.insights.last, isA<PrismStoryNarrativeInsight>());
    });

    test('accepts empty insights list', () {
      const panel = PrismStoryPanel(title: 'Empty', insights: []);
      expect(panel.insights, isEmpty);
    });

    test('accepts all optional fields', () {
      const panel = PrismStoryPanel(
        title: 'Full panel',
        subtitle: 'With everything',
        insights: [],
      );
      expect(panel.title, equals('Full panel'));
      expect(panel.subtitle, equals('With everything'));
      expect(panel.icon, isNull);
      expect(panel.accentColor, isNull);
      expect(panel.footer, isNull);
    });
  });

  group('PrismStoryPanel renders narrative layers', () {
    testWidgets('paints evidence, risk badge, and connection', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PrismStoryPanel(
                title: 'Narrative Render',
                insights: [
                  PrismStoryNarrativeInsight(
                    text: 'Router exposes /governance',
                    detail: 'StatefulShellRoute branch',
                    value: '1',
                    evidence: 'apps/observatory/lib/app/router.dart',
                    riskLevel: PrismInsightRiskLevel.high,
                    connection: 'shell index 4 → GovernanceOverviewPage',
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Router exposes /governance'), findsOneWidget);
      expect(find.text('StatefulShellRoute branch'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(
        find.text('Evidence: apps/observatory/lib/app/router.dart'),
        findsOneWidget,
      );
      expect(
        find.text('Connection: shell index 4 → GovernanceOverviewPage'),
        findsOneWidget,
      );
      expect(find.text('high'), findsOneWidget);
    });

    testWidgets('omits risk badge and meta lines for base insights', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PrismStoryPanel(
              title: 'Base Only',
              insights: [
                PrismStoryInsight(
                  text: 'Simple insight',
                  detail: 'No narrative extras',
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Simple insight'), findsOneWidget);
      expect(find.text('No narrative extras'), findsOneWidget);
      expect(find.textContaining('Evidence:'), findsNothing);
      expect(find.textContaining('Connection:'), findsNothing);
      expect(find.text('high'), findsNothing);
      expect(find.text('critical'), findsNothing);
    });

    testWidgets('omits risk badge when riskLevel is none', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PrismStoryPanel(
              title: 'No Risk',
              insights: [
                PrismStoryNarrativeInsight(
                  text: 'Informational only',
                  evidence: 'README.md',
                  riskLevel: PrismInsightRiskLevel.none,
                  connection: 'docs → monorepo structure',
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Informational only'), findsOneWidget);
      expect(find.text('Evidence: README.md'), findsOneWidget);
      expect(
        find.text('Connection: docs → monorepo structure'),
        findsOneWidget,
      );
      expect(find.text('none'), findsNothing);
    });
  });
}
