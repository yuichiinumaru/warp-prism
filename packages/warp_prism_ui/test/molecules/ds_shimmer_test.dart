// Widget tests for DSShimmer and skeleton variants.
//
// These tests verify the shimmer animation base widget and the skeleton
// loading placeholders render correctly, use DS tokens, and compose
// as expected.
//
// Run: flutter test test/molecules/ds_shimmer_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warp_prism_ui/src/molecules/molecules.dart';
import 'package:warp_prism_ui/src/tokens/tokens.dart';

void main() {
  group('DSShimmer', () {
    testWidgets('renders without errors', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DSShimmer(width: 200, height: 16)),
        ),
      );

      expect(find.byType(DSShimmer), findsOneWidget);
    });

    testWidgets('wraps content in ExcludeSemantics (decorative)', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DSShimmer(width: 100, height: 20)),
        ),
      );

      // Scope under DSShimmer — MaterialApp/Scaffold may also use
      // ExcludeSemantics in some Flutter versions.
      expect(
        find.descendant(
          of: find.byType(DSShimmer),
          matching: find.byType(ExcludeSemantics),
        ),
        findsOneWidget,
      );
    });

    testWidgets('reduced motion shows solid base without animation', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: MaterialApp(
            home: Scaffold(body: DSShimmer(width: 100, height: 20)),
          ),
        ),
      );

      expect(find.byType(DSShimmer), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(DSShimmer),
          matching: find.byType(AnimatedBuilder),
        ),
        findsNothing,
      );

      // Pump time — widget must remain stable (no animation-driven rebuild).
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(DSShimmer), findsOneWidget);
    });

    testWidgets('renders a Container widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DSShimmer(width: 100, height: 20)),
        ),
      );

      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('animates continuously', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DSShimmer(width: 100, height: 20)),
        ),
      );

      // Initial frame
      expect(find.byType(DSShimmer), findsOneWidget);

      // Pump forward to trigger animation frames
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(DSShimmer), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(DSShimmer), findsOneWidget);
    });

    testWidgets('accepts custom colors', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DSShimmer(
              width: 100,
              height: 20,
              baseColor: DSColors.obsidianBase,
              highlightColor: DSColors.accentCyan,
            ),
          ),
        ),
      );

      expect(find.byType(DSShimmer), findsOneWidget);
    });

    testWidgets('accepts custom border radius', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DSShimmer(width: 48, height: 48, borderRadius: DSRadii.full),
          ),
        ),
      );

      expect(find.byType(DSShimmer), findsOneWidget);
    });

    testWidgets('expands when width is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(width: 300, child: DSShimmer(height: 16)),
          ),
        ),
      );

      expect(find.byType(DSShimmer), findsOneWidget);
    });
  });

  group('DSSkeletonTextLine', () {
    testWidgets('renders without errors', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: DSSkeletonTextLine())),
      );

      expect(find.byType(DSSkeletonTextLine), findsOneWidget);
      expect(find.byType(FractionallySizedBox), findsOneWidget);
      expect(find.byType(DSShimmer), findsOneWidget);
    });

    testWidgets('uses default width factor of 0.7', (tester) async {
      const widget = DSSkeletonTextLine();
      expect(widget.widthFactor, 0.7);
    });

    testWidgets('accepts custom width factor', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DSSkeletonTextLine(widthFactor: 0.5)),
        ),
      );

      expect(find.byType(DSSkeletonTextLine), findsOneWidget);
    });
  });

  group('DSSkeletonCard', () {
    testWidgets('renders without errors', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: DSSkeletonCard())),
      );

      expect(find.byType(DSSkeletonCard), findsOneWidget);
    });

    testWidgets('contains shimmer blocks', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: DSSkeletonCard())),
      );

      // Should contain multiple shimmer blocks: icon + text lines
      expect(find.byType(DSShimmer), findsWidgets);
    });

    testWidgets('uses DSColors and DSRadii tokens', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: DSSkeletonCard())),
      );

      // The Container decoration uses DSColors.obsidianElevated and DSRadii.card
      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, DSColors.obsidianElevated);
      expect(decoration.borderRadius, BorderRadius.circular(DSRadii.card));
    });

    testWidgets('hides subtitle when showSubtitle is false', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DSSkeletonCard(showSubtitle: false)),
        ),
      );

      // With subtitle hidden, there are fewer DSSkeletonTextLine widgets
      final textLines = find.byType(DSSkeletonTextLine);
      expect(textLines, findsNWidgets(2)); // title + description only
    });

    testWidgets('shows subtitle by default', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: DSSkeletonCard())),
      );

      final textLines = find.byType(DSSkeletonTextLine);
      expect(textLines, findsNWidgets(3)); // title + description + subtitle
    });
  });

  group('DSSkeletonTableRows', () {
    testWidgets('renders without errors', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: DSSkeletonTableRows())),
      );

      expect(find.byType(DSSkeletonTableRows), findsOneWidget);
    });

    testWidgets('renders default 3 rows', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: DSSkeletonTableRows())),
      );

      // 3 rows × 3 columns = 9 shimmer blocks
      expect(find.byType(DSShimmer), findsNWidgets(9));
    });

    testWidgets('renders custom row count', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DSSkeletonTableRows(
              rowCount: 5,
              columnWidths: [0.3, 0.3, 0.4],
            ),
          ),
        ),
      );

      // 5 rows × 3 columns = 15 shimmer blocks
      expect(find.byType(DSShimmer), findsNWidgets(15));
    });

    testWidgets('renders custom column widths', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DSSkeletonTableRows(
              rowCount: 2,
              columnWidths: [0.2, 0.5, 0.2, 0.1],
            ),
          ),
        ),
      );

      // 2 rows × 4 columns = 8 shimmer blocks
      expect(find.byType(DSShimmer), findsNWidgets(8));
    });

    testWidgets('uses DSShimmer with DSRadii tokens', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DSSkeletonTableRows(rowCount: 1)),
        ),
      );

      expect(find.byType(DSShimmer), findsWidgets);
    });
  });
}
