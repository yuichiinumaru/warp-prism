import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// Relative luminance calculation per WCAG 2.x standard.
double _relativeLuminance(Color c) {
  double r = c.r;
  double g = c.g;
  double b = c.b;
  r = r <= 0.03928 ? r / 12.92 : math.pow((r + 0.055) / 1.055, 2.4).toDouble();
  g = g <= 0.03928 ? g / 12.92 : math.pow((g + 0.055) / 1.055, 2.4).toDouble();
  b = b <= 0.03928 ? b / 12.92 : math.pow((b + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

/// Contrast ratio per WCAG 2.x standard.
double _contrastRatio(Color fg, Color bg) {
  final l1 = _relativeLuminance(fg);
  final l2 = _relativeLuminance(bg);
  final lighter = l1 > l2 ? l1 : l2;
  final darker = l1 > l2 ? l2 : l1;
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  group('PrismTalonPurpleSkin (Talon Purple ThemeExtension)', () {
    test('accent ladder completeness and default hex values', () {
      const skin = PrismTalonPurpleSkin.talonPurple();
      expect(skin.accent, equals(const Color(0xFF9911E5)));
      expect(skin.accentMuted, equals(const Color(0xFF770CB3)));
      expect(skin.accentDim, equals(const Color(0xFF4F0878)));
      expect(skin.borderGlow, equals(const Color(0xFF9911E5)));
      expect(PrismTalonPurpleSkin.corePurple, equals(const Color(0xFF9911E5)));
      expect(PrismTalonPurpleSkin.corePurpleMuted, equals(const Color(0xFF770CB3)));
      expect(PrismTalonPurpleSkin.corePurpleDim, equals(const Color(0xFF4F0878)));
    });

    test('distinctness assertions against protected tokens', () {
      const skin = PrismTalonPurpleSkin.talonPurple();
      const protectedBlue = Color(0xFF2F81FF); // accentBlue
      const protectedInfo = Color(0xFF3B82F6); // statusInfo
      const protectedError = Color(0xFFEF4444); // statusError
      const protectedViolet = Color(0xFF8B5CF6); // accentViolet

      for (final color in [skin.accent, skin.accentMuted, skin.accentDim]) {
        expect(color, isNot(equals(protectedBlue)));
        expect(color, isNot(equals(protectedInfo)));
        expect(color, isNot(equals(protectedError)));
        expect(color, isNot(equals(protectedViolet)));
      }
    });

    test('opt-in non-mutation: does not modify static PrismColors', () {
      final beforeBlue = PrismColors.accentBlue;
      final beforeDeep = PrismColors.obsidianDeep;

      final theme = const PrismTalonPurpleSkin.talonPurple().applyToTheme(
        PrismTheme.dark(),
      );

      expect(PrismColors.accentBlue, equals(beforeBlue));
      expect(PrismColors.obsidianDeep, equals(beforeDeep));
      expect(theme.scaffoldBackgroundColor, equals(PrismColors.obsidianDeep));
    });

    test('applyToTheme remaps primary ColorScheme and component borders', () {
      final base = PrismTheme.dark();
      final theme = const PrismTalonPurpleSkin.talonPurple().applyToTheme(base);

      expect(theme.colorScheme.primary, equals(const Color(0xFF9911E5)));
      expect(theme.colorScheme.primaryContainer, equals(const Color(0xFF4F0878)));
      expect(theme.colorScheme.inversePrimary, equals(const Color(0xFF770CB3)));
      expect(theme.extension<PrismTalonPurpleSkin>(), isNotNull);
      expect(
        theme.extension<PrismTalonPurpleSkin>()!.accent,
        equals(const Color(0xFF9911E5)),
      );
    });

    test('WCAG AA contrast: white text on Talon Purple accent and accentDim', () {
      const skin = PrismTalonPurpleSkin.talonPurple();

      final ratioAccent = _contrastRatio(PrismColors.white, skin.accent);
      expect(
        ratioAccent,
        greaterThanOrEqualTo(4.5),
        reason:
            'White text on Talon Purple accent (#9911E5) must meet WCAG AA (>= 4.5:1), got ${ratioAccent.toStringAsFixed(2)}',
      );

      final ratioDim = _contrastRatio(PrismColors.white, skin.accentDim);
      expect(
        ratioDim,
        greaterThanOrEqualTo(7.0),
        reason:
            'White text on Talon Purple accentDim (#4F0878) must meet WCAG AAA (>= 7.0:1), got ${ratioDim.toStringAsFixed(2)}',
      );
    });

    test('copyWith / lerp / equality', () {
      const a = PrismTalonPurpleSkin.talonPurple();
      final b = a.copyWith(accentMuted: const Color(0xFF8800CC));

      expect(b.accent, equals(a.accent));
      expect(b.accentMuted, equals(const Color(0xFF8800CC)));
      expect(a, equals(const PrismTalonPurpleSkin.talonPurple()));
      expect(
        a.hashCode,
        equals(const PrismTalonPurpleSkin.talonPurple().hashCode),
      );

      final mid = a.lerp(b, 0.5);
      expect(mid.accent, equals(a.accent));
      expect(mid.accentMuted, isNot(equals(a.accentMuted)));
    });

    testWidgets('of / maybeOf resolution in widget tree', (tester) async {
      const probeKey = Key('talon-probe');
      await tester.pumpWidget(
        MaterialApp(
          theme: PrismTheme.talonPurple(),
          home: Builder(
            builder: (context) {
              final skin = PrismTalonPurpleSkin.of(context);
              expect(skin.accent, equals(const Color(0xFF9911E5)));
              expect(
                PrismTalonPurpleSkin.maybeOf(context)!.accent,
                equals(const Color(0xFF9911E5)),
              );
              return ColoredBox(key: probeKey, color: skin.accent);
            },
          ),
        ),
      );

      final box = tester.widget<ColoredBox>(find.byKey(probeKey));
      expect(box.color, equals(const Color(0xFF9911E5)));
    });

    test('glow decoration shadow generation', () {
      const skin = PrismTalonPurpleSkin.talonPurple();
      final glow = skin.glow();
      expect(glow, hasLength(2));
      expect(glow.first.color.r, closeTo(skin.accent.r, 0.001));
      expect(glow.first.color.g, closeTo(skin.accent.g, 0.001));
      expect(glow.first.color.b, closeTo(skin.accent.b, 0.001));
    });
  });
}
