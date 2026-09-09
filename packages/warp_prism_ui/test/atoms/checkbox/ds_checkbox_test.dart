import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart' hide group;
// ignore: depend_on_referenced_packages
import 'package:test_api/scaffolding.dart' show group;
import 'package:warp_prism_ui/src/atoms/atoms.dart';
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
  group('DSCheckbox unit and widget tests', () {
    testWidgets('Unchecked renders empty box without check icon or bar', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(DSCheckbox(value: false, onChanged: (_) {}, label: 'Unchecked')),
      );

      expect(find.text('Unchecked'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsNothing);
    });

    testWidgets(
      'Checked renders check mark and accent blue background with glow',
      (tester) async {
        await tester.pumpWidget(
          _wrap(DSCheckbox(value: true, onChanged: (_) {}, label: 'Checked')),
        );

        expect(find.text('Checked'), findsOneWidget);
        expect(find.byIcon(Icons.check), findsOneWidget);
        expect(find.byType(DSGlowBorder), findsOneWidget);
      },
    );

    testWidgets('Indeterminate renders horizontal blue bar', (tester) async {
      await tester.pumpWidget(
        _wrap(
          DSCheckbox(
            value: null,
            tristate: true,
            onChanged: (_) {},
            label: 'Indeterminate',
          ),
        ),
      );

      expect(find.text('Indeterminate'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsNothing);
      // Indeterminate state renders a 10x2 blue bar Container inside center
      final containers = tester.widgetList<Container>(find.byType(Container));
      final barContainer = containers.firstWhere(
        (c) =>
            c.constraints?.minWidth == 10 ||
            (c.decoration is BoxDecoration &&
                (c.decoration as BoxDecoration).color == DSColors.accentBlue),
      );
      expect(barContainer, isNotNull);
    });

    testWidgets(
      'Tap fires onChanged with toggled value (false -> true -> false)',
      (tester) async {
        bool? currentValue = false;

        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return _wrap(
                DSCheckbox(
                  value: currentValue,
                  onChanged: (val) {
                    setState(() {
                      currentValue = val;
                    });
                  },
                  label: 'Toggleable',
                ),
              );
            },
          ),
        );

        expect(currentValue, false);
        await tester.tap(find.text('Toggleable'));
        await tester.pumpAndSettle();
        expect(currentValue, true);

        await tester.tap(find.byType(DSCheckbox));
        await tester.pumpAndSettle();
        expect(currentValue, false);
      },
    );

    testWidgets('Tristate cycles correctly: false -> true -> null -> false', (
      tester,
    ) async {
      bool? currentValue = false;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return _wrap(
              DSCheckbox(
                value: currentValue,
                tristate: true,
                onChanged: (val) {
                  setState(() {
                    currentValue = val;
                  });
                },
                label: 'Tristate',
              ),
            );
          },
        ),
      );

      expect(currentValue, false);

      // Tap 1: false -> true
      await tester.tap(find.byType(DSCheckbox));
      await tester.pumpAndSettle();
      expect(currentValue, true);

      // Tap 2: true -> null
      await tester.tap(find.byType(DSCheckbox));
      await tester.pumpAndSettle();
      expect(currentValue, null);

      // Tap 3: null -> false
      await tester.tap(find.byType(DSCheckbox));
      await tester.pumpAndSettle();
      expect(currentValue, false);
    });

    testWidgets('Disabled reduces opacity and ignores input', (tester) async {
      bool? currentValue = false;

      await tester.pumpWidget(
        _wrap(
          DSCheckbox(
            value: false,
            enabled: false,
            onChanged: (val) {
              currentValue = val;
            },
            label: 'Disabled',
          ),
        ),
      );

      final opacityWidget = tester.widget<Opacity>(find.byType(Opacity));
      expect(opacityWidget.opacity, 0.5);

      await tester.tap(find.byType(DSCheckbox));
      await tester.pumpAndSettle();
      expect(currentValue, false);
    });

    testWidgets('Space key toggles when focused', (tester) async {
      bool? currentValue = false;
      final focusNode = FocusNode();

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return _wrap(
              DSCheckbox(
                value: currentValue,
                onChanged: (val) {
                  setState(() {
                    currentValue = val;
                  });
                },
                focusNode: focusNode,
                label: 'Keyboard Toggle',
              ),
            );
          },
        ),
      );

      focusNode.requestFocus();
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(currentValue, true);

      focusNode.dispose();
    });

    testWidgets('Minimum 48x48 touch target constraint is enforced', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(DSCheckbox(value: false, onChanged: (_) {})),
      );

      final renderBox = tester.renderObject<RenderBox>(find.byType(DSCheckbox));
      expect(renderBox.size.width, greaterThanOrEqualTo(48.0));
      expect(renderBox.size.height, greaterThanOrEqualTo(48.0));
    });
  });

  group('DSCheckbox golden tests', tags: 'golden', () {
    testWidgets('renders unchecked golden', (tester) async {
      await tester.pumpWidget(
        _wrap(
          DSCheckbox(
            value: false,
            onChanged: (_) {},
            label: 'Unchecked Option',
          ),
        ),
      );
      await expectLater(
        find.byType(DSCheckbox),
        matchesGoldenFile('../../goldens/goldens/checkbox_unchecked.png'),
      );
    });

    testWidgets('renders checked golden', (tester) async {
      await tester.pumpWidget(
        _wrap(
          DSCheckbox(value: true, onChanged: (_) {}, label: 'Checked Option'),
        ),
      );
      await expectLater(
        find.byType(DSCheckbox),
        matchesGoldenFile('../../goldens/goldens/checkbox_checked.png'),
      );
    });

    testWidgets('renders indeterminate golden', (tester) async {
      await tester.pumpWidget(
        _wrap(
          DSCheckbox(
            value: null,
            tristate: true,
            onChanged: (_) {},
            label: 'Indeterminate Option',
          ),
        ),
      );
      await expectLater(
        find.byType(DSCheckbox),
        matchesGoldenFile('../../goldens/goldens/checkbox_indeterminate.png'),
      );
    });

    testWidgets('renders disabled golden', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const DSCheckbox(
            value: true,
            enabled: false,
            onChanged: null,
            label: 'Disabled Option',
          ),
        ),
      );
      await expectLater(
        find.byType(DSCheckbox),
        matchesGoldenFile('../../goldens/goldens/checkbox_disabled.png'),
      );
    });
  });
}
