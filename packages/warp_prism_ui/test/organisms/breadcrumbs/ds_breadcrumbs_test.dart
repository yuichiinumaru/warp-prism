import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

void main() {
  Widget harness({required Widget child, RouteSettings? settings}) {
    return MaterialApp(
      initialRoute: settings?.name ?? '/',
      routes: {settings?.name ?? '/': (context) => Scaffold(body: child)},
    );
  }

  group('DSBreadcrumbs / PrismBreadcrumbs', () {
    testWidgets('renders item labels with separators', (tester) async {
      const items = [
        PrismBreadcrumbItem(label: 'Home', href: '/'),
        PrismBreadcrumbItem(label: 'Projects', href: '/projects'),
        PrismBreadcrumbItem(label: 'WarpPrism'),
      ];

      await tester.pumpWidget(
        harness(child: const PrismBreadcrumbs(items: items)),
      );

      expect(find.byType(PrismBreadcrumbs), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Projects'), findsOneWidget);
      expect(find.text('WarpPrism'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsNWidgets(2));
    });

    testWidgets('renders custom separator icon', (tester) async {
      const items = [
        PrismBreadcrumbItem(label: 'A'),
        PrismBreadcrumbItem(label: 'B'),
      ];

      await tester.pumpWidget(
        harness(
          child: const PrismBreadcrumbs(
            items: items,
            separator: Icons.arrow_forward_ios,
          ),
        ),
      );
      expect(find.byIcon(Icons.arrow_forward_ios), findsOneWidget);
    });

    testWidgets('renders custom separator widget', (tester) async {
      const items = [
        PrismBreadcrumbItem(label: 'A'),
        PrismBreadcrumbItem(label: 'B'),
      ];

      await tester.pumpWidget(
        harness(
          child: const PrismBreadcrumbs(
            items: items,
            separatorWidget: Text('/'),
          ),
        ),
      );
      expect(find.text('/'), findsOneWidget);
    });

    testWidgets('last item is not interactive, prior items invoke callbacks', (
      tester,
    ) async {
      PrismBreadcrumbItem? globalTapped;
      var localTapped = false;

      final items = [
        PrismBreadcrumbItem(
          label: 'Root',
          href: '/',
          onTap: () => localTapped = true,
        ),
        const PrismBreadcrumbItem(label: 'Current'),
      ];

      await tester.pumpWidget(
        harness(
          child: PrismBreadcrumbs(
            items: items,
            onItemTap: (item) => globalTapped = item,
          ),
        ),
      );

      // Tap non-last item
      await tester.tap(find.text('Root'));
      await tester.pump();

      expect(localTapped, isTrue);
      expect(globalTapped?.label, 'Root');

      // Tap last item (should not trigger interactive surface callbacks)
      globalTapped = null;
      await tester.tap(find.text('Current'));
      await tester.pump();

      expect(globalTapped, null);
    });

    testWidgets('truncates long path when maxItems is specified', (
      tester,
    ) async {
      const items = [
        PrismBreadcrumbItem(label: 'Level 1'),
        PrismBreadcrumbItem(label: 'Level 2'),
        PrismBreadcrumbItem(label: 'Level 3'),
        PrismBreadcrumbItem(label: 'Level 4'),
        PrismBreadcrumbItem(label: 'Level 5'),
      ];

      await tester.pumpWidget(
        harness(child: const PrismBreadcrumbs(items: items, maxItems: 3)),
      );

      expect(find.text('Level 1'), findsOneWidget);
      expect(find.text('Level 5'), findsOneWidget);
      expect(find.text('Level 2'), findsNothing);
      expect(find.text('Level 3'), findsNothing);
      expect(find.byIcon(Icons.more_horiz), findsOneWidget);

      // Tap overflow button
      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();

      expect(find.text('Level 2'), findsOneWidget);
      expect(find.text('Level 3'), findsOneWidget);
      expect(find.text('Level 4'), findsOneWidget);
    });

    testWidgets('overflow popup item tap fires callback', (tester) async {
      PrismBreadcrumbItem? tapped;
      const items = [
        PrismBreadcrumbItem(label: 'L1'),
        PrismBreadcrumbItem(label: 'L2'),
        PrismBreadcrumbItem(label: 'L3'),
        PrismBreadcrumbItem(label: 'L4'),
      ];

      await tester.pumpWidget(
        harness(
          child: PrismBreadcrumbs(
            items: items,
            maxItems: 3,
            onItemTap: (item) => tapped = item,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();

      await tester.tap(find.text('L2').last);
      await tester.pumpAndSettle();

      expect(tapped?.label, 'L2');
    });

    testWidgets('renders item icon when provided', (tester) async {
      const items = [
        PrismBreadcrumbItem(label: 'Home', icon: Icons.home),
        PrismBreadcrumbItem(label: 'Settings'),
      ];

      await tester.pumpWidget(
        harness(child: const PrismBreadcrumbs(items: items)),
      );

      expect(find.byIcon(Icons.home), findsOneWidget);
    });

    testWidgets('autoDerive builds items from route name', (tester) async {
      await tester.pumpWidget(
        harness(
          settings: const RouteSettings(name: '/admin/settings/users'),
          child: const PrismBreadcrumbs(autoDerive: true),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Admin'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Users'), findsOneWidget);
    });

    testWidgets(
      'autoDerive falls back to single Home item when route is root or null',
      (tester) async {
        await tester.pumpWidget(
          harness(
            settings: const RouteSettings(name: '/'),
            child: const PrismBreadcrumbs(autoDerive: true),
          ),
        );

        expect(find.text('Home'), findsOneWidget);
        expect(find.byIcon(Icons.chevron_right), findsNothing);
      },
    );

    testWidgets(
      'semantic tree verifies active item non-button vs interactive link surface',
      (tester) async {
        const items = [
          PrismBreadcrumbItem(label: 'Home', href: '/'),
          PrismBreadcrumbItem(label: 'Current'),
        ];

        await tester.pumpWidget(
          harness(child: const PrismBreadcrumbs(items: items)),
        );

        final linkSurface = find.byWidgetPredicate(
          (widget) =>
              widget is PrismInteractiveSurface &&
              widget.semanticLabel == 'Navigate to Home',
        );
        expect(linkSurface, findsOneWidget);

        final activeItemText = find.text('Current');
        expect(activeItemText, findsOneWidget);
        expect(
          find.ancestor(
            of: activeItemText,
            matching: find.byType(PrismInteractiveSurface),
          ),
          findsNothing,
        );
      },
    );

    test('PrismBreadcrumbItem value equality and hashCode', () {
      const a = PrismBreadcrumbItem(
        label: 'Test',
        href: '/test',
        icon: Icons.star,
      );
      const b = PrismBreadcrumbItem(
        label: 'Test',
        href: '/test',
        icon: Icons.star,
      );
      const c = PrismBreadcrumbItem(
        label: 'Test2',
        href: '/test',
        icon: Icons.star,
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });
  });
}
