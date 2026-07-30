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
      test('obsidian background tokens exist and are non-null', () {
        expect(DSColors.obsidianDeep, isA<Color>());
        expect(DSColors.obsidianBase, isA<Color>());
        expect(DSColors.obsidianElevated, isA<Color>());
        expect(DSColors.obsidianHover, isA<Color>());
        expect(DSColors.obsidianActive, isA<Color>());
        expect(DSColors.glassOverlay, isA<Color>());
      });

      test('energy accent tokens exist in primary/muted/dim triplets', () {
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

      test('semantic status tokens exist in primary/muted/dim triplets', () {
        // Success
        expect(DSColors.statusSuccess, isA<Color>());
        expect(DSColors.statusSuccessMuted, isA<Color>());
        expect(DSColors.statusSuccessDim, isA<Color>());
        // Warning
        expect(DSColors.statusWarning, isA<Color>());
        expect(DSColors.statusWarningMuted, isA<Color>());
        expect(DSColors.statusWarningDim, isA<Color>());
        // Error
        expect(DSColors.statusError, isA<Color>());
        expect(DSColors.statusErrorMuted, isA<Color>());
        expect(DSColors.statusErrorDim, isA<Color>());
        // Info
        expect(DSColors.statusInfo, isA<Color>());
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
        expect(DSTypography.fontFamilySans, equals('Inter'));
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

      test('display styles use sans-serif family', () {
        expect(DSTypography.displayLarge.fontFamily, equals('Inter'));
        expect(DSTypography.displayMedium.fontFamily, equals('Inter'));
        expect(DSTypography.displaySmall.fontFamily, equals('Inter'));
      });

      test('code styles use mono family', () {
        expect(DSTypography.codeLarge.fontFamily, equals('JetBrainsMono'));
        expect(DSTypography.codeMedium.fontFamily, equals('JetBrainsMono'));
        expect(DSTypography.codeSmall.fontFamily, equals('JetBrainsMono'));
      });

      test('numeric styles use mono family', () {
        expect(DSTypography.numericLarge.fontFamily, equals('JetBrainsMono'));
        expect(DSTypography.numericMedium.fontFamily, equals('JetBrainsMono'));
        expect(DSTypography.numericSmall.fontFamily, equals('JetBrainsMono'));
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
        expect(DSShadows.glowCyan(), isNotEmpty);
        expect(DSShadows.glowViolet(), isNotEmpty);
        expect(DSShadows.glowGold(), isNotEmpty);
        expect(DSShadows.glowSuccess(), isNotEmpty);
        expect(DSShadows.glowError(), isNotEmpty);
        expect(DSShadows.glowWarning(), isNotEmpty);
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
