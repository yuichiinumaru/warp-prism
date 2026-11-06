import 'package:flutter/material.dart';

import 'ds_colors.dart';
import 'ds_radii.dart';
import 'prism_token_registry.dart';

/// Optional Talon Purple accent skin (Protoss lore: Talon faction violet/crimson-purple energy).
///
/// **Opt-in only.** Observatory defaults remain the Black Obsidian + action blue
/// stack on [DSColors] (`accentBlue = #2F81FF`, Khalai Blue).
///
/// Lore brand naming convention:
/// - **Khalai Blue**: default primary action accent (`accentBlue = #2F81FF`)
/// - **Nerazim Teal**: retained cyan/green data category accents
/// - **Purifier Gold**: gold energy accent (`accentGold = #FFB800`)
/// - **Taldarim Red**: crimson energy accent (`#E51A4C` family)
/// - **Talon Purple**: violet/crimson-purple energy accent (`#9911E5` family)
///
/// This extension never mutates static Observatory tokens. Consumer apps that
/// want Talon Purple identity must install it via [ThemeData.extensions] or call
/// [applyToTheme] / [DSTheme.talonPurple()].
@immutable
class DSTalonPurpleSkin extends ThemeExtension<DSTalonPurpleSkin>
    implements PrismAccentSkin {
  /// Primary Talon Purple violet/crimson-purple energy (`#9911E5`).
  static const Color corePurple = Color(0xFF9911E5);

  /// Muted purple for secondary action chrome (`#770CB3`).
  static const Color corePurpleMuted = Color(0xFF770CB3);

  /// Dim purple for deep accents and selected backgrounds (`#4F0878`).
  static const Color corePurpleDim = Color(0xFF4F0878);

  /// Creates a Talon Purple skin. Defaults match [talonPurple].
  const DSTalonPurpleSkin({
    this.accent = corePurple,
    this.accentMuted = corePurpleMuted,
    this.accentDim = corePurpleDim,
    this.borderGlow = corePurple,
  });

  /// Canonical Talon Purple skin (factory alias of defaults).
  const DSTalonPurpleSkin.talonPurple()
    : accent = corePurple,
      accentMuted = corePurpleMuted,
      accentDim = corePurpleDim,
      borderGlow = corePurple;

  /// Primary energy accent (violet/crimson-purple).
  @override
  final Color accent;

  /// Muted energy accent.
  @override
  final Color accentMuted;

  /// Dim energy accent.
  @override
  final Color accentDim;

  /// Luminous border / glow edge color for Talon chrome.
  @override
  final Color borderGlow;

  /// Resolves the extension from [context], or `null` when not installed.
  static DSTalonPurpleSkin? maybeOf(BuildContext context) {
    return Theme.of(context).extension<DSTalonPurpleSkin>();
  }

  /// Resolves the extension from [context].
  ///
  /// Throws [FlutterError] when the skin is not installed.
  static DSTalonPurpleSkin of(BuildContext context) {
    final skin = maybeOf(context);
    assert(() {
      if (skin == null) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary('DSTalonPurpleSkin was not found in the theme.'),
          ErrorDescription(
            'Talon Purple is opt-in. Wrap MaterialApp with '
            'DSTheme.talonPurple() or install via ThemeData.extensions.',
          ),
        ]);
      }
      return true;
    }());
    if (skin == null) {
      throw FlutterError(
        'DSTalonPurpleSkin was not found in the theme. '
        'Install it via ThemeData.extensions (opt-in Talon Purple only).',
      );
    }
    return skin;
  }

  /// Returns [base] with this skin registered on [ThemeData.extensions].
  ///
  /// Does **not** rewrite [DSColors] statics. Reuses obsidian background
  /// mapping and remaps primary scheme slots when [remapColorScheme] is true.
  ThemeData applyToTheme(ThemeData base, {bool remapColorScheme = true}) {
    final preserved =
        base.extensions.values
            .where((Object e) => e is! DSTalonPurpleSkin)
            .cast<ThemeExtension<dynamic>>()
            .toList(growable: true)
          ..add(this);
    final ThemeData withExtension = base.copyWith(extensions: preserved);
    if (!remapColorScheme) {
      return withExtension;
    }
    final ColorScheme scheme = withExtension.colorScheme;
    return withExtension.copyWith(
      colorScheme: scheme.copyWith(
        primary: accent,
        onPrimary: DSColors.white,
        primaryContainer: accentDim,
        onPrimaryContainer: DSColors.white,
        inversePrimary: accentMuted,
      ),
      inputDecorationTheme: withExtension.inputDecorationTheme.copyWith(
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DSRadii.md),
          borderSide: BorderSide(color: accent, width: 1.5),
        ),
      ),
      chipTheme: withExtension.chipTheme.copyWith(selectedColor: accentDim),
    );
  }

  /// Soft glow for Talon chrome using this skin's accent.
  List<BoxShadow> glow({double intensity = 1.0}) => <BoxShadow>[
    BoxShadow(
      color: accent.withValues(alpha: 0.3 * intensity),
      blurRadius: 12,
      spreadRadius: -2,
    ),
    BoxShadow(
      color: accent.withValues(alpha: 0.1 * intensity),
      blurRadius: 24,
      spreadRadius: -4,
    ),
  ];

  @override
  DSTalonPurpleSkin copyWith({
    Color? accent,
    Color? accentMuted,
    Color? accentDim,
    Color? borderGlow,
  }) {
    return DSTalonPurpleSkin(
      accent: accent ?? this.accent,
      accentMuted: accentMuted ?? this.accentMuted,
      accentDim: accentDim ?? this.accentDim,
      borderGlow: borderGlow ?? this.borderGlow,
    );
  }

  @override
  DSTalonPurpleSkin lerp(ThemeExtension<DSTalonPurpleSkin>? other, double t) {
    if (other is! DSTalonPurpleSkin) {
      return this;
    }
    return DSTalonPurpleSkin(
      accent: Color.lerp(accent, other.accent, t)!,
      accentMuted: Color.lerp(accentMuted, other.accentMuted, t)!,
      accentDim: Color.lerp(accentDim, other.accentDim, t)!,
      borderGlow: Color.lerp(borderGlow, other.borderGlow, t)!,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is DSTalonPurpleSkin &&
        other.accent == accent &&
        other.accentMuted == accentMuted &&
        other.accentDim == accentDim &&
        other.borderGlow == borderGlow;
  }

  @override
  int get hashCode => Object.hash(accent, accentMuted, accentDim, borderGlow);
}
