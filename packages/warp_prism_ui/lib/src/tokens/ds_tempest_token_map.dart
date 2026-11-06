import 'package:flutter/material.dart';

import 'ds_colors.dart';
import 'prism_token_registry.dart';

/// Tempest token → Prism disposition map (Task 1882, convergence wiring).
///
/// Maps the Tempest `AppTheme` + `AppColors` token layer onto
/// [PrismTokenRegistry] + the `DSTheme.dark()` M3 factory + accent skins.
/// This file is **wiring, not a primitive**: it introduces no new token
/// values, no new [PrismColorRole], and no new `DSColors` statics. Tempest
/// stem/domain colours stay **injected** — [resolveDark] echoes them back to
/// the caller and never bakes them into Prism tokens.
///
/// Source reality observed (revision UNKNOWN — VCS reads are out of scope
/// for this worker; paths below are workspace-local symlink routes):
///
/// * `references/ganthritor-tempest/flutter/lib/core/theme/app_colors.dart:1-47`
///   — 33 named `AppColors` constants (10 brand/alert, 7 stems, 8 dark, 8 light).
/// * `references/ganthritor-tempest/flutter/lib/core/theme/app_theme.dart:6-147`
///   — `AppTheme.darkTheme`: 17-slot dark `ColorScheme` + structural themes.
/// * `references/ganthritor-tempest/flutter/lib/core/layout/main_shell.dart:9-203`
///   — `MainShellLayout`: 7-branch rail (`main_shell.dart:155-191`).
/// * `references/ganthritor-command-center/apps/command_center/lib/integration/theme.dart:1-48`
///   — Command-center baseline, already consuming (`PrismTheme.dark()` +
///   opt-in `PrismNerazimTealSkin`); verified, never reinvented here.
///
/// Token arithmetic (actuals, recorded per backlog U-ARITH): 33 named
/// `AppColors` constants + 14 mapped `AppTheme` dark M3 roles = 47 rows.
/// The 17 dark `ColorScheme` slots minus 3 framework constants
/// (`onPrimary`/`onTertiary` white, `onSecondary` black) = 14 mapped roles.
/// Structural `ThemeData` applications (`scaffoldBackgroundColor`,
/// `canvasColor`, `cardColor`, `dividerColor`) reuse the dark rows, not new rows.
///
/// Dispositions:
///
/// * `owned-registry` — structural dark token served by a [PrismColorRole].
/// * `owned-prism` — text token served by an existing `DSColors` static or
///   the `DSTheme.dark()` factory (no new values).
/// * `injected*` — Tempest brand/stem/domain/light/framework colour the
///   consumer passes in; Prism never owns it.
abstract final class DSTempestTokenMap {
  /// Total dispositioned rows: 33 `AppColors` + 14 `AppTheme` M3 roles.
  static const int expectedRowCount = 47;

  /// Rows with an `owned-*` disposition (served by Prism tokens/factory).
  static const int ownedCount = 13;

  /// Rows with an `injected*` disposition (caller-supplied, never owned).
  static const int injectedCount = 34;

