import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/src/atoms/atoms.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

void main() {
  setUp(() {
    PrismTokenRegistry.instance.reset();
  });

  tearDown(() {
    PrismTokenRegistry.instance.reset();
  });

  Future<String?> readClipboardText() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    return data?.text;
  }

  Widget buildHarness() {
    return MaterialApp(
      theme: PrismTheme.dark(),
      home: const Scaffold(
        body: Center(
          child: SizedBox(width: 400, height: 700, child: PrismThemeEditor()),
        ),
      ),
    );
  }

  group('PrismThemeEditor', () {
    testWidgets('renders title, categories, preset chips, and role fields', (
      tester,
    ) async {
      await tester.pumpWidget(buildHarness());

      expect(find.text('Prism Theme Editor'), findsOneWidget);
      expect(find.text('Export Snippet'), findsOneWidget);
      expect(find.text('Reset Defaults'), findsOneWidget);
      expect(find.text('Obsidian Blue'), findsOneWidget);
      expect(find.text('Nerazim Teal'), findsOneWidget);
      expect(find.text('ACCENT & FOCUS'), findsOneWidget);

      await tester.dragUntilVisible(
        find.text('SURFACES'),
        find.byType(ListView),
        const Offset(0, -100),
      );
      expect(find.text('SURFACES'), findsOneWidget);
    });

    testWidgets('applying preset chip updates registry colors', (tester) async {
      await tester.pumpWidget(buildHarness());

      await tester.tap(find.text('Nerazim Teal'));
      await tester.pump();

      expect(
        PrismTokenRegistry.instance.accentBlue,
        equals(const Color(0xFF00FFCC)),
      );
      expect(PrismTokenRegistry.instance.hasOverrides, isTrue);
    });

    testWidgets('reset button restores registry to default values', (
      tester,
    ) async {
      PrismTokenRegistry.instance.setColor(
        PrismColorRole.accentBlue,
        const Color(0xFFFF0000),
      );

      await tester.pumpWidget(buildHarness());
      expect(find.text('Reset Defaults'), findsOneWidget);

      await tester.tap(find.text('Reset Defaults'));
      await tester.pump();

      expect(
        PrismTokenRegistry.instance.accentBlue,
        equals(const Color(0xFF2F81FF)),
      );
      expect(PrismTokenRegistry.instance.hasOverrides, isFalse);
    });

    testWidgets('export snippet button opens dialog with code snippet', (
      tester,
    ) async {
      await tester.pumpWidget(buildHarness());

      await tester.tap(find.text('Export Snippet'));
      await tester.pumpAndSettle();

      expect(find.text('Bake-Back Code Snippet'), findsOneWidget);
      expect(find.text('Copy to Clipboard'), findsOneWidget);
      expect(
        find.textContaining('Converged Theme Token Values'),
        findsOneWidget,
      );
    });

    testWidgets('hex input updates registry when valid hex entered', (
      tester,
    ) async {
      await tester.pumpWidget(buildHarness());

      // Find the first DSTextField (accentBlue field)
      final textFieldFinder = find.byType(DSTextField).first;
      await tester.enterText(textFieldFinder, '#00FFCC');
      await tester.pump();

      expect(
        PrismTokenRegistry.instance.accentBlue,
        equals(const Color(0xFF00FFCC)),
      );
    });

    testWidgets('shows error state when invalid hex entered', (tester) async {
      await tester.pumpWidget(buildHarness());

      final textFieldFinder = find.byType(DSTextField).first;
      await tester.enterText(textFieldFinder, 'invalid-hex');
      await tester.pump();

      expect(
        find.text('Invalid hex (use #RGB, #RRGGBB, #AARRGGBB)'),
        findsOneWidget,
      );
    });

    testWidgets('per-role copy-hex action copies hex and shows feedback', (
      tester,
    ) async {
      final semanticsHandle = tester.ensureSemantics();
      var clipboardText = '';
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
            if (call.method == 'Clipboard.setData') {
              clipboardText =
                  (call.arguments as Map<Object?, Object?>)['text'] as String;
            }
            if (call.method == 'Clipboard.getData') {
              return <String, String>{'text': clipboardText};
            }
            return null;
          });
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, null),
      );
      await tester.pumpWidget(buildHarness());

      final copyButton = find.byKey(const ValueKey('copy-hex-accentBlue'));
      expect(copyButton, findsOneWidget);

      final semantics = tester.getSemantics(
        find.ancestor(of: copyButton, matching: find.byType(Semantics)).first,
      );
      expect(semantics.flagsCollection.isButton, isTrue);
      expect(semantics.label, contains('Copy hex for Primary Accent (Blue)'));

      await tester.tap(copyButton);
      await tester.pump();
      semanticsHandle.dispose();

      expect(await readClipboardText(), '#2F81FF');
      expect(
        find.textContaining('Copied #2F81FF for Primary Accent (Blue)'),
        findsOneWidget,
      );
    });

    testWidgets(
      'per-role actions and preset chips satisfy 48x48 touch targets',
      (tester) async {
        final semanticsHandle = tester.ensureSemantics();
        PrismTokenRegistry.instance.setColor(
          PrismColorRole.accentBlue,
          const Color(0xFFFF0000),
        );

        await tester.pumpWidget(buildHarness());

        final copyFinder = find.byKey(const ValueKey('copy-hex-accentBlue'));
        final copySize = tester.getSize(copyFinder);
        expect(copySize.width, greaterThanOrEqualTo(48.0));
        expect(copySize.height, greaterThanOrEqualTo(48.0));
        final copySemantics = tester.getSemantics(
          find.ancestor(of: copyFinder, matching: find.byType(Semantics)).first,
        );
        expect(copySemantics.flagsCollection.isButton, isTrue);

        final resetFinder = find.byKey(const ValueKey('reset-role-accentBlue'));
        final resetSize = tester.getSize(resetFinder);
        expect(resetSize.width, greaterThanOrEqualTo(48.0));
        expect(resetSize.height, greaterThanOrEqualTo(48.0));
        final resetSemantics = tester.getSemantics(
          find
              .ancestor(of: resetFinder, matching: find.byType(Semantics))
              .first,
        );
        expect(resetSemantics.flagsCollection.isButton, isTrue);
        expect(
          resetSemantics.label,
          contains('Reset Primary Accent (Blue) to default'),
        );

        final presetLabel = find.text('Obsidian Blue');
        final presetSemantics = tester.getSemantics(
          find
              .ancestor(of: presetLabel, matching: find.byType(Semantics))
              .first,
        );
        expect(presetSemantics.flagsCollection.isButton, isTrue);
        expect(presetSemantics.label, contains('Apply Obsidian Blue preset'));
        final presetTarget = find.ancestor(
          of: find.text('Obsidian Blue'),
          matching: find.byType(ConstrainedBox),
        );
        expect(presetTarget, findsWidgets);
        expect(
          presetTarget.evaluate().any((element) {
            final size = element.size;
            return size != null && size.width >= 48 && size.height >= 48;
          }),
          isTrue,
        );
        semanticsHandle.dispose();
      },
    );
  });
}
