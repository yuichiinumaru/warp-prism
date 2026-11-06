import 'package:flutter/material.dart';

import 'ds_colors.dart';
import 'ds_radii.dart';
import 'prism_token_registry.dart';

/// Optional Nerazim Teal accent skin (OmniRoute DNA).
///
/// **Opt-in only.** Observatory defaults remain the multi-accent sky-cyan stack
/// on [DSColors] (`accentCyan = #00D4FF`). This extension never mutates static
/// Observatory tokens; product apps that want mono-teal Nerazim Teal identity
/// must install it on [ThemeData.extensions] and read values from the extension
/// (or from [ThemeData.colorScheme] after applying helpers).
///
/// Soft inventory assumption (Task 1600 did not freeze a full skin palette):
/// OmniRoute `coreCyan` / harvest `coreTeal` = `#00FFCC`. Muted/dim ladder
/// follows the same structure as [DSColors.accentCyan] muted/dim pairs, shifted
/// toward teal rather than sky cyan.
///
/// Not a full second design system — accent core + glow border only.
@immutable
class DSNerazimTealSkin extends ThemeExtension<DSNerazimTealSkin>
    implements PrismAccentSkin {
  /// OmniRoute / harvest core teal (`#00FFCC`).
  static const Color coreTeal = Color(0xFF00FFCC);

  /// Muted teal for secondary chrome (structured mute, not opacity wash).
  static const Color coreTealMuted = Color(0xFF00B894);

  /// Dim teal for deep accents and inactive energy.
  static const Color coreTealDim = Color(0xFF007A66);

  /// Creates a Nerazim Teal skin. Defaults match [nerazimTeal].
  const DSNerazimTealSkin({
    this.accent = coreTeal,
    this.accentMuted = coreTealMuted,
    this.accentDim = coreTealDim,
    this.borderGlow = coreTeal,
  });

  /// Canonical Nerazim Teal skin (factory alias of defaults).
  const DSNerazimTealSkin.nerazimTeal()
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

  /// Luminous border / glow edge color for Nerazim Teal chrome.
  @override
  final Color borderGlow;

  /// Resolves the extension from [context], or `null` when not installed.
  static DSNerazimTealSkin? maybeOf(BuildContext context) {
    return Theme.of(context).extension<DSNerazimTealSkin>();
  }

  /// Resolves the extension from [context].
  ///
  /// Throws [FlutterError] when the skin is not installed — callers that need
  /// a soft fallback should use [maybeOf] or [DSColors] static tokens.
  static DSNerazimTealSkin of(BuildContext context) {
    final skin = maybeOf(context);
    assert(() {
      if (skin == null) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary('DSNerazimTealSkin was not found in the theme.'),
          ErrorDescription(
            'Nerazim Teal is opt-in. Wrap MaterialApp with '
            'ThemeData(extensions: [DSNerazimTealSkin.nerazimTeal()]) or use '
            'DSNerazimTealSkin.applyToTheme(...). Observatory apps must not '
            'require this extension.',
          ),
        ]);
      }
      return true;
    }());
    if (skin == null) {
      throw FlutterError(
        'DSNerazimTealSkin was not found in the theme. '
        'Install it via ThemeData.extensions (opt-in Nerazim Teal only).',
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
            .where((Object e) => e is! DSNerazimTealSkin)
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
      chipTheme: withExtension.chipTheme.copyWith(selectedColor: accentDim),
    );
  }

  /// Soft glow for Nerazim Teal chrome using this skin's accent (not [DSShadows.glowCyan]).
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
  DSNerazimTealSkin copyWith({
    Color? accent,
    Color? accentMuted,
    Color? accentDim,
    Color? borderGlow,
  }) {
    return DSNerazimTealSkin(
      accent: accent ?? this.accent,
      accentMuted: accentMuted ?? this.accentMuted,
      accentDim: accentDim ?? this.accentDim,
      borderGlow: borderGlow ?? this.borderGlow,
    );
  }

  @override
  DSNerazimTealSkin lerp(ThemeExtension<DSNerazimTealSkin>? other, double t) {
    if (other is! DSNerazimTealSkin) {
      return this;
    }
    return DSNerazimTealSkin(
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
    return other is DSNerazimTealSkin &&
        other.accent == accent &&
        other.accentMuted == accentMuted &&
        other.accentDim == accentDim &&
        other.borderGlow == borderGlow;
  }

  @override
  int get hashCode => Object.hash(accent, accentMuted, accentDim, borderGlow);
}
