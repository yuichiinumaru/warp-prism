// Story Panel Narrative Contract Test
// Task 1050: Validates DSStoryPanel narrative contract and DSStoryNarrativeInsight model
//
// These tests verify that the narrative insight model supports the four layers
// required by the EPIC 10 demo script: insight, evidence, risk, and connection.

import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/src/organisms/ds_story_panel.dart';

void main() {
  group('InsightRiskLevel enum', () {
    test('has exactly five risk levels', () {
      expect(InsightRiskLevel.values.length, equals(5));
    });

    test('defines none, low, medium, high, and critical', () {
      expect(InsightRiskLevel.values, contains(InsightRiskLevel.none));
      expect(InsightRiskLevel.values, contains(InsightRiskLevel.low));
      expect(InsightRiskLevel.values, contains(InsightRiskLevel.medium));
      expect(InsightRiskLevel.values, contains(InsightRiskLevel.high));
      expect(InsightRiskLevel.values, contains(InsightRiskLevel.critical));
    });
  });

  group('DSStoryInsight (base contract)', () {
    test('creates with required text only', () {
      const insight = DSStoryInsight(text: 'Test insight');
      expect(insight.text, equals('Test insight'));
      expect(insight.detail, isNull);
      expect(insight.value, isNull);
      expect(insight.color, isNull);
    });

    test('accepts optional fields', () {
      const insight = DSStoryInsight(
        text: '38 skills',
        detail: 'across 13 families',
        value: '38',
      );
      expect(insight.detail, equals('across 13 families'));
      expect(insight.value, equals('38'));
    });
  });

  group('DSStoryNarrativeInsight (narrative contract)', () {
    test('creates with required text only, defaults risk to none', () {
      const insight = DSStoryNarrativeInsight(text: 'Test');
      expect(insight.text, equals('Test'));
      expect(insight.riskLevel, equals(InsightRiskLevel.none));
      expect(insight.evidence, isNull);
      expect(insight.connection, isNull);
    });

    test('inherits base fields from DSStoryInsight', () {
      const insight = DSStoryNarrativeInsight(
        text: 'What exists',
        detail: 'file count',
        value: '40',
      );
      // DSStoryNarrativeInsight is a DSStoryInsight
      expect(insight, isA<DSStoryInsight>());
      expect(insight.detail, equals('file count'));
      expect(insight.value, equals('40'));
    });

    test('supports evidence field', () {
      const insight = DSStoryNarrativeInsight(
        text: 'README is stale',
        evidence: 'README.md',
      );
      expect(insight.evidence, equals('README.md'));
    });

    test('supports all risk levels', () {
      for (final level in InsightRiskLevel.values) {
        final insight = DSStoryNarrativeInsight(
          text: 'Risk test',
          riskLevel: level,
        );
        expect(insight.riskLevel, equals(level));
      }
    });

    test('supports connection field', () {
      const insight = DSStoryNarrativeInsight(
        text: 'Task 1010 blocks Task 1020',
        connection: 'dependsOn edge',
      );
      expect(insight.connection, equals('dependsOn edge'));
    });

    test('supports all four narrative layers simultaneously', () {
      const insight = DSStoryNarrativeInsight(
        text: 'No main.dart exists',
        detail: 'App cannot compile',
        value: '0',
        evidence: 'lib/',
        riskLevel: InsightRiskLevel.critical,
        connection: 'blocks all end-to-end verification',
      );
      expect(insight.text, isNotEmpty); // insight layer
      expect(insight.evidence, isNotNull); // evidence layer
      expect(insight.riskLevel, equals(InsightRiskLevel.critical)); // risk layer
      expect(insight.connection, isNotNull); // connection layer
    });
  });

  group('DSStoryPanel narrative contract', () {
    test('accepts DSStoryNarrativeInsight in insights list', () {
      const panel = DSStoryPanel(
        title: 'Governance',
        insights: [
          DSStoryNarrativeInsight(
            text: 'README is stale',
            evidence: 'README.md',
            riskLevel: InsightRiskLevel.high,
            connection: 'misroutes contributors',
          ),
        ],
      );
      expect(panel.insights.length, equals(1));
      expect(panel.insights.first, isA<DSStoryNarrativeInsight>());
    });

    test('accepts mixed base and narrative insights', () {
      const panel = DSStoryPanel(
        title: 'Mixed',
        insights: [
          DSStoryInsight(text: 'Base insight'),
          DSStoryNarrativeInsight(
            text: 'Narrative insight',
            evidence: 'file.dart',
            riskLevel: InsightRiskLevel.low,
          ),
        ],
      );
      expect(panel.insights.length, equals(2));
      expect(panel.insights.first, isA<DSStoryInsight>());
      expect(panel.insights.last, isA<DSStoryNarrativeInsight>());
    });

    test('accepts empty insights list', () {
      const panel = DSStoryPanel(
        title: 'Empty',
        insights: [],
      );
      expect(panel.insights, isEmpty);
    });

    test('accepts all optional fields', () {
      const panel = DSStoryPanel(
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
}
