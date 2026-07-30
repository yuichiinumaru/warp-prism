import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/src/atoms/atoms.dart';
import 'package:warp_prism_ui/src/molecules/molecules.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

void main() {
  Widget buildTestApp(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }

  group('DSDialog Widget Tests', () {
    testWidgets('renders title, subtitle, icon, content, and action buttons', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          const DSDialog(
            title: 'Test Dialog',
            subtitle: 'Dialog Subtitle',
            icon: Icons.info,
            content: Text('Dialog Content Text'),
            actions: [
              DSDialogAction(label: 'Cancel', variant: DSButtonVariant.secondary),
              DSDialogAction(label: 'Confirm', variant: DSButtonVariant.primary),
            ],
          ),
        ),
      );

      expect(find.text('Test Dialog'), findsOneWidget);
      expect(find.text('Dialog Subtitle'), findsOneWidget);
      expect(find.byIcon(Icons.info), findsOneWidget);
      expect(find.text('Dialog Content Text'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Confirm'), findsOneWidget);
    });

    testWidgets('action onPressed triggers callback', (tester) async {
      bool confirmTapped = false;

      await tester.pumpWidget(
        buildTestApp(
          DSDialog(
            title: 'Action Test',
            content: const Text('Content'),
            actions: [
              DSDialogAction(
                label: 'Confirm Action',
                onPressed: () {
                  confirmTapped = true;
                },
              ),
            ],
          ),
        ),
      );

      await tester.tap(find.text('Confirm Action'));
      await tester.pump();

      expect(confirmTapped, isTrue);
    });

    testWidgets('showPrismDialog helper opens dialog and returns result on pop', (tester) async {
      bool dialogOpened = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  dialogOpened = true;
                  final result = await showPrismDialog<String>(
                    context: context,
                    builder: (ctx) => DSDialog(
                      title: 'Modal Title',
                      content: const Text('Modal Body'),
                      actions: [
                        DSDialogAction(
                          label: 'OK',
                          onPressed: () => Navigator.of(ctx).pop('RESULT_OK'),
                        ),
                      ],
                    ),
                  );
                  expect(result, equals('RESULT_OK'));
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(dialogOpened, isTrue);
      expect(find.text('Modal Title'), findsOneWidget);
      expect(find.text('Modal Body'), findsOneWidget);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.text('Modal Title'), findsNothing);
    });

    testWidgets('close icon tap dismisses dialog when dismissible is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showPrismDialog(
                    context: context,
                    builder: (ctx) => const DSDialog(
                      title: 'Dismissible Dialog',
                      content: Text('Content'),
                      dismissible: true,
                    ),
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Dismissible Dialog'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.text('Dismissible Dialog'), findsNothing);
    });

    testWidgets('Escape key dismisses dialog when dismissible is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showPrismDialog(
                    context: context,
                    builder: (ctx) => const DSDialog(
                      title: 'ESC Dismiss Dialog',
                      content: Text('Content'),
                      dismissible: true,
                    ),
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('ESC Dismiss Dialog'), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(find.text('ESC Dismiss Dialog'), findsNothing);
    });

    testWidgets('Enter key triggers primary action', (tester) async {
      bool primaryTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showPrismDialog(
                    context: context,
                    builder: (ctx) => DSDialog(
                      title: 'Enter Action Dialog',
                      content: const Text('Content'),
                      actions: [
                        DSDialogAction.cancel(onPressed: () {}),
                        DSDialogAction.confirm(
                          onPressed: () {
                            primaryTriggered = true;
                          },
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(primaryTriggered, isTrue);
    });

    testWidgets('PrismDialog public alias delegates correctly to DSDialog', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          const PrismDialog(
            title: 'Alias Dialog',
            content: Text('Alias Content'),
            actions: [
              PrismDialogAction(label: 'Alias Action'),
            ],
          ),
        ),
      );

      expect(find.text('Alias Dialog'), findsOneWidget);
      expect(find.text('Alias Content'), findsOneWidget);
      expect(find.text('Alias Action'), findsOneWidget);
    });
  });
}
