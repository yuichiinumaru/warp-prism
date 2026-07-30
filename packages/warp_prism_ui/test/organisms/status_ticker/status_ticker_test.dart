import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// Task 1508: PrismStatusTicker widget tests
///
/// Covers: single item, multi item, empty list, severity styling,
/// controller rotation, reduced-motion static strip, marquee mode.
void main() {
  List<PrismStatusTickerItem> multiItems() =>
      PrismStatusTickerFixtures.mockFeed();

  Widget harness({
    List<PrismStatusTickerItem>? items,
    PrismStatusTickerMode mode = PrismStatusTickerMode.rotate,
    PrismStatusTickerController? controller,
    Duration rotateInterval = const Duration(seconds: 3),
    bool animate = true,
    bool autoRotate = true,
    bool pauseOnHover = true,
    bool wrapInGlass = true,
    ValueChanged<int>? onIndexChanged,
    ValueChanged<PrismStatusTickerItem>? onItemTap,
    String? liveBadge = 'LIVE',
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 640,
          height: 80,
          child: PrismStatusTicker(
            items: items ?? multiItems(),
            mode: mode,
            controller: controller,
            rotateInterval: rotateInterval,
            animate: animate,
            autoRotate: autoRotate,
            pauseOnHover: pauseOnHover,
            wrapInGlass: wrapInGlass,
            onIndexChanged: onIndexChanged,
            onItemTap: onItemTap,
            liveBadge: liveBadge,
          ),
        ),
      ),
    );
  }

  group('PrismStatusTicker', () {
    testWidgets('renders multi-item rotate feed with live badge', (
      tester,
    ) async {
      await tester.pumpWidget(harness());

      expect(find.byType(PrismStatusTicker), findsOneWidget);
      expect(find.byKey(PrismStatusTicker.regionKey), findsOneWidget);
      expect(find.byKey(PrismStatusTicker.liveBadgeKey), findsOneWidget);
      expect(find.text('LIVE'), findsOneWidget);
      // First fixture item text is visible.
      expect(find.text('Tile feed healthy'), findsOneWidget);
      expect(find.byKey(PrismStatusTicker.indexLabelKey), findsOneWidget);
      expect(find.text('1/6'), findsOneWidget);
    });

    testWidgets('single item hides index label and does not auto-advance', (
      tester,
    ) async {
      final single = [
        const PrismStatusTickerItem(
          id: 'only',
          text: 'Single status',
          detail: 'ok',
          state: PrismOperationalState.healthy,
        ),
      ];
      final indices = <int>[];

      await tester.pumpWidget(
        harness(
          items: single,
          rotateInterval: const Duration(milliseconds: 50),
          onIndexChanged: indices.add,
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Single status'), findsOneWidget);
      expect(find.byKey(PrismStatusTicker.indexLabelKey), findsNothing);
      // No advance callbacks beyond optional initial listener noise.
      expect(indices.where((i) => i != 0), isEmpty);
    });

    testWidgets('empty list shows empty placeholder', (tester) async {
      await tester.pumpWidget(harness(items: const []));

      expect(find.byKey(PrismStatusTicker.emptyKey), findsOneWidget);
      expect(find.text('No status items'), findsOneWidget);
      expect(find.byKey(PrismStatusTicker.regionKey), findsNothing);
    });

    testWidgets('severity styling applies operational state colors', (
      tester,
    ) async {
      const items = [
        PrismStatusTickerItem(
          id: 'err',
          text: 'Pipeline failure',
          detail: 'critical',
          state: PrismOperationalState.error,
          source: 'RUN',
        ),
        PrismStatusTickerItem(
          id: 'ok',
          text: 'All green',
          state: PrismOperationalState.healthy,
        ),
      ];

      final controller = PrismStatusTickerController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        harness(items: items, controller: controller, autoRotate: false),
      );

      expect(find.text('Pipeline failure'), findsOneWidget);
      expect(find.text('RUN'), findsOneWidget);
      expect(find.text('critical'), findsOneWidget);

      // Status dot uses error color.
      final dots = tester.widgetList<PrismStatusDot>(
        find.byType(PrismStatusDot),
      );
      expect(dots, isNotEmpty);
      expect(dots.first.color, equals(PrismOperationalState.error.color));

      controller.advance(itemCount: items.length);
      await tester.pumpAndSettle();

      expect(find.text('All green'), findsOneWidget);
      expect(find.byKey(PrismStatusTicker.itemKey('ok')), findsOneWidget);
      // Dot under the visible healthy chip (AnimatedSwitcher may briefly keep
      // outgoing children until settled — pumpAndSettle clears them).
      final healthyChip = find.ancestor(
        of: find.byKey(PrismStatusTicker.itemKey('ok')),
        matching: find.byType(Row),
      );
      final dotsAfter = tester.widgetList<PrismStatusDot>(
        find.descendant(
          of: healthyChip.first,
          matching: find.byType(PrismStatusDot),
        ),
      );
      expect(dotsAfter, isNotEmpty);
      expect(
        dotsAfter.first.color,
        equals(PrismOperationalState.healthy.color),
      );
    });

    testWidgets('controller advances rotate index', (tester) async {
      final controller = PrismStatusTickerController();
      addTearDown(controller.dispose);
      final indices = <int>[];

      await tester.pumpWidget(
        harness(
          controller: controller,
          autoRotate: false,
          onIndexChanged: indices.add,
        ),
      );
      await tester.pump();
      indices.clear();

      expect(find.text('Tile feed healthy'), findsOneWidget);

      controller.advance(itemCount: multiItems().length);
      await tester.pump();

      expect(controller.index, 1);
      expect(find.text('P95 latency'), findsOneWidget);
      expect(indices, contains(1));
      expect(find.text('2/6'), findsOneWidget);
    });

    testWidgets('timer auto-rotates when autoRotate enabled', (tester) async {
      final indices = <int>[];

      await tester.pumpWidget(
        harness(
          rotateInterval: const Duration(milliseconds: 100),
          onIndexChanged: indices.add,
        ),
      );
      await tester.pump();
      indices.clear();

      await tester.pump(const Duration(milliseconds: 110));
      expect(indices, isNotEmpty);
      expect(indices.last, greaterThanOrEqualTo(1));
    });

    testWidgets('reduced motion shows static multi-item strip', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: harness(),
        ),
      );

      expect(find.byKey(PrismStatusTicker.staticListKey), findsOneWidget);
      // All fixture texts present (static alternative).
      expect(find.text('Tile feed healthy'), findsOneWidget);
      expect(find.text('P95 latency'), findsOneWidget);
      expect(find.text('Stale agent proofs'), findsOneWidget);
      expect(find.byKey(PrismStatusTicker.indexLabelKey), findsNothing);
    });

    testWidgets('animate:false forces static strip', (tester) async {
      await tester.pumpWidget(harness(animate: false));

      expect(find.byKey(PrismStatusTicker.staticListKey), findsOneWidget);
      expect(find.text('Pipeline failure'), findsOneWidget);
    });

    testWidgets('marquee mode builds track without throwing', (tester) async {
      await tester.pumpWidget(harness(mode: PrismStatusTickerMode.marquee));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(PrismStatusTicker), findsOneWidget);
      expect(find.byKey(PrismStatusTicker.regionKey), findsOneWidget);
      expect(find.byKey(PrismStatusTicker.trackKey), findsOneWidget);
    });

    testWidgets('pause on hover freezes auto-rotate', (tester) async {
      final controller = PrismStatusTickerController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        harness(
          controller: controller,
          rotateInterval: const Duration(milliseconds: 80),
        ),
      );
      await tester.pump();

      final region = find.byKey(PrismStatusTicker.regionKey);
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(gesture.removePointer);
      await gesture.addPointer(location: Offset.zero);
      await gesture.moveTo(tester.getCenter(region));
      await tester.pump();

      final indexAtHover = controller.index;
      await tester.pump(const Duration(milliseconds: 250));
      expect(controller.index, equals(indexAtHover));
    });

    testWidgets('item tap callback fires', (tester) async {
      PrismStatusTickerItem? tapped;
      final controller = PrismStatusTickerController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        harness(
          controller: controller,
          autoRotate: false,
          onItemTap: (item) => tapped = item,
        ),
      );

      await tester.tap(find.byKey(PrismStatusTicker.itemKey('feed-health')));
      await tester.pump();

      expect(tapped, isNotNull);
      expect(tapped!.id, 'feed-health');
    });

    testWidgets('tappable chip exposes button semantics and >=48dp target', (
      tester,
    ) async {
      final controller = PrismStatusTickerController();
      addTearDown(controller.dispose);
      final feed = multiItems();
      final first = feed.first;

      await tester.pumpWidget(
        harness(
          items: feed,
          controller: controller,
          autoRotate: false,
          onItemTap: (_) {},
        ),
      );

      final chip = find.byKey(PrismStatusTicker.itemKey(first.id));
      expect(chip, findsOneWidget);

      // Prefer exact chip label; fall back to semantics via keyed descendant.
      final byLabel = find.bySemanticsLabel(first.accessibilitySummary);
      expect(byLabel, findsOneWidget);
      final buttonSemantics = tester.getSemantics(byLabel);
      expect(buttonSemantics.flagsCollection.isButton, isTrue);
      expect(buttonSemantics.label, first.accessibilitySummary);

      // ConstrainedBox owns the WCAG 48dp minimum; InkWell fills it.
      final hitTarget = find.ancestor(
        of: chip,
        matching: find.byType(ConstrainedBox),
      );
      expect(hitTarget, findsWidgets);
      var found48 = false;
      for (final element in hitTarget.evaluate()) {
        final size = element.size;
        if (size != null && size.width >= 48 && size.height >= 48) {
          found48 = true;
          break;
        }
      }
      expect(
        found48,
        isTrue,
        reason: 'expected a >=48x48 constrained hit target',
      );
    });

    test('public model aliases and fixtures', () {
      expect(PrismStatusTickerMode.rotate.name, equals('rotate'));
      expect(PrismStatusTickerMode.marquee.name, equals('marquee'));
      expect(PrismStatusTickerFixtures.mockFeed(), hasLength(6));

      const item = PrismStatusTickerItem(
        id: 'x',
        text: 'Hello',
        detail: '1',
        state: PrismOperationalState.degraded,
        source: 'OPS',
      );
      expect(item.accessibilitySummary, contains('Hello'));
      expect(item.accentColor, equals(PrismOperationalState.degraded.color));
      // Public keys exist on the alias type.
      expect(PrismStatusTicker.regionKey, isNotNull);
      expect(PrismStatusTicker.itemKey('x'), isNotNull);
    });

    test('controller pause/resume/goTo/reset', () {
      final c = PrismStatusTickerController();
      addTearDown(c.dispose);

      c.goTo(3);
      expect(c.index, 3);
      c.pause();
      expect(c.isPaused, isTrue);
      c.resume();
      expect(c.isPaused, isFalse);
      c.advance(itemCount: 5);
      expect(c.index, 4);
      c.advance(itemCount: 5);
      expect(c.index, 0); // wrap
      c.reset();
      expect(c.index, 0);
      expect(c.isPaused, isFalse);
    });
  });
}
