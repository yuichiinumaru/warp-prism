import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/src/molecules/color_field/color_field.dart';
import 'package:warp_prism_ui/src/theme/ds_theme.dart';
import 'package:warp_prism_ui/src/tokens/tokens.dart';

int _a(Color c) => (c.a * 255).round().clamp(0, 255);
int _r(Color c) => (c.r * 255).round().clamp(0, 255);
int _g(Color c) => (c.g * 255).round().clamp(0, 255);
int _b(Color c) => (c.b * 255).round().clamp(0, 255);

void main() {
  Widget buildFrame(Widget child) {
    return MaterialApp(
      theme: DSTheme.dark(),
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(DSSpacing.md),
          child: child,
        ),
      ),
    );
  }

  group('DSColorField Widget Tests', () {
    testWidgets('renders initial color value and label', (tester) async {
      await tester.pumpWidget(
        buildFrame(
          const DSColorField(label: 'Accent Color', value: Color(0xFF2F81FF)),
        ),
      );

      expect(find.text('Accent Color'), findsOneWidget);
      expect(find.text('#2F81FF'), findsOneWidget);
    });

    testWidgets('fires onChanged when valid 6-digit hex typed', (tester) async {
      Color? changedColor;
      await tester.pumpWidget(
        buildFrame(
          DSColorField(
            label: 'Color Field',
            onChanged: (color) => changedColor = color,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), '#00D4FF');
      await tester.pumpAndSettle();

      expect(changedColor, isNotNull);
      expect(changedColor, equals(const Color(0xFF00D4FF)));
    });

    testWidgets('fires onChanged when valid 3-digit hex typed', (tester) async {
      Color? changedColor;
      await tester.pumpWidget(
        buildFrame(
          DSColorField(
            label: 'Color Field',
            onChanged: (color) => changedColor = color,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), '#F0A');
      await tester.pumpAndSettle();

      expect(changedColor, isNotNull);
      expect(_r(changedColor!), equals(0xFF));
      expect(_g(changedColor!), equals(0x00));
      expect(_b(changedColor!), equals(0xAA));
    });

    testWidgets('fires onChanged when valid 8-digit hex typed', (tester) async {
      Color? changedColor;
      await tester.pumpWidget(
        buildFrame(
          DSColorField(
            label: 'Color Field',
            onChanged: (color) => changedColor = color,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), '#80FF0000');
      await tester.pumpAndSettle();

      expect(changedColor, isNotNull);
      expect(_a(changedColor!), equals(0x80));
      expect(_r(changedColor!), equals(0xFF));
    });

    testWidgets('shows parse error when invalid hex typed', (tester) async {
      await tester.pumpWidget(
        buildFrame(const DSColorField(label: 'Color Field')),
      );

      await tester.enterText(find.byType(TextField), '#INVALID');
      await tester.pumpAndSettle();

      expect(find.textContaining('Invalid hex color'), findsOneWidget);
    });

    testWidgets('shows custom errorText when provided', (tester) async {
      await tester.pumpWidget(
        buildFrame(
          const DSColorField(
            label: 'Color Field',
            errorText: 'Custom error message',
          ),
        ),
      );

      expect(find.text('Custom error message'), findsOneWidget);
    });

    testWidgets('swatch tap selects color and fires onChanged', (tester) async {
      Color? selectedColor;
      await tester.pumpWidget(
        buildFrame(
          DSColorField(
            label: 'Color Field',
            onChanged: (color) => selectedColor = color,
            presetSwatches: const [Color(0xFF2F81FF), Color(0xFF00D4FF)],
          ),
        ),
      );

      final cyanSwatchFinder = find.bySemanticsLabel(RegExp(r'00D4FF'));
      expect(cyanSwatchFinder, findsOneWidget);

      await tester.tap(cyanSwatchFinder);
      await tester.pumpAndSettle();

      expect(selectedColor, equals(const Color(0xFF00D4FF)));
      expect(find.text('#00D4FF'), findsOneWidget);
    });

    testWidgets('clear button clears text and fires onChanged with null', (
      tester,
    ) async {
      Color? selectedColor = const Color(0xFF2F81FF);
      await tester.pumpWidget(
        buildFrame(
          DSColorField(
            label: 'Color Field',
            value: selectedColor,
            onChanged: (color) => selectedColor = color,
          ),
        ),
      );

      final clearButtonFinder = find.bySemanticsLabel('Clear color field');
      expect(clearButtonFinder, findsOneWidget);

      await tester.tap(clearButtonFinder);
      await tester.pumpAndSettle();

      expect(selectedColor, isNull);
      expect(find.text('#2F81FF'), findsNothing);
    });

    testWidgets('eyedropper button fires onEyedropperTap callback', (
      tester,
    ) async {
      bool eyedropperTapped = false;
      await tester.pumpWidget(
        buildFrame(
          DSColorField(
            label: 'Color Field',
            onEyedropperTap: () => eyedropperTapped = true,
          ),
        ),
      );

      final eyedropperFinder = find.bySemanticsLabel(
        'Activate color eyedropper',
      );
      expect(eyedropperFinder, findsOneWidget);

      await tester.tap(eyedropperFinder);
      await tester.pumpAndSettle();

      expect(eyedropperTapped, isTrue);
    });

    testWidgets('disabled state prevents interaction', (tester) async {
      bool changed = false;
      await tester.pumpWidget(
        buildFrame(
          DSColorField(
            label: 'Color Field',
            enabled: false,
            value: const Color(0xFF2F81FF),
            onChanged: (_) => changed = true,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), '#00D4FF');
      await tester.pumpAndSettle();

      expect(changed, isFalse);
    });

    testWidgets(
      'enforces min 48x48 touch targets for swatches and action buttons',
      (tester) async {
        await tester.pumpWidget(
          buildFrame(
            DSColorField(
              label: 'Color Field',
              value: const Color(0xFF2F81FF),
              onEyedropperTap: () {},
              presetSwatches: const [Color(0xFF2F81FF)],
            ),
          ),
        );

        final eyedropperSize = tester.getSize(
          find.bySemanticsLabel('Activate color eyedropper'),
        );
        expect(eyedropperSize.width, greaterThanOrEqualTo(48));
        expect(eyedropperSize.height, greaterThanOrEqualTo(48));

        final clearSize = tester.getSize(
          find.bySemanticsLabel('Clear color field'),
        );
        expect(clearSize.width, greaterThanOrEqualTo(48));
        expect(clearSize.height, greaterThanOrEqualTo(48));

        final swatchSize = tester.getSize(
          find.bySemanticsLabel(RegExp(r'2F81FF')),
        );
        expect(swatchSize.width, greaterThanOrEqualTo(48));
        expect(swatchSize.height, greaterThanOrEqualTo(48));
      },
    );

    testWidgets('recovers error state sequentially valid -> invalid -> valid', (
      tester,
    ) async {
      Color? changedColor;
      await tester.pumpWidget(
        buildFrame(
          DSColorField(
            label: 'Color Field',
            onChanged: (color) => changedColor = color,
          ),
        ),
      );

      // 1. Valid hex #2F81FF
      await tester.enterText(find.byType(TextField), '#2F81FF');
      await tester.pumpAndSettle();
      expect(changedColor, equals(const Color(0xFF2F81FF)));
      expect(find.textContaining('Invalid hex color'), findsNothing);

      // 2. Invalid hex #INVALID
      await tester.enterText(find.byType(TextField), '#INVALID');
      await tester.pumpAndSettle();
      expect(find.textContaining('Invalid hex color'), findsOneWidget);

      // 3. Valid hex #00D4FF
      await tester.enterText(find.byType(TextField), '#00D4FF');
      await tester.pumpAndSettle();
      expect(changedColor, equals(const Color(0xFF00D4FF)));
      expect(find.textContaining('Invalid hex color'), findsNothing);
    });

    testWidgets('normalizes leading and trailing whitespace in widget path', (
      tester,
    ) async {
      Color? changedColor;
      await tester.pumpWidget(
        buildFrame(
          DSColorField(
            label: 'Color Field',
            onChanged: (color) => changedColor = color,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), '   #2F81FF   ');
      await tester.pumpAndSettle();

      expect(changedColor, equals(const Color(0xFF2F81FF)));
      expect(find.textContaining('Invalid hex color'), findsNothing);
    });

    testWidgets('explicitly rejects 4-digit hex #RGBA in widget path', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildFrame(const DSColorField(label: 'Color Field')),
      );

      await tester.enterText(find.byType(TextField), '#1234');
      await tester.pumpAndSettle();

      expect(find.textContaining('Invalid hex color'), findsOneWidget);
    });

    testWidgets(
      'swatch focus traversal and keyboard activation via Space/Enter key',
      (tester) async {
        Color? selectedColor;
        await tester.pumpWidget(
          buildFrame(
            DSColorField(
              label: 'Color Field',
              onChanged: (color) => selectedColor = color,
              presetSwatches: const [Color(0xFF2F81FF), Color(0xFF00D4FF)],
            ),
          ),
        );

        final surfaceFinder = find.bySemanticsLabel('Color swatch #00D4FF');
        expect(surfaceFinder, findsOneWidget);

        // Start in the text field and traverse to both swatches so the shortcuts
        // exercise the focusable interactive surface rather than the tap handler.
        await tester.tap(find.byType(TextField));
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();

        selectedColor = null;
        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await tester.pumpAndSettle();
        expect(selectedColor, equals(const Color(0xFF00D4FF)));

        selectedColor = null;
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();

        expect(selectedColor, equals(const Color(0xFF00D4FF)));
      },
    );

    testWidgets(
      'full semantics tree assertions for field, swatches, clear, and eyedropper',
      (tester) async {
        await tester.pumpWidget(
          buildFrame(
            DSColorField(
              label: 'Primary Accent',
              value: const Color(0xFF2F81FF),
              onEyedropperTap: () {},
              presetSwatches: const [Color(0xFF2F81FF), Color(0xFF00D4FF)],
            ),
          ),
        );

        expect(
          tester.getSemantics(find.byType(TextField)),
          matchesSemantics(
            isTextField: true,
            label: 'Primary Accent',
            hint: '#RRGGBB',
            hasEnabledState: true,
            isEnabled: true,
          ),
        );

        expect(find.bySemanticsLabel('Clear color field'), findsOneWidget);

        expect(
          find.bySemanticsLabel('Activate color eyedropper'),
          findsOneWidget,
        );

        expect(find.bySemanticsLabel('Color swatch #2F81FF'), findsOneWidget);
        expect(find.bySemanticsLabel('Color swatch #00D4FF'), findsOneWidget);
      },
    );
  });
}
