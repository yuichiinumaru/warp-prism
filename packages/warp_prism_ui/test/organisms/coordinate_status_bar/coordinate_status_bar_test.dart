import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// Task 1509: PrismCoordinateStatusBar widget tests
///
/// Covers: lat/lon display, missing coords, place/style, feed health, a11y.
void main() {
  Widget harness({
    double? latitude = PrismCoordinateStatusFixtures.defaultLatitude,
    double? longitude = PrismCoordinateStatusFixtures.defaultLongitude,
    String? placeLabel = PrismCoordinateStatusFixtures.defaultPlaceLabel,
    String? styleLabel = PrismCoordinateStatusFixtures.defaultStyleLabel,
    String? secondaryMetric,
    List<PrismCoordinateFeedHealth> feeds =
        PrismCoordinateStatusFixtures.defaultFeeds,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 720,
            height: 80,
            child: PrismCoordinateStatusBar(
              latitude: latitude,
              longitude: longitude,
              placeLabel: placeLabel,
              styleLabel: styleLabel,
              secondaryMetric: secondaryMetric,
              feeds: feeds,
            ),
          ),
        ),
      ),
    );
  }

  group('PrismCoordinateStatusBar', () {
    testWidgets('renders coordinates place style and feeds', (tester) async {
      await tester.pumpWidget(harness());

      expect(find.byType(PrismCoordinateStatusBar), findsOneWidget);
      expect(
        find.byKey(PrismCoordinateStatusBar.panelRegionKey),
        findsOneWidget,
      );
      expect(
        find.byKey(PrismCoordinateStatusBar.coordinatesKey),
        findsOneWidget,
      );
      expect(
        find.byKey(PrismCoordinateStatusBar.placeLabelKey),
        findsOneWidget,
      );
      expect(
        find.byKey(PrismCoordinateStatusBar.styleLabelKey),
        findsOneWidget,
      );
      expect(find.byKey(PrismCoordinateStatusBar.feedsRowKey), findsOneWidget);

      final expected = PrismCoordinateStatusBar.formatCoordinates(
        latitude: PrismCoordinateStatusFixtures.defaultLatitude,
        longitude: PrismCoordinateStatusFixtures.defaultLongitude,
      );
      expect(find.text(expected), findsOneWidget);
      expect(
        find.text(PrismCoordinateStatusFixtures.defaultPlaceLabel),
        findsOneWidget,
      );
      expect(
        find.text(PrismCoordinateStatusFixtures.defaultStyleLabel),
        findsOneWidget,
      );
      expect(
        find.byKey(PrismCoordinateStatusBar.feedChipKey('agents')),
        findsOneWidget,
      );
      expect(find.textContaining('Agents'), findsOneWidget);
    });

    testWidgets('missing coordinates show placeholder', (tester) async {
      await tester.pumpWidget(harness(latitude: null, longitude: null));

      expect(find.text('— · —'), findsOneWidget);
    });

    testWidgets('formatCoordinates handles southern/western hemispheres', (
      tester,
    ) async {
      final text = PrismCoordinateStatusBar.formatCoordinates(
        latitude: -33.8688,
        longitude: -151.2093,
        precision: 2,
      );
      expect(text, contains('S'));
      expect(text, contains('W'));
      expect(text, contains('33.87'));
      expect(text, contains('151.21'));
    });

    testWidgets('feed chips expose a11y labels', (tester) async {
      await tester.pumpWidget(harness());

      expect(find.bySemanticsLabel('Coordinate status bar'), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp(r'Agents, healthy')), findsOneWidget);
      expect(
        find.bySemanticsLabel(RegExp(r'Skills, degraded')),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel(RegExp(r'Alerts, offline')), findsOneWidget);
    });

    testWidgets('public aliases resolve to Prism types', (tester) async {
      const feed = PrismCoordinateFeedHealth(
        id: 'x',
        label: 'X',
        status: PrismCoordinateFeedStatus.healthy,
        count: 1,
      );
      expect(feed.status, PrismCoordinateFeedStatus.healthy);
      expect(
        PrismCoordinateStatusBar.statusColor(
          PrismCoordinateFeedStatus.degraded,
        ),
        isNotNull,
      );
      await tester.pumpWidget(harness(feeds: [feed]));
      expect(find.byType(PrismCoordinateStatusBar), findsOneWidget);
      expect(find.textContaining('X'), findsOneWidget);
    });

    testWidgets('is read-only (no interactive feed controls)', (tester) async {
      await tester.pumpWidget(harness());
      // Status bar has no IconButtons / Switch / Checkbox of its own.
      expect(find.byType(Switch), findsNothing);
      expect(find.byType(Checkbox), findsNothing);
      expect(find.byType(IconButton), findsNothing);
    });
  });
}
