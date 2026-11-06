import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/src/atoms/atoms.dart';
import 'package:warp_prism_ui/src/molecules/molecules.dart';
import 'package:warp_prism_ui/src/organisms/organisms.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

void main() {
  group('DSSearchBar / PrismSearchBar — Material Ancestry Contract (Task 1831)', () {
    testWidgets(
      'DSSearchBar mounts directly in MaterialApp without Scaffold without throwing',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: DSSearchBar(placeholder: 'Search assets...')),
        );

        expect(tester.takeException(), isNull);
        expect(find.byType(DSSearchBar), findsOneWidget);
        expect(find.byType(TextField), findsOneWidget);
      },
    );

    testWidgets(
      'PrismSearchBar mounts inside DSShellResponsive without Scaffold without throwing',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: DSShellResponsive(
              sidebar: SizedBox.shrink(),
              collapsedSidebar: SizedBox.shrink(),
              content: PrismSearchBar(placeholder: 'Search in shell...'),
            ),
          ),
        );

        expect(tester.takeException(), isNull);
        expect(find.byType(PrismSearchBar), findsOneWidget);
        expect(find.byType(TextField), findsOneWidget);
      },
    );

    testWidgets(
      'PrismSearchBar mounts in nested IndexedStack route layout without Scaffold',
      (tester) async {
        // Replicates Observatory /map route ancestry:
        // MaterialApp -> DSShellResponsive -> Column -> Expanded -> IndexedStack -> Column -> Padding -> PrismSearchBar
        await tester.pumpWidget(
          const MaterialApp(
            home: DSShellResponsive(
              sidebar: SizedBox.shrink(),
              collapsedSidebar: SizedBox.shrink(),
              content: Column(
                children: [
                  Expanded(
                    child: IndexedStack(
                      index: 0,
                      children: [
                        Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(16),
                              child: PrismSearchBar(
                                placeholder: 'Search agents...',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        expect(tester.takeException(), isNull);
        expect(find.byType(PrismSearchBar), findsOneWidget);
        expect(find.byType(TextField), findsOneWidget);
      },
    );

    testWidgets(
      'Interactive cycle without Scaffold: text input, clear button, and filter callback',
      (tester) async {
        String? currentQuery;
        var filterTapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: DSShellResponsive(
              sidebar: const SizedBox.shrink(),
              collapsedSidebar: const SizedBox.shrink(),
              content: DSSearchBar(
                placeholder: 'Type to filter...',
                onChanged: (val) => currentQuery = val,
                onFilterTap: () => filterTapped = true,
                activeFilterCount: 3,
              ),
            ),
          ),
        );

        expect(tester.takeException(), isNull);
        expect(find.byType(DSBadge), findsOneWidget);

        // Type text into the search field
        await tester.enterText(find.byType(TextField), 'cybercore');
        await tester.pump();

        expect(currentQuery, 'cybercore');
        expect(find.byIcon(DSIcons.close), findsOneWidget);

        // Tap filter button
        await tester.tap(find.byIcon(DSIcons.filter));
        await tester.pump();
        expect(filterTapped, isTrue);

        // Tap clear button
        await tester.tap(find.byIcon(DSIcons.close));
        await tester.pump();

        expect(currentQuery, '');
        expect(find.byIcon(DSIcons.close), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
