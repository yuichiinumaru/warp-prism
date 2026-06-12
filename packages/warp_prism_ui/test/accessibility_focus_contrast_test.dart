import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:warp_prism_ui/src/tokens/tokens.dart';

/// Task 1010: Accessibility Contrast and Focus Pass
///
/// Regression tests for:
/// 1. WCAG AA contrast ratios on primary text/background pairs
/// 2. Text color token values
/// 3. Semantic color token existence and distinctness

/// Calculate relative luminance per WCAG 2.x
double _relativeLuminance(Color c) {
  double r = c.red / 255.0;
  double g = c.green / 255.0;
  double b = c.blue / 255.0;
  r = r <= 0.03928 ? r / 12.92 : math.pow((r + 0.055) / 1.055, 2.4).toDouble();
  g = g <= 0.03928 ? g / 12.92 : math.pow((g + 0.055) / 1.055, 2.4).toDouble();
  b = b <= 0.03928 ? b / 12.92 : math.pow((b + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

double _contrastRatio(Color fg, Color bg) {
  final l1 = _relativeLuminance(fg);
  final l2 = _relativeLuminance(bg);
  final lighter = l1 > l2 ? l1 : l2;
  final darker = l1 > l2 ? l2 : l1;
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  group('WCAG Contrast - Text on obsidianDeep', () {
    test('textPrimary meets WCAG AA (>= 4.5:1) on obsidianDeep', () {
      final ratio = _contrastRatio(DSColors.textPrimary, DSColors.obsidianDeep);
      expect(
        ratio,
        greaterThanOrEqualTo(4.5),
        reason:
            'textPrimary on obsidianDeep should be >= 4.5:1, got ${ratio.toStringAsFixed(2)}',
      );
    });

    test('textSecondary meets WCAG AA (>= 4.5:1) on obsidianDeep', () {
      final ratio = _contrastRatio(
        DSColors.textSecondary,
        DSColors.obsidianDeep,
      );
      expect(
        ratio,
        greaterThanOrEqualTo(4.5),
        reason:
            'textSecondary on obsidianDeep should be >= 4.5:1, got ${ratio.toStringAsFixed(2)}',
      );
    });

    test('textTertiary meets WCAG AA (>= 4.5:1) on obsidianDeep', () {
      final ratio = _contrastRatio(
        DSColors.textTertiary,
        DSColors.obsidianDeep,
      );
      expect(
        ratio,
        greaterThanOrEqualTo(4.5),
        reason:
            'textTertiary on obsidianDeep should be >= 4.5:1, got ${ratio.toStringAsFixed(2)}',
      );
    });

    test('textTertiary is #8888A0 (raised from #606070)', () {
      expect(
        DSColors.textTertiary,
        const Color(0xFF8888A0),
        reason: 'textTertiary must be #8888A0 for WCAG AA compliance',
      );
    });

    test('textPrimary meets WCAG AAA (>= 7:1) on obsidianDeep', () {
      final ratio = _contrastRatio(DSColors.textPrimary, DSColors.obsidianDeep);
      expect(
        ratio,
        greaterThanOrEqualTo(7.0),
        reason: 'textPrimary on obsidianDeep should be >= 7:1 for AAA',
      );
    });
  });

  group('WCAG Contrast - Text on obsidianBase', () {
    test('textTertiary meets WCAG AA (>= 4.5:1) on obsidianBase', () {
      final ratio = _contrastRatio(
        DSColors.textTertiary,
        DSColors.obsidianBase,
      );
      expect(
        ratio,
        greaterThanOrEqualTo(4.5),
        reason: 'textTertiary on obsidianBase should be >= 4.5:1',
      );
    });

    test('textSecondary meets WCAG AA (>= 4.5:1) on obsidianBase', () {
      final ratio = _contrastRatio(
        DSColors.textSecondary,
        DSColors.obsidianBase,
      );
      expect(
        ratio,
        greaterThanOrEqualTo(4.5),
        reason: 'textSecondary on obsidianBase should be >= 4.5:1',
      );
    });
  });

  group('Semantic Color Distinctness', () {
    test('statusSuccess, statusWarning, statusError are all different', () {
      expect(DSColors.statusSuccess, isNot(DSColors.statusWarning));
      expect(DSColors.statusSuccess, isNot(DSColors.statusError));
      expect(DSColors.statusWarning, isNot(DSColors.statusError));
    });

    test(
      'all status colors meet WCAG AA large text (>= 3:1) on obsidianDeep',
      () {
        final pairs = [
          DSColors.statusSuccess,
          DSColors.statusWarning,
          DSColors.statusError,
          DSColors.statusInfo,
        ];

        for (final color in pairs) {
          final ratio = _contrastRatio(color, DSColors.obsidianDeep);
          expect(
            ratio,
            greaterThanOrEqualTo(3.0),
            reason:
                '${color.toString()} on obsidianDeep must be >= 3:1 (large text minimum)',
          );
        }
      },
    );

    test('lane colors are all distinct', () {
      final laneColors = [
        DSColors.lanePlanning,
        DSColors.laneOpen,
        DSColors.laneDoing,
        DSColors.laneReview,
        DSColors.laneCompleted,
      ];
      final uniqueColors = laneColors.toSet();
      expect(
        uniqueColors.length,
        laneColors.length,
        reason: 'All 5 lane colors must be unique',
      );
    });

    test('governance colors are all distinct', () {
      final govColors = [
        DSColors.governanceCanonical,
        DSColors.governanceLocal,
        DSColors.governanceGenerated,
        DSColors.governanceAppendOnly,
        DSColors.governanceArchive,
        DSColors.governanceMock,
      ];
      final uniqueColors = govColors.toSet();
      expect(
        uniqueColors.length,
        govColors.length,
        reason: 'All 6 governance colors must be unique',
      );
    });
  });

  group('Color Token Integrity', () {
    test('forAssetKind returns non-null for all known kinds', () {
      final kinds = [
        'agent',
        'skill',
        'subskill',
        'workflow',
        'task',
        'changelog',
        'script',
        'reference',
        'rule',
      ];
      for (final kind in kinds) {
        final color = DSColors.forAssetKind(kind);
        expect(
          color,
          isNot(DSColors.transparent),
          reason: '$kind should have a non-transparent color',
        );
      }
    });

    test('forLane returns non-null for all known lanes', () {
      final lanes = [
        '00-planning',
        '01-open',
        '02-doing',
        '03-review',
        '04-completed',
      ];
      for (final lane in lanes) {
        final color = DSColors.forLane(lane);
        expect(
          color,
          isNot(DSColors.transparent),
          reason: '$lane should have a non-transparent color',
        );
      }
    });

    test('forCanonicity returns non-null for all known values', () {
      final values = [
        'parentcanonical',
        'childlocal',
        'generated',
        'appendonly',
        'archive',
        'mock',
      ];
      for (final v in values) {
        final color = DSColors.forCanonicity(v);
        expect(
          color,
          isNot(DSColors.transparent),
          reason: '$v should have a non-transparent color',
        );
      }
    });
  });

  group('Focus Indicator Colors', () {
    test('accentCyan is bright enough for focus ring visibility', () {
      expect(
        DSColors.accentCyan.red +
            DSColors.accentCyan.green +
            DSColors.accentCyan.blue,
        greaterThan(200),
        reason: 'accentCyan must be bright enough for focus indicators',
      );
    });

    test('obsidianActive is distinguishable from obsidianHover', () {
      expect(
        DSColors.obsidianActive,
        isNot(DSColors.obsidianHover),
        reason: 'Active and hover states must use different colors',
      );
    });

    test('obsidianActive is distinguishable from obsidianBase', () {
      expect(
        DSColors.obsidianActive,
        isNot(DSColors.obsidianBase),
        reason: 'Active and base states must use different colors',
      );
    });
  });
}
