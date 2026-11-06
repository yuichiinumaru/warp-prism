import 'package:flutter/material.dart';

import 'ds_colors.dart';
import 'ds_radii.dart';
import 'prism_token_registry.dart';

/// Optional Taldarim Red accent skin (Protoss lore: Tal'darim crimson energy).
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
/// want Taldarim Red identity must install it via [ThemeData.extensions] or call
/// [applyToTheme] / [DSTheme.taldarimRed()].
@immutable
class DSTaldarimRedSkin extends ThemeExtension<DSTaldarimRedSkin>
    implements PrismAccentSkin {
  /// Primary Taldarim Red crimson energy (`#E51A4C`).
  static const Color coreRed = Color(0xFFE51A4C);

  /// Muted crimson for secondary action chrome (`#B8103A`).
  static const Color coreRedMuted = Color(0xFFB8103A);

  /// Dim crimson for deep accents and selected backgrounds (`#7A0A26`).
  static const Color coreRedDim = Color(0xFF7A0A26);

  /// Creates a Taldarim Red skin. Defaults match [taldarimRed].
  const DSTaldarimRedSkin({
    this.accent = coreRed,
    this.accentMuted = coreRedMuted,
    this.accentDim = coreRedDim,
    this.borderGlow = coreRed,
  });

  /// Canonical Taldarim Red skin (factory alias of defaults).
  const DSTaldarimRedSkin.taldarimRed()
    : accent = coreRed,
      accentMuted = coreRedMuted,
      accentDim = coreRedDim,
      borderGlow = coreRed;

  /// Primary energy accent (crimson).
  @override
  final Color accent;

  /// Muted energy accent.
  @override
  final Color accentMuted;

  /// Dim energy accent.
  @override
  final Color accentDim;

  /// Luminous border / glow edge color for Taldarim chrome.
  @override
  final Color borderGlow;

  /// Resolves the extension from [context], or `null` when not installed.
  static DSTaldarimRedSkin? maybeOf(BuildContext context) {
    return Theme.of(context).extension<DSTaldarimRedSkin>();
  }

  /// Resolves the extension from [context].
  ///
  /// Throws [FlutterError] when the skin is not installed.
  static DSTaldarimRedSkin of(BuildContext context) {
    final skin = maybeOf(context);
    assert(() {
      if (skin == null) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary('DSTaldarimRedSkin was not found in the theme.'),
          ErrorDescription(
            'Taldarim Red is opt-in. Wrap MaterialApp with '
            'DSTheme.taldarimRed() or install via ThemeData.extensions.',
          ),
        ]);
      }
      return true;
    }());
    if (skin == null) {
      throw FlutterError(
        'DSTaldarimRedSkin was not found in the theme. '
        'Install it via ThemeData.extensions (opt-in Taldarim Red only).',
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
            .where((Object e) => e is! DSTaldarimRedSkin)
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

  /// Soft glow for Taldarim chrome using this skin's accent.
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
  DSTaldarimRedSkin copyWith({
    Color? accent,
    Color? accentMuted,
    Color? accentDim,
    Color? borderGlow,
  }) {
    return DSTaldarimRedSkin(
      accent: accent ?? this.accent,
      accentMuted: accentMuted ?? this.accentMuted,
      accentDim: accentDim ?? this.accentDim,
      borderGlow: borderGlow ?? this.borderGlow,
    );
  }

  @override
  DSTaldarimRedSkin lerp(ThemeExtension<DSTaldarimRedSkin>? other, double t) {
    if (other is! DSTaldarimRedSkin) {
      return this;
    }
    return DSTaldarimRedSkin(
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
    return other is DSTaldarimRedSkin &&
        other.accent == accent &&
        other.accentMuted == accentMuted &&
        other.accentDim == accentDim &&
        other.borderGlow == borderGlow;
  }

  @override
  int get hashCode => Object.hash(accent, accentMuted, accentDim, borderGlow);
}
