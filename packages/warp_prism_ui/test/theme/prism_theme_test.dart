import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

void main() {
  group('PrismTheme.dark() canonical theme composition', () {
    test('emits complete M3 ThemeData with obsidian deep background', () {
      final theme = PrismTheme.dark();
      expect(theme.brightness, equals(Brightness.dark));
      expect(theme.useMaterial3, isTrue);
      expect(theme.scaffoldBackgroundColor, equals(PrismColors.obsidianDeep));
      expect(theme.textTheme.bodyMedium?.fontFamily, equals('Rajdhani'));
      expect(
        theme.textTheme.bodyMedium?.fontFamilyFallback,
        equals(['Roboto', 'Helvetica Neue', 'Arial', 'sans-serif']),
      );
    });

    test('defines every ColorScheme slot against contract obsidian/accent hexes', () {
      final theme = PrismTheme.dark();
       final scheme = theme.colorScheme;

       expect(scheme.brightness, equals(Brightness.dark));

       // Primary & action accents

      expect(scheme.primary, equals(const Color(0xFF2F81FF)));
      expect(scheme.onPrimary, equals(const Color(0xFFFFFFFF)));
      expect(scheme.primaryContainer, equals(const Color(0xFF114299)));
      expect(scheme.onPrimaryContainer, equals(const Color(0xFFFFFFFF)));

       // Secondary & data accents
       expect(scheme.secondary, equals(const Color(0xFF8B5CF6)));
       expect(scheme.onSecondary, equals(const Color(0xFFFFFFFF)));
       expect(scheme.secondaryContainer, equals(const Color(0xFF4C3899)));
       expect(scheme.onSecondaryContainer, equals(const Color(0xFFFFFFFF)));
       expect(scheme.tertiary, equals(const Color(0xFF00D4FF)));
       expect(scheme.onTertiary, equals(const Color(0xFFFFFFFF)));
       expect(scheme.tertiaryContainer, equals(const Color(0xFF006680)));
       expect(scheme.onTertiaryContainer, equals(const Color(0xFFFFFFFF)));

       // Status error
       expect(scheme.error, equals(const Color(0xFFEF4444)));
       expect(scheme.onError, equals(const Color(0xFFFFFFFF)));
       expect(scheme.errorContainer, equals(const Color(0xFFB91C1C)));
       expect(scheme.onErrorContainer, equals(const Color(0xFFFFFFFF)));


      // Surface hierarchy (Obsidian family)
      expect(scheme.surface, equals(const Color(0xFF080C0E)));
      expect(scheme.onSurface, equals(const Color(0xFFF0F0F5)));
      expect(scheme.surfaceDim, equals(const Color(0xFF030506)));
      expect(scheme.surfaceBright, equals(const Color(0xFF0C1114)));

      expect(scheme.surfaceContainerLowest, equals(const Color(0xFF030506)));
      expect(scheme.surfaceContainerLow, equals(const Color(0xFF030506)));
      expect(scheme.surfaceContainer, equals(const Color(0xFF080C0E)));
      expect(scheme.surfaceContainerHigh, equals(const Color(0xFF0C1114)));
      expect(scheme.surfaceContainerHighest, equals(const Color(0xFF12181C)));

      // Borders & outlines
      expect(scheme.onSurfaceVariant, equals(const Color(0xFFA0A0B0)));
      expect(scheme.outline, equals(const Color(0xFF121D22)));
      expect(scheme.outlineVariant, equals(const Color(0xFF1E1E28)));

      // Utility & inverse
      expect(scheme.shadow, equals(const Color(0xFF030506)));
      expect(scheme.scrim, equals(const Color(0xFF000000)));
      expect(scheme.inverseSurface, equals(const Color(0xFFF0F0F5)));
      expect(scheme.onInverseSurface, equals(const Color(0xFF080C0E)));
      expect(scheme.inversePrimary, equals(const Color(0xFF1D64D8)));
      expect(scheme.surfaceTint, equals(Colors.transparent));
    });

    test('maps TextTheme from DSTypography with explicit composed colors', () {
      final theme = PrismTheme.dark();
      final textTheme = theme.textTheme;

      expect(textTheme.displayLarge?.fontFamily, equals('Rajdhani'));
      expect(textTheme.bodyLarge?.fontFamily, equals('Rajdhani'));
      expect(textTheme.bodyMedium?.fontFamily, equals('Rajdhani'));
      expect(textTheme.labelMedium?.fontFamily, equals('Rajdhani'));

      expect(textTheme.bodyMedium?.color, equals(PrismColors.textPrimary));
      expect(textTheme.bodySmall?.color, equals(PrismColors.textSecondary));
      expect(textTheme.labelSmall?.color, equals(PrismColors.textSecondary));
    });

    testWidgets('component-level non-mono assertion (DS molecules render sans by default)', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: PrismTheme.dark(),
          home: const Scaffold(
            body: Column(
              children: [
                PrismText.bodyMedium('Sans Body Text'),
                PrismText.headingMedium('Sans Heading Text'),
                PrismText.code('Mono Code Text'),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final bodyTextWidget = tester.widget<Text>(find.text('Sans Body Text'));
      expect(bodyTextWidget.style?.fontFamily, equals('Rajdhani'));
      expect(
        bodyTextWidget.style?.fontFamilyFallback,
        equals(['Roboto', 'Helvetica Neue', 'Arial', 'sans-serif']),
      );

      final selectableWidget = tester.widget<SelectableText>(find.byType(SelectableText));
      expect(selectableWidget.style?.fontFamily, equals('JetBrainsMono'));
      expect(
        selectableWidget.style?.fontFamilyFallback,
        equals(['Courier New', 'monospace']),
      );
    });

    test('CyberCore applyToTheme regression over PrismTheme.dark()', () {
      final baseTheme = PrismTheme.dark();
      final skinnedTheme = const PrismCyberCoreTealSkin.omniRoute().applyToTheme(
        baseTheme,
      );

      // Extension is present
      expect(skinnedTheme.extension<PrismCyberCoreTealSkin>(), isNotNull);
      expect(
        skinnedTheme.extension<PrismCyberCoreTealSkin>()!.accent,
        equals(const Color(0xFF00FFCC)),
      );

      // Primary remapped to core teal #00FFCC
      expect(skinnedTheme.colorScheme.primary, equals(const Color(0xFF00FFCC)));

      // Scaffold background & M3 obsidian slots remain intact
      expect(
        skinnedTheme.scaffoldBackgroundColor,
        equals(PrismColors.obsidianDeep),
      );
      expect(
        skinnedTheme.colorScheme.surfaceContainerHighest,
        equals(const Color(0xFF12181C)),
      );
      expect(
        skinnedTheme.colorScheme.outline,
        equals(const Color(0xFF121D22)),
      );
    });

    test('PrismTheme.taldarimRed() factory emits dark theme with Taldarim Red skin', () {
      final theme = PrismTheme.taldarimRed();

      expect(theme.brightness, equals(Brightness.dark));
      expect(theme.scaffoldBackgroundColor, equals(PrismColors.obsidianDeep));
      expect(theme.colorScheme.primary, equals(const Color(0xFFE51A4C)));
      expect(theme.colorScheme.primaryContainer, equals(const Color(0xFF7A0A26)));
      expect(theme.extension<PrismTaldarimRedSkin>(), isNotNull);
      expect(
        theme.extension<PrismTaldarimRedSkin>()!.accent,
        equals(const Color(0xFFE51A4C)),
      );
      // Obsidian background slots unchanged
      expect(theme.colorScheme.surface, equals(const Color(0xFF080C0E)));
      expect(theme.colorScheme.outline, equals(const Color(0xFF121D22)));
    });

    test('PrismTheme.talonPurple() factory emits dark theme with Talon Purple skin', () {
      final theme = PrismTheme.talonPurple();

      expect(theme.brightness, equals(Brightness.dark));
      expect(theme.scaffoldBackgroundColor, equals(PrismColors.obsidianDeep));
      expect(theme.colorScheme.primary, equals(const Color(0xFF9911E5)));
      expect(theme.colorScheme.primaryContainer, equals(const Color(0xFF4F0878)));
      expect(theme.extension<PrismTalonPurpleSkin>(), isNotNull);
      expect(
        theme.extension<PrismTalonPurpleSkin>()!.accent,
        equals(const Color(0xFF9911E5)),
      );
      // Obsidian background slots unchanged
      expect(theme.colorScheme.surface, equals(const Color(0xFF080C0E)));
      expect(theme.colorScheme.outline, equals(const Color(0xFF121D22)));
    });
  });
}
