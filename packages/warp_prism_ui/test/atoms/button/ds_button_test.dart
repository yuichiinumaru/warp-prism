import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart' hide group;
// ignore: depend_on_referenced_packages
import 'package:test_api/scaffolding.dart' show group;
import 'package:warp_prism_ui/src/atoms/atoms.dart';
import 'package:warp_prism_ui/src/molecules/molecules.dart';
import 'package:warp_prism_ui/src/theme/ds_theme.dart';
import 'package:warp_prism_ui/src/tokens/tokens.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: PrismTheme.dark(),
    home: Scaffold(
      backgroundColor: DSColors.obsidianBase,
      body: Center(child: child),
    ),
  );
}

void main() {
  group('DSButton unit & widget tests', () {
    testWidgets('Renders label and primary variant by default', (tester) async {
      await tester.pumpWidget(
        _wrap(DSButton(label: 'Click Me', onPressed: () {})),
      );

      expect(find.text('Click Me'), findsOneWidget);
      expect(find.byType(DSGlassPanel), findsOneWidget);
      expect(find.byType(DSGlowBorder), findsOneWidget);
    });

    testWidgets('Named constructors render corresponding variants', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          Column(
            children: [
              DSButton.primary(label: 'Primary', onPressed: () {}),
              DSButton.secondary(label: 'Secondary', onPressed: () {}),
              DSButton.outline(label: 'Outline', onPressed: () {}),
              DSButton.ghost(label: 'Ghost', onPressed: () {}),
              DSButton.danger(label: 'Danger', onPressed: () {}),
            ],
          ),
        ),
      );

      expect(find.text('Primary'), findsOneWidget);
      expect(find.text('Secondary'), findsOneWidget);
      expect(find.text('Outline'), findsOneWidget);
      expect(find.text('Ghost'), findsOneWidget);
      expect(find.text('Danger'), findsOneWidget);
    });

    testWidgets('Renders leading and trailing icons when provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          DSButton(
            label: 'Action',
            icon: Icons.play_arrow,
            trailingIcon: Icons.arrow_forward,
            onPressed: () {},
          ),
        ),
      );

      expect(find.text('Action'), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
    });

    testWidgets('Tap fires onPressed callback', (tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        _wrap(
          DSButton(
            label: 'Press',
            onPressed: () {
              pressed = true;
            },
          ),
        ),
      );

      await tester.tap(find.byType(DSButton));
      await tester.pumpAndSettle();

      expect(pressed, isTrue);
    });

    testWidgets('Disabled state reduces opacity and does not fire onPressed', (
      tester,
    ) async {
      bool pressed = false;

      await tester.pumpWidget(
        _wrap(
          DSButton(
            label: 'Disabled',
            enabled: false,
            onPressed: () {
              pressed = true;
            },
          ),
        ),
      );

      expect(find.text('Disabled'), findsOneWidget);

      final Opacity opacityWidget = tester.widget<Opacity>(
        find.descendant(
          of: find.byType(DSButton),
          matching: find.byType(Opacity),
        ),
      );
      expect(opacityWidget.opacity, 0.5);

      await tester.tap(find.byType(DSButton));
      await tester.pumpAndSettle();

      expect(pressed, isFalse);
    });

    testWidgets(
      'Loading state shows CircularProgressIndicator, hides label, and blocks onPressed',
      (tester) async {
        bool pressed = false;

        await tester.pumpWidget(
          _wrap(
            DSButton(
              label: 'Loading',
              isLoading: true,
              onPressed: () {
                pressed = true;
              },
            ),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Loading'), findsNothing);

        await tester.tap(find.byType(DSButton));
        await tester.pump();

        expect(pressed, isFalse);
      },
    );

    testWidgets(
      'Keyboard activation (Enter and Space) fires onPressed when focused',
      (tester) async {
        int pressCount = 0;
        final focusNode = FocusNode();

        await tester.pumpWidget(
          _wrap(
            DSButton(
              label: 'Keyboard Focus',
              focusNode: focusNode,
              onPressed: () {
                pressCount++;
              },
            ),
          ),
        );

        focusNode.requestFocus();
        await tester.pump();

        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        expect(pressCount, 1);

        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await tester.pumpAndSettle();
        expect(pressCount, 2);

        focusNode.dispose();
      },
    );

    testWidgets('Tab-focus renders visible focus ring BoxDecoration', (
      tester,
    ) async {
      final focusNode = FocusNode();

      await tester.pumpWidget(
        _wrap(
          Column(
            children: [
              // Dummy focus target so Tab moves focus to the button.
              const Focus(
                autofocus: true,
                child: SizedBox(width: 10, height: 10),
              ),
              DSButton(
                label: 'Focus Ring',
                focusNode: focusNode,
                onPressed: () {},
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tab switches FocusHighlightMode to traditional and moves focus.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();

      expect(focusNode.hasFocus, isTrue);

      // Verify the blue focus-ring BoxDecoration renders.
      final containers = <Widget>[
        ...tester.widgetList<Container>(find.byType(Container)),
        ...tester.widgetList<AnimatedContainer>(find.byType(AnimatedContainer)),
      ];
      bool foundFocusRing = false;
      final expectedColor = DSTheme.focusRingOf(tester.element(find.byType(DSButton)));
      for (final c in containers) {
        final dec = c is Container
            ? c.decoration
            : (c as AnimatedContainer).decoration;
        if (dec is BoxDecoration && dec.border is Border) {
          final side = (dec.border! as Border).top;
          if (side.width == 2 &&
              side.style == BorderStyle.solid &&
              side.color == expectedColor) {
            foundFocusRing = true;
            break;
          }
        }
      }
      expect(
        foundFocusRing,
        isTrue,
        reason:
            'DSInteractiveSurface should render a blue focus ring when keyboard-focused',
      );

      focusNode.dispose();
    });

    testWidgets('Enforces minimum 48x48px interactive target', (tester) async {
      await tester.pumpWidget(
        _wrap(
          DSButton(label: 'Min Touch', size: DSButtonSize.sm, onPressed: () {}),
        ),
      );

      final size = tester.getSize(find.byType(DSInteractiveSurface));
      expect(size.width, greaterThanOrEqualTo(48.0));
      expect(size.height, greaterThanOrEqualTo(48.0));
    });
  });

  group('DSButton golden tests', tags: 'golden', () {
    testWidgets('Primary variant golden', (tester) async {
      await tester.pumpWidget(
        _wrap(DSButton.primary(label: 'Primary Button', onPressed: () {})),
      );
      await expectLater(
        find.byType(DSButton),
        matchesGoldenFile('../../goldens/button_primary.png'),
      );
    });

    testWidgets('Secondary variant golden', (tester) async {
      await tester.pumpWidget(
        _wrap(DSButton.secondary(label: 'Secondary Button', onPressed: () {})),
      );
      await expectLater(
        find.byType(DSButton),
        matchesGoldenFile('../../goldens/button_secondary.png'),
      );
    });

    testWidgets('Outline variant golden', (tester) async {
      await tester.pumpWidget(
        _wrap(DSButton.outline(label: 'Outline Button', onPressed: () {})),
      );
      await expectLater(
        find.byType(DSButton),
        matchesGoldenFile('../../goldens/button_outline.png'),
      );
    });

    testWidgets('Ghost variant golden', (tester) async {
      await tester.pumpWidget(
        _wrap(DSButton.ghost(label: 'Ghost Button', onPressed: () {})),
      );
      await expectLater(
        find.byType(DSButton),
        matchesGoldenFile('../../goldens/button_ghost.png'),
      );
    });

    testWidgets('Danger variant golden', (tester) async {
      await tester.pumpWidget(
        _wrap(DSButton.danger(label: 'Danger Button', onPressed: () {})),
      );
      await expectLater(
        find.byType(DSButton),
        matchesGoldenFile('../../goldens/button_danger.png'),
      );
    });

    testWidgets('Disabled state golden', (tester) async {
      await tester.pumpWidget(
        _wrap(const DSButton.primary(label: 'Disabled Button', enabled: false)),
      );
      await expectLater(
        find.byType(DSButton),
        matchesGoldenFile('../../goldens/button_disabled.png'),
      );
    });

    testWidgets('Loading state golden', (tester) async {
      await tester.pumpWidget(
        _wrap(const DSButton.primary(label: 'Loading Button', isLoading: true)),
      );
      await expectLater(
        find.byType(DSButton),
        matchesGoldenFile('../../goldens/button_loading.png'),
      );
    });
  });
}
