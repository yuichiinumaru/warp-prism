import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/warp_prism_ui.dart';

/// Task 1122: DSSplitPane widget tests
///
/// Covers: horizontal/vertical layout, draggable divider, min/max
/// constraints, cursor hints, divider visibility.
void main() {
  Widget buildSplitHarness({
    Axis axis = Axis.horizontal,
    double initialRatio = 0.5,
    double leadingMinExtent = 100,
    double trailingMinExtent = 100,
    double? leadingMaxExtent,
    double? trailingMaxExtent,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 800,
          height: 600,
          child: DSSplitPane(
            axis: axis,
            initialRatio: initialRatio,
            leadingMinExtent: leadingMinExtent,
            trailingMinExtent: trailingMinExtent,
            leadingMaxExtent: leadingMaxExtent,
            trailingMaxExtent: trailingMaxExtent,
            leading: Container(
              key: const Key('leading'),
              color: Colors.blue,
              child: const Text('Leading'),
            ),
            trailing: Container(
              key: const Key('trailing'),
              color: Colors.red,
              child: const Text('Trailing'),
            ),
          ),
        ),
      ),
    );
  }

  group('DSSplitPane', () {
    testWidgets('renders both panes horizontally', (tester) async {
      await tester.pumpWidget(buildSplitHarness());

      expect(find.text('Leading'), findsOneWidget);
      expect(find.text('Trailing'), findsOneWidget);
      expect(find.byKey(const Key('leading')), findsOneWidget);
      expect(find.byKey(const Key('trailing')), findsOneWidget);
    });

    testWidgets('renders both panes vertically', (tester) async {
      await tester.pumpWidget(buildSplitHarness(axis: Axis.vertical));

      expect(find.text('Leading'), findsOneWidget);
      expect(find.text('Trailing'), findsOneWidget);
    });

    testWidgets('divider is present and semantically labeled', (tester) async {
      await tester.pumpWidget(buildSplitHarness());

      expect(
        find.bySemanticsLabel(RegExp('Split pane divider')),
        findsOneWidget,
      );
    });

    testWidgets('initial ratio controls pane sizes', (tester) async {
      await tester.pumpWidget(buildSplitHarness(initialRatio: 0.7));

      // Leading pane should be approximately 70% of 800px
      // (minus divider thickness of 6px, so available = 794)
      final leadingBox = tester.widget<SizedBox>(
        find
            .ancestor(
              of: find.byKey(const Key('leading')),
              matching: find.byType(SizedBox),
            )
            .first,
      );
      expect(leadingBox.width, closeTo(794 * 0.7, 1));
    });

    testWidgets('divider drag resizes panes', (tester) async {
      await tester.pumpWidget(buildSplitHarness(initialRatio: 0.5));

      final divider = find.bySemanticsLabel(RegExp('Split pane divider'));
      expect(divider, findsOneWidget);

      // Drag the divider 100px to the right
      await tester.drag(divider, const Offset(100, 0));
      await tester.pumpAndSettle();

      // Leading pane should now be larger
      final leadingBox = tester.widget<SizedBox>(
        find
            .ancestor(
              of: find.byKey(const Key('leading')),
              matching: find.byType(SizedBox),
            )
            .first,
      );
      // Original: 794 * 0.5 = 397; after +100: ~497
      expect(leadingBox.width, greaterThan(450));
    });

    testWidgets('min constraints prevent dragging below minimum', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildSplitHarness(
          initialRatio: 0.5,
          leadingMinExtent: 200,
          trailingMinExtent: 200,
        ),
      );

      final divider = find.bySemanticsLabel(RegExp('Split pane divider'));

      // Drag the divider far to the left
      await tester.drag(divider, const Offset(-300, 0));
      await tester.pumpAndSettle();

      final leadingBox = tester.widget<SizedBox>(
        find
            .ancestor(
              of: find.byKey(const Key('leading')),
              matching: find.byType(SizedBox),
            )
            .first,
      );

      // Leading should be clamped to at least 200
      expect(leadingBox.width, greaterThanOrEqualTo(200));
    });

    testWidgets('max constraints prevent dragging above maximum', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildSplitHarness(initialRatio: 0.5, leadingMaxExtent: 400),
      );

      final divider = find.bySemanticsLabel(RegExp('Split pane divider'));

      // Drag the divider far to the right
      await tester.drag(divider, const Offset(300, 0));
      await tester.pumpAndSettle();

      final leadingBox = tester.widget<SizedBox>(
        find
            .ancestor(
              of: find.byKey(const Key('leading')),
              matching: find.byType(SizedBox),
            )
            .first,
      );

      // Leading should be clamped to at most 400
      expect(leadingBox.width, lessThanOrEqualTo(400));
    });

    testWidgets('vertical split uses height instead of width', (tester) async {
      await tester.pumpWidget(
        buildSplitHarness(axis: Axis.vertical, initialRatio: 0.6),
      );

      final leadingBox = tester.widget<SizedBox>(
        find
            .ancestor(
              of: find.byKey(const Key('leading')),
              matching: find.byType(SizedBox),
            )
            .first,
      );

      // In vertical mode, height should be set
      expect(leadingBox.height, isNotNull);
      expect(leadingBox.height, closeTo(594 * 0.6, 1)); // 600 - 6 divider
    });

    testWidgets('horizontal divider shows resize column cursor', (
      tester,
    ) async {
      await tester.pumpWidget(buildSplitHarness());

      final mouseRegion = tester.widget<MouseRegion>(
        find
            .descendant(
              of: find.bySemanticsLabel(RegExp('Split pane divider')),
              matching: find.byType(MouseRegion),
            )
            .first,
      );

      expect(mouseRegion.cursor, SystemMouseCursors.resizeColumn);
    });

    testWidgets('vertical divider shows resize row cursor', (tester) async {
      await tester.pumpWidget(buildSplitHarness(axis: Axis.vertical));

      final mouseRegion = tester.widget<MouseRegion>(
        find
            .descendant(
              of: find.bySemanticsLabel(RegExp('Split pane divider')),
              matching: find.byType(MouseRegion),
            )
            .first,
      );

      expect(mouseRegion.cursor, SystemMouseCursors.resizeRow);
    });

    testWidgets('divider drag works vertically', (tester) async {
      await tester.pumpWidget(
        buildSplitHarness(axis: Axis.vertical, initialRatio: 0.5),
      );

      final divider = find.bySemanticsLabel(RegExp('Split pane divider'));

      // Drag divider downward
      await tester.drag(divider, const Offset(0, 50));
      await tester.pumpAndSettle();

      final leadingBox = tester.widget<SizedBox>(
        find
            .ancestor(
              of: find.byKey(const Key('leading')),
              matching: find.byType(SizedBox),
            )
            .first,
      );

      // Original: 594 * 0.5 = 297; after +50: ~347
      expect(leadingBox.height, greaterThan(320));
    });
  });
}
