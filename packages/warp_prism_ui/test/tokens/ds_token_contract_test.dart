// Design System Token Contract Test
// Task 0014: Validates that the DS token barrel exports a coherent API
//
// These tests verify structural contracts — that classes exist, key
// properties are accessible, and the barrel export is coherent.
// They do NOT require a running Flutter app or widget tester.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:warp_prism_ui/src/tokens/tokens.dart';
import 'package:warp_prism_ui/src/atoms/atoms.dart';

void main() {
  group('DS Token Contract', () {
    group('DSColors', () {
      test(
        'obsidian background tokens match Black Obsidian contract hexes',
        () {
          expect(DSColors.obsidianDeep, equals(const Color(0xFF030506)));
          expect(DSColors.obsidianBase, equals(const Color(0xFF080C0E)));
          expect(DSColors.obsidianElevated, equals(const Color(0xFF0C1114)));
          expect(DSColors.obsidianHover, equals(const Color(0xFF12181C)));
          expect(DSColors.obsidianActive, isA<Color>());
          expect(DSColors.glassOverlay, isA<Color>());
          expect(DSColors.borderDefault, equals(const Color(0xFF121D22)));
        },
      );

      test(
        'additive blue accent ladder tokens exist and match Task 1800 hexes',
        () {
          expect(DSColors.accentBlue, equals(const Color(0xFF2F81FF)));
          expect(DSColors.accentBlueMuted, equals(const Color(0xFF1D64D8)));
          expect(DSColors.accentBlueDim, equals(const Color(0xFF114299)));
          expect(DSColors.focusRing, equals(const Color(0x802F81FF)));
        },
      );

      test(
        'collision guard: blue accent candidates are distinct from #3B82F6',
        () {
          const protectedBlue = Color(0xFF3B82F6);
          // Collision guard: accentBlue != statusInfo, governanceLocal, laneOpen
          expect(DSColors.accentBlue, isNot(equals(protectedBlue)));
          expect(DSColors.accentBlueMuted, isNot(equals(protectedBlue)));
          expect(DSColors.accentBlueDim, isNot(equals(protectedBlue)));

          expect(DSColors.statusInfo, equals(protectedBlue));
          expect(DSColors.governanceLocal, equals(protectedBlue));
          expect(DSColors.laneOpen, equals(protectedBlue));

          expect(DSColors.accentBlue, isNot(equals(DSColors.statusInfo)));
          expect(DSColors.accentBlue, isNot(equals(DSColors.governanceLocal)));
          expect(DSColors.accentBlue, isNot(equals(DSColors.laneOpen)));
        },
      );

      test('energy accent tokens exist in primary/muted/dim triplets', () {
        // Blue
        expect(DSColors.accentBlue, isA<Color>());
        expect(DSColors.accentBlueMuted, isA<Color>());
        expect(DSColors.accentBlueDim, isA<Color>());
        // Cyan
        expect(DSColors.accentCyan, isA<Color>());
        expect(DSColors.accentCyanMuted, isA<Color>());
        expect(DSColors.accentCyanDim, isA<Color>());
        // Violet
        expect(DSColors.accentViolet, isA<Color>());
        expect(DSColors.accentVioletMuted, isA<Color>());
        expect(DSColors.accentVioletDim, isA<Color>());
        // Gold
        expect(DSColors.accentGold, isA<Color>());
        expect(DSColors.accentGoldMuted, isA<Color>());
        expect(DSColors.accentGoldDim, isA<Color>());
      });

      test('semantic status tokens are protected and match contract hexes', () {
        // Success
        expect(DSColors.statusSuccess, equals(const Color(0xFF10B981)));
        expect(DSColors.statusSuccessMuted, isA<Color>());
        expect(DSColors.statusSuccessDim, isA<Color>());
        // Warning
        expect(DSColors.statusWarning, equals(const Color(0xFFF59E0B)));
        expect(DSColors.statusWarningMuted, isA<Color>());
        expect(DSColors.statusWarningDim, isA<Color>());
        // Error
        expect(DSColors.statusError, equals(const Color(0xFFEF4444)));
        expect(DSColors.statusErrorMuted, isA<Color>());
        expect(DSColors.statusErrorDim, isA<Color>());
        // Info
        expect(DSColors.statusInfo, equals(const Color(0xFF3B82F6)));
        expect(DSColors.statusInfoMuted, isA<Color>());
        expect(DSColors.statusInfoDim, isA<Color>());
      });

      test('governance colors exist for all canonicality states', () {
        expect(DSColors.governanceCanonical, isA<Color>());
        expect(DSColors.governanceLocal, isA<Color>());
        expect(DSColors.governanceGenerated, isA<Color>());
        expect(DSColors.governanceAppendOnly, isA<Color>());
        expect(DSColors.governanceArchive, isA<Color>());
        expect(DSColors.governanceMock, isA<Color>());
      });

      test('text colors exist for all emphasis levels', () {
        expect(DSColors.textPrimary, isA<Color>());
        expect(DSColors.textSecondary, isA<Color>());
        expect(DSColors.textTertiary, isA<Color>());
        expect(DSColors.textDisabled, isA<Color>());
        expect(DSColors.textInverse, isA<Color>());
      });

      test('border colors exist for all levels', () {
        expect(DSColors.borderSubtle, isA<Color>());
        expect(DSColors.borderDefault, isA<Color>());
        expect(DSColors.borderStrong, isA<Color>());
        expect(DSColors.borderGlow, isA<Color>());
      });

      test('lane colors exist for all 5 lanes', () {
        expect(DSColors.lanePlanning, isA<Color>());
        expect(DSColors.laneOpen, isA<Color>());
        expect(DSColors.laneDoing, isA<Color>());
        expect(DSColors.laneReview, isA<Color>());
        expect(DSColors.laneCompleted, isA<Color>());
      });

      test('asset kind colors exist for all 9 asset types', () {
        expect(DSColors.assetAgent, isA<Color>());
        expect(DSColors.assetSkill, isA<Color>());
        expect(DSColors.assetSubskill, isA<Color>());
        expect(DSColors.assetWorkflow, isA<Color>());
        expect(DSColors.assetTask, isA<Color>());
        expect(DSColors.assetChangelog, isA<Color>());
        expect(DSColors.assetScript, isA<Color>());
        expect(DSColors.assetReference, isA<Color>());
        expect(DSColors.assetRule, isA<Color>());
      });

      test('forAssetKind returns valid color for known kinds', () {
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
          expect(color, isA<Color>());
          expect(color, isNot(equals(DSColors.transparent)));
        }
      });

      test('forLane returns valid color for known lanes', () {
        final lanes = [
          '00-planning',
          '01-open',
          '02-doing',
          '03-review',
          '04-completed',
        ];
        for (final lane in lanes) {
          final color = DSColors.forLane(lane);
          expect(color, isA<Color>());
          expect(color, isNot(equals(DSColors.transparent)));
        }
      });

      test('forCanonicity returns valid color for known states', () {
        final states = [
          'parentcanonical',
          'childlocal',
          'generated',
          'appendonly',
          'archive',
          'mock',
        ];
        for (final state in states) {
          final color = DSColors.forCanonicity(state);
          expect(color, isA<Color>());
        }
      });
    });

    group('DSTypography', () {
      test('font family constants are defined', () {
        expect(DSTypography.fontFamilyMono, equals('JetBrainsMono'));
        expect(DSTypography.fontFamilySans, equals('Rajdhani'));
      });

      test('fallback chain constants are defined', () {
        expect(
          DSTypography.fontFamilySansFallback,
          containsAll(['Roboto', 'Helvetica Neue', 'Arial', 'sans-serif']),
        );
        expect(
          DSTypography.fontFamilyMonoFallback,
          containsAll(['Courier New', 'monospace']),
        );
      });

      test('all 18 text styles are defined', () {
        // Display
        expect(DSTypography.displayLarge, isA<TextStyle>());
        expect(DSTypography.displayMedium, isA<TextStyle>());
        expect(DSTypography.displaySmall, isA<TextStyle>());
        // Heading
        expect(DSTypography.headingLarge, isA<TextStyle>());
        expect(DSTypography.headingMedium, isA<TextStyle>());
        expect(DSTypography.headingSmall, isA<TextStyle>());
        // Body
        expect(DSTypography.bodyLarge, isA<TextStyle>());
        expect(DSTypography.bodyMedium, isA<TextStyle>());
        expect(DSTypography.bodySmall, isA<TextStyle>());
        // Label
        expect(DSTypography.labelLarge, isA<TextStyle>());
        expect(DSTypography.labelMedium, isA<TextStyle>());
        expect(DSTypography.labelSmall, isA<TextStyle>());
        // Code
        expect(DSTypography.codeLarge, isA<TextStyle>());
        expect(DSTypography.codeMedium, isA<TextStyle>());
        expect(DSTypography.codeSmall, isA<TextStyle>());
        // Numeric
        expect(DSTypography.numericLarge, isA<TextStyle>());
        expect(DSTypography.numericMedium, isA<TextStyle>());
        expect(DSTypography.numericSmall, isA<TextStyle>());
      });

      test(
        'display, heading, body, and label styles use UI sans family (Rajdhani) and fallback chain',
        () {
          final uiStyles = [
            DSTypography.displayLarge,
            DSTypography.displayMedium,
            DSTypography.displaySmall,
            DSTypography.headingLarge,
            DSTypography.headingMedium,
            DSTypography.headingSmall,
            DSTypography.bodyLarge,
            DSTypography.bodyMedium,
            DSTypography.bodySmall,
            DSTypography.labelLarge,
            DSTypography.labelMedium,
            DSTypography.labelSmall,
          ];
          for (final style in uiStyles) {
            expect(style.fontFamily, equals('Rajdhani'));
            expect(
              style.fontFamilyFallback,
              equals(DSTypography.fontFamilySansFallback),
            );
          }
        },
      );

      test('code styles use mono family and fallback chain', () {
        final codeStyles = [
          DSTypography.codeLarge,
          DSTypography.codeMedium,
          DSTypography.codeSmall,
        ];
        for (final style in codeStyles) {
          expect(style.fontFamily, equals('JetBrainsMono'));
          expect(
            style.fontFamilyFallback,
            equals(DSTypography.fontFamilyMonoFallback),
          );
        }
      });

      test('numeric styles use mono family for tabular metrics role', () {
        final numericStyles = [
          DSTypography.numericLarge,
          DSTypography.numericMedium,
          DSTypography.numericSmall,
        ];
        for (final style in numericStyles) {
          expect(style.fontFamily, equals('JetBrainsMono'));
          expect(
            style.fontFamilyFallback,
            equals(DSTypography.fontFamilyMonoFallback),
          );
        }
      });

      test('font weight constants are defined', () {
        expect(DSTypography.weightLight, equals(FontWeight.w300));
        expect(DSTypography.weightRegular, equals(FontWeight.w400));
        expect(DSTypography.weightMedium, equals(FontWeight.w500));
        expect(DSTypography.weightSemibold, equals(FontWeight.w600));
        expect(DSTypography.weightBold, equals(FontWeight.w700));
      });
    });

    group('DSSpacing', () {
      test('base scale is monotonically increasing', () {
        final scale = [
          DSSpacing.xxs,
          DSSpacing.xs,
          DSSpacing.sm,
          DSSpacing.md,
          DSSpacing.lg,
          DSSpacing.xl,
          DSSpacing.xxl,
          DSSpacing.xxxl,
          DSSpacing.huge,
          DSSpacing.massive,
        ];
        for (int i = 1; i < scale.length; i++) {
          expect(
            scale[i],
            greaterThan(scale[i - 1]),
            reason: '${_spacingName(i)} should be > ${_spacingName(i - 1)}',
          );
        }
      });

      test('semantic layout dimensions are reasonable', () {
        expect(DSSpacing.sidebarCollapsed, lessThan(DSSpacing.sidebarExpanded));
        expect(DSSpacing.topbarHeight, greaterThan(0));
        expect(
          DSSpacing.inspectorWidth,
          greaterThan(DSSpacing.sidebarExpanded),
        );
      });

      test('all spacing values are positive', () {
        expect(DSSpacing.xxs, greaterThanOrEqualTo(0));
        expect(DSSpacing.massive, greaterThan(0));
        expect(DSSpacing.sidebarCollapsed, greaterThan(0));
        expect(DSSpacing.iconButtonSize, greaterThan(0));
      });
    });

    group('DSRadii', () {
      test('base radii scale is monotonically increasing (except full)', () {
        final scale = [
          DSRadii.none,
          DSRadii.xs,
          DSRadii.sm,
          DSRadii.md,
          DSRadii.lg,
          DSRadii.xl,
          DSRadii.xxl,
        ];
        for (int i = 1; i < scale.length; i++) {
          expect(scale[i], greaterThan(scale[i - 1]));
        }
        expect(DSRadii.full, greaterThan(DSRadii.xxl));
      });

      test('semantic radii reference base values', () {
        expect(DSRadii.card, equals(DSRadii.lg));
        expect(DSRadii.button, equals(DSRadii.md));
        expect(DSRadii.chip, equals(DSRadii.sm));
        expect(DSRadii.input, equals(DSRadii.md));
        expect(DSRadii.panel, equals(DSRadii.xl));
        expect(DSRadii.modal, equals(DSRadii.xxl));
      });
    });

    group('DSShadows', () {
      test('elevation shadows exist at all 4 levels', () {
        expect(DSShadows.elevation1, isA<List<BoxShadow>>());
        expect(DSShadows.elevation2, isA<List<BoxShadow>>());
        expect(DSShadows.elevation3, isA<List<BoxShadow>>());
        expect(DSShadows.elevation4, isA<List<BoxShadow>>());
      });

      test('elevation shadows increase in complexity', () {
        expect(
          DSShadows.elevation1.length,
          lessThanOrEqualTo(DSShadows.elevation2.length),
        );
        expect(
          DSShadows.elevation2.length,
          lessThanOrEqualTo(DSShadows.elevation3.length),
        );
      });

      test('glow effects return non-empty lists', () {
        expect(DSShadows.glowBlue(), isNotEmpty);
        expect(DSShadows.glowCyan(), isNotEmpty);
        expect(DSShadows.glowViolet(), isNotEmpty);
        expect(DSShadows.glowGold(), isNotEmpty);
        expect(DSShadows.glowSuccess(), isNotEmpty);
        expect(DSShadows.glowError(), isNotEmpty);
        expect(DSShadows.glowWarning(), isNotEmpty);
      });

      test('glow effects auto-shift when derived accent colors update', () {
        final blueGlow = DSShadows.glowBlue();
        expect(blueGlow.first.color.r, closeTo(DSColors.accentBlue.r, 0.001));
        expect(blueGlow.first.color.g, closeTo(DSColors.accentBlue.g, 0.001));
        expect(blueGlow.first.color.b, closeTo(DSColors.accentBlue.b, 0.001));

        final cyanGlow = DSShadows.glowCyan();
        expect(cyanGlow.first.color.r, closeTo(DSColors.accentCyan.r, 0.001));
        expect(cyanGlow.first.color.g, closeTo(DSColors.accentCyan.g, 0.001));
        expect(cyanGlow.first.color.b, closeTo(DSColors.accentCyan.b, 0.001));
      });

      test('glow effects accept intensity parameter', () {
        final dimGlow = DSShadows.glowCyan(intensity: 0.5);
        final brightGlow = DSShadows.glowCyan(intensity: 2.0);
        expect(dimGlow, isNotEmpty);
        expect(brightGlow, isNotEmpty);
      });
    });

    group('DSMotion', () {
      test('durations are ordered from fastest to slowest', () {
        expect(DSMotion.instant, lessThan(DSMotion.fast));
        expect(DSMotion.fast, lessThan(DSMotion.normal));
        expect(DSMotion.normal, lessThan(DSMotion.slow));
        expect(DSMotion.slow, lessThan(DSMotion.slower));
        expect(DSMotion.slower, lessThan(DSMotion.slowest));
      });

      test('all curves are defined', () {
        expect(DSMotion.standard, isA<Curve>());
        expect(DSMotion.enter, isA<Curve>());
        expect(DSMotion.exit, isA<Curve>());
        expect(DSMotion.emphasized, isA<Curve>());
        expect(DSMotion.spring, isA<Curve>());
        expect(DSMotion.linear, isA<Curve>());
      });

      test('semantic animation durations are defined', () {
        expect(DSMotion.hoverDuration, isA<Duration>());
        expect(DSMotion.focusDuration, isA<Duration>());
        expect(DSMotion.pageDuration, isA<Duration>());
        expect(DSMotion.panelDuration, isA<Duration>());
        expect(DSMotion.staggerDelay, isA<Duration>());
      });
    });

    group('DSSemantics', () {
      test('status styles are defined', () {
        expect(DSSemantics.statusSuccess, isA<TextStyle>());
        expect(DSSemantics.statusWarning, isA<TextStyle>());
        expect(DSSemantics.statusError, isA<TextStyle>());
        expect(DSSemantics.statusInfo, isA<TextStyle>());
      });

      test('forAssetKind returns valid style for all kinds', () {
        final kinds = [
          'agent',
          'skill',
          'subskill',
          'workflow',
          'task',
          'changelog',
        ];
        for (final kind in kinds) {
          expect(DSSemantics.forAssetKind(kind), isA<TextStyle>());
        }
      });

      test('forLane returns valid style for all lanes', () {
        final lanes = [
          '00-planning',
          '01-open',
          '02-doing',
          '03-review',
          '04-completed',
        ];
        for (final lane in lanes) {
          expect(DSSemantics.forLane(lane), isA<TextStyle>());
        }
      });

      test('forProofState returns valid style for all states', () {
        final states = ['complete', 'partial', 'missing', null];
        for (final state in states) {
          expect(DSSemantics.forProofState(state), isA<TextStyle>());
        }
      });
    });

    group('DSBreakpoints', () {
      test('responsive thresholds are ordered and positive', () {
        expect(DSBreakpoints.narrow, equals(600));
        expect(DSBreakpoints.sidebarCollapse, equals(800));
        expect(DSBreakpoints.timelineDetail, equals(1000));
        expect(DSBreakpoints.masterDetailSideBySide, equals(1200));
        expect(DSBreakpoints.narrow, lessThan(DSBreakpoints.sidebarCollapse));
        expect(
          DSBreakpoints.sidebarCollapse,
          lessThan(DSBreakpoints.timelineDetail),
        );
        expect(
          DSBreakpoints.timelineDetail,
          lessThan(DSBreakpoints.masterDetailSideBySide),
        );
      });
    });

    group('DSOperationalState (barrel surface)', () {
      test('15 operational states are exported from tokens barrel', () {
        expect(DSOperationalState.values.length, equals(15));
        expect(
          DSOperationalState.values,
          containsAll(<DSOperationalState>[
            DSOperationalState.pending,
            DSOperationalState.running,
            DSOperationalState.approved,
            DSOperationalState.rejected,
            DSOperationalState.promoted,
            DSOperationalState.archived,
            DSOperationalState.healthy,
            DSOperationalState.degraded,
            DSOperationalState.error,
            DSOperationalState.disabled,
            DSOperationalState.unverified,
            DSOperationalState.exposed,
            DSOperationalState.redacted,
            DSOperationalState.stale,
            DSOperationalState.excluded,
          ]),
        );
      });

      test('operational color aliases exist on DSColors', () {
        expect(DSColors.statusPending, isA<Color>());
        expect(DSColors.statusRunning, isA<Color>());
        expect(DSColors.statusApproved, isA<Color>());
        expect(DSColors.statusRejected, isA<Color>());
        expect(DSColors.statusPromoted, isA<Color>());
        expect(DSColors.statusArchived, isA<Color>());
        expect(DSColors.statusHealthy, isA<Color>());
        expect(DSColors.statusDegraded, isA<Color>());
        expect(DSColors.statusOpError, isA<Color>());
        expect(DSColors.statusDisabled, isA<Color>());
        expect(DSColors.statusUnverified, isA<Color>());
        expect(DSColors.statusExposed, isA<Color>());
        expect(DSColors.statusRedacted, isA<Color>());
        expect(DSColors.statusStale, isA<Color>());
        expect(DSColors.statusExcluded, isA<Color>());
      });
    });

    group('Barrel Export Coherence', () {
      test('all token classes are accessible from tokens barrel', () {
        // These would fail at import time if barrel is broken,
        // but we verify instantiation works
        expect(DSColors.obsidianDeep, isNotNull);
        expect(DSTypography.bodyMedium, isNotNull);
        expect(DSSpacing.md, isNotNull);
        expect(DSRadii.md, isNotNull);
        expect(DSShadows.elevation1, isNotNull);
        expect(DSMotion.fast, isNotNull);
        expect(DSSemantics.statusSuccess, isNotNull);
        expect(DSBreakpoints.narrow, isNotNull);
        expect(DSOperationalState.values, isNotEmpty);
        expect(DSOperationalSeverity.values, isNotEmpty);
        expect(DSOperationalCategory.values, isNotEmpty);
      });

      test('DSTextVariant enum has all 18 variants', () {
        expect(DSTextVariant.values.length, equals(18));
      });

      test('DSIconSize enum has all 5 sizes', () {
        expect(DSIconSize.values.length, equals(5));
      });
    });
  });
}

String _spacingName(int index) {
  const names = [
    'xxs',
    'xs',
    'sm',
    'md',
    'lg',
    'xl',
    'xxl',
    'xxxl',
    'huge',
    'massive',
  ];
  return index < names.length ? names[index] : 'index_$index';
}