  /// One row per Tempest token: Tempest-side key, Tempest literal (or
  /// `framework` for white/black constants), disposition, and Prism target
  /// or injection note. Foreign hexes live **only** in this ledger —
  /// `token_1882_no_forked_tempest_tokens_in_prism` keeps every other file
  /// under `tokens/` free of them.
  static const List<Map<String, String>> rows = [
    // --- AppColors brand / accents (injected; Prism counterpart noted) ---
    {
      'tempest': 'AppColors.primary',
      'hex': '#7C4DFF',
      'disposition': 'injected',
      'prism':
          'consumer injects; Prism counterpart PrismColors.accentBlue (no rebrand)',
    },
    {
      'tempest': 'AppColors.primaryLight',
      'hex': '#B47CFF',
      'disposition': 'injected',
      'prism':
          'consumer injects; Prism counterpart PrismColors.accentViolet family',
    },
    {
      'tempest': 'AppColors.primaryDark',
      'hex': '#3F1DCB',
      'disposition': 'injected',
      'prism':
          'consumer injects; Prism counterpart PrismColors.accentBlueDim role',
    },
    {
      'tempest': 'AppColors.secondary',
      'hex': '#00E5FF',
      'disposition': 'injected',
      'prism':
          'consumer injects; Prism counterpart PrismColors.accentCyan (data accent)',
    },
    {
      'tempest': 'AppColors.secondaryLight',
      'hex': '#6EFFFF',
      'disposition': 'injected',
      'prism': 'consumer injects alongside secondary',
    },
    {
      'tempest': 'AppColors.secondaryDark',
      'hex': '#00B2CC',
      'disposition': 'injected',
      'prism': 'consumer injects alongside secondary',
    },
    {
      'tempest': 'AppColors.amberWarmth',
      'hex': '#FFB300',
      'disposition': 'injected-domain',
      'prism':
          'consumer injects; Prism equivalent PrismColors.accentGold available',
    },
    {
      'tempest': 'AppColors.recordRed',
      'hex': '#FF3366',
      'disposition': 'injected-domain',
      'prism':
          'consumer injects; Prism equivalent PrismColors.statusError available',
    },
    {
      'tempest': 'AppColors.successGreen',
      'hex': '#00E676',
      'disposition': 'injected-domain',
      'prism':
          'consumer injects; Prism equivalent PrismColors.statusSuccess available',
    },
    {
      'tempest': 'AppColors.warningOrange',
      'hex': '#FF9100',
      'disposition': 'injected-domain',
      'prism':
          'consumer injects; Prism equivalent PrismColors.statusWarning available',
    },
    // --- AppColors stems (injected; never owned — domain leakage rule) ---
    {
      'tempest': 'AppColors.stemVocals',
      'hex': '#00E5FF',
      'disposition': 'injected-stem',
      'prism':
          'per-item DSSidebarItem.color / caller palette slot; never a Prism token',
    },
    {
      'tempest': 'AppColors.stemDrums',
      'hex': '#FF9100',
      'disposition': 'injected-stem',
      'prism':
          'per-item DSSidebarItem.color / caller palette slot; never a Prism token',
    },
    {
      'tempest': 'AppColors.stemBass',
      'hex': '#B388FF',
      'disposition': 'injected-stem',
      'prism':
          'per-item DSSidebarItem.color / caller palette slot; never a Prism token',
    },
    {
      'tempest': 'AppColors.stemOther',
      'hex': '#00E676',
      'disposition': 'injected-stem',
      'prism':
          'per-item DSSidebarItem.color / caller palette slot; never a Prism token',
    },
    {
      'tempest': 'AppColors.stemGuitar',
      'hex': '#FF5252',
      'disposition': 'injected-stem',
      'prism':
          'per-item DSSidebarItem.color / caller palette slot; never a Prism token',
    },
    {
      'tempest': 'AppColors.stemPiano',
      'hex': '#FFD700',
      'disposition': 'injected-stem',
      'prism':
          'per-item DSSidebarItem.color / caller palette slot; never a Prism token',
    },
    {
      'tempest': 'AppColors.stemInstrumental',
      'hex': '#40C4FF',
      'disposition': 'injected-stem',
      'prism':
          'per-item DSSidebarItem.color / caller palette slot; never a Prism token',
    },
    // --- AppColors dark palette (owned by Prism registry / statics) ---
    {
      'tempest': 'AppColors.darkBackground',
      'hex': '#0E0F14',
      'disposition': 'owned-registry',
      'prism': 'PrismColorRole.obsidianDeep',
    },
    {
      'tempest': 'AppColors.darkSurface',
      'hex': '#161820',
      'disposition': 'owned-registry',
      'prism': 'PrismColorRole.obsidianBase',
    },
    {
      'tempest': 'AppColors.darkSurfaceElevated',
      'hex': '#1E212D',
      'disposition': 'owned-registry',
      'prism': 'PrismColorRole.obsidianElevated',
    },
    {
      'tempest': 'AppColors.darkSurfaceHighlight',
      'hex': '#282C3C',
      'disposition': 'owned-registry',
      'prism': 'PrismColorRole.obsidianHover',
    },
    {
      'tempest': 'AppColors.darkBorder',
      'hex': '#2C3042',
      'disposition': 'owned-registry',
      'prism': 'PrismColorRole.borderDefault',
    },
    {
      'tempest': 'AppColors.darkTextPrimary',
      'hex': '#F1F3F9',
      'disposition': 'owned-prism',
      'prism': 'PrismColors.textPrimary (existing static)',
    },
    {
      'tempest': 'AppColors.darkTextSecondary',
      'hex': '#A0A6B8',
      'disposition': 'owned-prism',
      'prism': 'PrismColors.textSecondary (existing static)',
    },
    {
      'tempest': 'AppColors.darkTextTertiary',
      'hex': '#6B7280',
      'disposition': 'owned-prism',
      'prism': 'PrismColors.textTertiary (existing static)',
    },
    // --- AppColors light palette (injected; Prism is dark-only scope) ---
    {
      'tempest': 'AppColors.lightBackground',
      'hex': '#F3F5FA',
      'disposition': 'injected-light',
      'prism': 'out of Prism dark-only scope; consumer owns light theme',
    },
    {
      'tempest': 'AppColors.lightSurface',
      'hex': '#FFFFFF',
      'disposition': 'injected-light',
      'prism': 'out of Prism dark-only scope; consumer owns light theme',
    },
    {
      'tempest': 'AppColors.lightSurfaceElevated',
      'hex': '#E8ECF4',
      'disposition': 'injected-light',
      'prism': 'out of Prism dark-only scope; consumer owns light theme',
    },
    {
      'tempest': 'AppColors.lightSurfaceHighlight',
      'hex': '#DCE2EE',
      'disposition': 'injected-light',
      'prism': 'out of Prism dark-only scope; consumer owns light theme',
    },
    {
      'tempest': 'AppColors.lightBorder',
      'hex': '#D0D7E5',
      'disposition': 'injected-light',
      'prism': 'out of Prism dark-only scope; consumer owns light theme',
    },
    {
      'tempest': 'AppColors.lightTextPrimary',
      'hex': '#141722',
      'disposition': 'injected-light',
      'prism': 'out of Prism dark-only scope; consumer owns light theme',
    },
    {
      'tempest': 'AppColors.lightTextSecondary',
      'hex': '#555E75',
      'disposition': 'injected-light',
      'prism': 'out of Prism dark-only scope; consumer owns light theme',
    },
    {
      'tempest': 'AppColors.lightTextTertiary',
      'hex': '#8B94A7',
      'disposition': 'injected-light',
      'prism': 'out of Prism dark-only scope; consumer owns light theme',
    },
    // --- AppTheme.darkTheme M3 roles (app_theme.dart:7-25) ---
    {
      'tempest': 'AppTheme.dark.colorScheme.primary',
      'hex': '#7C4DFF',
      'disposition': 'injected',
      'prism':
          'DSTheme.dark primary is PrismColors.accentBlue; Tempest violet stays injected (skin slot, never owned)',
    },
    {
      'tempest': 'AppTheme.dark.colorScheme.onPrimary',
      'hex': 'framework',
      'disposition': 'injected-framework',
      'prism':
          'Colors.white framework constant; DSTheme.dark onPrimary is PrismColors.white',
    },
    {
      'tempest': 'AppTheme.dark.colorScheme.primaryContainer',
      'hex': '#3F1DCB',
      'disposition': 'injected',
      'prism':
          'consumer injects; Prism counterpart primaryContainer PrismColors.accentBlueDim',
    },
    {
      'tempest': 'AppTheme.dark.colorScheme.onPrimaryContainer',
      'hex': '#B47CFF',
      'disposition': 'injected',
      'prism': 'consumer injects alongside primaryContainer',
    },
    {
      'tempest': 'AppTheme.dark.colorScheme.secondary',
      'hex': '#00E5FF',
      'disposition': 'injected',
      'prism':
          'DSTheme.dark secondary is PrismColors.accentViolet; Tempest cyan stays injected',
    },
    {
      'tempest': 'AppTheme.dark.colorScheme.secondaryContainer',
      'hex': '#004D5A',
      'disposition': 'injected',
      'prism':
          'consumer injects; inline literal in AppTheme, never a Prism token',
    },
    {
      'tempest': 'AppTheme.dark.colorScheme.onSecondaryContainer',
      'hex': '#6EFFFF',
      'disposition': 'injected',
      'prism': 'consumer injects alongside secondaryContainer',
    },
    {
      'tempest': 'AppTheme.dark.colorScheme.tertiary',
      'hex': '#FFB300',
      'disposition': 'injected-domain',
      'prism':
          'consumer injects; DSTheme.dark tertiary is PrismColors.accentCyan',
    },
    {
      'tempest': 'AppTheme.dark.colorScheme.surface',
      'hex': '#161820',
      'disposition': 'owned-registry',
      'prism': 'PrismColorRole.obsidianBase (DSTheme.dark surface)',
    },
    {
      'tempest': 'AppTheme.dark.colorScheme.onSurface',
      'hex': '#F1F3F9',
      'disposition': 'owned-prism',
      'prism': 'PrismColors.textPrimary (DSTheme.dark onSurface)',
    },
    {
      'tempest': 'AppTheme.dark.colorScheme.surfaceContainerHighest',
      'hex': '#1E212D',
      'disposition': 'owned-registry',
      'prism':
          'PrismColorRole.obsidianElevated (DSTheme.dark surfaceContainerHighest)',
    },
    {
      'tempest': 'AppTheme.dark.colorScheme.outline',
      'hex': '#2C3042',
      'disposition': 'owned-registry',
      'prism': 'PrismColorRole.borderDefault (DSTheme.dark outline)',
    },
    {
      'tempest': 'AppTheme.dark.colorScheme.outlineVariant',
      'hex': '#282C3C',
      'disposition': 'owned-registry',
      'prism':
          'PrismColorRole.obsidianHover (DSTheme.dark outlineVariant maps to hover surface)',
    },
    {
      'tempest': 'AppTheme.dark.colorScheme.error',
      'hex': '#FF3366',
      'disposition': 'injected-domain',
      'prism':
          'consumer injects; DSTheme.dark error is PrismColors.statusError',
    },
  ];

