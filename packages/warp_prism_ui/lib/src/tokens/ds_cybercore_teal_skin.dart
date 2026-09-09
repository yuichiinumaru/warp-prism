import 'package:flutter/material.dart';

import 'ds_colors.dart';
import 'ds_radii.dart';
import 'prism_token_registry.dart';

/// Optional CyberCore teal accent skin (OmniRoute DNA).
///
/// **Opt-in only.** Observatory defaults remain the multi-accent sky-cyan stack
/// on [DSColors] (`accentCyan = #00D4FF`). This extension never mutates static
/// Observatory tokens; product apps that want mono-teal CyberCore identity must
/// install it on [ThemeData.extensions] and read values from the extension
/// (or from [ThemeData.colorScheme] after applying helpers).
///
/// Soft inventory assumption (Task 1600 did not freeze a full skin palette):
/// OmniRoute `coreCyan` / harvest `coreTeal` = `#00FFCC`. Muted/dim ladder
/// follows the same structure as [DSColors.accentCyan] muted/dim pairs, shifted
/// toward teal rather than sky cyan.
///
/// Not a full second design system — accent core + glow border only.
@immutable
class DSCyberCoreTealSkin extends ThemeExtension<DSCyberCoreTealSkin>
    implements PrismAccentSkin {
  /// OmniRoute / harvest core teal (`#00FFCC`).
  static const Color coreTeal = Color(0xFF00FFCC);

  /// Muted teal for secondary chrome (structured mute, not opacity wash).
  static const Color coreTealMuted = Color(0xFF00B894);

  /// Dim teal for deep accents and inactive energy.
  static const Color coreTealDim = Color(0xFF007A66);

  /// Creates a CyberCore teal skin. Defaults match [omniRoute].
  const DSCyberCoreTealSkin({
    this.accent = coreTeal,
    this.accentMuted = coreTealMuted,
    this.accentDim = coreTealDim,
    this.borderGlow = coreTeal,
  });

  /// Canonical OmniRoute teal skin (factory alias of defaults).
  const DSCyberCoreTealSkin.omniRoute()
    : accent = coreTeal,
      accentMuted = coreTealMuted,
      accentDim = coreTealDim,
      borderGlow = coreTeal;

  /// Primary energy accent (teal).
  @override
  final Color accent;

  /// Muted energy accent.
  @override
  final Color accentMuted;

  /// Dim energy accent.
  @override
  final Color accentDim;

  /// Luminous border / glow edge color for CyberCore chrome.
  @override
  final Color borderGlow;

  /// Resolves the extension from [context], or `null` when not installed.
  static DSCyberCoreTealSkin? maybeOf(BuildContext context) {
    return Theme.of(context).extension<DSCyberCoreTealSkin>();
  }

  /// Resolves the extension from [context].
  ///
  /// Throws [FlutterError] when the skin is not installed — callers that need
  /// a soft fallback should use [maybeOf] or [DSColors] static tokens.
  static DSCyberCoreTealSkin of(BuildContext context) {
    final skin = maybeOf(context);
    assert(() {
      if (skin == null) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary('DSCyberCoreTealSkin was not found in the theme.'),
          ErrorDescription(
            'CyberCore teal is opt-in. Wrap MaterialApp with '
            'ThemeData(extensions: [DSCyberCoreTealSkin.omniRoute()]) or use '
            'DSCyberCoreTealSkin.applyToTheme(...). Observatory apps must not '
            'require this extension.',
          ),
        ]);
      }
      return true;
    }());
    if (skin == null) {
      throw FlutterError(
        'DSCyberCoreTealSkin was not found in the theme. '
        'Install it via ThemeData.extensions (opt-in CyberCore only).',
      );
    }
    return skin;
  }

  /// Returns [base] with this skin registered on [ThemeData.extensions].
  ///
  /// Does **not** rewrite [DSColors] statics. Optionally remaps
  /// [ColorScheme.primary] / related scheme fields when [remapColorScheme] is
  /// true so Material primary chrome follows teal without global token rebrand.
  ThemeData applyToTheme(ThemeData base, {bool remapColorScheme = true}) {
    // Avoid explicit ThemeExtension<dynamic> list inference under Dart 3.12 /
    // Flutter 3.44 (CFE rewrites the recursive ThemeExtension bound).
    final preserved =
        base.extensions.values
            .where((Object e) => e is! DSCyberCoreTealSkin)
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
        primaryContainer: accentDim,
        onPrimary: DSColors.textInverse,
        inversePrimary: accentMuted,
        tertiary: accentMuted,
      ),
      inputDecorationTheme: withExtension.inputDecorationTheme.copyWith(
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DSRadii.md),
          borderSide: BorderSide(color: accent, width: 1.5),
        ),
      ),
      chipTheme: withExtension.chipTheme.copyWith(
        selectedColor: accentDim,
      ),
    );
  }

  /// Soft glow for CyberCore chrome using this skin's accent (not [DSShadows.glowCyan]).
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
  DSCyberCoreTealSkin copyWith({
    Color? accent,
    Color? accentMuted,
    Color? accentDim,
    Color? borderGlow,
  }) {
    return DSCyberCoreTealSkin(
      accent: accent ?? this.accent,
      accentMuted: accentMuted ?? this.accentMuted,
      accentDim: accentDim ?? this.accentDim,
      borderGlow: borderGlow ?? this.borderGlow,
    );
  }

  @override
  DSCyberCoreTealSkin lerp(
    ThemeExtension<DSCyberCoreTealSkin>? other,
    double t,
  ) {
    if (other is! DSCyberCoreTealSkin) {
      return this;
    }
    return DSCyberCoreTealSkin(
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
    return other is DSCyberCoreTealSkin &&
        other.accent == accent &&
        other.accentMuted == accentMuted &&
        other.accentDim == accentDim &&
        other.borderGlow == borderGlow;
  }

  @override
  int get hashCode => Object.hash(accent, accentMuted, accentDim, borderGlow);
}
