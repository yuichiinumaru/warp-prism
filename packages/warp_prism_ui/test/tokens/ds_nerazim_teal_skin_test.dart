import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// Public barrel only — proves Prism aliases + non-rebrand without src/ leaks.
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// Task 1616: Nerazim Teal ThemeExtension skin — non-rebrand + public API.
///
/// Amends Task 1616 regression guards per EPIC-18 / Task 1800 / Task 1801:
/// Observatory default primary action accent is PrismColors.accentBlue (#2F81FF);
/// PrismColors.accentCyan (#00D4FF) is retained as a data-category accent.
///
/// Brand normalization by Task 1839: the teal skin class, its public alias,
/// and its factory constructor were renamed to the canonical `Nerazim Teal`
/// brand vocabulary. No hex or behavior change.
///
/// Imports the **public barrel** so Prism aliases are proven end-to-end
/// (consumers never import DS* names).
void main() {
  group('Observatory defaults (Black Obsidian + Blue Accent Contract)', () {
    test('PrismColors default scaffold background is black obsidian #030506', () {
      // Provenance: Amends Task 1616 regression guards per EPIC-18 / Task 1800 / Task 1801
      expect(PrismColors.obsidianDeep, equals(const Color(0xFF030506)));
      expect(PrismColors.obsidianBase, equals(const Color(0xFF080C0E)));
      expect(PrismColors.obsidianElevated, equals(const Color(0xFF0C1114)));
      expect(PrismColors.obsidianHover, equals(const Color(0xFF12181C)));
    });

    test('PrismColors.accentBlue is action blue #2F81FF', () {
      // Provenance: Amends Task 1616 regression guards per EPIC-18 / Task 1800 / Task 1801
      expect(PrismColors.accentBlue, equals(const Color(0xFF2F81FF)));
      expect(PrismColors.accentBlueMuted, equals(const Color(0xFF1D64D8)));
      expect(PrismColors.accentBlueDim, equals(const Color(0xFF114299)));
    });

    test(
      'PrismColors.accentCyan remains sky cyan #00D4FF (retained data accent)',
      () {
        expect(PrismColors.accentCyan, equals(const Color(0xFF00D4FF)));
      },
    );

    test('accentCyan is not OmniRoute core teal #00FFCC', () {
      expect(PrismColors.accentCyan, isNot(equals(const Color(0xFF00FFCC))));
      expect(
        PrismColors.accentCyan,
        isNot(equals(PrismNerazimTealSkin.coreTeal)),
      );
    });

    test('borderGlow default still tracks Observatory cyan data accent', () {
      expect(PrismColors.borderGlow, equals(const Color(0xFF00D4FF)));
    });

    test('PrismColors multi-accent stack remains intact', () {
      expect(PrismColors.accentViolet, equals(const Color(0xFF8B5CF6)));
      expect(PrismColors.accentGold, equals(const Color(0xFFFFB800)));
    });
  });

  group('PrismNerazimTealSkin (public ThemeExtension)', () {
    test('nerazimTeal skin exposes core teal #00FFCC', () {
      const skin = PrismNerazimTealSkin.nerazimTeal();
      expect(skin.accent, equals(const Color(0xFF00FFCC)));
      expect(skin.accent, equals(PrismNerazimTealSkin.coreTeal));
      expect(skin.borderGlow, equals(const Color(0xFF00FFCC)));
      expect(skin.accentMuted, equals(PrismNerazimTealSkin.coreTealMuted));
      expect(skin.accentDim, equals(PrismNerazimTealSkin.coreTealDim));
    });

    test('default ThemeData does not install the skin', () {
      final theme = ThemeData.dark();
      expect(theme.extension<PrismNerazimTealSkin>(), isNull);
    });

    test('applyToTheme installs extension without mutating PrismColors', () {
      const beforeCyan = PrismColors.accentCyan;
      final themed = const PrismNerazimTealSkin.nerazimTeal().applyToTheme(
        ThemeData.dark(),
      );

      expect(themed.extension<PrismNerazimTealSkin>(), isNotNull);
      expect(
        themed.extension<PrismNerazimTealSkin>()!.accent,
        equals(const Color(0xFF00FFCC)),
      );
      expect(themed.colorScheme.primary, equals(const Color(0xFF00FFCC)));
      // Static Observatory tokens remain sky cyan after apply.
      expect(PrismColors.accentCyan, equals(beforeCyan));
      expect(PrismColors.accentCyan, equals(const Color(0xFF00D4FF)));
    });

    test('applyToTheme can skip ColorScheme remap', () {
      final themed = const PrismNerazimTealSkin.nerazimTeal().applyToTheme(
        ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: Color(0xFF00D4FF)),
        ),
        remapColorScheme: false,
      );
      expect(themed.extension<PrismNerazimTealSkin>(), isNotNull);
      expect(themed.colorScheme.primary, equals(const Color(0xFF00D4FF)));
    });

    test('copyWith / lerp / equality', () {
      const a = PrismNerazimTealSkin.nerazimTeal();
      final b = a.copyWith(accentMuted: const Color(0xFF00AA88));
      expect(b.accent, equals(a.accent));
      expect(b.accentMuted, equals(const Color(0xFF00AA88)));
      expect(a, equals(const PrismNerazimTealSkin.nerazimTeal()));
      expect(
        a.hashCode,
        equals(const PrismNerazimTealSkin.nerazimTeal().hashCode),
      );

      final mid = a.lerp(b, 0.5);
      expect(mid.accent, equals(a.accent));
      expect(mid.accentMuted, isNot(equals(a.accentMuted)));
    });

    testWidgets('maybeOf is null when skin not installed', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Builder(
            builder: (context) {
              expect(PrismNerazimTealSkin.maybeOf(context), isNull);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });

    testWidgets('of throws when skin not installed (fail-closed)', (
      tester,
    ) async {
      Object? caught;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Builder(
            builder: (context) {
              try {
                PrismNerazimTealSkin.of(context);
              } catch (e) {
                caught = e;
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(caught, isA<FlutterError>());
      expect(
        (caught! as FlutterError).message,
        contains('DSNerazimTealSkin was not found'),
      );
    });

    testWidgets('of/maybeOf resolve teal when skin installed', (tester) async {
      const accentProbeKey = Key('nerazim-teal-accent-probe');
      await tester.pumpWidget(
        MaterialApp(
          theme: const PrismNerazimTealSkin.nerazimTeal().applyToTheme(
            ThemeData.dark(),
          ),
          home: Builder(
            builder: (context) {
              final skin = PrismNerazimTealSkin.of(context);
              expect(skin.accent, equals(const Color(0xFF00FFCC)));
              expect(
                PrismNerazimTealSkin.maybeOf(context)!.accent,
                equals(const Color(0xFF00FFCC)),
              );
              return ColoredBox(key: accentProbeKey, color: skin.accent);
            },
          ),
        ),
      );

      final box = tester.widget<ColoredBox>(find.byKey(accentProbeKey));
      expect(box.color, equals(const Color(0xFF00FFCC)));
    });

    test('glow uses skin accent not Observatory cyan', () {
      const skin = PrismNerazimTealSkin.nerazimTeal();
      final glow = skin.glow();
      expect(glow, isNotEmpty);
      // Compare channels that differ: teal #00FFCC vs cyan #00D4FF (both r=0).
      expect(glow.first.color.g, closeTo(skin.accent.g, 0.001));
      expect(glow.first.color.b, closeTo(skin.accent.b, 0.001));
      expect(
        glow.first.color.g,
        isNot(closeTo(PrismColors.accentCyan.g, 0.001)),
      );
      expect(
        glow.first.color.b,
        isNot(closeTo(PrismColors.accentCyan.b, 0.001)),
      );
    });
  });
}
