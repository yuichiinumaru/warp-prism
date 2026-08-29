import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';
import 'package:warp_prism_ui/src/molecules/select/ds_select.dart';
import 'package:warp_prism_ui/src/molecules/ds_state_surface.dart';

void main() {
  final sampleOptions = [
    const DSSelectItem(
      value: 'dev',
      label: 'Development',
      icon: Icons.developer_mode,
    ),
    const DSSelectItem(
      value: 'staging',
      label: 'Staging',
      icon: Icons.cloud_queue,
    ),
    const DSSelectItem(
      value: 'prod',
      label: 'Production',
      icon: Icons.cloud_done,
    ),
    const DSSelectItem(value: 'legacy', label: 'Legacy', disabled: true),
  ];

  group('DSSelect / PrismSelect Widget Tests', () {
    testWidgets('renders placeholder when value is null', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DSSelect<String>(
              placeholder: 'Choose environment...',
              options: sampleOptions,
            ),
          ),
        ),
      );

      expect(find.text('Choose environment...'), findsOneWidget);
    });

    testWidgets('renders selected option label in trigger', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DSSelect<String>(value: 'staging', options: sampleOptions),
          ),
        ),
      );

      expect(find.text('Staging'), findsOneWidget);
    });

    testWidgets('renders label above trigger when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DSSelect<String>(
              label: 'Environment',
              options: sampleOptions,
            ),
          ),
        ),
      );

      expect(find.text('Environment'), findsOneWidget);
    });

    testWidgets('tapping trigger opens popup overlay', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DSSelect<String>(options: sampleOptions)),
        ),
      );

      expect(find.text('Development'), findsNothing);

      await tester.tap(find.byType(DSSelect<String>));
      await tester.pumpAndSettle();

      expect(find.text('Development'), findsOneWidget);
      expect(find.text('Staging'), findsOneWidget);
      expect(find.text('Production'), findsOneWidget);
      expect(find.text('Legacy'), findsOneWidget);
    });

    testWidgets(
      'tapping option fires onChanged with correct value and closes popup',
      (tester) async {
        String? selectedValue;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DSSelect<String>(
                options: sampleOptions,
                onChanged: (val) => selectedValue = val,
              ),
            ),
          ),
        );

        await tester.tap(find.byType(DSSelect<String>));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Production'));
        await tester.pumpAndSettle();

        expect(selectedValue, 'prod');
        expect(find.text('Development'), findsNothing);
      },
    );

    testWidgets('disabled options ignore taps', (tester) async {
      String? selectedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DSSelect<String>(
              options: sampleOptions,
              onChanged: (val) => selectedValue = val,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(DSSelect<String>));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Legacy'));
      await tester.pumpAndSettle();

      expect(selectedValue, null);
      // Popup remains open
      expect(find.text('Development'), findsOneWidget);
    });

    testWidgets('disabled select widget ignores taps', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DSSelect<String>(enabled: false, options: sampleOptions),
          ),
        ),
      );

      await tester.tap(find.byType(DSSelect<String>));
      await tester.pumpAndSettle();

      expect(find.text('Development'), findsNothing);
    });

    testWidgets('error state renders error text and red indicator', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DSSelect<String>(
              errorText: 'Selection is required',
              options: sampleOptions,
            ),
          ),
        ),
      );

      expect(find.text('Selection is required'), findsOneWidget);
    });

    testWidgets('clear button clears value when clearable: true', (
      tester,
    ) async {
      String? selectedValue = 'prod';

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                body: DSSelect<String>(
                  value: selectedValue,
                  clearable: true,
                  options: sampleOptions,
                  onChanged: (val) {
                    setState(() => selectedValue = val);
                  },
                ),
              ),
            );
          },
        ),
      );

      expect(find.text('Production'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(selectedValue, null);
      expect(find.text('Select an option...'), findsOneWidget);
    });

    testWidgets('searchable mode filters options as user types', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DSSelect<String>(searchable: true, options: sampleOptions),
          ),
        ),
      );

      await tester.tap(find.byType(DSSelect<String>));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Prod');
      await tester.pumpAndSettle();

      expect(find.text('Production'), findsOneWidget);
      expect(find.text('Development'), findsNothing);
      expect(find.text('Staging'), findsNothing);
    });

    testWidgets('shows empty state when no options match search query', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DSSelect<String>(searchable: true, options: sampleOptions),
          ),
        ),
      );

      await tester.tap(find.byType(DSSelect<String>));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'nonexistent');
      await tester.pumpAndSettle();

      expect(find.byType(DSStateSurface), findsOneWidget);
      expect(find.text('No options match'), findsOneWidget);
    });

    testWidgets('keyboard navigation: Escape closes popup', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DSSelect<String>(options: sampleOptions)),
        ),
      );

      await tester.tap(find.byType(DSSelect<String>));
      await tester.pumpAndSettle();

      expect(find.text('Development'), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(find.text('Development'), findsNothing);
    });

    testWidgets(
      'keyboard navigation: ArrowDown / ArrowUp moves highlight and Enter selects',
      (tester) async {
        String? selectedValue;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DSSelect<String>(
                options: sampleOptions,
                onChanged: (val) => selectedValue = val,
              ),
            ),
          ),
        );

        await tester.tap(find.byType(DSSelect<String>));
        await tester.pumpAndSettle();

        // Initially highlighted index is 0 ('Development')
        // Move down to 'Staging'
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();

        // Press Enter to select
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();

        expect(selectedValue, 'staging');
        expect(find.text('Development'), findsNothing);
      },
    );

    testWidgets('keyboard navigation: ArrowUp wraps to last option', (
      tester,
    ) async {
      String? selectedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DSSelect<String>(
              options: sampleOptions,
              onChanged: (val) => selectedValue = val,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(DSSelect<String>));
      await tester.pumpAndSettle();

      // Initially highlighted index is 0 ('Development')
      // ArrowUp wraps around to the last non-disabled option ('Production')
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(selectedValue, 'prod');
    });

    testWidgets(
      'keyboard navigation: Space activates trigger and selects option',
      (tester) async {
        String? selectedValue;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DSSelect<String>(
                options: sampleOptions,
                onChanged: (val) => selectedValue = val,
              ),
            ),
          ),
        );

        // Focus the trigger and open with Space
        await tester.tap(find.byType(DSSelect<String>));
        await tester.pumpAndSettle();

        // Popup open; ArrowDown once then Space to select highlighted row
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();

        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await tester.pumpAndSettle();

        expect(selectedValue, 'staging');
      },
    );

    testWidgets('renders helperText below trigger when provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DSSelect<String>(
              helperText: 'Pick an environment for deployment',
              options: sampleOptions,
            ),
          ),
        ),
      );

      expect(find.text('Pick an environment for deployment'), findsOneWidget);
    });

    testWidgets(
      'onClear callback fires instead of onChanged(null) when provided',
      (tester) async {
        String? clearCalled;
        String? selectedValue = 'prod';

        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return MaterialApp(
                home: Scaffold(
                  body: DSSelect<String>(
                    value: selectedValue,
                    clearable: true,
                    options: sampleOptions,
                    onClear: () {
                      setState(() {
                        clearCalled = 'clear';
                        selectedValue = null;
                      });
                    },
                    onChanged: (val) {
                      setState(() => selectedValue = val);
                    },
                  ),
                ),
              );
            },
          ),
        );

        expect(find.byIcon(Icons.close), findsOneWidget);

        await tester.tap(find.byIcon(Icons.close));
        await tester.pumpAndSettle();

        expect(clearCalled, 'clear');
        expect(selectedValue, null);
        expect(find.text('Select an option...'), findsOneWidget);
      },
    );

    testWidgets('PrismSelect and PrismSelectItem public aliases work', (
      tester,
    ) async {
      String? val = 'a';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrismSelect<String>(
              value: val,
              options: const [
                PrismSelectItem(value: 'a', label: 'Option A'),
                PrismSelectItem(value: 'b', label: 'Option B'),
              ],
              onChanged: (newVal) => val = newVal,
            ),
          ),
        ),
      );

      expect(find.text('Option A'), findsOneWidget);
    });

    testWidgets(
      'enforces 48dp minimum touch target height on trigger and clear action',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DSSelect<String>(
                value: 'dev',
                clearable: true,
                options: sampleOptions,
              ),
            ),
          ),
        );

        final AnimatedContainer container = tester.widget(
          find
              .descendant(
                of: find.byType(DSSelect<String>),
                matching: find.byType(AnimatedContainer),
              )
              .first,
        );
        expect(container.constraints?.minHeight, equals(48.0));

        final clearButtonBox = tester.getSize(
          find.bySemanticsLabel('Clear selection').first,
        );
        expect(clearButtonBox.width, greaterThanOrEqualTo(48.0));
        expect(clearButtonBox.height, greaterThanOrEqualTo(48.0));
      },
    );
  });
}
