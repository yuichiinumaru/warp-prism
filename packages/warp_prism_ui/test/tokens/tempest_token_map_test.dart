import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/src/theme/ds_theme.dart';
import 'package:warp_prism_ui/src/tokens/tokens.dart';

// Task 1882 (F-15): Tempest token map proof.
//
// Source reality (revision UNKNOWN — VCS out of scope; workspace-local routes):
// * references/ganthritor-tempest/flutter/lib/core/theme/app_colors.dart:1-47
//   — 33 named AppColors constants.
// * references/ganthritor-tempest/flutter/lib/core/theme/app_theme.dart:6-147
//   — AppTheme.darkTheme (17-slot ColorScheme).
// Backlog U-ARITH (43/50 vs 39+12) is not resolvable from in-scope sources;
// actuals recorded: 33 named + 14 mapped M3 roles = 47 rows.
void main() {
  setUp(() {
    PrismTokenRegistry.instance.reset();
  });

  tearDown(() {
    PrismTokenRegistry.instance.reset();
  });

  group('Tempest token map (Task 1882)', () {
    test('ledger holds exactly 47 rows (33 AppColors + 14 M3 roles)', () {
      expect(DSTempestTokenMap.expectedRowCount, equals(47));
      expect(DSTempestTokenMap.rows, hasLength(47));
    });

    test('owned/injected counts partition the ledger (13 + 34)', () {
      expect(DSTempestTokenMap.ownedCount, equals(13));
      expect(DSTempestTokenMap.injectedCount, equals(34));
      expect(
        DSTempestTokenMap.ownedCount + DSTempestTokenMap.injectedCount,
        equals(DSTempestTokenMap.rows.length),
      );

      var owned = 0;
      var injected = 0;
      for (final row in DSTempestTokenMap.rows) {
        final disposition = row['disposition']!;
        expect(row['tempest'], isNotEmpty);
        expect(row['prism'], isNotEmpty);
        if (disposition.startsWith('owned')) {
          owned++;
        } else if (disposition.startsWith('injected')) {
          injected++;
        } else {
          fail('unknown disposition $disposition for ${row['tempest']}');
        }
      }
      expect(owned, equals(DSTempestTokenMap.ownedCount));
      expect(injected, equals(DSTempestTokenMap.injectedCount));
    });

    test('all 33 AppColors names are dispositioned', () {
      const names = [
        'AppColors.primary',
        'AppColors.primaryLight',
        'AppColors.primaryDark',
        'AppColors.secondary',
        'AppColors.secondaryLight',
        'AppColors.secondaryDark',
        'AppColors.amberWarmth',
        'AppColors.recordRed',
        'AppColors.successGreen',
        'AppColors.warningOrange',
        'AppColors.stemVocals',
        'AppColors.stemDrums',
        'AppColors.stemBass',
        'AppColors.stemOther',
        'AppColors.stemGuitar',
        'AppColors.stemPiano',
        'AppColors.stemInstrumental',
        'AppColors.darkBackground',
        'AppColors.darkSurface',
        'AppColors.darkSurfaceElevated',
        'AppColors.darkSurfaceHighlight',
        'AppColors.darkBorder',
        'AppColors.darkTextPrimary',
        'AppColors.darkTextSecondary',
        'AppColors.darkTextTertiary',
        'AppColors.lightBackground',
        'AppColors.lightSurface',
        'AppColors.lightSurfaceElevated',
        'AppColors.lightSurfaceHighlight',
        'AppColors.lightBorder',
        'AppColors.lightTextPrimary',
        'AppColors.lightTextSecondary',
        'AppColors.lightTextTertiary',
      ];
      for (final name in names) {
        expect(
          DSTempestTokenMap.dispositionOf(name),
          isNotNull,
          reason: '$name must be dispositioned (owned vs injected)',
        );
      }
    });

    test('all 7 stems are injected, never owned', () {
      const stems = [
        'AppColors.stemVocals',
        'AppColors.stemDrums',
        'AppColors.stemBass',
        'AppColors.stemOther',
        'AppColors.stemGuitar',
        'AppColors.stemPiano',
        'AppColors.stemInstrumental',
      ];
      for (final stem in stems) {
        final row = DSTempestTokenMap.dispositionOf(stem)!;
        expect(row['disposition'], equals('injected-stem'));
      }
    });

    test('structural dark tokens resolve to live registry values', () {
      const injected = Color(0xFF7C4DFF);
      final resolved = DSTempestTokenMap.resolveDark(
        primary: injected,
        secondary: const Color(0xFF00E5FF),
        tertiary: const Color(0xFFFFB300),
        error: const Color(0xFFFF3366),
        success: const Color(0xFF00E676),
        warning: const Color(0xFFFF9100),
        stemVocals: const Color(0xFF00E5FF),
        stemDrums: const Color(0xFFFF9100),
        stemBass: const Color(0xFFB388FF),
        stemOther: const Color(0xFF00E676),
        stemGuitar: const Color(0xFFFF5252),
        stemPiano: const Color(0xFFFFD700),
        stemInstrumental: const Color(0xFF40C4FF),
      );

      // Owned slots follow the registry (Black Obsidian defaults here).
      expect(resolved.background, equals(const Color(0xFF030506)));
      expect(resolved.surface, equals(const Color(0xFF080C0E)));
      expect(resolved.elevated, equals(const Color(0xFF0C1114)));
      expect(resolved.highlight, equals(const Color(0xFF12181C)));
      expect(resolved.border, equals(const Color(0xFF121D22)));

      // Injected slots echo the caller untouched (identity, never owned).
      expect(resolved.primary, equals(injected));
      expect(resolved.stemVocals, equals(const Color(0xFF00E5FF)));
      expect(resolved.stemPiano, equals(const Color(0xFFFFD700)));
    });

    test('resolve follows registry overrides without forking tokens', () {
      PrismTokenRegistry.instance.setColor(
        PrismColorRole.obsidianDeep,
        const Color(0xFF111111),
      );
      final resolved = DSTempestTokenMap.resolveDark(
        primary: const Color(0xFF7C4DFF),
        secondary: const Color(0xFF00E5FF),
        tertiary: const Color(0xFFFFB300),
        error: const Color(0xFFFF3366),
        success: const Color(0xFF00E676),
        warning: const Color(0xFFFF9100),
        stemVocals: const Color(0xFF00E5FF),
        stemDrums: const Color(0xFFFF9100),
        stemBass: const Color(0xFFB388FF),
        stemOther: const Color(0xFF00E676),
        stemGuitar: const Color(0xFFFF5252),
        stemPiano: const Color(0xFFFFD700),
        stemInstrumental: const Color(0xFF40C4FF),
      );
      expect(resolved.background, equals(const Color(0xFF111111)));
      // Static Prism contract untouched by the override path.
      expect(DSColors.textPrimary, equals(const Color(0xFFF0F0F5)));
    });

    test('unknown keys stay UNKNOWN (null, never invented)', () {
      expect(DSTempestTokenMap.dispositionOf('AppColors.nope'), isNull);
    });

    test('Command-center theme baseline resolves (verify, never reinvent)', () {
      // Mirrors references/ganthritor-command-center/apps/command_center/lib/
      // integration/theme.dart:29-33 — DSTheme.dark() + opt-in Nerazim Teal.
      final theme = const DSNerazimTealSkin.nerazimTeal().applyToTheme(
        DSTheme.dark(),
      );
      expect(theme.colorScheme.primary, equals(const Color(0xFF00FFCC)));
      expect(theme.scaffoldBackgroundColor, equals(DSColors.obsidianDeep));
      expect(theme.extension<DSNerazimTealSkin>(), isNotNull);
    });
  });
}
