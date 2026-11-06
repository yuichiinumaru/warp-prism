import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';
import 'package:warp_prism_ui/src/atoms/switch/ds_switch.dart';
import 'package:warp_prism_ui/src/tokens/tokens.dart';

void main() {
  group('DSSwitch Widget Tests', () {
    testWidgets('Off state renders track and thumb on the left', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(child: DSSwitch(value: false, onChanged: (_) {})),
          ),
        ),
      );

      final switchFinder = find.byType(DSSwitch);
      expect(switchFinder, findsOneWidget);

      final animatedAlign = tester.widget<AnimatedAlign>(
        find.descendant(of: switchFinder, matching: find.byType(AnimatedAlign)),
      );
      expect(animatedAlign.alignment, Alignment.centerLeft);
    });

    testWidgets('On state renders thumb on the right', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(child: DSSwitch(value: true, onChanged: (_) {})),
          ),
        ),
      );

      final animatedAlign = tester.widget<AnimatedAlign>(
        find.descendant(
          of: find.byType(DSSwitch),
          matching: find.byType(AnimatedAlign),
        ),
      );
      expect(animatedAlign.alignment, Alignment.centerRight);
    });

    testWidgets(
      'Tapping switch triggers onChanged callback with toggled value',
      (WidgetTester tester) async {
        bool? newValue;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: DSSwitch(
                  value: false,
                  onChanged: (val) => newValue = val,
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.byType(DSSwitch));
        await tester.pump();

        expect(newValue, isTrue);
      },
    );

    testWidgets(
      'Label renders next to switch and tapping label toggles switch',
      (WidgetTester tester) async {
        bool? newValue;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: DSSwitch(
                  value: false,
                  onChanged: (val) => newValue = val,
                  label: 'Enable Feature',
                ),
              ),
            ),
          ),
        );

        expect(find.text('Enable Feature'), findsOneWidget);

        await tester.tap(find.text('Enable Feature'));
        await tester.pump();

        expect(newValue, isTrue);
      },
    );

    testWidgets('Disabled state reduces opacity and ignores tap input', (
      WidgetTester tester,
    ) async {
      bool called = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: DSSwitch(
                value: false,
                enabled: false,
                onChanged: (val) => called = true,
                label: 'Disabled Switch',
              ),
            ),
          ),
        ),
      );

      expect(find.byType(Opacity), findsOneWidget);

      await tester.tap(find.byType(DSSwitch));
      await tester.pump();

      expect(called, isFalse);
    });

    testWidgets('Keyboard activation (Space and Enter) toggles switch', (
      WidgetTester tester,
    ) async {
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      int toggleCount = 0;
      bool currentValue = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: StatefulBuilder(
                builder: (context, setState) {
                  return DSSwitch(
                    value: currentValue,
                    focusNode: focusNode,
                    onChanged: (val) {
                      toggleCount++;
                      setState(() => currentValue = val);
                    },
                  );
                },
              ),
            ),
          ),
        ),
      );

      focusNode.requestFocus();
      await tester.pump();
      expect(focusNode.hasFocus, isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(toggleCount, 1);
      expect(currentValue, isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(toggleCount, 2);
      expect(currentValue, isFalse);
    });

    testWidgets('Interactive touch target enforces min 48x48 size', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(child: DSSwitch(value: false, onChanged: (_) {})),
          ),
        ),
      );

      final size = tester.getSize(find.byType(DSSwitch));
      expect(size.width, greaterThanOrEqualTo(48.0));
      expect(size.height, greaterThanOrEqualTo(48.0));
    });

    testWidgets(
      'PrismSwitch and PrismToggle public aliases function as DSSwitch',
      (WidgetTester tester) async {
        bool? toggled;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: Column(
                  children: [
                    PrismSwitch(
                      value: false,
                      onChanged: (val) => toggled = val,
                      label: 'Prism Switch',
                    ),
                    PrismToggle(
                      value: false,
                      onChanged: (val) => toggled = val,
                      label: 'Prism Toggle',
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        expect(find.text('Prism Switch'), findsOneWidget);
        expect(find.text('Prism Toggle'), findsOneWidget);
        await tester.tap(find.byType(PrismSwitch).first);
        await tester.pump();
        expect(toggled, isTrue);
      },
    );

    testWidgets(
      'Nerazim Teal skin accent overrides active track color when present',
      (WidgetTester tester) async {
        const tealSkin = DSNerazimTealSkin.nerazimTeal();

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark().copyWith(extensions: const [tealSkin]),
            home: Scaffold(
              body: Center(child: DSSwitch(value: true, onChanged: (_) {})),
            ),
          ),
        );

        final animatedContainer = tester.widget<AnimatedContainer>(
          find.byType(AnimatedContainer).first,
        );
        final decoration = animatedContainer.decoration as BoxDecoration;
        expect(decoration.color, tealSkin.accent);
      },
    );
  });
}