  /// Returns the disposition row for [tempestKey], or `null` when the key
  /// is not part of the 47-row ledger (unknown stays UNKNOWN).
  static Map<String, String>? dispositionOf(String tempestKey) {
    for (final row in rows) {
      if (row['tempest'] == tempestKey) return row;
    }
    return null;
  }

  /// Resolves the Tempest-dark structural surface from live Prism tokens.
  ///
  /// Owned slots read from [registry] (defaults to the singleton, so skin
  /// and Theme Editor overrides flow through); every brand/stem/domain
  /// colour is a required caller-supplied parameter and is echoed
  /// untouched. This function never mutates the registry.
  static ({
    Color background,
    Color surface,
    Color elevated,
    Color highlight,
    Color border,
    Color textPrimary,
    Color textSecondary,
    Color textTertiary,
    Color primary,
    Color secondary,
    Color tertiary,
    Color error,
    Color success,
    Color warning,
    Color stemVocals,
    Color stemDrums,
    Color stemBass,
    Color stemOther,
    Color stemGuitar,
    Color stemPiano,
    Color stemInstrumental,
  })
  resolveDark({
    required Color primary,
    required Color secondary,
    required Color tertiary,
    required Color error,
    required Color success,
    required Color warning,
    required Color stemVocals,
    required Color stemDrums,
    required Color stemBass,
    required Color stemOther,
    required Color stemGuitar,
    required Color stemPiano,
    required Color stemInstrumental,
    PrismTokenRegistry? registry,
  }) {
    final tokens = registry ?? PrismTokenRegistry.instance;
    return (
      background: tokens.obsidianDeep,
      surface: tokens.obsidianBase,
      elevated: tokens.obsidianElevated,
      highlight: tokens.obsidianHover,
      border: tokens.borderDefault,
      textPrimary: DSColors.textPrimary,
      textSecondary: DSColors.textSecondary,
      textTertiary: DSColors.textTertiary,
      primary: primary,
      secondary: secondary,
      tertiary: tertiary,
      error: error,
      success: success,
      warning: warning,
      stemVocals: stemVocals,
      stemDrums: stemDrums,
      stemBass: stemBass,
      stemOther: stemOther,
      stemGuitar: stemGuitar,
      stemPiano: stemPiano,
      stemInstrumental: stemInstrumental,
    );
  }
}
