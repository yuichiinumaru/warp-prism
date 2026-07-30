import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/src/atoms/atoms.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: ThemeData.dark(),
    home: Scaffold(
      backgroundColor: PrismColors.obsidianBase,
      body: Center(
        child: SizedBox(
          width: 400,
          child: child,
        ),
      ),
    ),
  );
}

void main() {
  group('DSTextField unit and widget tests', () {
    testWidgets('renders label, hint, and helperText correctly', (tester) async {
      await tester.pumpWidget(_wrap(
        const DSTextField(
          label: 'Username',
          hint: 'Enter your username',
          helperText: 'Must be unique',
        ),
      ));

      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Enter your username'), findsOneWidget);
      expect(find.text('Must be unique'), findsOneWidget);
    });

    testWidgets('errorText overrides helperText and displays error message', (tester) async {
      await tester.pumpWidget(_wrap(
        const DSTextField(
          label: 'Email',
          hint: 'Enter email',
          helperText: 'Optional helper',
          errorText: 'Invalid email address',
        ),
      ));

      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Invalid email address'), findsOneWidget);
      expect(find.text('Optional helper'), findsNothing);
    });

    testWidgets('typing text updates controller and fires onChanged', (tester) async {
      String changedValue = '';
      final controller = TextEditingController();

      await tester.pumpWidget(_wrap(
        DSTextField(
          controller: controller,
          label: 'Input',
          onChanged: (val) {
            changedValue = val;
          },
        ),
      ));

      await tester.enterText(find.byType(TextField), 'Hello Prism');
      await tester.pumpAndSettle();

      expect(controller.text, 'Hello Prism');
      expect(changedValue, 'Hello Prism');
    });

    testWidgets('submitting text fires onSubmitted', (tester) async {
      String submittedValue = '';

      await tester.pumpWidget(_wrap(
        DSTextField(
          label: 'Submit Field',
          onSubmitted: (val) {
            submittedValue = val;
          },
        ),
      ));

      await tester.enterText(find.byType(TextField), 'Submit Payload');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(submittedValue, 'Submit Payload');
    });

    testWidgets('prefixIcon and suffixIcon render correctly', (tester) async {
      await tester.pumpWidget(_wrap(
        const DSTextField(
          prefixIcon: Icons.search,
          suffixIcon: Icons.clear,
        ),
      ));

      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('onSuffixTap fires when interactive suffix icon is tapped', (tester) async {
      var suffixTapped = false;

      await tester.pumpWidget(_wrap(
        DSTextField(
          prefixIcon: Icons.lock,
          suffixIcon: Icons.visibility,
          onSuffixTap: () {
            suffixTapped = true;
          },
          suffixSemanticsLabel: 'Toggle visibility',
        ),
      ));

      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pumpAndSettle();

      expect(suffixTapped, isTrue);
    });

    testWidgets('disabled state reduces opacity and disables input', (tester) async {
      final controller = TextEditingController(text: 'Read only text');

      await tester.pumpWidget(_wrap(
        DSTextField(
          controller: controller,
          enabled: false,
          label: 'Disabled',
        ),
      ));

      final opacityWidget = tester.widget<Opacity>(find.byType(Opacity));
      expect(opacityWidget.opacity, 0.5);

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, isFalse);
    });

    testWidgets('focusing field updates focus state', (tester) async {
      final focusNode = FocusNode();

      await tester.pumpWidget(_wrap(
        DSTextField(
          focusNode: focusNode,
          label: 'Focusable',
        ),
      ));

      expect(focusNode.hasFocus, isFalse);

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      expect(focusNode.hasFocus, isTrue);

      focusNode.dispose();
    });

    testWidgets('obscureText conceals entered text', (tester) async {
      await tester.pumpWidget(_wrap(
        const DSTextField(
          obscureText: true,
          label: 'Password',
        ),
      ));

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.obscureText, isTrue);
    });

    testWidgets('multiline configuration configures maxLines and minLines', (tester) async {
      await tester.pumpWidget(_wrap(
        const DSTextField(
          maxLines: 4,
          minLines: 2,
          label: 'Notes',
        ),
      ));

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.maxLines, 4);
      expect(textField.minLines, 2);
    });

    testWidgets('PrismTextField typedef behaves identically to DSTextField', (tester) async {
      await tester.pumpWidget(_wrap(
        const PrismTextField(
          label: 'Prism Alias Test',
          hint: 'Alias hint',
        ),
      ));

      expect(find.text('Prism Alias Test'), findsOneWidget);
      expect(find.text('Alias hint'), findsOneWidget);
    });

    testWidgets('maxLength renders custom counter below field', (tester) async {
      final controller = TextEditingController(text: 'abc');

      await tester.pumpWidget(_wrap(
        DSTextField(
          controller: controller,
          label: 'Limited',
          maxLength: 10,
        ),
      ));
      await tester.pumpAndSettle();

      // Custom counter shows current length / max
      expect(find.text('3 / 10'), findsOneWidget);

      // Typing grows the counter
      await tester.enterText(find.byType(TextField), 'abcdef');
      await tester.pumpAndSettle();
      expect(find.text('6 / 10'), findsOneWidget);
    });

    testWidgets('showCounter false hides the counter', (tester) async {
      final controller = TextEditingController(text: 'abc');

      await tester.pumpWidget(_wrap(
        DSTextField(
          controller: controller,
          label: 'No Counter',
          maxLength: 10,
          showCounter: false,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('3 / 10'), findsNothing);
    });

    testWidgets('counter suppressed when error state active', (tester) async {
      final controller = TextEditingController(text: 'abc');

      await tester.pumpWidget(_wrap(
        DSTextField(
          controller: controller,
          label: 'Errored',
          maxLength: 10,
          errorText: 'Bad value',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('3 / 10'), findsNothing);
      expect(find.text('Bad value'), findsOneWidget);
    });

    testWidgets('prefix and static suffix icons carry semantics label',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const DSTextField(
          prefixIcon: Icons.lock,
          suffixIcon: Icons.info_outline,
          prefixSemanticsLabel: 'Password field icon',
          suffixSemanticsLabel: 'More information',
        ),
      ));

      // Icons render
      expect(find.byIcon(Icons.lock), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);

      // Prefix semantics propagated to the render tree (Icon.semanticLabel)
      final prefixIcon =
          tester.widget<Icon>(find.byIcon(Icons.lock).first);
      expect(prefixIcon.semanticLabel, 'Password field icon');

      final suffixIcon =
          tester.widget<Icon>(find.byIcon(Icons.info_outline).first);
      expect(suffixIcon.semanticLabel, 'More information');
    });
  });

  group('DSTextField golden tests', () {
    testWidgets('renders default state golden', (tester) async {
      await tester.pumpWidget(_wrap(
        const DSTextField(
          label: 'Golden Field',
          hint: 'Type here...',
          prefixIcon: Icons.search,
        ),
      ));
      await expectLater(
        find.byType(DSTextField),
        matchesGoldenFile('../../goldens/text_field_default.png'),
      );
    });

    testWidgets('renders error state golden', (tester) async {
      await tester.pumpWidget(_wrap(
        const DSTextField(
          label: 'Email Field',
          errorText: 'Invalid email address',
          prefixIcon: Icons.email,
        ),
      ));
      await expectLater(
        find.byType(DSTextField),
        matchesGoldenFile('../../goldens/text_field_error.png'),
      );
    });

    testWidgets('renders disabled state golden', (tester) async {
      await tester.pumpWidget(_wrap(
        const DSTextField(
          label: 'Disabled Field',
          hint: 'Cannot edit',
          enabled: false,
          prefixIcon: Icons.lock,
        ),
      ));
      await expectLater(
        find.byType(DSTextField),
        matchesGoldenFile('../../goldens/text_field_disabled.png'),
      );
    });
  });
}
