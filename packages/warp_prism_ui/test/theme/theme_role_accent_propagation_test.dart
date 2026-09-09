import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/src/atoms/atoms.dart';
import 'package:warp_prism_ui/src/organisms/organisms.dart';
import 'package:warp_prism_ui/src/tokens/tokens.dart';
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
  setUp(() {
    PrismTokenRegistry.instance.reset();
  });

  tearDown(() {
    PrismTokenRegistry.instance.reset();
  });

  group('Task 1833: Theme-Role and Accent Recipe Propagation Regressions', () {
    test('Token registry supports applying Taldarim Red skin recipe', () {
      expect(PrismColors.accentBlue, equals(const Color(0xFF2F81FF)));

      // Apply Taldarim Red skin to registry
      PrismTokenRegistry.instance.applySkin(const PrismTaldarimRedSkin.taldarimRed());

      expect(PrismColors.accentBlue, equals(const Color(0xFFE51A4C)));
      expect(PrismColors.accentBlueMuted, equals(const Color(0xFFB8103A)));
      expect(PrismColors.accentBlueDim, equals(const Color(0xFF7A0A26)));
      expect(
        PrismColors.focusRing,
        equals(const Color(0xFFE51A4C).withValues(alpha: 0.5)),
      );

      // Reset restores contract defaults
      PrismTokenRegistry.instance.reset();
      expect(PrismColors.accentBlue, equals(const Color(0xFF2F81FF)));
      expect(PrismColors.accentBlueMuted, equals(const Color(0xFF1D64D8)));
      expect(PrismColors.accentBlueDim, equals(const Color(0xFF114299)));
      expect(PrismColors.focusRing, equals(const Color(0x802F81FF)));
    });

    test('Token registry supports applying Talon Purple skin recipe', () {
      PrismTokenRegistry.instance.applySkin(const PrismTalonPurpleSkin.talonPurple());

      expect(PrismColors.accentBlue, equals(const Color(0xFF9911E5)));
      expect(PrismColors.accentBlueMuted, equals(const Color(0xFF770CB3)));
      expect(PrismColors.accentBlueDim, equals(const Color(0xFF4F0878)));
      expect(
        PrismColors.focusRing,
        equals(const Color(0xFF9911E5).withValues(alpha: 0.5)),
      );

      PrismTokenRegistry.instance.reset();
      expect(PrismColors.accentBlue, equals(const Color(0xFF2F81FF)));
    });

    test('Token registry supports applying CyberCore Teal skin recipe', () {
      PrismTokenRegistry.instance.applySkin(const PrismCyberCoreTealSkin.omniRoute());

      expect(PrismColors.accentBlue, equals(const Color(0xFF00FFCC)));
      expect(PrismColors.accentBlueMuted, equals(const Color(0xFF00B894)));
      expect(PrismColors.accentBlueDim, equals(const Color(0xFF007A66)));
      expect(
        PrismColors.focusRing,
        equals(const Color(0xFF00FFCC).withValues(alpha: 0.5)),
      );

      PrismTokenRegistry.instance.reset();
      expect(PrismColors.accentBlue, equals(const Color(0xFF2F81FF)));
    });

    test('Semantic and data roles remain byte-identical under skin application', () {
      // Freeze baseline values
      const success = DSColors.statusSuccess;
      const warning = DSColors.statusWarning;
      const error = DSColors.statusError;
      const info = DSColors.statusInfo;
      const cyan = DSColors.accentCyan;
      const violet = DSColors.accentViolet;
      const gold = DSColors.accentGold;
      final deep = DSColors.obsidianDeep;
      final base = DSColors.obsidianBase;
      final elevated = DSColors.obsidianElevated;

      // Apply Taldarim Red
      PrismTokenRegistry.instance.applySkin(const PrismTaldarimRedSkin.taldarimRed());

      expect(DSColors.statusSuccess, equals(success));
      expect(DSColors.statusWarning, equals(warning));
      expect(DSColors.statusError, equals(error));
      expect(DSColors.statusInfo, equals(info));
      expect(DSColors.accentCyan, equals(cyan));
      expect(DSColors.accentViolet, equals(violet));
      expect(DSColors.accentGold, equals(gold));
      expect(DSColors.obsidianDeep, equals(deep));
      expect(DSColors.obsidianBase, equals(base));
      expect(DSColors.obsidianElevated, equals(elevated));

      // Apply CyberCore Teal
      PrismTokenRegistry.instance.applySkin(const PrismCyberCoreTealSkin.omniRoute());

      expect(DSColors.statusSuccess, equals(success));
      expect(DSColors.statusWarning, equals(warning));
      expect(DSColors.statusError, equals(error));
      expect(DSColors.statusInfo, equals(info));
      expect(DSColors.accentCyan, equals(cyan));
      expect(DSColors.accentViolet, equals(violet));
      expect(DSColors.accentGold, equals(gold));
      expect(DSColors.obsidianDeep, equals(deep));
      expect(DSColors.obsidianBase, equals(base));
      expect(DSColors.obsidianElevated, equals(elevated));
    });

    testWidgets(
      'DSButton, DSSwitch, DSCheckbox, DSTextField resolve Taldarim Red and Talon Purple without registry mutation',
      (tester) async {
        Widget buildApp(ThemeData theme) {
          return MaterialApp(
            theme: theme,
            home: Scaffold(
              body: Column(
                children: [
                  DSButton(
                    label: 'Primary Button',
                    variant: DSButtonVariant.primary,
                    onPressed: () {},
                  ),
                  DSSwitch(value: true, onChanged: (_) {}),
                  DSCheckbox(value: true, onChanged: (_) {}),
                  const DSTextField(label: 'Field'),
                ],
              ),
            ),
          );
        }

        // --- 1. Taldarim Red (#E51A4C) with ZERO registry mutation ---
        await tester.pumpWidget(buildApp(PrismTheme.taldarimRed()));
        await tester.pumpAndSettle();

        // Button primary glow
        final buttonGlow = tester.widget<DSGlowBorder>(
          find.descendant(
            of: find.byType(DSButton),
            matching: find.byType(DSGlowBorder),
          ),
        );
        expect(
          buttonGlow.color,
          equals(const Color(0xFFE51A4C)),
          reason: 'DSButton must resolve Taldarim Red from theme without registry mutation',
        );

        // Switch active track
        final switchTrack = tester.widget<AnimatedContainer>(
          find.descendant(
            of: find.byType(DSSwitch),
            matching: find.byType(AnimatedContainer),
          ),
        );
        final switchDecoration = switchTrack.decoration as BoxDecoration;
        expect(
          switchDecoration.color,
          equals(const Color(0xFFE51A4C)),
          reason: 'DSSwitch must resolve Taldarim Red from theme without registry mutation',
        );

        // Checkbox checked glow
        final checkboxGlow = tester.widget<DSGlowBorder>(
          find.descendant(
            of: find.byType(DSCheckbox),
            matching: find.byType(DSGlowBorder),
          ),
        );
        expect(
          checkboxGlow.color,
          equals(const Color(0xFFE51A4C)),
          reason: 'DSCheckbox must resolve Taldarim Red from theme without registry mutation',
        );

        // TextField focused border
        await tester.tap(find.byType(DSTextField));
        await tester.pumpAndSettle();
        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(
          textField.cursorColor,
          equals(const Color(0xFFE51A4C)),
          reason: 'DSTextField cursorColor must resolve Taldarim Red from theme',
        );

        // --- 2. Talon Purple (#9911E5) with ZERO registry mutation ---
        await tester.pumpWidget(buildApp(PrismTheme.talonPurple()));
        await tester.pumpAndSettle();

        final purpleButtonGlow = tester.widget<DSGlowBorder>(
          find.descendant(
            of: find.byType(DSButton),
            matching: find.byType(DSGlowBorder),
          ),
        );
        expect(
          purpleButtonGlow.color,
          equals(const Color(0xFF9911E5)),
          reason: 'DSButton must resolve Talon Purple from theme without registry mutation',
        );

        final purpleSwitchTrack = tester.widget<AnimatedContainer>(
          find.descendant(
            of: find.byType(DSSwitch),
            matching: find.byType(AnimatedContainer),
          ),
        );
        final purpleSwitchDeco = purpleSwitchTrack.decoration as BoxDecoration;
        expect(
          purpleSwitchDeco.color,
          equals(const Color(0xFF9911E5)),
          reason: 'DSSwitch must resolve Talon Purple from theme without registry mutation',
        );

        final purpleCheckboxGlow = tester.widget<DSGlowBorder>(
          find.descendant(
            of: find.byType(DSCheckbox),
            matching: find.byType(DSGlowBorder),
          ),
        );
        expect(
          purpleCheckboxGlow.color,
          equals(const Color(0xFF9911E5)),
          reason: 'DSCheckbox must resolve Talon Purple from theme without registry mutation',
        );

        final purpleTextField = tester.widget<TextField>(find.byType(TextField));
        expect(
          purpleTextField.cursorColor,
          equals(const Color(0xFF9911E5)),
          reason: 'DSTextField cursorColor must resolve Talon Purple from theme',
        );
      },
    );

    testWidgets(
      'Theme replacement test: swapping ThemeData in same subtree updates visible roles without registry mutation',
      (tester) async {
        final swapperKey = GlobalKey<_ThemeSwapperState>();

        await tester.pumpWidget(
          _ThemeSwapper(
            key: swapperKey,
            initialTheme: PrismTheme.dark(),
            child: Column(
              children: [
                DSButton(
                  label: 'Action',
                  variant: DSButtonVariant.primary,
                  onPressed: () {},
                ),
                DSSwitch(value: true, onChanged: (_) {}),
                DSCheckbox(value: true, onChanged: (_) {}),
                const DSTextField(label: 'Field'),
              ],
            ),
          ),
        );
        await tester.pumpAndSettle();

        // 1. Initial default: Khalai Blue (#2F81FF)
        DSGlowBorder buttonGlow = tester.widget<DSGlowBorder>(
          find.descendant(
            of: find.byType(DSButton),
            matching: find.byType(DSGlowBorder),
          ),
        );
        expect(buttonGlow.color, equals(const Color(0xFF2F81FF)));

        // 2. Swap theme to Taldarim Red
        swapperKey.currentState!.updateTheme(PrismTheme.taldarimRed());
        await tester.pumpAndSettle();

        buttonGlow = tester.widget<DSGlowBorder>(
          find.descendant(
            of: find.byType(DSButton),
            matching: find.byType(DSGlowBorder),
          ),
        );
        expect(buttonGlow.color, equals(const Color(0xFFE51A4C)));

        AnimatedContainer switchTrack = tester.widget<AnimatedContainer>(
          find.descendant(
            of: find.byType(DSSwitch),
            matching: find.byType(AnimatedContainer),
          ),
        );
        expect((switchTrack.decoration as BoxDecoration).color, equals(const Color(0xFFE51A4C)));

        DSGlowBorder checkboxGlow = tester.widget<DSGlowBorder>(
          find.descendant(
            of: find.byType(DSCheckbox),
            matching: find.byType(DSGlowBorder),
          ),
        );
        expect(checkboxGlow.color, equals(const Color(0xFFE51A4C)));

        // 3. Swap theme to Talon Purple
        swapperKey.currentState!.updateTheme(PrismTheme.talonPurple());
        await tester.pumpAndSettle();

        buttonGlow = tester.widget<DSGlowBorder>(
          find.descendant(
            of: find.byType(DSButton),
            matching: find.byType(DSGlowBorder),
          ),
        );
        expect(buttonGlow.color, equals(const Color(0xFF9911E5)));

        // 4. Swap theme to CyberCore Teal via applyToTheme
        swapperKey.currentState!.updateTheme(
          const PrismCyberCoreTealSkin.omniRoute().applyToTheme(PrismTheme.dark()),
        );
        await tester.pumpAndSettle();

        buttonGlow = tester.widget<DSGlowBorder>(
          find.descendant(
            of: find.byType(DSButton),
            matching: find.byType(DSGlowBorder),
          ),
        );
        expect(buttonGlow.color, equals(const Color(0xFF00FFCC)));

        // 5. Swap back to Khalai Blue
        swapperKey.currentState!.updateTheme(PrismTheme.dark());
        await tester.pumpAndSettle();

        buttonGlow = tester.widget<DSGlowBorder>(
          find.descendant(
            of: find.byType(DSButton),
            matching: find.byType(DSGlowBorder),
          ),
        );
        expect(buttonGlow.color, equals(const Color(0xFF2F81FF)));
      },
    );

    testWidgets('Interactive chrome updates when skin is applied and rebuilt', (
      tester,
    ) async {
      await tester.pumpWidget(
        ListenableBuilder(
          listenable: PrismTokenRegistry.instance,
          builder: (context, _) {
            return MaterialApp(
              theme: PrismTheme.dark(),
              home: Scaffold(
                body: Column(
                  children: [
                    DSButton(label: 'Action Button', onPressed: () {}),
                    DSCheckbox(value: true, onChanged: (_) {}),
                    DSSwitch(value: true, onChanged: (_) {}),
                    const DSTextField(label: 'Field'),
                    const SizedBox(
                      height: 150,
                      child: DSSidebar(
                        items: [
                          DSSidebarItem(id: 'item1', label: 'Item 1'),
                        ],
                        selectedId: 'item1',
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
      await tester.pumpAndSettle();

      // Initial state: Khalai Blue (#2F81FF)
      final initialGlow = tester.widget<DSGlowBorder>(find.byType(DSGlowBorder).first);
      expect(initialGlow.color, equals(const Color(0xFF2F81FF)));

      // Switch to Taldarim Red
      PrismTokenRegistry.instance.applySkin(const PrismTaldarimRedSkin.taldarimRed());
      await tester.pumpAndSettle();

      // Button and Checkbox should now reflect Taldarim Red (#E51A4C)
      final redGlows = tester.widgetList<DSGlowBorder>(find.byType(DSGlowBorder)).toList();
      expect(redGlows.first.color, equals(const Color(0xFFE51A4C)));
      expect(redGlows[1].color, equals(const Color(0xFFE51A4C)));

      // Switch to Talon Purple
      PrismTokenRegistry.instance.applySkin(const PrismTalonPurpleSkin.talonPurple());
      await tester.pumpAndSettle();

      final purpleGlows = tester.widgetList<DSGlowBorder>(find.byType(DSGlowBorder)).toList();
      expect(purpleGlows.first.color, equals(const Color(0xFF9911E5)));
      expect(purpleGlows[1].color, equals(const Color(0xFF9911E5)));

      // Switch to CyberCore Teal
      PrismTokenRegistry.instance.applySkin(const PrismCyberCoreTealSkin.omniRoute());
      await tester.pumpAndSettle();

      final tealGlows = tester.widgetList<DSGlowBorder>(find.byType(DSGlowBorder)).toList();
      expect(tealGlows.first.color, equals(const Color(0xFF00FFCC)));
      expect(tealGlows[1].color, equals(const Color(0xFF00FFCC)));

      // Revert to Khalai Blue
      PrismTokenRegistry.instance.reset();
      await tester.pumpAndSettle();

      final revertedGlow = tester.widget<DSGlowBorder>(find.byType(DSGlowBorder).first);
      expect(revertedGlow.color, equals(const Color(0xFF2F81FF)));
    });

    testWidgets('DSTheme accent recipe helpers resolve correct colors per theme', (
      tester,
    ) async {
      late Color resolvedAccent;
      late Color resolvedMuted;
      late Color resolvedDim;
      late Color resolvedFocus;

      Widget buildProbe(ThemeData theme) {
        return MaterialApp(
          theme: theme,
          home: Builder(
            builder: (context) {
              resolvedAccent = PrismTheme.accentOf(context);
              resolvedMuted = PrismTheme.accentMutedOf(context);
              resolvedDim = PrismTheme.accentDimOf(context);
              resolvedFocus = PrismTheme.focusRingOf(context);
              return const SizedBox.shrink();
            },
          ),
        );
      }

      // 1. Default dark theme (Khalai Blue)
      await tester.pumpWidget(buildProbe(PrismTheme.dark()));
      await tester.pumpAndSettle();
      expect(resolvedAccent, equals(const Color(0xFF2F81FF)));
      expect(resolvedMuted, equals(const Color(0xFF1D64D8)));
      expect(resolvedDim, equals(const Color(0xFF114299)));
      expect(resolvedFocus, equals(const Color(0xFF2F81FF).withValues(alpha: 0.5)));

      // 2. Taldarim Red theme
      await tester.pumpWidget(buildProbe(PrismTheme.taldarimRed()));
      await tester.pumpAndSettle();
      expect(resolvedAccent, equals(const Color(0xFFE51A4C)));
      expect(resolvedMuted, equals(const Color(0xFFB8103A)));
      expect(resolvedDim, equals(const Color(0xFF7A0A26)));
      expect(resolvedFocus, equals(const Color(0xFFE51A4C).withValues(alpha: 0.5)));

      // 3. Talon Purple theme
      await tester.pumpWidget(buildProbe(PrismTheme.talonPurple()));
      await tester.pumpAndSettle();
      expect(resolvedAccent, equals(const Color(0xFF9911E5)));
      expect(resolvedMuted, equals(const Color(0xFF770CB3)));
      expect(resolvedDim, equals(const Color(0xFF4F0878)));
      expect(resolvedFocus, equals(const Color(0xFF9911E5).withValues(alpha: 0.5)));

      // 4. CyberCore Teal skin applied over dark theme
      await tester.pumpWidget(
        buildProbe(
          const PrismCyberCoreTealSkin.omniRoute().applyToTheme(PrismTheme.dark()),
        ),
      );
      await tester.pumpAndSettle();
      expect(resolvedAccent, equals(const Color(0xFF00FFCC)));
      expect(resolvedMuted, equals(const Color(0xFF00B894)));
      expect(resolvedDim, equals(const Color(0xFF007A66)));
      expect(resolvedFocus, equals(const Color(0xFF00FFCC).withValues(alpha: 0.5)));
    });

    test('Criterion 9: Contrast re-proof for recipe accent ladder roles', () {
      // Prove that white text on dark surfaces with each recipe's accent meets WCAG AA standards
      final recipes = [
        ('Khalai Blue', const Color(0xFF2F81FF), const Color(0xFF114299)),
        ('Taldarim Red', const Color(0xFFE51A4C), const Color(0xFF7A0A26)),
        ('Talon Purple', const Color(0xFF9911E5), const Color(0xFF4F0878)),
        ('CyberCore Teal', const Color(0xFF00FFCC), const Color(0xFF007A66)),
      ];

      for (final (name, accent, dim) in recipes) {
        // High-contrast focus ring visibility (channel sum > 200)
        final channelSum = (accent.r + accent.g + accent.b) * 255.0;
        expect(
          channelSum,
          greaterThan(200),
          reason: '$name accent must be bright enough for focus indicators',
        );

        // White text on accentDim (used for selected item backgrounds / tags)
        final contrastOnDim = _contrastRatio(PrismColors.white, dim);
        expect(
          contrastOnDim,
          greaterThanOrEqualTo(4.5),
          reason: '$name white text on accentDim must meet WCAG AA (>= 4.5:1), got ${contrastOnDim.toStringAsFixed(2)}',
        );
      }
    });
  });
}

class _ThemeSwapper extends StatefulWidget {
  final ThemeData initialTheme;
  final Widget child;

  const _ThemeSwapper({
    super.key,
    required this.initialTheme,
    required this.child,
  });

  @override
  State<_ThemeSwapper> createState() => _ThemeSwapperState();
}

class _ThemeSwapperState extends State<_ThemeSwapper> {
  late ThemeData _theme;

  @override
  void initState() {
    super.initState();
    _theme = widget.initialTheme;
  }

  void updateTheme(ThemeData newTheme) {
    setState(() {
      _theme = newTheme;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _theme,
      home: Scaffold(
        body: widget.child,
      ),
    );
  }
}
