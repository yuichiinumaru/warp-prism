import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// Public barrel only — proves Prism aliases + non-rebrand without src/ leaks.
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// Task 1616: CyberCore teal ThemeExtension skin — non-rebrand + public API.
///
/// Imports the **public barrel** so Prism aliases are proven end-to-end
/// (consumers never import DS* names).
void main() {
  group('Observatory defaults (non-rebrand)', () {
    test('PrismColors.accentCyan remains sky cyan #00D4FF', () {
      expect(PrismColors.accentCyan, equals(const Color(0xFF00D4FF)));
    });

    test('accentCyan is not OmniRoute core teal #00FFCC', () {
      expect(PrismColors.accentCyan, isNot(equals(const Color(0xFF00FFCC))));
      expect(
        PrismColors.accentCyan,
        isNot(equals(PrismCyberCoreTealSkin.coreTeal)),
      );
    });

    test('borderGlow default still tracks Observatory cyan', () {
      expect(PrismColors.borderGlow, equals(const Color(0xFF00D4FF)));
    });

    test('PrismColors multi-accent stack remains intact', () {
      expect(PrismColors.accentViolet, equals(const Color(0xFF8B5CF6)));
      expect(PrismColors.accentGold, equals(const Color(0xFFFFB800)));
    });
  });

  group('PrismCyberCoreTealSkin (public ThemeExtension)', () {
    test('omniRoute skin exposes core teal #00FFCC', () {
      const skin = PrismCyberCoreTealSkin.omniRoute();
      expect(skin.accent, equals(const Color(0xFF00FFCC)));
      expect(skin.accent, equals(PrismCyberCoreTealSkin.coreTeal));
      expect(skin.borderGlow, equals(const Color(0xFF00FFCC)));
      expect(skin.accentMuted, equals(PrismCyberCoreTealSkin.coreTealMuted));
      expect(skin.accentDim, equals(PrismCyberCoreTealSkin.coreTealDim));
    });

    test('default ThemeData does not install the skin', () {
      final theme = ThemeData.dark();
      expect(theme.extension<PrismCyberCoreTealSkin>(), isNull);
    });

    test('applyToTheme installs extension without mutating PrismColors', () {
      const beforeCyan = PrismColors.accentCyan;
      final themed = const PrismCyberCoreTealSkin.omniRoute().applyToTheme(
        ThemeData.dark(),
      );

      expect(themed.extension<PrismCyberCoreTealSkin>(), isNotNull);
      expect(
        themed.extension<PrismCyberCoreTealSkin>()!.accent,
        equals(const Color(0xFF00FFCC)),
      );
      expect(themed.colorScheme.primary, equals(const Color(0xFF00FFCC)));
      // Static Observatory tokens remain sky cyan after apply.
      expect(PrismColors.accentCyan, equals(beforeCyan));
      expect(PrismColors.accentCyan, equals(const Color(0xFF00D4FF)));
    });

    test('applyToTheme can skip ColorScheme remap', () {
      final themed = const PrismCyberCoreTealSkin.omniRoute().applyToTheme(
        ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: Color(0xFF00D4FF)),
        ),
        remapColorScheme: false,
      );
      expect(themed.extension<PrismCyberCoreTealSkin>(), isNotNull);
      expect(themed.colorScheme.primary, equals(const Color(0xFF00D4FF)));
    });

    test('copyWith / lerp / equality', () {
      const a = PrismCyberCoreTealSkin.omniRoute();
      final b = a.copyWith(accentMuted: const Color(0xFF00AA88));
      expect(b.accent, equals(a.accent));
      expect(b.accentMuted, equals(const Color(0xFF00AA88)));
      expect(a, equals(const PrismCyberCoreTealSkin.omniRoute()));
      expect(
        a.hashCode,
        equals(const PrismCyberCoreTealSkin.omniRoute().hashCode),
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
              expect(PrismCyberCoreTealSkin.maybeOf(context), isNull);
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
                PrismCyberCoreTealSkin.of(context);
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
        contains('DSCyberCoreTealSkin was not found'),
      );
    });

    testWidgets('of/maybeOf resolve teal when skin installed', (tester) async {
      const accentProbeKey = Key('cybercore-teal-accent-probe');
      await tester.pumpWidget(
        MaterialApp(
          theme: const PrismCyberCoreTealSkin.omniRoute().applyToTheme(
            ThemeData.dark(),
          ),
          home: Builder(
            builder: (context) {
              final skin = PrismCyberCoreTealSkin.of(context);
              expect(skin.accent, equals(const Color(0xFF00FFCC)));
              expect(
                PrismCyberCoreTealSkin.maybeOf(context)!.accent,
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
      const skin = PrismCyberCoreTealSkin.omniRoute();
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
